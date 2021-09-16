
package Base::Cmd;

use strict;
use warnings;

sub run_cmd {
    my ($self, $ref) = @_;

    $ref ||= {};
    my $cmd = $ref->{cmd} || $self->{cmd};
    my @cmds = split("," => $cmd);

    foreach my $c (@cmds) {
        next unless $c;
    
        my $sub = 'cmd_'.$cmd;
        if ($self->can($sub)) {
            $self->$sub;
        }else{
            warn "No command defined: " . $cmd . "\n";
            #exit 1;
        }

    }
    #exit 0;

    return $self;

}

1;
 

