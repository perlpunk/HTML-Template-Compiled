# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl HTML-Template-Compiled.t'
# $Id: 12_path.t 985 2007-11-04 21:03:50Z tinita $

use lib 'blib/lib';
use Test::More tests => 4;
BEGIN { use_ok('HTML::Template::Compiled') };
use File::Spec ();
use lib 't';
use HTC_Utils qw($tdir);

eval {
	my $htc = HTML::Template::Compiled->new(
		path => [
            File::Spec->catfile(qw(t templates_foo)),
            $tdir,
        ],
		filename => File::Spec->catfile(qw(a file1.html)),
		search_path_on_include => 0,
		#debug => 1,
	);
};
print "err: $@\n"  unless $ENV{HARNESS_ACTIVE};
my $f = File::Spec->catfile(qw/ a file1.html /);
cmp_ok($@, '=~', qr{'\Q$f\E' not found}, "search_path_on_include off");

my $htc = HTML::Template::Compiled->new(
	path => ["$tdir/subdir", "$tdir/subdir2"],
	filename => File::Spec->catfile(qw(a file1.html)),
    search_path_on_include => 1,
	#debug => 1,
);
my $out = $htc->output;
$out =~ tr/\r\n//d;
ok(
	$out =~ m{Template t/templates/subdir/a/file1.htmlTemplate t/templates/subdir/a/file2.html},
	"include form current dir"
);
	


TODO: {
    local $TODO = "path not yet correctly implemented";
    my $out = '';
    eval {
        my $htc = HTML::Template::Compiled->new(
            path => File::Spec->catfile(qw(t templates)),
            filename => 'subdir/a/path.html',
        );
        $out = $htc->output;
        #warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\$out], ['out']);
    };
    #warn __PACKAGE__.':'.__LINE__.": error? $@\n";
    cmp_ok($out, '=~', 'this is t/templates/subdir/b.html', 'search current path on include');

}
