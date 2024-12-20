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
# pmfunc -- show a function 

# ------ pragmas
use strict;
use warnings;

our $VERSION = '2.0';

# ------ define variables
my $errors   = 0;        # error count
my $file     = undef;        # module file path
my $function = undef;        # function name
my $module   = undef;        # module name
my $ok       = undef;        # OK count

BEGIN { $^W = 1 }
BEGIN { die "usage: $0 module ...\n" unless @ARGV }

use FindBin qw($Bin);

$errors = 0;

for my $arg (@ARGV) { 
    ($module, $function) = $arg =~ /(\w.*)::(\w+)$/;
    if (!defined($module)) {
        print STDERR "Sorry, '$arg' is not the name of a function in a module.\n";
        next;
    }

    $file = `$^X -S $Bin/pmpath $module`;
    if ($?) {
        $errors++;
        next;
    } 
    chomp $file;

    my $found = 0;
    my $ifh;
    my $in_function = 0;
    open $ifh, '<', $file or die "cannot open '$file': $!\n";
    while (my $line = <$ifh>) {
        $in_function = 1 if ($line =~ m/^sub\s+$function\W/msx);
        next if !$in_function;

        $found = 1;
        print $line;

        $in_function = 0 if $line =~ m/^}\s*$/msx;
    }
    close $ifh;
    print STDERR "cannot find '$module::$function'\n" if !$found;

    $errors++ if $? || !$found;
}

exit ($errors != 0);

__END__

=head1 NAME

pmfunc - cat out a function from a module

=head1 DESCRIPTION

Given a fully-qualified function, this program opens
up the file and attempts to display the source for 
that function.

=head1 EXAMPLES

    $ pmfunc Cwd::_perl_getcwd
    sub _perl_getcwd
    {
        abs_path('.');
    }

=head1 RESTRICTIONS

Only subroutines that are defined in the normal fashion are seen, since
a simple pattern-match is what does the extraction.  Those loaded other
ways, such as via AUTOLOAD, typeglob aliasing, or in an C<eval>, will
all necessarily be missed.

This is mostly here for people who are too lazy to type

    sed '/^sub getcwd/,/}/p' `pmpath Cwd`
or
    perl -ne 'print if /^sub\s+getcwd\b/ .. /}/' `pmpath Cwd`

=head1 RESTRICTIONS

=head1 SEE ALSO

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
