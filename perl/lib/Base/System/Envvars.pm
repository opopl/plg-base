
package Base::System::Envvars;

use Win32::Env;
use Win32::Env::Path;

use File::Spec::Functions qw(catfile);
use Getopt::Long;
use Data::Dumper qw(Dumper);

our ($hm,$home,$prg,$comp);
our ($pfiles);

our @PATH;

# env variables
our (@do);

# PATH insertions
our (@ip);

our $debug = 1;

our (%ENVV,%ENVV_SYS);

use warnings;
use strict;

use Exporter ();
use base qw(Exporter);
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

@ISA     = qw(Exporter);
@EXPORT  = qw( );
$VERSION = '0.01';

BEGIN { 

###s_do
    @do = qw(
       do_core

       do_doc
       do_microsoft
       do_perl
       do_projs
       do_python
       do_tdm
       do_tex
       do_vim
       do_www
    );

###s_ip
    @ip = qw(
	    ip_core

	    ip_perl
	    ip_tdm

	    ip_prg
	    ip_php
	    ip_python
    );

###s_env
    my @env = qw(
       env_alias
       env_catfile
       env_defined
       env_get
       env_join
       env_set
       env_force
       env_set_sys
    );

###s_i_path
    my @i_path;
    push @i_path,
        qw(i_path),
        ;

    my @util = qw(
        _eval
    );

###s_path
    my @path = qw(
        _path_push
        _path_insert
        _path_clear
    );

###subs
    my @subs = qw(
       install_env
       init dmp

       put pute put_dump

       list_env
    );

    push @subs,
        @do, @env, @i_path, @path, @util
        ;

    eval sprintf( q{use subs qw(%s)},join(" ",@subs) );
    if ($@) {
        die $@;
    }

###export_tags
    %EXPORT_TAGS = (
        'funcs' => \@subs,
        'vars'  => [ ]
    );
    
    @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );
};

sub list_env {
    print "--------- ENV_USER --------" . "\n";
    my @vars_u=ListEnv(ENV_USER);
    print(join(', ', sort @vars_u) . "\n");
    #
    print "--------- ENV_SYSTEM --------" . "\n";

    my @vars_s=ListEnv(ENV_SYSTEM);
    print(join(', ', sort @vars_s) . "\n");

    my @p_s=split(";",GetEnv(ENV_SYSTEM,'Path'));
    print "--------- Path (ENV_SYSTEM) --------" . "\n";
    print $_ . "\n" for(@p_s);
}

###install_env
sub install_env {
    init;

    unless ($debug) {
        put 'Broadcasting env...' ;
        BroadcastEnv();
    }else{
        put 'DEBUG MODE' ;
        dmp;
    }

}

sub env_push {
    my %o = @_;

    while(my($k,$v) = each %o){
        $ENVV{$k} = $v;

        put "Setting env $k => $v";
        #SetEnv(ENV_USER,$k,$v);
    }
}

sub env_defined {
    my ($k) = @_;

    defined $ENV{$k} ? 1 : 0;
}

sub env_force {
    my %o = @_;

    while(my($k,$v) = each %o){

        $ENVV{$k} = $v;
        print "Forcing env $k => $v" . "\n";

        SetEnv(ENV_USER, $k, $v);
    }
}

sub env_set {
    my (%o) = @_;

    while(my($k,$v) = each %o){
        next if env_defined($k);

        next unless defined $v;

        $ENVV{$k} = $v;
        put "Setting env $k => $v";

        SetEnv(ENV_USER, $k, $v) unless $debug;
    }
}

sub env_set_sys {
    my %o = @_;

    while(my($k,$v)=each %o){
        next unless env_defined_sys($k);

        $ENVV_SYS{$k} = $v;

        print "Setting SYSTEM env $k => $v" . "\n";
        SetEnv(ENV_SYSTEM,$k,$v);
    }
}

sub env_catfile {
    my $root = shift;

    catfile(env_get($root),@_);
}

sub env_alias {
    my %o=@_;

    while(my($k,$v) = each %o){
        env_set $k => env_get($v);
    }
}

