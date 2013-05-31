# NAME

WWW::GitHub::PostReceiveHook - A simple means of receiving GitHub's web hooks

# SYNOPSIS

Create the listener:

    use WWW::GitHub::PostReceiveHook;

    WWW::GitHub::PostReceiveHook->new(
        routes => {
            '/myProject' => sub { my $payload = shift; },
            '/myOtherProject' => sub { run3 \@cmd ... }
        }
    )->run_if_script;

Save it. Toss it in /cgi-bin or mount it as a psgi app. Add http://your.host/myProject to github.com/myname/myproject/admin/hooks.

# DESCRIPTION

WWW::GitHub::PostReceiveHook is a CGI / PSGI wrapper for GitHub that tries to be simple like a local git hook.

# METHODS

## new

Argument: routes => HashRef\[CodeRef\]

Sets up [Web::Simple](http://search.cpan.org/perldoc?Web::Simple) to listen on each route. If a GitHub payload is POST'd to a given path, it will be deserialized and passed to that paths callback.

# QUESTIONS

## Why WWW::GitHub::PostReceiveHook?

Sometimes you just want to kick off an email, or run a small script when someone commits to github. In situations like these, busting out a full-sized framework like Dancer/Catalyst is almost always overkill to listen for GitHub's postreceive hooks. Use this module and you can be off to the races after a quick copy-paste.

## Can't I do this just as easily using Web::Simple?

Yes! But most people searching cpan for 'github postreceive' probably haven't heard of Web::Simple.

# SEE ALSO

[http://help.github.com/post-receive-hooks/](http://help.github.com/post-receive-hooks/) for details on what gets POST'd by GitHub

WWW::GitHub::PostReceiveHook uses [Web::Simple](http://search.cpan.org/perldoc?Web::Simple) to do the heaving lifting, so that would be a good start.

[Dancer](http://search.cpan.org/perldoc?Dancer), [Catalyst](http://search.cpan.org/perldoc?Catalyst), [CGI](http://search.cpan.org/perldoc?CGI)

# AUTHOR

Matt Phillips <mattp@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Matt Phillips.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
