#!/usr/bin/env perl

use v5.36.0;

use strict;
use warnings;

use utf8;

use Mojo::UserAgent;

my $ua = Mojo::UserAgent->new;
my $base_url = "https://www.mundogenuino.eu";
my $dom = $ua->get($base_url)->result->dom;
my $category_anchors = $dom->find('a.s123-fast-page-load');
binmode STDOUT, ':utf8';
for my $category_anchor ($category_anchors->each) {
    my $title_category = $category_anchor->all_text;
    my $url_category = $base_url . $category_anchor->attr('href');
    next unless $title_category;
    $title_category =~ s/^\s+//;
    $title_category =~ s/\s+$//;
    say "$title_category";
    say "$url_category";
    my $dom_category = $ua->get($url_category)->result->dom;
    my @product_containers = $dom_category->find('a.article-container')->each;
    for my $product_container (@product_containers) {
        my $url_product = $base_url.$product_container->attr('href');
        my $product_title = $product_container->at('h4')->all_text;
        my $dom_product = $ua->get($url_product)->result->dom;
        my $ingredients_tag = $dom_product->at('strong');
        my $ingredients = '';
        if (defined $ingredients_tag) {
            $ingredients = $ingredients_tag->all_text;
        }
        my @prices;
        my $i = 0;
        my $product_text = $dom_product->all_text;
        while ($product_text =~ /(\S+(\s*)€)/ug) {
            my $price = $1;
            $price =~ s/,/./g;
            $price =~ s/\s//g;
            push @prices, $price;
            last if ++$i == 2;
        }
        if (!scalar @prices) {
            my ($price) = $product_text =~ /(\d+,\d{2})(?:\s|$)/;
            if (defined $price) {
                $price =~ s/,/./g;
                push @prices, $price.'€';
            }
        }
        say join '', map { "($_)" } $product_title, $url_product, $ingredients, @prices;
    }
    #    say join "\n", $dom_category->find('h4')->map('all_text')->each;
}
