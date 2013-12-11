#!/usr/bin/env perl

use strict;
use warnings;

use Module::Build::Pluggable ( 'CPANfile' );

my $builder = Module::Build::Pluggable->new(
    module_name => 'BioSD',
    license => 'apache',
    dist_author => 'Ian Streeter <streeter@ebi.ac.uk>',
);
$builder->create_build_script();
