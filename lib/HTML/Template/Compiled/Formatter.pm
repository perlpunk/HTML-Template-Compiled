package HTML::Template::Compiled::Formatter;
# $Id: Formatter.pm 750 2006-10-11 21:52:24Z tinita $
use strict;
use warnings;
our $VERSION = "0.01";

use base 'HTML::Template::Compiled';

use vars qw($formatter);

1;

__END__

=head1 NAME

HTML::Template::Compiled::Formatter - HTC subclass for using a formatter

=head1 SYNOPSIS

    my $formatter = {
        'HTC::Class1' => {
            fullname => sub {
                $_[0]->first . ' ' . $_[0]->last
            },
            first => HTC::Class1->can('first'),
            last => HTC::Class1->can('last'),
        },
    };
    my $htc = HTML::Template::Compiled::Formatter->new(
        path => 't/templates',
        filename => 'formatter.htc',
        debug => 0,
    );
    my $obj = bless ({ first => 'Abi', last => 'Gail'}, 'HTC::Class1');

    $htc->param(
        test => 23,
        obj => $obj,
    );
    local $HTML::Template::Compiled::Formatter::formatter = $formatter;
    my $out = $htc->output;


=cut

