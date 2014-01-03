
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

    BioSD::Property

=head1 SYNOPSIS

    # fetch a property from a valid Sample object or Group object
    my $age = $sample->property('age');
    my $title = $group->property('Submission Title');

    # get some information about the property
    my $type = $property->type(); 
    my $value = $property->value(); 
    my $is_characteristic = $property->is_characteristic(); 
    my $is_comment = $property->is_comment(); 
    my $type = $property->type(); 
    my $unit = $property->unit(); 
    my $term_source = $property->term_source(); 

=head1 Description

    A BioSD::Property object represents a piece of data held for a Sample or a
    Group in the BioSamples database

=cut

package BioSD::Property;
use strict;
use warnings;

require BioSD;

=head values

  Arg [1]    : none
  Example    : @values = @{$property->value()}
  Description: Returns the literal values of the property
               Identical to [map {$_->value} @{$property->qualified_values()}]
  Returntype : arrayref of strings
  Exceptions : none

=cut

sub values {
  my ($self) = @_;
  return [map {$_->value} @{$self->qualified_values()}];
}

=head is_comment

  Arg [1]    : none
  Example    : $is_comment = $property->is_comment()
  Description: Returns 1 if this property is a comment, else 0
  Returntype : int
  Exceptions : none

=cut

sub is_comment {
  my ($self) = @_;
  my $is_comment = $self->_xml_element->getAttribute('comment');
  return 0 if ! $is_comment;
  return 1;
}

=head class

  Arg [1]    : none
  Example    : $class = $property->class()
  Description: Each property of an object is uniquely defined by its class, e.g.
               'age' or 'Submission Version'
  Returntype : string
  Exceptions : none

=cut

sub class {
  my ($self) = @_;
  return $self->_xml_element->getAttribute('class');
}

=head type

  Arg [1]    : none
  Example    : $type = $property->type()
  Description: Describes the type of the property value e.g. 'STRING' or
               'BOOLEAN'
  Returntype : string
  Exceptions : none

=cut

sub type {
  my ($self) = @_;
  return $self->_xml_element->getAttribute('type');
}

=head is_characteristic

  Arg [1]    : none
  Example    : $is_characteristic = $property->is_characteristic()
  Description: Returns 1 if this property is a characteristic, else 0
  Returntype : int
  Exceptions : none

=cut

sub is_characteristic {
  my ($self) = @_;
  my $is_characteristic = $self->_xml_element->getAttribute('characteristic');
  return 0 if ! $is_characteristic;
  return 1;
}

=head qualified_values

  Arg [1]    : none
  Example    : @qualified_values = @{$property->qualified_value()}
  Description: Gets a list of qualified values for this property
  Returntype : arrayref of BioSD::QualifiedValue
  Exceptions : none

=cut

sub qualified_values {
  my ($self) = @_;
  $self->{_qualified_values} //= [map {BioSD::QualifiedValue->_new($_)}
            $self->_xml_element->getChildrenByTagName('QualifiedValue')];
  return $self->{_qualified_values};
}

sub _xml_element {
  my ($self, $xml_element) = @_;
  if ($xml_element) {
    $self->{_xml_element} = $xml_element;
  }
  return $self->{_xml_element};
}

sub _new{
  my ($class, $xml_element) = @_;
  my $self = {};
  bless $self, $class;

  $self->_xml_element($xml_element);
  return $self;
}


1;
