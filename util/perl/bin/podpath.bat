@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
perl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
perl -x -S %0 %*
if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
if %errorlevel% == 9009 echo You do not have Perl in your PATH.
if errorlevel 1 goto script_failed_so_exit_with_non_zero_val 2>nul
goto endofperl
@rem ';
#!/usr/bin/env perl
#line 15
# podpath - print the path to the Pod

# ------ pragmas
use strict;
use warnings;
use pmtools;

our $VERSION = '2.2.0';

for my $module (@ARGV) {
    if ( $module =~ /^perl/ ) {
	     system("$^X -S stdpods | grep $module");
    } else {
	    $module =~ s#::#/#gmsx;
        my $found = 0;
        my $pod_iter = pmtools::new_pod_iterator($module);
        while (my $pod_file = $pod_iter->()) {
            next if !-s $pod_file;

            # in case we find the .pm before the .pod
            my $output = `grep '=head1' $pod_file`;
            if ($? == 0) {
                print "$pod_file\n";
                $found++;
                last;
            }
        }

        if (!$found) {
            print STDERR "$0: Can't locate $module.pm or $module.pod "
            . "in \@INC (\@INC contains: " . join(' ', @INC) . ")\n";
        }
    } 
} 

__END__

=head1 NAME

podpath - print the path to the Pod

=head1 DESCRIPTION

podpath prints the path to the Pod. podpath calls stdpods underneath
if the Pod name includes 'perl'. Otherwise, it searches down
@INC, printing the '.pod' filename if there is a separate Pod
file, otherwise printing the 'pm' filename. This accommodates
systems where the Pod lives in a separate file from the module file.

=head1 EXAMPLES

    $ podpath Cwd
    /usr/local/devperl/lib/5.00554/Cwd.pm

It works with alternate installations, too:

    $ devperl -S podpath perlfunc
    /usr/local/devperl/lib/5.00554/pod/perlfunc.pod

    $ oldperl -S podpath IO::Handle
    /usr/lib/perl5/i386-linux/5.00404/IO/Handle.pm

    $ filsperl -S podpath Thread
    /usr/local/filsperl/lib/5.00554/i686-linux-thread/Thread.pm

=head1 SEE ALSO

stdpods(1),
pmpath(1),
perlmodlib(1).

=head1 AUTHORS and COPYRIGHTS

Copyright (C) 1999 Tom Christiansen.

Copyright (C) 2006-2014, 2018 Mark Leighton Fisher.

=head1 LICENSE

This is free software; you can redistribute it and/or modify it
under the terms of either:
(a) the GNU General Public License as published by the Free
Software Foundation; either version 1, or (at your option) any
later version, or
(b) the Perl "Artistic License".
(This is the Perl 5 licensing scheme.)

Please note this is a change from the
original pmtools-1.00 (still available on CPAN),
as pmtools-1.00 were licensed only under the
Perl "Artistic License".

__END__
:endofperl
