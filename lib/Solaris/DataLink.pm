package Solaris::DataLink;
# ABSTRACT: Represents Solaris 11 and later data links
#
use Data::Dumper;

use Moose;
use Moose::Util::TypeConstraints;
with 'MooseX::Log::Log4perl';
use namespace::autoclean;
use Log::Log4perl qw(:easy);
#BEGIN {
#    Log::Log4perl->easy_init({
#        level   => $DEBUG,
#        file    => ">>/tmp/sc.log",
#        layout  => '%d %p [%P] %l %m%n',
#    });
#};

#has '+logger'   => ( traits => ['DoNotSerialize'] );

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
  my $log = Log::Log4perl->get_logger();

  # TODO: Note conflicting constructor args and raise exception
  #
  # Constructor had show-link option passed in/injected (usually for testing)
  $log->info('CONSTRUCTOR: handling link');
  if ($h{'show-link'}) {
    my (@keys) = qw(name class mtu state over);
    chomp($h{'show-link'}); # Bye bye trailing newline
    # NOTE: We're using a chunk-limit of -1 here, to ensure that we get all
    #       trailing, possibly empty, fields.
    my (@vals) = split(/:/, $h{'show-link'}, -1);
    delete $h{'show-link'};
    @h{@keys} = @vals;
  } else {
    my @cmd = (qw(/sbin/dladm show-link -p -o), q(link,class,mtu,state,over));
    my $out = qx{@cmd};
    my $status = $? >> 8;
    if ($status != 0) {
      die "Unable to run dladm show-link system-wide!";
    }
    # TODO: Parse link properties into Solaris::DataLink::Property instances,
    #       should probably do in Solaris::DataLink::Property class, or a Role
  }

  # TODO: datalink properties
  # TODO: datalink private properties
  #       (per physical NIC device type from dladm show-phys)
  # TODO: 

  # Constructor had show-linkprop option passed in
  $log->info('CONSTRUCTOR: handling link properties');
  if ($h{'show-linkprop'}) {
    my (@keys) = qw(name property perm value default possible);
    chomp($h{'show-linkprop'}); # Bye bye trailing newline
    # NOTE: We're using a chunk-limit of -1 here, to ensure that we get all
    #       trailing, possibly empty, fields.
    my (@vals) = split(/:/, $h{'show-linkprop'}, -1);
    delete $h{'show-linkprop'};
    # TODO: The 'LINK' or 'NAME' should be identical to the one provided by the
    # show-link property, if passed in.  We should probably validate that,
    # rather than just overwrite it as we do currently, since both show-link and
    # show-linkprop have it.
    # Probably best to do the above in the BUILD method
    @h{@keys} = @vals;
  } else {

  }

  # TODO: datalink private properties
  #       (per physical NIC device type from dladm show-phys)

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
