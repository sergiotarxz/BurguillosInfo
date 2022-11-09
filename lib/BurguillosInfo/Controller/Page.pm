package BurguillosInfo::Controller::Page;

use BurguillosInfo::Categories;
use BurguillosInfo::Posts;

use v5.34.1;

use strict;
use warnings;

use Data::Dumper;

use Mojo::Base 'Mojolicious::Controller';

sub index {
    my $self             = shift;
    my $categories       = BurguillosInfo::Categories->new->Retrieve;
    my $current_category = $categories->{'index'};

    # Render template "example/welcome.html.ep" with message
    $self->render(
        categories       => $categories,
        current_category => $current_category
    );
}

sub post {
    my $self = shift;
    my $slug = $self->param('slug');
    my ( $posts_categories, $posts_slug ) =
      BurguillosInfo::Posts->new->Retrieve;
    my $categories       = BurguillosInfo::Categories->new->Retrieve;
    my $post             = $posts_slug->{$slug};
    my $current_category = $categories->{ $post->{category} };
    if ( !defined $post ) {
        $self->render( template => '404', status => 404 );
        return;
    }
    $self->render( post => $post, current_category => $current_category );
}

sub category {
    my $self             = shift;
    my $categories       = BurguillosInfo::Categories->new->Retrieve;
    my $category_name    = $self->param('category');
    my $current_category = $categories->{$category_name};
    if ( !defined $current_category ) {
        $self->render( template => '404', status => 404 );
        return;
    }
    $self->render(
        template         => 'page/index',
        categories       => $categories,
        current_category => $current_category
    );
}
1;
