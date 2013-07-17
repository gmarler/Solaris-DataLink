package TestsFor::Solaris::DataLink;
use Test::Class::Moose;
with 'Test::Class::Moose::Role::AutoUse';

sub test_constructor {
  my ($test, $report) = @_;

  my $datalink = Solaris::DataLink->new();

  isa_ok $datalink, $test->class_name,
    'The object the constructor returns';
}

1;

