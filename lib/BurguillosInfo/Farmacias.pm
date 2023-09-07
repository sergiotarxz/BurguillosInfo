package BurguillosInfo::Farmacias;

use v5.36.0;

use strict;
use warnings;
use utf8;

use Moo;

use Module::Pluggable
  search_path      => ['BurguillosInfo::Farmacias'],
  instantiate      => 'new',
  on_require_error => sub ( $plugin, $error ) {
    die $error;
  };

{
    my $array;
    sub array($self) {
        if (!defined $array) {
            $self->_populate_farmacias; 
        }
        return $array;
    }

    sub _populate_farmacias($self) {
        $array = [];
        @$array = $self->plugins();
        for my $farmacia (@$array) {
            $self->_check_farmacia_valid($farmacia);
        }
    }
}

{
    my $farmacias_by_id;
    sub by_id($self, $target_id) {
        if (!defined $farmacias_by_id) {
            $self->_populate_farmacias_by_id;
        }
        if (!defined $target_id) {
            die 'You must pass $target_id.';
        }
        my $farmacia = $farmacias_by_id->{$target_id};
        if (!defined $farmacia) {
            die "Farmacia $target_id not found.";
        }
        return $farmacia;
    }

    sub _populate_farmacias_by_id($self) {
        $farmacias_by_id = {};
        my $farmacias = $self->array;
        for my $farmacia (@$farmacias) {
            $farmacias_by_id->{$farmacia->id} = $farmacia;
        }
    }
}

sub _check_farmacia_valid($self, $farmacia) {
    if ( !$farmacia->does('BurguillosInfo::Farmacia') ) {
        die "$farmacia does not implement BurguillosInfo::Farmacia.";
    }
}
1;
