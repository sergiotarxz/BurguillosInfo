package BurguillosInfo::Farmacias::CruzDeLaErmita;

use v5.36.0;


use strict;
use warnings;
use utf8;

use feature 'signatures';

use Moo;
use parent 'BurguillosInfo::Farmacia';

sub id {
    return 'cruz_de_la_ermita';
}

sub name {
    return 'Farmacia Cruz de La Ermita';
}

sub address {
    return 'Avenida. Alcalde José Cuesta Godoy, Nº 21. (La calle aun es como Avenida Cruz de la Ermita si lo buscas en Google Maps.)';
}

1;
