package BurguillosInfo::Controller::Sitemap;

use v5.34.1;

use strict;
use warnings;

use BurguillosInfo::Categories;
use BurguillosInfo::Posts;

use DateTime::Format::ISO8601;

use XML::Twig;

use Mojo::Base 'Mojolicious::Controller', '-signatures';

sub sitemap ($self) {
    my $categories = BurguillosInfo::Categories->new->Retrieve;
    my $dom = Mojo::DOM->new_tag(
        'urlset',
        xmlns => 'http://www.sitemaps.org/schemas/sitemap/0.9',
        undef
    );
    $dom->xml(1);
    for my $category_key ( keys %$categories ) {
        $self->_append_category_dom( $dom, $category_key, $categories );
    }
    my $xml_string = "$dom";
    my $document = XML::Twig->new(pretty_print=> 'indented');
    $xml_string = $document->parse($xml_string)->sprint;
    $self->render(text => $xml_string, format => 'xml');
}

sub _append_category_dom ( $self, $dom, $category_key, $categories ) {
    my $category = $categories->{$category_key};
    my $slug     = $category->{'slug'};
    my $date_publish_category;
    my $date_last_modification_category;

    my ( $posts_categories, $posts_slug ) =
      BurguillosInfo::Posts->new->Retrieve;
    for my $post ( $posts_categories->{$category_key}->@* ) {
        ( $date_publish_category, $date_last_modification_category ) =
          _get_dates_for_category( $date_publish_category,
            $date_last_modification_category, $post );
        my $url_post = $self->_generate_url_for_post($post);
        $dom->child_nodes->first->append_content($url_post);
    }
    my $url          = Mojo::DOM->new_tag('url');
    my $base_url   = $self->config('base_url');
    my $location_tag = Mojo::DOM->new_tag( loc => "$base_url/$slug" );
    my $final_date_last_modification_category =
      _compare_dates_return_most_recent( $date_publish_category,
        $date_last_modification_category );
    if (defined $final_date_last_modification_category) {
        my $last_modification_tag =
          Mojo::DOM->new_tag( lastmod => $final_date_last_modification_category );
        $url->child_nodes->first->append_content($last_modification_tag);
    }
    my $priority_tag = Mojo::DOM->new_tag( priority => 0.6 );
    $url->child_nodes->first->append_content($location_tag);
    $url->child_nodes->first->append_content($priority_tag);

    $dom->child_nodes->first->append_content($url);
}

sub _generate_url_for_post ( $self, $post ) {
    my $url_tag                     = Mojo::DOM->new_tag('url');
    my $date                        = $post->{date};
    my $date_last_modification_post = $post->{last_modification_date};
    my $final_date_last_modification_post =
      _compare_dates_return_most_recent( $date, $date_last_modification_post );
    my $base_url   = $self->config('base_url');
    my $url_resource = "$base_url/@{[$post->{slug}]}";
    my $last_modification_tag =
      Mojo::DOM->new_tag( lastmod => $final_date_last_modification_post );
    my $location_tag = Mojo::DOM->new_tag( loc => $url_resource );
    $url_tag->child_nodes->first->append_content($location_tag);
    $url_tag->child_nodes->first->append_content($last_modification_tag);
    return $url_tag;
}

my $error_no_dates = "Undefined dates";

sub _get_dates_for_category ( $current_date_publish,
    $current_date_modification, $post )
{
    my @return_list;
    @return_list = (
        _compare_dates_return_most_recent(
            $current_date_publish, $post->{date}
        ),
        _compare_dates_return_most_recent(
            $current_date_publish, $post->{last_modification_date}
        ),
    );
    return @return_list;

}

sub _compare_dates_return_most_recent ( $date_a, $date_b ) {
    if ( !defined $date_a && !defined $date_b ) {
        return undef;
    }
    if ( !defined $date_a ) {
        return $date_b;
    }
    if ( !defined $date_b ) {
        return $date_a;
    }
    my $date_a_dt = DateTime::Format::ISO8601->parse_datetime($date_a);
    my $date_b_dt = DateTime::Format::ISO8601->parse_datetime($date_b);
    if ( $date_a_dt >= $date_b_dt ) {
        return $date_a;
    }
    return $date_b;
}
1;
