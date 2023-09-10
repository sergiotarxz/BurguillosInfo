package BurguillosInfo::Categories;

use v5.34.1;

use strict;
use warnings;

use feature 'signatures';

use Const::Fast;
use Mojo::DOM;
use Path::Tiny;

use BurguillosInfo::Preview;

const my $CURRENT_FILE => __FILE__;
const my $CATEGORIES_DIR =>
  path($CURRENT_FILE)->parent->parent->parent->child('content/categories');

my $cached_categories;

sub new {
    return bless {}, shift;
}

sub Retrieve($self) {
    if ( defined $cached_categories ) {
        return $cached_categories;
    }
    $cached_categories = {};
    for my $category_file ( $CATEGORIES_DIR->children ) {
        warn "Bad file $category_file, omiting...", next
          if !-f $category_file || $category_file !~ /\.xml$/;
        my $dom   = Mojo::DOM->new( $category_file->slurp_utf8 );
        defined(my $title = $dom->at(':root > title')->text)
          or die "Missing title at $category_file.";
        defined(my $description = $dom->at(':root > description')->content)
          or die "Missing description at $category_file";
        defined(my $slug = $dom->at(':root > slug')->text)
          or die "Missing slug at $category_file";
        defined (my $menu_text = $dom->at(':root > menu_text')->content)
          or die "Missing menu_text at $category_file";
        defined (my $priority = $dom->at(':root > priority')->text)
          or die "Missing priority at $category_file";
        my $attributes = $self->_GetAttributes($dom, $category_file);
        my $parent_tag = $dom->at(':root > parent');
        my $random_tag = $dom->at(':root > random');
        my $random;
        if (defined $random_tag) {{
            $random = $random_tag->text;
            if ($random =~ /^true$/i || $random =~ /^yes$/ ) {
                $random = 1;
                next;
            }
            if (int($random) != 0) {
                $random = 1;
                next;
            }
            $random = 0;
        }}
        my $parent;
        if (defined $parent_tag) {
            $parent = $parent_tag->content;
        }
        my $category = {
            title       => $title,
            menu_text   => $menu_text,
            slug        => $slug,
            description => $description,
            priority    => $priority,
            (
                (defined $parent) ?
                (parent => $parent) :
                ()
            ),
            attributes => $attributes,
            (
                (defined $random) ?
                (random => $random):
                ()
            )
        };
        $cached_categories->{$slug} = $category;
    }
    $self->_AvoidGrandChildCategories($cached_categories);
    $self->_PopulateChildrenField($cached_categories);
    return $cached_categories;
}

sub _GetAttributes($self, $dom, $category_file) {
    my $attributes_tag = $dom->at(':root > attributes');
    my %attributes;
    if (defined $attributes_tag) {
        my @attribute_tag_list = $attributes_tag->find('attributes > attribute')->each;
        for my $attribute_tag (@attribute_tag_list) {
            defined (my $menu_text = $attribute_tag->at('attribute > menu_text')->content)
              or die "Missing attribute menu_text at $category_file";
            defined (my $description = $attribute_tag->at('attribute > description')->content)
              or die "Missing attribute description at $category_file";
            defined (my $title = $attribute_tag->at('attribute > title')->text)
              or die "Missing attribute title at $category_file";
            defined (my $identifier = $attribute_tag->at('attribute > identifier')->text)
              or die "Missing attribute identifier at $category_file";
            defined (my $priority = $attribute_tag->at('attribute > priority')->text)
              or die "Missing attribute priority at $category_file";
            $attributes{$identifier} = {
              title => $title,
              identifier => $identifier,
              priority => $priority,
              menu_text => $menu_text,
              description => $description,
            };
        }
    }
    return \%attributes;
}

sub _PopulateChildrenField($self, $categories) {
    for my $category_name (keys %$categories) {
        my $category = $categories->{$category_name};
        $category->{children} //= [];
        my $parent_name = $category->{parent};
        if (!defined $parent_name) {
            next;
        }
        my $parent = $categories->{$parent_name};
        if (!defined $parent) {
            die "Category $parent_name not exists and it is the parent of $category_name.";
        }
        if (!exists $category->{random} && exists $parent->{random}) {
            $category->{random} = $parent->{random};
        }
        $parent->{children} //= [];
        push $parent->{children}->@*, $category;
    }
}

sub _AvoidGrandChildCategories($self, $categories) {
    for my $category_slug (keys %$categories) {
        my $category = $categories->{$category_slug};
        my $parent = $category->{parent};
        if (defined $parent && defined $categories->{$parent}{parent}) {
            die "$category_slug category is grandchild of $categories->{$parent}{parent}) category and this is not allowed.";
        }
    }
}

sub PreviewOg($self, $category) {
    my $title = $category->{title};
    my $description = $category->{description};
    return BurguillosInfo::Preview->Generate($title, $description, undef);
}
1;
