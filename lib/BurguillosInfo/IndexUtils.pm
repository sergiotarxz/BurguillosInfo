package BurguillosInfo::IndexUtils;

use v5.36.0;

use strict;
use warnings;
use utf8;

use feature 'signatures';

use Unicode::Normalize qw/NFKD/;

use Moo;

sub normalize ( $self, $text ) {
    return undef if !defined $text;
    my $decomposed = NFKD($text);
    $decomposed =~ s/\p{NonspacingMark}//g;
    $decomposed =~ s/es\b//g;
    $decomposed =~ s/as\b//g;
    $decomposed =~ s/os\b//g;
    $decomposed =~ s/e\b//g;
    $decomposed =~ s/o\b//g;
    $decomposed =~ s/a\b//g;
    $decomposed =~ s/i\b//g;
    $decomposed =~ s/au\b//g;
    $decomposed =~ s/ad\b//g;
    $decomposed =~ s/ad\b//g;
    $decomposed =~ s/aj\b//g;
    $decomposed =~ s/cion\b//g;
    $decomposed =~ s/diccion\b//g;
    $decomposed =~ s/duccion\b//g;
    $decomposed =~ s/dur\b//g;
    $decomposed =~ s/eccion\b//g;
    $decomposed =~ s/epcion\b//g;
    $decomposed =~ s/id\b//g;
    $decomposed =~ s/mient\b//g;
    $decomposed =~ s/nc\b//g;
    $decomposed =~ s/scripcion\b//g;
    $decomposed =~ s/sicion\b//g;
    $decomposed =~ s/sion\b//g;
    $decomposed =~ s/dad\b//g;
    $decomposed =~ s/tad\b//g;
    $decomposed =~ s/bilidad\b//g;
    $decomposed =~ s/edad\b//g;
    $decomposed =~ s/er\b//g;
    $decomposed =~ s/er\b//g;
    $decomposed =~ s/ez\b//g;
    $decomposed =~ s/ez\b//g;
    $decomposed =~ s/idad\b//g;
    $decomposed =~ s/ism\b//g;
    $decomposed =~ s/nc\b//g;
    $decomposed =~ s/ant\b//g;
    $decomposed =~ s/ent\b//g;
    $decomposed =~ s/ur\b//g;
    $decomposed =~ s/dor\b//g;
    $decomposed =~ s/der\b//g;
    $decomposed =~ s/er\b//g;
    $decomposed =~ s/ist\b//g;
    $decomposed =~ s/ad\b//g;
    $decomposed =~ s/ar\b//g;
    $decomposed =~ s/er\b//g;
    $decomposed =~ s/abl\b//g;
    $decomposed =~ s/ac\b//g;
    $decomposed =~ s/ac\b//g;
    $decomposed =~ s/al\b//g;
    $decomposed =~ s/ant\b//g;
    $decomposed =~ s/ent\b//g;
    $decomposed =~ s/rgir\b//g;
    $decomposed =~ s/ent\b//g;
    $decomposed =~ s/errim\b//g;
    $decomposed =~ s/ibl\b//g;
    $decomposed =~ s/ic\b//g;
    $decomposed =~ s/ific\b//g;
    $decomposed =~ s/il\b//g;
    $decomposed =~ s/in\b//g;
    $decomposed =~ s/isim\b//g;
    $decomposed =~ s/iv\b//g;
    $decomposed =~ s/iz\b//g;
    $decomposed =~ s/os\b//g;
    $decomposed =~ s/ecer\b//g;
    $decomposed =~ s/ific\b//g;
    say STDERR $decomposed;
    return $decomposed;
}

sub n (@args) {
    normalize(@args);
}
1;
