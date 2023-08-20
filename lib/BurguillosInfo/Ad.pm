package BurguillosInfo::Ad;

use v5.36.0;

use strict;
use warnings;

use feature 'signatures';

use Moo::Role;

sub order {
    return 999;
}

sub seconds {
    return 15;
}

requires 'id is_active img text';
1;
