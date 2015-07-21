#!/usr/bin/perl
use strict;
use warnings;

use HTML::Template::Compiled;

use Archive::Tar;
my $tar = Archive::Tar->new;

#use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
#my $zip = Archive::Zip->new();

HTML::Template::Compiled->clear_filecache('t/cache');
{
    my $templates = HTML::Template::Compiled->precompile(
        path     => 't/templates',
        cache_dir => 't/cache',
        filenames => [@ARGV],
    );
    warn Data::Dumper->Dump([\$templates], ['templates']);
    my $out = $templates->[0]->output;
    print "out: '$out'\n";
    opendir my $dh, 't/cache' or die $!;
    my @tarfiles;
    while (my $file = readdir $dh) {
        next unless $file =~ m/\.pl\z/;
#        my $member = $zip->addFile( "t/cache/$file" );
        push @tarfiles, "t/cache/$file";
    }
    $tar->add_files(@tarfiles);
    $tar->write('files.tar.gz', 1);
    #$tar->write('files.tar', 0);
    #unless ($zip->writeToFileNamed( 'someZip.zip' ) == AZ_OK) {
    #    die 'write error'
    #}

}
HTML::Template::Compiled->clear_filecache('t/cache');




