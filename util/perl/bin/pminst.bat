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
# pminst -- find modules whose names match this pattern

# ------ pragmas
use strict;
use warnings;

our $VERSION = '2.2.0';

# ------ define variables
my $pattern = undef;	# module name pattern
our $startdir = undef;	# starting directory
my $tmpname  = undef;	# temp version of full module name

BEGIN { $^W = 1 }

use Getopt::Std qw(getopts);
use File::Find;

getopts('ls') || die "bad usage";

if (@ARGV == 0) {
    @ARGV = ('.');
} 

die "usage: $0 [-l] [-s] pattern\n" unless @ARGV == 1;

$pattern = shift();
$pattern =~ s,::,/,g;

no lib '.';

use vars qw($opt_l $opt_s %seen);

for $startdir (@INC) { 
    next if (!-d $startdir);

    find({ wanted => \&wanted, follow => 1 }, $startdir);
}

sub wanted {
    if (-d && /^[a-z]/) { 
	# this is so we don't go down site_perl etc too early
	$File::Find::prune = 1;
	return;
    }
    # Some expansions of @INC have subdirs of other @INC directories in them;
    # to wit:
    # /opt/perl/lib/site_perl/5.8.8
    # /opt/perl/lib/site_perl
    # This will result in output, when looking for module Foo:
    # Foo
    # 5.8.8:Foo
    # We add full module paths for found modules to %seen so
    # we can skip them the next time around.
    return unless ( /\.pm$/ and not exists $seen{$File::Find::name} );
    local $_ = $File::Find::name;
    ($tmpname = $_) =~ s{^\Q$startdir/}{};
    return unless $tmpname =~ /$pattern/o;

    if ($opt_l) { 
	s{^(\Q$startdir\E)/}{$1 } if $opt_s;
    } 
    else {
	s{^\Q$startdir/}{};  
	s/\.pm$//;
	s{/}{::}g;
	print "$startdir " if $opt_s;
    } 

    $seen{$File::Find::name}=1;
    print $_, "\n";
} 

__END__

=head1 NAME

pminst - find modules whose names match this pattern

=head1 SYNOPSIS

pminst [B<-s>] [B<-l>] [I<pattern>]

=head1 DESCRIPTION

Without arguments, show the names of all installed modules.  Given a
pattern, show all module names that match it.  The B<-l> flag will show
the full pathname.  The B<-s> flag will separate the base directory from
@INC from the module portion itself.


=head1 EXAMPLES

    $ pminst
    (lists all installed modules)

    $ pminst Carp
    CGI::Carp
    Carp

    $ pminst ^IO::
    IO::Socket::INET
    IO::Socket::UNIX
    IO::Select
    IO::Socket
    IO::Poll
    IO::Handle
    IO::Pipe
    IO::Seekable
    IO::Dir
    IO::File

    $ pminst '(?i)io'
    IO::Socket::INET
    IO::Socket::UNIX
    IO::Select
    IO::Socket
    IO::Poll
    IO::Handle
    IO::Pipe
    IO::Seekable
    IO::Dir
    IO::File
    IO
    Pod::Functions

  The -s flag provides output with the directory separated
  by a space:

    $ pminst -s | sort +1
    (lists all modules, sorted by name, but with where they 
     came from)

    $ oldperl -S pminst -s IO
    /usr/lib/perl5/i386-linux/5.00404 IO::File
    /usr/lib/perl5/i386-linux/5.00404 IO::Handle
    /usr/lib/perl5/i386-linux/5.00404 IO::Pipe
    /usr/lib/perl5/i386-linux/5.00404 IO::Seekable
    /usr/lib/perl5/i386-linux/5.00404 IO::Select
    /usr/lib/perl5/i386-linux/5.00404 IO::Socket
    /usr/lib/perl5/i386-linux/5.00404 IO
    /usr/lib/perl5/site_perl LWP::IO
    /usr/lib/perl5/site_perl LWP::TkIO
    /usr/lib/perl5/site_perl Tk::HTML::IO
    /usr/lib/perl5/site_perl Tk::IO
    /usr/lib/perl5/site_perl IO::Stringy
    /usr/lib/perl5/site_perl IO::Wrap
    /usr/lib/perl5/site_perl IO::ScalarArray
    /usr/lib/perl5/site_perl IO::Scalar
    /usr/lib/perl5/site_perl IO::Lines
    /usr/lib/perl5/site_perl IO::WrapTie
    /usr/lib/perl5/site_perl IO::AtomicFile

  The -l flag gives full paths:

    $ filsperl -S pminst -l Thread
    /usr/local/filsperl/lib/5.00554/i686-linux-thread/Thread/Queue.pm
    /usr/local/filsperl/lib/5.00554/i686-linux-thread/Thread/Semaphore.pm
    /usr/local/filsperl/lib/5.00554/i686-linux-thread/Thread/Signal.pm
    /usr/local/filsperl/lib/5.00554/i686-linux-thread/Thread/Specific.pm
    /usr/local/filsperl/lib/5.00554/i686-linux-thread/Thread.pm

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
