package Acme::PM::Dresden::VQWikiClient;

use MIME::Base64;
use WWW::Mechanize;

use strict;
use warnings;

use base 'WWW::Mechanize';

use Class::MethodMaker
 get_set => [
	     'bin_url',
	     'current_topic',
	     'auth_user',
	     'auth_passwd',
	     'verbose',
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
  $self->verbose (0);
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

sub make_action_url {
  my $self   = shift;
  my $action = shift;
  my $topic  = shift;

  my $url = $self->bin_url;
  $url .= "?topic=$topic";
  $url .= "&action=action_$action";
  return $url;
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

  #print STDERR "edit_press_cancel\n" if $self->verbose;
  $self->form_number (1);
  $self->current_form;
  $self->click_button ( name  => 'action',
			value => $self->value_cancel_button );
}

sub regex_save_user {
  my $self = shift;
  return qr/form name=".*" method="post" action=".*\?action=action_save_user"/;
}

sub regex_error {
  my $self = shift;
  return qr/<title>Error<\/title>/;
}

sub value_cancel_button {
  my $self = shift;
  return 'Abbrechen';
}

sub value_save_button {
  my $self = shift;
  return 'Speichern';
}

sub handle_save_user {
  my $self = shift;

  #print STDERR "Handle user registration.\n" if $self->verbose;
  $self->form_number (2);
  $self->current_form;
  $self->set_fields ( username => $self->auth_user );
  $self->click_button ( value => "Save" );
  return $self->content;
}

sub read_topic {
  my $self = shift;
  my $topic = shift || $self->current_topic;
  my $url = $self->make_action_url ('edit', $topic);
  #print STDERR "read_topic: $url\n" if $self->verbose;
  $self->get ($url);
  my $html_content = $self->content;

  # user registration
  if ($html_content =~ $self->regex_save_user)
  {
    $html_content = $self->handle_save_user;
  }
  # locked?
  if ($html_content =~ $self->regex_error)
  {
    print STDERR "Error editing page. Probably locked.\n" if $self->verbose;
    return undef;
  }

  my $raw_content = $self->htmlparse_extract_single_textarea ($html_content);
  $self->edit_press_cancel;
  return $raw_content;
}

sub save_topic {
  my $self    = shift;
  my $content = shift;
  my $topic   = shift || $self->current_topic;

  my $url = $self->make_action_url ('edit', $topic);
  #print STDERR "save_topic: $url\n" if $self->verbose;
  $self->get ($url);
  my $html_content = $self->content;

  # user registration
  if ($html_content =~ $self->regex_save_user)
  {
    $html_content = $self->handle_save_user;
  }
  # locked?
  if ($html_content =~ $self->regex_error)
  {
    print STDERR "Error editing page. Probably locked.\n" if $self->verbose;
    return 0;
  }

  $self->form_number (1);
  $self->current_form;
  $self->set_fields ( contents => $content );
  $self->click_button ( name  => 'action',
			value => $self->value_save_button );

  return 1;
}

1;
