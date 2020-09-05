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
# pmpath -- show path to a perl module

# ------ pragmas
use strict;
use warnings;

our $VERSION = '2.0.0';

# ------ define variables
my $errors    = 0;	# error count
my $fullpath  = undef;	# full path
my $module    = undef;	# module name
my $shortpath = undef;	# short path

BEGIN { $^W = 1 }

$errors = 0;

for $module (@ARGV) {
    eval "local \$^W = 0; require $module";
    if ($@) {
	$@ =~ s/at \(eval.*$//;
	warn "$0: $@";
	$errors++;
	next;
    } 
    for ($shortpath = $module) {
	s{::}{/}g;
	s/$/.pm/;
    }
    # print "$module is in " if @ARGV > 1;
    if (defined($fullpath = $INC{$shortpath})) { 
	print "$fullpath\n";
    } 
    else { 
	$errors++;
	warn "$0: path unavailable in %INC\n";
    }
} 

exit ($errors != 0);

__END__

=head1 NAME

pmpath - show full path to a perl module

=head1 SYNOPSIS

pmpath module ...

=head1 DESCRIPTION

For each module name given as an argument, produces its full path on
the standard output, one per line.

=head1 EXAMPLES

    $ pmpath CGI
    /usr/local/devperl/lib/5.00554/CGI.pm

    $ filsperl -S pmpath IO::Socket CGI::Carp
    /usr/local/filsperl/lib/5.00554/i686-linux-thread/IO/Socket.pm
    /usr/local/filsperl/lib/5.00554/CGI/Carp.pm

    $ oldperl -S pmpath CGI CGI::Imagemap
    /usr/lib/perl5/CGI.pm
    /usr/lib/perl5/site_perl/CGI/Imagemap.pm

=head1 SEE ALSO

pmdesc(1),
pmvers(1),
pmcat(1).

=head1 AUTHORS and COPYRIGHTS

Copyright (C) 1999 Tom Christiansen.

Copyright (C) 2006-2014 Mark Leighton Fisher.

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
