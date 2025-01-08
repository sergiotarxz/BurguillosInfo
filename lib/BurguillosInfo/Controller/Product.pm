package BurguillosInfo::Controller::Product;

use v5.34.1;

use strict;
use warnings;

use BurguillosInfo::Products;

use Data::Dumper;

use Mojo::Base 'Mojolicious::Controller', '-signatures';

sub direct_buy($self) {
    my $products = BurguillosInfo::Products->new->Retrieve;
    my $slug     = $self->param('slug');
    my $product  = $products->{$slug};
    my $referer  = $self->req->headers->referer || '';
    my $base_url = $self->config('base_url');
    if ( $referer !~ /^$base_url/ ) {
        undef $referer;
    }
    if ( $product->{vendor} eq 'Aliexpress' ) {
        return $self->render(
            template => 'page/aliexpress-product',
            product  => $product,
            referer  => $referer,
        );
    }
    $self->redirect_to( $product->{url} );
    return;
}
1;
