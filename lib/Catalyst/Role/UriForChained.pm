package Catalyst::Role::UriForChained;

use Carp qw/croak/;
use Moose::Role;

#use namespace::clean -except => ['meta'];

sub uri_for_chained {
  my ($c, $uri) = (shift,shift);

  my $action;
  if ($uri =~ m!^/!) {
    my $a = $c->dispatcher->get_action_by_path($uri);
    croak "Invalid action path $uri" unless $a;
    croak "Not a chained action: $uri" 
      unless $a->attributes->{Chained};

    $c->_uri_for_abs_chained($a, @_);
  } else {
    # Relative to current action
    $c->_uri_for_rel_chained($uri, @_);
  }
}

sub _uri_for_abs_chained {
  my ($c, $action) = (shift,shift);

  my @actions = $c->_build_action_chain($action);

  my @captures;
  my @captures_in = splice @_;

  my $a;
  foreach $a (@actions) {
      last unless exists $a->attributes->{CaptureArgs};
      my $cap_args = $a->attributes->{CaptureArgs}[0];
      croak("Not enough captures passed to uri_for_chained")
        unless $cap_args <= scalar @captures_in;

      push @captures, splice(@captures_in, 0, $cap_args);
  }

  @_ =  \@captures;
  my $args = $action->attributes->{Args};
  croak "Final action doesn't sepcify Args"
    unless $args;

  croak "Wrong number of final Args to uri_for_chained"
    if (defined $args->[0] && $args->[0] != @captures_in);

  push @_, @captures_in;

  $c->uri_for($action, @_);
}

sub _uri_for_rel_chained {
  my ($c, $uri) = (shift,shift);

  $DB::single = 1;
  my @shared;
  # First work out where the actions diverge
  my @segs = split m!/!, $uri;

  my $chain = $c->action->chain;

  my $search = 1;
  if ($segs[0] !~ /^\./) {
    $search = 0;
    @shared = @$chain[0..$#$chain-1];
  }

  while ($search) {
    $_ = $segs[0];
    if (/^\.$/) {
      # "./foo" Shared at parent to this chained
      @shared = @$chain[0..$#$chain-1];
      shift @segs;
      last;
    } elsif (/^\.\.$/) {
      croak "Invalid action path (no more parents): $uri"
        unless @$chain;
      pop @$chain;
      shift @segs;
    } else {
      last;
    }
  }

  1;
}

# TODO: Refactor this section into Cat::DispatchType::Chained or similar

# Given a terminal action, build up the chain for it
sub _build_action_chain {
  my ($c, $action) = @_;
  my $chain = $action->attributes->{Chained};

  my @actions = ($action);

  $chain = $chain->[0];
  while ($chain ne '/') {
      my $action = $c->dispatcher->get_action_by_path($chain);
      croak "Unable to find action in chain: $chain" unless $action;

      unshift @actions, $action;
      $chain = $action->attributes->{Chained}[0];
  }
  return @actions;
}

# Return the actions used by the given (chain of) actions
sub _captures_for_actions {
  my ($c, $actions) = @_;

  my $num = 0;
  $num += $_->attributes->{CaptureArgs}[0] for @$actions;
  return @{$c->req->captures}[0..$num-1];
}

1;
