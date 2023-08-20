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

sub is_active ($self) {
    return 1;
}

sub img {
    return '/img/afasode.svg';
}

sub text {
    return 'Prueba.';
}

sub href {
    return 'https://example.com';
}
1;
