#! /usr/bin/perl

use strict;
use warnings;

use Acme::PM::Dresden::Convert::VQWiki2TWiki;
use Test::More;

use Text::Diff;

plan tests => 1;

my $fname = "t/vqwikipage.txt";
my $text;
open FH, "<$fname";
{
  local $/;
  $text = <FH>;
}
close FH;

################## tests ##################

my $convert = new Acme::PM::Dresden::Convert::VQWiki2TWiki (vqwiki => $text);
my $twiki_text = $convert->twiki;

##############
my $diff = diff \$twiki_text, "t/target_twikipage.txt";
ok     (!$diff, "convert from vqwiki")
 or diag ("convert from vqwiki, diff:\n$diff");
