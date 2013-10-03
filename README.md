Cube Client
---
**New in version 0.1.1** UDP support.

Usage:
```
$client = Cube::Client(hostname=>'1.2.3.4', transport_type='udp');
```
This will use a UDP socket to beam your data to the target machine at port `1180` (default).


---

### tldr;
```
my $client = Cube::Client->new('hostname'=>'10.0.14.86'); # Cube server in the cloud
$client->put('my_gauge', {'value' => 10}); # a metric
$client->put('my_event', {'processing_time' => 1021, 'url' => '/foo/bar/'}); # an event

```

### Run tests
```
lib/perl/DevTools$ perl Cube/tests/test_harness.pl
```

### Getting started

**Note**: our Cube server is currently at the following url, he rest of the documentation 
will assume this as a base:
```
http://10.0.14.86:1081
```

**Also note**: all the timestamps are UTC, you'll need to factor offset into your calculations
when you start pulling data back.

Cube basically deals in 2 things: metrics and events. In reality, metrics are events, but they 
have their own format to actually qualify under the `/1.0/metric` evaluator. For more info on
metrics, events, and cube in general, check out [their wiki](https://github.com/square/cube/wiki)
under API Reference, it's fairly well documented.

### Sending a metric
Metrics are a "gauge" of something, for example, I just ran a loop, and want to report that the 
loop processed `71` vehicles. I would do something like:

```
$client->put('my_import.vehicle_count', {'value'=>71});
```
Note that the `value` key is what makes it a metric. 


To get that back, I would do:

```
/1.0/metric?expression=sum(my_import(value).re(subtype,'vehicle_count'))&step=864e5&limit=1&start=2013-01-09T00:00:00.000Z

// yields
[
  {
    "time": "2013-01-09T00:00:00.000Z",
    "value": 71
  }
]

```
##### A couple important things about this expression

 * `sum()` is going to give us the sum for that period
 * `my_import(value)` makes it return the actual `value`, to get a count of the number of `my_import` requests, we could just use `sum(my_import)`
 * `.re(subtype, 'vehicle_counts')` makes sure we only see that subtype
 * the resolution `864e5` is one day (other resolutions below).


Also, I don't need to use the subtype `vehicle_count`, the following would qualify as a metric also:
```
$client->put('a_value_to_measure', {'value'=>1234});
```

To see a (hypothetical) `max` metric every minute for the last 30 minutes, we could do:

```
/1.0/metric?expression=max(my_metric(value))&step=6e4&limit=30
```

Metrics are meant to be `sum`med and whatnot, for more of what you can do with metrics, see
[cube metric expressions](https://github.com/square/cube/wiki/Queries).


#### Sending an event
Events simply mark something at a point in time, but with Cube (as opposed to logging), you can
arbitrarily attach whatever data you want to the event for further evaluation. An example:

```
$client->put('my_import.run_decoder', {'event'=>'start', 'vin'=>'...'});
```
... or whatever you want.

To get that event back, you can:

```
/1.0/event?expression=my_import(*)&limit=1

// result
[
  {
    "time": "2013-01-09T22:21:18.000Z",
    "data": {
      "event": "start",
      "vin": "...",
      "subtype": "run_decoder"
    }
  }
]

```

I could also be more specific to drill down *just* to the `run_decoder` subtype:
```
/1.0/event?expression=my_import(*).re(subtype,'run_decoder')&limit=1

// result
[
  {
    "time": "2013-01-09T22:21:18.000Z",
    "data": {
      "event": "start",
      "vin": "...",
      "subtype": "run_decoder"
    }
  }
]

```
The results look the same, but the second query would only return `run_decoder` subtypes
as the first query would effectively return `my_import.*`.

#### Types
Types on the server [http://10.0.14.86:1081/1.0/types](http://10.0.14.86:1081/1.0/types)


#### Realtime streaming (and timestamps)


### TODO:

 * methods to query evaluator
 * UPD transport
 * websocket transport
 * shiny graphs
