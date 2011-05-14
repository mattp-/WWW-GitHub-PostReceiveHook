use Web::Simple 'WWW::GitHub::PostReceiveHook';
package WWW::GitHub::PostReceiveHook;
# ABSTRACT: A simple means of receiving GitHub's web hooks

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

=head2



=cut

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

1;

__END__

=head1 Synposis

Create the listener:

    use WWW::GitHub::PostReceiveHook;

    my $s = WWW::GitHub::PostReceiveHook->new(
        routes => {
            '/myProject' => sub { print 'hello' },
            '/myOtherProject' => sub { run3 \@cmd ... }
        }
    )->run_if_script;

Save it. Toss it in /cgi-bin or mount it as a psgi app.

=head1 Why WWW::GitHub::PostReceiveHook?

Sometimes you just want to kick off an email, or run a small script when someone commits to github. In situations like these, busting out a full-sized framework like Dancer/Catalyst is almost always overkill to listen for GitHub's postreceive hooks. Use this module and you can be off to the races after a quick copy-paste.

=head1 Can't I do this just as easily using Web::Simple?

Yes! But most people searching cpan for 'github postreceive' probably haven't heard of Web::Simple.

=head1 SEE ALSO

WWW::GitHub::PostReceiveHook uses L<Web::Simple> to do the heaving lifting, so that would be a good start.

L<Web::Simple>, L<Dancer>, L<Catalyst>, L<CGI>
