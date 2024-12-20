#!/usr/bin/env perl -w


use strict;
require File::Rename;
require File::Rename::Options;
use Pod::Usage;

main() unless caller;

sub main {
    my $options = File::Rename::Options::GetOptions()
        or pod2usage;

    mod_version() if $options->{show_version};
    pod2usage( -verbose => 2 ) if $options->{show_manual};
    pod2usage( -exitval => 1 ) if $options->{show_help};

    @ARGV = map {glob} @ARGV if $^O =~ m{Win}msx;

    File::Rename::rename(\@ARGV, $options);
}

sub mod_version {
    print __FILE__;
    print ' using File::Rename version '.  $File::Rename::VERSION;
    print ', File::Rename::Options version '. $File::Rename::Options::VERSION
    	if (eval $File::Rename::Options::VERSION) < (eval $File::Rename::VERSION);
    print "\n\n";
    exit 0
}   

1;

__END__

=head1 NAME

rename - renames multiple files

=head1 SYNOPSIS

B<rename>
S<[ B<-h>|B<-m>|B<-V> ]>
S<[ B<-v> ]>
S<[ B<-0> ]>
S<[ B<-n> ]>
S<[ B<-f> ]>
S<[ B<-d> ]>
S<[ B<-e>|B<-E> I<perlexpr>]*|I<perlexpr>>
S<[ I<files> ]>

=head1 DESCRIPTION

C<rename>
renames the filenames supplied according to the rule specified as the
first argument.
The I<perlexpr> 
argument is a Perl expression which is expected to modify the C<$_>
string in Perl for at least some of the filenames specified.
If a given filename is not modified by the expression, it will not be
renamed.
If no filenames are given on the command line, filenames will be read
via standard input.

=head2 Examples (Larry Wall,  1992)

For example, to rename all files matching C<*.bak> to strip the extension,
you might say

	rename 's/\.bak$//' *.bak

To translate uppercase names to lower, you'd use

	rename 'y/A-Z/a-z/' *

=head2 More examples (2020)

You can also use rename to move files between directories, possibly at
the same time as making other changes (but see B<--filename>)

	rename 'y/A-Z/a-z/;s/^/my_new_dir\//' *.*

You can also write the statements separately (see B<-e>/B<-E>)

	rename -E 'y/A-Z/a-z/' -E 's/^/my_new_dir\//' *.*

=head1 OPTIONS

=over 8

=item B<-v>, B<--verbose>

Verbose: print names of files successfully renamed.

=item B<-0>, B<--null>

Use \0 as record separator when reading from STDIN.

=item B<-n>, B<--nono>

No action: print names of files to be renamed, but don't rename.

=item B<-f>, B<--force>

Over write: allow existing files to be over-written.

=item B<--path>, B<--fullpath>

Rename full path: including any directory component.  DEFAULT

=item B<-d>, B<--filename>, B<--nopath>, B<--nofullpath>

Do not rename directory: only rename filename component of path.

=item B<-h>, B<--help>

Help: print SYNOPSIS and OPTIONS.

=item B<-m>, B<--man>

Manual: print manual page.

=item B<-V>, B<--version>

Version: show version number.

=item B<-e>

Expression: code to act on files name.

May be repeated to build up code (like C<perl -e>).
If no B<-e>, the first argument is used as code.

=item B<-E>

Statement: code to act on files name, as B<-e> but terminated by ';'.

=back

=head1 ENVIRONMENT

No environment variables are used.

=head1 AUTHOR

Larry Wall

=head1 SEE ALSO

mv(1), perl(1)

=head1 DIAGNOSTICS

If you give an invalid Perl expression you'll get a syntax error.

=head1 BUGS

The original
C<rename>
did not check for the existence of target filenames,
so had to be used with care.

=cut

