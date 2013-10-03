#!/usr/bin/perl -w

# Usage:
#   $ perl test_harness.pl

# OK if it ends with 'PASS'

use strict;
use warnings;
use TAP::Harness;

my %args = (
  lib => [ 
    'Cube',
    'Cube/Transports',
  ],
);
my $harness = TAP::Harness->new(\%args);
my @tests = (
  'Cube/tests/00_TestCubeClient.t',
  'Cube/tests/01_TestHTTPTransport.t',
  'Cube/tests/02_TestBaseTransport.t',
  'Cube/tests/03_TestUDPTransport.t',
);
$harness->runtests(@tests);