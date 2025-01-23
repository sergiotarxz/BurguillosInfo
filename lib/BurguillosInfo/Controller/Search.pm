package BurguillosInfo::Controller::Search;

use v5.34.1;

use strict;
use warnings;

use Data::Dumper;

use Mojo::Base 'Mojolicious::Controller', '-signatures';
use Mojo::UserAgent;

use BurguillosInfo::IndexUtils;
use BurguillosInfo::Posts;
use BurguillosInfo::Interest;

my $index_utils = BurguillosInfo::IndexUtils->new;

my $search_cache = {};

sub _render_search( $self, $embedded, $query ) {
    if (!$self->config('base_url') =~ /onion/) {
        my $interest = BurguillosInfo::Interest->new( app => $self->app );
        $interest->increment_search_interest( $self, $query );
    }
    my $searchObjects = $search_cache->{$query};
    $searchObjects = [ grep {  $self->filterSearch($_) } @$searchObjects ];
    $search_cache->{$query} = $searchObjects;
    return $self->render(
        template      => 'page/search',
        searchObjects => $search_cache->{$query},
        embedded      => $embedded,
        query         => $query,
    );
}

sub search_user($self) {
    my $ua       = Mojo::UserAgent->new;
    my $query    = $self->param('q');
    my $embedded = $self->param('e');
    my $base_url = $self->config('base_url');
    if ( defined $query && !$query ) {
        $self->redirect_to( $base_url . '/search.html' );
    }
    if ( defined $search_cache->{$query} ) {
        return $self->_render_search( $embedded, $query );
    }
    my $config         = $self->config;
    my $search_backend = $config->{search_backend};
    my $search_index   = $config->{search_index};
    $query =~ s/\btitle:/titleNormalized:/g;
    $query =~ s/\bcontent:/contentNormalized:/g;
    my $tx = $ua->get( $search_backend . '/search/' . $search_index,
        {}, form => { q => $index_utils->n($query) } );
    my $result = $tx->result;
    my $output = $result->json;

    if ( !defined $output ) {
        return $self->render( status => 500, json => { ok => 0 } );
    }
    my $ok     = $output->{ok};
    my $reason = $output->{reason};
    $search_cache->{$query} = $output->{searchObjects};
    return $self->_render_search( $embedded, $query );
}

sub search ($self) {
    my $ua    = Mojo::UserAgent->new;
    my $query = $self->param('q');
    if ( defined $search_cache->{$query} ) {
        return $self->render(
            status => 200,
            json   => { ok => 1, searchObjects => $search_cache->{$query} }
        );
    }
    my $config         = $self->config;
    my $search_backend = $config->{search_backend};
    my $search_index   = $config->{search_index};
    $query =~ s/\btitle:/titleNormalized:/g;
    $query =~ s/\bcontent:/contentNormalized:/g;
    my $tx = $ua->get( $search_backend . '/search/' . $search_index,
        {}, form => { q => $index_utils->n($query) } );
    my $result = $tx->result;
    my $output = $result->json;

    if ( !defined $output ) {
        return $self->render( status => 500, json => { ok => 0 } );
    }
    my $ok     = $output->{ok};
    my $reason = $output->{reason};
    if ( !$ok ) {
        return $self->render( status => 400, json => { ok => 0 } );
    }
    my $searchObjects = $output->{searchObjects};
    $searchObjects = [ grep { $self->filterSearch($_) } @$searchObjects ];
    $search_cache->{$query} = $searchObjects;
    return $self->render(
        status => 200,
        json   => { ok => 1, searchObjects => $search_cache->{$query} }
    );
}

sub filterSearch( $self, $searchObject ) {
    my $url = $searchObject->{url};
    my ( $posts_by_categories, $posts ) = BurguillosInfo::Posts->Retrieve;
    my $slug;
    my $interest = BurguillosInfo::Interest->new( app => $self->app );
    if ( $url =~ m{^/posts/([^/]+?)(?:\?.*)?$} ) {
        $slug = $1;
        if ( !defined $posts->{$slug} ) {
            return 0;
        }
    }
    if ( $url =~ m{^/producto?/([^/]+?)(?:\?.*)?$} ) {
        $slug = $1;
        $interest->set_product_interest_searched( $self, $slug );
    }
    return 1;
}
1;
