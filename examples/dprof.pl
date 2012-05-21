#!/usr/bin/perl
use strict;
use warnings;
my ($type, $num) = @ARGV;
$type ||= 'htc';
$num ||= 2000;

my %params = (
  name => 'merlyn',
  loopa => [{a=>3},{a=>4},{a=>5}],
  #a => [qw(b c d)],
  loopb => [{ inner => 23 }],
  c => [
   {
     d=>[({F=>11},{F=>22}, {F=>33})]
   },
  {
    d=>[({F=>44}, {F=>55}, {F=>66})]
  }
  ],
  if2 => 1,
  if3 => 0,
  blubber => "html <test>",
);


if ($type eq 'htc') {
	require HTML::Template::Compiled;
	for (1 .. $num) {
		my $htc = HTML::Template::Compiled->new_file('test.htc',
			path => 'examples',
            tagstyle => [qw(-classic -comment +asp)],
			#case_sensitive => 0, # slow down
			loop_context_vars => 1,
			#filename => 'test.htc.20',
            #filename => 'test.htc',
            #file_cache_dir => "cache/htc",
            # file_cache => 1,
            cache => 1,
		);
		$htc->param(%params);

	}
}
else {
	require HTML::Template;
	for (1 .. $num) {
		my $ht = HTML::Template->new_file('test.htc',
			path => 'examples',
			#case_sensitive => 0, # slow down
			loop_context_vars => 1,
			cache => 1,
		);
		$ht->param(%params);
	}
}  
 

