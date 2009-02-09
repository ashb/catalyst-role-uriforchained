package Catty::Controller::Root;

use Moose;
use namespace::clean -except => ['meta'];

BEGIN { extends 'Catalyst::Controller'; }

__PACKAGE__->config( namespace => '' );

sub root : Chained('/') PathPart('') CaptureArgs(0) { }

sub index : Chained('root') PathPart('') Args(0) {
  my ($self, $c) = @_;

  $self->do($c, "/view_product", 123);
}

sub product : Chained('root') CaptureArgs(1) {
}

sub view_product : Chained('product') PathPart('') Args(0) {
  my ($self, $c) = @_;

  # chained action at same level.
  $self->do($c, "rate_product", 5);
}

sub rate_product : Chained('product') PathPart('rate') Args(1) {
}

sub category : Chained('root') CaptureArgs(2) {
}

sub chain2_1 : Chained('category') CaptureArgs(0) { }

sub chain2_2 : Chained('category') CaptureArgs(0) { }

sub chain2_1_1 : Chained('chain2_1') Args(1) {
  my ($self, $c) = @_;
}

sub chain2_1_2 : Chained('chain2_2') Args(0) { 
  my ($self, $c) = @_;

  # $self->do($c, "/view_product"); # Not enough caps
  $self->do($c, "/view_product", "123"); 
  #$self->do($c, "../chain_2_1_1", "foo");
}

sub do {
  my ($self, $c, $url, @args) = @_;

  $url = eval { $c->uri_for_chained($url, @args) };
  if (my $e = $@) {
    $c->res->body("Error: $e");
  } else {
    $c->res->body("$url");
  }
  $c->res->content_type('text/plain');
}

1;
