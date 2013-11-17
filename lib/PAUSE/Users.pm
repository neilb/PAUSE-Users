package PAUSE::Users;
# ABSTRACT: interface to PAUSE's users file (00whois.xml)
use strict;
use warnings;

use Moo;
use PAUSE::Users::User;
use PAUSE::Users::UserIterator;
use File::HomeDir;
use File::Spec::Functions 'catfile';
use HTTP::Tiny;

my $DISTNAME = '{{ $dist->name }}';
my $BASENAME = '00whois.xml';

has 'url' =>
    (
     is      => 'ro',
     default => sub { return "http://www.cpan.org/authors/$BASENAME"; },
    );

has 'path' =>
    (
     is => 'rw',
    );

sub user_iterator
{
    my $self = shift;

    return PAUSE::Users::UserIterator->new( users => $self );
}

sub BUILD
{
    my $self = shift;

    # If constructor didn't specify a local file, then mirror the file from CPAN
    if (not $self->path) {
        $self->path( catfile(File::HomeDir->my_dist_data( $DISTNAME, { create => 1 } ), $BASENAME) );
        HTTP::Tiny->new()->mirror($self->url, $self->path);
    }
}

1;

=head1 NAME

PAUSE::Users - interface to PAUSE's users file (00whois.xml)

=head1 SYNOPSIS

 use PAUSE::Users;

 my $users    = PAUSE::Users->new();
 my $iterator = $users->user_iterator();

 while (defined($user = $iterator->next_user)) {
   print "PAUSE id = ", $user->id, "\n";
   print "Name     = ", $user->fullname, "\n";
 }

=head1 DESCRIPTION

B<NOTE>: this is very much an alpha release. Any and all feedback appreciated.

PAUSE::Users provides an interface to the C<00whois.xml>
file produced by the Perl Authors Upload Server (PAUSE).
The file contains a list of all PAUSE users:

=head1 FILE FORMAT

The meat of the file is a list of C<E<lt>cpanidE<gt>> elements,
each of which contains details of one PAUSE user:

 <?xml version="1.0" encoding="UTF-8"?>
 <cpan-whois xmlns='http://www.cpan.org/xmlns/whois'
            last-generated='Sat Nov 16 18:19:01 2013 UTC'
            generated-by='/home/puppet/pause/cron/cron-daily.pl'>
  
  ...
  
  <cpanid>
   <id>NEILB</id>
   <type>author</type>
   <fullname>Neil Bowers</fullname>
   <email>neil@bowers.com</email>
   <has_cpandir>1</has_cpandir>
  </cpanid>
  
  ...
  
 </cpan-whois>

=head1 SEE ALSO

L<Parse::CPAN::Whois> is another module that parses 00whois.xml, but you have to download it
yourself first.

L<Parse::CPAN::Authors> is another module for getting information about PAUSE users,
but based on C<01.mailrc.txt.gz>.

L<PAUSE::Permissions>, L<PAUSE::Packages>.

=head1 REPOSITORY

L<https://github.com/neilbowers/PAUSE-Users>

=head1 AUTHOR

Neil Bowers E<lt>neilb@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Neil Bowers <neilb@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

