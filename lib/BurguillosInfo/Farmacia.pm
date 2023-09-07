package BurguillosInfo::Farmacia;

use v5.36.0;

use strict;
use warnings;
use utf8;

use Moo::Role;

requires qw(id name address);

sub serialize ($self) {
    return {
        id      => $self->id,
        name    => $self->name,
        address => $self->address,
    };
}
1;
