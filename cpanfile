requires 'LWP::UserAgent';
requires 'XML::LibXML';

on 'build' => sub {
    requires 'Module::Build::Pluggable';
    requires 'Module::Build::Pluggable::CPANfile';
};
