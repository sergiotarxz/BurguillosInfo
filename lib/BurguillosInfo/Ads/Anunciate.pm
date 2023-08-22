package BurguillosInfo::Ads::Anunciate;

use v5.36.0;

use strict;
use warnings;
use utf8;

use feature 'signatures';

use Moo;

use parent 'BurguillosInfo::Ad';

sub weight {
    return 10;
}

sub id ($self) {
    return 'anunciate';
}

sub is_active ($self) {
    return 1;
}

sub seconds {
    return 8;
}

sub img {
    return '/img/burguillos-new-logo.svg';
}

sub href {
    return 'mailto:contact@owlcode.tech?subject=Quiero%20anunciarme%20en%20Burguillos.info';
}

sub text {
    return
'Pulsando este anuncio puedes enviarnos un correo para anunciarte en este sitio. ¡Si me ves funciona!';
}
1;
