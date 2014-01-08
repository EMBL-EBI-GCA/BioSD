
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

=pod

=head1 NAME

    BioSD::XPathContext

=head1 Description

    Utility package to help BioSD API interpret xml

    Intended only for internal use by other BioSD packages.

=cut

package BioSD::XPathContext;

require BioSD;
use strict;
use warnings;

my $sample_group_nsuri = 'http://www.ebi.ac.uk/biosamples/SampleGroupExport/1.0';
my $result_query_nsuri = 'http://www.ebi.ac.uk/biosamples/ResultQuery/1.0';
my $xc = XML::LibXML::XPathContext->new();
$xc->registerNs('SG', $sample_group_nsuri);
$xc->registerNs('RQ', $result_query_nsuri);

sub findvalue {
  my ($xpath, $element) = @_;
  return $xc->findvalue($xpath, $element);
}

sub findnodes {
  my ($xpath, $element) = @_;
  return $xc->findnodes($xpath, $element);
}

sub find {
  my ($xpath, $element) = @_;
  return $xc->find($xpath, $element);
}

sub exists {
  my ($xpath, $element) = @_;
  return $xc->exists($xpath, $element);
}

1;
