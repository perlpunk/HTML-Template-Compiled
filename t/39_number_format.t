# $Id: 18_objects.t 1019 2008-03-02 16:26:48Z tinita $

use constant TESTS => 4;
use Test::More tests => TESTS + 1;
use strict;
use warnings;
BEGIN { use_ok('HTML::Template::Compiled') };
my $nf = eval "use Number::Format 1.73; 1";
my $class_accessor = eval "use Class::Accessor::Fast; 1";

SKIP: {
    skip "no Number::Format 1.73", TESTS unless $nf;
    skip "no Class::Accessor::Fast installed", TESTS unless $class_accessor;
    my $nf_version = Number::Format->VERSION;
    require HTML::Template::Compiled::Plugin::NumberFormat;
    my $nf1 = Number::Format->new(
        -thousands_sep      => '.',
        -decimal_point      => ',',
        -int_curr_symbol    => "\x{20ac}",
        -kilo_suffix        => 'Kb',
        -mega_suffix        => 'Mb',
        -decimal_digits     => 2,
    );
    my $nf2 = Number::Format->new(
        -thousands_sep      => ',',
        -decimal_point      => '.',
        -int_curr_symbol    => '$',
        -kilo_suffix        => 'K',
        -mega_suffix        => 'M',
        -decimal_digits     => 2,
    );
    my @nf = ($nf1, $nf2);
my $t = <<"EOM";
<%= expr=".nfx.format_number(.nums{'big'})" %>
<%= expr=".nfx.format_number(.nums{'big_dec'}, 3)" %>
<%= expr=".nfx.format_price(.nums{'price'})" %>
<%= expr=".nfx.format_bytes(.nums{'bytes1'})" %>
<%= expr=".nfx.format_bytes(.nums{'bytes2'})" %>
<%= expr=".nfx.format_bytes(.nums{'bytes3'})" %>
EOM
my $t_plug = <<"EOM";
<%= .nums.big escape=format_number %>
<%format_number .nums.big_dec precision=3 %>
<%= .nums.price escape=format_price %>
<%= .nums.bytes1 escape=format_bytes %>
<%= .nums.bytes2 escape=format_bytes %>
<%= .nums.bytes3 escape=format_bytes %>
EOM
    my $plug = HTML::Template::Compiled::Plugin::NumberFormat->new({
    });
    my $htc_plug = HTML::Template::Compiled->new(
        scalarref => \$t_plug,
        debug => 0,
        use_expressions => 1,
        plugin => [$plug],
    );
    my %p = (
        nf1 => $nf1,
        nf2 => $nf2,
        nums => {
            big => 123_456_789_123,
            big_dec => 123_456_789_123.765,
            price => 459.95,
            bytes1 => 1_024,
            bytes2 => 1_500,
            bytes3 => 1_500_000,
        },
    );
    $htc_plug->param( %p );

    for my $count (1, 2) {
        my $nf = $nf[$count - 1];
        $plug->formatter($nf);
        my $html = $t;
        $html =~ s/nfx/nf$count/g;
        my $htc = HTML::Template::Compiled->new(
            scalarref => \$html,
            debug => 0,
            use_expressions => 1,
        );
        $htc->param( %p );
        my $out = $htc->output;
        my $out_plug = $htc_plug->output;
        my $exp = '';
        $exp .= <<"EOM";
@{[ $nf->format_number($p{nums}->{big}) ]}
@{[ $nf->format_number($p{nums}->{big_dec}, 3) ]}
@{[ $nf->format_price($p{nums}->{price}) ]}
@{[ $nf->format_bytes($p{nums}->{bytes1}) ]}
@{[ $nf->format_bytes($p{nums}->{bytes2}) ]}
@{[ $nf->format_bytes($p{nums}->{bytes3}) ]}
EOM
        if (0) {
            binmode STDOUT, ":encoding(utf-8)";
print <<"EOM";
template:
$html
expected:
$exp
output:
$out
output plugin:
$out_plug
EOM
        }
        #$out =~ tr/\n\r //d;
        cmp_ok($out, "eq", $exp, "Number::Format $nf_version (expressions)");
        cmp_ok($out_plug, "eq", $exp, "Number::Format $nf_version (plugin)");
    }
}

