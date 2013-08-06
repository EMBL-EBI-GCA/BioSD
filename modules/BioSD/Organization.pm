
package BioSD::Organization;
use strict;
use warnings;

sub new{
  my ($class, $xml_element) = @_;
  my $self = {};
  bless $self, $class;

  $self->_xml_element($xml_element);
  return $self;
}


sub address {
  my ($self) = @_;
  my ($address) = map {$_->to_literal} $self->_xml_element->getChildrenByTagName('Address');
  return $address;
}

sub uri {
  my ($self) = @_;
  my ($uri) = map {$_->to_literal} $self->_xml_element->getChildrenByTagName('URI');
  return $uri;
}


sub email {
  my ($self) = @_;
  my ($email) = map {$_->to_literal} $self->_xml_element->getChildrenByTagName('Email');
  return $email;
}

sub role {
  my ($self) = @_;
  my ($role) = map {$_->to_literal} $self->_xml_element->getChildrenByTagName('Role');
  return $role;
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
