use strict;
use warnings;

use Test::More tests => 6;
use Data::Dumper;

require_ok('Cube::Transports::UDP');

print "\nTESTING INSTANCE\n";
my $transport = Cube::Transports::UDP->new;
isa_ok($transport, 'Cube::Transports::UDP', 'It should be an instance of Cube::Transports::UDP.');

print "\nTESTING DEFAULT SETTINGS\n";
is($transport->hostname, 'localhost', 'It should default to hostname "localhost".');
is($transport->port, 1180, 'The port should default to 1180.');

print "\nTESTING CUSTOM SETTINGS\n";
$transport = Cube::Transports::UDP->new(hostname=>'1.2.3.4', port=>9999, api_version=>'1.1');
is($transport->hostname, '1.2.3.4', 'It should have hostname "1.2.3.4".');
is($transport->port, 9999, 'It should have port 9999.');