package BurguillosInfo::DB::Migrations;

use v5.34.1;

use strict;
use warnings;

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
	);
}
1;
