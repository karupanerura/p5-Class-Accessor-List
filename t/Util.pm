package t::Util;
use strict;
use warnings;

use parent qw/Test::Builder::Module/;

our @EXPORT = qw/position_valid read_ok write_ok fail_ok/;

sub position_valid ($$$) { ## no critic
    my($obj, $position, $expected) = @_;
    my $tb = __PACKAGE__->builder;

    return $tb->ok($obj->[$position] eq $expected, "${obj}'s position[${position}] is ${expected}.");
}

sub read_ok ($&;$) { ## no critic
    my($name, $code, $expected) = @_;
    my $tb = __PACKAGE__->builder;

    my $got = do {
        local $@;
        my $got = eval { $code->() };
        $tb->ok(not($@), $@ ? "Error: $@" : "can read ${name}.");
        $got;
    };
    $tb->ok($got eq $expected, "Got ${expected}.") if ($expected);
}

sub write_ok ($&) { ## no critic
    my($name, $code) = @_;
    my $tb = __PACKAGE__->builder;

    do {
        local $@;
        eval { $code->() };
        $tb->ok(not($@), $@ ? "Error: $@" : "can write ${name}.");
    };
}

sub fail_ok ($&) { ## no critic
    my($name, $code) = @_;
    my $tb = __PACKAGE__->builder;

    do {
        local $@;
        eval { $code->() };
        $tb->ok($@, $@ ? "Throw ok: $@" : "Not fail '$name'.");
    };
}

1;
