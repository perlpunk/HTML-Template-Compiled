# $Id: 27_chomp.t 977 2007-10-09 18:24:59Z tinita $
use warnings;
use strict;
use blib;
use lib 't';
use Test::More tests => 3;
use_ok('HTML::Template::Compiled');
use HTC_Utils qw($cache $tdir &cdir);

sub HTML::Template::Compiled::Test::bar {
    return $_[0]->[0]
}
sub HTML::Template::Compiled::Test::baz {
    return $_[0]->[1]
}

local $HTML::Template::Compiled::DEBUG = 1;
{
    local $HTML::Template::Compiled::DEBUG = 1;
    my $htc = HTML::Template::Compiled->new(
        scalarref => \<<'EOM',
<%= /foo.bar %>
<%= /foo.boo %>
<%= /foo.baz %>
EOM
        debug => 0,
    );
    my $obj = bless [23, 24], 'HTML::Template::Compiled::Test';
    $htc->param(foo => $obj);
    my $out;
    eval {
        $out = $htc->output;
    };
    ok($@, "Exception");
    if ($@) {
        #warn __PACKAGE__.':'.__LINE__.": $@\n";
        my $msg = $htc->debug_code;
        my $msg_html = $htc->debug_code(1);;
        #print $msg, $/;
        #print $msg_html, $/;
        cmp_ok($msg, '=~', qr/ ERROR line (\d+)/, 'Error message');
    }
    else {
        ok(0, 'Exception');
    }
}



