#!/usr/bin/perl -w

# Usage:
#   $ perl test_harness.pl

# OK if it ends with 'PASS'

use strict;
use warnings;
use TAP::Harness;

my %args = (
  lib => [ 
    './',
    '../'
  ],
);
my $harness = TAP::Harness->new(\%args);
my @tests = (
  'tests/00_TestCubeClient.t',
  'tests/01_TestHTTPTransport.t',
  'tests/02_TestBaseTransport.t',
  'tests/03_TestUDPTransport.t',
);
$harness->runtests(@tests);