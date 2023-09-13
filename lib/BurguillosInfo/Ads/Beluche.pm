package BurguillosInfo::Ads::Beluche;

use v5.36.0;

use strict;
use warnings;
use utf8;

use feature 'signatures';

use Moo;

use parent 'BurguillosInfo::Ad';

sub id ($self) {
    return 'beluche';
}

sub weight {
    return 50;
}

sub max_alternative {
    return 2;
}

sub default_alternative($self) {
    return int($self->alternative * ($self->max_alternative + 1));
}

sub is_active ($self) {
    return 1;
}

sub img ($self) {
    if ( $self->default_alternative == 1 ) {
        return '/img/anuncio-beluche-2.webp'
    }
    return '/img/anuncio-beluche-1.webp'
}

sub text($self) {
    if ( $self->default_alternative == 1 ) {
        return 'Un ambiente inmejorable en el local y un servicio de reparto a domicilio excelente. Tu comida en Café Bar Beluche.';
    }
    return 'Increíbles platos en Café Bar Beluche, ve y descubreló.';
}

sub href {
    return '/posts/cafe-bar-beluche?come-from-ad=1';
}
1;
