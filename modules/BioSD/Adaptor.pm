
package BioSD::Adaptor;

use LWP::UserAgent;
use XML::LibXML;
use strict;
use warnings;

our $root_url = 'http://www.ebi.ac.uk/biosamples/xml';
our $query_pagesize = 500;

my $ua = LWP::UserAgent->new;

sub fetch_sample_element {
  my ($sample_id) = @_;
  my $location = "$root_url/sample/$sample_id";
  my $response = $ua->get($location);
  die $response->status_line if $response->is_error;
  return undef if ($response->content !~ /^<[^<>]*><BioSample/);
  return XML::LibXML->load_xml( string => $response->content)->getDocumentElement;
}

sub fetch_group_element {
  my ($group_id) = @_;
  my $location = "$root_url/group/$group_id";
  my $response = $ua->get($location);
  die $response->status_line if $response->is_error;
  return undef if ($response->content !~ /^<[^<>]*><BioSampleGroup/);
  return XML::LibXML->load_xml( string => $response->content)->getDocumentElement;
}

sub fetch_groupsamples_query_element {
  my ($group_id, $query, $page) = @_;
  my $location = "$root_url/groupsamples/$group_id/query=";
  $location .= $query;
  $location .= "&page=$page" if defined $page;
  $location .= "&pagesize=$query_pagesize";
  my $response = $ua->get($location);
  die $response->status_line if $response->is_error;
  return XML::LibXML->load_xml( string => $response->content)->getDocumentElement;
}

sub fetch_group_query_element {
  my ($query, $page) = @_;
  my $location = "$root_url/group/query=";
  $location .= $query if $query;
  $location .= "&page=$page" if defined $page;
  $location .= "&pagesize=$query_pagesize";
  my $response = $ua->get($location);
  die $response->status_line if $response->is_error;
  return XML::LibXML->load_xml( string => $response->content)->getDocumentElement;
}

sub query_samples {
  my ($group_id, $query) = @_;
  my @sample_ids;
  my $page = 1;
  my $total;
  PAGE:
  while (1) {
    my $query_element = fetch_groupsamples_query_element($group_id, $query, $page);
    push(@sample_ids, map {$_->to_literal} $query_element->findnodes('./BioSample/@id'));
    $total //= $query_element->findvalue('./SummaryInfo/Total');
    last PAGE if $total <= $page*$query_pagesize;
    $page += 1;
  }
  return \@sample_ids;
}

sub query_groups {
  my ($query) = @_;
  if (!$query) {
    warn('Calls to query_groups with an empty query will return EVERY Biosamples group in the database');
  }
  my @group_ids;
  my $page = 1;
  my $total;
  PAGE:
  while (1) {
    my $query_element = fetch_group_query_element($query, $page);
    push(@group_ids, map {$_->to_literal} $query_element->findnodes('./BioSampleGroup/@id'));
    $total //= $query_element->findvalue('./SummaryInfo/Total');
    last PAGE if $total <= $page*$query_pagesize;
    $page += 1;
  }
  return \@group_ids;
}
