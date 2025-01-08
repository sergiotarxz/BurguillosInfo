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
use BurguillosInfo::Products;
use BurguillosInfo::IndexUtils;

my $index_utils = BurguillosInfo::IndexUtils->new;

sub run ( $self, @args ) {
    require BurguillosInfo;
    my $app            = BurguillosInfo->new;
    my $config         = $app->config;
    my $search_backend = $config->{search_backend};
    my $search_index   = $config->{search_index};
    my $ua             = Mojo::UserAgent->new;
    my $posts          = BurguillosInfo::Posts->new->Retrieve(0);
    my $categories     = BurguillosInfo::Categories->new->Retrieve;
    my $products       = BurguillosInfo::Products->new->Retrieve;
    my $index          = [];
    $self->_index_posts( $index, $posts );
    $self->_index_categories( $index, $categories );
    $self->_index_products( $index, $products );
    my $response = $ua->put( $search_backend . '/index/' . $search_index,
        {} => json => $index );
    say $response->result->body;
}

sub _index_categories ( $self, $index, $categories ) {
    my @categories_keys = keys %$categories;
    for my $category_key (@categories_keys) {
        my $category = $categories->{$category_key};
        my $slug     = $category->{slug};
        my $url      = "/$slug";
        my $content =
          Mojo::DOM->new(
            '<html>' . $category->{description} =~ s/\s+/ /gr . '</html>' )
          ->all_text;
        my $title      = $category->{title};
        my $attributes = $category->{attributes};
        my $image      = $category->{image};
        $self->_index_attributes( $index, $slug, $attributes );
        push @$index, {
            title             => $title,
            titleNormalized   => $index_utils->n($title),
            content           => $content,
            contentNormalized => $index_utils->n( $content =~ s/\s+/ /gr ),
            url               => $url,
            urlNormalized     => $index_utils->n($url),
            (
                  ( defined $image )
                ? ( urlImage => $image )
                : ()
            )

        };
    }
}

sub _index_products( $self, $index, $products ) {
    my @product_keys = keys %$products;
    for my $key (@product_keys) {
        my $product = $products->{$key};
        my $title   = $product->{title};
        my $content = $product->{description_text};
        my $url     = "/producto/@{[$product->{slug}]}";
        my $image   = $product->{img};
        my $vendor  = $product->{vendor};
        push @$index, {
            title             => $title,
            titleNormalized   => $index_utils->n($title),
            content           => $content,
            contentNormalized => $index_utils->n( $content =~ s/\s+/ /gr ),
            url               => $url,
            urlNormalized     => $index_utils->n($url),
            vendor            => $vendor,
            (
                  ( defined $image )
                ? ( urlImage => $image )
                : ()
            )

        };
    }
}

sub _index_attributes ( $self, $index, $category_slug, $attributes ) {
    my @attributes_keys = keys %$attributes;
    for my $attribute_key (@attributes_keys) {
        my $attribute = $attributes->{$attribute_key};
        my $slug      = $attribute->{identifier};
        my $url       = "/$category_slug/atributo/$slug";
        my $title     = $attribute->{title};
        my $image     = $attribute->{image};
        my $content =
          Mojo::DOM->new( '<html>' . $attribute->{description} . '</html>' )
          ->all_text;
        push @$index,
          {
            titleNormalized   => $index_utils->n($title),
            title             => $title,
            contentNormalized => $index_utils->n( $content =~ s/\s+/ /gr ),
            content           => $content =~ s/\s+/ /gr,
            urlNormalized     => $index_utils->n($url),
            url               => $url,
            (
                  ( defined $image )
                ? ( urlImage => $image )
                : ()
            )
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
            titleNormalized    => $index_utils->n($title),
            title              => $title,
            authorNormalized   => $index_utils->n($author),
            author             => $author,
            contentNormalized  => $index_utils->n( $content =~ s/\s+/ /gr ),
            content            => $content =~ s/\s+/ /gr,
            urlNormalized      => $index_utils->n($url),
            url                => $url,
            urlImageNormalized => $index_utils->n($urlImage),
            urlImage           => $urlImage,
          };
    }
}
1;
