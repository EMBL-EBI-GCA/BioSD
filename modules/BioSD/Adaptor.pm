
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

    BioSD::Adaptor

=head1 Description

    Utility package to help BioSD API query the BioSamples database

    Intended only for internal use by other BioSD packages.

=cut

package BioSD::Adaptor;

require BioSD;
use strict;
use warnings;

my $ua = LWP::UserAgent->new;

sub fetch_sample_element {
  my ($sample_id) = @_;
  my $location = "$BioSD::root_url/sample/$sample_id";
  my $response = $ua->get($location);
  die $response->status_line if $response->is_error;
  return undef if ($response->content !~ /^<[^<>]*><BioSample/);
  return XML::LibXML->load_xml( string => $response->content)->getDocumentElement;
}

sub fetch_group_element {
  my ($group_id) = @_;
  my $location = "$BioSD::root_url/group/$group_id";
  my $response = $ua->get($location);
  die $response->status_line if $response->is_error;
  return undef if ($response->content !~ /^<[^<>]*><BioSampleGroup/);
  return XML::LibXML->load_xml( string => $response->content)->getDocumentElement;
}

sub fetch_groupsamples_query_element {
  my ($group_id, $query, $page) = @_;
  my $location = "$BioSD::root_url/groupsamples/$group_id/query=";
  $location .= $query;
  $location .= "&page=$page" if defined $page;
  $location .= "&pagesize=$BioSD::query_pagesize";
  my $response = $ua->get($location);
  die $response->status_line if $response->is_error;
  return XML::LibXML->load_xml( string => $response->content)->getDocumentElement;
}

sub fetch_group_query_element {
  my ($query, $page) = @_;
  my $location = "$BioSD::root_url/group/query=";
  $location .= $query if $query;
  $location .= "&page=$page" if defined $page;
  $location .= "&pagesize=$BioSD::query_pagesize";
  my $response = $ua->get($location);
  die $response->status_line if $response->is_error;
  return XML::LibXML->load_xml( string => $response->content)->getDocumentElement;
}

sub fetch_sample_ids {
  my ($group_id, $query) = @_;
  my @sample_ids;
  my $page = 1;
  my $total;
  PAGE:
  while (1) {
    my $query_element = fetch_groupsamples_query_element($group_id, $query, $page);
    push(@sample_ids, map {$_->to_literal} $query_element->findnodes('./BioSample/@id'));
    $total //= $query_element->findvalue('./SummaryInfo/Total');
    last PAGE if $total <= $page*$BioSD::query_pagesize;
    $page += 1;
  }
  return \@sample_ids;
}

sub fetch_group_ids {
  my ($query) = @_;
  if (!$query) {
    warn('BioSD: Call to fetch_group_ids with an empty query is returning EVERY Biosamples group in the database');
  }
  my @group_ids;
  my $page = 1;
  my $total;
  PAGE:
  while (1) {
    my $query_element = fetch_group_query_element($query, $page);
    push(@group_ids, map {$_->to_literal} $query_element->findnodes('./BioSampleGroup/@id'));
    $total //= $query_element->findvalue('./SummaryInfo/Total');
    last PAGE if $total <= $page*$BioSD::query_pagesize;
    $page += 1;
  }
  return \@group_ids;
}

