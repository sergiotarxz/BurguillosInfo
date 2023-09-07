package BurguillosInfo::Controller::FarmaciaGuardia;

use v5.34.1;

use strict;
use warnings;

use BurguillosInfo::FarmaciaGuardia;

use Mojo::Base 'Mojolicious::Controller', '-signatures';

sub current($self) {
    my $farmacia = BurguillosInfo::FarmaciaGuardia->new->get_current;
    $self->render( json => $farmacia->serialize );
}
1;
