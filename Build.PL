use Module::Build;

my $build = new Module::Build
 (
  module_name        => 'Acme::PM::Dresden',
  license            => 'perl',
  requires           => {
                         perl               => '5.6.1',
                         XML::Simple        => 0,
                         Class::MethodMaker => 0,
			 WWW::Mechanize     => 0,
                        },
  build_requires     => {
			 Text::Diff  => 0,
			 Test::More => 0,
			 Test::Distribution => 0,
			 Test::Pod::Coverage => 0,
                        },
  create_makefile_pl => 'passthrough',
 );
$build->create_build_script;
$build->create_makefile_pl;
