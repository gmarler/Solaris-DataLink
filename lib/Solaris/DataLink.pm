package Solaris::DataLink;

use Moose;

has [ 'name' ] => ( 
  is  => 'ro',
  isa => 'Str',
);

1;
