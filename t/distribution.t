#! /usr/bin/perl

use strict;
use Test::More;

# not => 'description', because we wait until Test::Distribution accepts our ChangeLog file."
eval "use Test::Distribution not => 'description'";
plan skip_all => "Test::Distribution required for checking distribution" if $@;
