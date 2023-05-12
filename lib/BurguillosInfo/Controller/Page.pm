package BurguillosInfo::Controller::Page;

use v5.34.1;

use strict;
use warnings;

use BurguillosInfo::Categories;
use BurguillosInfo::Posts;

use Data::Dumper;

use Mojo::Base 'Mojolicious::Controller', '-signatures';

use DateTime::Format::ISO8601;
use DateTime::Format::Mail;

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

sub rickroll($self) {
    if ($self->req->headers->user_agent =~ /bot/i) {
        return $self->render(text => '');
    }
    $self->res->headers->location('ibaillanos.tv');
    $self->render(text => '', status => 302);
}

sub category_rss {
    my $self             = shift;
    my $categories       = BurguillosInfo::Categories->new->Retrieve;
    my $category_name    = $self->param('category');
    my $current_category = $categories->{$category_name};
    my ( $posts_categories, $posts_slug ) =
      BurguillosInfo::Posts->new->Retrieve;
    if ( !defined $current_category && $category_name ne 'all' ) {
        $self->render( template => '404', status => 404 );
        return;
    }
    my $dom         = Mojo::DOM->new_tag( 'rss', version => '2.0', undef );
    my $channel_tag = Mojo::DOM->new_tag('channel');
    if ( $category_name eq 'all' ) {
        my $title_tag       = Mojo::DOM->new_tag( 'title', 'Burguillos.info' );
        my $description_tag = Mojo::DOM->new_tag( 'description',
            'Todas las noticias de Burguillos.info.' );
        my $link_tag = Mojo::DOM->new_tag( 'link', 'https://burguillos.info/' );
        $channel_tag->child_nodes->first->append_content($title_tag);
        $channel_tag->child_nodes->first->append_content($description_tag);
        $channel_tag->child_nodes->first->append_content($link_tag);
        for my $category ( keys %$posts_categories ) {
            my $posts = $posts_categories->{$category};
            for my $post (@$posts) {
                $channel_tag->child_nodes->first->append_content(
                    _post_to_rss($post) );
            }
        }
    }
    else {
        my $category  = $current_category;
        my $title_tag = Mojo::DOM->new_tag( 'title',
            "Burguillos.info - " . $category->{title} );
        my $description_tag = Mojo::DOM->new_tag( 'description',
            'Todas las noticias de la categoria de Burguillos.info '
              . $category->{title} );
        my $link_tag = Mojo::DOM->new_tag( 'link',
            'https://burguillos.info/' . $category->{slug} );
        $channel_tag->child_nodes->first->append_content($title_tag);
        $channel_tag->child_nodes->first->append_content($description_tag);
        $channel_tag->child_nodes->first->append_content($link_tag);
        my $posts = $posts_categories->{$category_name};

        for my $post (@$posts) {
            $channel_tag->child_nodes->first->append_content(
                _post_to_rss($post) );
        }

    }
    $dom->child_nodes->first->append_content($channel_tag);
    $self->render(
        format => 'xml',
        text   => $dom,
    );
}

sub _post_to_rss {
    my $post      = shift;
    my $item_tag  = Mojo::DOM->new_tag('item');
    my $title_tag = Mojo::DOM->new_tag( 'title', $post->{title} );
    my $link      = Mojo::DOM->new_tag( 'link',
        'https://burguillos.info/posts/' . $post->{slug} );
    my $description = Mojo::DOM->new_tag( 'description',
        Mojo::DOM->new( $post->{content} )->all_text );
    my $guid = Mojo::DOM->new_tag( 'guid', $post->{slug} );
    my $date = Mojo::DOM->new_tag(
        'pubDate',
        ''
          . DateTime::Format::Mail->format_datetime(
            DateTime::Format::ISO8601->parse_datetime( $post->{date} )
          )
    );

    $item_tag->child_nodes->first->append_content($title_tag);
    $item_tag->child_nodes->first->append_content($link);
    $item_tag->child_nodes->first->append_content($description);
    $item_tag->child_nodes->first->append_content($guid);
    $item_tag->child_nodes->first->append_content($date);
    return $item_tag;
}

sub post {
    my $self = shift;
    my $slug = $self->param('slug');
    my ( $posts_categories, $posts_slug ) =
      BurguillosInfo::Posts->new->Retrieve;
    my $categories = BurguillosInfo::Categories->new->Retrieve;
    my $post       = $posts_slug->{$slug};
    if ( !defined $post ) {
        $self->render( template => '404', status => 404 );
        return;
    }
    my $current_category = $categories->{ $post->{category} };
    my $base_url         = $self->config('base_url');
    $self->stash(
        ogimage => $base_url . '/posts/' . $post->{slug} . '-preview.png' );
    $self->stash( useragent => $self->req->headers->user_agent );
    $self->render( post => $post, current_category => $current_category );
}

sub category {
    my $self             = shift;
    my $categories       = BurguillosInfo::Categories->new->Retrieve;
    my $category_name    = $self->param('category');
    my $current_category = $categories->{$category_name};
    my $base_url         = $self->config('base_url');
    if ( !defined $current_category ) {
        $self->render( template => '404', status => 404 );
        return;
    }
    $self->render(
        template   => 'page/index',
        categories => $categories,
        ogimage => $base_url . '/' . $current_category->{slug} . '-preview.png',
        current_category => $current_category
    );
}

sub get_category_preview {
    my $self           = shift;
    my $category_slug  = $self->param('category');
    my $category_model = BurguillosInfo::Categories->new;
    my $categories     = $category_model->Retrieve;
    if ( !defined $categories->{$category_slug} ) {
        $self->render( template => '404', status => 404 );
        return;
    }
    my $category = $categories->{$category_slug};
    $self->render(
        format => 'png',
        data   => $category_model->PreviewOg($category)
    );
}

sub get_post_preview {
    my $self       = shift;
    my $slug       = $self->param('slug');
    my $post_model = BurguillosInfo::Posts->new;
    my ( $posts_categories, $posts_slug ) = $post_model->Retrieve;
    if ( !defined $posts_slug->{$slug} ) {
        $self->render( template => '404', status => 404 );
        return;
    }
    my $post = $posts_slug->{$slug};
    $self->render(
        format => 'png',
        data   => $post_model->PreviewOg($post)
    );
}
1;
