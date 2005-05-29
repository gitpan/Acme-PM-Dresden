#! /usr/bin/perl

use Acme::PM::Dresden::Acme::Framify;
use Test::More;

use strict;
use warnings;

plan tests => 2;

################## tests ##################

##############
my $target = qr/,------\. \n\| affe \| \n\`------\´ \n/s;
my $framed = Acme::PM::Dresden::Acme::Framify::framify('affe');
#print STDERR "\n", $framed, "\n";
like ($framed, $target, 'framify');

$target = qr/,------\. ,-------\. \n\| affe \| | zomtec | \n\`------\´ `-------\´ \n/s;
$framed = Acme::PM::Dresden::Acme::Framify::framify('affe zomtec');
#print STDERR "\n", $framed, "\n";
like ($framed, $target, 'framify');
