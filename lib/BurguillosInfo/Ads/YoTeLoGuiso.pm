package BurguillosInfo::Ads::YoTeLoGuiso;

use v5.36.0;

use strict;
use warnings;
use utf8;

use feature 'signatures';

use Moo;

use parent 'BurguillosInfo::Ad';

sub id ($self) {
    return 'yo-te-lo-guiso';
}

sub order {
    return 50;
}

sub max_alternative {
    return 2;
}

sub is_active ($self) {
    return 1;
}

sub img ($self) {
    if ( $self->alternative == 1 ) {
        return '/img/anuncio-yo-te-lo-guiso-2.webp';
    }
    return '/img/anuncio-yo-te-lo-guiso-1.webp';
}

sub text($self) {
    if ( $self->alternative == 1 ) {
        return
'Una comida como esta no la ves todos los días, disponible en Burguillos, entra y descubrelo.';
    }
    return 'Comida hecha como en tu casa, Yo Te Lo Guiso...';
}

sub href {
    return 'https://example.com';
}
1;
