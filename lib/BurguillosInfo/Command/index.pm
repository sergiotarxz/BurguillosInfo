package BurguillosInfo::Command::index;

use v5.36.0;

use strict;
use warnings;
use utf8;

use feature 'signatures';

use Data::Dumper;

use Mojo::Base 'Mojolicious::Command';
use Moo;

use Mojo::UserAgent;

use BurguillosInfo::Posts;
use BurguillosInfo::Categories;

sub run ( $self, @args ) {
    require BurguillosInfo;
    my $app            = BurguillosInfo->new;
    my $config         = $app->config;
    my $search_backend = $config->{search_backend};
    my $search_index   = $config->{search_index};
    my $ua             = Mojo::UserAgent->new;
    my $posts          = BurguillosInfo::Posts->new->Retrieve;
    my $categories     = BurguillosInfo::Categories->new->Retrieve;
    my $index          = [];
    $self->_index_posts( $index, $posts );
    $self->_index_categories( $index, $categories );
    my $response = $ua->put( $search_backend . '/index/' . $search_index,
        {} => json => $index );
    say $response->result->body;
}

sub _index_categories ( $self, $index, $categories ) {
    my @categories_keys = keys %$categories;
    for my $category_key (@categories_keys) {
        my $category     = $categories->{$category_key};
        my $slug     = $category->{slug};
        my $url      = "/$slug";
        my $content =
          Mojo::DOM->new( '<html>' . $category->{description} =~ s/\s+/ /gr . '</html>' )->all_text;
        my $title  = $category->{title};
        my $attributes = $category->{attributes};
        $self->_index_attributes($index, $slug, $attributes);
        push @$index,
          {
            title    => $title,
            content  => $content,
            url      => $url,
          };
    }
}

sub _index_attributes($self, $index, $category_slug, $attributes) {
    my @attributes_keys = keys %$attributes;
    for my $attribute_key (@attributes_keys) {
        my $attribute = $attributes->{$attribute_key};
        my $slug = $attribute->{identifier};
        my $url = "/$category_slug/atributo/$slug";
        my $title  = $attribute->{title};
        my $content  = Mojo::DOM->new( '<html>' . $attribute->{description} . '</html>' )->all_text;
        push @$index, {
            title    => $title,
            content  => $content =~ s/\s+/ /gr,
            url      => $url,
        };
    }
}

sub _index_posts ( $self, $index, $posts ) {
    my @posts_keys = keys %$posts;
    for my $post_key (@posts_keys) {
        my $post     = $posts->{$post_key};
        my $slug     = $post->{slug};
        my $url      = "/posts/$slug";
        my $urlImage = $post->{image};
        my $content =
          Mojo::DOM->new( '<html>' . $post->{content} . '</html>' )->all_text;
        my $title  = $post->{title};
        my $author = $post->{author};
        push @$index,
          {
            title    => $title,
            author   => $author,
            content  => $content =~ s/\s+/ /gr,
            url      => $url,
            urlImage => $urlImage,
          };
    }
}
1;
