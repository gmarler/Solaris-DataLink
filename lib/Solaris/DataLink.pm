package Solaris::DataLink;
# ABSTRACT: Represents Solaris 11 and later data links
#
use Data::Dumper;

use Moose;
use Moose::Util::TypeConstraints;

has [ 'name' ]  => ( is  => 'ro', isa => 'Str', required => 1, );
has [ 'zone' ]  => ( is  => 'ro', isa => 'Str', );

enum 'Solaris::DataLink::Class', [ qw/aggr bridge etherstub
                                      iptun part phys vlan vnic/ ];
has [ 'class' ] => ( is       => 'ro',
                     isa      => 'Solaris::DataLink::Class',
                     required => 1,);

has [ 'mtu' ]  => ( is  => 'rw', isa => 'Int', default => 0, );

enum 'Solaris::DataLink::State', [ qw/up down unknown/ ];

has [ 'state' ]  => ( is  => 'rw',
                      isa => 'Solaris::DataLink::State', );

# TODO: 'over' attribute is usually undef when class is 'phys'
has [ 'over' ]       => ( is => 'ro',
                          isa => 'Str', );

has [ 'properties' ] => ( is => 'ro',
                          isa => 'ArrayRef[Solaris::DataLink::Property]',
                        );

# TODO: This should not be explicitly defined in this class, as it could
#       differ from site to site.  Make this configurable
enum 'Solaris::DataLink::UseCase', [ qw/none PRCCOM LVM HVM HRP N2/ ];

has [ 'usecase' ] => ( is => 'rw',
                       isa => 'Solaris::DataLink::UseCase',
                       default => "none", );

#
# METHODS
#
#sub BUILD {
# Use this for object validation(s)
#  my $self = shift;
                     #
#}

around BUILDARGS => sub {
  my $orig   = shift;
  my $class  = shift;
  my @params = @_;

  my %h = @params;

  # TODO: Note conflicting constructor args and raise exception
  #
  # Constructor had show-link option passed in
  if ($h{'show-link'}) {
    my (@keys) = qw(name class mtu state over);
    chomp($h{'show-link'}); # Bye bye trailing newline
    # NOTE: We're using a chunk-limit of -1 here, to ensure that we get all
    #       trailing, possibly empty, fields.
    my (@vals) = split(/:/, $h{'show-link'}, -1);
    delete $h{'show-link'};
    @h{@keys} = @vals;
  }
  return $class->$orig( \%h );
};  # NEED THE SEMICOLON HERE!!!

# TODO:
# constructor 
#   Dependency Injection:
#   - Class method:
#     - No options indicates dladm show-link -p ... should be run
#       and possibly generate many instances
#       - NEED TO MOCK OUTPUT OF dladm show-link -p ...
#     - name: if no other data provided, run dladm show-link|show-linkprop
#     - show-link: create a single DataLink instance from the data
#     - show-linkprops: create single instance
#   - Emissions from dlstat/dladm [show-link|show-linkprop] -p ...
#   - configuration(s) for: Solaris::DataLink::UseCase
#                           Properties related to above UseCase definitions
#
# update_linkprops
# update_linkstats
# print
# print_linkstats
# print_linkprops
# print_summary
#
# If 'usecase' attribute is altered, update everything down the line
#

no Moose;
__PACKAGE__->meta->make_immutable;

1;
