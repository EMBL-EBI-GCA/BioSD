
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

package BioSD::TermSource;
use strict;
use warnings;

=head1 NAME

    BioSD::TermSource

=head1 SYNOPSIS

    # fetch a term source from a valid Group object or Property object
    my ($term_source) = @{$group->term_sources()};
    my $term_source = $property->term_source();

    # get some information about the term source
    my $version = $term_source->version(); 
    my $uri = $term_source->uri(); 
    my $term_source_id = $term_source->term_source_id(); 
    my $description = $term_source->description(); 
    my $name = $term_source->name(); 

=head1 Description

    A BioSD::TermSource object describes the source of the term used to describe
    a Property in the BioSamples database e.g. an ontology

=cut

=head version

  Arg [1]    : none
  Example    : $version = $term_source->version()
  Description: Returns the version of the term_source
  Returntype : string or undefined
  Exceptions : none

=cut

sub version {
  my ($self) = @_;
  my ($version) = map {$_->to_literal} $self->_xml_element->getChildrenByTagName('Version');
  return $version;
}

=head uri

  Arg [1]    : none
  Example    : $uri = $term_source->uri()
  Description: Returns the uri associated with the term_source
  Returntype : string or undefined
  Exceptions : none

=cut

sub uri {
  my ($self) = @_;
  my ($uri) = map {$_->to_literal} $self->_xml_element->getChildrenByTagName('URI');
  return $uri;
}

=head term_source_id

  Arg [1]    : none
  Example    : $term_source_id = $term_source->term_source_id()
  Description: Returns the id associated with the term in the term source (e.g.
               an onotology id)
  Returntype : string or undefined
  Exceptions : none

=cut

sub term_source_id {
  my ($self) = @_;
  my ($term_source_id) = map {$_->to_literal} $self->_xml_element->getChildrenByTagName('TermSourceID');
  return $term_source_id;
}

=head description

  Arg [1]    : none
  Example    : $description = $term_source->description()
  Description: Returns a description of the term source
  Returntype : string or undefined
  Exceptions : none

=cut

sub description {
  my ($self) = @_;
  my ($description) = map {$_->to_literal} $self->_xml_element->getChildrenByTagName('Description');
  return $description;
}

=head name

  Arg [1]    : none
  Example    : $name = $term_source->name()
  Description: Returns the name of the term source
  Returntype : string
  Exceptions : none

=cut

sub name {
  my ($self) = @_;
  my ($name) = map {$_->to_literal} $self->_xml_element->getChildrenByTagName('Name');
  return $name;
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
