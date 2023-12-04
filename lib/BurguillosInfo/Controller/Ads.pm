package BurguillosInfo::Controller::Ads;

use v5.34.1;

use strict;
use warnings;

use BurguillosInfo::Ads;

use Mojo::Base 'Mojolicious::Controller', '-signatures';

sub next_ad {
    my $self              = shift;
    my $ads_factory       = BurguillosInfo::Ads->new;
    my $current_ad_number = $self->param('n');
    $self->res->headers->access_control_allow_origin('*');
    $self->render( json => $ads_factory->get_next($current_ad_number) );
}
1;
