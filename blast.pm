package blast;
use strict;

our $blastnExecutable = "/usr/local/ncbi-blast-2.3.0+/bin/blastn";
our $blastOutputPath = "/tmp/bigdata230/blastOutput/";
our $blastOutfmt = 10;

sub GetTopHit {
        my $queryFile = shift;
        my $subjectFile = shift;
        my $accession = shift;
        my $blastOutput = $blastOutputPath . $accession . ".csv";

        system("$blastnExecutable -outfmt \"$blastOutfmt\" -query $queryFile -subject $subjectFile -num_alignments 1 > $blastOutput");

        open BLASTOUT, "$blastOutput" or die $!;
        my %resultsHash;

        my $subject;
        my $query;
        my $alignmentLength;
		my $homology;
        my $qframe;
        my $sframe;
        while (<BLASTOUT>) {
                chomp;
                my $line = $_;
                my @lineContents = split ',', $line;

                $query = $lineContents[0];
                $subject = $lineContents[1];
                $homology = $lineContents[2];
                $alignmentLength = $lineContents[3];
                $qframe = $lineContents[4];
                $sframe = $lineContents[5];
        }

        close BLASTOUT or die $!;
        #`rm "$blastOutput"`;

        return ($subject, $homology, $alignmentLength,$qframe,$sframe);
}

1;
