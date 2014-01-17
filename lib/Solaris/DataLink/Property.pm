package Solaris::DataLink::Property;

use Moose;
use Moose::Util::TypeConstraints;

has [ 'link' ]  => ( is  => 'ro', isa => 'Solaris::DataLink', required => 1, );
# TODO: May want to create a Solaris::DataLink::Property::Properties datatype
#       later
has [ 'name' ]  => ( is  => 'ro', isa => 'Str',               required => 1, );

enum 'Solaris::DataLink::Property::Perm', [ qw/ rw r- / ];
has [ 'perm' ]  => ( is  => 'ro', isa => 'Solaris::DataLink::Property::Perm',
                     required => 1, );

has [ 'value' ]    => ( is  => 'rw', isa => 'Str', );
has [ 'default' ]  => ( is  => 'ro', isa => 'Str', );
# TODO: May want to make this an ArrayRef during construction from the raw data
has [ 'possible' ] => ( is  => 'ro', isa => 'ArrayRef[Str]', );

no Moose;
__PACKAGE__->meta->make_immutable;

1;
