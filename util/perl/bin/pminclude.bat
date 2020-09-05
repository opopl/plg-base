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
# pminclude -- show the include path for modules (@INC)

use strict;
use warnings;

our $VERSION = '2.0.0';

BEGIN { $^W = 1 }

for my $inc (@INC) {
    print "$inc\n";
} 

__END__

=head1 NAME

pminclude - show the include path for modules (@INC)

=head1 DESCRIPTION

This is mostly here for people too lazy to type:

    $ perl -V | tail

=head1 EXAMPLES

    $ pminclude
    /etc/perl
    /usr/local/lib/perl/5.14.2
    /usr/local/share/perl/5.14.2
    /usr/lib/perl5
    /usr/share/perl5
    /usr/lib/perl/5.14
    /usr/share/perl/5.14
    /usr/local/lib/site_perl


=head1 SEE ALSO

pmls(1), pmpath(1)

=head1 AUTHORS and COPYRIGHTS

Copyright (C) 2013-2014 Mark Leighton Fisher.

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
