package PAUSE::Users::UserIterator::LibXML;

use strict;
use warnings;

use XML::LibXML::Reader ();
use XML::LibXML::XPathContext ();

use Moo;
extends 'PAUSE::Users::UserIterator';

has xml => (is => 'lazy', clearer => 'clear_xml', builder => '_build_xml');

my $NS = 'http://www.cpan.org/xmlns/whois';

sub next_user
{
    my $self = shift;

    while ($self->xml->nextElement('cpanid', $NS)) {
        my $element = $self->xml->copyCurrentNode(1);
        my $xpc = XML::LibXML::XPathContext->new;
        $xpc->registerNs(whois => $NS);

        next if 'list' eq $xpc->findvalue("whois:type", $element);

        my $user = PAUSE::Users::User->new(map {
            $_->localName, $_->textContent
        } $xpc->findnodes("whois:*", $element));

        return $user;
    }
    $self->clear_xml;
    return undef;
}

sub _build_xml
{
    my $self = shift;
    my $reader = XML::LibXML::Reader->new(location => $self->users->path)
        or die "Cannot open " . $self->users->path;
    return $reader;
}

1;
