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
# pmexp -- show a module's exports

# ------ pragmas
use strict;
use warnings;

our $VERSION = '2.0.0';

# ------ define variables
my $errors   = 0;	# error count
my @list     = ();	# list of module exports
my $module   = undef;	# module name
my %table    = ();	# module export tags
my $tag      = undef;	# module export tag

BEGIN { $^W = 1 }
BEGIN { die "usage: $0 module ...\n" unless @ARGV }

$errors = 0;

for $module (@ARGV) { 
    eval "local \$^W = 0; require $module";
    if ($@) {
        $@ =~ s/at \(eval.*$//;
        warn "$0: $@";
        $errors++;
        next;
    } 

no strict 'refs';
    if (@list = @{ $module . "::EXPORT" } ) { 
use strict 'refs';
	print "$module automatically exports ",
	    commify_series(@list), "\n";
    }
    if (@list = @{ $module . "::EXPORT_OK" } ) { 
	print "$module optionally exports ",
	    commify_series(@list), "\n";
    }
    if (%table = %{ $module . "::EXPORT_TAGS" } ) { 
	for $tag (sort keys %table) {
	    print "$module export tag '$tag' includes ", commify_series(@{$table{$tag}}), "\n";
	} 
    }
}

exit($errors != 0);


sub commify_series {
    (@_ == 0) ? ''                                      :
    (@_ == 1) ? $_[0]                                   :
    (@_ == 2) ? join(" and ", @_)                       :
		join(", ", @_[0 .. ($#_-1)], "and $_[-1]");
}

__END__

=head1 NAME

pmexp - show a module's exports

=head1 DESCRIPTION

Given a module name, this program identifies which symbols are
automatically exported (in that package's @EXPORT), those which are
optionally exported (in that package's @EXPORT_OK), and also lists out
the import groups (in that package's %EXPORT_TAGS hash).

=head1 EXAMPLES

    $ pmexp Text::ParseWords
    Text::ParseWords automatically exports shellwords, quotewords, nested_quotewords, and parse_line
    Text::ParseWords optionally exports old_shellwords

    $ pmexp Text::Wrap
    Text::Wrap automatically exports wrap and fill
    Text::Wrap optionally exports $columns, $break, and $huge

    $ pmexp Fcntl
    Fcntl automatically exports FD_CLOEXEC, F_DUPFD, F_EXLCK, F_GETFD, F_GETFL, F_GETLK, F_GETLK64, F_GETOWN, F_POSIX, F_RDLCK, F_SETFD, F_SETFL, F_SETLK, F_SETLK64, F_SETLKW, F_SETLKW64, F_SETOWN, F_SHLCK, F_UNLCK, F_WRLCK, O_ACCMODE, O_APPEND, O_ASYNC, O_BINARY, O_CREAT, O_DEFER, O_DSYNC, O_EXCL, O_EXLOCK, O_LARGEFILE, O_NDELAY, O_NOCTTY, O_NONBLOCK, O_RDONLY, O_RDWR, O_RSYNC, O_SHLOCK, O_SYNC, O_TEXT, O_TRUNC, and O_WRONLY

    Fcntl optionally exports FAPPEND, FASYNC, FCREAT, FDEFER, FEXCL, FNDELAY, FNONBLOCK, FSYNC, FTRUNC, LOCK_EX, LOCK_NB, LOCK_SH, and LOCK_UN
    Fcntl export tag 'Fcompat' includes FAPPEND, FASYNC, FCREAT, FDEFER, FEXCL, FNDELAY, FNONBLOCK, FSYNC, and FTRUNC
    Fcntl export tag 'flock' includes LOCK_SH, LOCK_EX, LOCK_NB, and LOCK_UN

=head1 BUGS

The output formatting should be nicer, perhaps using
C<format> and C<write>.

=head1 SEE ALSO

pmeth(1), perlmod(1), Exporter(3).

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
