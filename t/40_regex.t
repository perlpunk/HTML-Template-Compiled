use warnings;
use strict;
use lib 't';
use 5.010;

use constant TESTS => 1 + 17;
use Test::More tests => TESTS + 1;
eval { require Parse::RecDescent; };
my $prd = $@ ? 0 : 1;
use_ok('HTML::Template::Compiled');
use HTC_Utils qw($cache $tdir &cdir);

SKIP: {
    skip "No Parse::RecDescent installed", TESTS unless $prd;
    use_ok('HTML::Template::Compiled::Expr');
    my $htc;
    my @tests = (
        [ q#[%= expr="string1 like /ABC/" %]#, 1, 0],
        [ q#[%= expr="string1 like /ABCD/" %]#, '', 0],
        [ q#[%= expr="string2 like /\\\\/" %]#, 1, 0],
        [ q#[%= expr="string3 like /\'/" %]#, 1, 0],
        [ q#[%= expr="string4 like /\@\{\[ die 'oops' ]}/" %]#, 1, 0],
        [ q#[%= expr="string3 like ///" %]#, 1, " at "],
        [ q#[%= expr="string5 like /abc\\//" %]#, 1, 0],
        [ q#[%= expr="string5 like m,abc\\/," %]#, 1, 0],
        [ q#[%= expr="string6 like m,abc\\,," %]#, 1, 0],
    );
    for my $i (0 .. $#tests) {
        my $test = $tests[$i];
        my ($tmpl, $exp, $error) = @$test;
        $tmpl =~ tr/\r\n//d;

        my $out;
        eval {
            my $htc = HTML::Template::Compiled->new(
                scalarref => \$tmpl,
                use_expressions => 1,
                debug => 0,
                tagstyle => [qw/ -classic -comment -asp +tt /],
                loop_context_vars => 1,
            );
            my %params = (
                string1 => 'ABC',
                string2 => '\\',
                string3 => "'",
                string4 => q/@{[ die 'oops' ]}/,
                string5 => "abc/",
                string6 => "abc,",
            );
            $htc->param( %params );
            $out = $htc->output;
        };
        if ($error) {
            like($@, qr/$error/, "Regex Expressions $i: '$tmpl' error");
        }
        else {
            is($@, '', "Regex Expressions $i: '$tmpl' no error");
            #print "out: $out\n";
            cmp_ok($out, 'eq', $exp, "Regex Expressions $i. '$tmpl' match");
        }
    }
}

