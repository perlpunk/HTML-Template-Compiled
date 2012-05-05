#!/usr/bin/perl
use blib;
use Test::More qw/no_plan/;
use HTML::Template::Compiled;

# Tests for the "new_" shortcuts

new_filehandle: { 
    open(TEMPLATE, "t/templates/simple.tmpl") || croak $!;
    $t = HTML::Template::Compiled->new_filehandle(*TEMPLATE);
    $t->param('ADJECTIVE', 'very');
    like ($t->output, qr/very/ ); 
    close(TEMPLATE);
}

new_file: {
    $t = HTML::Template::Compiled->new_file('t/templates/simple.tmpl');
    $t->param('ADJECTIVE', 'very');
    like ($t->output, qr/very/ ); 
}

new_scalar_ref: {
    $t = HTML::Template::Compiled->new_scalar_ref(
        \'IIII am a <TMPL_VAR NAME="ADJECTIVE"> simple template.'
    );
    $t->param('ADJECTIVE', 'very');
    like ($t->output, qr/very/ ); 
}

new_array_ref: {
    $t = HTML::Template::Compiled->new_array_ref(
        ['I am a <TMPL_VAR NAME="ADJECTIVE"> simple template.']
    );
    $t->param('ADJECTIVE', 'very');
    like ($t->output, qr/very/ ); 
}


type_filename: {
    $t = HTML::Template::Compiled->new_file('t/templates/simple.tmpl');
    my $t = HTML::Template::Compiled->new(type => 'filename', 
                                      source => 't/templates/simple.tmpl');
    $t->param('ADJECTIVE', 'very');
    like ($t->output, qr/very/ ); 
}

short: {
    use HTML::Template::Compiled short => 1;
    my $htc = HTC(
        scalarref => \"foo",
    );
    my $out = $htc->output;
    cmp_ok($out, 'eq', "foo", "HTC() shortcut");
}
