#!/usr/bin/perl;
use strict;
use sequence;
use blast;
use clustal;
use POSIX qw(strftime);

my $accession = $ARGV[0];
my $blastQuery = $ARGV[1]; #fasta file with sample sequence - nucleotide
my $blastSubject = $ARGV[2]; #reference_sequence_subtype file - nucleotide
my $referenceSequenceFile = $ARGV[3];
my $alignmentOutputPath="/tmp/bigdata230/alignmentOutput/";
my $topBlastHit;
my $blastAccession;
my $homologyRef;
my $alignmentLength;
my $qframe;
my $sframe;
my $subtype;
my $refSubtype;

###################### BLAST
($topBlastHit, $homologyRef, $alignmentLength, $qframe, $sframe) = blast::GetTopHit($blastQuery, $blastSubject, $accession);

if (length($topBlastHit) < 1) {
	print "No blast hit found for $accession\n";
	exit(1); #not HCV so exit
}
else {
	my @blastOutput = split('\|',$topBlastHit);
	$blastAccession = $blastOutput[1];
	$subtype = $blastOutput[2];
}

$refSubtype = getRefSubtype($subtype);

#print "TopBlastHit\: $topBlastHit Subtype\: $subtype ReferenceSubtype\: $refSubtype\n";

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

####query hive table to get reference sequence
my ($ref_accession, $reference_sequence, $aa_ref_seq) = &getReference($refSubtype);

###################### correct reading frame
$nucleotideSequence = sequence::correct_reading_frame($nucleotideSequence, $aa_ref_seq);

my $aa_sequence = sequence::convert_to_protein ($nucleotideSequence);

my $date_obtained = strftime "%m/%d/%Y", localtime;
print "$alignmentOutputPath$accession\_sequenceOutput.csv\n";
open SEQOUT, ">$alignmentOutputPath$accession\_sequenceOutput.csv" or die $!;
print SEQOUT "$accession,,$nucleotideSequence,$aa_sequence,$date_obtained,$subtype,$homologyRef,$alignmentLength,$qframe,$sframe,$blastAccession,$ref_accession";
close SEQOUT or die$

###################### CLUSTAL
#remove stop codons before alignment
$aa_sequence =~ s/\*/O/g;
$aa_ref_seq =~ s/\*/O/g;

clustal::execute_clustal($aa_sequence, $aa_ref_seq,$accession,$ref_accession,$nucleotideSequence,$alignmentOutputPath,'true');

#####################

sub getRefSubtype 
{
	my $subtype = shift;
	if ($subtype eq '1b' || $subtype eq '2b') { return $subtype; }
	else 
	{
		return substr($subtype,0,1) . 'a';
	}
}

sub getReference
{
	my $subtype = shift;
	open REF, $referenceSequenceFile;
	while (<REF>) 
	{
		chomp;
		my @lineContents = split ',', $_;
		if ($subtype eq $lineContents[1])
		{
			return ($lineContents[0],$lineContents[2],$lineContents[3]);
		}
	}

	die "reference sequence not found\n";
}

