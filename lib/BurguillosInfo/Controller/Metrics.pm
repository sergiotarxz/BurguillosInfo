package BurguillosInfo::Controller::Metrics;

use v5.34.1;

use strict;
use warnings;

use Data::Dumper;

use BurguillosInfo::Tracking;

use Mojo::Base 'Mojolicious::Controller';

use DateTime::Format::ISO8601;
use DateTime::Format::Mail;

my $tracking;
sub request {
	shift;
	my $c = shift;
	my $app = $c->app;
	if (!defined $tracking) {
		$tracking = BurguillosInfo::Tracking->new($app);
	}
	$tracking->register_request($c);	
}
1;
