use strict;
use warnings;

use Test::More tests => 24;
use Data::Dumper;

require_ok('Cube::Client');
require_ok('Cube::Transports::HTTP');
require_ok('Cube::Transports::UDP');
 
print "\nTESTING HTTP DEFAULTS\n";
my $cube = Cube::Client->new;
isa_ok($cube, 'Cube::Client', 'It should be an instance of Cube::Client.');
isa_ok($cube->transport, 'Cube::Transports::HTTP', 'It should pick HTTP transport by default.');
is($cube->hostname, 'localhost', 'It should default to "localhost" for hostname.');
is($cube->port, 1080, 'It should default to port 1080 for http.');
is($cube->use_local_time, 1, 'It should use local time by default.');

print "\nTESTING UDP DEFAULTS\n";
$cube = Cube::Client->new(transport=>'udp');
isa_ok($cube->transport, 'Cube::Transports::UDP', 'The transport should be UDP.');
is($cube->port, 1180, 'It should default to port 1180 for udp.');

print "\nTESTING NON DEFAULTS\n";
$cube = Cube::Client->new(hostname=>'11.22.33.44', port=>9876, use_remote_time=>1);
is($cube->hostname, '11.22.33.44', 'It should use a custom hostname.');
is($cube->port, 9876, 'It should use a custom port.');
is($cube->use_local_time, 0, 'It should not use local time.');

print "\nTESTING EVENT GENERATION\n";
$cube = Cube::Client->new;
eval {
  my $event = $cube->generate_event;
};
ok($@ ne '', 'It should provide an error when generating event with no arguments.');
like($@, qr/event_type must be specified/, 'It should provide specify the parameter that is missing');

eval {
  my $event = $cube->generate_event('foo_type');
};
ok($@ ne '', 'It should provide an error when generating event with missing hash_ref argument.');
like($@, qr/data_hashref must be specified/, 'It should provide specify the parameter that is missing');

my $event = $cube->generate_event('foo_type', {'wiznat' => 'fizbang'});
is($event->{'type'}, 'foo_type', 'It should generate the proper "type" key.');
is($event->{'data'}->{'wiznat'}, 'fizbang', 'It should transfer the hashref to the data key.');
isnt(undef, $event->{'time'}, 'It should generate a timestamp');
is($cube->use_local_time, 1, 'use_local_time flag should be true.');
#
my $time = "2000-01-01T12:01:01+0700";
$event = $cube->generate_event('foo_type', {'wiznat' => 'fizbang', 'time' => $time});
is($event->{'time'}, $time, 'It should transfer the time param when provided.');
#
my $cube2 = Cube::Client->new(
  hostname=>'11.22.33.44',
  collector_port=>8888,
  evaluator_port=>9999,
  use_remote_time=>1,
);
is($cube2->use_local_time, 0, "use_local_time flag should be false when overriden.");
$event = $cube2->generate_event('foo_type', {'wiznat' => 'fizbang'});
is(undef, $event->{'time'}, 'It should not generate a timestamp when disable_timestamp is 1.');

