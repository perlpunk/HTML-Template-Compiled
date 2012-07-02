# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl HTML-Template-Compiled.t'
# $Id: 11_dhtml.t 952 2007-07-30 20:42:25Z tinita $

use Test::More tests => 3;
BEGIN { use_ok('HTML::Template::Compiled') };
use lib 't';
use HTC_Utils qw($cache $cache_lock $tdir &cdir &remove_cache);
mkdir($cache);

eval {
	require Data::TreeDumper::Renderer::DHTML;
    require Data::TreeDumper;
};
my $dhtml = $@ ? 0 : 1;
	my %hash = (
		dhtml => [
			qw(array items),
			[qw(inner array)],
		],
		more => {
			hash => 'keys',
		},
	);
SKIP: {
    {
        skip "no Data::TreeDumper::Renderer::DHTML/Data::TreeDumper installed", 2 unless $dhtml;
        my $htc = HTML::Template::Compiled->new(
            filename => "t/templates/dhtml.htc",
            debug => 0,
            plugin => [qw(HTML::Template::Compiled::Plugin::DHTML)],
            file_cache_dir => $cache,
            file_cache => 1,
            cache => 0,
        );
        $htc->param(%hash);
        my $out = $htc->output;
        #print $out;
        ok($out =~ m/data_treedumper_dhtml/, 'DHTML plugin');
    }
    {
#        HTML::Template::Compiled::Compiler->delete_subs;
        # from cache
        my $htc = HTML::Template::Compiled->new(
            filename => "t/templates/dhtml.htc",
            debug => 0,
            plugin => [qw(HTML::Template::Compiled::Plugin::DHTML)],
            file_cache_dir => $cache,
            file_cache => 1,
            cache => 0,
        );
        $htc->param(%hash);
        my $out = $htc->output;
#        print $out;
        ok($out =~ m/data_treedumper_dhtml/, 'DHTML plugin with file cache');
    }
}
HTML::Template::Compiled->clear_filecache($cache);
remove_cache();
