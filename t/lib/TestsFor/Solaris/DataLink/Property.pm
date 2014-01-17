package TestsFor::Solaris::DataLink::Property;

use Path::Class::File ();

use Test::Class::Moose;
with 'Test::Class::Moose::Role::AutoUse';

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

  my $datalink = Solaris::DataLink->new(name  => 'vnic0',
                                        class => 'vnic');

  isa_ok($datalink,'Solaris::DataLink', 'Solaris::DataLink object created');

  my $dl_prop = Solaris::DataLink::Property->new(link => $datalink,
                                                 name => 'state',
                                                 perm => 'r-',
                                                 value => 'unknown',
                                                 default => 'up',
                                                 possible => [ 'up', 'down' ]
                                                );

  isa_ok $dl_prop, $test->class_name,
    'The object the constructor returns';
}



1;
