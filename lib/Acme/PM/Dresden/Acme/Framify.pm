package Acme::PM::Dresden::Acme::Framify;
#TODO Namen "andern, das ist nur der Arbeitsname

use strict;
use warnings;

use vars qw($VERSION);
$VERSION = 0.01;

sub framify {
  my $text   = shift;
  my $result = "";
  my @lines  = split /\n/, $text;

  foreach (@lines) {
    my $d1 = "";
    my $d2 = "";
    my $l  = "";

    map {
      if ( 75 <=  (length($_.$d1)+5) ) {
        $result .= "$d1>\n$l>\n$d2>\n";
        $d1 = $d2 = $l = " >";
      }

      $d1 .= ","."-"x(length($_)+2).". ";
      $d2 .= "`"."-"x(length($_)+2)."´ ";
      $l  .= "| $_ | ";
    } (split);

    $result .= ((length($l)) ? "$d1\n$l\n$d2\n" : ",--.\n|  |\n`--´\n");
  }
  return $result;
}

1;
