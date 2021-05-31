#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

    our $styles = {
      'detail_copy' => {
           'color'       => '#392720',
           'font-family' => q{'HelveticaNeueLTStd45Light','Helvetica Neue',Helvetica,Arial,Sans-Serif},
           'font-size'   => '15px', 
           'font-style'  => 'normal', 
           'font-weight' => 'normal',
           'padding-bottom' => '0px',
           'text-align' => 'left',
      }
    
    };

    sub get_style {
      my ($key) = @_;
      my $css = $styles->{$key} || {};

      my $style = join ';', map { join(':', $_, $css->{$_}) } sort keys %$css;

      return $style;
    };

	print get_style('detail_copy') . "\n";
