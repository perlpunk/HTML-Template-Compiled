
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl HTML-Template-Compiled.t'
# $Id: 25_translate.t 1151 2012-04-21 21:46:30Z tinita $

use lib 'blib/lib';
use Test::More tests => 6;
BEGIN { use_ok('HTML::Template::Compiled') };
use lib 't';
use HTC_Utils qw($cache $tdir &cdir);
use strict;
use warnings;
my $class_accessor = eval "use Class::Accessor::Fast; 1";
my $file = cdir('translate.html');

my %map = (
    de => {
        foo => [qw/ Perle Perlen /],
        bar => [qw/ Telefon Telefone /],
    },
    en => {
        foo => [qw/ Pearl Pearls /],
        bar => [qw/ Phone Phones /],
    },
);
SKIP: {
    skip "No Class::Accessor::Fast installed", 5 unless $class_accessor;
    use_ok('HTML::Template::Compiled::Plugin::Translate');
my $plug = HTML::Template::Compiled::Plugin::Translate->new({});
for my $filecache (0, 1) {
    for my $lang (qw/ de en /) {
        $plug->set_map($map{$lang});
        my $htc = HTML::Template::Compiled->new(
            path => $tdir,
            plugin => [$plug],
            filename => $file,
            $filecache ?  (
                file_cache => 0,
                file_cache_dir => $cache,
                cache => 1,
            ) : (
                cache => 1,
            ),
            loop_context_vars => 1,
            search_path_on_include => 1,
            debug => 0,
        );
#        $htc->param(
#            included => 'translate_included.html',
#        );
        #my $test = $htc->get_plugin('HTML::Template::Compiled::Plugin::Translate');
        #warn __PACKAGE__.':'.__LINE__.": ***** ref  $test\n";
        #warn __PACKAGE__.':'.__LINE__.": ***** orig $plug\n";
        #$htc->get_plugin('HTML::Template::Compiled::Plugin::Translate')->set_map($map{$lang});

        my $out = $htc->output;
        #print $out, $/;
        $out =~ s/\s+//g;
        my $exp = $map{$lang}->{foo}->[1] . $map{$lang}->{bar}->[0];
        #my $exp = $map{$lang}->{foo}->[1] . $map{$lang}->{bar}->[0] . $map{$lang}->{bar}->[0];
        cmp_ok($out, 'eq', $exp, "Translate $lang (filecache: $filecache)");
    }
}
}


