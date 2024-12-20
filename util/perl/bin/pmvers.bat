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
# pmvers -- print out a module's version, if findable

# ------ pragmas
use strict;
use warnings;

our $VERSION = '2.0.0';

# ------ define variables
my $errors  = 0;	# error count
my $module  = undef;	# module name
my $version = undef;	# module version string

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
    print "$module: " if @ARGV > 1;
    if (defined($version = $module->VERSION())) { 
	print "$version\n";
    } 
    else { 
	$errors++;
	if (@ARGV > 1) {
	    print "unknown version\n";
	} 
	else {
	    warn "$0: unknown version for module `$module'\n";
	} 
    }
} 

exit ($errors != 0);


__END__

=head1 NAME

pmvers - print out a module's version

=head1 DESCRIPTION

Given one or more module names, show the version number if present.
If more than one argument is given, the name of the module will also
be printed.  Not all modules define version numbers, however.

=head1 EXAMPLES

    $ pmvers CGI
    2.46

    $ pmvers IO::Socket Text::Parsewords
    IO::Socket: 1.25
    Text::ParseWords: 3.1

    $ oldperl -S pmvers CGI
    2.42

    $ filsperl -S pmvers CGI
    2.46

    $ pmvers Devel::Loaded
    pmvers: unknown version for module `Devel::Loaded'

=head1 SEE ALSO

pmdesc(1),
pmpath(1),
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
