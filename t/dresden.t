#! /usr/bin/perl

use Acme::PM::Dresden;
use Test::More;

use strict;
use warnings;

plan tests => 1;

################## tests ##################

##############
like (Acme::PM::Dresden::hello(), qr/Hello world/, 'hello');
