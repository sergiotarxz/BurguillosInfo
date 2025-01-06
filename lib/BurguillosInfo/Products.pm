package BurguillosInfo::Products;

use v5.40.0;
use strict;
use warnings;

use utf8;

use Moo;

use Const::Fast;

use Path::Tiny;

const my $CURRENT_FILE => __FILE__;
const my $PRODUCTS_DIR =>
  path($CURRENT_FILE)->parent->parent->parent->child('content/products/');

my $cached_products;

sub Retrieve ($self) {
    if ( defined $cached_products ) {
        return $cached_products;
    }
    $cached_products = {};
    for my $product_file ( $PRODUCTS_DIR->children ) {
        warn "Bad file $product_file, omiting...", next
          if !-f $product_file || $product_file !~ /\.xml$/;
        my $dom = Mojo::DOM->new->xml(1)->parse( $product_file->slurp_utf8 );
        defined( my $title = $dom->at(':root > title')->text )
          or die "Missing title at $product_file.";
        defined( my $description = $dom->at(':root > description')->text )
          or die "Missing description at $product_file.";
        defined( my $slug = $dom->at(':root > slug')->text )
          or die "Missing slug at $product_file.";
        defined( my $img = $dom->at(':root > img')->text )
          or die "Missing img at $product_file.";
        defined( my $vendor = $dom->at(':root > vendor')->text )
          or die "Missing vendor at $product_file.";
        defined( my $url = $dom->at(':root > url')->text )
          or die "Missing url at $product_file.";
        $cached_products->{$slug} = {
            title       => $title,
            description => $description,
            slug        => $slug,
            img         => $img,
            vendor      => $vendor,
            url         => $url,
        };
    }
    return $cached_products;
}
