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
    if (!defined $product) {
        return $self->render( template => '404', status => 404 );
    }
    my $interest = BurguillosInfo::Interest->new(app => $self->app);
    $interest->set_product_interest_visited($self, $slug);
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

sub get_data($self) {
    my $products = BurguillosInfo::Products->new->Retrieve;
    my $slug     = $self->param('slug');
    my $product  = $products->{$slug};
    if (!defined $product) {
        return $self->render( template => '404', status => 404 );
    }
    my $interest = BurguillosInfo::Interest->new(app => $self->app);
    $interest->set_product_interest_got_details($self, $slug);
    return $self->render(
        json => $product
    );
}
1;
