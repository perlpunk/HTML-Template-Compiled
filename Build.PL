use strict;
use warnings;
require 5.008001;
use Module::Build;

my $build = Module::Build->new(
    create_makefile_pl => 'traditional',
    license            => 'perl',
    configure_requires => {
        'Module::Build' => 0.28,
    },
    module_name        => 'HTML::Template::Compiled',
    dist_author        => 'Tina Mueller',
    build_requires => {
        'Test::More' => 0,
        'Module::Build' => 0.28,
    },
    requires => {
        'perl'           => '5.8.1',
        'Carp'           => 0,
        'Digest::MD5'    => 0,
        'File::Basename' => 0,
        'File::Spec'     => 0,
        'Test::More'     => 0,
        'B::Deparse'     => 0.61,
        'Storable'       => 2,
        'URI::Escape' => 0,
    },
    recommends         => {
        'Parse::RecDescent'                 => 0,
        'Data::TreeDumper::Renderer::DHTML' => 0,
        'Data::TreeDumper'                  => 0,
    },
    create_readme      => 1,
    sign               => 0,
    meta_merge => {
        resources => {
            repository  => 'https://github.com/perlpunk/HTML-Template-Compiled',
        },
    },
);
$build->create_build_script;

