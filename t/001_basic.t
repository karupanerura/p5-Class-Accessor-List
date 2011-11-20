#!perl -w
use strict;
use warnings;
use Test::More;
use t::Util;
use t::Mocks;

subtest 'Read only' => sub {
    my $obj = Mock::Class::Ro->new('hoge');
    read_ok 'hoge' => sub { $obj->hoge }, 'hoge';
    fail_ok 'hoge' => sub { $obj->hoge('Fuga!') };
    position_valid $obj => 0, 'hoge';
    read_ok 'fuga' => sub { $obj->fuga }, 'fuga';
    fail_ok 'fuga' => sub { $obj->fuga('Hoge!') };
    position_valid $obj => 2, 'fuga';
    done_testing;
};

subtest 'Read only and new' => sub {
    my $obj = Mock::Class::Ro::New->new(hoge => 'hoge', fuga => 'fuga');
    read_ok 'hoge' => sub { $obj->hoge }, 'hoge';
    fail_ok 'hoge' => sub { $obj->hoge('Fuga!') };
    position_valid $obj => 0, 'hoge';
    read_ok 'fuga' => sub { $obj->fuga }, 'fuga';
    fail_ok 'fuga' => sub { $obj->fuga('Hoge!') };
    position_valid $obj => 2, 'fuga';
    done_testing;
};

subtest 'Write only' => sub {
    my $obj = Mock::Class::Wo->new('hoge');
    fail_ok  'hoge' => sub { $obj->hoge };
    write_ok 'hoge' => sub { $obj->hoge('Fuga!') };
    position_valid $obj => 0, 'Fuga!';
    fail_ok  'fuga' => sub { $obj->fuga };
    write_ok 'fuga' => sub { $obj->fuga('Hoge!') };
    position_valid $obj => 2, 'Hoge!';
    done_testing;
};

subtest 'Write only and new' => sub {
    my $obj = Mock::Class::Wo::New->new(hoge => 'hoge', fuga => 'fuga');
    fail_ok  'hoge' => sub { $obj->hoge };
    write_ok 'hoge' => sub { $obj->hoge('Fuga!') };
    position_valid $obj => 0, 'Fuga!';
    fail_ok 'fuga' => sub { $obj->fuga };
    write_ok 'fuga' => sub { $obj->fuga('Hoge!') };
    position_valid $obj => 2, 'Hoge!';
    done_testing;
};

subtest 'Read and write ok' => sub {
    my $obj = Mock::Class::Rw->new('hoge');
    read_ok  'hoge' => sub { $obj->hoge }, 'hoge';
    write_ok 'hoge' => sub { $obj->hoge('Fuga!') };
    read_ok  'hoge' => sub { $obj->hoge }, 'Fuga!';
    position_valid $obj => 0, 'Fuga!';
    read_ok  'fuga' => sub { $obj->fuga }, 'fuga';
    write_ok 'fuga' => sub { $obj->fuga('Hoge!') };
    read_ok  'fuga' => sub { $obj->fuga }, 'Hoge!';
    position_valid $obj => 2, 'Hoge!';
    done_testing;
};

subtest 'Read and Write ok and new' => sub {
    my $obj = Mock::Class::Rw::New->new(hoge => 'hoge', fuga => 'fuga');
    read_ok  'hoge' => sub { $obj->hoge }, 'hoge';
    write_ok 'hoge' => sub { $obj->hoge('Fuga!') };
    read_ok  'hoge' => sub { $obj->hoge }, 'Fuga!';
    position_valid $obj => 0, 'Fuga!';
    read_ok  'fuga' => sub { $obj->fuga }, 'fuga';
    write_ok 'fuga' => sub { $obj->fuga('Hoge!') };
    read_ok  'fuga' => sub { $obj->fuga }, 'Hoge!';
    position_valid $obj => 2, 'Hoge!';
    done_testing;
};

subtest 'Mix ok' => sub {
    my $obj = Mock::Class::Mix->new('hoge');
    read_ok  'hoge' => sub { $obj->hoge }, 'hoge';
    fail_ok  'hoge' => sub { $obj->hoge('Fuga!') };
    position_valid $obj => 0, 'hoge';
    read_ok  'fuga' => sub { $obj->fuga }, 'fuga';
    write_ok 'fuga' => sub { $obj->fuga('Hoge!') };
    read_ok  'fuga' => sub { $obj->fuga }, 'Hoge!';
    position_valid $obj => 2, 'Hoge!';
    done_testing;
};

subtest 'Mix ok and new' => sub {
    my $obj = Mock::Class::Mix::New->new(hoge => 'hoge', fuga => 'fuga');
    read_ok  'hoge' => sub { $obj->hoge }, 'hoge';
    fail_ok  'hoge' => sub { $obj->hoge('Fuga!') };
    read_ok  'fuga' => sub { $obj->fuga }, 'fuga';
    write_ok 'fuga' => sub { $obj->fuga('Hoge!') };
    read_ok  'fuga' => sub { $obj->fuga }, 'Hoge!';
    position_valid $obj => 2, 'Hoge!';
    done_testing;
};

done_testing;
