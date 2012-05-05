#!/usr/bin/perl
use strict;
use warnings;
use lib 'blib/lib';
$ARGV[0] ||= 'htc';

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


if ($ARGV[0] eq 'htc') {
	require HTML::Template::Compiled;
	for (0..2000) {
		my $htc = HTML::Template::Compiled->new_file('test.htc',
			path => 'examples',
            tagstyle => [qw(-classic -comment +asp)],
			#case_sensitive => 0, # slow down
			loop_context_vars => 1,
			#filename => 'test.htc.20',
            #filename => 'test.htc',
            #file_cache_dir => "cache/htc",
            # file_cache => 1,
            cache => 0,
		);
		$htc->param(%params);

	}
}
else {
	require HTML::Template;
	for (0..1000) {
		my $ht = HTML::Template->new(
			path => 'examples',
			#case_sensitive => 0, # slow down
			loop_context_vars => 1,
			filename => 'test.htc',
			cache => 1,
		);
		$ht->param(%params);
	}
}  
 

