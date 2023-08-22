package BurguillosInfo::Ads;

use v5.36.0;

use strict;
use warnings;

use feature 'signatures';

use List::AllUtils qw/none/;

use Moo;

use Module::Pluggable
  search_path      => ['BurguillosInfo::Ads'],
  instantiate      => 'instance',
  on_require_error => sub ( $plugin, $error ) {
    die $error;
  };

{
    my @array_ads;

    sub _array ($self) {
        if ( !scalar @array_ads ) {
            $self->_populate_array;
        }
        return [@array_ads];
    }

    sub _populate_array ($self) {
        @array_ads = $self->plugins();
        for my $ad (@array_ads) {
            $self->_check_ad_valid($ad);
        }
    }
}

sub get_next ( $self, $current_ad_number = undef ) {
    my $array = $self->_array;
    use Data::Dumper;
    if (  !scalar @$array
        || none { $_->is_active } @$array )
    {
        return { continue => 0, current_ad_number => undef };
    }
    if ( !defined $current_ad_number ) {
        $current_ad_number = 0;
    }
    my $ad = $self->get_rand_ad($array);
    $ad->regenerate_alternative;
    return {
        ad                => $ad->serialize,
        continue          => 1,
        current_ad_number => $self->_get_next_number($current_ad_number),
    };
}

sub get_rand_ad($self, $array) {
    my $valid_ads = [ grep { $_->is_active } @$array ];
    my $max_weight = $self->sum_weights($array);
    my $rand = int(rand() * $max_weight);
    my $sum_weight = 0;
    for my $ad (@$array) {
        $sum_weight += $ad->weight;
        if ($rand < $sum_weight) {
            return $ad;
        }
    }
    die "This should not happen, there should be always a corresponding ad.";
}

sub sum_weights($self, $array) {
    my $sum = 0;
    for my $ad (@$array) {
        $sum += $ad->weight;
    }
    return $sum;
}

sub _get_next_number ( $self, $current_ad_number = undef ) {
    my $array = $self->_array;
    if ( !scalar @$array ) {
        return undef;
    }
    if ( !defined $current_ad_number ) {
        return 0;
    }
    if ( ++$current_ad_number > ( scalar @$array ) - 1 ) {
        return 0;
    }
    return $current_ad_number;
}

sub _check_ad_valid ( $self, $ad ) {
    if ( !$ad->does('BurguillosInfo::Ad') ) {
        die "$ad does not implement BurguillosInfo::Ad.";
    }
}
1;
