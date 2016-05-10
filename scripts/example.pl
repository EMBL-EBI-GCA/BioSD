#!/usr/bin/env perl

use strict;
use warnings;

use BioSD;

my $sample_id = 'SAMEA2201446';
my $sample = BioSD::fetch_sample($sample_id);
my $sample_name = $sample->property('Sample Name')->values->[0];
my $release_date = $sample->submission_release_date();
my $update_date = $sample->submission_update_date();

print "sample id is: $sample_id\n";
print "sample name is: $sample_name\n";
print "release date is: $release_date\n";
print "update date is: $update_date\n";
print "\n";

my $groups = $sample->groups;
my $num_groups = scalar @$groups;
print "sample $sample_name belongs to $num_groups groups:\n";
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
  foreach my $derivative (@{$ancester->derivatives}) {
    print $derivative->id, ": ", $derivative->property('Sample Name')->values->[0], "\n";
  }
}
print "\n";

print "sample $sample_name has the following properties:\n";
foreach my $property (@{$sample->properties}) {
  print $property->class, ' = ', join(',', @{$property->values});
  foreach my $qualified_value (@{$property->qualified_values}) {
    if (my $term_source = $qualified_value->term_source) {
      print "\t", $term_source->term_source_id;
    }
  }
  print "\tThis is a comment" if $property->is_comment;
  print "\tThis is a characteristic" if $property->is_characteristic;
  print "\n";
}
