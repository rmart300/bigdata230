#!/usr/bin/perl;
use strict;
use sequence;
use blast;
#use hiveQuery;

my $accession = $ARGV[0];
my $blastQuery = $ARGV[1]; #fasta file with sample sequence - nucleotide
my $blastSubject = $ARGV[2]; #reference_sequence_subtype file - nucleotide
#my $ref_seq_gene_file = $ARGV[3];
my $topBlastHit;
my $homologyRef;
my $alignmentLength;
my $qframe;
my $sframe;
my $subtype;

###################### BLAST
($topBlastHit, $homologyRef, $alignmentLength, $qframe, $sframe) = blast::GetTopHit($blastQuery, $blastSubject);

if (length($topBlastHit) < 1) {
	print "No blast hit found for $accession\n";
	exit(1); #not HCV so exit
}
else {
	my @blastOutput = split('\|',$topBlastHit);
	$subtype = $blastOutput[2];
}

print "$topBlastHit $subtype\n";

open SEQFILE, "$blastQuery" or die $!;
my $nucleotideSequence;
my $seqCount=0;

while (<SEQFILE>) {
	chomp $_;
	if ($_ =~ />/) { $seqCount++; }
	elsif ($seqCount == 1) { $nucleotideSequence .= $_; }
	elsif ($seqCount > 1) { last; } #only read first sequence
}
close SEQFILE;

print "$nucleotideSequence\n";

####query hive table to get reference sequence
my ($ref_accession, $reference_sequence, $aa_ref_seq); # = hiveQuery::getReference($subtype);

###################### correct reading frame
$nucleotideSequence = sequence::correct_reading_frame($nucleotideSequence, $aa_ref_seq);

my $aa_sequence = sequence::convert_to_protein ($nucleotideSequence);

print "$nucleotideSequence\n$aa_sequence\n";

###################### CLUSTAL
#remove stop codons before alignment
$aa_sequence =~ s/\*/O/g;
$aa_ref_seq =~ s/\*/O/g;

#get positions of genes in reference_sequence - can be different per genotype
#this could be a hive query as well
my %reference_sequence_gene; # = hiveQuery::getReferenceSequenceGeneHash($ref_accession);

if (scalar(keys %reference_sequence_gene) <1) { exit(0); } #cannot proceed if data not found

my $sequence="";
my $reference="";
my $results="";
my $file_path="/tmp/alignment_output/$accession/";
mkdir($file_path);

clustal::execute_clustal($aa_sequence, $aa_ref_seq,$file_path,$sequence,$reference,$results);

clustal::parseClustalOutput($sequence, $reference, $file_path);
		
