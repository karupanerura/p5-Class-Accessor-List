use strict;
use warnings;

package t::Mocks;
package Mock::Class::Ro;
use Class::Accessor::List (
    ro => [+{ fuga => 2 }, qw/hoge undef_value no_value/],
);

sub new {
    my $class = shift;
    my $hoge = shift;

    bless [$hoge, undef, 'fuga'] => $class;
}

package Mock::Class::Ro::New;
use Class::Accessor::List (
    ro  => [+{ fuga => 2 }, qw/hoge undef_value no_value/],
    new => 1,
);

package Mock::Class::Wo;
use Class::Accessor::List (
    wo => [+{ fuga => 2 }, qw/hoge undef_value no_value/],
);

sub new {
    my $class = shift;
    my $hoge = shift;

    bless [$hoge, undef, 'fuga'] => $class;
}

package Mock::Class::Wo::New;
use Class::Accessor::List (
    wo  => [+{ fuga => 2 }, qw/hoge undef_value no_value/],
    new => 1,
);

package Mock::Class::Rw;
use Class::Accessor::List (
    rw => [+{ fuga => 2 }, qw/hoge undef_value no_value/],
);

sub new {
    my $class = shift;
    my $hoge = shift;

    bless [$hoge, undef, 'fuga'] => $class;
}

package Mock::Class::Rw::New;
use Class::Accessor::List (
    rw  => [+{ fuga => 2 }, qw/hoge undef_value no_value/],
    new => 1,
);
package Mock::Class::Mix;
use Class::Accessor::List (
    rw  => [+{ fuga => 2 }],
    ro  => [+{ hoge => 0 }, qw/undef_value/],
    wo  => [qw/no_value/],
);

sub new {
    my $class = shift;
    my $hoge = shift;

    bless [$hoge, undef, 'fuga'] => $class;
}

package Mock::Class::Mix::New;
use Class::Accessor::List (
    rw  => [+{ fuga => 2 }],
    ro  => [qw/hoge undef_value/],
    wo  => [qw/no_value/],
    new => 1,
);

1;
