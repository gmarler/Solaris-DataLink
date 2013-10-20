package Solaris::DataLink;
# ABSTRACT: Represents Solaris 11 and later data links
use Moose;
use Moose::Util::TypeConstraints;

has [ 'name' ]  => ( is  => 'ro', isa => 'Str', );
has [ 'zone' ]  => ( is  => 'ro', isa => 'Str', );
enum 'Solaris::DataLink::Class', [ qw/aggr bridge etherstub
                                      iptun part phys vlan vnic/ ];
has [ 'class' ] => ( is  => 'ro',
                     isa => 'Solaris::DataLink::Class', );
has [ 'mtu' ]  => ( is  => 'rw', isa => 'Int', default => 0, );

enum 'Solaris::DataLink::State', [ qw/up down unknown/ ];

has [ 'state' ]  => ( is  => 'rw',
                      isa => 'Solaris::DataLink::State', );



1;
