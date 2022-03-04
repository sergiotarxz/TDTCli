use Module::Build;

my $home = $ENV{HOME};

my $build = Module::Build->new(
    module_name => 'TDT::Cli',
    license => 'AGPLv3',
    requires => {
        'Mojolicious' => 0,
        'JSON' => 0,
        'Const::Fast' => 0,
    },
);
$build->create_build_script;
