use Test::More tests => 6;
BEGIN { use_ok('HTML::Template::Compiled') };
use lib 't';
use HTC_Utils qw($tdir &cdir &create_cache &remove_cache);
my $cache_dir = "cache25";
$cache_dir = create_cache($cache_dir);
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
                file_cache => 1,
                file_cache_dir => $cache_dir,
                cache => 0,
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


HTML::Template::Compiled->clear_filecache($cache_dir);
remove_cache($cache_dir);
