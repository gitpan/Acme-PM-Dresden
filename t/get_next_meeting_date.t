#! /usr/bin/perl

use Acme::PM::Dresden;
use Test::More;

use XML::Simple;

use strict;
use warnings;

plan tests => 1;

################## tests ##################

##############
like (Acme::PM::Dresden::hello(), qr/Hello world/, 'hello');

my $fcontent_raw;
my $fcontent_xml;
my $fcontent_html;

my $fname_raw = "t/TermineTreffen_rawrss.xml";
open FH, "<$fname_raw";
{
  local $/;
  $fcontent_raw = <FH>;
}
close FH;

my $fname_xml = "t/TermineTreffen.xml";
open FH, "<$fname_xml";
{
  local $/;
 $fcontent_xml = <FH>;
}
close FH;

my $fname_html = "t/TermineTreffen.htm";
open FH, "<$fname_html";
{
  local $/;
  $fcontent_html = <FH>;
}
close FH;

#print $fcontent_raw . "\n";
#print "-"x 70 . "\n";
#print $fcontent_raw . "\n";
#print "-"x 70 . "\n";
#print $fcontent_raw . "\n";

if ($fcontent_raw =~ m/(\d{1,2}\.\s*(Januar|Februar|März|April|Mai|Juni|Juli|August|September|Okober|November|Dezember)\s20\d\d)/) {
  print "MATCH: " . $1 . "\n";
}
