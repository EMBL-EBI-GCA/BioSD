
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

    BioSD::Sample

=head1 SYNOPSIS

    my $sample = BioSD::Sample->new('SAME123456');

    # check we have used a valid sample id
    if ($sample->is_valid) {
      print 'BioSamples database contains a sample with id SAME123456';
    }

    # get some information about the sample
    my $properties = $sample->properties; 
    my $age = $sample->property('age')->value;
    my $annotations = $sample->annotations;

    # find groups containing the sample
    my $groups = $sample->groups;

    # find which samples it was derived from
    my $ancestors = $sample->derived_from;

    # find which samples were derived from it
    my $descendents = $sample->derivatives;

=head1 Description

    A BioSD::Sample object represents all data held for a sample in the
    BioSamples database

=cut

package BioSD::Sample;
use strict;
use warnings;

require BioSD;

my %cache;

=head new

  Arg [1]    : string   sample id for the BioSamples database e.g. 'SAME123456'
  Example    : $sample = BioSD::Sample->new('SAME123456');
  Description: Creates a new sample object.  A sample object will be created for
               any id, without initially checking if that id is present in the
               BioSamples database.  If the id is not valid, errors will be
               thrown later when trying to access details of the sample e.g.
               $sample->properties

               Samples are automatically cached to avoid repetitive queries to
               the BioSamples database 

  Returntype : BioSD::Sample
  Exceptions : throws if the BioSamples id is not specified

=cut

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

=head id

  Arg [1]    : none
  Example    : $sample_id = $sample->id()
  Description: Returns the id of the sample
  Returntype : string
  Exceptions : none

=cut


sub id {
  my ($self) = @_;
  return $self->{_id};
}

=head is_valid

  Arg [1]    : none
  Example    : $is_valid = $sample->is_valid()
  Description: Returns 1 if this sample is present in the BioSamples database, else 0
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
  Example    : @annotations = @{$sample->annotations()}
  Description: Gets a list of annotations of this sample from the BioSamples database
  Returntype : arrayref of BioSD::Annotation
  Exceptions : throws if sample is not present in BioSamples database

=cut

sub annotations {
  my ($self) = @_;
  my $sample_xml_element = $self->_xml_element;
  die 'No annotations for invalid Sample with id ' . $self->id if !$sample_xml_element;
  $self->{_annotations} //= [map {BioSD::Annotation->_new($_)}
            $self->_xml_element->getChildrenByTagName('Annotation')];
  return $self->{_annotations};
}

=head properties

  Arg [1]    : none
  Example    : @properties = @{$sample->properties()}
  Description: Gets a list of properties of this sample from the BioSamples database
  Returntype : arrayref of BioSD::Property
  Exceptions : throws if sample is not present in BioSamples database

=cut

sub properties {
  my ($self) = @_;
  my $sample_xml_element = $self->_xml_element;
  die 'No properties for invalid Sample with id ' . $self->id if !$sample_xml_element;
  $self->{_properties} //= [map {BioSD::Property->_new($_)}
            $self->_xml_element->getChildrenByTagName('Property')];
  return $self->{_properties};
}

=head derived_from

  Arg [1]    : none
  Example    : @ancestors = @{$sample->derived_from()}
  Description: Gets a list of samples from which this sample was derived
  Returntype : arrayref of BioSD::Sample
  Exceptions : throws if sample is not present in BioSamples database

=cut

sub derived_from {
  my ($self) = @_;
  my $sample_xml_element = $self->_xml_element;
  die 'No derived from for invalid Sample with id ' . $self->id if !$sample_xml_element;
  if (!$self->{_derived_from}) {
    my @ancester_ids = map {$_->to_literal} $self->_xml_element->getChildrenByTagName('derivedFrom');
    if (my $derived_from_property = $self->property('Derived From')) {
      push(@ancester_ids, split(',', $derived_from_property->value));
    }
    $self->{_derived_from} = [map {BioSD::Sample->new($_)} @ancester_ids];
  }
  return $self->{_derived_from};
}

=head derived_from

  Arg [1]    : none
  Example    : @descendents = @{$sample->derivatives()}
  Description: Gets a list of samples which were derived from this sample
  Returntype : arrayref of BioSD::Sample
  Exceptions : throws if sample is not present in BioSamples database

=cut

sub derivatives {
  my ($self) = @_;
  my $sample_xml_element = $self->_xml_element;
  die 'No derivatives for invalid Sample with id ' . $self->id if !$sample_xml_element;
  if (!$self->{_derivatives}) {
    my @derivatives;
    my $self_id = $self->id;
    #foreach my $group (map {BioSD::Group->new($_)} @{BioSD::Adaptor::query_groups($self_id)}) {
    foreach my $group (@{BioSD::search_for_groups($self_id)}) {
      SAMPLE:
      #foreach my $sample (map {BioSD::Sample->new($_)} @{BioSD::Adaptor::query_samples($group->id, $self_id)}) {
      foreach my $sample (@{BioSD::search_for_samples($group, $self_id)}) {
        next SAMPLE if ! grep {$self_id eq $_->id} @{$sample->derived_from};
        push(@derivatives, $sample);
      }
    }
    $self->{_derivatives} = \@derivatives;
  }
  return $self->{_derivatives};
}

=head property

  Arg [1]    : string class
  Example    : $property = $sample->property('age')
  Description: Gets a specific property of the sample
  Returntype : BioSD::Property, or undef if the sample has no property matching
               that class
  Exceptions : throws if sample is not present in BioSamples database

=cut

sub property {
  my ($self, $class) = @_;
  return (grep {$_->class eq $class} @{$self->properties})[0];
}

=head groups

  Arg [1]    : none
  Example    : @groups = @{$sample->groups()}
  Description: Gets a list of groups that contain this sample
  Returntype : arrayref of BioSD::Group
  Exceptions : none

=cut

sub groups {
  my ($self) = @_;
  if (! $self->{_groups}) {
    my @groups;
    my $self_id = $self->id;
    foreach my $group (@{BioSD::search_for_groups($self_id)}) {
      if (grep {$_->id eq $self_id} @{$group->samples}) {
        push(@groups, $group);
      }
    }
    $self->{_groups} = \@groups;
  }
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
