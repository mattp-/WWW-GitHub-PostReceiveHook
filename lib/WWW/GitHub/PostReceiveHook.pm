use Web::Simple 'WWW::GitHub::PostReceiveHook';
{
    package WWW::GitHub::PostReceiveHook;

    use Try::Tiny;
    use JSON;

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
                my $response;

                try {
                    # deserialize
                    my $json = decode_json $payload;

                    # callback
                    $self->routes->{ "/$path" }->( $json );
                }
                catch {
                    # malformed JSON string, neither array, object, number, string or atom, at character offset 0 ?
                    # you are trying to POST non JSON data. don't do that.
                    warn "Caught exception: /$path: attempted to trigger callback but failed:\n$_";

                    # override the default 200 OK
                    $response = [ 400, [ 'Content-type' => 'text/plain' ], ['Bad Request'] ];
                };

                # return catch response if set
                return $response if $response;

                $response = [ 200, [ 'Content-type' => 'text/plain' ], ['OK'] ];
            }
        },
    }

}

1;
