package BurguillosInfo::Farmacias::Morera;

use v5.36.0;

use strict;
use warnings;
use utf8;

use Moo;

sub id {
    return 'morera';
}

sub name {
    return 'Farmacia Óptica Morera';
}

sub address {
    return 'Calle Virgen del Rosario número 13';
};

use parent 'BurguillosInfo::Farmacia';
1;
