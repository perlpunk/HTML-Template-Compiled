# $Id: 21_while.t 1078 2008-09-09 20:44:07Z tinita $
use warnings;
use strict;
use lib qw(blib/lib t);
use Test::More tests => 5;
use_ok('HTML::Template::Compiled');
use HTC_Utils qw($cache $tdir &cdir);


{
    my $class = 'HTML::Template::Compiled::__Test';
    my $iterator = bless [undef,[23..25]], $class;
    my $next = sub {
        my ($self) = @_;
        my $index = $self->[0];
        my $array = $self->[1];
        return unless @$array;
        unless (defined $index) {
            $self->[0] = $index = 0;
        }
        elsif ($index < $#$array) {
            $self->[0] = ++$index;
        }
        else {
            $self->[0] = undef;
            return;
        }
        return $array->[$index];
    };
    {
        no strict 'refs';
        *{$class."::next"} = $next;
    }

    my $htc = HTML::Template::Compiled->new(
        filehandle => \*DATA,
        debug => 0,
        loop_context_vars => 1,
    );
    #while (my $row = $iterator->next) {
        #print "row $row\n";
        #}
    $htc->param(iterator => $iterator);
    my $out = $htc->output;
    cmp_ok($out,"=~", qr{
        23.*1odd.*
        24.*2.*
        25.*3odd.*
        23.*1odd.*
        24.*2.*
        25.*3odd}xs, "while");
    #print "out: $out\n";

}

{
    my $htc = HTML::Template::Compiled->new(
        scalarref => \'
<%each letters%><%= __key__ %>=<%= __value__ %><%/each%>
<%each numbers sort=num %><%= __key__ %>=<%= __value__ %><%/each%>
<%each numbers sort=num reverse=1 %><%= __key__ %>=<%= __value__ %><%/each%>',
        debug => 0,
        loop_context_vars => 1,
    );
    $htc->param(letters => { a => 1, b => 2, c => 3 });
    $htc->param(numbers => { 21 => 'b', 2 => 'a', 100 => 'c' });
    my $out = $htc->output;
    #print "out: $out\n";
    cmp_ok($out, '=~', 'a=1b=2c=3', 'each alpha sort');
    cmp_ok($out, '=~', '2=a21=b100=c', 'each numeric sort');
    cmp_ok($out, '=~', '100=c21=b2=a', 'each numeric sort');

}


__DATA__
<%with iterator%>
<%while next %>
    <%VAR NAME="_" %>
    <%= __counter__ %><%if __odd__ %>odd<%/if%>
<%/while%>
<%while next alias=hiThere%>
    <%VAR NAME="hiThere" %>
    <%= __counter__ %><%if __odd__ %>odd<%/if%>
<%/while%>
<%/with iterator%>

