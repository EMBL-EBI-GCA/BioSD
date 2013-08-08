
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

    BioSD::Annotation

=head1 SYNOPSIS

    # fetch annotations from a valid Sample object or Group object
    my @sample_annotations = @{$sample->annotations()};
    my @group_annotations = @{$group->annotations()};

    # get some information about the annotation
    my $type = $annotation->type(); 
    my $value = $annotation->to_string()

=head1 Description

    A BioSD::Annotation object represents a piece of data held for a Sample or a
    Group in the BioSamples database

=cut

package BioSD::Annotation;
use strict;
use warnings;

=head to_string

  Arg [1]    : none
  Example    : $value = $annotation->to_string()
  Description: Returns the literal value of the annotation
  Returntype : string
  Exceptions : none

=cut

sub to_string {
  my ($self) = @_;
  return $self->_xml_element->to_literal;
}

=head type

  Arg [1]    : none
  Example    : $type = $annotation->type()
  Description: Returns the type describing the annotation
  Returntype : string
  Exceptions : none

=cut

sub type {
  my ($self) = @_;
  return $self->_xml_element->getAttribute('type');
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
