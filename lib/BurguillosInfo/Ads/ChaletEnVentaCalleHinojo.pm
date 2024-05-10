package BurguillosInfo::Ads::ChaletEnVentaCalleHinojo;

use v5.36.0;

use strict;
use warnings;
use utf8;

use DateTime;

use feature 'signatures';

use Moo;

use parent 'BurguillosInfo::Ad';

sub id ($self) {
    return 'chalet-en-venta-calle-hinojo';
}

sub weight {
    return 50;
}

sub max_alternative {
    return 1;
}

sub seconds($self) {
    return 15;
}

sub default_alternative($self) {
    return int($self->alternative * ($self->max_alternative + 1));
}

sub is_active ($self) {
    if (DateTime->new(year => 2024, month => 6, day => 11) < DateTime->now()) {
        return 0;
    }
    return 1;
}

sub img ($self) {
    return '/img/chalet-calle-hinojo.webp';
}

sub text($self) {
    return 'Chalet pareado en venta en calle Hinojo por 160 000€';
}

sub href {
    return 'https://www.idealista.com/inmueble/104802645/';
}
1;
