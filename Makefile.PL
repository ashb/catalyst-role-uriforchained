use inc::Module::Install 0.77;

use strict;
use warnings;

name 'Catalyst-Role-UriForChained';
all_from 'lib/Catalyst/Role/UriForChained.pm';

requires 'Catalyst' => '5.80';
requires 'Moose';
requires 'namespace::clean';

test_requires 'Test::More';
test_requires 'Test::WWW::Mechanize::Catalyst' => '0.50';

postamble(<<"EOM");
testcover: pm_to_blib
\tcover -delete
\tHARNESS_PERL_SWITCHES=-MDevel::Cover \$(MAKE) test
\tcover
EOM

resources(
    'repository' => 'git://github.com/ashb/catalyst-role-uriforchained.git',
    'homepage'   => 'http://github.com/ashb/catalyst-role-uriforchained/tree/master',
);

auto_install;
WriteAll;
