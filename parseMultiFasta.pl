#!/usr/bin/perl
use strict;

my $dir = $ARGV[0];
my $inputFile = $ARGV[1];
open IN, "$inputFile" or die $!;

my ($header, $old_sequence, $new_sequence) = "";
my (%nucleotide_hash);

while (<IN>) {
         chomp;

         #if first character is > then header line
         if ($_ =~ m/>/) {
            $header = $_;
            $old_sequence = "";
         }
         #if first character is letter then sequence line
         elsif ($_ =~ m/\w+/) {
            $_ =~ s/-//g;
            $old_sequence .= $_; #add sequence line to existing sequence
        }
        else {
          #do nothing if blank line
        }
        
        $nucleotide_hash{$header} = $old_sequence;
}
close IN;

foreach my $key (keys %nucleotide_hash) {
    my @keyArray = split /\|/, $key;
    my $accession = $keyArray[3];
    if ($keyArray[3] =~ /(\w+)(.)(\d+)/) {
        $accession = $1;
    }

    open OUTPUT, ">$dir/$accession\.fas";
    print OUTPUT "$key\n" . $nucleotide_hash{$key} . "\n";
    close OUTPUT;
}
