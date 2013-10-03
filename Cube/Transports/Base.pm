use strict;
use warnings;

package Cube::Transports::Base;


=item new(hostname, port, api_version)

    Base class for Cube::Transports. Implement the 'send' method at minimum
    in your subclass to add transports to this package.

Arguments:

    hostname -- string domain name or ip of the server eg: '1.2.3.4', 
                            defaults to 'localhost'.
    port -- integer port number of the cube server, defaults to 1080.
    api_version -- the API version of the Cube server.

Returns

    Cube::Transports::Base instance.

=cut
sub new {
    my ($class, %args) = @_;
    my $self = {
        'hostname' => $args{'hostname'} || 'localhost',
        'port' => $args{'port'},
        'api_version' => $args{'api_version'} || '1.0',
    };
  
    bless($self, $class);
    return $self;
}


=item port

    Accessor for port value.

Returns:

    Integer

=cut
sub port {
    my $self = shift @_;
    return $self->{'port'};
}


=item hostname

    Accessor for hostname value.

Returns:

    String

=cut
sub hostname {
    my $self = shift @_;
    return $self->{'hostname'}
}


=item api_version

    Accessor for api_version value.

Returns:

    String

=cut
sub api_version {
    my $self = shift @_;
    return $self->{'api_version'};
}

=item send

    Extension point for subclasses to send data somewhere.

=cut
sub send {
    my $self = shift @_;
    print "WARNING: you need to extend this class to send data somewhere...";
}

return 1;