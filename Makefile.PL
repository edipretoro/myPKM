use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'myPKM',
    AUTHOR              => q{Emmanuel Di Pretoro <edipretoro@gmail.com>},
    VERSION_FROM        => 'lib/myPKM.pm',
    ABSTRACT            => 'A first implementation of a personal PKM tool',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'               => 0,
        'YAML'                     => 0,
        'Dancer'                   => 1.3020,
        'Dancer::Plugin::DBIC'     => 0,
        'HTML::ExtractMain'        => 0,
        'LWP::UserAgent'           => 0,
        'HTML::ResolveLink'        => 0,
        'HTML::TreeBuilder::XPath' => 0,
        'Encode'                   => 0,
        'DateTime'                 => 0,
        'DBIx::Class'              => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'myPKM-*' },
);
