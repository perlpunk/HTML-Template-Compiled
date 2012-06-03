package HTML::Template::Compiled::Plugin::NumberFormat;
use strict;
use warnings;
use base 'Class::Accessor::Fast';
__PACKAGE__->mk_accessors(qw/ formatter /);
use Number::Format ();
use HTML::Template::Compiled;
HTML::Template::Compiled->register(__PACKAGE__);
our $VERSION = '0.01';

sub register {
    my ($class) = @_;
    my %plugs = (
        escape => {
            # <tmpl_var foo escape=format_bytes >
            FORMAT_NUMBER => {
                code => \&format_number,
                arguments => [qw/ var self /],
            },
            FORMAT_BYTES => {
                code => \&format_bytes,
                arguments => [qw/ var self /],
            },
            FORMAT_PRICE => {
                code => \&format_price,
                arguments => [qw/ var self /],
            },
        },
        tagnames => {
            HTML::Template::Compiled::Token::OPENING_TAG() => {
                FORMAT_NUMBER => [sub { exists $_[1]->{NAME} }, qw/ TYPE PRECISION TRAILING_ZEROES /],
            },
        },
        compile => {
            FORMAT_NUMBER => {
                open => \&_compile_format_number,,
            },
        },
    );
    return \%plugs;
}

sub format_number {
    my ($var, $self) = @_;
    $self->formatter->format_number($var);
}

sub format_bytes {
    my ($var, $self) = @_;
    $self->formatter->format_bytes($var);
}

sub format_price {
    my ($var, $self) = @_;
    $self->formatter->format_price($var);
}

sub _compile_format_number {
    my ($htc, $token, $args) = @_;
    my $OUT = $args->{out};
    my $attr = $token->get_attributes;
    my $var = $attr->{NAME};
    $var = $htc->var2expression($var);
    my $type = $attr->{TYPE} || 'number';
    my $method = 'format_number';
    my @args;
    if (lc $type eq 'number') {
        $method = 'format_number';
        my $precision = $attr->{PRECISION};
        my $trailing_zeroes = $attr->{TRAILING_ZEROES};
        for ($precision, $trailing_zeroes) {
            if (defined $_ and length $_) {
                $_ =~ tr/0-9//cd;
                $_ ||= 0;
            }
            else {
                $_ = 'undef';
            }
            push @args, $_;
        }
    }
    elsif (lc $type eq 'price') {
        $method = 'format_price';
    }
    elsif (lc $type eq 'bytes') {
        $method = 'format_bytes';
    }
    local $" = ',';
    my $expression = <<"EOM";
    $OUT \$t->get_plugin('HTML::Template::Compiled::Plugin::NumberFormat')->formatter->$method($var, @args);
EOM
    return $expression;
}

1;

__END__

=pod

=head1 NAME

HTML::Template::Compiled::Plugin::NumberFormat - Plugin for formatting numbers, bytes in templates

=head1 SYNOPSIS

    use HTML::Template::Compiled::Plugin::NumberFormat;
    my $plugin = HTML::Template::Compiled::Plugin::NumberFormat->new({
        formatter => Number::Format->new(...),
    });

    my $htc = HTML::Template::Compiled->new(
        plugin => [$plugin],
        ...
    );
    my $out = $htc->output;
    $plugin->formatter($another_number_format_object);
    $out = $htc->output;

=head1 DESCRIPTION

This plugin implements escapes ("filters") for easy use and tag names
if you need more arguments.

    use HTML::Template::Compiled::Plugin::NumberFormat;
    my $plugin = HTML::Template::Compiled::Plugin::NumberFormat->new({
        formatter => Number::Format->new(...),
    });
    my $htc = HTML::Template::Compiled->new(
        plugin => [$plugin],
        scalarref => \<<"EOM",
number with different precision than the one set in the object:
<%format_number .nums.big_dec precision=3 %>

escapes using the object settings:
<%= .nums.big escape=format_number %>
<%= .nums.price escape=format_price %>
<%= .nums.bytes1 escape=format_bytes %>
<%= .nums.bytes2 escape=format_bytes %>
<%= .nums.bytes3 escape=format_bytes %>
EOM
    );
    $htc->param(
        ...
    );
    print $htc->output;

=head1 METHODS

=over 4

=item register

gets called by HTC

=item format_number

calls $number_format->format_number

=item format_bytes

calls $number_format->format_bytes

=item format_price

calls $number_format->format_price

=back

=cut

