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
# pmdesc -- show NAME section

# ------ pragmas
use strict;
use warnings;
use FindBin qw($Bin);
use Getopt::Long;

our $VERSION = '2.1.0';

# ------ define variables
my $errors;     # error count
my $fullpath;   # full module path
my $module;     # module name
my $use_pod;    # use .pod instead of .pm file for systems with split POD/pm
my $vers;       # module version

BEGIN { $^W = 1 }

GetOptions ("splitpod"  => \$use_pod); 

$errors = 0;

MODULE: for $module (@ARGV) {
    if ($use_pod) {
        $fullpath = `$^X $Bin/podpath $module`;
    } else {
        $fullpath = `$^X $Bin/pmpath $module`;
    }
    if ($?) {
        $errors++;
        next;
    } 
    chomp $fullpath;
    unless (open(POD, "< $fullpath")) {
        warn "$0: cannot open $fullpath: $!";
        $errors++;
        next;
    } 

    local $/ = '';
    local $_;
    while (<POD>) {
        if (/=head\d\s+NAME/) {
            chomp($_ = <POD>);
            s/^.*?-\s+//s; 
            s/\n/ /g;
            #write;
            my $v;
            if (defined ($vers = getversion($module))) {
                print "$module ($vers) ";
            } else {
                print "$module ";
            }
            print "- $_\n";

            next MODULE;
        } 
    } 
    print "no description found\n";
    $errors++;
} 

sub getversion {
    my $module = shift;

    my $vers;
    if ( $^O eq "MSWin32" ) {
        $vers = `$^X -S $Bin/pmvers $module 2>NUL`;
    } else {
        $vers = `$^X -S $Bin/pmvers $module 2>/dev/null`;
    }
    return if $?;
    chomp $vers;
    return $vers;
} 

exit ($errors != 0);

__END__

=head1 NAME

pmdesc - print out version and whatis description of perl modules

=head1 DESCRIPTION

Given one or more module names, show the version number (if known)
and the 'whatis' line, that is, the NAME section's description,
typically used for generation of whatis databases.

=head1 EXAMPLES

    $ pmdesc IO::Socket
    IO::Socket (1.25) - Object interface to socket communications

    $ oldperl pmdesc IO::Socket
    IO::Socket (1.1603) - Object interface to socket communications

    $ pmdesc `pminst -s | perl -lane 'print $F[1] if $F[0] =~ /site/'`
    XML::Parser::Expat (2.19) - Lowlevel access to James Clark's expat XML parser
    XML::Parser (2.19) - A perl module for parsing XML documents

=head1 RESTRICTIONS

This only works on modules.  It should also work on filenames, but then
it's a bit tricky finding out the package to call the VERSION method on.

=head1 SEE ALSO

pmdesc(1)
pminst(1)
pmpath(1)
pmvers(1)

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
