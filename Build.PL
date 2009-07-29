use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Lingua::FR::Fathom',
    license             => 'perl',
    dist_author         => q{Jean-Francois Leforestier URC HEGP Paris XV <jean-francois.leforestier@egp.aphp.fr>},
    dist_version_from   => 'lib/Lingua/FR/Fathom.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Lingua-FR-Fathom-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
