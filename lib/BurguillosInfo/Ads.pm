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
        @array_ads = sort { $self->_order_two_ads( $a, $b ); } @array_ads;
    }
}

sub _order_two_ads ( $self, $a, $b ) {
    my $by_order = $a->order <=> $b->order;
    if ($by_order) {
        return $by_order;
    }
    my $by_alpha = $a->id cmp $b->id;
    return $by_alpha;
}

sub get_next ( $self, $current_ad_number = undef ) {
    my $array = $self->_array;
    if (  !scalar @$array
        || none { $_->is_active } @$array )
    {
        return { continue => 0, current_ad_number => undef };
    }
    if ( !defined $current_ad_number ) {
        $current_ad_number = 0;
    }
    my $ad = $array->[$current_ad_number];
    if ( !$ad->is_active ) {
        return $self->get_next( $self->_get_next_number($current_ad_number) );
    }
    return {
        ad                => $ad,
        continue          => 1,
        current_ad_number => $self->_get_next_number($current_ad_number),
    };
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
