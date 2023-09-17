package BurguillosInfo::Preview;

use v5.36.0;

use strict;
use warnings;

use feature 'signatures';

use SVG;
use Path::Tiny;

use Const::Fast;
use Capture::Tiny qw/capture/;
use MIME::Base64;

const my $CURRENT_FILE    => __FILE__;
const my $ROOT_PROJECT    => path($CURRENT_FILE)->parent->parent->parent;
const my $PUBLIC_DIR      => $ROOT_PROJECT->child('public');
const my $BURGUILLOS_LOGO => $PUBLIC_DIR->child('img/burguillos-new-logo.svg');
const my $SVG_WIDTH       => 1200;
const my $SVG_HEIGHT      => 627;
const my $SVG_EMBEDDED_IMAGE_MAX_WIDTH  => 1200;
const my $SVG_EMBEDDED_IMAGE_MAX_HEIGHT => 400;

sub Generate($self, $title, $content, $image_file = undef, $image_bottom_preview = undef) {
    my $dom     = Mojo::DOM->new($content);
    $content = $dom->all_text;


    my $svg =
      $self->_GenerateSVGPreview( $title, $self->_DivideTextContentInLines($content), $image_file, $image_bottom_preview );
    return $self->_SVGToPNG($svg);
}

sub _ToPng($self, $image) {
    if ($image =~ /\.\w+$/) {
        my $new_image = $image =~ s/\.\w+$/.generated.png/r;
        say $new_image;
        if (!-e $new_image) {
            system 'convert', '-background', 'none', "$image", "$new_image";
        }
        $image = $new_image;
    }
    return path($image);
}

sub _GenerateSVGPreviewHeaderBar($self, $svg, $group) {
    $group->rect(
        x      => 0,
        y      => 0,
        width  => 1200,
        height => 50,
        style  => { fill => 'blueviolet' }
    );
    $group->rect(
        x      => 0,
        y      => 50,
        width  => 1200,
        height => 627,
        style  => { fill => '#F8F8FF' }
    );


    my $burguillos_logo_png = path($self->_ToPng($BURGUILLOS_LOGO));
    say $burguillos_logo_png;
    say ''.$burguillos_logo_png;
    $group->image(
        x      => 10,
        y      => 5,
        width  => 40,
        height => 40,
        -href  => 'data:image/png;base64,'
          . encode_base64( $burguillos_logo_png->slurp )
    );
    $group->text(
        x     => 60,
        y     => 40,
        style => { 'font-size' => 50, fill => '#f2eb8c' }
    )->cdata('Burguillos.info');
}

sub _GenerateSVGPreview($self, $title, $content, $image_file, $image_bottom_preview) {
    my @content = @$content;
    my $svg     = SVG->new( width => $SVG_WIDTH, height => $SVG_HEIGHT );

    my $group = $svg->group(
        id    => 'group',
        style => {
            font        => 'Arial',
            'font-size' => 30,
        }
    );

    $self->_GenerateSVGPreviewHeaderBar($svg, $group);

    my $new_y;

    if ( defined $image_file ) {
        $new_y = $self->_AttachImageSVG( $svg, $group, $image_file, $image_bottom_preview );
    }

    $new_y //= 100;
    $group->text(
        x     => 10,
        y     => $new_y,
        style => { 'font-size' => 42 }
    )->cdata($title);

    my $n = 0;
    for my $line (@content) {
	next if $line =~ /^\s*$/;
        $group->text(
            x     => 10,
            y     => $new_y + 40 + ( 30 * $n ),
            style => { 'font-size' => 32 }
        )->cdata($line);
        $n++;
	last if $n > 2;
    }
    return $svg->xmlify;
}

sub _SVGToPNG($self, $svg) {
    path('a.svg')->spew_utf8($svg);
    my ( $stdout, $stderr ) = capture {
        open my $fh, '|-', qw{convert /dev/stdin png:fd:1};
        binmode $fh, 'utf8';
        print $fh $svg;
        close $fh;
    };
    say STDERR $stderr;
    return $stdout;
}

sub _DivideTextContentInLines($self, $content) {
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
    return \@new_content;
}

sub _AttachImageSVG($self, $svg, $group, $image_file, $image_bottom_preview) {
    $image_file = $PUBLIC_DIR->child( './' . $image_file );
    $image_file = path($self->_ToPng($image_file));
    my ( $stdout, $stderr, $error ) = capture {
        system qw/identify -format "%wx%h"/, $image_file;
    };
    if ($error) {
        warn "$image_file not recognized by identify.";
        return;
    }
    my ( $width, $height ) = $stdout =~ /^"(\d+)x(\d+)"$/;
    $height = int($height * 1200 / $width);
    $width = 1200;
    my $height_complete_image = (1200 / $width) * $height;

    if ( $height > $SVG_EMBEDDED_IMAGE_MAX_HEIGHT ) {
        $width /= $height / $SVG_EMBEDDED_IMAGE_MAX_HEIGHT;
        $width  = int($width);
        $height = $SVG_EMBEDDED_IMAGE_MAX_HEIGHT;
    }

    if ( $width > $SVG_EMBEDDED_IMAGE_MAX_WIDTH ) {
        $height /= $width / $SVG_EMBEDDED_IMAGE_MAX_WIDTH;
        $height = int($height);
        $width  = $SVG_EMBEDDED_IMAGE_MAX_WIDTH;
    }

    my $defs = $svg->defs();
    my $clip_path = $defs->clipPath(id => 'cut-top');
    $clip_path->rect(x => 0, y => 50, width => 1200, height => $height);

    my $x        = 0;
    my $y_image  = 50 - $height_complete_image + $height;
    if (defined $image_bottom_preview && $height_complete_image > $SVG_EMBEDDED_IMAGE_MAX_HEIGHT) {
	$y_image += $height_complete_image - $image_bottom_preview;
    }
    my $y = 50;
    my ($output) = capture {
        system qw/file --mime-type/, $image_file;
    };
    my ($format) = $output =~ /(\S+)$/;
    $group->image(
        x      => 0,
        y      => $y_image,
        width  => $SVG_WIDTH,
        height => $height_complete_image,
        -href  => "data:$format;base64," . encode_base64( $image_file->slurp ),
	'clip-path' => 'url(#cut-top)',
    );
    $group->rect(
        x      => 0,
        y      => $y+$height,
        width  => $SVG_WIDTH,
        height => $SVG_HEIGHT,
        style => { fill => 'azure' },
    );
    return $y + $height + 50;
}

1;
