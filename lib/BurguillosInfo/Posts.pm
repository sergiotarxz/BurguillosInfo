package BurguillosInfo::Posts;

use v5.34.1;

use strict;
use warnings;

use Data::Dumper;
use MIME::Base64;

use Const::Fast;
use Mojo::DOM;
use Path::Tiny;
use DateTime::Format::ISO8601;
use SVG;
use Capture::Tiny qw/capture/;

const my $CURRENT_FILE    => __FILE__;
const my $ROOT_PROJECT    => path($CURRENT_FILE)->parent->parent->parent;
const my $PUBLIC_DIR      => $ROOT_PROJECT->child('public');
const my $POSTS_DIR       => $ROOT_PROJECT->child('content/posts');
const my $BURGUILLOS_LOGO => $PUBLIC_DIR->child('img/burguillos.png');
const my $SVG_WIDTH       => 1200;
const my $SVG_HEIGHT      => 627;
const my $SVG_EMBEDDED_IMAGE_MAX_WIDTH  => 1000;
const my $SVG_EMBEDDED_IMAGE_MAX_HEIGHT => 200;

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
        my $image_element = $dom->at(':root > img');
	my $image;
	if (defined $image_element) {
		$image = $image_element->attr->{src};
	}

        my $post = {
            title    => $title,
            author   => $author,
            date     => $date,
            ogdesc   => $ogdesc,
            category => $category,
            slug     => $slug,
            content  => $content,
            ( ( defined $image ) ? ( image => $image ) : () ),
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
    my $n_chars_per_line = 70;

    for my $line (@content_divided_in_lines) {
        if ( length($line) <= $n_chars_per_line ) {
            push @new_content, $line;
            next;
        }
        my $last_word = '';
        while ( $line =~ /(.{1,${n_chars_per_line}})/g ) {
            my $new_line = $last_word . $1;
            $new_line =~ s/(\S*)$//;
            $last_word = $1;
            push @new_content, $new_line;
        }
        if ($last_word) {
            $new_content[$#new_content] .= $last_word;
        }
    }

    my $svg =
      $self->_GenerateSVGPostPreview( $title, \@new_content, $post->{image} );
    my ( $stdout, $stderr ) = capture {
        open my $fh, '|-', qw{convert /dev/stdin png:fd:1};
        print $fh $svg;
        close $fh;
    };
    say STDERR $stderr;
    return $stdout;
}

sub _AttachImageSVG {
    my $self  = shift;
    my $svg   = shift;
    my $image = shift;
    $image = $PUBLIC_DIR->child( './' . $image );
    my ( $stdout, $stderr, $error ) = capture {
        system qw/identify -format "%wx%h"/, $image;
    };
    if ($error) {
        warn "$image not recognized by identify.";
        return;
    }
    my ( $width, $height ) = $stdout =~ /^"(\d+)x(\d+)"$/;
    if ( $height > $SVG_EMBEDDED_IMAGE_MAX_HEIGHT ) {
        $width /= $height / $SVG_EMBEDDED_IMAGE_MAX_HEIGHT;
	$width = int($width);
        $height = $SVG_EMBEDDED_IMAGE_MAX_HEIGHT;
    }

    if ( $width > $SVG_EMBEDDED_IMAGE_MAX_WIDTH ) {
        $height /= $width / $SVG_EMBEDDED_IMAGE_MAX_WIDTH;
	$height = int($height);
        $width = $SVG_EMBEDDED_IMAGE_MAX_WIDTH;
    }

    my $x = int(($SVG_WIDTH/2) - ($width / 2));
    my $y = 90;
    my ($output) = capture {
    	system qw/file --mime-type/, $image;
    };
    my ($format) = $output =~ /(\S+)$/;
    $svg->image(
        x      => $x,
        y      => $y,
        width  => $width,
        height => $height,
        -href  => "data:$format;base64,"
          . encode_base64( $image->slurp )
    );
    return $y + $height + 50;
}

sub _GenerateSVGPostPreview {
    my $self    = shift;
    my $title   = shift;
    my $content = shift;
    my $image   = shift;
    my @content = @$content;
    my $svg     = SVG->new( width => $SVG_WIDTH, height => $SVG_HEIGHT );
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

    $group->image(
        x      => 10,
        y      => 5,
        width  => 40,
        height => 40,
        -href  => 'data:image/png;base64,'
          . encode_base64( $BURGUILLOS_LOGO->slurp )
    );
    $group->text(
        x     => 60,
        y     => 40,
        style => { 'font-size' => 50, fill => '#f2eb8c' }
    )->cdata('Burguillos.info');
    my $new_y;

    if ( defined $image ) {
        $new_y = $self->_AttachImageSVG( $group, $image );
    }
    $new_y //= 100;
    $group->text(
        x     => 10,
        y     => $new_y,
        style => { 'font-size' => 50 }
    )->cdata($title);

    my $n = 0;
    for my $line (@content) {
        $group->text(
            x     => 10,
            y     => $new_y + 40 + ( 30 * $n ),
            style => { 'font-size' => 38 }
        )->cdata($line);
        $n++;
    }
    return $svg->xmlify;
}

1;
