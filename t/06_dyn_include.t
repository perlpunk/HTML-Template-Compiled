# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl HTML-Template-Compiled.t'
# $Id: 06_dyn_include.t 1069 2008-07-26 11:04:03Z tinita $

use lib 'blib/lib';
use Test::More tests => 10;
BEGIN { use_ok('HTML::Template::Compiled') };

my $htc = HTML::Template::Compiled->new(
	path => 't/templates',
	filename => 'dyn_include.htc',
	debug => 0,
);
#exit;
for my $ix (1..2,undef) {
	$htc->param(
        file => (defined $ix? "dyn_included$ix.htc" : undef),
		test => 23,
	);
    my $out;
    eval {
        $out = $htc->output;
    };
    if (defined $ix) {
        #print $out;
        $out =~ s/\r\n|\r/\n/g;
        cmp_ok($out, "=~",
            "Dynamic include:", "dynamic include $ix.1");
        cmp_ok($out, "=~", "This is dynamically included file $ix\.", "dynamic include $ix.2");
        cmp_ok($out, "=~", "23", "dynamic include $ix.3");
    }
    else {
        #print "Error: $@\n";
        #print "out: $out\n";
        cmp_ok($out, "=~", 'Dynamic include:\s+$', "undefined filename");
    }
}

{
    my $htc = HTML::Template::Compiled->new(
        scalarref => \<<'EOM',
inc: <%include_string foo %>
EOM
        debug => 0,
    );
    $htc->param(
        foo => 'included=<%= bar%>',
        bar => 'real',
    );
    my $out = $htc->output;
    #print "out: $out\n";
    my $exp = 'inc: included=real';
    cmp_ok($out, '=~', $exp, "include_string");
}

{
    my $htc;
    eval {
        $htc = HTML::Template::Compiled->new(
            filename => 'user_template.html',
            path => 't/templates',
            no_includes => 1,
        );
    };
    my $error = "$@";
    cmp_ok($error, '=~', 'Syntax error.*near.*include', "no_includes");
}

__END__
Dynamic include:
This is dynamically included file 1.
23
