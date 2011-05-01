use Web::Simple 'WWW::GitHub::PostReceiveHook';

{
    package WWW::GitHub::PostReceiveHook;
    use JSON;
    use Data::Dump;

    has routes => (
        is       => 'rw',
        required => 1
    );

    sub BUILD {
    }

    sub dispatch_request {

        sub (POST + /*) {
            my ( $self, $path ) = @_;
            return if !$self->has_routes;

            sub (%payload=) {
                my ( $self, $p ) = @_;
                dd from_json $p;
                [ 200, [ 'Content-type' => 'text/plain' ], ['OK'] ];
              }
          }, sub () {
            [ 405, [ 'Content-type', 'text/plain' ], ['Method not allowed'] ];
          }
    }
}

1;
