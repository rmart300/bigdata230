package clustal;
use strict;

sub execute_clustal{
        my $query_seq=$_[0];
        my $subject_seq=$_[1];
        my $file_path=$_[2];
        my $sequence=$_[3];
        my $reference = $_[4];
        my $results = $_[5];

        open (IN_CLUSTAL,">$file_path"."inClustal");
        print IN_CLUSTAL ">Sequence,\n$query_seq\n";
        print IN_CLUSTAL ">Reference,\n$subject_seq\n";
        close IN_CLUSTAL;

        my $params="-INFILE=$file_path"."inClustal -align -QUIET -GAPOPEN=3 -GAPEXT=3";

        system("~/CLUSTAL/clustalw-2.1-linux-x86_64-libcppstatic/clustalw2 $params");

        open OUT_CLUSTAL, "$file_path"."inClustal.aln";

        while(my $line=<OUT_CLUSTAL>){
                my @split=split(/\s+/,$line);

                if($line =~ /^Sequence/){
                        $sequence.=$split[1];

                        $line=<OUT_CLUSTAL>;
                        @split=split(/\s+/,$line);
                        $reference.=$split[1];

                        $line=<OUT_CLUSTAL>;
                        my $startPos=length($line)-length($split[1]);

                        $results .= substr($line,$startPos);
                }
        }
        close OUT_CLUSTAL;
        $_[3]=$sequence;
        $_[4]= $reference;
        $_[5]=$results;

        #delete temp files
        unlink "$file_path"."inClustal";
		unlink "$file_path"."inClustal.aln";
        unlink "$file_path"."inClustal.dnd";
}

sub parseClustalOutput
{
	my $sequence = shift;
	my $reference = shift;
	my $file_path = shift;
	
	my $sequenceStartPos = 0;
	my $sequenceEndPos = length($reference);

	#Regex precedingDashPattern = new Regex(@"^[\-]+");
	#Regex trailingDashPattern = new Regex(@"[\-]+$");

	#first restrict alignment to length of reference
	#chop dashes off front of alignment
	if ($reference =~ /^[\-]+/)
	{
		#find number of preceding dashes
		my $indexOfSequenceBase = index($reference,'\w');

		#chop sequence and reference by number of preceding dashes
		$sequence = substr($sequence, $indexOfSequenceBase);
		#if (!string.IsNullOrEmpty(nucleotideSequence)) { nucleotideSequence = nucleotideSequence.Substring(indexOfSequenceBase * 3); }
		$reference = substr($reference, $indexOfSequenceBase);
	}

	#chop dashes off of end of alignment
	if ($reference =~ /[\-]+$/)
	{
		#find number of trailing dashes
		my $indexOfSequenceBase = rindex($reference, '\w');

		#chop sequence and reference by number of preceding dashes
		$sequence = substr($sequence, 0, $indexOfSequenceBase + 1);
		#my sequenceDeletionCount = $sequence.Count<char>(s => s == '-');
		#if (!string.IsNullOrEmpty(nucleotideSequence)) { nucleotideSequence = nucleotideSequence.Substring(0, (indexOfSequenceBase + 1 - sequenceDeletionCount) * 3); }
		$reference = substr($reference, 0, $indexOfSequenceBase + 1);
		
		$sequenceEndPos = length($reference) + $sequenceStartPos;
	}

	#then cut down reference and results if sequence is not full length of reference
	#chop dashes off the end of alignment
	if ($sequence =~ /[\-]+$/)
	{
		#find number of trailing dashes
		my $indexOfSequenceBase = rindex($sequence, '\w');
		$sequenceEndPos = $indexOfSequenceBase + $sequenceStartPos;

		#chop sequence and reference by number of preceding dashes
		$sequence = substr($sequence, 0, $indexOfSequenceBase + 1);
		$reference = substr($reference, 0, $indexOfSequenceBase + 1);
		$results = substr(results, 0, $indexOfSequenceBase + 1);
	}

	#chop dashes off the front of alignment
	if ($sequence =~ /[\-]+$/)
	{
		#find number of preceding dashes
		my $indexOfSequenceBase = index($sequence, '\w');
		$sequenceStartPos = $indexOfSequenceBase + $sequenceStartPos;

		#chop sequence
		$sequence = substr($sequence,$indexOfSequenceBase);
		$reference = substr($reference, $indexOfSequenceBase);
	}

	#Parse the result strings into a list of positions
	open MUTATIONOUT, ">$file_path/$accession_mutation.csv" or die $!;
	my $position = $sequenceStartPos;
	my $insertionOffset = 0;
	foreach (keys %reference_sequence_gene)
	{
		my $gene = $_;
		my $mutationLength = 0;

		for (; $position + $insertionOffset < (length($sequence) + $sequenceStartPos)
			 && $position + $insertionOffset < (length($reference) + $sequenceStartPos)
			 && $position >= $reference_sequence_gene{$gene}{'startPos'};
			 && $position <= $reference_sequence_gene{$gene}{'endPos'}; )
		{
			$mutationLength++;
			my $readyToCreateMutation = 'false';

			#if reached end of sequence or insertion not found, then ready to create mutation
			if ($position - $sequenceStartPos + $mutationLength + $insertionOffset >= length($sequence))
				$readyToCreateMutation = 'true';
			else if ($reference[$position - $sequenceStartPos + $mutationLength + $insertionOffset] != '-')
				$readyToCreateMutation = 'true';

			if ($readyToCreateMutation)
			{
				my $aa_ref;
				my $aa_pos;
				my $aa_ins;
				my $aa_mut;
				my $aa_codon;

				for (my $j = 0; $j < $mutationLength; $j++)
				{
					$aa_mut = substr($sequence,($position - $sequenceStartPos + $insertionOffset + j), 1);
					$aa_ins = $j;
					$aa_codon += substr($nucleotideSequence,($position - $sequenceStartPos + $insertionOffset + $j) * 3, 3);				
				}

				if ($aa_mut =~ /O/))
				{
					$aa_mut =~ s/O/\*/g;
				}

				$aa_ref = $reference[$position - $sequenceStartPos + $insertionOffset];
				if ($aa_ref =~ /O/) { $aa_ref =~ s/O/\*/; }

				$aa_pos = $position; 
				#pr.TherapeuticAreaID = ampliconGene.Value.TherapeuticAreaID;
				print MUTATIONOUT "$gene,$aa_ref,$aa_pos,$aa_ins,$aa_mut,$aa_codon\n";
				
				$position++;

				#increment insertion offset if insertion found
				if ($mutationLength > 1)
					$insertionOffset += $mutationLength - 1;

				$mutationLength = 0; #reset codon length
			}
			#else iterate through loop again
	}
}

close MUTATIONOUT;
}

1;
