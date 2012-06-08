# $Id: 04_out_fh.t 1144 2012-04-21 18:59:13Z tinita $
use Test::More tests => 5;
BEGIN { use_ok('HTML::Template::Compiled') };
use lib 't';
use File::Spec;
use HTC_Utils qw($cache $cache_lock $tdir &cdir &remove_cache);
mkdir($cache);
#my $cache = File::Spec->catfile('t', 'cache');
my $out = File::Spec->catfile('t', 'templates', 'out_fh.htc.output');
HTML::Template::Compiled->clear_filecache($cache);
test('compile', 'clearcache');
test('filecache');
test('memcache', 'clearcache');
HTML::Template::Compiled->preload($cache);
test('after preload', 'clearcache');

sub test {
	my ($type, $clearcache) = @_;
	# test output($fh)
	my $htc = HTML::Template::Compiled->new(
		path => 't/templates',
		filename => 'out_fh.htc',
		out_fh => 1,
		file_cache_dir => 't/cache',
        file_cache => 1,
	);
	open my $fh, '>', $out or die $!;
	$htc->output($fh);
	close $fh;
	open my $f, '<', File::Spec->catfile('t', 'templates', 'out_fh.htc') or die $!;
	open my $t, '<', File::Spec->catfile('t', 'templates', 'out_fh.htc.output') or die $!;
	local $/;
	my $orig = <$f>;
	my $test = <$t>;
	for ($orig, $test) {
		tr/\n\r//d;
	}
	ok($orig eq $test, "out_fh $type");
	$htc->clear_cache() if $clearcache;

	# this is not portable
	#ok(-s $out == -s File::Spec->catfile('t', 'out_fh.htc'), "out_fh");
}

unlink $out;
HTML::Template::Compiled->clear_filecache($cache);
remove_cache();
