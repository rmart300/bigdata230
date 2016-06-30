/* id.pig */
--REGISTER file:/usr/hdp/lib/pig/piggybank.jar;
--REGISTER file:/usr/hdp/lib/jython.jar;

--command to execute pig script
--pig -f loadMutationsIntoHive.pig -param sequenceOutputFile="../alignmentOutput/KX185080_sequenceOutput.csv" -param alignmentOutputFile="../alignmentOutput/KX185080_mutation.csv" -param accession="KX185080" -useHCatalog

--#########################
--sampleMutationHive = LOAD 'sample_mutation' USING org.apache.hcatalog.pig.HCatLoader(); 
--sampleMuts = filter sampleMutationHive by accession = '$accession';
--sampleMutsCount = FOREACH (GROUP sampleMuts ALL) GENERATE COUNT(sampleMuts);

seqs = LOAD '$sequenceOutputFile' USING PigStorage(',')
as (accession:chararray,definition:chararray,nucleotide_sequence:chararray,amino_acid_sequence:chararray,date_obtained:chararray,subtype:chararray,subtype_homology:double,alignment_length:int,qframe:int,sframe:int,subtype_accession:chararray,reference_accession:chararray);

STORE seqs INTO 'sample_sequence' USING org.apache.hive.hcatalog.pig.HCatStorer();

muts = LOAD '$alignmentOutputFile' USING  PigStorage(',') 
as (accession:chararray,reference_accession:chararray,gene:chararray,aaref:chararray,aapos:int,aains:int,aasub:chararray,codon:chararray);

STORE muts INTO 'sample_mutation' USING org.apache.hive.hcatalog.pig.HCatStorer();
