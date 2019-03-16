package Vim::Perl::Old;

use strict;
use warnings;

sub Old_VimVar {
    my ($var) = @_;

    return '' unless VimExists($var);

    my $res;
    my $vartype = VimVarType($var);

    for ($vartype) {
        /^(String|Number|Float)$/ && do {
            $res = VimEval($var);

            next;
        };
        /^List$/ && do {
            my $len = VimEval( 'len(' . $var . ')' );
            my $i   = 0;
            $res    = [];

            while ( $i < $len ) {
                my @v     = split( "\n", VimEval( $var . '[' . $i . ']' ) );
                my $first = shift @v;

                if (@v) {
                    push @$res,[ $first, @v ];
                }
                else {
                    push @$res,$first;
                }

                $i++;
            }

            next;
        };
###VimVar_Dictionary
        /^Dictionary$/ && do {
            $res = {};
		   	VimCmd( 'let keys = keys(' . $var . ')' );
			my @keys=VimVar('keys');

			#VimMsg(Dumper(\@keys));

            foreach my $k (@keys) {
                $res->{$k} = VimEval( $var . "['" . $k . "']" );
            }

            next;
        };
		last;
    }

    unless ( ref $res ) {
        $res;
    }
    elsif ( ref $res eq "ARRAY" ) {
        wantarray ? @$res : $res;
    }
    elsif ( ref $res eq "HASH" ) {
        wantarray ? %$res : $res;
    }

}


1;
 

