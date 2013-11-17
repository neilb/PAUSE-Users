package PAUSE::Users::User;

use 5.10.0;
use Moo;

has 'asciiname'     => (is => 'ro');
has 'email'         => (is => 'ro');
has 'fullname'      => (is => 'ro');
has 'has_cpandir'   => (is => 'ro');
has 'homepage'      => (is => 'ro');
has 'id'            => (is => 'ro');
has 'info'          => (is => 'ro');
has 'introduced'    => (is => 'ro');
has 'type'          => (is => 'ro');

1;
