# bigdata230

Final project steps

processing steps
producer = perl script
1 download file

kafka
2 parse file, send each sequence to consumer

consumer
Perl
#ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.3.0+-x64-linux.tar.gz
3 blast against subtype database
	get subtype

4 pick reference to use

5 convert to amino acid sequence, align to subtype reference
#http://www.clustal.org/download/current/clustalw-2.1-linux-x86_64-libcppstatic.tar.gz

6 parse alignment, store mutations by gene in flatfile
	

pig/spark/webhdfs	
7 check for existing accession

8 store sample_sequence, sample_gene	
	
9 store mutations by gene
	hive
	

hive data tables
create table sample_sequence (accession String, 
							  organism String,
							  definition String,
							  nucleotide_sequence String, 
							  amino_acid_sequence String, 
							  date_obtained String,
							  subtype String,
							  ref_homology Double,
							  alignment_length Double,
                              qString Double,
							  sString Double)
reference_sequence_gene (reference_sequence_id, subtype, gene, start_pos, end_pos)
sample_mutation (accession String, ref_accession String, gene String, refAA String, AApos String, AAins String, AAsub String)

spark analytics
