package PAUSE::Users::UserIterator::Twig;

use strict;
use warnings;

use XML::Twig;

use Moo;
extends 'PAUSE::Users::UserIterator';

has twig => (is => 'lazy', clearer => 'clear_twig');

my $NS = 'http://www.cpan.org/xmlns/whois';

sub next_user
{
    my $self = shift;

    $self->twig->parsefile($self->users->path)
        unless  $self->twig->root;

    while (my $elt = $self->twig->first_elt('cpanid')) {
        if ('list' eq $elt->first_child_text('type')) {
            $elt->purge;
            next;
        }

        my $user = PAUSE::Users::User->new(map {
            $_->name => $_->text
        } $elt->children);
        $elt->purge;

        return $user;
    }

    $self->clear_twig;
    return undef;
}

sub _build_twig
{
    my $self = shift;
    my $twig = XML::Twig->new;
    return $twig;
}

1;
