use strict;
use warnings;
package Cube::Transports::UDP;

use Cube::Transports::Base;
use base 'Cube::Transports::Base';

use IO::Socket;
use JSON::XS;

my $json = JSON::XS->new;


=item new(hostname, port)

    Constructor for the Cube::Transports::UDP.

Arguments:

    hostname -- string domain name or ip of the server eg: '1.2.3.4', 
                            defaults to 'localhost'.
    port -- integer port number of the cube server, defaults to 1080.

Returns

    Cube::Transports::UDP instance.

=cut
sub new {
    my ($class, %args) = @_;
    my $port = $args{'port'} || 1180;
    my $self = $class->SUPER::new(hostname=>$args{'hostname'}, port=>$port);
    $self->{'socket'} = IO::Socket::INET->new(
        Proto=>'udp',
        PeerPort=>$self->port,
        PeerAddr=>$self->hostname,
    );

    bless $self, $class;
    return $self;
}


=item send(data)

    Sends data to the Cube server through a UDP socket, json-encoded.

Arguments:
    
    data -- hashref object to be sent to server.

Returns:

    true

=cut
sub send {
    my ($self, $data) = @_;
    $self->{'socket'}->send($json->encode($data));
    return 1;
}

return 1;