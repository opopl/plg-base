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
# podgrep -- grep in pod sections only

# ------ pragmas
use strict;
use warnings;
use Getopt::Std  qw(getopts);

our $VERSION = '2.2.0';

# ------ define variables
my $chunk        = undef;	# chunk count
my $file         = undef;	# file name
my $inmatch      = undef;	# TRUE if inside match
my $inpod        = undef;	# TRUE if inside POD
my $only_header  = undef;	# copy of $opt_h
our $opt_f       = undef;	# output plain text, paged if -p
our $opt_h       = undef;	# output only POD headers
our $opt_i       = undef;	# case-insensitive pattern
our $opt_p       = undef;	# use $ENV{PAGER} to page output
my $orig_pattern = undef;	# original pattern to search for
my $pager        = undef;	# contents of $ENV{PAGER}
my $pattern      = undef;	# pattern to search for


getopts("fhpi") 
  || die "usage: $0 [-i] [-f] [-h] [-p] pattern [podfiles ...]";

$/ = '';
$only_header = $opt_h;
$orig_pattern = $pattern = shift;
$pattern  = '^=.*' . $pattern if $only_header;
$pattern .= '(?i)' if $opt_i;

if ($opt_p) {
    unless ($pager = $ENV{PAGER}) {
    	require Config;
        {
            no warnings qw(once);
    	    $pager = $Config::Config{"pager"} || "more";
        }
    } 
} 

if ($opt_f) {
    if ($opt_p) {
	open(STDOUT, "| pod2text | $pager '+/$orig_pattern'");
    } else {
	open(STDOUT, "| pod2text");
    } 

} 
elsif ($opt_p) {
    open(STDOUT, "| $pager '+/$orig_pattern'");
} 


($file, $chunk) = ('-', 0);

while (<>) {
    if ($inpod && /^=cut/) {
	$inmatch = $inpod = 0;
	next;
    } 

    if (! $inpod && /^=(?!cut)\w+/) {
	$inpod = 1;
    } 

    if ($inmatch && /^=\w+/) {
	$inmatch = 0;
    }

    if ($inpod && !$inmatch && /$pattern/o) {
	print "=head1 $ARGV chunk $.\n\n" 
	    unless $file eq $ARGV && $chunk+1 == $.;
	($file, $chunk) = ($ARGV, $.);
	print;
	$inmatch = 1 if $only_header;
	next;
    } 

    print if $inmatch;


} continue {

    if (eof) {
	$inmatch = $inpod = 0;
	($file, $chunk) = ('-', 0);
	close ARGV;
    }

} 

close STDOUT;

__END__

=head1 NAME

podgrep - grep in pod sections only

=head1 SYNOPSIS

podgrep [B<-i>] [B<-p>] [B<-f>] [B<-h>] I<pattern> [ I<files> ... ]

=head1 DESCRIPTION

This program searches each paragraph in a pod document and prints each
paragraph that matches the supplied pattern.  This pod may be mixed with
program code, such as in a module.

Options are:

=over 4

=item -i 

means case insensitive match

=item -p 

means page output though the user's pager.  The pager will be primed
with an argument to search for the string.  This highlights the result.

=item -f

means format output though the I<pod2text> program.

=item -h

means check for matches in pod C<=head> and C<=item> headers alone,
and to keep printing podagraphs until the next header is found.

=back


=head1 EXAMPLES

    $ podgrep mail `pmpath CGI`
    (prints out podagraphs from the CGI.pm manpage that mention mail)

    $ podgrep -i destructor `sitepods`
    (prints out podagraphs that mention destructors in the 
     site-installed pods)

    $ podgrep -i 'type.?glob' `stdpods`

    (prints out podagraphs that mention typeglob in the
     standard pods)

    $ podgrep -hpfi "lock" `faqpods`

    (prints out all podagraphs with "lock" in the headers
    case-insensitively, then formats these with pod2text, then
    shows them in the pager with matches high-lighted)

    $ podgrep -fh seek `podpath perlfunc`
    (prints out and formats podagraphs from the standard perlfunc manpage
    whose headers or items contain "seek".)

=head1 SEE ALSO

faqpods(1),
pfcat(1), 
pmpath(1),
pod2text(1), 
podpath(1),
sitepods(1),
stdpods(1),
and
tcgrep(1).

=head1 NOTE

For a pager, the author likes these environment settings (in the login
startup, of course):

    $ENV{PAGER} = "less";
    $ENV{LESS}  = "MQeicsnf";

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
