package Vim::Perl;

=head1 NAME 

Vim::Perl - Perl package for efficient interaction with VimScript

=head1 USAGE

=cut

use strict;
use warnings;

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use File::Spec::Functions qw(catfile rel2abs curdir catdir );

use File::Dat::Utils qw( readarr );
use Text::TabularDisplay;
use String::Escape qw(escape printable quote);
use JSON::XS;

use Clone qw(clone);

use Data::Dumper;
use File::Basename qw(basename dirname);
use File::Slurp qw(
  append_file
  edit_file
  edit_file_lines
  read_file
  write_file
  prepend_file
);

use DBI;

use Base::DB qw(
    dbh_insert_hash
);

use Base::Util qw(
    replace_undefs
    file_w
);

$VERSION = '0.01';
@ISA     = qw(Exporter);

@EXPORT = qw();

=head1 EXPORTS

=head2 SUBROUTINES

=head2 VARIABLES

=cut

###export_vars_scalar
my @ex_vars_scalar = qw(
  $ArgString
  $NumArgs
  $MsgColor
  $MsgPrefix
  $MsgDebug
  $ModuleName
  $SubName
  $FullSubName
  $CURBUF
  $UnderVim
  $PAPINFO
  $SILENT
);
###export_vars_hash
my @ex_vars_hash = qw(
  %VDIRS
  %VFILES
);
###export_vars_array
my @ex_vars_array = qw(
  @BUFLIST
  @BFILES
  @Args
  @NamedArgs
  @PIECES
  @LOCALMODULES
);

