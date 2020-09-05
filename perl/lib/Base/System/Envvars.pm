package Base::System::Envvars;

use Win32::Env;
use Win32::Env::Path;

use File::Spec::Functions qw(catfile);
use Getopt::Long;

our ($hm,$home,$progs,@path,$comp);
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

            ENV_alias
            ENV_catfile
            ENV_get
            ENV_join
            ENV_set
            ENV_set_SYS
            
            set_PATH_USER
            set_PERLLIB
            set_vars
            set_env_perl

            list_ENV
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

sub list_ENV {
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

sub set_CLASSPATH {

    my $a=[
        [qw(c: lib java httpcomponents-client lib)],
        [qw(c: lib java)]
    ];
    my $cp = join(";", map { catfile(@{$_}) } @$a );

    ENV_set 
        CLASSPATH => $cp;
}

sub main {

    if (@ARGV) {
    }else{ }

    init;

    set_env_perl;
    #list_ENV();
    #exit;

    set_vars;
    set_PATH_USER;
    set_CLASSPATH;

    set_env_perl;

    print 'Broadcasting env...' . "\n";
    BroadcastEnv();

}

sub set_env_perl {
    set_PERLLIB;

    my @p_s=split(";",GetEnv(ENV_SYSTEM,'Path'));
    my %p_s=map { $_ => 1 } @p_s;

    @p_s{
        ENV_get('Perl_Bin_ActiveState'),
        ENV_get('Perl_Site_Bin_ActiveState'),
        #'C:\Program Files (x86)\Git\bin',
    }=0;
    my @n;
    foreach(@p_s) {
        push @n,$_ if $p_s{$_};
    }
    my $n=join(';',@n);
    print $n . "\n";

    #ENV_set_SYS(PATH => $n);


}

sub set_PERLLIB {

    ENV_set 
        PERLLIB => ENV_join(qw(
            perlmoddir_lib
            htmltool_lib
            perlmoddir_vim_perl_lib
            perl_lib_strawberry
            perl_lib_strawberry_vendor
            perl_lib_strawberry_c
            perl_lib_strawberry_c_site
        ));
    
}

sub init {
    $comp=$ENV{COMPUTERNAME};
}

sub ENV_set {
    my %o=@_;

    while(my($k,$v)=each %o){
        $ENVV{$k}=$v;
        print "Setting env $k => $v" . "\n";
        SetEnv(ENV_USER,$k,$v);
    }
}

sub ENV_set_SYS {
    my %o=@_;

    while(my($k,$v)=each %o){
        $ENVV_SYS{$k}=$v;
        print "Setting SYSTEM env $k => $v" . "\n";
        SetEnv(ENV_SYSTEM,$k,$v);
    }
}

sub ENV_catfile {
    my $root = shift;

    catfile($ENVV{$root},@_);
}

sub ENV_alias {
    my %o=@_;

    while(my($k,$v)=each %o){
        ENV_set $k => ENV_get($v);
    }
}

sub ENV_get {
    my $id=shift;

    $ENVV{$id} || $ENV{$id};
}

sub ENV_join {
    join ';' => map { ENV_get($_) } @_;
}

sub set_vars {

    $home = catfile($ENV{HOMEDRIVE},$ENV{HOMEPATH});
    $hm   = $home;
    $progs = catfile($hm,qw(programs));

    $pfiles = catfile($ENV{PROGRAMFILES});

    ENV_set HOME    => $home;

    ENV_set 
        hm               => $hm,
        hm_bin           => catfile($hm,qw(bin)),
        reposgit         => catfile($hm,qw(repos git)),
        progs            => $progs,
        perl_strawberry  => catfile(qw( C: strawberry perl )),
        vcbin            => catfile('c:\Program Files (x86)' ,'Microsoft Visual Studio 10.0','VC','bin'),
    ;

    ENV_set 
        localhost => ENV_catfile(qw(OpenServer domains localhost));


    ENV_set 
        bin_php => ENV_catfile(qw(OpenServer modules php PHP-7.1-x64));

    ENV_set 
        bin_php_pear => ENV_catfile(qw(bin_php),'PEAR');

    ENV_set 
        saved_html => catfile(qw(c: saved html ));

    ENV_set 
        bin_wget => ENV_catfile(qw(OpenServer modules wget bin));

    # to handle problem with Python vs Windows console
    ENV_set 
        PYTHONIOENCODING => 'UTF-8';

    ENV_set 
        Perl_Strawberry_C  => catfile(qw(C: strawberry perl));

    ENV_set 
        Perl_Lib_ActiveState       => ENV_catfile(qw(Perl_ActiveState lib)),
        Perl_Lib_Strawberry        => ENV_catfile(qw(Perl_Strawberry lib)),
        Perl_Lib_Strawberry_vendor => ENV_catfile(qw(Perl_Strawberry vendor lib)),
        Perl_Lib_Strawberry_C      => ENV_catfile(qw(Perl_Strawberry_C lib)),
        Perl_Lib_Strawberry_C_Site => ENV_catfile(qw(Perl_Strawberry_C site lib)),
        ;

    ENV_set 
        Perl_Bin_Strawberry       => ENV_catfile(qw(Perl_Strawberry bin)),
        Perl_Bin_ActiveState      => ENV_catfile(qw(Perl_ActiveState bin)),
        Perl_Site_Bin_ActiveState => ENV_catfile(qw(Perl_ActiveState site bin)),
        ;

    ENV_set 
        inews_local     => ENV_catfile(qw(OpenServer domains inews.local )),
        ap_local        => ENV_catfile(qw(OpenServer domains ap.local )),
        jq_course_local => ENV_catfile(qw(OpenServer domains jq-course.local ));

    ENV_set 
        mysql_bin => ENV_catfile(qw(OpenServer modules database MySQL-5.7-x64 bin )),
        ;

    ENV_set
        postgresql_bin => ENV_catfile(qw(OpenServer modules database PostgreSQL-9.6-x64 bin ));

    ENV_set 
        src_java_imported => ENV_catfile(qw(
            REPOSGIT java imported
            ));

    ENV_set 
        src_vim => catfile(qw(C: src vim));


    ENV_set 
        include_win_sdk => 'C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\Include';

    ENV_set 
        src_latexdraw_root => ENV_catfile(qw(
                src_java_imported
                latexdraw 
                latexdraw-core 
                net.sf.latexdraw
                src main ));

    ENV_set 
        src_latexdraw => ENV_catfile(qw(
            src_latexdraw_root
            java net sf latexdraw
        ));

    ENV_alias vrt => 'vimruntime';

    ENV_set 
        PERLMODDIR => ENV_catfile(qw(REPOSGIT perlmod));

    ENV_set 
        HTMLTOOL => ENV_catfile(qw(REPOSGIT htmltool));

    ENV_set 
        HTMLTOOL_LIB => ENV_catfile(qw(HTMLTOOL lib));

    ENV_set 
        PERLMODDIR_VIM_PERL_LIB => ENV_catfile(qw(PERLMODDIR mods Vim-Perl lib ));

    ENV_set 
        PERLMODDIR_LIB => ENV_catfile(qw(PERLMODDIR lib));

    ENV_set 
        CLASSPATH => catfile(qw(c: lib java httpcomponents-client lib));

    ENV_set 
        JAVA_HOME => catfile('c:','Program Files','Java','jdk-9');

    ENV_set 
        M2_HOME => catfile('c:','Users','apoplavskiy','programs','maven');

    ENV_set
        JDK_BIN => ENV_catfile(qw(JAVA_HOME bin));

    ENV_set
        MVN_BIN => ENV_catfile(qw(M2_HOME bin));

    my @texinputs;

    push @texinputs, 
        '.',
        ENV_catfile(qw(REPOSGIT texinputs)),
        ENV_catfile(qw(REPOSGIT p)),
        ''
    ;
    my $ti=join(';',@texinputs);
    $ti =~ s{\\}{\/}g;

    ENV_set TEXINPUTS => $ti;

    my @bibinputs;

    push @bibinputs, 
        '.',
        ENV_catfile(qw(REPOSGIT p)),
        ''
    ;
    my $bi=join(';',@bibinputs);
    $bi =~ s{\\}{\/}g;

    ENV_set BIBINPUTS => $bi;

    ENV_set 
        IPTE_LIB_CLIENT => ENV_catfile(qw(REPOSSVN Veloxum iPTE trunk Clients Perl)),
        IPTE_AO => ENV_catfile(qw(REPOSSVN Veloxum iPTE trunk Clients Perl_AO)),
        IPTE_DOCS       => ENV_catfile(qw(REPOSSVN Veloxum iPTE trunk Docs)),
        IPTE_RECIPES    => ENV_catfile(qw(REPOSSVN ipteclient recipes)),
        IPTE_TESTS      => ENV_catfile(qw(C: testipte)),
        VIM_GFN         => 'Lucida_Console:h15:cANSI',
    ;

    ENV_set 
        VIM => ENV_catfile(qw(HOME programs Vim));

    ENV_set 
        VIMRUNTIME => ENV_catfile(qw(VIM Vim74));

    ENV_set 
        HTMLOUT => catfile(qw(C: out html )),
        PDFOUT  => catfile(qw(C: out pdf ))
    ;

    ENV_set 
        PROJSDIR => ENV_catfile(qw(REPOSGIT texdocs)), 
        TEXDOCS  => ENV_catfile(qw(REPOSGIT texdocs)), 
        JSDOCS   => ENV_catfile(qw(REPOSGIT jsdocs)); 

    ENV_set 
        TexPapersRoot => ENV_catfile(qw(REPOSGIT p)); 

    ENV_set 
        PdfPapersField => 'ChemPhys'; 

    ENV_set 
        PdfPapersRoot => catfile(qw(C: doc papers )); 

    ENV_set 
        LINUX_VRT     => ENV_catfile(qw(REPOSGIT vrt));

    ENV_set 
        SCRIPTSDIR => ENV_catfile(qw(HOME scripts)),
        CONFDIR  => ENV_catfile(qw(HOME config)),
    ;


    #TMP => #%USERPROFILE%\AppData\Local\Temp

}

sub set_PATH_USER {

    print "Setting User PATH" . "\n";

    SetEnv(ENV_USER,'PATH','');
    
    @path = ( 
        [ $progs ,'ctags58'      ] ,
        [ $progs ,'lynx'         ] ,
        [ $progs ,'elinks'         ] ,
        [ $progs ,'gtags','bin'  ] ,
        [ $progs ,'exiv2',       ] ,
        [ $progs ,'eclipse',     ] ,
        [ $progs ,'mingw', 'bin' ] ,
        [ $progs ,'rapidEE',     ] ,
        [ $home ,qw(bin)        ] ,
        [ $hm   ,qw(bin)        ] ,
        [ $hm   ,qw(bin_phd) ],
        [ ENV_get('JDK_BIN') ],
        [ ENV_get('MVN_BIN') ],
        [ ENV_get('mysql_bin') ],
        [ ENV_get('postgresql_bin') ],
        [ $pfiles, 'Microsoft Visual Studio 10.0\VC\bin' ],
        [ $pfiles, 'IrfanView' ],
        [ ENV_get('Perl_Bin_Strawberry') ],
        [ ENV_get('bin_php') ],
        [ ENV_get('bin_php_pear')],
        [ ENV_get('bin_wget') ],
        [ ENV_catfile(qw(Perl_Strawberry_C bin)) ],
        [ ENV_catfile(qw(Perl_Strawberry_C site bin )) ],
        [ ENV_catfile(qw(OpenServer progs _Office Notepad++ )) ],
        [ ENV_catfile(qw(VIMRUNTIME plg idephp scripts perl)) ],
    );
    
    push @path, 
        [ qw(C: texlive 2015 bin win32) ],
        [ qw(C: Ruby22 bin) ],
        [ qw(C: ),'Resource Tuner Console' ],
        [ qw(C: ),'Resource Tuner Console' ],
    ;
    
    @path=map { 
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
 

