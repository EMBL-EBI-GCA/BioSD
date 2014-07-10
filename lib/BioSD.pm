
=head1 LICENSE

   Copyright 2013 EMBL - European Bioinformatics Institute

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

=cut

package BioSD;

=head1 NAME

BioSD - Programmatic access to BioSD from EBI

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use BioSD;

    my $sample = BioSD::fetch_sample('SAME123456');
    my $group = BioSD::fetch_group('SAMEG123456');

    my ($cancer_group) = @{BioSD::search_for_groups('cancer')};
    my ($female_sample) = @{BioSD::search_for_samples($cancer_group, 'female');

=head1 Description

    Your script can 'use' this module to get all the functionality of the BioSD
    API

=cut


use strict;
use warnings;

use LWP::UserAgent;
use XML::LibXML;

require BioSD::Adaptor;
require BioSD::Annotation;
require BioSD::Database;
require BioSD::Group;
require BioSD::Organization;
require BioSD::Person;
require BioSD::Property;
require BioSD::Publication;
require BioSD::QualifiedValue;
require BioSD::Sample;
require BioSD::TermSource;
require BioSD::XPathContext;


=head2 BioSD::root_url

  Description: Package variable set to http://www.ebi.ac.uk/biosamples/xml
               It is unlikely you will want to change this variable
  Example    : $BioSD::root_utl = 'http://www.somewhere_else.com/'

=cut

our $root_url = 'http://www.ebi.ac.uk/biosamples/xml';

=head2 BioSD::query_pagesize

  Description: Package variable set to 500. It is unlikely you will want to
               change this variable
               When querying the database, samples and groups will be returned
               in batches of this size. The perl BioSD API always combines the
               batches to return all possible results
  Example    : $BioSD::query_pagesize = 200;

=cut

our $query_pagesize = 500;

=head2 fetch_sample

  Arg [1]    : string   sample_id
  Example    : $group = BioSD::fetch_sample('SAME123456');
  Description: Gets a sample object from the BioSamples database, or returns
               undef if sample id is not valid
  Returntype : BioSD::Sample or undef
  Exceptions : none

=cut

sub fetch_sample {
  my ($sample_id) = @_;
  my $sample = BioSD::Sample->new($sample_id);
  return undef if ! $sample->is_valid;
  return $sample;
}

=head2 fetch_group

  Arg [1]    : string   group_id
  Example    : $group = BioSD::fetch_group('SAMEG123456');
  Description: Gets a BioSamples Group from the BioSamples database, or returns
               undef if group id is not valid
  Returntype : BioSD::Group or undef
  Exceptions : none

=cut

sub fetch_group {
  my ($group_id) = @_;
  my $group = BioSD::Group->new($group_id);
  return undef if ! $group->is_valid;
  return $group;
}

=head2 search_for_groups

  Arg [1]    : string        the search query term
  Example    : @groups = @{BioSD::search_for_groups('cancer')}
  Description: Gets a list of groups that match the search query
  Returntype : arrayref of BioSD::Group
  Exceptions : none

=cut

sub search_for_groups {
  my ($query) = @_;
  my @groups = map {BioSD::Group->new($_)} @{BioSD::Adaptor::fetch_group_ids($query)};
  return \@groups;
}

=head2 search_for_samples

  Arg [1]    : BioSD::Group  group within which to search
  Arg [2]    : string        the search query term
  Example    : @samples = @{BioSD::search_for_samples($group, 'female')}
  Description: Gets a list of samples that are contained by this group and match
               the query
  Returntype : arrayref of BioSD::Sample
  Exceptions : none

=cut

sub search_for_samples {
  my ($group, $query) = @_;
  my @samples = map {BioSD::Sample->new($_)} @{BioSD::Adaptor::fetch_sample_ids($group->id, $query)};
  return \@samples;
}


1;
