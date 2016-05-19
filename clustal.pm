package clustal;
use strict;

our $sequence="";
our $reference="";
our $results="";
<<<<<<< HEAD
our $clustalPath="/data/CLUSTAL/clustalw-2.1-linux-x86_64-libcppstatic/";
=======
our $file_path="/home/ec2-user/alignmentOutput/";
#our $file_path="/data/home/smartin/alignmentOutput/";
#our $clustalPath="/data/CLUSTAL/clustalw-2.1-linux-x86_64-libcppstatic/";
our $clustalPath="/home/ec2-user/clustalw-2.1-linux-x86_64-libcppstatic/";
>>>>>>> origin/master

sub execute_clustal
{
        my $query_seq=$_[0];
        my $subject_seq=$_[1];
		my $accession =$_[2];
		my $ref_accession=$_[3];
		my $nucleotideSequence = $_[4];
		my $file_path = $_[5];
		my $parseOutput=$_[6];

        open (IN_CLUSTAL,">$file_path"."inClustal");
        print IN_CLUSTAL ">Sequence,\n$query_seq\n";
        print IN_CLUSTAL ">Reference,\n$subject_seq\n";
        close IN_CLUSTAL;

        my $params="-INFILE=$file_path"."inClustal -align -QUIET -GAPOPEN=3 -GAPEXT=3";

        #system("~/CLUSTAL/clustalw-2.1-linux-x86_64-libcppstatic/clustalw2 $params");
	system($clustalPath."clustalw2 $params");


        open OUT_CLUSTAL, "$file_path"."inClustal.aln" or die $!;

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

        #delete temp files
        #unlink "$file_path"."inClustal";
	    #unlink "$file_path"."inClustal.aln";
        #unlink "$file_path"."inClustal.dnd";


	if ($parseOutput eq 'true') {	&parseClustalOutput($accession,$ref_accession, $nucleotideSequence); }
}

