package Base::Const;

use strict;
use warnings;

use base 'Exporter';

our @EXPORT_OK = qw(
	EXE_DUMP_HTML
);

use constant { 
	EXE_DUMP_HTML => 
		join(' ',qw{ 
			links 
			-codepage utf8
			-dump 
			-force-html 
			-html-tables 1 
		})
};



1;
 

