use strict;
use warnings;

use Test::More tests => 10;
use Data::Dumper;

require_ok('Cube::Transports::HTTP');

print "\nTESTING INSTANCE\n";
my $transport = Cube::Transports::HTTP->new;
isa_ok($transport, 'Cube::Transports::HTTP', 'It should be an instance of Cube::Transports::HTTP.');

print "\nTESTING DEFAULT SETTINGS\n";
is($transport->hostname, 'localhost', 'It should default to hostname "localhost".');
is($transport->port, 1080, 'It should default to port 1080.');
is($transport->api_version, '1.0', 'It should have api_version 1.0.');
is($transport->_generate_event_url, 'http://localhost:1080/1.0/event/put', 'It should have the correct default event url.');

print "\nTESTING CUSTOM SETTINGS\n";
$transport = Cube::Transports::HTTP->new(hostname=>'1.2.3.4', port=>9999, api_version=>'1.1');
is($transport->hostname, '1.2.3.4', 'It should have hostname "1.2.3.4".');
is($transport->port, 9999, 'It should have port 9999.');
is($transport->api_version, '1.1', 'It should have api_version 1.1.');
is($transport->_generate_event_url, 'http://1.2.3.4:9999/1.1/event/put', 'It should have the correct custom event url.');