sub env_get {
    my ($id, $default) = @_;

    $default ||= '';

    $ENVV{$id} || $ENV{$id} || $default;
}

sub env_join {
    join ';' => map { env_get($_) } @_;
}

sub do_microsoft {
    env_set
        vcbin => catfile('c:\Program Files (x86)' ,'Microsoft Visual Studio 10.0','VC','bin'),
        include_win_sdk => 'C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\Include',
        ;

}

sub do_perl {

    env_set 
        perl_strawberry  => catfile(qw( C: strawberry perl ));

    env_set 
        perl_strawberry_c  => catfile(qw(c: strawberry c));

    env_set 
        perl_lib_strawberry        => env_catfile(qw(perl_strawberry lib)),
        perl_lib_strawberry_vendor => env_catfile(qw(perl_strawberry vendor lib)),
        perl_lib_strawberry_c      => env_catfile(qw(perl_strawberry_c lib)),
        perl_lib_strawberry_c_site => env_catfile(qw(perl_strawberry_c site lib)),
        ;

    env_set 
        perl_bin_strawberry       => env_catfile(qw(perl_strawberry bin)),
        ;

    env_set 
        perlmoddir => env_catfile(qw(reposgit perlmod));

    env_set 
        htmltool => env_catfile(qw(reposgit htmltool));

    env_set 
        htmltool_lib => env_catfile(qw(htmltool lib));

    env_set 
        perlmoddir_vim_perl_lib => env_catfile(qw(perlmoddir mods vim-perl lib ));

    env_set 
        perlmoddir_lib => env_catfile(qw(perlmoddir lib));

    env_set 
        perl_lib_plg_base => env_catfile(qw(plg base perl lib));

    env_set 
        perl_lib_plg_base_util => env_catfile(qw( plg base util perl lib ));

    env_set 
        perl_lib_plg_projs => env_catfile(qw(plg projs perl lib));

    env_set 
        perl_lib_plg_idephp => env_catfile(qw(plg idephp perl lib));

    my $perllib = env_join(qw(
            perlmoddir_lib
            htmltool_lib
            perlmoddir_vim_perl_lib
            perl_lib_strawberry
            perl_lib_strawberry_vendor
            perl_lib_strawberry_c
            perl_lib_strawberry_c_site
            perl_lib_plg_base
            perl_lib_plg_base_util
            perl_lib_plg_idephp
            perl_lib_plg_projs
        ));

    env_set perllib => $perllib;
}

sub do_core {
    $comp = $ENV{COMPUTERNAME};

    $home = catfile($ENV{HOMEDRIVE},$ENV{HOMEPATH});
    $hm   = $home;
    $prg  = catfile($hm,qw(programs));

    $pfiles = catfile($ENV{PROGRAMFILES});

    env_set 
        home             => $home,
        hm               => $hm,
        hm_bin           => catfile($hm,qw(bin)),
        reposgit         => catfile($hm,qw(repos git)),
        prg              => $prg,
    ;

    env_set 
        config_win => env_catfile(qw(home config_win)),
    ;

}

sub do_tex {
    my @texinputs;

    env_set 
        texpapersroot => env_catfile(qw(reposgit p));

    push @texinputs, 
        '.',
        env_catfile(qw(reposgit texinputs)),
        env_catfile(qw(reposgit p)),
        ''
    ;
    my $ti = join(';',@texinputs);
    $ti =~ s{\\}{\/}g;

    env_set 
        texinputs => $ti;

    my @bibinputs;

    push @bibinputs, 
        '.',
        env_catfile(qw(reposgit p)),
        ''
    ;
    my $bi = join(';',@bibinputs);
    $bi =~ s{\\}{\/}g;

    env_set 
        bibinputs => $bi;

}

sub do_doc {
    env_set 
        htmlout => catfile(qw(c: out html )),
        pdfout  => catfile(qw(c: out pdf )),
        pdf     => env_catfile(qw(home doc pdf )),
        doc     => env_catfile(qw(home doc  )),
    ;
}

