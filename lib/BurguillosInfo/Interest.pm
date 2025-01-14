package BurguillosInfo::Interest;

use v5.40.0;

use strict;
use warnings;
use utf8;

use Moo;

use BurguillosInfo::DB;

use UUID::URandom qw/create_uuid_hex/;

use namespace::clean;

has _dbh => ( is => 'lazy', );

has app => (
    is       => 'rw',
    required => 1,
);

sub _build__dbh($self) {
    my $app = $self->app;
    return BurguillosInfo::DB->connect($app);
}

sub set_javascript_capable( $self, $c ) {
    my $cookie_value = $self->get_interest_cookie($c);
    my $dbh          = $self->_dbh;
    $dbh->do(
'UPDATE interest_cookies SET has_javascript = true WHERE cookie_value = ?',
        {}, $cookie_value
    );
}

sub get_interest_cookie( $self, $c ) {
    my $cookie_value = $c->cookie( $self->_cookie_name, );
    say $cookie_value;
    if ( !defined $cookie_value ) {
        $cookie_value = create_uuid_hex();
        say $cookie_value;
    }
    eval {
        $self->_dbh->do( '
INSERT INTO interest_cookies
    (cookie_value)
VALUES (?);
            ', {}, $cookie_value );
    };
    if ($@) {

        # warn $@;
    }
    $c->cookie(
        $self->_cookie_name,
        $cookie_value,
        {
            expires  => time + 3600 * 24 * 390,
            samesite => 'Lax',
            (
                $c->config('base_url') =~ /https/
                ? ( secure => 1, )
                : ()
            ),
        }
    );

    return $cookie_value;
}

sub increment_search_interest( $self, $c, $term ) {
    my $cookie_value = $self->get_interest_cookie($c);
    my $dbh          = $self->_dbh;
    $dbh->do( '
INSERT INTO interest_searches (
        id_cookie,
        term,
        count
    )
SELECT id, ?, 1 
    FROM interest_cookies
    WHERE cookie_value = ?
ON CONFLICT (id_cookie, term)
DO UPDATE SET
    count
        = interest_searches.count + 1;
', {}, $term, $cookie_value );
}

sub increment_post_interest( $self, $c, $slug ) {
    my $cookie_value = $self->get_interest_cookie($c);
    my $dbh          = $self->_dbh;
    $dbh->do( '
INSERT INTO interest_posts (
        id_cookie,
        slug,
        count
    )
SELECT id, ?, 1 
    FROM interest_cookies
    WHERE cookie_value = ?
ON CONFLICT (id_cookie, slug)
DO UPDATE SET
    count
        = interest_posts.count + 1;
', {}, $slug, $cookie_value );
}

sub _set_product_interest( $self, $c, $slug, $interest_value ) {
    my $cookie_value = $self->get_interest_cookie($c);
    my $dbh          = $self->_dbh;
    $dbh->do( '
INSERT INTO interest_products (
        id_cookie,
        max_interest,
        slug
    )
SELECT id, ?, ?
    FROM interest_cookies
    WHERE cookie_value = ?
ON CONFLICT (id_cookie, slug)
DO UPDATE SET
    max_interest
        = GREATEST(
            EXCLUDED.max_interest,
            interest_products.max_interest
        );
        ', {}, $interest_value, $slug, $cookie_value );
}

sub set_product_interest_searched( $self, $c, $slug ) {
    $self->_set_product_interest( $c, $slug, 100 );
}

sub set_product_interest_got_details( $self, $c, $slug ) {
    $self->_set_product_interest( $c, $slug, 500 );
}

sub set_product_interest_visited( $self, $c, $slug ) {
    $self->_set_product_interest( $c, $slug, 1000 );
}

sub _cookie_name {
    return 'birra';
}
1;
