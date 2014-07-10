#!/usr/bin/env perl

use strict;
use warnings;

use BioSD;

my $sample_id = 'SAMEA1603480';
my $sample = BioSD::fetch_sample($sample_id);
my $sample_name = $sample->property('Sample Name')->values->[0];

print "sample id is: $sample_id\n";
print "sample name is: $sample_name\n";
print "\n";

my $groups = $sample->groups;
my $num_groups = scalar @$groups;
print "sample belongs to $num_groups groups:\n";
foreach my $group (@$groups) {
  print $group->id, ": ", $group->property('Submission Title')->values->[0], "\n";
}
print "\n";


my $derived_from = $sample->derived_from;
my $num_derived_from = scalar @$derived_from;
print "sample was derived from $num_derived_from other samples:\n";
foreach my $ancester (@$derived_from) {
  print $ancester->id, ": ", $ancester->property('Sample Name')->values->[0], "\n";
}
print "\n";


foreach my $ancester (@{$sample->derived_from}) {
  print "The following samples were also derived from ", $ancester->id, ":\n";
  print join(', ', map {$_->id} @{$ancester->derivatives}), "\n";
}
