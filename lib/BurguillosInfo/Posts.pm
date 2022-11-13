package BurguillosInfo::Posts;

use v5.34.1;

use strict;
use warnings;

use Data::Dumper;

use Const::Fast;
use Mojo::DOM;
use Path::Tiny;
use DateTime::Format::ISO8601;
use SVG;
use Capture::Tiny qw/capture/;

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
    for my $post_file ( sort { $b cmp $a } $POSTS_DIR->children ) {
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
    return ( $cached_posts_by_category, $cached_posts_by_slug );
}

sub PostPreviewOg {
    my $self    = shift;
    my $post    = shift;
    my $title   = $post->{title};
    my $content = $post->{content};
    my $dom     = Mojo::DOM->new($content);
    $content = $dom->all_text;

    my @content_divided_in_lines = split /\n/, $content;
    my @new_content;
    my $n_chars_per_line = 60;

    for my $line (@content_divided_in_lines) {
        if ( length($line) <= $n_chars_per_line ) {
            push @new_content, $line;
            next;
        }
        while ( $line =~ /(.{1,${n_chars_per_line}})/g ) {
            my $new_line = $1;
            push @new_content, $new_line;
        }
    }
    my $svg = $self->_GenerateSVGPostPreview( $title, \@new_content );
    my ($stdout) = capture {
    	open my $fh, '|-', qw{convert /dev/stdin png:fd:1};
	binmode ':utf8', $fh;
	print $fh $svg;
	close $fh;
    };
    return $stdout; 
}

sub _GenerateSVGPostPreview {
    my $self    = shift;
    my $title   = shift;
    my $content = shift;
    my @content = @$content;
    my $svg     = SVG->new( width => 1200, height => 627 );
    $svg->rect(
        x      => 0,
        y      => 0,
        width  => 1200,
        height => 50,
        style  => { fill => 'blueviolet' }
    );
    $svg->rect(
        x      => 0,
        y      => 50,
        width  => 1200,
        height => 627,
        style  => { fill => '#F8F8FF' }
    );

    my $group = $svg->group(
        id    => 'group',
        style => {
            font        => 'Arial',
            'font-size' => 30,
        }
    );
    $group->text(
	x => 10,
	y => 40,
    	style => { 'font-size' => 50, fill => '#f2eb8c' }
    )->cdata('Burguillos.info');

    $group->text(
        x     => 10,
        y     => 100,
        style => { 'font-size' => 50 }
    )->cdata($title);

    my $n = 0;
    for my $line (@content) {
        $group->text(
            x     => 10,
            y     => 140 + ( 30 * $n ),
            style => { 'font-size' => 38 }
        )->cdata($line);
        $n++;
    }
    return $svg->xmlify;
}

1;
