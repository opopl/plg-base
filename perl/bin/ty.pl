#!/usr/bin/env perl 
#
package ty;

=head1 NAME

ty - wrapper for running L<Base::Perlfile> module

=cut

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

use FindBin qw($Script $Bin);

use lib "$Bin/../lib";

use Getopt::Long qw(GetOptions);
use File::Spec::Functions qw(catfile);
use File::Slurp qw(append_file);
use File::Path qw(rmtree);
use List::MoreUtils qw(uniq);

use Base::PerlFile;

use Base::Arg qw(
    hash_inject
);

use Cwd qw(abs_path getcwd);

use base qw(Base::Logging);

=head1 METHODS

=head2 new

Constructor

=cut

sub new
{
    my ($class, %opts) = @_;
    my $self = bless (\%opts, ref ($class) || $class);

    $self->init if $self->can('init');

    return $self;
}

sub init {
    my ($self) = @_;

    my $h = {
        dbfile => catfile($ENV{HOME},qw(db ty.sqlite)),
    };
    hash_inject($self, $h);

    return $self;

}

sub logfile {
    my $self = shift;

    my $logfile = catfile(getcwd(),'ty.log');

    return $logfile;
}
      
sub get_opt {
    my ($self) = @_;
    
    Getopt::Long::Configure(qw(bundling no_getopt_compat no_auto_abbrev no_ignore_case_always));
    
    my (@optstr, %opt);

    @optstr=( 
        "tfile=s",
        "dbfile=s",
        "dir=s@" ,
        "file=s@" ,
        "add=s" ,
        "inc",
        "action|a=s",
        "max_node_count=i",
        "files_limit=i",
        "redo_files",
        "redo_db",
        "ns=s",
        "debug|d",
    );
    
    unless( @ARGV ){ 
        $self->dhelp;
        exit 0;
    }

    GetOptions(\%opt,@optstr);
    $self->{opt} = \%opt;
    
    $self;
}

sub dhelp {
    my ($self) = @_;

    my $s= << "S";
    USAGE
        perl $Script OPTIONS
    OPTIONS
        --help

        --tfile     FILE         (string)
        --dir DIR1 --dir DIR2    (array)
        --inc 

        --debug -d

        --dbfile DBFILE

        --action -a ACTION          (string)
            values:
                generate_from_fs
                generate_from_db
            default: 
                generate_from_db

        --max_node_count COUNT   (int)
            default: 0

        --files_limit LIM        (int)
            default: 0

        --redo      

        --ns  NAMESPACE          (string)
    EXAMPLES
        perl $Script --inc
        perl $Script --inc -a generate_from_fs
        perl $Script --dir "../lib" -a generate_from_fs
        perl $Script --dir "../lib" -a generate_from_fs -d

S
    print $s . "\n";

    $self;
}

=head2 run

=head3 Calls:

get_opt, run_pf

=cut

sub run {
    my $self=shift;

    $self
        ->get_opt
        ->run_pf;

    $self;

}

=head2 run_pf

=head3 Purpose

=over 4

=item * create a new L<Base::PerlFile> instance stored in C<$pf> variable;

=item * run one of L<Base::PerlFile> actions via created C<$pf> L<Base::PerlFile> instance  ( generate_from_db, generate_from_fs )

=back

=cut

sub run_pf {
    my ($self) = @_;

    # directories to be processed by Base::PerlFile
    my @dirs =  @{ $self->{opt}->{dir} || [] };

    # files to be processed by Base::PerlFile
    my @files =  @{ $self->{opt}->{file} || [] };

    my $redo_files = $self->{opt}->{redo_files} || 0;
    my $redo_db    = $self->{opt}->{redo_db} || 0;

    my $tfile = $self->{opt}->{tfile} || catfile(getcwd(),'tygs');
    if (-e $tfile) {
        $self->log(['Removing tygs file: ', "\t" . $tfile ]);
        rmtree $tfile;
    }

    if ($self->{opt}->{inc}) {
        push @dirs, @INC;
    }

    # SQLite database location
    my $dbfile = $self->{opt}->{dbfile} || $self->{dbfile};
    if ($redo_db && -e $dbfile) {
        $self->log([ 'Removing dbfile: ', "\t" . $dbfile ]);
        rmtree $dbfile;
    }

    # possible actions are:
    #   generate_from_db
    #   generate_from_fs
    my $action = $self->{opt}->{action} || 'generate_from_db';

    @dirs = map { abs_path($_) } @dirs;
    @dirs = uniq(@dirs);

    my $logfile = $self->logfile;
    rmtree $logfile if -e $logfile;

    my $add_s = $self->{opt}->{add} || q{subs,packs,vars,include};
    my @add   = split( "," => $add_s );

    my $files_limit = $self->{opt}->{files_limit} || 0;

    my @m;
    push @m,
        'redo_files:   ',
            "\t" . $redo_files,
        'redo_db:   ',
            "\t" . $redo_db,
        'logfile:   ',
            "\t" . $logfile,
        'tagfile:   ',
            "\t" . $tfile,
        (@dirs) ? ( 'dirs:   ', ( map { (defined $_) ? "\t" . $_ : () } @dirs )) : (), 
        (@files) ? ( 'files:   ', ( map { (defined $_) ? "\t" . $_ : () } @files )) : (), 
        'dbfile:   ',
            "\t" . $dbfile,
        'action:   ',
            "\t" . $action,
        'add:   ',
            "\t" . $add_s,
        ;
    if ($files_limit) {
        push @m, 'files_limit: ', "\t" . $files_limit;
    }

    $self->log([@m]);

    my $def_PRINT = sub { 
        append_file($logfile,join("\n",map { (defined) ? $_ : () } @_ ) . "\n");
    };
    my $def_WARN = sub { 
        append_file($logfile,join("\n",map { (defined) ? 'WARN ' . $_  : () } @_) . "\n");
    };

    my %o = (
        dirs           => [@dirs],
        files          => [@files],
        tagfile        => $tfile,
        dbfile         => $dbfile,
        def_PRINT      => $def_PRINT,
        def_WARN       => $def_WARN,
        add            => [@add],
        max_node_count => $self->{opt}->{max_node_count} || 0,
        files_limit    => $files_limit,
        redo_files     => $redo_files,
        ns             => $self->{opt}->{ns} || '',
        debug          => $self->{opt}->{debug},
    );

    my $pf = Base::PerlFile->new(%o);

    my $start = time();
    $pf->$action;
    my $end = time();

    $self->log(['TIME SPENT:',"\t" . ($end-$start)]);

    $self;
}



package main;

ty->new->run;
