
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

package BioSD::Group;

use strict;
use warnings;

use BioSD::Sample;
use BioSD::Adaptor;
use BioSD::Property;
use BioSD::TermSourceREF;
use BioSD::Database;

my %cache;

sub new{
  my ($class, $id) = @_;
  die 'A BioSD::Group must have an id' if ! $id;
  if (my $cached = $cache{$id}) {
    return $cached;
  }
  my $self = {};
  bless $self, $class;

  $self->{'id'} = $id;
  $cache{$id} = $self;
  return $self;
}

sub id {
  my ($self) = @_;
  return $self->{'id'};
}

sub is_valid {
  my ($self) = @_;
  return 0 if $self->_query_failed;
  return 1 if defined $self->_xml_element;
  return 0;
}

sub annotations {
  my ($self) = @_;
  my $group_xml_element = $self->_xml_element;
  die 'No attributes for invalid Sample Group with id ' . $self->id if !$group_xml_element;
  $self->{_attributes} //= [map {BioSD::Attribute->new($_)}
            $group_xml_element->getChildrenByTagName('Attribute')];
  return $self->{_attributes};
}

sub term_sources {
  my ($self) = @_;
  my $group_xml_element = $self->_xml_element;
  die 'No term_sources for invalid Sample Group with id ' . $self->id if !$group_xml_element;
  $self->{_term_sources} //= [map {BioSD::TermSourceREF->new($_)}
            $group_xml_element->getChildrenByTagName('TermSource')];
  return $self->{_term_sources};
}

sub properties {
  my ($self) = @_;
  my $group_xml_element = $self->_xml_element;
  die 'No properties for invalid Sample Group with id ' . $self->id if !$group_xml_element;
  $self->_properties //= [map {BioSD::Property->new($_)}
            $group_xml_element->getChildrenByTagName('Property')];
  return $self->{_properties};
}

sub organizations {
  my ($self) = @_;
  my $group_xml_element = $self->_xml_element;
  die 'No organizations for invalid Sample Group with id ' . $self->id if !$group_xml_element;
  $self->{_organizations} //= [map {BioSD::Organization->new($_)}
            $group_xml_element->getChildrenByTagName('Organization')];
  return $self->{_organizations};
}

sub people {
  my ($self) = @_;
  my $group_xml_element = $self->_xml_element;
  die 'No people for invalid Sample Group with id ' . $self->id if !$group_xml_element;
  $self->{_people} //= [map {BioSD::TermSourceREF->new($_)}
            $group_xml_element->getChildrenByTagName('Person')];
  return $self->{_people};
}

sub databases {
  my ($self) = @_;
  my $group_xml_element = $self->_xml_element;
  die 'No databases for invalid Sample Group with id ' . $self->id if !$group_xml_element;
  $self->{_databases} //= [map {BioSD::Database->new($_)}
            $group_xml_element->getChildrenByTagName('Database')];
  return $self->{_databases};
}

sub publications {
  my ($self) = @_;
  my $group_xml_element = $self->_xml_element;
  die 'No publications for invalid Sample Group with id ' . $self->id if !$group_xml_element;
  $self->{_publications} //= [map {BioSD::TermSourceREF->new($_)}
            $group_xml_element->getChildrenByTagName('Publication')];
  return $self->{_publications};
}


sub property {
  my ($self, $class) = @_;
  return (grep {$_->class eq $class} @{$self->properties})[0];
}

sub samples {
  my ($self) = @_;
  $self->{_samples} //= [map {BioSD::Sample->new($_)} @{BioSD::Adaptor::query_samples($self->id, '')}];
  return $self->{_samples};
}

sub query_samples {
  my ($self, $query) = @_;
  return [map {BioSD::Sample->new($_)} @{BioSD::Adaptor::query_samples($self->id, $query)}];
}


sub _xml_element {
  my ($self) = @_;
  return $self->{_xml_element} if defined $self->{_xml_element};
  return undef if $self->_query_failed;

  my $xml_element = BioSD::Adaptor::fetch_group_element($self->id);
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
