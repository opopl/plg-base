#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);
use DateTime;
use Date::Manip;

#'pickup_deadline_dt' => '2022-02-04T11:50:00.000Z'
#'pickup_ready_dt' => '2022-02-04T09:50:00.000Z'

my $date = '2022-02-04T11:50:00.000Z';

my $dm = Date::Manip::Date->new;
my $dt = $dm->new_date;

# Текущее локальное время. Только через парсинг.
$dt->parse('now');

## Текущее время UTC
#$dt->parse('now gmt');

## Время в заданной зоне
#$date->parse('now gtm+10');

## Парсинг строки (ISO8601)
$dt->parse($date);
