use strict;
use warnings;
package Cube::Client;

BEGIN {
    $Cube::Client::VERSION = "0.1.1";
}

# vendor
use JSON::XS;
use Net::Domain;
use POSIX qw{strftime};
use Carp qw{croak};

# local modules
use Cube::Transports::HTTP;
use Cube::Transports::UDP;


=item new(transport, api_version, use_remote_time)

    Constructor for the Cube::Client.

Arguments:

    transport -- Either 'http' (default) or 'udp'.
    api_version -- Cube server API version, defaults to '1.0'.
    use_remote_time -- Flag to use server time instead of local, defaults to 0.

Returns

    Cube::Client instance.

=cut
sub new {
    my ($class, %args) = @_;

    # unpack
    my $transport_type = $args{'transport'} || 'http';
    my $api_version = $args{'api_version'} || '1.0';
    my $use_remote_time = $args{'use_remote_time'} || 0;

    # pass api version to transport
    if ($api_version) {
        $args{'api_version'} = $api_version;
    }

    my $transport = undef;
    if ($transport_type eq 'udp') {
        $transport = Cube::Transports::UDP->new(%args);
    } else {
        $transport = Cube::Transports::HTTP->new(%args);
    }

    my $self = {
        'use_remote_time' => $use_remote_time,
        'transport'      => $transport,
    };

    # reference the package
    bless $self, $class;
    return $self;
}


=item is_development

    Accessor used to determine if this is a development machine. Checks
    the hostname of the machine for 'dev-' prefix.

Returns:

    String

=cut
sub is_development {
    return Net::Domain::hostname() =~ m/^dev-/;
}


=item transport

    Accessor for the underlying transport object, either HTTP or UDP.

Returns:

    Cube::Transports::BaseTransport subclass (HTTP|UDP) instance.
=cut
sub transport {
    my ($self) = @_;
    return $self->{'transport'};
}


=item hostname

    Accessor for hostname value.

Returns:

    String

=cut
sub hostname {
    my ($self) = @_;
    return $self->transport->hostname;
}


=item port

    Accessor for port value.

Returns:

    Integer

=cut
sub port {
    my ($self) = @_;
    return $self->transport->port;
}


=item timestamp

    Generates and returns a string ISO8601 timestamp of 'now',
    Zulu (UTC) time.

Returns:

    String

=cut
sub timestamp {
    my ($self, $now) = @_;
    $now = $now || time();
    my $tz = strftime("%z", localtime($now));
    # regex changes '-0700' to '-07:00' for ISO8601
    $tz =~ s/(\d{2})(\d{2})/$1:$2/;
    my $ret = strftime("%Y-%m-%dT%H:%M:%S", localtime($now)) . $tz;
    return $ret;
}


=item use_local_time

    Accessor used to determine whether we generate time here or at the
    server.

Returns:

    Boolean

=cut
sub use_local_time {
    my ($self) = @_;
    if ($self->{'use_remote_time'}) {
        return 0;
    }
    return 1;
}


=item generate_event(type, data)

    Accessor used to determine whether we generate time here or at the
    server.

Arguments:

    type -- string namespace for the event, eg: 'wiznat' or 'fiz.bang'. 
            Note:
            - you can use up to a maximum of 1 '.' separators,
            - keys need to be all lowercase,
            - keys cannot start with numbers.
            - (TODO: these all need enforced and tested)
    data -- hashref data object to send to the cube server.

Returns:

    event object (hash)

=cut
sub generate_event {
    my ($self, $event_type, $data) = @_;
    unless ($event_type) {
        croak "event_type must be specified as first argument.";
    }
    unless ($data) {
        croak "data_hashref must be specified as the second argument.";
    }

    # specify dev-related debugging.
    if ($self->is_development) {
        $data->{'dev'} = 'true';
    }

    my $event = {'type'=>"$event_type", 'data'=>$data};

    # decide what timestamp to use, local/remote
    if ($self->use_local_time) { 
        # if timestamp was provided, transfer it to the parent
        # $event, $data becomes a child of the event and we 
        # don't want a duplicate value
        if ($data->{'time'}) {
            $event->{'time'} = $data->{'time'};
            delete $data->{'time'};
        } else {
            $event->{'time'} = $self->timestamp;
        }
    }
    return $event;
}


=item put(type, data)

    Send provided data to the cube server using the local transport.

Arguments:

    See `generate_event`.

Usage:

    $cube->put('event_name', {'measurement'=>5});
    $cube->put('event_name', {'measurement'=>5, 'id': 123}); # update
    $cube->put('event_name', {'measurement'=>5, 'time': '2011-09-12T21:33:12+07:00'});

Returns:

    event object (hash)

=cut
sub put {
    my $self = shift @_;
    # pass args directly through to generate_event
    my $event = $self->generate_event(@_);  
    $self->{'transport'}->send($event);
    return $event;
}

return 1;
