
use strict;
use warnings;

use Test::More;                      

BEGIN { 
    require_ok('Base::Arg');

    my @funcs = qw(
        dict_exe_cb
    );
    use_ok('Base::Arg',@funcs);
}

my $a = { 
    a => [( 'a' .. 'z' )]
};

done_testing();
