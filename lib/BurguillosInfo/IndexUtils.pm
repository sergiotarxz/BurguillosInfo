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
    $decomposed =~ s/(?:
	ada|ado|aje|cion|diccion|duccion|dura|ección|epcion|ido|ion|miento|
        ncia|on|scripcion|sicion|sion|dad|tad|bilidad|edad|era|eria|ez|eza|ia|idad|ismo|
        ncia|ante|ente|ura|dor|dero|ero|ista|ado|ario|ia|ero|eria|able|aceo|aco|al|aneo|
	ante|ario|ente|rgir|ento|errimo|ible|ico|ífico|il|ino|ísimo|ivo|izo|oso|ear|ecer
	ificar|izar|es|as|os|e|o|a
    )\b//xg;
    $decomposed =~ s/a\b/o/g;
    return $decomposed;
}

sub n(@args) {
    normalize(@args);
}
1;
