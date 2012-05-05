package # hide from cpan =)
    HTC_Utils;
use base 'Exporter';
use File::Spec;
@EXPORT_OK = qw($cache $tdir &cdir);

$cache = File::Spec->catdir(qw(t cache));
$tdir  = File::Spec->catdir(qw(t templates));

sub cdir { File::Spec->catdir(@_) }

1;
