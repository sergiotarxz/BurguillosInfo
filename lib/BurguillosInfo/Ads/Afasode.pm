package BurguillosInfo::Ads::Afasode;

use v5.36.0;

use strict;
use warnings;
use utf8;

use feature 'signatures';

use Moo;

use parent 'BurguillosInfo::Ad';

sub id ($self) {
    return 'afasode-loteria';
}

sub weight {
    return 15;
}

sub is_active ($self) {
    return 1;
}

sub img {
    return '/img/afasode.svg';
}

sub href {
    return '/posts/boletos-loteria-afasode-sevilla-2023';
}

sub text {
    return
'54359 es el número de la lotería de Navidad de AFASODE, colabora con una buena causa y no pierdas la ilusión.';
}
1;
