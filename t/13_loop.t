# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl HTML-Template-Compiled.t'
# $Id: 13_loop.t 1077 2008-09-01 19:02:06Z tinita $

use Test::More tests => 9;
BEGIN { use_ok('HTML::Template::Compiled') };
use lib 't';
use
HTC_Utils qw($cache $tdir &cdir);

{
	my $htc = HTML::Template::Compiled->new(
		scalarref => \<<'EOM',
<tmpl_loop array alias=iterator>
<tmpl_var iterator>
</tmpl_loop>
<tmpl_loop array2 alias=iterator>
<tmpl_var iterator.foo>
</tmpl_loop>
EOM
		debug => 0,
        loop_context_vars => 1,
	);
	$htc->param(
        array => [qw(a b c)],
        array2 => [{ foo => 'a' }, { foo => 'b' }, { foo => 'c' }],
    );
	my $out = $htc->output;
	$out =~ s/\s+//g;
	cmp_ok($out, "eq", "abcabc", "tmpl_loop array alias=iterator");
	#print "out: $out\n";
}
my $text1 = <<'EOM';
<tmpl_loop array>
<tmpl_var __counter__>
<tmpl_var _.x>
</tmpl_loop>
EOM
for (0,1) {
	my $htc = HTML::Template::Compiled->new(
		scalarref => \$text1,
        debug => 0,
        loop_context_vars => $_,
	);
	$htc->param(array => [
        {x=>"a","__counter__"=>"A"},
        {x=>"b","__counter__"=>"B"},
        {x=>"c","__counter__"=>"C"},
    ]);
	my $out = $htc->output;
	$out =~ s/\s+//g;
	my $exp;
	if ($_ == 1) {
		$exp = "1a2b3c";
	}
	else {
		$exp = "AaBbCc";
	}
	#print "($out)($exp)\n";
	cmp_ok($out, "eq", $exp, "loop context");
}

{
    my $htc = HTML::Template::Compiled->new(
        scalarref => \<<EOM,
<%loop list join=", " %><%= _ %><%/loop list %>
EOM
        debug => 0,
    );
    $htc->param(
        list => [qw(a b c)]
    );
    my $out = $htc->output;
    $out =~ s/^\s+//;
    $out =~ s/\s+\z//;
    #print $out, $/;
    cmp_ok($out, 'eq','a, b, c', "loop join attribute");
}

{
    my $htc = HTML::Template::Compiled->new(
        scalarref => \<<EOM,
<%loop list break="3" %><%= _ %><%if __break__%>.<%/if %><%/loop list %>
EOM
        debug => 0,
        loop_context_vars => 1,
    );
    $htc->param(
        list => [qw(a b c d e f g h)]
    );
    my $out = $htc->output;
    $out =~ s/^\s+//;
    $out =~ s/\s+\z//;
    #print $out, $/;
    cmp_ok($out, 'eq','abc.def.gh', "loop break attribute");
}

{
    my $htc = HTML::Template::Compiled->new(
        scalarref => \<<'EOM',
<%loop list %>
<%include loop_included.tmpl %>
<%/loop list %>
EOM
        debug => 0,
        loop_context_vars => 1,
        path => $tdir,
    );
    $htc->param(
        list => [qw(a b c d e f g h)]
    );
    my $out = $htc->output;
    $out =~ s/\s+/ /g;
    #print $out, $/;
    cmp_ok($out, 'eq',' 0 1 2 3 4 5 6 7 h ', "loop context vars in include");
}

for (0, 1) {
    my $htc = HTML::Template::Compiled->new(
        scalarref => \<<'EOM',
<%loop foo.list %>
<%= a %>
<%/loop foo.list %>
EOM
        debug => 0,
        loop_context_vars => 1,
        path => $tdir,
        cache => 0,
        file_cache => 1,
        file_cache_dir => $cache,
    );
    $htc->param(
        foo => {
            list => [{a => 1},{a => 2},{a => 3}],
        },
    );
    my $out = $htc->output;
    $out =~ s/\s+/ /g;
    #print $out, $/;
    cmp_ok($out, 'eq',' 1 2 3 ', "loop " . ($_ ? "after" : "before") . " caching");
}

HTML::Template::Compiled->clear_filecache('t/cache');
