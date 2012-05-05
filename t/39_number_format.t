# $Id: 18_objects.t 1019 2008-03-02 16:26:48Z tinita $

use constant TESTS => 1;
use Test::More tests => TESTS + 1;
use strict;
use warnings;
BEGIN { use_ok('HTML::Template::Compiled') };
my $nf = eval "use Number::Format 1.73; 1";

SKIP: {
    skip "no Number::Format 1.73", TESTS unless $nf;
    my $nf_version = Number::Format->VERSION;
    my $nf1 = Number::Format->new(
        -thousands_sep      => '.',
        -decimal_point      => ',',
        -int_curr_symbol    => "\x{20ac}",
        -kilo_suffix        => 'Kb',
        -mega_suffix        => 'Mb',
    );
    my $nf2 = Number::Format->new(
        -thousands_sep      => ',',
        -decimal_point      => '.',
        -int_curr_symbol    => '$',
        -kilo_suffix        => 'K',
        -mega_suffix        => 'M',
    );
my $t = <<"EOM";
<%= expr=".nfx.format_number(.nums{'big'}, 3)" %>
<%= expr=".nfx.format_number(.nums{'big_dec'}, 3)" %>
<%= expr=".nfx.format_price(.nums{'price'})" %>
<%= expr=".nfx.format_bytes(.nums{'bytes1'})" %>
<%= expr=".nfx.format_bytes(.nums{'bytes2'})" %>
<%= expr=".nfx.format_bytes(.nums{'bytes3'})" %>
EOM
    my $html = '';
    for (1, 2) {
        my $t = $t;
        $t =~ s/nfx/nf$_/g;
        $html .= $t;
    }
	my $htc = HTML::Template::Compiled->new(
		scalarref => \$html,
		debug => 0,
        use_expressions => 1,
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
	$htc->param(
        %p,
	);
	my $out = $htc->output;
    my $exp = '';
    for my $nf ($nf1, $nf2) {
        $exp .= <<"EOM";
@{[ $nf->format_number($p{nums}->{big}, 3) ]}
@{[ $nf->format_number($p{nums}->{big_dec}, 3) ]}
@{[ $nf->format_price($p{nums}->{price}) ]}
@{[ $nf->format_bytes($p{nums}->{bytes1}) ]}
@{[ $nf->format_bytes($p{nums}->{bytes2}) ]}
@{[ $nf->format_bytes($p{nums}->{bytes3}) ]}
EOM
    }
    if (1) {
        binmode STDOUT, ":encoding(utf-8)";
        print $html;
        print $exp;
    }
	#$out =~ tr/\n\r //d;
    #print $out,$/;
    cmp_ok($out, "eq", $exp, "Number::Format $nf_version");
}

