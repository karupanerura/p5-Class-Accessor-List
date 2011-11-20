package Class::Accessor::List;
use 5.008_001;
use strict;
use warnings;

use Carp ();
use Scalar::Util qw/reftype/;

our $VERSION = '0.01';

sub import {
    my $class = shift;
    my %opt   = (@_ == 1 and reftype($_[0]) eq 'HASH') ? %{ $_[0] } : @_;
    return unless %opt;

    my $caller = caller;
    $class->mk_accessor(%opt, import_to => $caller);
    if (exists $opt{new}) {
        $class->mk_new(import_to => $caller);
    }
}

my %exists;
my %counter;
sub mk_accessor {
    my $class = shift;
    my %opt   = (@_ == 1 and reftype($_[0]) eq 'HASH') ? %{ $_[0] } : @_;
    my $import_to = $opt{import_to} || caller;

    $exists{$import_to}  ||= [];
    $counter{$import_to} ||= 0;

    my @mk_accessor_args;
    foreach my $cond (grep { exists $opt{$_} } $class->accessor_cond) {
        if (reftype($opt{$cond}) eq 'ARRAY') {
            my @hash_arg = grep { ref($_) && reftype($_) eq 'HASH' } @{ $opt{$cond} };
            my @arg      = grep { not reftype($_)                  } @{ $opt{$cond} };

            {### absolute dispatch
                my %where;
                foreach my $arg (@hash_arg) {
                    foreach my $name (keys %$arg) {
                        my $position = $arg->{$name};

                        Carp::croak("Duplicate position '$position'.") if ($exists{$import_to}[$position]);
                        $exists{$import_to}[$position] = $name;
                        $where{$position} = $name;
                    }
                }
                unshift @mk_accessor_args => +{
                    cond      => $cond,
                    where     => \%where,
                    import_to => $import_to
                };
            }

            ### auto dispatch
            push @mk_accessor_args => +{
                cond      => $cond,
                where     => sub { ### lazy evaluation
                    my %where;

                    foreach my $name (@arg) {
                        my $position = $counter{$import_to}++;
                        while ($exists{$import_to}[$position]) {
                            $position = $counter{$import_to}++;
                        }
                        $exists{$import_to}[$position] = $name;
                        $where{$position} = $name;
                    }

                    return \%where;
                },
                import_to => $import_to,
            };
        }
        else {
            Carp::croak("option '$cond' is not valid. pass to ArrayRef or HashRef.");
        }
    }

    foreach my $args (@mk_accessor_args) {
        $args->{where} = $args->{where}->() if (reftype($args->{where}) eq 'CODE');
        $class->_mk_accessor(%$args);
    }
}

our %ACCESSOR_CODEREF = (
    rw => sub {
        my $position = shift;
        return sub {
            (@_ == 1) ? $_[0]->[$position] : ($_[0]->[$position] = $_[1]);
        }
    },
    ro => sub {
        my $position = shift;
        return sub {
            Carp::croak("This valiable is read only.") if (@_ == 2);
            $_[0]->[$position]
        }
    },
    wo => sub {
        my $position = shift;
        return sub {
            Carp::croak("This valiable is write only.") if (@_ == 1);
            $_[0]->[$position] = $_[1];
        }
    },
);
sub accessor_cond { keys %ACCESSOR_CODEREF }

sub _mk_accessor {
    my $class = shift;
    my %opt   = (@_ == 1 and reftype($_[0]) eq 'HASH') ? %{ $_[0] } : @_;

    my $import_to = $opt{import_to} || caller;
    my $cond      = $opt{cond};

    foreach my $position (keys %{ $opt{where} }) {
        my $coderef = $ACCESSOR_CODEREF{$cond}->($position);
        my $name    = $opt{where}{$position};

        {
            no strict 'refs';
            *{"${import_to}::${name}"} = $coderef;
        }
    }
}

our $NEW_METHOD_CODEREF = sub {
    my $import_to = shift;
    my @exists = @{ $exists{$import_to} };

    return sub {
        my $class = shift;
        my %opt   = (@_ == 1 and reftype($_[0]) eq 'HASH') ? %{ $_[0] } : @_;

        bless [ @opt{@exists} ] => $class;
    };
};

sub mk_new {
    my $class = shift;
    my %opt   = (@_ == 1 and reftype($_[0]) eq 'HASH') ? %{ $_[0] } : @_;

    my $import_to = $opt{import_to} || caller;
    my $coderef   = $NEW_METHOD_CODEREF->($import_to);

    {
        no strict 'refs';
        *{"${import_to}::new"} = $coderef;
    }
}

1;
__END__

=head1 NAME

Class::Accessor::List - Accessor for list blessed object.

=head1 VERSION

This document describes Class::Accessor::List version 0.01.

=head1 SYNOPSIS

    package MyClass;
    use Class::Accessor::List (
        rw  => [qw/hoge/, { hoge2 => 2, fuga => 1 }], # can set absolute position of list blessed object.
        ro  => [qw/foo/], # auto set position
        wo  => [qw/bar/],
        new => 1,
    );

    package main;

    my $obj = MyClass->new(
        hoge  => 'Hoge!!',
        hoge2 => 'Hoge2!',
        foo   => 'Fooooooo!!!',
    );

    print $obj->hoge; # This code print 'Hoge!!'
    print $obj->foo;  # This code print 'Hoge!!'
    $obj->hoge('Hoge?'); # rw valiable and wo variable have setter.
    print $obj->hoge;  # This code print 'Hoge?'
    print $obj->hoge2; # This code print 'Hoge2!'
    print $obj->[2];   # This code print 'Hoge2!' (hoge2's really position is 2.)

=head1 DESCRIPTION

Accessor for list blessed object.

=head1 INTERFACE

=head2 Functions

=head3 C<< hello() >>

# TODO

=head1 DEPENDENCIES

Perl 5.8.1 or later.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 SEE ALSO

L<perl>

=head1 AUTHOR

Kenta Sato E<lt>karupa@cpan.orgE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011, Kenta Sato. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
