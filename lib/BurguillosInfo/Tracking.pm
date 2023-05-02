package BurguillosInfo::Tracking;

use v5.34.1;

use strict;
use warnings;

use JSON;
use Const::Fast;

use BurguillosInfo::DB;

my $app;

const my $SELECT_GLOBAL => <<'EOF';
SELECT COUNT(DISTINCT (remote_address, user_agent))
	FROM requests
EOF


sub new {
    my $class = shift;
    $app = shift;
    my $dbh = BurguillosInfo::DB->connect($app);
    return bless {}, $class;
}

sub register_request {
    my $self = shift;
    my $c    = shift;
    my $path = $c->req->url->path;
    my $dbh = BurguillosInfo::DB->connect($app);
    $dbh->do( <<'EOF', undef, $c->req->url->path );
INSERT INTO paths (path) VALUES (?) ON CONFLICT DO NOTHING;
EOF
    my $remote_address = $c->tx->remote_address;
    my $user_agent     = $c->req->headers->user_agent;
    my $params_json    = encode_json( $c->req->params->to_hash );
    $dbh->do(
	<<'EOF', undef, $remote_address, $user_agent, $params_json, $path );
INSERT INTO requests(remote_address, user_agent, params, path)
	VALUES (?, ?, ?, ?);
EOF
	say "Registered $remote_address with user agent $user_agent visited $path with $params_json";
}

    sub get_global_data {
    	my $self = shift;
	my $c    = shift;
	my $app = $c->app;
    	my $dbh = BurguillosInfo::DB->connect($app);	
	my $data = $dbh->selectrow_hashref(<<"EOF", undef);
SELECT 
	(
		$SELECT_GLOBAL
		where date > NOW() - interval '1 day'
	) as unique_ips_last_24_hours,
	(
		$SELECT_GLOBAL
		where date > NOW() - interval '1 week'
	) as unique_ips_last_week,
	(
		$SELECT_GLOBAL
		where date > NOW() - interval '1 month'
	) as unique_ips_last_month;


EOF
	return $data;
    }

    sub get_data_for_urls {
        my $self = shift;
	my $c    = shift;
	my $app = $c->app;
    	my $dbh = BurguillosInfo::DB->connect($app);	
	my $data = $dbh->selectall_arrayref(<<"EOF", {Slice => {}});
SELECT paths.path,
	(
		$SELECT_GLOBAL
		where requests.path = paths.path
	) as unique_ips,
	(
		$SELECT_GLOBAL
		where requests.path = paths.path and date > NOW() - interval '1 day'
	) as unique_ips_last_24_hours,
	(
		$SELECT_GLOBAL
		where requests.path = paths.path and date > NOW() - interval '1 week'
	) as unique_ips_last_week,
	(
		$SELECT_GLOBAL
		where requests.path = paths.path and date > NOW() - interval '1 month'
	) as unique_ips_last_month
FROM paths;


EOF
	return $data;
}

1;
