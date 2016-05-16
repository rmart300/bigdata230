package sequence;
use strict;

sub correct_reading_frame
{
	my $nucleotideSequence;
	my $reference_sequence;
	
	#translate in each frame
    my $firstFrame = convert_to_protein($nucleotideSequence);
    my $secondFrame = convert_to_protein(substr($nucleotideSequence,1, length($nucleotideSequence) - 1));
    my $thirdFrame = convert_to_protein(substr($nucleotideSequence, 2, length($nucleotideSequence) - 2));
	
	my $firstFrameScore = 0;
    my $secondFrameScore = 0;
    my $thirdFrameScore = 0;

    my %refAAseeds;
	for (my $i = 0; $i < length($reference_sequence) - 2; $i += 3)
	{
		if (length($reference_sequence) >= $i + 3) {
			$refAAseeds{$i} = substr($reference_sequence,$i, 3);
		}
	}

	for (my $a = 0; $a < length($firstFrame) - 2; $a++)
	{
		my $seed = substr($firstFrame, $a, 3);
		if (exists $refAAseeds{$seed}) { $firstFrameScore++; }
	}

	for (my $b = 0; $b < length($secondFrame) - 2; $b++)
	{
		my $seed = substr($secondFrame, $b, 3);
		if (exists $refAAseeds{$seed}) { $secondFrameScore++; }
	}

	for (my $c = 0; $c < length($thirdFrame) - 2; $c++)
	{
		my $seed = substr($thirdFrame,$c, 3);
		if (exists $refAAseeds{$seed}) { $thirdFrameScore++; }
	}

	if ($firstFrameScore >= $secondFrameScore && $firstFrameScore >= $thirdFrameScore)
	{
		return $nucleotideSequence;
	}
	elsif ($secondFrameScore >= $thirdFrameScore && $secondFrameScore > $firstFrameScore)
	{
		return substr($nucleotideSequence,1, length($nucleotideSequence) - 1);
	}
	else
	{
		return substr($nucleotideSequence,2, length($nucleotideSequence) - 2);
	}
}

sub convert_to_protein {

        my %aa = ("CTT" => "L", "CCT" => "P", "CAT" => "H", "CGT" => "R",
                   "CTC" => "L", "CCC" => "P", "CAC" => "H", "CGC" => "R",
                   "CTA" => "L", "CCA" => "P", "CAA" => "Q", "CGA" => "R",
                   "CTG" => "L", "CCG" => "P", "CAG" => "Q", "CGG" => "R",
                   "ATT" => "I", "ACT" => "T", "AAT" => "N", "AGT" => "S",
                   "ATC" => "I", "ACC" => "T", "AAC" => "N", "AGC" => "S",
                   "ATA" => "I", "ACA" => "T", "AAA" => "K", "AGA" => "R",
                   "ATG" => "M", "ACG" => "T", "AAG" => "K", "AGG" => "R",
                   "GTT" => "V", "GCT" => "A", "GAT" => "D", "GGT" => "G",
                   "GTC" => "V", "GCC" => "A", "GAC" => "D", "GGC" => "G",
                   "GTA" => "V", "GCA" => "A", "GAA" => "E", "GGA" => "G",
                   "GTG" => "V", "GCG" => "A", "GAG" => "E", "GGG" => "G",
                   "TTT" => "F", "TCT" => "S", "TAT" => "Y", "TGT" => "C",
                   "TTC" => "F", "TCC" => "S", "TAC" => "Y", "TGC" => "C",
                   "TTA" => "L", "TCA" => "S", "TAA" => "*", "TGA" => "*",
                   "TTG" => "L", "TCG" => "S", "TAG" => "*", "TGG" => "W",
        #A mixtures
        "GCB" => "A", "GCD" => "A", "GCH" => "A", "GCK" => "A",
        "GCM" => "A", "GCN" => "A", "GCR" => "A", "GCS" => "A",
        "GCV" => "A", "GCW" => "A", "GCY" => "A",
        #R mixtures
        "CGB" => "R", "CGD" => "R", "CGH" => "R", "CGK" => "R",
        "CGM" => "R", "CGN" => "R", "CGR" => "R", "CGS" => "R",
        "CGV" => "R", "CGW" => "R", "CGY" => "R", "AGR" => "R",
        #N mixtures
        "AAY" => "N",
        #D mixtures
        "GAY" => "D",
        #C mixtures
        "TGY" => "C",
        #Q mixtures
        "CAR" => "Q",
        #E mixtures
        "GAR" => "E",
		#G mixtures
        "GGB" => "G", "GGD" => "G", "GGH" => "G", "GGK" => "G",
        "GGM" => "G", "GGN" => "G", "GGR" => "G", "GGS" => "G",
        "GGV" => "G", "GGW" => "G", "GGY" => "G",
        #H mixtures
        "CAY" => "H",
        #I mixtures
        "ATH" => "I", "ATM" => "I", "ATW" => "I", "ATY" => "I",
        #L mixtures
        "CTB" => "L", "CTD" => "L", "CTH" => "L", "CTK" => "L",
        "CTM" => "L", "CTN" => "L", "CTR" => "L", "CTS" => "L",
        "CTV" => "L", "CTW" => "L", "CTY" => "L", "TTR" => "L",
        #K mixtures
        "AAR" => "K",
        #F mixtures
        "TTY" => "F",
        #P mixtures
        "CCB" => "P", "CCD" => "P", "CCH" => "P", "CCK" => "P",
        "CCM" => "P", "CCN" => "P", "CCR" => "P", "CCS" => "P",
        "CCV" => "P", "CCW" => "P", "CCY" => "P",
        #S mixtures
        "TCB" => "S", "TCD" => "S", "TCH" => "S", "TCK" => "S",
        "TCM" => "S", "TCN" => "S", "TCR" => "S", "TCS" => "S",
        "TCV" => "S", "TCW" => "S", "TCY" => "S", "AGY" => "S",
        #T mixtures
        "ACB" => "T", "ACD" => "T", "ACH" => "T", "ACK" => "T",
        "ACM" => "T", "ACN" => "T", "ACR" => "T", "ACS" => "T",
        "ACV" => "T", "ACW" => "T", "ACY" => "T",
        #Y mixtures
        "TAY" => "Y",
        #V mixtures
        "GTB" => "V", "GTD" => "V", "GTH" => "V", "GTK" => "V",
        "GTM" => "V", "GTN" => "V", "GTR" => "V", "GTS" => "V",
        "GTV" => "V", "GTW" => "V", "GTY" => "V",
                  );

        my(@codons, $protein_seq);  #initialize variables
        my $orf = shift;    #read the nucleotide sequence
        #print "Orf: " . $orf . "\n";
        my $orflength = length($orf);    #get the length of the ORF

		#Now extract each codon (3 bp) from the string and place it
        #into an array - use a loop that increments $i (the offset)
        #by 3 every loop until you reach the end of the string, then
        #use the substring function to take 3 bases at a time
        #and push them onto an array

        for (my $i = 0; $i < $orflength; $i += 3) {
                if (length(substr($orf, $i, 3)) == 3) {
                        push(@codons, substr($orf, $i, 3));
                }
        }
        #Now use the hash to translate each codon

        foreach my $codon (@codons) {
            #add value for each key to end of protein seq
            if ($codon eq "---") {
                $protein_seq .= "-"; #deletion
            }
            elsif ($aa{$codon} and $aa{$codon} =~ m/[A-Z*]/) {
                $protein_seq .= $aa{$codon};
            }
            else {
                $protein_seq .= "X"; #if not found put in mixture code
            }
        }

        return $protein_seq;
}

1;
