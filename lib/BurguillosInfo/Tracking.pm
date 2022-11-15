package BurguillosInfo::Tracking;

use v5.34.1;

use strict;
use warnings;

use JSON;

use BurguillosInfo::DB;

my $app;

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

1;
