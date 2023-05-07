package BurguillosInfo::Controller::Attribute;
use v5.34.1;

use strict;
use warnings;

use Data::Dumper;

use BurguillosInfo::Categories;

use Mojo::Base 'Mojolicious::Controller', -signatures;

use BurguillosInfo::Preview;

sub get_attribute_preview ($self) {
    my $category_slug  = $self->param('category_slug');
    my $attribute_slug = $self->param('attribute_slug');
    my $categories     = BurguillosInfo::Categories->new->Retrieve;
    my $category       = $categories->{$category_slug};
    if ( !defined $category ) {
        return $self->reply->not_found;
    }
    my $attribute = $category->{attributes}{$attribute_slug};
    if ( !defined $attribute ) {
        return $self->reply->not_found;
    }

    $self->render(
        format => 'png',
        data   => BurguillosInfo::Preview->Generate(
            $attribute->{title}, $attribute->{description}, undef
        ),
    );
}

sub get ($self) {
    my $category_slug  = $self->param('category_slug');
    my $attribute_slug = $self->param('attribute_slug');

    my $categories = BurguillosInfo::Categories->new->Retrieve;
    my $category   = $categories->{$category_slug};
    if ( !defined $category ) {
        return $self->reply->not_found;
    }
    my $attribute = $category->{attributes}{$attribute_slug};
    if ( !defined $attribute ) {
        return $self->reply->not_found;
    }
    my $posts = BurguillosInfo::Posts->RetrieveDirectPostsForCategory(
        $category->{slug} );
    $posts = [ grep { defined $_->{attributes}{$attribute_slug} } @$posts ];
    my $base_url = $self->config('base_url');
    $self->render(
        template   => 'page/attribute',
        category   => $category,
        attribute  => $attribute,
        categories => $categories,
        posts      => $posts,
        ogimage    => $base_url . '/'
          . $category->{slug}
          . '/atributo/'
          . $attribute->{identifier}
          . '-preview.png',
    );
}
1;
