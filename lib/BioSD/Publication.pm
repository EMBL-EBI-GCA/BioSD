
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

=head1 NAME

    BioSD::Publication

=head1 SYNOPSIS

    # fetch a publication from a valid Group object
    my ($publication) = @{$group->publications()};

    # get some information about the publication
    my $doi = $publication->doi(); 
    my $pubmed_id = $publication->pubmed_id(); 

=head1 Description

    A BioSD::Publication object represents a publication associated with a group
    in the BioSamples databases

=cut


package BioSD::Publication;
use strict;
use warnings;

=head doi

  Arg [1]    : none
  Example    : $doi = $publication->doi()
  Description: Returns the doi (digital object identifier) of the
               publication
  Returntype : string or undefined
  Exceptions : none

=cut

sub doi {
  my ($self) = @_;
  return BioSD::XPathContext::findvalue('./SG:DOI', $self->_xml_element);
}

=head pubmed_id

  Arg [1]    : none
  Example    : $pubmed_id = $publication->pubmed_id()
  Description: Returns the pubmed_id of the publication
  Returntype : string or undefined
  Exceptions : none

=cut

sub pubmed_id {
  my ($self) = @_;
  return BioSD::XPathContext::findvalue('./SG:PubMedID', $self->_xml_element);
}

sub _new{
  my ($class, $xml_element) = @_;
  my $self = {};
  bless $self, $class;

  $self->_xml_element($xml_element);
  return $self;
}

sub _xml_element {
  my ($self, $xml_element) = @_;
  if ($xml_element) {
    $self->{_xml_element} = $xml_element;
  }
  return $self->{_xml_element};
}


1;
