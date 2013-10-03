use strict;
use warnings;
package Cube::Transports::HTTP;

use Cube::Transports::Base;
use base 'Cube::Transports::Base';

use HTTP::Async;
use HTTP::Request;
use JSON::XS;
my $JSON = JSON::XS->new;
my $async = HTTP::Async->new;


=item new(hostname, port, api_version)

    Constructor for the Cube::Transports::HTTP.

Arguments:

    hostname -- string domain name or ip of the server eg: '1.2.3.4', 
                defaults to 'localhost'.
    port -- integer port number of the cube server, defaults to 1080.
    api_version -- version of the Cube server API to use.

Returns

    Cube::Transports::HTTP instance.

=cut
sub new {
    my ($class, %args) = @_;
    # default port for http is 1080
    $args{'port'} = $args{'port'} || 1080;
    my $self = $class->SUPER::new(%args);
    # reference to the package
    bless $self, $class;
    return $self;
}


=item _generate_event_url

    Builds HTTP endpoint for post request based on hostname, port, and 
    api version.

Returns:

    string url endpoint

=cut
sub _generate_event_url {
    my ($self) = @_;
    my $hostname = $self->hostname;
    my $port = $self->port;
    my $api_version = $self->api_version;
    return "http://$hostname:$port/$api_version/event/put";
}

=item send(data)

    JSON-encodes and sends data to the Cube server using HTTP::Async.

Arguments:
    
    data -- hashref object to be sent to server.

Returns:

    true

=cut
sub send {
    my ($self, $data) = @_;
    my $request = HTTP::Request->new('POST', $self->_generate_event_url);
    $request->header('Content-Type' => 'application/json');
    $request->content($JSON->encode($data));
    
    # TODO: how to abstract this to test
    # TODO: ability to specify HTTPSync or HTTPAsync
    $async->add($request);
    
    return 1;
}

return 1;

