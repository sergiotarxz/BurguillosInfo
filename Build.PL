#!/usr/bin/env perl
use Module::Build;

my $home = $ENV{HOME};

my $build = Module::Build->new(
    module_name   => 'BurguillosInfo',
    license       => 'AGPLv3',
    dist_author   => 'Sergio Iglesias <contact@owlcode.tech>',
    dist_abstract => 'The burguillos.info webpage.',
    requires      => {
        'Mojolicious' => 0,
        'Const::Fast' => 0,
        'Crypt::URandom' => 0,
        'Crypt::Bcrypt' => 0,
        'DBI' => 0,
        'DBD::Pg' => 0,
        'DateTime::Format::ISO8601.pm' => 0,
        'DateTime::Format::Mail.pm' => 0,
        'SVG' => 0,
        'XML::Twig' => 0,
    },
);
$build->create_build_script;
