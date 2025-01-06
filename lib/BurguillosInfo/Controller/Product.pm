package BurguillosInfo::Controller::Product;

use v5.34.1;

use strict;
use warnings;

use BurguillosInfo::Products;

use Data::Dumper;

use Mojo::Base 'Mojolicious::Controller', '-signatures';

sub direct_buy($self) {
    my $products       = BurguillosInfo::Products->new->Retrieve;
    my $slug = $self->param('slug');
    $self->redirect_to($products->{$slug}{url});
    return;
}
1;
