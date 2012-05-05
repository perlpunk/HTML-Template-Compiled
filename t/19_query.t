# $Id: 19_query.t 1088 2009-07-04 18:52:56Z tinita $
use warnings;
use strict;
use lib 'blib/lib';
use Test::More tests => 4;

HTML::Template::Compiled->clear_filecache('t/cache');
# test query() (From HTML::Template test suite)
use HTML::Template::Compiled;
use HTML::Template::Compiled::Lazy;
$HTML::Template::Compiled::NEW_CHECK = 1;
#$HTML::Template::Compiled::NEW_CHECK = 10000;
use File::Copy;
use Fcntl qw(:seek);
my $file_orig = File::Spec->catfile(qw(t templates query-test.tmpl));
my $file_copy = File::Spec->catfile(qw(t templates query-test-copy.tmpl));
copy($file_orig, $file_copy);
chmod 0644, $file_copy;
my $ok1 = query_template();
ok($ok1, "query 1");
#print `ls t/cache`;


if (1) {
    my $htc = HTML::Template::Compiled::Lazy->new(
        scalarref => \"<%= foo%>",
        use_query => 1,
    );
    my @params;
    eval {
        @params = $htc->query;
    };
    cmp_ok("@params", 'eq', 'foo', 'HTC::Lazy and query()');
}
sleep 3;
{
    open my $fh, '+<', $file_copy or die $!;
    local $/;
    my $data = <$fh>;
    seek $fh, SEEK_SET, 0;
    truncate $fh, 0;
    $data =~ s/EXAMPLE_INNER_LOOP/EXAMPLE_INNER_LOOP_TEST/;
    print $fh $data;
    close $fh;
}
my $ok2 = query_template();
ok(!$ok2, "query 2");
#exit;

sub query_template {
    local $HTML::Template::Compiled::DEFAULT_QUERY = 1;
    my $template = HTML::Template::Compiled->new(
        path     => 't/templates',
        filename => 'query-test-copy.tmpl',
        file_cache_dir => 't/cache',
        file_cache => 1,
    );
    my %params;
    eval {
        %params = map {$_ => 1} $template->query(loop => 'EXAMPLE_LOOP');
    };

    my @result;
    eval {
        @result = $template->query(loop => ['EXAMPLE_LOOP', 'BEE']);
    };

    my $ok = (
    $@ =~ /error/ and
    $template->query(name => 'var') eq 'VAR' and
    $template->query(name => 'included_var') eq 'VAR' and
    #$template->query(name => 'included_var2') eq 'VAR' and
       $template->query(name => 'EXAMPLE_LOOP') eq 'LOOP' and
       exists $params{bee} and
       exists $params{bop} and
       exists $params{example_inner_loop} and
       $template->query(name => ['EXAMPLE_LOOP', 'EXAMPLE_INNER_LOOP']) eq 'LOOP'
    );
    my $out = $template->output;
    $template->clear_cache;
    return $ok;

    print "out: $out\n";
}

{
    local $HTML::Template::Compiled::DEFAULT_QUERY = 1;
    # test query() (From HTML::Template test suite)
    my $template = HTML::Template::Compiled->new(                                
        path     => 't/templates',
        filename => 'query-test2.tmpl',
    );
    my %p;
    eval { %p = map {$_ => 1} $template->query(loop => ['LOOP_FOO', 'LOOP_BAR']); };
    ok(exists $p{foo} and exists $p{bar} and exists $p{bash}, "foo bar");
}

HTML::Template::Compiled->clear_filecache('t/cache');

unlink $file_copy;
