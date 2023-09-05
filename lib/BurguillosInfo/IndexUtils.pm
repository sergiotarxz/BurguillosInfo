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
    $decomposed =~ s/aui\b//g;
    $decomposed =~ s/ada\b//g;
    $decomposed =~ s/ado\b//g;
    $decomposed =~ s/aje\b//g;
    $decomposed =~ s/cion\b//g;
    $decomposed =~ s/diccion\b//g;
    $decomposed =~ s/duccion\b//g;
    $decomposed =~ s/dura\b//g;
    $decomposed =~ s/eccion\b//g;
    $decomposed =~ s/epcion\b//g;
    $decomposed =~ s/ido\b//g;
    $decomposed =~ s/miento\b//g;
    $decomposed =~ s/ncia\b//g;
    $decomposed =~ s/scripcion\b//g;
    $decomposed =~ s/sicion\b//g;
    $decomposed =~ s/sion\b//g;
    $decomposed =~ s/dad\b//g;
    $decomposed =~ s/tad\b//g;
    $decomposed =~ s/bilidad\b//g;
    $decomposed =~ s/edad\b//g;
    $decomposed =~ s/era\b//g;
    $decomposed =~ s/eria\b//g;
    $decomposed =~ s/ez\b//g;
    $decomposed =~ s/eza\b//g;
    $decomposed =~ s/ia\b//g;
    $decomposed =~ s/idad\b//g;
    $decomposed =~ s/ismo\b//g;
    $decomposed =~ s/ncia\b//g;
    $decomposed =~ s/ante\b//g;
    $decomposed =~ s/ente\b//g;
    $decomposed =~ s/ura\b//g;
    $decomposed =~ s/dor\b//g;
    $decomposed =~ s/dero\b//g;
    $decomposed =~ s/ero\b//g;
    $decomposed =~ s/ista\b//g;
    $decomposed =~ s/ado\b//g;
    $decomposed =~ s/ario\b//g;
    $decomposed =~ s/ia\b//g;
    $decomposed =~ s/ero\b//g;
    $decomposed =~ s/eria\b//g;
    $decomposed =~ s/able\b//g;
    $decomposed =~ s/aceo\b//g;
    $decomposed =~ s/aco\b//g;
    $decomposed =~ s/al\b//g;
    $decomposed =~ s/aneo\b//g;
    $decomposed =~ s/ante\b//g;
    $decomposed =~ s/ario\b//g;
    $decomposed =~ s/ente\b//g;
    $decomposed =~ s/rgir\b//g;
    $decomposed =~ s/ento\b//g;
    $decomposed =~ s/errimo\b//g;
    $decomposed =~ s/ible\b//g;
    $decomposed =~ s/ico\b//g;
    $decomposed =~ s/ifico\b//g;
    $decomposed =~ s/il\b//g;
    $decomposed =~ s/ino\b//g;
    $decomposed =~ s/isimo\b//g;
    $decomposed =~ s/ivo\b//g;
    $decomposed =~ s/izo\b//g;
    $decomposed =~ s/oso\b//g;
    $decomposed =~ s/ecer\b//g;
    $decomposed =~ s/ificar\b//g;
    $decomposed =~ s/izar\b//g;
    return $decomposed;
}

sub n (@args) {
    normalize(@args);
}
1;
