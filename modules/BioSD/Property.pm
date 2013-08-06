
package BioSD::Property;
use strict;
use warnings;

use BioSD::TermSourceREF;

sub new{
  my ($class, $xml_element) = @_;
  my $self = {};
  bless $self, $class;

  $self->_xml_element($xml_element);
  return $self;
}


sub value {
  my ($self) = @_;
  my ($value) = map {$_->to_literal} $self->_xml_element->getChildrenByTagName('Value');
  return $value;
}

sub term_source_ref {
  my ($self) = @_;
  if (!$self->{_term_source_ref}) {
    ($self->{_term_source_ref}) = map {BioSD::TermSourceREF->new($_)}
              $self->_xml_element->getChildrenByTagName('TermSourceREF');
  }
  return $self->{_term_source_ref};
}

sub comment {
  my ($self) = @_;
  return $self->_xml_element->getAttribute('comment');
}

sub class {
  my ($self) = @_;
  return $self->_xml_element->getAttribute('class');
}

sub type {
  my ($self) = @_;
  return $self->_xml_element->getAttribute('type');
}

sub characteristic {
  my ($self) = @_;
  return $self->_xml_element->getAttribute('characteristic');
}

sub _xml_element {
  my ($self, $xml_element) = @_;
  if ($xml_element) {
    $self->{_xml_element} = $xml_element;
  }
  return $self->{_xml_element};
}

1;
