package BurguillosInfo::Tracking;

use v5.34.1;

use strict;
use warnings;

use feature 'signatures';

use JSON;
use Const::Fast;

use BurguillosInfo::DB;

my $app;

const my $SELECT_GLOBAL => <<'EOF';
SELECT COUNT(*)
	FROM requests
EOF

sub new {
    my $class = shift;
    $app = shift;
    my $dbh = BurguillosInfo::DB->connect($app);
    return bless {}, $class;
}

sub _add_path ( $self, $url ) {
    my $dbh = BurguillosInfo::DB->connect($app);
    $dbh->do( <<'EOF', undef, $url );
INSERT INTO paths (path) VALUES($1)
ON CONFLICT (path) DO
    UPDATE SET last_seen = NOW() where paths.path = $1;
EOF
}

sub _update_null_last_seen_paths_if_any ($self) {
    my $dbh = BurguillosInfo::DB->connect($app);
    $dbh->do( <<'EOF', undef );

UPDATE paths
SET last_seen = requests_for_path.last_date
FROM (
    SELECT requests.path, max(requests.date) as last_date
    FROM requests
    GROUP BY requests.path
) requests_for_path 
WHERE paths.last_seen IS NULL AND requests_for_path.path = paths.path;
EOF
}

sub _register_request_query ( $self, $remote_address, $user_agent,
    $params_json, $path, $referer )
{
    my $dbh = BurguillosInfo::DB->connect($app);
    my $country = $self->_get_country($remote_address);
    my $subdivision = $self->_get_subdivision($remote_address);

    $dbh->do(
        <<'EOF', undef, $remote_address, $user_agent, $params_json, $path, $referer, $country, $subdivision );
INSERT INTO requests(remote_address,
        user_agent, params, path,
        referer, country, subdivision)
	VALUES (?, ?, ?, ?, ?, ?, ?);
EOF
}

sub update_country_and_subdivision($self, $dbh, $uuid, $remote_address) {
    my $country = $self->_get_country($remote_address);
    my $subdivision = $self->_get_subdivision($remote_address);
    $dbh->do(<<'EOF', undef, $country, $subdivision, $uuid);
UPDATE requests
SET country=?,
    subdivision=?
WHERE uuid=?;
EOF
}

sub _get_country($self, $remote_address) {
    my $geoip = $self->_geoip;
    if (!defined $geoip) {
        return;
    }
    my $data = $geoip->record_for_address($remote_address);
    return $data->{country}{names}{es};
}

sub _get_subdivision($self, $remote_address) {
    my $geoip = $self->_geoip;
    if (!defined $geoip) {
        return;
    }
    my $data = $geoip->record_for_address($remote_address);
    return $data->{subdivisions}[0]{names}{es};
}

sub _geoip($self) {
    require IP::Geolocation::MMDB;
    my $path = $self->_geoip_path;
    if (!defined $path) {
        return;
    }
    return IP::Geolocation::MMDB->new(file => $path); 
}

sub _geoip_path($self) {
    require BurguillosInfo;
    my $app = BurguillosInfo->new;
    my $config = $app->config->{geoip_database};
    return $config;
}

sub register_request {
    my $self = shift;
    my $c    = shift;
    my $path = $c->req->url->path;
    # Avoiding overloading the /stats endpoint.
    return if $path =~ /\.json$/;
    my $dbh  = BurguillosInfo::DB->connect($app);
    $self->_add_path($path);
    $self->_update_null_last_seen_paths_if_any();
    my $remote_address = $c->tx->remote_address;
    my $user_agent     = $c->req->headers->user_agent;
    my $referer        = $c->req->headers->referer // '';
    my $params_json    = encode_json( $c->req->params->to_hash );
    $self->_register_request_query( $remote_address, $user_agent, $params_json,
        $path, $referer );
    say
"Registered $remote_address with user agent $user_agent visited $path with $params_json";
}

sub get_global_data {
    my $self = shift;
    my $c    = shift;
    my $app  = $c->app;
    my $dbh  = BurguillosInfo::DB->connect($app);
    my $data = $dbh->selectrow_hashref( <<"EOF", undef );
SELECT 
    (
            $SELECT_GLOBAL
            where path not like '%/%.%' and 
                date > NOW() - interval '1 day'
    ) as unique_ips_last_24_hours,
    (
            $SELECT_GLOBAL
            where path not like '%/%.%' and 
                date > NOW() - interval '1 week'
    ) as unique_ips_last_week,
    (
            $SELECT_GLOBAL
            where path not like '%/%.%' and 
                date > NOW() - interval '1 month'
    ) as unique_ips_last_month;
EOF
    return $data;
}

my $GOOGLE_REFERER_REGEX = "'^https?://(?:www\\.)?google\\.\\w'";
my $GOOGLE_SELECT = "$SELECT_GLOBAL
where requests.path = paths.path 
    and requests.referer IS NOT NULL
    and requests.referer ~* $GOOGLE_REFERER_REGEX
    and date > NOW()";

sub get_google_data {
    my $self = shift;
    my $c    = shift;
    my $app  = $c->app;
    my $dbh  = BurguillosInfo::DB->connect($app);
    my $data = $dbh->selectall_arrayref(<<"EOF", { Slice => {} } );
    SELECT paths.path,     
    (
        $GOOGLE_SELECT - interval '1 hour'
    ) as unique_ips_last_1_hour,
    (
        $GOOGLE_SELECT - interval '3 hour'
    ) as unique_ips_last_3_hours,
    (
        $GOOGLE_SELECT - interval '6 hour'
    ) as unique_ips_last_6_hours,
    (
        $GOOGLE_SELECT - interval '12 hour'
    ) as unique_ips_last_12_hours,
    (
        $GOOGLE_SELECT - interval '1 day'
    ) as unique_ips_last_24_hours,
    (
        $GOOGLE_SELECT - interval '1 week'
    ) as unique_ips_last_week,
    (
        $GOOGLE_SELECT - interval '1 month'
    ) as unique_ips_last_month
FROM paths right join requests on paths.path = requests.path 
WHERE paths.last_seen > NOW() - INTERVAL '1 month'
    and requests.referer ~* $GOOGLE_REFERER_REGEX
    and requests.date > NOW() - INTERVAL '1 month'
GROUP BY
    paths.path;
EOF
    return $data;
}

sub get_data_for_urls {
    my $self = shift;
    my $c    = shift;
    my $app  = $c->app;
    my $dbh  = BurguillosInfo::DB->connect($app);
    my $data = $dbh->selectall_arrayref( <<"EOF", { Slice => {} } );
SELECT paths.path,
    (
            $SELECT_GLOBAL
            where requests.path = paths.path and date > NOW() - interval '1 hour'
    ) as unique_ips_last_1_hour,
    (
            $SELECT_GLOBAL
            where requests.path = paths.path and date > NOW() - interval '3 hour'
    ) as unique_ips_last_3_hours,
    (
            $SELECT_GLOBAL
            where requests.path = paths.path and date > NOW() - interval '6 hour'
    ) as unique_ips_last_6_hours,
    (
            $SELECT_GLOBAL
            where requests.path = paths.path and date > NOW() - interval '12 hour'
    ) as unique_ips_last_12_hours,
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
FROM paths 
WHERE paths.last_seen > NOW() - INTERVAL '1 month';
EOF
    return $data;
}

1;
