#!/usr/bin/perl
use strict;
use IO::Handle;
use ForkManager;

my $subjectFile=$ARGV[0];
my $referenceFile=$ARGV[1];
my $dirname = "tmp/";
my $ncbiFile = "ncbi_out.fas";

#system("perl","ncbi_fetch_seqs.pl",$ncbiFile);
#system("perl","parseMultiFasta.pl",$dirname,$ncbiFile);

#system("rm $ncbiFile");

opendir(DIR, $dirname) or die "can't opendir $dirname: $!";
my @array;
while (my $file = readdir(DIR)) {
    # do something with "$dirname/$file"
    push(@array, $file);
}

closedir(DIR);

my $pm = ForkManager->new(10);
for (my $i = 0; $i < @array; $i++)
{
    my $file = $array[$i];
    my $accession;
    if ($file =~ /(\w+)(\.)/) 
    { 
        $accession = $1; 

        print "Processing Sample: ".($i+1)."/".scalar(@array)."\n";
        my $pid = $pm->start and next;
        my $command = "perl consumer.pl $accession $dirname"."$file $subjectFile $referenceFile";
        print $command . "\n";
        system($command);
        $pm->finish;
        system("mv ". $dirname.$file ." ".$dirname."processed\$file");
    }
}

print "Waiting\n";
wait();
closedir(DIR);
