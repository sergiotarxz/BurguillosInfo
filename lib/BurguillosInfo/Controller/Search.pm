package BurguillosInfo::Controller::Search;

use v5.34.1;

use strict;
use warnings;

use Data::Dumper;

use Mojo::Base 'Mojolicious::Controller', '-signatures';
use Mojo::UserAgent;

use BurguillosInfo::IndexUtils;
use BurguillosInfo::Posts;

my $index_utils = BurguillosInfo::IndexUtils->new;

my $search_cache = {};

sub search_user($self) {
    my $ua    = Mojo::UserAgent->new;
    my $query = $self->param('q');
    my $embedded = $self->param('e');
    if ( defined $search_cache->{$query} ) {
        return $self->render(
            template => 'page/search',
            searchObjects => $search_cache->{$query},
            embedded => $embedded,
            query => $query,
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
    my $searchObjects = $output->{searchObjects} || [];
    $searchObjects = [ grep { $self->filterSearch($_) } @$searchObjects ];
    $search_cache->{$query} = $searchObjects;
    return $self->render(
            template => 'page/search',
            searchObjects => $search_cache->{$query},
            embedded => $embedded,
            query => $query,
    );
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
    if ( $url =~ m{^/posts/([^/]+?)(?:\?.*)?$} ) {
        $slug = $1;
        if ( !defined $posts->{$slug} ) {
            return 0;
        }
    }
    return 1;
}
1;
