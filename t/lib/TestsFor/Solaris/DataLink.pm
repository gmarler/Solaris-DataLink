package TestsFor::Solaris::DataLink;
use Test::Class::Moose;
with 'Test::Class::Moose::Role::AutoUse';

sub test_constructor {
  my ($test, $report) = @_;

  my $datalink = Solaris::DataLink->new();

  isa_ok $datalink, $test->class_name,
    'The object the constructor returns';
}

sub test_datalink_class {
  my ($test, $report) = @_;
  my @valid_class = qw( aggr bridge etherstub
                        iptun part phys vlan vnic);
  my @invalid_class = qw( barf junk crazy tunnel aggregation
                          virtual_nic ether ethernet VLAN );
  my $dl_obj;

  foreach my $class (@valid_class) {
    $dl_obj = Solaris::DataLink->new(name => 'e1000g0',
                                     class => $class);
    isa_ok $dl_obj, $test->class_name,
      "DataLink with class $class";
  }

  foreach my $class (@invalid_class) {
    throws_ok { $dl_obj = Solaris::DataLink->new(name => 'e1000g0',
                                                 class => $class) }
      '/Attribute.+?does\snot\spass\sthe\stype\sconstraint/',
      "bad DataLink class '$class'";
  }
}

sub test_datalink_state {
  my ($test, $report) = @_;
  my @valid_state = qw( up down unknown );
  my @invalid_state = qw( broken misaligned transient );
  my $dl_obj;

  foreach my $state (@valid_state) {
    $dl_obj = Solaris::DataLink->new(name => 'e1000g0',
                                     class => 'phys',
                                     state => $state);
    isa_ok $dl_obj, $test->class_name,
      "DataLink with state $state";
  }

  foreach my $state (@invalid_state) {
    throws_ok { $dl_obj = Solaris::DataLink->new(name => 'e1000g0',
                                                 class => 'phys',
                                                 state => $state ) }
      '/Attribute.+?does\snot\spass\sthe\stype\sconstraint/',
      "bad DataLink state '$state'";
  }
}


1;

