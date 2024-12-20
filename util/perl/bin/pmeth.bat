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
# pmeth -- show a class's methods

# ------ pragmas
use strict;
use warnings;

our $VERSION = '2.0.0';

# ------ define variables
my $ancestor = undef;	# ancestor
my $errors   = 0;	# error count
my %got_def  = ();	# got definition already
my $name     = undef;	# symbol name

BEGIN { $^W = 1 }
BEGIN { die "usage: $0 module\n" unless @ARGV == 1 }

$errors = 0;

%got_def = ();

show_methods($ARGV[0]);
show_methods("UNIVERSAL", $ARGV[0]);

sub show_methods {
    my $module = shift;
    my @indirect = @_;
    my @baseclasses = @indirect[ 0 .. ($#indirect-1) ];
    eval "local \$^W = 0; require $module";
    if ($@) {
	$@ =~ s/at \(eval.*$//;
	warn "$0: $@";
	$errors++;
	return;
    } 
no strict 'refs';
    foreach $name ( sort keys %{ $module . "::" } ) { 
use strict 'refs';
	print '[constant] ' if declared($module . "::" . $name);

	if (defined &{ $module . "::" . $name } ) {
	    print "[overridden] " if $got_def{$name}++;
	    if (@indirect) { 
		print join(" via ", $name, $module, @baseclasses), "\n";
	    } else {
		print "$name\n";
	    }
	} 
    }
    if (my @parents = @{ $module . "::ISA" } ) {
	foreach $ancestor (@parents) { 
	    show_methods($ancestor, $module, @indirect);
	}
    }
} 

sub declared ($) {
    use constant 1.01;              # don't omit this!
    my $name = shift;
    $name =~ s/^::/main::/;
    my $pkg = caller;
    my $full_name = $name =~ /::/ ? $name : "${pkg}::$name";
    $constant::declared{$full_name};
}

exit ($errors != 0);

__END__

=head1 NAME

pmeth - show a Perl class's methods

=head1 DESCRIPTION

Given a class name, print out all methods available to that class.
It does this by loading in the class module, and walking its
symbol table and those of its ancestor classes.  A regular method
call shows up simply:

    $ pmeth IO::Socket | grep '^con'
    confess
    configure
    connect
    connected

But one that came from else where is noted with one or
more "via" notations:

    DESTROY via IO::Handle
    export via Exporter via IO::Handle

A base-class method that is unavailable due to being hidden by a close
derived-class method by the same name (but accessible via SUPER::)
is indicated by a leading "[overridden]" before it:

    [overridden] new via IO::Handle

Constants declared via L<constant> have a leading "[constant]" added
to the output, but XS C<define>'s are not yet so flagged.

=head1 EXAMPLES

    $ pmeth IO::Socket
    AF_INET
    AF_UNIX
    INADDR_ANY
    INADDR_BROADCAST
    INADDR_LOOPBACK
    INADDR_NONE
    SOCK_DGRAM
    SOCK_RAW
    SOCK_STREAM
    accept
    bind
    carp
    confess
    configure
    connect
    connected
    croak
    getsockopt
    import
    inet_aton
    inet_ntoa
    listen
    new
    pack_sockaddr_in
    pack_sockaddr_un
    peername
    protocol
    recv
    register_domain
    send
    setsockopt
    shutdown
    sockaddr_in
    sockaddr_un
    sockdomain
    socket
    socketpair
    sockname
    sockopt
    socktype
    timeout
    unpack_sockaddr_in
    unpack_sockaddr_un
    DESTROY via IO::Handle
    SEEK_CUR via IO::Handle
    SEEK_END via IO::Handle
    SEEK_SET via IO::Handle
    _IOFBF via IO::Handle
    _IOLBF via IO::Handle
    _IONBF via IO::Handle
    _open_mode_string via IO::Handle
    autoflush via IO::Handle
    blocking via IO::Handle
    [overridden] carp via IO::Handle
    clearerr via IO::Handle
    close via IO::Handle
    [overridden] confess via IO::Handle
    constant via IO::Handle
    [overridden] croak via IO::Handle
    eof via IO::Handle
    error via IO::Handle
    fcntl via IO::Handle
    fdopen via IO::Handle
    fileno via IO::Handle
    flush via IO::Handle
    format_formfeed via IO::Handle
    format_line_break_characters via IO::Handle
    format_lines_left via IO::Handle
    format_lines_per_page via IO::Handle
    format_name via IO::Handle
    format_page_number via IO::Handle
    format_top_name via IO::Handle
    format_write via IO::Handle
    formline via IO::Handle
    gensym via IO::Handle
    getc via IO::Handle
    getline via IO::Handle
    getlines via IO::Handle
    gets via IO::Handle
    input_line_number via IO::Handle
    input_record_separator via IO::Handle
    ioctl via IO::Handle
    [overridden] new via IO::Handle
    new_from_fd via IO::Handle
    opened via IO::Handle
    output_field_separator via IO::Handle
    output_record_separator via IO::Handle
    print via IO::Handle
    printf via IO::Handle
    printflush via IO::Handle
    qualify via IO::Handle
    qualify_to_ref via IO::Handle
    read via IO::Handle
    setbuf via IO::Handle
    setvbuf via IO::Handle
    stat via IO::Handle
    sync via IO::Handle
    sysread via IO::Handle
    syswrite via IO::Handle
    truncate via IO::Handle
    ungensym via IO::Handle
    ungetc via IO::Handle
    untaint via IO::Handle
    write via IO::Handle
    _push_tags via Exporter via IO::Handle
    export via Exporter via IO::Handle
    export_fail via Exporter via IO::Handle
    export_ok_tags via Exporter via IO::Handle
    export_tags via Exporter via IO::Handle
    export_to_level via Exporter via IO::Handle
    [overridden] import via Exporter via IO::Handle
    require_version via Exporter via IO::Handle
    VERSION via UNIVERSAL
    can via UNIVERSAL
    [overridden] import via UNIVERSAL
    isa via UNIVERSAL

=head1 NOTE

Perl makes no distinction between functions, procedures, and methods,
nor whether they are public or nominally private, nor whether a method
is nominally a class method, an object method, or both.  They all show up
as subs in the package namespace.  So if your class says C<use Carp>, you
just polluted your namespace with things like croak() and confess(), which
will appear to be available as method calls on objects of your class.

=head1 SEE ALSO

perltoot(1), perlobj(1)

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
