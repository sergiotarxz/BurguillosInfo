package BurguillosInfo::Categories;

use v5.34.1;

use strict;
use warnings;

use Const::Fast;
use Mojo::DOM;
use Path::Tiny;

const my $CURRENT_FILE => __FILE__;
const my $CATEGORIES_DIR =>
  path($CURRENT_FILE)->parent->parent->parent->child('content/categories');

my $cached_categories;

sub new {
    return bless {}, shift;
}

sub Retrieve {
    if ( defined $cached_categories ) {
        return $cached_categories;
    }
    $cached_categories = {};
    for my $category_file ( $CATEGORIES_DIR->children ) {
        warn "Bad file $category_file, omiting...", next
          if !-f $category_file || $category_file !~ /\.xml$/;
        my $dom   = Mojo::DOM->new( $category_file->slurp_utf8 );
        my $title = $dom->at(':root > title')->text
          or die "Missing title at $category_file.";
        my $description = $dom->at(':root > description')->content
          or die "Missing description at $category_file";
        my $slug = $dom->at(':root > slug')->text
          or die "Missing slug at $category_file";
        my $menu_text = $dom->at(':root > menu_text')->content
          or die "Missing menu_text at $category_file";
        defined (my $priority = $dom->at(':root > priority')->text)
          or die "Missing priority at $category_file";
        my $category = {
            title       => $title,
            menu_text   => $menu_text,
            slug        => $slug,
            description => $description,
            priority    => $priority,
        };
        $cached_categories->{$slug} = $category;
    }
    return $cached_categories;
}

1;
