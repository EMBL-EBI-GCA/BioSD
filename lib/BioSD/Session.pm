
=head1 LICENSE

   Copyright 2016 EMBL - European Bioinformatics Institute

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

    BioSD::Session

=head1 Description

    Class to perform queries against the BioSD API, maintaining a cache over entities

=cut

package BioSD::Session;

require BioSD;
use strict;
use warnings;

use BioSD::Adaptor;
use BioSD::Sample;
use Scalar::Util qw(weaken);

my $sample_cache = 'samples';
my $group_cache = 'groups';

sub new {
    my ($class) = @_;
    my $self = {
        $sample_cache => {},
        $group_cache  => {},
    };
    bless $self, $class;

    my $ref = $self;
    weaken($ref);
    $self->{_weakened_session_ref} = $ref;

    return $self;
}

=head2 fetch_sample

  Arg [1]    : string   sample_id
  Example    : $group = $session->fetch_sample('SAME123456');
  Description: Gets a sample object from the BioSamples database, or returns
               undef if sample id is not valid
  Returntype : BioSD::Sample or undef
  Exceptions : none

=cut

sub fetch_sample {
    my ( $self, $sample_id ) = @_;

    my $sample = $self->_cache( $sample_cache, $sample_id );
    return $sample if $sample;

    $sample = BioSD::Sample->new( $sample_id, $self->_weakened_session_ref );
    return undef if !$sample->is_valid;
    $self->_cache( $sample_cache, $sample_id, $sample );

    return $sample;
}

=head2 fetch_group

  Arg [1]    : string   group_id
  Example    : $group = $session->fetch_group('SAMEG123456');
  Description: Gets a BioSamples Group from the BioSamples database, or returns
               undef if group id is not valid
  Returntype : BioSD::Group or undef
  Exceptions : none

=cut

sub fetch_group {
    my ( $self, $group_id ) = @_;
    
    my $group = $self->_cache( $group_cache, $group_id );
    return $group if $group;
    
    $group = BioSD::Group->new($group_id,$self->_weakened_session_ref);
    return undef if !$group->is_valid;
    
    $self->_cache( $group_cache, $group_id, $group );
    
    
    return $group;
}

=head2 search_for_groups

  Arg [1]    : string        the search query term
  Example    : @groups = @{$session->search_for_groups('cancer')}
  Description: Gets a list of groups that match the search query
  Returntype : arrayref of BioSD::Group
  Exceptions : none

=cut

sub search_for_groups {
    my ( $self, $query ) = @_;
    my @groups =
      map { BioSD::Group->new($_,$self->_weakened_session_ref) }
      @{ BioSD::Adaptor::fetch_group_ids($query) };
    return \@groups;
}

=head2 search_for_samples

  Arg [1]    : BioSD::Group  group within which to search
  Arg [2]    : string        the search query term
  Example    : @samples = @{$session->search_for_samples($group, 'female')}
  Description: Gets a list of samples that are contained by this group and match
               the query
  Returntype : arrayref of BioSD::Sample
  Exceptions : none

=cut

sub search_for_samples {
    my ( $self, $query ) = @_;
    my @samples =
      map { BioSD::Sample->new( $_, $self->_weakened_session_ref ) }
      @{ BioSD::Adaptor::fetch_sample_ids($query) };
    return \@samples;
}

=head2 search_for_samples_in_group

  Arg [1]    : BioSD::Group  group within which to search
  Arg [2]    : string        the search query term
  Example    : @samples = @{$session->search_for_samples($group, 'female')}
  Description: Gets a list of samples that are contained by this group and match
               the query
  Returntype : arrayref of BioSD::Sample
  Exceptions : none

=cut

sub search_for_samples_in_group {
    my ( $self, $group, $query ) = @_;

    my @samples =
      map { BioSD::Sample->new( $_, $self->_weakened_session_ref ) }
      @{ BioSD::Adaptor::fetch_sample_ids_in_group( $group->id, $query ) };
    return \@samples;
}


=head2 _weakened_session_ref

  Example    : my $session = $session->_weakened_session_ref
  Description: Gets a weakened ref to this session object.
               Used to avoid circular references with the sample
               and group objects held in the cache
  Returntype : BioSD::Session
  Exceptions : none

=cut

sub _weakened_session_ref {
    my ($self) = @_;
    return $self->{_weakened_session_ref};
}

=head2 _cache

  Example    : my $group = $session->_cache('group_cache','SAMEG123456');
               $session->_cache('group_cache','SAMEG123456',$group);
  Description: Add an object to the named cache, or retrieve something from it
  Returntype : whatever you put into it, or undef
  Exceptions : none

=cut
sub _cache {
    my ( $self, $cache_name, $id, $thing ) = @_;

    if ($thing) {
        $self->{$cache_name}{$id} = $thing;
    }

    return $self->{$cache_name}{$id};
}

1;
