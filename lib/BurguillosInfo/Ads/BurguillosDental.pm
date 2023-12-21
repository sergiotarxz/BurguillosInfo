package BurguillosInfo::Ads::BurguillosDental;

use v5.36.0;

use strict;
use warnings;
use utf8;

use feature 'signatures';

use Moo;

use parent 'BurguillosInfo::Ad';

sub id ($self) {
    return 'burguillos-dental';
}

sub weight {
    return 50;
}

sub max_alternative {
    return 3;
}

sub seconds($self) {
    return 15;
}

sub default_alternative($self) {
    return int($self->alternative * ($self->max_alternative + 1));
}

sub is_active ($self) {
    return 1;
}

sub img ($self) {
    if ( $self->default_alternative == 2 ) {
        return '/img/burguillos-dental-ad-0-small.webp'
    }
    if ( $self->default_alternative == 1 ) {
        return '/img/burguillos-dental-ad-1-small.webp'
    }
    return '/img/burguillos-dental-ad-1-small.webp'
}

sub text($self) {
    if ( $self->default_alternative == 2 ) {
        return 'Pide presupuesto para conseguir una sonrisa perfecta en Burguillos Dental, '.
        'ubicado en Centro Médico Juan Manuel Pérez Sanchez.';
    }
    if ( $self->default_alternative == 1 ) {
        return '¿Te has hecho ya tu limpieza completa de boca anual? Confia en profesionales, confia en Burguillos Dental, '.
        'ubicado en Centro Médico Juan Manuel Pérez Sanchez.';
    }
    return '¿Te duele un diente? No lo dejes, ven a Burguillos Dental '.
    'ubicado en Centro Médico Juan Manuel Pérez Sanchez.';
}

sub href {
    return '/posts/burguillos-dental?come-from-ad=1';
}
1;
