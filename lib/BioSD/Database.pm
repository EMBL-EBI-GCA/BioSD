
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

    BioSD::Database

=head1 SYNOPSIS

    # fetch a database from a valid Group object
    my ($database) = @{$group->databases()};

    # get some information about the database
    my $id = $database->id(); 
    my $uri = $database->uri(); 
    my $name = $database->name(); 

=head1 Description

    A BioSD::Database object represents an external database associated with a
    group in the BioSamples databases

=cut

package BioSD::Database;
use strict;
use warnings;

=head id

  Arg [1]    : none
  Example    : $id = $database->id()
  Description: Returns the external database id corresponding to the BioSamples
               group
  Returntype : string
  Exceptions : none

=cut

sub id {
  my ($self) = @_;
  my ($id) = map {$_->to_literal} $self->_xml_element->getChildrenByTagName('ID');
  return $id;
}

=head uri

  Arg [1]    : none
  Example    : $uri = $database->uri()
  Description: Returns a uri for the external database corresponding to the
               BioSamples group
  Returntype : string or undefined
  Exceptions : none

=cut

sub uri {
  my ($self) = @_;
  my ($uri) = map {$_->to_literal} $self->_xml_element->getChildrenByTagName('URI');
  return $uri;
}

=head name

  Arg [1]    : none
  Example    : $name = $database->name()
  Description: Returns a name for the external database entry corresponding to
               the BioSamples group
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
