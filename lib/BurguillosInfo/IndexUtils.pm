package BurguillosInfo::IndexUtils;

use v5.36.0;

use strict;
use warnings;
use utf8;

use feature 'signatures';

use Unicode::Normalize qw/NFKD/;

use Moo;

sub normalize($self, $text) {
    return undef if !defined $text;
    my $decomposed = NFKD( $text );
    $decomposed =~ s/\p{NonspacingMark}//g;
    $decomposed =~ s/s\b//g;
    $decomposed =~ s/a\b/o/g;
    return $decomposed;
}

sub n(@args) {
    normalize(@args);
}
1;
