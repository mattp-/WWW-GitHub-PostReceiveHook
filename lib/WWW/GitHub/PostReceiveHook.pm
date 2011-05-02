use Web::Simple 'WWW::GitHub::PostReceiveHook';
{
    package WWW::GitHub::PostReceiveHook;

    use Try::Tiny;
    use JSON::Any;

    has routes => (
        is        => 'rw',
        predicate => 'has_routes',
        required  => 1,
        isa       => sub {
            # must be hash
            die 'Routes must be a HASH ref.' unless ref $_[0] eq 'HASH';

            # validate each route
            while (my ($key, $value) = each %{ $_[0] }) {
                # must match simple path
                die 'Routes must be of the form qr{^/\w+/?}' if $key !~ m{^/\w+/?$};
                # must map to a coderef
                die 'route must map to CODE ref.' unless ref $value eq 'CODE';
            }
        },
    );

    sub dispatch_request {

        sub (POST + /*) {
            my ( $self, $path ) = @_;

            # only pass along the request if it matches a given path
            return if ! $self->has_routes || ! $self->routes->{ "/$path" };

            # catch the payload
            sub (%payload=) {
                my ( $self, $payload ) = @_;

                try {
                    # deserialize
                    my $json = JSON::Any->jsonToObj( $payload );

                    # callback
                    $self->routes->{ "/$path" }->( $json );
                }
                catch {
                    warn "Exception: /$path: attempted to trigger callback but failed:\n$_";

                    # override the default 200 OK
                    return [ 400, [ 'Content-type' => 'text/plain' ], ['Bad Request'] ];
                };

                [ 200, [ 'Content-type' => 'text/plain' ], ['OK'] ];
            }
        },
    }

}

1;
