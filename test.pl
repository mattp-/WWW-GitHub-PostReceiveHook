#!/usr/bin/env perl

use v5.12;
use strict;
use warnings;

use WWW::GitHub::PostReceiveHook;

my $s = WWW::GitHub::PostReceiveHook->new(
    routes => {
        '/hello'   => sub { say 'hello' },
        '/goodbye' => sub { say 'goodbye' },
    }
);

use Data::Dump;
dd $s;
