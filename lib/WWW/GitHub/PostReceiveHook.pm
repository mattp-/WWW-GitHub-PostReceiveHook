use Web::Simple 'WWW::GitHub::PostReceiveHook';

{
    package WWW::GitHub::PostReceiveHook;

    use Sub::Quote;
    use JSON;

    has routes => (
        is       => 'rw',
        required => 1,
        isa      => sub {
            # must be hash
            die 'Routes must be a HASH ref.' unless ref $_[0] eq 'HASH';

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
            return if !$self->has_routes;

            sub (%payload=) {
                my ( $self, $p ) = @_;
                use Data::Dump;
                dd from_json $p;
                [ 200, [ 'Content-type' => 'text/plain' ], ['OK'] ];
              }
          }, sub () {
            [ 405, [ 'Content-type', 'text/plain' ], ['Method not allowed'] ];
          }
    }
}

1;
