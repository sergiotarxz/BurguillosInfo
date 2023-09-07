package BurguillosInfo::DB::Migrations;

use v5.34.1;

use strict;
use warnings;
use utf8;

use feature 'signatures';

sub MIGRATIONS {
    return (
        'CREATE TABLE options (
                name TEXT PRIMARY KEY,
                value TEXT
        )',
        'CREATE EXTENSION IF NOT EXISTS "uuid-ossp"',
        'CREATE TABLE paths (
                path TEXT PRIMARY KEY,
                first_seen timestamp DEFAULT NOW()
        )',
        'CREATE TABLE requests (
                uuid UUID DEFAULT uuid_generate_v4(),
                remote_address TEXT NOT NULL,
                user_agent TEXT NOT NULL,
                params JSON NOT NULL,
                date timestamp DEFAULT NOW(),
                path TEXT,
                FOREIGN KEY (path) REFERENCES paths(path)
        )',
        'ALTER TABLE paths ADD column last_seen TIMESTAMP;',
        'ALTER TABLE paths ALTER COLUMN last_seen SET DEFAULT NOW();',
        'ALTER TABLE requests ADD PRIMARY KEY (uuid)',
        'CREATE INDEX request_extra_index on requests (date, path);',
        'ALTER TABLE requests ADD column referer text;',
        'CREATE INDEX request_referer_index on requests (referer);',
        'ALTER TABLE requests ADD COLUMN country TEXT;',
        'CREATE INDEX request_country_index on requests (country);',
        'ALTER TABLE requests ADD COLUMN subdivision TEXT;',
        'CREATE INDEX request_subdivision_index on requests (subdivision);',
        \&_populate_locations,
        \&_populate_locations,
        \&_populate_locations,
        \&_populate_locations,
        \&_populate_locations,
        'CREATE TABLE farmacia_guardia (
            uuid UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
            date timestamp NOT NULL,
            id_farmacia TEXT NOT NULL
        );',
        'CREATE INDEX farmacia_guardia_index on farmacia_guardia (date, id_farmacia, uuid);',
    );
}

sub _populate_locations ($dbh) {
    require BurguillosInfo;
    require BurguillosInfo::Tracking;
    my $tracking = BurguillosInfo::Tracking->new( BurguillosInfo->new );
    my $page     = 0;
    while (1) {
        last if !_update_request_page( $dbh, $tracking, $page );
        $page += 100;
    }
}

sub _update_request_page ( $dbh, $tracking, $page ) {
    my $data = $dbh->selectall_arrayref( <<"EOF", { Slice => {} }, $page );
SELECT uuid, remote_address
FROM requests
WHERE date > NOW() - interval '1 month'
    AND country IS NULL
    AND subdivision IS NULL
ORDER BY date desc
OFFSET $page
LIMIT ?;
EOF
    if ( !@$data ) {
        return;
    }
    for my $request (@$data) {
        my ( $uuid, $remote_address ) = $request->@{ 'uuid', 'remote_address' };
        $tracking->update_country_and_subdivision( $dbh, $uuid,
            $remote_address );
    }
    return 1;
}
1;
