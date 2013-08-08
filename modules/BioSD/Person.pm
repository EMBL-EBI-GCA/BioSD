
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

    BioSD::Person

=head1 SYNOPSIS

    # fetch a person from a valid Group object
    my ($person) = @{$group->people()};

    # get some information about the organization
    my $first_name = $person->first_name(); 
    my $last_name = $person->last_name(); 
    my $mid_initials = $person->mid_initials(); 
    my $email = $person->email(); 
    my $role = $person->role(); 

=head1 Description

    A BioSD::Person object represents a person associated with a group in the
    BioSamples databases

=cut

package BioSD::Person;
use strict;
use warnings;

=head first_name

  Arg [1]    : none
  Example    : $first_name = $person->first_name()
  Description: Returns the first name of the person
  Returntype : string
  Exceptions : none

=cut

sub first_name {
  my ($self) = @_;
  my ($first_name) = map {$_->to_literal} $self->_xml_element->getChildrenByTagName('FirstName');
  return $first_name;
}

=head last_name

  Arg [1]    : none
  Example    : $last_name = $person->last_name()
  Description: Returns the last name of the person
  Returntype : string
  Exceptions : none

=cut

sub last_name {
  my ($self) = @_;
  my ($last_name) = map {$_->to_literal} $self->_xml_element->getChildrenByTagName('LastName');
  return $last_name;
}

=head mid_initials

  Arg [1]    : none
  Example    : $mid_initials = $person->mid_initials()
  Description: Returns the middle initials of the person
  Returntype : string or undefined
  Exceptions : none

=cut

sub mid_initials {
  my ($self) = @_;
  my ($mid_initials) = map {$_->to_literal} $self->_xml_element->getChildrenByTagName('MidInitials');
  return $mid_initials;
}

=head email

  Arg [1]    : none
  Example    : $email = $person->email()
  Description: Returns the email of the person
  Returntype : string or undefined
  Exceptions : none

=cut

sub email {
  my ($self) = @_;
  my ($email) = map {$_->to_literal} $self->_xml_element->getChildrenByTagName('Email');
  return $email;
}

=head role

  Arg [1]    : none
  Example    : $role = $person->role()
  Description: Returns the role of the person
  Returntype : string or undefined
  Exceptions : none

=cut

sub role {
  my ($self) = @_;
  my ($role) = map {$_->to_literal} $self->_xml_element->getChildrenByTagName('Role');
  return $role;
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
