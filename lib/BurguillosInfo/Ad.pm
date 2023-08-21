package BurguillosInfo::Ad;

use v5.36.0;

use strict;
use warnings;

use feature 'signatures';

use Moo::Role;

has alternative => (
    is => 'rw'
);

sub max_alternative {
    return 0;
}

sub regenerate_alternative($self) {
    $self->alternative(int(rand() * ($self->max_alternative+1)));
}

sub weight {
    return 25;
}

sub seconds {
    return 3;
}

sub serialize ($self) {
    return {
        id      => $self->id,
        img     => $self->img,
        text    => $self->text,
        href    => $self->href,
        seconds => $self->seconds,
    };
}

{
    my %instances;

    sub instance ($class) {
        if ( !defined $instances{$class} ) {
            $instances{$class} = $class->new;
        }
        return $instances{$class};
    }
}

requires 'id is_active img text href';
1;
