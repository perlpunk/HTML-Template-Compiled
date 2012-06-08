# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl HTML-Template-Compiled.t'
# $Id: 01_HTML-Template-Compiled.t 1136 2011-11-21 19:35:19Z tinita $
use strict;
use warnings;
use Test::More tests => 6;
use Data::Dumper;
local $Data::Dumper::Indent = 1; local $Data::Dumper::Sortkeys = 1;
BEGIN { use_ok('HTML::Template::Compiled') };
use Fcntl qw(:seek);
use File::Copy qw(copy);
use lib 't';
use HTC_Utils qw($cache $cache_lock $tdir &cdir &remove_cache);
mkdir($cache);

my $hash = {
	SELF => '/path/to/script.pl',
	LANGUAGE => 'de',
	BAND => 'Bauhaus',
	ALBUMS => [
		{
			ALBUM => 1,
			NAME => 'Mask',
			SONGS => [
				{ NAME => 'Hair of the Dog' },
				{ NAME => 'Passion of Lovers' },
		 	],
		},
	],
	INFO => {
		BIOGRAPHY => undef,
		LINK => 'http://...'
	},
	OBJECT => bless({
			'_key' => 23,
		}, "HTC::Test"),
	URITEST => 'a b c & d',
};
sub HTC::Test::key { return $_[0]->{"_key"} }

my $include_orig = cdir($tdir,'include.html');
my $include = cdir($tdir,'include_copy.html');
copy($include_orig, $include) or die $!;
chmod 0644, $include;
my %args = (
	path => $tdir,
	#case_insensitive => 1,
	case_sensitive => 0,
	loop_context_vars => 1,
	line_numbers => 1,
	filename => 'songs.html',
#	method_call => '/',
#	deref => '.',
#	debug => $ENV{HARNESS_ACTIVE} ? 0 : 1,
	# for testing without cache comment out
	file_cache_dir => $cache,
    file_cache => 1,
    #cache => 0,
    #search_path_on_include => 1,
    expire_time => 2,
);
sleep 2;
@HTML::Template::Compiled::subclass::ISA = qw(HTML::Template::Compiled);
my $subclass = 'HTML::Template::Compiled::subclass';
sub HTML::Template::Compiled::subclass::method_call { '/' }
sub HTML::Template::Compiled::subclass::deref { '.' }
HTML::Template::Compiled->clear_filecache($cache);

my $htc = $subclass->new(%args);
ok($htc, "template created");
my $time_before = time;
$htc->param(%$hash);

eval { require URI::Escape };
my $uri = $@ ? 0 : 1;
SKIP: {
	skip "no URI::Escape installed", 3, unless ($uri);
	my $out = $htc->output;
	my $dump = <<'EOM';
$DUMP = {
'biography' => undef,
'link' => 'http://...'
};
EOM
    $dump = HTML::Template::Compiled::Utils::escape_html($dump);
	my $exp = <<'EOM' . $dump . <<'EOM';
/path/to/script.pl?lang=de
Band: Bauhaus
Albums:
(first) (last)
Mask (Album)
1. Hair of the Dog
2. Passion of Lovers
---
Bio: No bio available
Homepage: http://...
EOM
Bio: No "bio" available
Homepage: http://...
Song 0: Hair of the Dog
a%20b%20c%20%26%20d
INCLUDED: Hair of the Dog
23
23
EOM
	for ($exp, $out) { s/^\s+//mg; tr/\n\r//d; }
	cmp_ok($out, "eq", $exp, "output ok");
	open my $fh, '+<', $include or die $!;
	local $/;
	my $txt = <$fh>;
	$txt =~ s/INCLUDED/INCLUDED_NEW/;
	seek $fh, 0, SEEK_SET;
	truncate $fh, 0;
	print $fh $txt;
	close $fh;
	my $htc = $subclass->new(%args);
	$htc->param(%$hash);
	$out = $htc->output;
    my $time_after = time;
    if ($time_after - $time_before >= 2) {
        # took too long, cache expired, just return ok
        ok(1, "output after update skipped");
    }
    else {
        $out =~ s/^\s+//mg; $out =~ tr/\n\r//d;
        cmp_ok($out, "eq", $exp, "output after update ok");
    }
    $exp =~ s/INCLUDED/INCLUDED_NEW/;

	sleep 2;
	$htc = $subclass->new(%args);
	$htc->param(%$hash);
	$out = $htc->output;
	$out =~ s/^\s+//mg; $out =~ tr/\n\r//d;
	cmp_ok($out,"eq", $exp, "output after update & sleep ok");

	open $fh, '+<', $include or die $!;
	local $/;
	$txt = <$fh>;
	$txt =~ s/INCLUDED_NEW/INCLUDED/;
	seek $fh, 0, SEEK_SET;
	truncate $fh, 0;
	print $fh $txt;
	close $fh;
}
{
	open my $fh, '<', $include or die $!;
	my $htc = $subclass->new(
		filehandle => $fh,
	);
	$htc->param(%$hash);
	my $out = $htc->output;
	#print STDERR "out: '$out'\n";
	cmp_ok($out, "eq", "INCLUDED: Hair of the Dog\n", "filehandle output");

}

HTML::Template::Compiled->clear_filecache($cache);
remove_cache();
unlink $include;
