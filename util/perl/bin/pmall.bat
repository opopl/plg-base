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
# pmall -- show all installed versions and descs

use strict;
use warnings;
use File::Find	qw(find);
use Getopt::Std	qw(getopts);
use Carp;

use vars (
    q!$opt_v!,		# give debug info
    q!$opt_w!,		# warn about missing descs on modules
    q!$opt_a!,		# include relative paths
    q!$opt_s!,		# sort output within each directory
);

our $VERSION = '2.0.0';

$| = 1;

getopts('wvas') || die "bad usage";

@ARGV = @INC unless @ARGV;


# Globals.  wish I didn't really have to do this.
use vars (
    q!$Start_Dir!,	# The top directory find was called with
    q!%Future!,		# topdirs find will handle later
);

my $Module;

if ($opt_s) {
    if (open(ME, "-|")) {
	$/ = '';
	while (<ME>) {
	    chomp;
	    print join("\n", sort split /\n/), "\n";
	} 
	exit;
    } 
} 

MAIN: { 
    my %visited;
    my ($dev,$ino);

    @Future{@ARGV} = (1) x @ARGV;

    foreach $Start_Dir (@ARGV) { 
	delete $Future{$Start_Dir};

	print "\n<<Modules from $Start_Dir>>\n\n"
	    if $opt_v;

	next unless ($dev,$ino) = stat($Start_Dir);
	next if $visited{$dev,$ino}++;
	next unless $opt_a || $Start_Dir =~ m!^/!;

	find(\&wanted, $Start_Dir);
    } 
    exit;
}

sub modname { 
    local $_ = $File::Find::name;

    if (index($_, $Start_Dir . '/') == 0) {
	substr($_, 0, 1+length($Start_Dir)) = '';
    } 

    s { /              }	{::}gx;
    s { \.p(m|od)$     }	{}x;

    return $_;
}

sub wanted { 
    if ( $Future{$File::Find::name} ) { 
	warn "\t(Skipping $File::Find::name, qui venit in futuro.)\n"
	    if 0 and $opt_v;
	$File::Find::prune = 1;
	return;
    } 
    return unless /\.pm$/ && -f;
    $Module = &modname;

    my    $file = $_;

    unless (open(POD, "< $file")) {
	warn "\tcannot open $file: $!";
	    # if $opt_w;
	return 0;
    } 

    $: = " -:";

    local $/ = '';
    local $_;
    while (<POD>) {
	if (/=head\d\s+NAME/) {
	    chomp($_ = <POD>);
	    s/^.*?-\s+//s; 
	    s/\n/ /g;
	    #write;
	    my $v;
	    if (defined ($v = getversion($Module))) {
		print "$Module ($v) ";
	    } else {
		print "$Module ";
	    }
	    print "- $_\n";
	    return 1;
	} 
    } 

    warn "\t(MISSING DESC FOR $File::Find::name)\n" 
	if $opt_w;

    return 0;
} 

sub getversion {
    my $mod = shift;
    my $vers = `$^X -m$mod -e 'print \$${mod}::VERSION' 2>&1`;
    #my $vers = `$^X -m$mod -e 'print \$${mod}::VERSION' 2>/dev/null`;
    # 2> due to errors from MM_Unix etc
    $vers =~ s/^\s*(.*?)\s*$/$1/; # why is there whitespace here??
    return ($vers || undef);
}

sub getversion_internal {
    # This should really use system(), because otherwise we bloat.
    my $mod = shift;
    local $SIG{__WARN__} = sub {};
    eval "local \$^W = 0; require $mod";
    if ($@) {
	warn "Cannot require $mod -- $@\n"
	    if $opt_v;
	return;
    } 
    my $vers;
    {
	no strict 'refs';
	return unless defined ($vers = ${ $mod . "::VERSION" });
    }
    $vers =~ s/^\s*(.*?)\s*$/$1/; # why is there whitespace here??
    return $vers;
} 


format  =
^<<<<<<<<<<<<<<<<<~~^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$Module,	$_
.

__END__

=head1 NAME

pmall - show all installed versions and descs

=head1 SYNOPSIS

    pmall [-d] [-w] [-a] [-s]

pmall - show all installed versions and descs

=head1 DESCRIPTION

This program runs through all your installed modules
and tells you what they're for and what version 
number they are at.  

The following options are honored:

=over 4

=item -v

give debug info

=item -w

warn about missing descriptions on modules

=item -a

include relative paths

=item -s

sort output within each directory

=back

=head1 HISTORICAL NOTE

This program used to be called I<pmdesc> and is included in I<The Perl
Cookbook> under that name.  However, that name has been usurped by 
a simpler program.

For example, to find the versions of what is in your site-specific
directory, the simpler I<pmdesc> might be preferred:

    $ pmdesc `pminst -s | perl -lane 'print $F[1] if $F[0] =~ /site/'`
    XML::Parser::Expat (2.19) - Lowlevel access to James Clark's expat XML parser
    XML::Parser (2.19) - A perl module for parsing XML documents

=head1 KNOWN BUGS

This program takes a long time to run.

Some modules don't work right (CPAN.pm, ExtUtils) because of noisy things
they do at compile time or poor formatting of the pod.

=head1 SEE ALSO

pmdesc(1)
pmvers(1)

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
