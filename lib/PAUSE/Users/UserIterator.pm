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
            my ($field, $value) = ($1, $2);

            # <type>author</type> specified a user account
            # <type>list</type> is a mailing list; we skip those
            if ($field eq 'type') {
                $inuser = 0 if $value eq 'list';
                next LINE;
            }

            push(@fields, $field => $value);
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
