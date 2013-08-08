
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

package BioSD::Organization;
use strict;
use warnings;

=head1 NAME

    BioSD::Organization

=head1 SYNOPSIS

    # fetch an organization from a valid Group object
    my ($organization) = @{$group->organizations()};

    # get some information about the organization
    my $address = $organization->address(); 
    my $uri = $organization->uri(); 
    my $email = $organization->email(); 
    my $role = $organization->role(); 
    my $name = $organization->name(); 

=head1 Description

    A BioSD::Organization object represents an organization associated with a
    group in the BioSamples databases

=cut


=head address

  Arg [1]    : none
  Example    : $address = $organization->address()
  Description: Returns the address of the organization
  Returntype : string or undefined
  Exceptions : none

=cut

sub address {
  my ($self) = @_;
  my ($address) = map {$_->to_literal} $self->_xml_element->getChildrenByTagName('Address');
  return $address;
}

=head uri

  Arg [1]    : none
  Example    : $uri = $organization->uri()
  Description: Returns the uri associated with the organization
  Returntype : string or undefined
  Exceptions : none

=cut

sub uri {
  my ($self) = @_;
  my ($uri) = map {$_->to_literal} $self->_xml_element->getChildrenByTagName('URI');
  return $uri;
}

=head email

  Arg [1]    : none
  Example    : $email = $organization->email()
  Description: Returns the email associated with the organization
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
  Example    : $rold = $organization->rold()
  Description: Returns the role of the organization
  Returntype : string or undefined
  Exceptions : none

=cut

sub role {
  my ($self) = @_;
  my ($role) = map {$_->to_literal} $self->_xml_element->getChildrenByTagName('Role');
  return $role;
}

=head name

  Arg [1]    : none
  Example    : $name = $organization->name()
  Description: Returns the name associated with the organization
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
