package BurguillosInfo::Posts;

use v5.34.1;

use strict;
use warnings;

use feature 'signatures';

use Data::Dumper;
use MIME::Base64;

use BurguillosInfo::Categories;

use Const::Fast;
use Mojo::DOM;
use Path::Tiny;
use DateTime::Format::ISO8601;
use DateTime;

use BurguillosInfo::Preview;

const my $CURRENT_FILE => __FILE__;
const my $ROOT_PROJECT => path($CURRENT_FILE)->parent->parent->parent;
const my $PUBLIC_DIR   => $ROOT_PROJECT->child('public');
const my $POSTS_DIR    => $ROOT_PROJECT->child('content/posts');

my $cached_posts_by_category;
my $cached_posts_by_slug;

sub new {
    return bless {}, shift;
}

sub _ReturnCacheFilter {
    my $self = shift;
    my %posts_by_category_filtered;
    my %posts_by_slug_filtered;
    my $iso8601      = DateTime::Format::ISO8601->new;
    my $current_date = DateTime->now;
    for my $category ( keys %$cached_posts_by_category ) {
        for my $post ( @{ $cached_posts_by_category->{$category} } ) {
            my $date_post;
            eval { $date_post = $iso8601->parse_datetime( $post->{date} ); };
            if ($@) {
                print Data::Dumper::Dumper $post;
            }
            if ( $date_post > $current_date ) {
                next;
            }
            $posts_by_slug_filtered{ $post->{slug} } = $post;
            $posts_by_category_filtered{ $post->{category} } //= [];
            push @{ $posts_by_category_filtered{ $post->{category} } }, $post;
        }
    }
    return ( \%posts_by_category_filtered, \%posts_by_slug_filtered );
}

sub _GeneratePostFromFile ( $self, $post_file ) {
    warn "Bad file $post_file, omiting...", return
      if !-f $post_file || $post_file !~ /\.xml$/;
    my $dom   = Mojo::DOM->new( $post_file->slurp_utf8 );
    my $title = $dom->at(':root > title')->text
      or die "Missing title at $post_file.";
    my $author = $dom->at(':root > author')->text
      or die "Missing author at $post_file.";
    my $date = $dom->at(':root > date')->text
      or die "Missing date at $post_file.";
    my $ogdesc = $dom->at(':root > ogdesc')->text
      or die "Missing ogdesc at $post_file";
    my $category = $dom->at(':root > category')->text
      or die "Missing category at $post_file.";
    my $slug = $dom->at(':root > slug')->text
      or die "Missing slug at $post_file.";
    my $content = $dom->at(':root > content')->content
      or die "Missing content at $post_file.";
    my $pinned_node   = $dom->at(':root > pinned');
    my $image_element = $dom->at(':root > img');
    my $image;
    my $image_bottom_preview;
    my $attributes = $self->_GetAttributes( $post_file, $dom );

    my $pinned;
    if ( defined $pinned_node ) {
        $pinned = int( $pinned_node->text );
    }
    if ( defined $image_element ) {
        $image                = $image_element->attr->{src};
        $image_bottom_preview = $image_element->attr->{'bottom-preview'};
    }

    my $last_modification_date_element =
      $dom->at(':root > last_modification_date');
    my $last_modification_date;
    if ( defined $last_modification_date_element ) {
        $last_modification_date = $last_modification_date_element->content;
    }

    return {
        title                => $title,
        author               => $author,
        date                 => $date,
        ogdesc               => $ogdesc,
        category             => $category,
        slug                 => $slug,
        content              => $content,
        attributes           => $attributes,
        image_bottom_preview => $image_bottom_preview,
        (
              ( defined $last_modification_date )
            ? ( last_modification_date => $last_modification_date )
            : ()
        ),
        ( ( defined $image ) ? ( image => $image ) : () ),
        (
              ( defined $pinned ) ? ( pinned => $pinned )
            : ()
        )
    };
}

sub _GetAttributes ( $self, $post_file, $dom ) {
    my $attributes_tag = $dom->at(':root > attributes');
    my %attributes;
    if ( defined $attributes_tag ) {
        my @attribute_list =
          $attributes_tag->find('attributes > attribute')->map('text')->each;
        %attributes = map {
            my $identifier = $_;
            ( $identifier => 1 );
        } @attribute_list;
    }
    return \%attributes;

}

sub _GeneratePostCache ($self) {
    $cached_posts_by_category = {};
    $cached_posts_by_slug     = {};
    for my $post_file ( sort { $b cmp $a } $POSTS_DIR->children ) {
        my $post = $self->_GeneratePostFromFile($post_file);
        if ( !defined $post ) {
            next;
        }
        my $category = $post->{category};
        $cached_posts_by_category->{$category} //= [];
        my $slug           = $post->{slug};
        my $category_posts = $cached_posts_by_category->{$category};
        $cached_posts_by_slug->{$slug} = $post;
        push @$category_posts, $post;
    }
}

sub Retrieve {
    my $self = shift;
    if ( defined $cached_posts_by_category && defined $cached_posts_by_slug ) {
        return $self->_ReturnCacheFilter;
    }
    $self->_GeneratePostCache();
    return $self->_ReturnCacheFilter;
}

my $cache_all_post_categories = {};

sub RetrieveAllPostsForCategory ( $self, $category_name ) {
    my $categories = BurguillosInfo::Categories->new->Retrieve;
    my $category   = $categories->{$category_name};
    if ( defined $cache_all_post_categories->{$category_name} ) {
        my $posts = $cache_all_post_categories->{$category_name};
        return $self->shufflePostsIfRequired( $category, $posts );
    }
    my $posts = $self->RetrieveDirectPostsForCategory($category_name);
    for my $child_category ( $category->{children}->@* ) {
        my $child_category_name = $child_category->{slug};
        push @$posts,
          @{ $self->RetrieveDirectPostsForCategory($child_category_name) };
    }
    @$posts = sort {
        DateTime::Format::ISO8601->parse_datetime( $b->{date} )
          <=> DateTime::Format::ISO8601->parse_datetime( $a->{date} )
    } @$posts;
    $cache_all_post_categories->{$category_name} = $posts;
    return $self->shufflePostsIfRequired( $category, $posts );
}

sub shufflePostsIfRequired ( $self, $category, $posts ) {
    my $pinned_posts = [
        sort { $b->{pinned} <=> $b->{pinned} }
        grep { exists $_->{pinned} } @$posts
    ];
    $posts        = [ grep { !exists $_->{pinned} } @$posts ];
    $pinned_posts = [ sort { $b <=> $a } @$pinned_posts ];
    if ( exists $category->{random} && $category->{random} ) {
        require List::AllUtils;
        $posts = [ List::AllUtils::shuffle @$posts ];
    }
    return [ @$pinned_posts, @$posts ];
}

sub RetrieveDirectPostsForCategory ( $self, $category_name ) {
    my ($post_by_category) = $self->Retrieve;
    my $categories         = BurguillosInfo::Categories->new->Retrieve;
    my $category           = $categories->{$category_name};
    if ( !defined $category ) {
        die "$category_name category does not exists";
    }
    my $posts = $post_by_category->{$category_name};
    $posts //= [];
    return [@$posts];
}

sub PreviewOg {
    my $self                 = shift;
    my $post                 = shift;
    my $title                = $post->{title};
    my $content              = $post->{content};
    my $image_file           = $post->{image};
    my $image_bottom_preview = $post->{image_bottom_preview};
    return BurguillosInfo::Preview->Generate( $title, $content, $image_file,
        $image_bottom_preview );
}
1;
