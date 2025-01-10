package BurguillosInfo::IndexUtils;

use v5.36.0;

use strict;
use warnings;
use utf8;

use feature 'signatures';

use Unicode::Normalize qw/NFKD/;

use Moo;

use Lingua::Stem::Snowball;

sub normalize($self, $text) {
    return undef if !defined $text;
    my $decomposed = NFKD($text);
    $decomposed =~ s/\bautobus\b/horario autobus martillo/gi;
    $decomposed =~ s/\bbus\b/horario autobus martillo/gi;
    $decomposed =~ s/\bautobus burguillos sevilla\b/horario autobus martillo/gi;
    $decomposed =~ s/\bhack\S+\b/hack/gi;
    $decomposed =~ s/\p{NonspacingMark}//g;
    $decomposed =~ s/\bEl\b//gi;
    my @words;
    while ($decomposed =~ /\b(\w+)\b/g) {
        push @words, $1;
    }
    my $stemmer = Lingua::Stem::Snowball->new( lang => 'es' );
    $stemmer->stem_in_place(\@words);
    $decomposed = join " ", @words;
    $decomposed =~ s/\bpizzeri\b/pizz/gi;
    $decomposed =~ s/\bcristob\b/cristobal/gi;
    return $decomposed;
}

sub n (@args) {
    normalize(@args);
}
1;