sub do_python {
    env_set 
        py2_root         => catfile(qw(c: python27 )),
        py3_root         => catfile(qw(c: python37 )),
        pythonioencoding => 'UTF-8'
    ;
}

sub do_vim {
    my $vv = env_get('vim_version', '82');

    env_set 
        vim => env_catfile(qw(home programs vim));

    env_set 
        vimruntime => env_catfile(qw(vim), qq{vim$vv} );

    env_alias vrt => 'vimruntime';

    env_set 
        plg => env_catfile( qw(vimruntime plg) );

    env_set 
        src_vim => env_catfile(qw(reposgit vim)),
        vim_gfn => 'Lucida_Console:h15:cANSI',
    ;
}

sub do_tdm {
    env_set 
        tdm_bin  => catfile(qw(c: tdm-gcc-64 bin));
}

sub do_projs {
    env_set 
        p_saintrussia => env_catfile(qw(reposgit p_saintrussia)),
        texdocs       => env_catfile(qw(reposgit texdocs)),
        projsdir      => env_catfile(qw(reposgit texdocs)),
        ;
}

sub do_www {
    env_set 
        xampp => env_catfile(qw(prg xampp));

    env_set 
        bin_php => env_catfile(qw(xampp php)),
        www     => env_catfile(qw(xampp htdocs))
        ;
}

sub _eval {
    for(@_){ eval $_; pute $@ if ($@); }
}

sub dmp {
    put_dump \@PATH, \%ENVV;
}

sub init {
    _eval(@do);
    i_path;

}

sub _path_clear {
    @PATH = ();
}

sub _path_insert {

    my @path_dirs = map { 
        my $d = catfile(@{$_}); 
        ( -d $d ) ? $d : () 
    } @PATH;
    
    InsertPathEnv(ENV_USER, PATH => join(';',@path_dirs));

}

sub _path_push {

    push @PATH, map { 
        my $y;
        my @a = @{$_};

        $y = (@a == 1) && (! length($a[0])) ? 0 : 1;
        $y ? $_ : ();
    } @_;
}

sub put {
    print $_ . "\n" for(@_);
}

sub pute {
    die shift;
}

sub put_dump {
    for(@_){
        put Dumper($_);
    }
}

sub ip_php {

    _path_push 
        [ env_get('bin_php') ],
        [ env_get('bin_php_pear')],
        ;
}

sub ip_perl {

    _path_push
        [ env_get('perl_bin_strawberry') ],
        [ env_catfile(qw(perl_strawberry_c bin)) ],
        [ env_catfile(qw(perl_strawberry_c site bin )) ],
        [ env_catfile(qw(htmltool bin )) ],
        ;
}

sub ip_tdm {
    _path_push
        [ env_get('tdm_bin') ]
        ;
}


sub ip_prg {
    _path_push
        [ $prg ,'ctags58'      ] ,
        [ $prg ,'lynx'         ] ,
        [ $prg ,'elinks'       ] ,
        [ $prg ,'gtags','bin'  ] ,
        [ $prg ,'exiv2',       ] ,
        [ $prg ,'eclipse',     ] ,
        [ $prg ,'mingw', 'bin' ] ,
        [ $prg ,'rapidEE',     ] ,
        [ $pfiles, 'IrfanView' ],
        ;
}

sub ip_core {

    _path_push
        [ $home ,qw(bin)        ] ,
        [ $hm   ,qw(bin)        ] ,
        ;
}

sub ip_python {
    _path_push 
        [ env_get('py2_root') ],
        [ env_get('py3_root') ],
    ;
}

sub ip_vim {
    _path_push
        [ env_catfile(qw(plg base bin)) ],
        [ env_catfile(qw(plg base util perl bin)) ],
        [ env_catfile(qw(plg idephp scripts perl)) ],
        [ env_catfile(qw(plg projs scripts)) ],
    ;
}

sub i_path {

    put "Setting User PATH";

    #SetEnv(ENV_USER,'PATH','') unless $;

    _eval(@ip);
    
}

1;
