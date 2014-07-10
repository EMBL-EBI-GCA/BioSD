
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

    BioSD::QualifiedValue

=head1 SYNOPSIS

    # fetch a qualified value from a valid Property object
    my ($qualified_value) = @{$property->qualified_value()};

    # get some information about the qualified value
    my $value = $qualified_value->value(); 
    my $unit = $qualified_value->unit(); 
    my $term_source = $qualified_value->term_source(); 

=head1 Description

    A BioSD::QualifiedValue object represents a value associated with a property
    in the BioSamples databases

=cut


package BioSD::QualifiedValue;
use strict;
use warnings;

=head value

  Arg [1]    : none
  Example    : $value = $qualified_value->value()
  Description: Returns the liberal value of the qualified_value
  Returntype : string
  Exceptions : none

=cut

sub value {
  my ($self) = @_;
  return BioSD::XPathContext::findvalue('./SG:Value', $self->_xml_element);
}

=head unit

  Arg [1]    : none
  Example    : $unit = $qualified_value->unit()
  Description: Returns the unit of the qualified_value
  Returntype : string or undefined
  Exceptions : none

=cut

sub unit {
  my ($self) = @_;
  return BioSD::XPathContext::findvalue('./SG:Unit', $self->_xml_element);
}

=head term_source

  Arg [1]    : none
  Example    : $term_sources = $qualified_value->term_source()
  Description: Gets a term_source asociated with this qualified value in the
               BioSamples database
  Returntype : BioSD::TermSource or undef
  Exceptions : none

=cut

sub term_source {
  my ($self) = @_;
  my $group_xml_element = $self->_xml_element;
  if (! $self->{_term_source}) {
    my ($term_source_xml_element) = $self->_xml_element->getChildrenByTagName('TermSourceREF');
    if ($term_source_xml_element) {
      $self->{_term_source} = BioSD::TermSource->_new($term_source_xml_element);
    }
  }
  return $self->{_term_source};
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
