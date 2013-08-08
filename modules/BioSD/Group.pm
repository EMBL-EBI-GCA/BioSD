
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

    BioSD::Group

=head1 SYNOPSIS

    my $group = BioSD::Group->new('SAMEG123456');

    # check we have used a valid group id
    if ($group->is_valid) {
      print 'BioSamples database contains a group with id SAMEG123456';
    }

    # get some information about the group
    my $properties = $group->properties; 
    my $title = $sample->property('Submission Title')->value;
    my $annotations = $group->annotations;

    # find samples contained in the group
    my $samples = $group->samples;

    # search within the group for samples of interest
    my $samples = $group->query_samples('female');

=head1 Description

    A BioSD::Group object represents all data held for a SampleGroup in the
    BioSamples database

=cut

package BioSD::Group;

use strict;
use warnings;

require BioSD;

my %cache;

=head new

  Arg [1]    : string   SampleGroup id for the BioSamples database e.g.
               'SAMEG123456'
  Example    : $group = BioSD::Group->new('SAMEG123456');
  Description: Creates a new group object.  A group object will be created for
               any id, without initially checking if that id is present in the
               BioSamples database.  If the id is not valid, errors will be
               thrown later when trying to access details of the group e.g.
               $group->properties

               Groups are automatically cached to avoid repetitive queries to
               the BioSamples database 

  Returntype : BioSD::Group
  Exceptions : throws if the BioSamples group id is not specified

=cut

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

=head id

  Arg [1]    : none
  Example    : $group_id = $group->id()
  Description: Returns the id of the group
  Returntype : string
  Exceptions : none

=cut

sub id {
  my ($self) = @_;
  return $self->{'id'};
}

=head is_valid

  Arg [1]    : none
  Example    : $is_valid = $group->is_valid()
  Description: Returns 1 if this group is present in the BioSamples database, else 0
  Returntype : int
  Exceptions : none

=cut

sub is_valid {
  my ($self) = @_;
  return 0 if $self->_query_failed;
  return 1 if defined $self->_xml_element;
  return 0;
}

=head annotations

  Arg [1]    : none
  Example    : @annotations = @{$group->annotations()}
  Description: Gets a list of annotations of this group from the BioSamples database
  Returntype : arrayref of BioSD::Annotation
  Exceptions : throws if group is not present in BioSamples database

=cut

sub annotations {
  my ($self) = @_;
  my $group_xml_element = $self->_xml_element;
  die 'No attributes for invalid Sample Group with id ' . $self->id if !$group_xml_element;
  $self->{_attributes} //= [map {BioSD::Attribute->_new($_)}
            $group_xml_element->getChildrenByTagName('Attribute')];
  return $self->{_attributes};
}

=head term_sources

  Arg [1]    : none
  Example    : @term_sources = @{$group->term_sources()}
  Description: Gets a list of term_sources asociated with this group in the
               BioSamples database
  Returntype : arrayref of BioSD::TermSource
  Exceptions : throws if group is not present in BioSamples database

=cut

sub term_sources {
  my ($self) = @_;
  my $group_xml_element = $self->_xml_element;
  die 'No term_sources for invalid Sample Group with id ' . $self->id if !$group_xml_element;
  $self->{_term_sources} //= [map {BioSD::TermSource->_new($_)}
            $group_xml_element->getChildrenByTagName('TermSource')];
  return $self->{_term_sources};
}

=head properties

  Arg [1]    : none
  Example    : @properties = @{$group->properties()}
  Description: Gets a list of properties of this group from the BioSamples database
  Returntype : arrayref of BioSD::Property
  Exceptions : throws if group is not present in BioSamples database

=cut

sub properties {
  my ($self) = @_;
  my $group_xml_element = $self->_xml_element;
  die 'No properties for invalid Sample Group with id ' . $self->id if !$group_xml_element;
  $self->{_properties} //= [map {BioSD::Property->_new($_)}
            $group_xml_element->getChildrenByTagName('Property')];
  return $self->{_properties};
}

=head organizations

  Arg [1]    : none
  Example    : @organizations = @{$group->organizations()}
  Description: Gets a list of organizations associated with this group in the
               BioSamples database
  Returntype : arrayref of BioSD::Property
  Exceptions : throws if group is not present in BioSamples database

=cut

sub organizations {
  my ($self) = @_;
  my $group_xml_element = $self->_xml_element;
  die 'No organizations for invalid Sample Group with id ' . $self->id if !$group_xml_element;
  $self->{_organizations} //= [map {BioSD::Organization->_new($_)}
            $group_xml_element->getChildrenByTagName('Organization')];
  return $self->{_organizations};
}

=head people

  Arg [1]    : none
  Example    : @people = @{$group->people()}
  Description: Gets a list of people associated with this group in the
               BioSamples database
  Returntype : arrayref of BioSD::Person
  Exceptions : throws if group is not present in BioSamples database

=cut

sub people {
  my ($self) = @_;
  my $group_xml_element = $self->_xml_element;
  die 'No people for invalid Sample Group with id ' . $self->id if !$group_xml_element;
  $self->{_people} //= [map {BioSD::TermSource->_new($_)}
            $group_xml_element->getChildrenByTagName('Person')];
  return $self->{_people};
}

=head databases

  Arg [1]    : none
  Example    : @databases = @{$group->databases()}
  Description: Gets a list of databases associated with this group in the
               BioSamples database
  Returntype : arrayref of BioSD::Database
  Exceptions : throws if group is not present in BioSamples database

=cut

sub databases {
  my ($self) = @_;
  my $group_xml_element = $self->_xml_element;
  die 'No databases for invalid Sample Group with id ' . $self->id if !$group_xml_element;
  $self->{_databases} //= [map {BioSD::Database->_new($_)}
            $group_xml_element->getChildrenByTagName('Database')];
  return $self->{_databases};
}

=head publications

  Arg [1]    : none
  Example    : @publications = @{$group->publications()}
  Description: Gets a list of publications associated with this group in the
               BioSamples database
  Returntype : arrayref of BioSD::Publication
  Exceptions : throws if group is not present in BioSamples database

=cut

sub publications {
  my ($self) = @_;
  my $group_xml_element = $self->_xml_element;
  die 'No publications for invalid Sample Group with id ' . $self->id if !$group_xml_element;
  $self->{_publications} //= [map {BioSD::Publication->_new($_)}
            $group_xml_element->getChildrenByTagName('Publication')];
  return $self->{_publications};
}

=head property

  Arg [1]    : string class
  Example    : $property = $group->property('Submission Title')
  Description: Gets a specific property of the group
  Returntype : BioSD::Property, or undef if the group has no property matching
               that class
  Exceptions : throws if group is not present in BioSamples database

=cut

sub property {
  my ($self, $class) = @_;
  return (grep {$_->class eq $class} @{$self->properties})[0];
}

=head samples

  Arg [1]    : none
  Example    : @samples = @{$group->samples()}
  Description: Gets a list of samples that are contained by this group
  Returntype : arrayref of BioSD::Sample
  Exceptions : none

=cut

sub samples {
  my ($self) = @_;
  $self->{_samples} //= BioSD::search_for_samples($self, '');
  return $self->{_samples};
}

=head search_for_samples

  Arg [1]    : string  query
  Example    : @samples = @{$group->search_for_samples('female')}
  Description: Gets a list of samples that are contained by this group and match
               the query
  Returntype : arrayref of BioSD::Sample
  Exceptions : none

=cut

sub search_for_samples {
  my ($self, $query) = @_;
  return BioSD::search_for_samples($self, $query);
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
