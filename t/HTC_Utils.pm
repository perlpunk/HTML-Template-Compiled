package # hide from cpan =)
    HTC_Utils;
use base 'Exporter';
use File::Spec;
@EXPORT_OK = qw($cache $cache_lock $tdir &cdir &remove_cache);

$cache = File::Spec->catdir(qw(t cache));
$cache_lock = File::Spec->catdir(qw(t cache lock));
$tdir  = File::Spec->catdir(qw(t templates));

sub cdir { File::Spec->catdir(@_) }

sub remove_cache {
    unlink $cache_lock;
    rmdir $cache;
}
1;
