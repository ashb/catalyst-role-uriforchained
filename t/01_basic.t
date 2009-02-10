use strict;
use warnings;

use Test::More tests => 3;

use FindBin '$Bin';
use lib "$Bin/lib";

use Test::WWW::Mechanize::Catalyst;
my $m = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'Catty');

can_ok("Catty", 'uri_for_chained');

$m->get_ok('/');
$m->content_is("http://localhost/product/123");
$m->get_ok("http://localhost/product/123");
$m->content_is("http://localhost/product/123/rate/5");



