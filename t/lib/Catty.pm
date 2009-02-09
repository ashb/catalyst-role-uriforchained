package Catty;

use Moose;

extends 'Catalyst';

with 'Catalyst::Role::UriForChained';

__PACKAGE__->setup;

1;
