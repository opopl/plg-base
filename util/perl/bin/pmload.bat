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
# pmload -- show what files a module loads

# ------ pragmas
use strict;
use warnings;

our $VERSION = '2.0.0';

# ------ define variables
my $module = undef;	# module name
my %seen = ();		# list of files we've seen before

BEGIN { $^W = 1 }

die "usage: $0 module\n" unless @ARGV == 1;

%seen = %INC;

$module = shift;
eval "local \$^W = 0; require $module";

if ($@) {
    $@ =~ s/at \(eval.*$//;
    die "$0: $@";
} 

for my $path (values %INC) {
    print "$path\n" unless $seen{$path};
} 

__END__

=head1 NAME

pmload - show what files a given module loads at compile time

=head1 DESCRIPTION

Given an argument of a module name, show all the files 
that are loaded directly or indirectly when the module
is used at compile-time.

=head1 EXAMPLES

    $ pmload IO::Handle
    /usr/local/devperl/lib/5.00554/Exporter.pm
    /usr/local/devperl/lib/5.00554/Carp.pm
    /usr/local/devperl/lib/5.00554/strict.pm
    /usr/local/devperl/lib/5.00554/vars.pm
    /usr/local/devperl/lib/5.00554/i686-linux/DynaLoader.pm
    /usr/local/devperl/lib/5.00554/i686-linux/IO/Handle.pm
    /usr/local/devperl/lib/5.00554/Symbol.pm
    /usr/local/devperl/lib/5.00554/i686-linux/IO/File.pm
    /usr/local/devperl/lib/5.00554/SelectSaver.pm
    /usr/local/devperl/lib/5.00554/i686-linux/Fcntl.pm
    /usr/local/devperl/lib/5.00554/AutoLoader.pm
    /usr/local/devperl/lib/5.00554/i686-linux/IO.pm
    /usr/local/devperl/lib/5.00554/i686-linux/IO/Seekable.pm

    $ cat `pmload IO::Socket` | wc -l
       4015

    $ oldperl -S pmload Tk
    /usr/lib/perl5/site_perl/Tk/Pretty.pm
    /usr/lib/perl5/Symbol.pm
    /usr/lib/perl5/site_perl/Tk/Frame.pm
    /usr/lib/perl5/site_perl/Tk/Toplevel.pm
    /usr/lib/perl5/strict.pm
    /usr/lib/perl5/Exporter.pm
    /usr/lib/perl5/vars.pm
    /usr/lib/perl5/site_perl/auto/Tk/Wm/autosplit.ix
    /usr/lib/perl5/site_perl/auto/Tk/Widget/autosplit.ix
    /usr/lib/perl5/site_perl/Tk.pm
    /usr/lib/perl5/i386-linux/5.00404/DynaLoader.pm
    /usr/lib/perl5/site_perl/auto/Tk/Frame/autosplit.ix
    /usr/lib/perl5/site_perl/auto/Tk/Toplevel/autosplit.ix
    /usr/lib/perl5/Carp.pm
    /usr/lib/perl5/site_perl/auto/Tk/autosplit.ix
    /usr/lib/perl5/site_perl/Tk/CmdLine.pm
    /usr/lib/perl5/site_perl/Tk/MainWindow.pm
    /usr/lib/perl5/site_perl/Tk/Submethods.pm
    /usr/lib/perl5/site_perl/Tk/Configure.pm
    /usr/lib/perl5/AutoLoader.pm
    /usr/lib/perl5/site_perl/Tk/Derived.pm
    /usr/lib/perl5/site_perl/Tk/Image.pm
    /usr/lib/perl5/site_perl/Tk/Wm.pm
    /usr/lib/perl5/site_perl/Tk/Widget.pm

=head1 NOTE

If the programmers used a delayed C<require>, those files won't show up.
Furthermore, this doesn't show all possible files that get opened,
just those that those up in %INC.  Most systems have a way to trace
system calls.  You can use this to find the real answer.  First, get a
baseline with no modules loaded.

    $ strace perl -e 1 2>&1 | perl -nle '/^open\("(.*?)".* = [^-]/ && print $1'
    /etc/ld.so.cache
    /lib/libnsl.so.1
    /lib/libdb.so.2
    /lib/libdl.so.2
    /lib/libm.so.6
    /lib/libc.so.6
    /lib/libcrypt.so.1
    /dev/null

    $ strace perl -e 1 2>&1 | grep -c '^open.*= [^-]'
    8

Now add module loads and see what you get:

    $ strace perl -MIO::Socket -e 1 2>&1 | grep -c '^open.*= [^-]'
    24

    $ strace perl -MTk -e 1 2>&1 | grep -c '^open.*= [^-]'
    35

=head1 SEE ALSO

Devel::Loaded, plxload(1).

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
