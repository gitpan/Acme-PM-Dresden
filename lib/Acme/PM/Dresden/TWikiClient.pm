package Acme::PM::Dresden::TWikiClient;

use MIME::Base64;
use WWW::Mechanize;

use strict;
use warnings;

use base 'WWW::Mechanize';

use Class::MethodMaker
 get_set => [
	     'bin_url',
	     'current_default_web',
	     'current_topic',
	     'auth_user',
	     'auth_passwd',
	     'override_locks',
            ],
 new_hash_init => 'hash_init'
 ;

sub new {
  my $class = shift;
  my $self = WWW::Mechanize::new ($class);
  $self->pre_init ();
  $self->hash_init (@_);
  $self->post_init ();
  return $self;
}

sub pre_init {
  my $self   = shift;
  $self->override_locks (0);
}

sub post_init {
  my $self   = shift;
}

# overloaded to provide username and password
# that we have in two own getters/setters
sub get_basic_credentials {
  my $self = shift;
  return ($self->auth_user, $self->auth_passwd);
}

# constructs URL
# if topic doesn't contain a Web prefix, "current_default_web" is prepended
sub make_url {
  my $self  = shift;
  my $cmd   = shift;
  my $topic = shift;
  my $tail  = shift;

  my $url = $self->bin_url;
  if ($topic =~ /\./) {
    $topic =~ s!\.!/!;
  } else {
    $topic = $self->current_default_web."/$topic";
  }
  $url .= '/' if $url !~ m!/$!;
  $url .= "$cmd/";
  $url .= $topic;
  $url .= $tail if $tail;
  return $url;
}

sub skin_regex_topic_locked {
  my $self = shift;
  return qr/name="Topic_is_locked_by_another_user"/;
}

sub skin_regex_topic_locked_edit_anyway {
  my $self = shift;
  return qr/Edit anyway/;
}

sub skin_regex_authentication_failed {
  my $self = shift;
  return qr/name="Either_you_need_to_register_or_t"/;
}

# a little helper function
sub htmplparse_get_text {
  my $self = shift;

  my($p, $stop) = @_;
  my $text;
  while (defined(my $t = $p->get_token)) {
    if (ref $t) {
      $p->unget_token($t) unless $t->[0] eq $stop;
      last;
    }
    else {
      $text .= $t;
    }
  }
  return $text;
}

sub htmlparse_extract_single_textarea {
  my $self = shift;
  my $doc = shift || $self->doc || '';

  my @FORM_TAGS = qw(form textarea);
  my $p = HTML::PullParser->new (
				 doc 	     => $doc,
				 start 	     => 'tag, attr',
				 end   	     => 'tag',
				 text  	     => '@{text}',
				 report_tags => \@FORM_TAGS,
				);
  while (defined(my $t = $p->get_token)) {
    next unless ref $t; # skip text
    if ($t->[0] eq "form") {
      shift @$t;
      while (defined(my $t = $p->get_token)) {
	next unless ref $t;  # skip text
	last if $t->[0] eq "/form";
	if ($t->[0] eq "textarea") {
	  return $self->htmplparse_get_text ($p, "/textarea");
	}
      }
    }
  }
  return undef;
}

sub edit_press_cancel {
  my $self = shift;

  my $url = $self->make_url ('view', $self->current_topic, '?unlock=on');
  print STDERR "edit_press_cancel: $url\n";
  $self->follow_link (url => $url);
}


sub read_topic {
  my $self = shift;
  my $topic = shift || $self->current_topic;
  my $url = $self->make_url ('view', $topic, '?raw=on');
  print STDERR "read_topic: $url\n";
  $self->get ($url);
  return $self->htmlparse_extract_single_textarea ($self->content);
}

sub save_topic {
  my $self = shift;
  my $content = shift;
  my $topic = shift || $self->current_topic;

  my $url = $self->make_url ('edit', $topic);
  print STDERR "save_topic: $url\n";

  # get page
  $self->get ($url);

  # locked?
  my $html_content = $self->content;
  if ($html_content =~ $self->skin_regex_topic_locked) {
    if ($self->override_locks) {
      # edit anyway
      $self->follow_link (text_regex => $self->skin_regex_topic_locked_edit_anyway);
      $self->get ($url);
    } else {
      print STDERR "Topic is locked.\n";
      return undef;
    }
  } elsif ($html_content =~ $self->skin_regex_authentication_failed) {
    print STDERR "Access denied. Authentication failed.\n";
    return undef;
  }

  # fill form
  $self->form_number (1);
  $self->current_form;
  $self->set_fields ( text => $content );
  $self->click_button ( value => "Save" );
  return 1;
}

1;
