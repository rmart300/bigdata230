#get file from hadoop
#pig -f myscript.pig

#########################
#sampleMutationHive = LOAD 'sample_mutation' USING org.apache.hcatalog.pig.HCatLoader(); 
#sampleMuts = filter sampleMutationHive by accession = '$accession';
#sampleMutsCount = FOREACH (GROUP sampleMuts ALL) GENERATE COUNT(sampleMuts);

seqs = LOAD '$sequenceOutputFile' USING PigStorage(',')
as (accession:chararray,definition:chararray,nucleotide_sequence:chararray,amino_acid_sequence:chararray,date_obtained:chararray,subtype:chararray,subtype_homology:double,alignment_length:double,qframe:int,sframe:int,subtype_accession:chararray,reference_accession:chararray)

STORE seqs INTO 'sample_sequence' USING org.apache.hcatalog.pig.HCatStorer();

muts = LOAD '$alignmentOutputFile' USING  PigStorage(',') 
as (accession:chararray,reference_accession:chararray,gene:chararray,aaref:chararray,aapos:int,aains:int,aasub:chararray,codon:chararray);

STORE muts INTO 'sample_mutation' USING org.apache.hcatalog.pig.HCatStorer();