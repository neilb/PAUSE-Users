package PAUSE::Users::UserIterator;

use strict;
use warnings;
use 5.14.0;

use Moo;
use PAUSE::Users::User;
use autodie;
use feature 'state';
use feature 'unicode_strings';

has 'users' => ( is => 'ro' );

sub next_user
{
    my $self = shift;
    my @fields;
    my $inuser;
    state $fh;
    local $_;

    if (not defined $fh) {
        open($fh, '<:encoding(UTF-8)', $self->users->path);
    }

    $inuser = 0;
    LINE:
    while (<$fh>) {

        if (m!<cpanid>!) {
            $inuser = 1;
            next LINE;
        }

        next LINE unless $inuser;

        if (m!<([a-zA-Z0-6_]+)>(.*?)</\1>!) {
            push(@fields, $1 => $2);
        }

        if (m!</cpanid>!) {
            my $user = PAUSE::Users::User->new(@fields);
            @fields  = ();
            return $user;
        }

    }
    close($fh);
    return undef;
}

1;
