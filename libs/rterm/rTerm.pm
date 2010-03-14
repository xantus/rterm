package rTerm;

use strict;
use warnings;

use base 'Mojolicious';

our $VERSION = '0.01';
our $config = {};

# This method will run for each request
sub process {
    my ( $self, $c ) = @_;

    $c->stash( config => $config );

    $self->dispatch( $c );
}

sub production_mode {
    shift->log->level( 'error' );
}

sub development_mode {
    shift->log->level( 'debug' );
}

# This method will run once at server start
sub startup {
    my $self = shift;

    $config = {};

    # merge config from plugins, and main one last
    foreach (
        $self->home.'/etc/rterm.conf',
        @Bootstrapper::configs
    ) {
        my $conf = $self->plugin( json_config => { file => $_ } );
        while( my ( $k, $v ) = each( %$conf ) ) {
            # merge 1st level
            if ( ref( $v ) eq 'ARRAY' ) {
                $config->{$k} = [] unless  $config->{$k};
                push( @{$config->{$k}}, @$v );
            } elsif ( ref( $v ) eq 'HASH' ) {
                $config->{$k} = {} unless $config->{$k};
                @{ $config->{$k} }{ keys %$v } = values %$v;
            } else {
                $config->{$k} = $v;
            }
        }
    }

    if ( $config->{mojo_plugins} ) {
        foreach( @{$config->{mojo_plugins}} ) {
            $self->plugin( $_, $config );
        }
    }

    require Data::Dumper;
    warn Data::Dumper->Dump([$config],['config']);

    # template helper <%= ext_path %>
    # TBD get this from a config file
    $self->renderer->add_helper(
        ext_version => sub { $config->{ext_version} }
    );

    if ( $config->{mojo_types} ) {
        while( my ( $k, $v ) = each %{$config->{mojo_types}} ) {
            $self->types->type( $k => $v );
        }
    }

#    $self->routes->route( '/login' )->via( 'get' )->to( 'auth#login' )->name( 'login' );

    return;
}

1;
