#!perl

use strict;
use warnings;

use Test::More 0.88 tests => 3 + 6 * !! $ENV{AUTHOR_TESTING};
use PAUSE::Users;

if ($ENV{AUTHOR_TESTING}) {
    require XML::LibXML;
    require XML::Twig;
}

my @SKIP = ([LibXML => 'PAUSE/Users/UserIterator/LibXML.pm'],
            [Twig   => 'PAUSE/Users/UserIterator/Twig.pm']);

{

#-----------------------------------------------------------------------
# construct PAUSE::Users
#-----------------------------------------------------------------------

my $users = PAUSE::Users->new(path => 't/00whois-mini.xml');

ok(defined($users), 'instantiate PAUSE::Users');

#-----------------------------------------------------------------------
# construct the iterator
#-----------------------------------------------------------------------

my $iterator = $users->user_iterator();

ok(defined($iterator), 'create user iterator');

note 'Using ', ref $iterator;

#-----------------------------------------------------------------------
# Construct a string with info
#-----------------------------------------------------------------------
my $expected = <<'END_EXPECTED';
FREW|Arthur Axel "fREW" Schmidt|frioux+cpan@gmail.com|1
NBERTRAM|Neil Bertram|CENSORED|0
NEILB|Neil Bowers|neil@bowers.com|1
NHAINER|Neil Hainer|CENSORED|0
END_EXPECTED

my $string = '';

while (my $user = $iterator->next_user) {
    $string .= $user->id()
               .'|'
               .$user->fullname()
               .'|'
               .$user->email()
               .'|'
               .$user->has_cpandir()
               ."\n";
}

is($string, $expected, "rendered user details");

if ($ENV{AUTHOR_TESTING} && @SKIP) {
    my ($rex, $module) = @{ shift @SKIP };
    unshift @INC, sub { die if $_[1] =~ /$rex/ };
    delete $INC{$module};
    redo;
}

}
