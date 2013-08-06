
package BioSD::Database;
use strict;
use warnings;

sub new{
  my ($class, $xml_element) = @_;
  my $self = {};
  bless $self, $class;

  $self->_xml_element($xml_element);
  return $self;
}


sub id {
  my ($self) = @_;
  my ($id) = map {$_->to_literal} $self->_xml_element->getChildrenByTagName('ID');
  return $id;
}

sub uri {
  my ($self) = @_;
  my ($uri) = map {$_->to_literal} $self->_xml_element->getChildrenByTagName('URI');
  return $uri;
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
