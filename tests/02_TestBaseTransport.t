use strict;
use warnings;

use Test::More tests => 8;
use Data::Dumper;

require_ok('Cube::Transports::Base');

print "\nTESTING INSTANCE\n";
my $transport = Cube::Transports::Base->new;
isa_ok($transport, 'Cube::Transports::Base', 'It should be an instance of Cube::Transports::Base.');

print "\nTESTING DEFAULT SETTINGS\n";
is($transport->hostname, 'localhost', 'It should default to hostname "localhost".');
is($transport->port, undef, 'The port should default to undef.');
is($transport->api_version, '1.0', 'It should have api_version 1.0.');

print "\nTESTING CUSTOM SETTINGS\n";
$transport = Cube::Transports::Base->new(hostname=>'1.2.3.4', port=>9999, api_version=>'1.1');
is($transport->hostname, '1.2.3.4', 'It should have hostname "1.2.3.4".');
is($transport->port, 9999, 'It should have port 9999.');
is($transport->api_version, '1.1', 'It should have api_version 1.1.');