sub parseClustalOutput
{
	#print "$sequence\n$reference\n";

	#my $sequence = shift;
	#my $reference = shift;
	#my $file_path = shift;
	my $accession = shift;
	my $ref_accession = shift;
	my $nucleotideSequence = shift;
	
	my $sequenceStartPos = 0;
	my $sequenceEndPos = length($reference);

	#Regex precedingDashPattern = new Regex(@"^[\-]+");
	#Regex trailingDashPattern = new Regex(@"[\-]+$");

	#first restrict alignment to length of reference
	#chop dashes off front of alignment
	if ($reference =~ /^[\-]+/)
	{
		#print "found dashes at front of reference\n";

		#find number of preceding dashes
		my $indexOfSequenceBase = 0;
		for (my $i = 0; $i<length($reference); $i++) 
		{
			if (substr($reference,$i,1) ne "-") 
			{
				$indexOfSequenceBase = $i;
				last;
			}
		}

		#print $indexOfSequenceBase."\n";

		#chop sequence and reference by number of preceding dashes
		$sequence = substr($sequence, $indexOfSequenceBase);
		if (length($nucleotideSequence) > 0) 
		{ 
			$nucleotideSequence = substr($nucleotideSequence,$indexOfSequenceBase * 3); 
		}
		$reference = substr($reference, $indexOfSequenceBase);
	}

	#chop dashes off of end of alignment
	if ($reference =~ /[\-]+$/)
	{
		#print "found dashes at end of reference\n";
		
		#find number of trailing dashes
		my $indexOfSequenceBase = length($reference) - 1; 
                my $sequenceDeletionCount = 0;
		for (my $i = length($reference)-1; $i > 0; $i--)
                {
                        if (substr($reference,$i,1) ne "-")
                        {
                                $indexOfSequenceBase = $i;
				last;
                        }
			else 
			{
				$sequenceDeletionCount++;
			}
                }


		#chop sequence and reference by number of preceding dashes
		$sequence = substr($sequence, 0, $indexOfSequenceBase + 1);
		if (length($nucleotideSequence) > 0) 
		{ 
			$nucleotideSequence = substr($nucleotideSequence,0,($indexOfSequenceBase + 1 - $sequenceDeletionCount) * 3); 
		}
		$reference = substr($reference, 0, $indexOfSequenceBase + 1);
		
		$sequenceEndPos = length($reference) + $sequenceStartPos;
	}

	#then cut down reference and results if sequence is not full length of reference
	#chop dashes off the end of alignment
	if ($sequence =~ /[\-]+$/)
	{
		#print "found dashes at end of sequence\n";

		#find number of trailing dashes
		my $indexOfSequenceBase = length($sequence) - 1; 
		for (my $i = length($sequence)-1; $i > 0; $i--) 
		{
			if (substr($sequence,$i,1) ne "-") 
			{
				$indexOfSequenceBase = $i;
				last;
			}
		}
		#print $indexOfSequenceBase . "\n";

		$sequenceEndPos = $indexOfSequenceBase + $sequenceStartPos;

		#chop sequence and reference by number of preceding dashes
		$sequence = substr($sequence, 0, $indexOfSequenceBase + 1);
		$reference = substr($reference, 0, $indexOfSequenceBase + 1);
	}

	#chop dashes off the front of alignment
	if ($sequence =~ /^[\-]+/)
	{
		#print "found dashes at front of sequence\n";
		
		#find number of preceding dashes
		my $indexOfSequenceBase = 0;
                for (my $i = 0; $i<length($sequence); $i++)
                {
                        if (substr($sequence,$i,1) ne "-")
                        {
                                $indexOfSequenceBase = $i;
                                last;
                        }
                }

		#print $indexOfSequenceBase . "\n";

		$sequenceStartPos = $indexOfSequenceBase + $sequenceStartPos;

		#chop sequence
		$sequence = substr($sequence,$indexOfSequenceBase);
		$reference = substr($reference, $indexOfSequenceBase);
	}


	if (length($nucleotideSequence) > 0 && $sequence =~ /-/)
        {
            for (my $i = 0; $i < length($sequence); $i++)
            {
                #add deletion to nucleotide sequence
                if (substr($sequence,$i,1) eq "-")
                {
                    $nucleotideSequence = substr($nucleotideSequence,0, $i*3) . "---" . substr($nucleotideSequence,($i+1)*3 - 3);
                }
            }

            
        }

	#get positions of genes in reference_sequence - can be different per genotype
	###this could be a hive query as well
	my %reference_sequence_gene = getReferenceSequenceGeneHash($ref_accession);

	if (scalar(keys %reference_sequence_gene) <1)
	{
        	print "No reference sequence genes found for $ref_accession\n";
	        exit(0);
	} #cannot proceed if data not found


	#Parse the result strings into a list of positions
	open MUTATIONOUT, ">$file_path\/$accession\_mutation.csv" or die $!;
	my $position = $sequenceStartPos;
	my $insertionOffset = 0;
	foreach (keys %reference_sequence_gene)
	{
		my $gene = $_;
		my $mutationLength = 0;

		for (; $position + $insertionOffset < (length($sequence) + $sequenceStartPos)
			 && $position + $insertionOffset < (length($reference) + $sequenceStartPos)
			 && $position >= $reference_sequence_gene{$gene}{'startpos'}
			 && $position <= $reference_sequence_gene{$gene}{'endpos'}; )
		{
			$mutationLength++;
			my $readyToCreateMutation = 'false';

			#if reached end of sequence or insertion not found, then ready to create mutation
			if ($position - $sequenceStartPos + $mutationLength + $insertionOffset >= length($sequence))
			{
				$readyToCreateMutation = 'true';
			}
			elsif (substr($reference,$position - $sequenceStartPos + $mutationLength + $insertionOffset,1) ne "-")
			{
				$readyToCreateMutation = 'true';
			}

			if ($readyToCreateMutation)
			{
				my $aa_ref;
				my $aa_pos;
				my $aa_ins;
				my $aa_mut;
				my $aa_codon;

				for (my $j = 0; $j < $mutationLength; $j++)
				{
					$aa_mut = substr($sequence,($position - $sequenceStartPos + $insertionOffset + $j), 1);
					$aa_ins = $j;
					$aa_codon = substr($nucleotideSequence,($position - $sequenceStartPos + $insertionOffset + $j) * 3, 3);				
				}

				if ($aa_mut =~ /O/)
				{
					$aa_mut =~ s/O/\*/g;
				}

				$aa_ref = substr($reference,$position - $sequenceStartPos + $insertionOffset,1);
				if ($aa_ref =~ /O/) 
				{ 
					$aa_ref =~ s/O/\*/; 
				}

				$aa_pos = $position; 
				#pr.TherapeuticAreaID = ampliconGene.Value.TherapeuticAreaID;
				print MUTATIONOUT "$accession,$ref_accession,$gene,$aa_ref,$aa_pos,$aa_ins,$aa_mut,$aa_codon\n";
				
				$position++;

				#increment insertion offset if insertion found
				if ($mutationLength > 1)
				{
					$insertionOffset += $mutationLength - 1;
				}

				$mutationLength = 0; #reset codon length
			}
			#else iterate through loop again
	}
}

close MUTATIONOUT;
}

sub getReferenceSequenceGeneHash
{
        my $ref_accession = shift;
        my %ref_seq_gene_hash;

        open REFSEQGENE, "reference_sequence_gene.csv";
        while (<REFSEQGENE>) {
                chomp;
                my @data = split ',', $_;
                if ($data[0] eq $ref_accession)
                {
                        $ref_seq_gene_hash{$data[2]}{'startpos'} = $data[3];
                        $ref_seq_gene_hash{$data[2]}{'endpos'} = $data[4];
                }
        }

        return %ref_seq_gene_hash;
}


1;
