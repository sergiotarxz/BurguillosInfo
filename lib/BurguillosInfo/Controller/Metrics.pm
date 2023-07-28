package BurguillosInfo::Controller::Metrics;

use v5.34.1;

use strict;
use warnings;

use Data::Dumper;

use BurguillosInfo::Tracking;

use Mojo::Base 'Mojolicious::Controller', '-signatures';

use DateTime::Format::ISO8601;
use DateTime::Format::Mail;
use Crypt::Bcrypt qw/bcrypt bcrypt_check/;

my $tracking;

my $iso8601      = DateTime::Format::ISO8601->new;
sub request {
	shift;
    eval {
        my $c = shift;
        my $app = $c->app;
        if (!defined $tracking) {
            $tracking = BurguillosInfo::Tracking->new($app);
        }
        $tracking->register_request($c);	
    };
    if ($@) {
        say STDERR $@;
    }
}

sub stats {
	my $self = shift;
	if (!$self->valid_login) {
		$self->res->headers->location('/stats/login');
		$self->render(text => 'You must login', status => 302);
		return;
	}
	my $data = $tracking->get_global_data($self);
	my $data_per_url = $tracking->get_data_for_urls($self);
        my $google_data = $tracking->get_google_data($self);
        $self->_filter_data_per_url($data_per_url);
        $self->_filter_data_per_url($google_data);
	$self->render(tracking_data => $data, tracking_by_url => $data_per_url, google_data => $google_data);
}

sub _filter_data_per_url($self, $data_per_url) {
    my $filter = $self->param('filter');
    if (!defined $filter) {
        return;
    }
    my @new_data_per_url; 
    if ($filter eq 'remove-extensions') {
        for my $url (@$data_per_url) {
            if ($url->{path} =~ /\.\w+$/) {
                next;
            }
            push @new_data_per_url, $url;
        }
    }
    @$data_per_url = @new_data_per_url;
}

sub submit_login {
	my $self = shift;
	if ($self->valid_login) {
		$self->res->headers->location('/stats');
		$self->render(text => 'Already logged in.', status => 302);
		return;
	}
	my $password = $self->param('password');
	if (!defined $password) {
		$self->render(text => 'No password passed.', status => 400);
		return;
	}
	my $bcrypted_pass = $self->config->{bcrypt_pass_stats};
	if (!defined $bcrypted_pass) {
		warn "No bcrypt pass.";
		$self->render(text => 'Server error.', status => 500);
		return;
	}
	say $password;
	say $bcrypted_pass;
	if (!bcrypt_check( $password, $bcrypted_pass )) {
		$self->render(text => 'Wrong password', status => 401);
		return;
	}
	say STDERR 'Login success.';	
	my $expiration_date = DateTime->now->add( days => 1);
	$self->session->{login} = "date_end_login:$expiration_date";
	$self->res->headers->location('/stats');
	$self->render(text => 'Login success.', status => 302);
	return;
}

sub valid_login {
	my $self = shift;
	my $login_cookie = $self->session->{login};
	if (!defined  $login_cookie) {
		return;
	}

	my ($date_text) = $login_cookie =~ /^date_end_login:(.*)$/;
	my $date;
	eval {
		$date = $iso8601->parse_datetime($date_text);	
	};
	if ($@) {
		warn "Bad date in cookie $login_cookie.";
		return;
	}
	my $current_date = DateTime->now();
	if ($current_date > $date) {
		return;
	}
	return 1;
}

sub login {
	my $self = shift;
	if ($self->valid_login) {
		$self->res->headers->location('/stats');
		$self->render(text => 'You are already logged in.', status => 302);
		return;
	}
	$self->render;
}
1;
