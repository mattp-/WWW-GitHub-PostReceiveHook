use strict;
use warnings FATAL => 'all';

use Test::More (
  eval { require HTTP::Request::AsCGI }
    ? 'no_plan'
    : (skip_all => 'No HTTP::Request::AsCGI')
);

use WWW::GitHub::PostReceiveHook;

# create the server
my $app = WWW::GitHub::PostReceiveHook->new(
    routes => {
        '/hello' => sub {
            my ($payload) = @_;

            use Data::Dump;
            diag dd $payload;
        },
        '/goodbye' => sub { print 'goodbye' },
    }
);

use HTTP::Request::Common qw(GET POST);

sub run_request {
    my $request = shift;
    my $c       = HTTP::Request::AsCGI->new($request)->setup;
    $app->run;
    $c->restore;
    return $c->response;
}

my $get = run_request(GET 'http://localhost/');
cmp_ok($get->code, '==', 404, '404 on GET');

my $no_body = run_request(POST 'http://localhost/');
cmp_ok($no_body->code, '==', 404, '404 with empty body');

my $no_payload_root = run_request(POST 'http://localhost/' => [ bar => 'BAR' ]);
cmp_ok($no_payload_root->code, '==', 404, '404 with no payload param');

my $no_payload = run_request(POST 'http://localhost/hello' => [ bar => 'BAR' ]);
cmp_ok($no_payload->code, '==', 404, '404 with no payload param to app path');

my $payload = run_request(POST 'http://localhost/hello', Content => [ 'payload' => 'FOO' ] );
#cmp_ok($payload->code, '==', 200, '200 with payload param');

is($payload ->content, 'OK', 'OK statement returned');

