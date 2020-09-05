package Base::System::Envvars;

use Win32::Env;
use Win32::Env::Path;

use File::Spec::Functions qw(catfile);
use Getopt::Long;

our ($hm,$home,$prg,@path,$comp);
our ($pfiles);

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
###subs
    my @subs = qw(
            main
            init

            env_alias
            env_catfile
            env_get
            env_join
            env_set
            env_set_sys
            
            set_path_user
            set_perllib

            do_tex
            do_microsoft

            init

            list_env
    );

    eval sprintf( q{use subs qw(%s)},join(" ",@subs) );
    if ($@) {
        die $@;
    }

###export_vars_scalar
    my @ex_vars_scalar=qw(
    );
###export_vars_hash
    my @ex_vars_hash=qw(
    );
###export_vars_array
    my @ex_vars_array=qw(
    );
    
###export_tags
    %EXPORT_TAGS = (
        'funcs' => \@subs,
        'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
    );
    
    @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );
};


#main;
#exit 0;

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

sub main {
    init;

    set_perllib;
    set_path_user;

    print 'Broadcasting env...' . "\n";
    BroadcastEnv();

}

sub env_push {
    my %o = @_;

    while(my($k,$v) = each %o){
        $ENVV{$k} = $v;
        print "Setting env $k => $v" . "\n";
        SetEnv(ENV_USER,$k,$v);
    }
}

sub env_set {
    my %o = @_;

    while(my($k,$v) = each %o){
        $ENVV{$k} = $v;
        print "Setting env $k => $v" . "\n";
        SetEnv(ENV_USER,$k,$v);
    }
}

sub env_set_sys {
    my %o=@_;

    while(my($k,$v)=each %o){
        $ENVV_SYS{$k}=$v;
        print "Setting SYSTEM env $k => $v" . "\n";
        SetEnv(ENV_SYSTEM,$k,$v);
    }
}

sub env_catfile {
    my $root = shift;

    catfile($ENVV{$root},@_);
}

sub env_alias {
    my %o=@_;

    while(my($k,$v)=each %o){
        env_set $k => ENV_get($v);
    }
}

sub env_get {
    my ($id, $default) = @_;

    $ENVV{$id} || $ENV{$id};
}

sub env_join {
    join ';' => map { ENV_get($_) } @_;
}

sub do_microsoft {
    env_set
        vcbin => catfile('c:\Program Files (x86)' ,'Microsoft Visual Studio 10.0','VC','bin'),
        include_win_sdk => 'C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\Include',
        ;

}

sub do_perl {

    env_set 
        perl_strawberry  => catfile(qw( C: strawberry perl )),

    env_set 
        perl_strawberry_c  => catfile(qw(c: strawberry perl c));

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

    env_set 
        perllib => env_join(qw(
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

}

sub do_tex {
    my @texinputs;

    env_set 
        projsdir => env_catfile(qw(reposgit texdocs)), 
        texdocs  => env_catfile(qw(reposgit texdocs)), 
        ;

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

sub do_python {

    # to handle problem with Python vs Windows console
    env_set 
        pythonioencoding => 'UTF-8';
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

sub do_xampp {

    env_set 
        xampp => env_catfile(qw(prg xampp));

    env_set 
        bin_php => env_catfile(qw(xampp php));
}

sub init {

    do_core;

    do_microsoft;
    do_xampp;
    do_python;
    do_vim;
    do_perl;
    do_tex;



    env_set 
        htmlout => catfile(qw(c: out html )),
        pdfout  => catfile(qw(c: out pdf ))
    ;

 

    env_set 
        scriptsdir => env_catfile(qw(home scripts)),
        confdir    => env_catfile(qw(home config)),
    ;


    #TMP => #%USERPROFILE%\AppData\Local\Temp

}

sub set_path_user {

    print "Setting User PATH" . "\n";

    SetEnv(ENV_USER,'PATH','');
    
    @path = ( 
        [ env_get('perl_bin_strawberry') ],
        [ env_get('bin_php') ],
        [ env_get('bin_php_pear')],
        [ env_get('bin_wget') ],
        [ $prg ,'ctags58'      ] ,
        [ $prg ,'lynx'         ] ,
        [ $prg ,'elinks'         ] ,
        [ $prg ,'gtags','bin'  ] ,
        [ $prg ,'exiv2',       ] ,
        [ $prg ,'eclipse',     ] ,
        [ $prg ,'mingw', 'bin' ] ,
        [ $prg ,'rapidEE',     ] ,
        [ $home ,qw(bin)        ] ,
        [ $hm   ,qw(bin)        ] ,
        [ $hm   ,qw(bin_phd) ],
        [ env_get('jdk_bin') ],
        [ env_get('mvn_bin') ],
        [ env_get('mysql_bin') ],
        [ env_get('postgresql_bin') ],
        [ $pfiles, 'IrfanView' ],
        [ env_catfile(qw(perl_strawberry_c bin)) ],
        [ env_catfile(qw(perl_strawberry_c site bin )) ],
        [ env_catfile(qw(vimruntime plg idephp scripts perl)) ],
    );
    
    @path = map { 
        my $d = catfile(@{$_}); 
        ( -d $d ) ? $d : () 
    } @path;
    
    InsertPathEnv(ENV_USER, PATH => join(';',@path));

}

1;


#C:\Program Files (x86)\ActiveState Perl Dev Kit 7.3\bin;C:\Perl\site\bin;C:\Perl\bin;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Program Files (x86)\Skype\Phone\;C:\Program Files (x86)\Git\cmd;C:\Program Files (x86)\Git\bin;C:\Program Files\TortoiseSVN\bin;C:\Ruby22\bin;C:\Users\op\bin;C:\Users\op\programs\ctags58;C:\texlive\2013\bin\win32;C:\Users\op\programs\Vim\vim74
#
#C:\Program Files (x86)\ActiveState Perl Dev Kit 7.3\bin
#C:\Perl\site\bin
#C:\Perl\bin
#C:\Windows\system32
#C:\Windows
#C:\Windows\System32\Wbem
#C:\Windows\System32\WindowsPowerShell\v1.0\
#C:\Program Files (x86)\Skype\Phone\
#C:\Program Files (x86)\Git\cmd
#C:\Program Files (x86)\Git\bin
#C:\Program Files\TortoiseSVN\bin
#C:\Ruby22\bin
#C:\Users\op\bin
#C:\Users\op\programs\ctags58
#C:\texlive\2013\bin\win32
#C:\Users\op\programs\Vim\vim74

#C:\Users\op\repos\svn\Perl
#C:\Users\op\repos\git\perlmod\lib
#C:\Users\op\repos\git\perlmod\mods\Vim-Perl\lib
 

