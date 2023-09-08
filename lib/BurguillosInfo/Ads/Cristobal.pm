package BurguillosInfo::Ads::Cristobal;

use v5.36.0;

use strict;
use warnings;
use utf8;

use feature 'signatures';

use Moo;

use parent 'BurguillosInfo::Ad';

sub id ($self) {
    return 'cristobal';
}

sub weight {
    return 50;
}

sub max_alternative {
    return 3;
}

sub default_alternative($self) {
    return int($self->alternative * ($self->max_alternative + 1));
}

sub is_active ($self) {
    return 1;
}

sub img ($self) {
    if ( $self->default_alternative == 2 ) {
        return '/img/anuncio-cristobal-1.webp'
    }
    if ( $self->default_alternative == 1 ) {
        return '/img/anuncio-cristobal-2.webp'
    }
    return '/img/anuncio-cristobal-3.webp'
}

sub text($self) {
    if ( $self->default_alternative == 2 ) {
        return 'Disfruta de comidas abundantes en Bar Cristóbal. Contacta a 621 210 460.';
    }
    if ( $self->default_alternative == 1 ) {
        return 'Bar Cristóbal, para chuparse los dedos. Contacta a 621 210 460.';
    }
    return '¿Te apetece una cervecita y buena comida? Ven a Bar Cristóbal. Contacta a 621 210 460.';
}

sub href {
    return '/posts/bar-cristobal?come-from-ad=1';
}
1;
