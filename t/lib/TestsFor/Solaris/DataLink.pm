package TestsFor::Solaris::DataLink;

use Path::Class::File ();

use Test::Class::Moose;
with 'Test::Class::Moose::Role::AutoUse';

# TODO:
# test_datalink_usecase
# test_datalink_properties
# test_datalink_constructor
#

sub test_startup {
  my ($test, $report) = @_;
  $test->next::method;

  # Log::Log4perl Configuration in a string ...
  my $conf = q(
    #log4perl.rootLogger          = DEBUG, Logfile, Screen
    log4perl.rootLogger          = DEBUG, Screen
  
    #log4perl.appender.Logfile          = Log::Log4perl::Appender::File
    #log4perl.appender.Logfile.filename = test.log
    #log4perl.appender.Logfile.layout   = Log::Log4perl::Layout::PatternLayout
    #log4perl.appender.Logfile.layout.ConversionPattern = [%r] %F %L %m%n
  
    log4perl.appender.Screen         = Log::Log4perl::Appender::Screen
    log4perl.appender.Screen.stderr  = 0
    log4perl.appender.Screen.layout = Log::Log4perl::Layout::SimpleLayout
  );

  # ... passed as a reference to init()
  Log::Log4perl::init( \$conf );
}



sub test_constructor {
  my ($test, $report) = @_;

  my $datalink = Solaris::DataLink->new(name => 'vnic0',
                                        class => 'vnic');

  isa_ok $datalink, $test->class_name,
    'The object the constructor returns';
}

sub test_constructor_show_link {
  my ($test, $report) = @_;

  my $filepath =
    Path::Class::File->new(__FILE__)->parent->parent->parent->parent
                     ->file("data","dladm_show-link1")
                     ->absolute->stringify;
  
  #  Test datafile should exist
  ok( -f $filepath, "$filepath should exist");

  my $ldata = IO::File->new($filepath,"<");

  foreach my $line (<$ldata>) {
    my %data;
    chomp($line);
    next if $line =~ m/^#/;
    my $dl_obj = Solaris::DataLink->new("show-link" => $line);
    my (@keys) = qw(name class mtu state over);
    my @vals = split(/:/, $line, -1);
    @data{@keys} = @vals;
    my ($link_name) = $data{name};
    isa_ok $dl_obj, $test->class_name,
      "$link_name";
    foreach my $key (@keys) {
      eq_or_diff($data{$key}, $dl_obj->${key}, "$key");
    }
  }
}

sub test_datalink_class {
  my ($test, $report) = @_;
  my @valid_class = qw( aggr bridge etherstub
                        iptun part phys vlan vnic);
  my @invalid_class = qw( barf junk crazy VLAN );
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
  my @invalid_state = qw( broken misaligned );
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

sub test_constructor_show_linkprop {
  my ($test, $report) = @_;

  my $link_filepath =
    Path::Class::File->new(__FILE__)->parent->parent->parent->parent
                     ->file("data","dladm_show-link1")
                     ->absolute->stringify;
  my $linkprop_filepath =
    Path::Class::File->new(__FILE__)->parent->parent->parent->parent
                     ->file("data","dladm_show-linkprop1")
                     ->absolute->stringify;
  
  #  Test datafile should exist
  ok( -f $link_filepath, "$link_filepath should exist");
  ok( -f $linkprop_filepath, "$linkprop_filepath should exist");

  my $link_data     = IO::File->new($link_filepath,"<");
  my $linkprop_data = IO::File->new($linkprop_filepath,"<");
  my $linkprops     = do { local $/; <$linkprop_data>; };
  $linkprop_data->close;

  foreach my $line (<$link_data>) {
    my %dl_data;
    my %dlp_data;

    # TODO: Extract the keys from the S::DataLink and S::DataLink::Property class objects
    my (@dl_keys)  = qw(name class mtu state over);
    # TODO: may or may not need these here
    my (@dlp_keys) = qw(link property perm value default possible);

    chomp($line);
    next if $line =~ m/^#/;

    my @dl_vals = split(/:/, $line, -1);
    @dl_data{@dl_keys} = @dl_vals;
    my ($link_name) = $dl_data{name};
    my (@linkprops, $linkprop_section);

    # Rip the section out of the $linkprops that relates to $linkname
    @linkprops = $linkprops =~ m/^(${link_name}:[^\n]+\n)/gsmx;
    $linkprop_section = join('', @linkprops);

    # For this test, we pass in a single line from dladm show-link, and the entire
    # section of properties for that particular datalink from dladm show-linkprop
    my $dl_obj = Solaris::DataLink->new("show-link"     => $line,
                                        "show-linkprop" => $linkprop_section);

    isa_ok $dl_obj, $test->class_name,
      "$link_name";
    foreach my $dl_key (@dl_keys) {
      eq_or_diff($dl_data{$dl_key}, $dl_obj->${dl_key}, "$dl_key");
    }
  }
}


1;

