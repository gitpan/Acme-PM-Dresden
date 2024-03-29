#! /usr/bin/perl

use strict;
use Test::More;

if ($ENV{DO_DIST_CHECK}) {
  eval "use Test::Distribution";
  plan skip_all => "Test::Distribution required for checking distribution" if $@;
} else {
  print STDERR 
  plan skip_all => 'Test::Distribution skipped unless env $DO_DIST_CHECK set.';
}