%EXPORT_TAGS = (
###export_funcs
    'funcs' => [
        qw(
          CurBufSet
          EnvVar
          UnderVim
          VimBufSplit
          VimListExtend
          VimAppend
          VimArg
          VimBufFiles_Insert_SubName
          VimChooseFromPrompt
          VimCmd
          VimCreatePrompt
          VimEcho
          VimEditBufFiles
          VimEval
          VimExists
          VimFileOpen
          VimGetFromChooseDialog
          VimGetLine
          VimGrep
          VimInput
          VimJoin
          VimLen
          VimLet
          VimLetEval
          VimLog
          VimMsg
          VimMsgDump
          VimPerlGetModuleName
          VimPerlGetModuleNameFromDialog
          VimPerlInstallModule
          VimPerlModuleNameFromPath
          VimPerlPathFromModuleName
          VimPerlViewModule
          VimPieceFullFile
          VimQuickFixList
          VimResetVars
          VimSet
          VimSetLine
          VimSetTags
          VimSo
          VimExecAu
          VimStrToOpts
          VimThisLine
          VimVar
          VimVarDump
          VimVarEcho
          VimVarType
          VimWarn
          Vim_Files
          Vim_Files_DAT
          Vim_MsgColor
          Vim_MsgDebug
          Vim_MsgPrefix
          _die
          init
          init_Args
          init_PIECES
          )
    ],
    'vars' => [ @ex_vars_scalar, @ex_vars_array, @ex_vars_hash ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );
our @EXPORT    = qw( );
our $VERSION   = '0.01';


################################
# GLOBAL VARIABLE DECLARATIONS
################################
###our
###our_scalar
# --- package loading, running under vim  
our $UnderVim;
#
# --- join(a:000,' ')
our $ArgString;

# --- len(a:000)
our ($NumArgs);

# --- VIM::Eval return values
our ( $EvalCode, $res );

# ---
our ($SubName);        #   => x
our ($FullSubName);    #   => VIMPERL_x

# ---
our ($CURBUF);

# ---
our ($MsgColor);
our ($MsgPrefix);
our ($MsgDebug);

our $SILENT;
our ($DBH,$DBFILE);

# ---
our ($ModuleName);
###our_array
our @BUFLIST;
our @BFILES;
our @PIECES;
our @LOCALMODULES;
our ( @Args, @NamedArgs );
our (@INITIDS);
###our_hash
our %VDIRS;
our %VFILES;
###our_ref
# stores current paper's information
our $PAPINFO;

=head1 SUBROUTINES

=cut

sub VimCmd {
    my $ref = shift;

    if (ref $ref eq "ARRAY"){
        my $cmds=$ref;
        foreach my $cmd (@$cmds) {
            VimCmd($cmd);
        }
        return;
        
    }elsif(ref $ref eq ''){
        my $cmd = $ref;
        return unless $UnderVim;
        return VIM::DoCommand("$cmd"); 
    }


}

sub VimArg {
    my $num = shift;

    my $arg = VimEval("a:$num");

    $arg;

}

sub VimExecAu {
    my ($ref) = @_;

    my $au      = $ref->{au} || [];
    my $tmp_dir = $ref->{tmp_dir} || '';
    my $tmp     = $ref->{tmp} || 'tmp.vim';

    my $tmp_vim = catfile($tmp_dir, $tmp);
    $tmp_vim =~ s/\\/\//g;

    file_w({ 
            file  => $tmp_vim,
            lines => $au,
    });
    VimSo($tmp_vim);

}

sub VimSo {
    my $file = shift;

    return unless $file;

    $file =~ s/\\/\//g;
    VimCmd("source $file");

}

sub VimLen {
    my $name = shift;

    my $len = 0;

    if ( VimExists($name) ) {
        $len = VimEval("len($name)");
    }

    return $len;
}

=head3 VimVar

=head4 Usage

    VimVar($var,$rtype,$vtype);

=head4 Purpose

Return Perl representation of a VimScript variable

=head4 Examples

    VimVar('000','arr','a');

    VimVar('confdir','','g');

=cut


sub VimVar {
    my ($var) = @_;

    return '' unless VimExists($var);
    my $vartype = VimVarType($var);

    for ($vartype) {
        /^(String|Number|Float)$/ && do {
            my $res = VimEval($var);
            return $res;
        };

        last;
    }

    my ($dmp,$res);

    $dmp = VimEval(qq{ pymy#var#pp($var) });

    my $coder = JSON::XS->new->ascii->pretty->allow_nonref;
    $res     = eval {$coder->decode($dmp); };
    if ($@) { VimWarn([ $@,$dmp ]); }

    unless ( ref $res ) {
        $res;
    }
    elsif ( ref $res eq "ARRAY" ) {
        wantarray ? @$res : $res;
    }
    elsif ( ref $res eq "HASH" ) {
        wantarray ? %$res : $res;
    }

    #return ($res,$dmp);

}



=head2 VimFileOpen

=head3 Usage 

    my $ref={
        file => $file,
        act  => q{split},
    };
    VimFileOpen($ref);

=cut

sub VimFileOpen {
    my ($ref) = @_;

    my $file = $ref->{file};
    my $act  = $ref->{act} || q{edit};

    $file = escape('printable',$file);
    my $cmd = qq{ 
        let f="$file"
        exe '$act ' . f  
    };
    VimCmd($cmd);
}

sub VimVarDump {
    my $var = shift;

    my $ref = VimVar($var);

    VimMsg("--------------------------------------");
    VimMsg("Type of Vim variable $var : " . VimVarType($var) );
    VimMsg("Contents of Vim variable $var :");
    VimMsg( Data::Dumper->Dump( [ $ref ], [ $var ] ) );

}

sub VimVarEcho {
    my $var = shift;

    my $ref = VimVar($var);
    my $str='';

    unless(ref $ref){
        $str=$ref;
    }elsif(ref $ref eq "ARRAY"){
        $str.="[ '";
        $str.=join("', '",@$ref);
        $str.="' ]";
    }elsif(ref $ref eq "HASH"){
        $str.="{ ";
        while(my($k,$v)=each %{$ref}){
            $str.="'" . $k . "': '" . $v . "',";
        }
        $str.=" }";
    }

    VimMsg($str);

}

sub VimVarType {
    my $var = shift;

    return '_NOT_EXIST_' unless VimExists($var);

    my $vimcode = <<"EOV";

      if type($var) == type('')
        let type='String'
      elseif type($var) == type(1)
        let type='Number'
      elseif type($var) == type(1.1)
        let type='Float'
      elseif type($var) == type([])
        let type='List'
      elseif type($var) == type({})
        let type='Dictionary'
      endif
  
EOV
    VimCmd("$vimcode");

    return VimEval('type');

}

sub VimGrep {
    my $pat = shift;

    my $ref = shift;
    my @files;

    unless ( ref $ref ) {
    }
    elsif ( ref $ref eq "ARRAY" ) {
        @files = @$ref;
        VimCmd("vimgrep /$pat/ @files");
    }

    return 1;

}

sub VimEcho {
    my $cmd = shift;

    VimMsg( VimEval($cmd), { prefix => 'none' } );

}



sub VimEval {
    my $cmd = shift;

    #return '' unless VimExists($cmd);

    ( $EvalCode, $res ) = VIM::Eval("$cmd");

    unless ($EvalCode) {
        _die("VIM::Eval evaluation failed for command: $cmd");
    }

    $res;

}

sub VimExists {
    my $expr = shift;

    ( $EvalCode, $res ) = VIM::Eval( 'exists("' . $expr . '")' );

    $res;

}



sub VimInput {
    my ( $dialog, $default ) = @_;

    unless ( defined $default ) {
        VimCmd( "let input=input(" . "'" . $dialog . "'" . ")" );
    }
    else {
        VimCmd(
            "let input=input(" . "'" . $dialog . "','" . $default . "'" . ")" );
    }

    my $inp = VimVar("input");

    return $inp;
}

=head3 VimChooseFromPrompt

=head4 Usage

    VimChooseFromPrompt($dialog,$list,$sep,@args);

=head4 Input

=over 4

=item C<$dialog> (SCALAR) 

Input dialog message string;

=item C<$list>   (SCALAR) 

String, containing list of values to be selected (separated by $sep);

=item C<$sep>   (SCALAR) 

Separator of values in $list.

=back

This is perl implementation of 
vimscript function F_ChooseFromPrompt(dialog, list, sep, ...)
in funcs.vim

=cut

#function! F_ChooseFromPrompt(dialog, list, sep, ...)

sub VimChooseFromPrompt {
    my ( $dialog, $list, $sep, @args ) = @_;

    unless ( ref $list eq "" ) {
        VimMsg_PE("Input list is not SCALAR ");
        return 0;
    }

    #let inp = input(a:dialog)
    my $inp = VimInput($dialog);

    my @opts = split( "$sep", $list );

    my $empty;
    if (@args) {
        $empty = shift @args;
    }
    else {
        $empty = $list->[0];
    }

    my $result;

    unless ($inp) {
        $result = $empty;
    }
    #elsif ( $inp =~ /^\s*(?<num>\d+)\s*$/ ) {
    elsif ( $inp =~ /^\s*(\d+)\s*$/ ) {
        $result = $opts[ $1 - 1 ];
    }
    else {
        $result = $inp;
    }

    return $result;

    #endfunction
}

sub VimCreatePrompt {
    my ( $list, $cols, $listsep ) = @_;

    my $numcommon;

    use integer;

    $numcommon = scalar @$list;

    my $promptstr = "";

    my @tableheader = split( " ", "Number Option" x $cols );
    my $table = Text::TabularDisplay->new(@tableheader);
    my @row;

    my $i     = 0;
    my $nrows = $numcommon / $cols;

    while ( $i < $nrows ) {
        @row = ();
        my $j = $i;

        for my $ncol ( ( 1 .. $cols ) ) {
            $j = $i + ( $ncol - 1 ) * $nrows;

            my $modj = $list->[$j];
            push( @row, $j + 1 );
            push( @row, $modj );

        }
        $table->add(@row);
        $i++;
    }

    $promptstr = $table->render;

    return $promptstr;

}

sub VimGetFromChooseDialog {
    my $iopts = shift;

    unless ( ref $iopts eq "HASH" ) {
        VimMsg_PE("input parameter opts should be HASH");
        return undef;
    }
    my $opts;

    $opts = {
        numcols  => 1,
        list     => [],
        startopt => '',
        header   => 'Option Choose Dialog',
        bottom   => 'Choose an option: ',
        selected => 'Selected: ',
    };

    my ( $dialog, $liststr );
    my $opt;

    $opts = _hash_add( $opts, $iopts );
    $liststr = _join( "\n", $opts->{list} );

    $dialog .= $opts->{header} . "\n";
    $dialog .= VimCreatePrompt( $opts->{list}, $opts->{numcols} ) . "\n";
    $dialog .= $opts->{bottom} . "\n";

    $opt = VimChooseFromPrompt( $dialog, $liststr, "\n", $opts->{startopt} );
    VimMsgNL();
    VimMsg( $opts->{selected} . $opt, { hl => 'Title' } );

    return $opt;

}

sub VimPerlGetModuleNameFromDialog {

    my $opts = {
        header  => "Choose the module name",
        bottom  => "Select the number of the module: ",
        list    => [@LOCALMODULES],
        numcols => 2,
    };

    my $module = VimGetFromChooseDialog($opts);

    return $module;

}

sub VimPerlGetModuleName {
    my $module;

    my $opts=shift || {};

    VimMsg(Dumper($opts));

    LOOP: while(1){

        # 1. Firstly, check for supplied input options
        foreach my $k(keys %$opts){
          for($k){
            /^selectdialog$/ && do {
                $module = VimPerlGetModuleNameFromDialog;
              last LOOP;
            };
          }
        }

        # 2. Check for command-line arguments
        #
        if ($NumArgs > 1) {
            $module=$Args[1];
            last;
        }

        # 3. If no command-line arguments have been supplied,
        #   check for the current buffer's name
        #
        my $path=VimCurBuf_Name();
        $module = '';
    
        if($path) {
            if ($path =~ /\.pm$/){
                $module = VimPerlModuleNameFromPath($path);
            }
        }else{
        # 4. If fail to get the current buffer's name, pop up a module chooser dialog
        #
            VimMsgE('Failed to get $CurBuf->{name} from Vim::Perl');
    
            $module = VimPerlGetModuleNameFromDialog;
        }
    
        unless($module){
            VimMsg("Module name is zero");
        }else{
            VimMsg("Module name is set as: $module");
            $ModuleName = $module;
        }

        last;
    }

    return $module;

}

sub VimPerlPathFromModuleName {
    my $module = shift || $ModuleName || '';

    return '' unless $module;

    require OP::PERL::PMINST;
    my $pmi = OP::PERL::PMINST->new;

    require OP::Perl::Installer;
    
    my $i = OP::Perl::Installer->new;
    $i->main;

    my $opts    = {};
    my $pattern = '.';

    $opts = {
        PATTERN    => "^" . $module . '$',
        mode       => "fullpath",
        searchdirs => $i->module_libdir($module),
    };

    # loading OP::Perl::Installer invoked unshift(@INC)
    #  for local perl module directories, so we need to exclude
    #   them  
    
    $pmi->main($opts);

    my @localpaths = $pmi->MPATHS;

    return shift @localpaths;

}

sub VimPerlModuleNameFromPath {
    my $path = shift;

    unless ( -e $path ) {
        VimMsgE( 'File :' . $path . ' does not exist' );
        return '';
    }

    my $module;

    require OP::PackName;

    VimMsgDebug('Going to create OP::PackName instance ');

    my $p = OP::PackName->new(
        {
            skip_get_opt => 1,
            ifile        => "$path",
        }
    );
    $p->opts($p->optsnew);
    $p->ifile($p->opts("ifile"));

    VimMsgDebug( Data::Dumper->Dump( [$p], [qw($p)] ) );

    $p->notpod(1);
    $p->getpackstr;

    VimMsgDebug(
        'After OP::PackName::run ' . Data::Dumper->Dump( [$p], [qw($p)] ) );

    my $packstr = $p->packstr;

    VimMsg($packstr);

    if ($packstr) {
        VimLet( "g:PMOD_ModuleName", $packstr );
        $ModuleName = $packstr;
        $module     = $packstr;

        VimMsgDebug( '$ModuleName is set to ' . $ModuleName );
    }
    else {
        VimMsgE('Failed to get $packstr from OP::PackName');
    }

    return $module;

}

sub Vim_MsgColor {
    my $color = shift;

    $MsgColor = $color;
    VimLet( "g:MsgColor", "$color" );

}

sub Vim_Files {
    my $id = shift;

    my $file = VimVar("g:files['$id']");

    return $file;
}

sub Vim_Files_DAT {
    my $id = shift;

    my $file = VimVar("g:datfiles['$id']");

    return $file;
}

sub VimResetVars {
    my $vars = shift || '';

    return '' unless $vars;

    foreach my $var (@$vars) {
        my $evs = 'Vim_' . $var . "('')";
        eval "$evs";
        if ($@) {
            VimMsg_PE($@);
        }
    }
}

sub Vim_MsgPrefix {
    my $prefix = shift || '';

    return unless $prefix;

    $MsgPrefix = $prefix;
    VimLet( "g:MsgPrefix", "$prefix" );

}

sub Vim_MsgDebug {
    my $val = shift;

    if ( defined $val ) {
        $MsgDebug = $val;
        VimLet( "g:MsgDebug", $val );
    }

    return $MsgPrefix;

}


sub VimLog {
    my @m = @_;

    for(@m){
        my $s = escape('printable',$_);
        VimCmd(qq{ call base#log("$s") });
    }
}

sub VimMsgDump {
	my @vars = @_;

	my $str='';
	foreach my $var (@vars) {
		$str .= Dumper($var);
	}
	$str =~ s/\n/ /gsm;
	VimMsg($str);
	return $str;

}

=head3 VimMsg

=head4 Usage

    my $text='aaa ... ';

    VimMsg($text,$options);
    VimMsg([ $text ],$options);

    VimMsg([ qw(a b) ],$options);

=head4 Input variables

=over 4

=item C<$text> (SCALAR,ARRAY)

input text to be displayed by Vim;

=item <$options> (HASH)

additional options (color, highlighting etc.).

=over 4

=item Structure of the C<$options> parameter.

=back

=back


=cut

sub VimMsg {
    my ($text,$ref) = @_;
    return  unless defined $text;

    $ref ||= {};
    $ref = {} unless (ref $ref eq 'HASH');

    if ( ref $text eq "ARRAY" ) {
        VimMsg($_,$ref) for(@$text);
        return 1;
    }

    unless (ref $text eq '') { return; }
    return if $SILENT;

    my $hl = $ref->{hl} || '';

    VIM::Msg($text,$hl);

    $ref->{dbfile} = $DBFILE;
    $ref->{dbh}    = $DBH;

    VimMsg_dbh($text,$ref);

    return 1;

}

sub VimMsg_dbh {
    my ($text, $ref) = @_;
    
    my $dbh    = $ref->{dbh} || $DBH;
    my $dbfile = $ref->{dbfile} || $DBFILE;

    my $start = int(VimVar('g:time_start') || time());
    my $elapsed = time() -  $start;
    my $r = {
        dbh    => $dbh,
        dbfile => $dbfile,
        t => 'log',
        i => q{INSERT OR IGNORE},
        h => {
            time     => time(),
            elapsed  => $elapsed,
            msg      => "$text",
            prf      => $ref->{prf} || "vim::perl",
            loglevel => $ref->{loglevel} || '',
            func     => $ref->{func} || '',
            plugin   => $ref->{plugin} || '',
        },
    };
        
    dbh_insert_hash($r);

}

sub VimWarn {
    my($text,$ref)=@_;
    $ref ||= {};

    my $h = {
        hl       => 'WarningMsg',
        loglevel => 'warn',
    };
    if (ref $ref eq 'HASH') {
        for (keys %$h){
            $ref->{$_} = $h->{$_};
        }
    }
    VimMsg($text,$ref);

}


=head3 VimLet

=head4 Usage

    VimLet( $var, $ref, $vtype );

=head4 Purpose

Set the value of a vimscript variable

=head4 Examples

    VimLet('paths',\%paths,'g')

    VimLet('PMOD_ModSubs',\@SUBS,'g')

=cut

sub VimLet {
    my ($var, $ref, $o) = @_;

    my $refc = clone $ref;
    replace_undefs($refc);

    my $valstr = "";
    my $vimcode = "";
    unless ( ref $ref ) {
        $valstr .= quote(printable($ref));
        $vimcode = qq{ let $var = $valstr };
    }else{
        my $coder = JSON::XS->new->ascii->pretty(0)->allow_nonref;
        $valstr = $coder->encode ($refc);
        $vimcode = qq{ let $var = $valstr };
        #$vimcode = escape('printable',$vimcode);
        print $vimcode if $o->{print_vc};
    }

    my $cmds = [];

    push @$cmds,
        qq{if exists("$var") | unlet $var  | endif},
        $vimcode
        ;

    for(@$cmds){
        VimCmd($_);
    }
}

sub VimLetOld {
    # $var - name of the vimscript variable to be assigned
    # $ref - contains value(s) to be assigned to $var
    my ($var,$ref) = @_;

    my $valstr = '';

    my $lhs = "let $var";

    unless ( ref $ref ) {
        $valstr .= quote(printable($ref));
    }
    elsif ( ref $ref eq "ARRAY" ) {
        $valstr .= "[ ";
        $valstr .= join( ',' =>  map { quote(printable($_)) } @$ref );
        $valstr .= "]";
    }
    elsif ( ref $ref eq "HASH" ) {
        unless (%$ref) {
            $valstr = '{}';
        }
        else {
            $valstr .= "{ ";
            while ( my ( $k, $v ) = each %{$ref} ) {
                $valstr .= " '$k' : '$v', ";
            }
            $valstr .= " }";
        }
    }

    if ($valstr) {
        my $cmds =[];

        push @$cmds,
            'if exists("' . $var . '") | unlet ' . $var . ' | endif ' ,
            $lhs . '=' . $valstr ;

        for(@$cmds){
            VimCmd($_);
        }
    }

}

=head3 VimLetEval

=head4 Usage

    VimLetEval($var,$expr);

=head4 Purpose

Assign to the variable C<$var> the result of evaluation of expression C<$expr>.

=head4 Examples

    VimLetEval('tempvar','tempname()') 

equivalent in vimscript to 

    let tempvar=tempname()

=cut

sub VimLetEval {
    my ($var,$expr)=@_;

    my $val=VimEval($expr);
    VimLet($var,$val);
}

sub VimSet {
    my $opt = shift;
    my $val = shift;

    VimCmd("set $opt=$val");

}



=head3 VimStrToOpts

=head4 Usage

    VimStrToOpts($str,$sep);

=head4 Input

=over 4

=item C<$str> (SCALAR) 

input string to be converted;

=item C<$sep> (SCALAR) 

separator between options in the input string.

=back

=head4 Output

hash reference of the form: 

    { OPTION1 => 1, OPTION2 => 0, etc. }

=cut

sub VimStrToOpts {
    my $str=shift;

    my $sep=shift;

    my $ropts={};

    my @opts=split("$sep",$str);

    VimMsg('Inside VimStrToOpts: sep=' . $sep . '; @opts=' . Dumper,\@opts);

    foreach my $o (@opts) {
        $ropts->{$o}=1;
    }

    $ropts;

}

###imod

=head3 VimPerlInstallModule($opts) 

=head4 Usage

    VimPerlInstallModule($opts);

=head4 Purpose

Install local Perl module(s)

Input Perl module name is provided through C<@Args>. Additional options are specified
in the optional hash structure C<$opts>.

=cut

sub VimPerlInstallModule {
    my @imodules;

    my $iopts=shift || {};
    my $opts;

    unless(ref $iopts){
        $opts=VimStrToOpts($iopts,":");
    }elsif(ref $iopts eq "HASH"){
        $opts=$iopts;
    }

    if (($NumArgs > 1 ) && ($Args[1] eq "_all_")){
        push(@imodules,@LOCALMODULES);
    }else{
        push(@imodules,VimPerlGetModuleName($opts));
    }

    require OP::Perl::Installer;
    my $i=OP::Perl::Installer->new;
    $i->main;

    foreach my $opt (keys %$opts) {
      for($opt){
        /^rbi_(force|discard_loaddat)$/ && do {
          my $evs='$i->' . $opt . '(1);' ;
          eval "$evs";
          die $@ if $@;
          next;
        };
      }
    }

    # rbi_force: 
  #     Force to install module, even if the local vs installed versions are the same
    # rbi_discard_loaddat: 
  #     Discard the list of modules from the modules_to_install.i.dat

    foreach my $module (@imodules) {

        VimMsg("Running install for module $module");

        my ($ok,$success,$fail,$failmods,$errorlines)=$i->run_build_install($module);
        if ($ok){
###imod_rbi
            VimMsg("SUCCESS");
        } else {
            VimMsg("FAIL");
            my $efmperl=catfile($VDIRS{VIMRUNTIME},qw(tools efm_perl.pl));
            my $efmfilter=catfile($VDIRS{VIMRUNTIME},qw(tools efm_filter.pl));
            my $tmpfile=VimEval('tempname()');
            my $elines=$errorlines->{module} || [];
            write_file($tmpfile,join("\n",@$elines) . "\n");

            my $qlist;
            my ($linenumber,$pattern);
            $qlist=[ {
                filename  => VimPerlPathFromModuleName($module),
                lnum  => '20',
            #text   description of the error
                text  => '',
            #type   single-character error type, 'E', 'W', etc.
                type  => '',
            } ];
###imod_qlist
            print Dumper($qlist);
            VimQuickFixList($qlist,'add');
##TODO todo_quickfix
        }
    }

}

=head3 VimQuickFixList($qlist,$action) - apply an action to the quickfix list.

=over 4

=item Input variables:

=over 4

=item $qlist    (ARRAY) array of hash items which will be added to the quickfix list.

=item $action   (SCALAR) 

=back

=back

=cut

sub VimQuickFixList {
    my $qlist=shift;

    my $action=shift;

    my @arr;

    if (ref $qlist eq "ARRAY"){
      @arr=@$qlist;
    }elsif(ref $qlist eq "HASH"){
      @arr=( $qlist );

    }

    my $i=0;
    foreach my $a (@arr) {
        VimLet('qlist',$a);

        for($action){
          /^add$/ && do {
                VimCmd("call setqflist([ qlist ], 'a')");
                next;
          };
          /^new$/ && do {
              unless($i){
                  VimCmd("call setqflist([ qlist ])");
              }else{
                  VimCmd("call setqflist([ qlist ],'a')");
              }
              next;
          };
        }
          VimMsg("Processed QLIST: " . VimEval('getqflist()'));
      $i++;
    }
}


sub VimPerlViewModule {

    my $module;

    unless($NumArgs){
        $module = VimPerlGetModuleNameFromDialog;
    }else{
        $module = $ArgString;
    }

    # get the local path of the module
    my $path = VimPerlPathFromModuleName($module);

    if ( -e $path ) {
        VimCmd("tabnew $path");
    }

}

sub VimThisLine {
    my $id=shift;

    VimEval("line('.')");
}

sub VimBufSplit {
    my $ref = shift;

    my $lines = $ref->{lines} || [];

    my $cmds=[
        'split',
        'enew',
        'setlocal buftype=nofile',
        #'setlocal nomodifiable'
    ];
    VimCmd($cmds);
    my $lnum=0;
    my @nlines;

    if (@$lines) {
        foreach(@$lines) {
            push @nlines, split ("\n" => $_);
        }

        foreach(@nlines) {
            chomp;

            #s/\\/\\\\/g;
            #s/"/\\"/g;
            #s/'/\\'/g;

            $_=escape('printable',$_);
            #VimMsg($_);
            
            VimCmd([
                'let line='.'"'.$_.'"',
                'let lnum='.$lnum,
                'call append(lnum,line)',
            ]);
            $lnum++;
        }
    }

}

sub VimListExtend {
    my ($vimlist,$arrayref,$opts) = @_;

    $opts ||= {};

	$opts = {
		escape => 1,
		%$opts,
	};

    for my $l (@$arrayref){
        local $_ = $l;

        unless(defined){
            $_ = '';
            if ($opts->{skip}->{undefined}) {
                next;
            }
        }

        if ($opts->{skip}->{spaces}) {
            next if /^\s*$/;
        }

		if ($opts->{escape}) {
	        s/\\/\\\\/g;
	        s/"/\\"/g;
		}

        VimLet('xx',$_);
        my $cmd = 'call add(' . $vimlist . ',xx)';
        VimCmd($cmd);
    }
}

sub VimPieceFullFile {
    my $piece = shift;

    my $path = catfile( $VDIRS{MKVIMRC}, $piece . '.vim' );

}

sub CurBufSet {
    my $ref = shift;

    my $text   = $ref->{text} || '';
    my $curbuf = $ref->{curbuf} || $CURBUF;

    my $c    = $curbuf->Count();

    my @lines;
    if (ref $text eq "ARRAY"){
        @lines=@$text;
        
    }elsif(not ref $text){
        @lines=split("\n",$text);
    }

    if (@lines) {
        $curbuf->Delete(1,$c);
        $curbuf->Append(1,@lines);
    }
}

sub VimGetLine {
    my $num=shift;

    VimLet('num',$num);

    return VimEval('getline(num)');
}

sub VimSetLine {
    my $num=shift;
    my $text=shift;

    VimLet('num',$num);
    VimLet('text',$text);

    VimCmd('call setline(num,text)');
}

sub VimAppend {
    my $num=shift;
    my $text=shift;

    VimLet('text',$text);
    VimLet('num',$num);

    VimCmd('call append(num,text)');
}


sub VimSetTags {
    my $ref = shift;

    unless ( ref $ref ) {
        VimSet( "tags", $ref );

    }
    elsif ( ref $ref eq "ARRAY" ) {
        my $first = $ref->[0];

        VimSet( "tags", join( ',', @$ref ) );
        VimLet( "g:CTAGS_CurrentTagID", '_buf_' );
        VimLet( "g:tagfile",            $first );

    }
}

=head3 VimJoin

=head4 Usage

    VimJoin( $arrname, $sep,  $vtype );

=over 4

=item Apply C<join()> on the vimscript array $arrname; returns string

=item Examples: 

=over 4

=item C<VimJoin('a:000')> - Equivalent to C<join(a:000,' ')> in vimscript

=back

=back

=cut

sub VimJoin {
    my $arr = shift;

    my $sep = shift;

    return '' unless VimExists($arr);

    ( $EvalCode, $res ) = VIM::Eval( "join($arr,'" . $sep . "')" );

    return '' unless $EvalCode;

    $res;

}

sub VimBufFiles_Edit {

    my $opts = shift;

    my $editopt = $opts->{editopt} || '';

    foreach my $bfile (@BFILES) {
        next unless $bfile =~ /\.vim$/;

        VimMsg("Processing vim file: $bfile");

        ( my $piece = $bfile ) =~ s/(\w+)\.vim/$1/g;

        my @lines = read_file $bfile;

        my %onfun;
        my $fname;
        my @nlines;

        foreach (@lines) {
            chomp;

###BufFiles_InsertSubName
            if ( $editopt == "Insert_SubName" ) {

                #/^\s*(?<fdec>fun|function)!\s+(?<fname>\w+)/ && do {
                /^\s*(fun|function)!\s+(\w+)/ && do {
                    $fname = $2;
                    $onfun{$fname} = 1;
                    $_ .= "\n" . " let g:SubName='" . $fname . "'";
                    push( @nlines, $_ );

                    next;
                };

                /^\s*let\s*g:SubName=/ && do {
                    $_ = '';
                    next;
                };
                /^\s*endf(|un|unction)/ && do {
                    $onfun{$fname} = 0 if $fname;

                };
###BufFiles_EditSlurp
            }
            elsif ( $editopt == "EditSlurp" ) {
                my $cmds = $opts->{cmds};
                foreach my $cmd (@$cmds) {
                    my $evs = $cmd;
                    eval "$evs";
                    die $@ if $@;
                }
            }

            push( @nlines, $_ );
        }
        open( F, ">$bfile" ) || die $!;
        foreach my $nline (@nlines) {
            print F $nline . "\n";
        }

        if ( $editopt == "Append_g_Loaded_Pieces" ) {
            print F "let g:LoadedPieces_$piece=1";
        }
        close(F);
    }
}

sub EnvVar {
    my ($varname,$default)=@_;

    my $env=sub { my $vname=shift; $ENV{$vname} || $default || ''; };

    my $val     = $env->($varname);
    return $val unless $val;

    if($^O eq 'MSWin32'){
        local $_=$val;
        while(/%(\w+)%/){
            my $vname = $1;
            my $vval  = $env->($vname);
            s/%(\w+)%/$vval/g;
        }
        $val=$_;
    }
    return $val;
}

sub init {

    my %opts = @_;

    $FullSubName = VimVar('g:SubName');

    ( $SubName = $FullSubName ) =~ s/^\s*_VIMPERL_//g;

    $MsgPrefix="$SubName()>> ";

    @INITIDS = qw(
      Args
      VDIRS
      PIECES
      MODULES
    );

    @BUFLIST = VIM::Buffers();

    @BFILES = ();

    foreach my $buf (@BUFLIST) {
        my $name = $buf->Name();
        $name =~ s/^\s*//g;
        $name =~ s/\s*$//g;
        push( @BFILES, $name ) if -e $name;
    }

    foreach my $id (@INITIDS) {
        eval 'init_' . $id;
        _die $@ if $@;
    }

    #$MsgColor  = VimVar("g:MsgColor");
    #$MsgPrefix = VimVar("g:MsgPrefix");
    #$MsgDebug  = VimVar("g:MsgDebug");

}

sub VimEditBufFiles {
    my $cmds = shift || $ArgString;

    unless ($cmds) {
        VimMsgE("No commands were provided");
        return 0;
    }

    my $slurpsub = shift || 'edit_file_lines';

    VimMsg("Will apply to all buffers: $cmds");

    foreach my $bfile (@BFILES) {
        VimMsg("Processing buffer: $bfile");
        my $evs = $slurpsub . ' { ' . $cmds . ' } $bfile';
        eval "$evs";
        die $@ if $@;
    }

}

sub _die {
    my $text = shift;

    die "VIMPERL_$SubName : $text";
}

=head3 init_Args

Process optional vimscript command-line arguments ( specified as ... in
vimscript function declarations )

=cut

sub init_Args {

    $NumArgs   = 0;
    $ArgString = '';
    @Args      = ();

    $NumArgs = VimLen('a:000');

    if ($NumArgs) {
        @Args = VimVar('a:000');
        $ArgString = VimJoin( 'a:000', ' ' );
    }
}

sub init_MODULES {
    @LOCALMODULES = VimVar('g:PMOD_available_mods');
}

sub init_PIECES {
    #@PIECES = readarr( catfile( $VDIRS{MKVIMRC}, qw(files.i.dat) ) );
}

sub init_VDIRS {
    %VDIRS = (
        'TAGS'       => catfile( $ENV{HOME}, 'tags' ),
        'MKVIMRC'    => catfile( $ENV{HOME}, qw( config mk vimrc ) ),
        'VIMRUNTIME' => $ENV{VIMRUNTIME},
        'PLG'        => catfile($ENV{VIMRUNTIME},qw(plg))
    );

}

###BEGIN
BEGIN {

    sub UnderVim {
        eval 'VIM::Eval("1")';
        
        my $uv = ($@) ? 0 : 1;
        return $uv;
    }

    $UnderVim=0;
    if (&UnderVim()){
        $UnderVim=1;
        init();
    }
    
}

1;
__END__

=head1 AUTHOR

Oleksandr Poplavskyy <opopl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014-2018 by Oleksandr Poplavskyy.

This is free software; you can redistribute it and/or modify it under the same
terms as the Perl 5 programming language system itself.

=cut
