package BurguillosInfo::Posts;

use v5.34.1;

use strict;
use warnings;

use Const::Fast;
use Mojo::DOM;
use Path::Tiny;
use DateTime::Format::ISO8601;

use Data::Dumper;

const my $CURRENT_FILE => __FILE__;
const my $POSTS_DIR =>
  path($CURRENT_FILE)->parent->parent->parent->child('content/posts');

my $iso8601 = DateTime::Format::ISO8601->new;

my $cached_posts_by_category;
my $cached_posts_by_slug;

sub new {
    return bless {}, shift;
}

sub Retrieve {
    if ( defined $cached_posts_by_category && defined $cached_posts_by_slug ) {
        return ( $cached_posts_by_category, $cached_posts_by_slug );
    }
    $cached_posts_by_category = {};
    $cached_posts_by_slug     = {};
    for my $post_file ( $POSTS_DIR->children ) {
        warn "Bad file $post_file, omiting...", next
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

        my $post = {
            title    => $title,
            author   => $author,
            date     => $date,
            ogdesc   => $ogdesc,
            category => $category,
            slug     => $slug,
            content  => $content,
        };
	$cached_posts_by_category->{$category} //= [];
        my $category_posts = $cached_posts_by_category->{$category};
	$cached_posts_by_slug->{$slug} = $post;
	push @$category_posts, $post;
    }
    return ($cached_posts_by_category, $cached_posts_by_slug);
}

1;
