
package BioSD::TermSourceREF;
use strict;
use warnings;

sub new{
  my ($class, $xml_element) = @_;
  my $self = {};
  bless $self, $class;

  $self->_xml_element($xml_element);
  return $self;
}

sub version {
  my ($self) = @_;
  my ($version) = map {$_->to_literal} $self->_xml_element->getChildrenByTagName('Version');
  return $version;
}

sub uri {
  my ($self) = @_;
  my ($uri) = map {$_->to_literal} $self->_xml_element->getChildrenByTagName('URI');
  return $uri;
}

sub term_source_id {
  my ($self) = @_;
  my ($term_source_id) = map {$_->to_literal} $self->_xml_element->getChildrenByTagName('TermSourceID');
  return $term_source_id;
}

sub description {
  my ($self) = @_;
  my ($description) = map {$_->to_literal} $self->_xml_element->getChildrenByTagName('Description');
  return $description;
}

sub name {
  my ($self) = @_;
  my ($name) = map {$_->to_literal} $self->_xml_element->getChildrenByTagName('Name');
  return $name;
}

sub _xml_element {
  my ($self, $xml_element) = @_;
  if ($xml_element) {
    $self->{_xml_element} = $xml_element;
  }
  return $self->{_xml_element};
}

1;
