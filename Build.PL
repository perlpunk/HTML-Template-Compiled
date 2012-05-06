use strict;
use warnings;
require 5.006001;
use Module::Build;

my $build = Module::Build->new(
    create_makefile_pl => 'traditional',
    license            => 'perl',
    resources => {
        repository => {
            url => 'https://htcompiled.svn.sourceforge.net/svnroot/htcompiled',
            type => 'svn',
        },
    },
    configure_requires => {
        'Module::Build' => 0,
    },
    module_name        => 'HTML::Template::Compiled',
    dist_author        => 'Tina Mueller',
    requires => {
        perl => '5.6.1',
        'Test::More'     => 0,
        'File::Spec'     => 0,
        'File::Basename' => 0,
        Carp             => 0,
        'Digest::MD5'    => 0,
    },
    recommends         => {
        'URI::Escape' => 0,
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
