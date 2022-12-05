
use strict;
use warnings;

use Test::More;                      

BEGIN { 
    require_ok('Base::Arg');

    my @funcs = qw(
        dict_exe_cb
        varexp
    );
    use_ok('Base::Arg',@funcs);
}

my $vars = {
    sec => '22_10_2022'
};

my $a = { 
    a => [( 'a' .. 'z' )],
    b => [ '$var{sec}' ]
};

dict_exe_cb($a, { 
    cb => sub { },
    cb_list => sub { varexp(shift, $vars) },
});

#is_deeply()

done_testing();
