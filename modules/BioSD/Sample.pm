
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

package BioSD::Sample;
use strict;
use warnings;

use BioSD::Property;
use BioSD::Adaptor;
use BioSD::Group;

my %cache;

sub new{
  my ($class, $id) = @_;
  die 'A BioSD::Sample must have an id' if ! $id;
  if (my $cached = $cache{$id}) {
    return $cached;
  }
  my $self = {};
  bless $self, $class;

  $self->{_id} = $id;
  $cache{$id} = $self;
  return $self;
}

sub id {
  my ($self) = @_;
  return $self->{_id};
}

sub is_valid {
  my ($self) = @_;
  return 0 if $self->_query_failed;
  return 1 if defined $self->_xml_element;
  return 0;
}

sub properties {
  my ($self) = @_;
  my $sample_xml_element = $self->_xml_element;
  die 'No properties for invalid Sample with id ' . $self->id if !$sample_xml_element;
  $self->_properties //= [map {BioSD::Property->new($_)}
            $self->_xml_element->getChildrenByTagName('Property')];
  return $self->{_properties};
}

sub property {
  my ($self, $class) = @_;
  return (grep {$_->class eq $class} @{$self->properties})[0];
}

sub groups {
  my ($self) = @_;
  $self->{_groups} //= [map {BioSD::Group->new($_)} @{BioSD::Adaptor::query_groups($self->id)}];
  return $self->{_groups};
}


sub _xml_element {
  my ($self) = @_;
  return $self->{_xml_element} if defined $self->{_xml_element};
  return undef if $self->_query_failed;

  my $xml_element = BioSD::Adaptor::fetch_sample_element($self->id);
  if (!defined $xml_element) {
    $self->_query_failed(1);
    return undef;
  }
  $self->{_xml_element} = $xml_element;
  return $xml_element;
}

sub _query_failed {
  my ($self, $query_failed) = @_;
  if ($query_failed) {
    $self->{_query_failed} = 1;
  }
  return $self->{_query_failed};
}


1;
