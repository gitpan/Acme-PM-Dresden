package Acme::PM::Dresden::Convert::VQWiki2TWiki;

use strict;
use warnings;

use Class::MethodMaker;

use Class::MethodMaker
 get_set => [
             'vqwiki',
            ],
 new_with_init => 'new',
 new_hash_init => 'hash_init';

sub init  {
  my $self   = shift;
  $self->pre_init  (@_);
  $self->hash_init (@_);
  $self->post_init (@_);
}

sub pre_init {
  my $self   = shift;
  $self->vqwiki      ('');
}

sub post_init {
  my $self   = shift;
}

sub twiki {
  my $self = shift;

  return vqwiki2twiki ($self->vqwiki)           if $self->vqwiki;
  return '';
}

sub vqwiki2twiki {
  my $text        = shift;

  my $in_table    = 0;
  my $in_html     = 0;
  my $in_java     = 0;
  my $in_verbatim = 0;
  my $output      = "";

  my @lines = split /\n/m, $text;

  foreach my $line (@lines) {
    $line =~ s/[\n\r]*$//;
    # start table
    if ($line =~ /^####/ and not $in_table) {
      $in_table = 1;
      $output .= "\n";
      next;
    }
    # end table
    if ($line =~ /^####/ and $in_table) {
      $in_table = 0;
      $output .= "\n";
      next;
    }
    # start html
    if ($line =~ /\[<html>\]/ and not $in_html) {
      $in_html = 1;
    }
    # end html
    if ($line =~ /\[<\/html>\]/ and $in_html) {
      $in_html = 0;
    }
    # start java
    if ($line =~ /\[<java>\]/ and not $in_java) {
      $in_java = 1;
    }
    # end java
    if ($line =~ /\[<\/java>\]/ and $in_java) {
      $in_java = 0;
    }
    # table content (evtl. erst NACH normaler Konvertierung?)
    if ($in_table) {
      $line =~ s/##/|/g;
      $line = '| '.$line;
    }
    # end verbatim (start verbatim is recognized after other transformations)
    if ($line =~ /^\s*$/ and $in_verbatim) { # empty line
      $in_verbatim = 0;
      $output .= "</verbatim>\n\n";
      next;
    }
    # verbatim content
    if ($in_verbatim) {
      $output .= "$line\n";
      next;
    }
    # explicit linking
    $line =~ s/\`([^\`]+)\`/\[\[$1\]\]/g;
    # horizontal line
    $line =~ s/^-{4,}$/---/g;
    # h1
    $line =~ s/^!{3}\s*([^!]+)!{3}/---+ $1\n/g;
    # h2
    $line =~ s/^!{2}\s*([^!]+)!{2}/---++ $1\n/g;
    # h3
    $line =~ s/^!{1}\s*([^!]+)!{1}/---+++ $1\n/g;
    # center
    $line =~ s/^\s*::\s*([^!]+)::\s$/\<center\>\n$1\n\<\/center\>\n/g;
    # underline
    $line =~ s/={3}([^']+)={3}/<u>$1<\/u>/gm;
    # bold italics
    $line =~ s/'{5}([^']+)'{5}/__$1__/gm;
    # bold
    $line =~ s/'{3}([^']+)'{3}/\*$1\*/gm;
    # italics
    $line =~ s/'{2}([^']+)'{2}/_$1_/gm;
    # code
    $line =~ s/\{\{\{([^\`]+)\}\}\}/=$1=/gm;
    # html
    $line =~ s/\[<\/?html>\]//gm;
    # java code
    $line =~ s/\[<java>\]/<verbatim>/gm;
    $line =~ s/\[<\/java>\]/<\/verbatim>/gm;
    # bullet list
    $line =~ s/^\t{1}\*\s*(.+)$/   * $1/g;
    $line =~ s/^\t{2}\*\s*(.+)$/      * $1/g;
    $line =~ s/^\t{3}\*\s*(.+)$/         * $1/g;
    $line =~ s/^\t{4}\*\s*(.+)$/            * $1/g;
    $line =~ s/^\t{5}\*\s*(.+)$/               * $1/g;
    # numbered list
    $line =~ s/^\t{1}\#\s*(.+)$/   1 $1/g;
    $line =~ s/^\t{2}\#\s*(.+)$/      1 $1/g;
    $line =~ s/^\t{3}\#\s*(.+)$/         1 $1/g;
    $line =~ s/^\t{4}\#\s*(.+)$/            1 $1/g;
    $line =~ s/^\t{5}\#\s*(.+)$/               1 $1/g;
    # start verbatim (after other transformations)
    if ($line =~ /\@\@\@\@/ and not $in_verbatim) {
      $in_verbatim = 1;
      $line =~ s/\@\@\@\@/<verbatim>/g;
      $output .= "$line\n";
      next;
    }
    # newline (should be last, as it inserts newline)
    $line =~ s/\@\@/ %BR%\n/g;
    # each original linebreak is new paragraph
    $output .= "$line\n";
    unless (
               ($line =~ /^(   ){1,}\*/) # bulleted list item (already twiki syntax)
            or ($line =~ /^(   ){1,}1/)  # numbered list item (already twiki syntax)
            or $in_verbatim
            or $in_table
            or $in_html
            or $in_java
           ) {
      $output .= "\n";
    }
  }
  # multiple empty lines become one
  $output =~ s/^\s*$//gm;
  $output =~ s/\n\n\n+/\n\n/gm;
  # always end with newline
  $output =~ s/(\s*\n*)$/\n/g;
  return $output;
}

1;
