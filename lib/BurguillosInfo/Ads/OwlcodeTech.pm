package BurguillosInfo::Ads::OwlcodeTech;

use v5.36.0;

use strict;
use warnings;
use utf8;

use feature 'signatures';

use Moo;

use parent 'BurguillosInfo::Ad';

sub id ($self) {
    return 'owlcode-tech';
}

sub weight {
    return 50;
}

sub seconds($self) {
    return 15;
}

sub max_alternative {
    return 1;
}

sub default_alternative($self) {
    return int($self->alternative * ($self->max_alternative + 1));
}

sub is_active ($self) {
    return 0;
}

sub img ($self) {
    return '/img/owlcode-tech.webp';
}

sub text($self) {
    return '¿Tienes una PYME o eres autónomo y aun no tienes presencia web? Consigue una web totalmente subvencionada. Pulsa aquí para más información.';
}

sub href {
    return 'mailto:contact@owlcode.tech?subject=Quiero%20una%20web%20completamente%20subvencionada';
}
1;
