# $Id: 24_pod_cover.t 668 2006-10-02 16:09:19Z tinita $

use Test::More;
eval "use Test::Pod::Coverage 1.00";
plan skip_all => "Test::Pod::Coverage required for testing pod coverage" if $@;
plan tests => 5;
# thanks to mark, at least HTC::Utils is covered...
pod_coverage_ok( "HTML::Template::Compiled::Utils", "HTC::Utils is covered");
pod_coverage_ok( "HTML::Template::Compiled::Plugin::XMLEscape", "HTC::Plugin::XMLEscape is covered");
pod_coverage_ok( "HTML::Template::Compiled::Classic", "HTML::Template::Compiled::Classic is covered");
pod_coverage_ok( "HTML::Template::Compiled::Plugin::DHTML", "HTML::Template::Compiled::Plugin::DHTML is covered");
pod_coverage_ok( "HTML::Template::Compiled::Plugin::NumberFormat", "HTML::Template::Compiled::Plugin::NumberFormat is covered");

