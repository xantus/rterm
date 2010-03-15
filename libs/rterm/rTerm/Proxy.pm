package rTerm::Proxy;

use strict;
use warnings;

use base 'Mojolicious::Controller';

sub foobar {
    my $self = shift;

    my $p = $self->req->params->to_hash;

    require Data::Dumper;

    warn Data::Dumper->Dump([ $p ]);

    $self->app->client->post( "http://127.0.0.1:8022/u", $p, sub {
    #$self->app->client->post( "http://127.0.0.1:8022/u", ( Connection => 'close' ), $self->req->params->clone, sub {
        my $s = shift;
        my $x = $s->res->headers->buffer;
        if ( !length( $x ) ) {
            warn Data::Dumper->Dump([ $s->res ]);
        }
        warn "post returned:".$x;
        $self->render_text( $x, type => 'text/xml' );
    })->process;

    return;
}

1;
