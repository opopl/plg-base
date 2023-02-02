#
#===============================================================================
#
#         FILE: deep_hash_utils.t
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 02/02/2023 12:48:01 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Deep::Hash::Utils qw(deepvalue);
use Test::More;                    
use Data::Dumper qw(Dumper);

my $a = { 1 => 'one' };
my $b = { 1 => 'one', 0 => 0 };

is_deeply(deepvalue($a,1), 'one', 'deepvalue');
is_deeply(deepvalue($b,0), 0, 'deepvalue' );

done_testing();
