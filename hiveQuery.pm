package hiveQuery;
use strict;

sub getReference 
{
	my $subtype = shift;
	my $refSubtype = substr($subtype,0,1) . 'a';
		
	######################query hive based on subtype
	return ($ref_accession, $reference_sequence);
}



sub getReferenceSequenceGeneHash
{
	my %reference_sequence_gene;
	my $gene = $contents[1];
		my $gene_start_pos = $contents[2];
		my $gene_end_pos = $contents[3];
		$reference_sequence_gene{$gene}{'startPos'} = $gene_start_pos;
		$reference_sequence_gene{$gene}{'endPos'} = $gene_end_pos;
}

1;
