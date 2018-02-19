
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
use Carp;

my $ua = LWP::UserAgent->new;

sub fetch_sample_element {
  my ($sample_id) = @_;
  confess('No sample ID provided') if !defined $sample_id;
  my $location = "$BioSD::root_url/samples/$sample_id";
  my $response = $ua->get($location);
  return _request_location( $location, qr/<BioSample/ );
}

sub fetch_group_element {
  my ($group_id) = @_;
  confess('No group ID provided') if !defined $group_id;
  my $location = "$BioSD::root_url/group/$group_id";
  my $response = $ua->get($location);
  return _request_location( $location, qr/<BioSampleGroup/ );
}

sub fetch_groupsamples_query_element {
  my ( $group_id, $query, $page ) = @_;
  confess('No group ID provided') if !defined $group_id;
  confess('No query provided')    if !defined $query;
  my $location = "$BioSD::root_url/groupsamples/$group_id/query=";
  if ($query) {
    $query = URI::Escape::uri_escape($query);
    $query = URI::Escape::uri_escape($query);
    $location .= q(") . $query . q(");
  }
  $location .= "&page=$page" if defined $page;
  $location .= "&pagesize=$BioSD::query_pagesize";
  my $response = $ua->get($location);
  return _request_location($location);
}

sub fetch_group_query_element {
  my ( $query, $page ) = @_;
  confess('No query provided') if !defined $query;
  my $location = "$BioSD::root_url/group/query=";
  if ($query) {
    $query = URI::Escape::uri_escape($query);
    $query = URI::Escape::uri_escape($query);
    $location .= q(") . $query . q(");
  }
  $location .= "&page=$page" if defined $page;
  $location .= "&pagesize=$BioSD::query_pagesize";
  my $response = $ua->get($location);
  return _request_location($location);
}

sub fetch_sample_query_element {
  my ( $query, $page ) = @_;
  confess('No query provided') if !defined $query;
  my $location = "$BioSD::root_url/samples/query=";
  if ($query) {
    $query = URI::Escape::uri_escape($query);
    $query = URI::Escape::uri_escape($query);
    $location .= q(") . $query . q(");
  }
  $location .= "&page=$page" if defined $page;
  $location .= "&pagesize=$BioSD::query_pagesize";
  my $response = $ua->get($location);
  return _request_location($location);
}

sub fetch_sample_ids_in_group {
  my ( $group_id, $query ) = @_;
  confess('No group ID provided') if !defined $group_id;
  confess('No query provided')    if !defined $query;
  my @sample_ids;
  my $page = 1;
  my $total;
PAGE:
  while (1) {
    my $query_element =
      fetch_groupsamples_query_element( $group_id, $query, $page );
    push( @sample_ids,
      map { $_->value }
        BioSD::XPathContext::findnodes( './RQ:BioSample/@id', $query_element )
    );
    $total //= BioSD::XPathContext::findvalue( './RQ:SummaryInfo/RQ:Total',
      $query_element );
    last PAGE if $total <= $page * $BioSD::query_pagesize;
    $page += 1;
  }
  return \@sample_ids;
}

sub fetch_group_ids {
  my ($query) = @_;
  if ( !$query ) {
    warn(
'BioSD: Call to fetch_group_ids with an empty query is returning EVERY Biosamples group in the database'
    );
  }
  my @group_ids;
  my $page = 1;
  my $total;
  my $fetch_attempts = 0;
PAGE:
  while (1) {
    my $query_element = fetch_group_query_element( $query, $page );
    $total //= BioSD::XPathContext::findvalue( './RQ:SummaryInfo/RQ:Total',
      $query_element );
    my $last_id = BioSD::XPathContext::findvalue( './RQ:SummaryInfo/RQ:To',
      $query_element );
    if ( $total && $last_id == -1 ) {
      $fetch_attempts += 1;
      die "Could not query $query: Rest server error"
        if $fetch_attempts >= $BioSD::max_fetch_attempts;
      redo PAGE;
    }
    push(
      @group_ids,
      map { $_->value } BioSD::XPathContext::findnodes(
        './RQ:BioSampleGroup/@id', $query_element
      )
    );
    last PAGE if $total <= $page * $BioSD::query_pagesize;
    $page += 1;
  }
  return \@group_ids;
}

sub fetch_sample_ids {
  my ($query) = @_;
  if ( !$query ) {
    warn(
'BioSD: Call to fetch_sample_ids with an empty query is returning EVERY Biosample in the database'
    );
  }
  my @sample_ids;
  my $page = 1;
  my $total;
  my $fetch_attempts = 0;
PAGE:
  while (1) {
    my $query_element = fetch_sample_query_element( $query, $page );
    $total //= BioSD::XPathContext::findvalue( './RQ:SummaryInfo/RQ:Total',
      $query_element );
    my $last_id = BioSD::XPathContext::findvalue( './RQ:SummaryInfo/RQ:To',
      $query_element );
    if ( $total && $last_id == -1 ) {
      $fetch_attempts += 1;
      die "Could not query $query: Rest server error"
        if $fetch_attempts >= $BioSD::max_fetch_attempts;
      redo PAGE;
    }
    push( @sample_ids,
      map { $_->value }
        BioSD::XPathContext::findnodes( './RQ:BioSample/@id', $query_element )
    );
    last PAGE if $total <= $page * $BioSD::query_pagesize;
    $page += 1;
  }
  return \@sample_ids;
}

sub _request_location {
  my ( $location, $success_regex ) = @_;

  my $response = $ua->get($location);

  return undef if ( $response->code == 404 );

  die $response->status_line if $response->is_error;

  return undef if ( $success_regex && $response->content !~ $success_regex );

  return XML::LibXML->load_xml( string => $response->content )
    ->getDocumentElement;
}
