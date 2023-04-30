#!/usr/bin/env perl

use v5.36.0;
use strict;
use warnings;

use Crypt::URandom qw/urandom/;
use Crypt::Bcrypt qw/bcrypt bcrypt_check/;

my $new_password = urandom(50);
my $new_salt = urandom(16);
$new_password = unpack 'H*', $new_password;

say "This is your password: ($new_password)";
say "This is bcrypted: (@{[bcrypt $new_password, '2b', 12, $new_salt]})";

