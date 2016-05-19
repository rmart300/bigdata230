#!/usr/bin/bash
#https://www.mapr.com/blog/quick-tips-using-hive-shell-inside-scripts

accession="K123456"
queryFile="queryFile.fas"
subjectFile="reference_sequence_subtype.fas"

sampleMut=$(hive -S -e -hiveconf accession=$accession "use default; select count(*) from sample_mutation where accession = ${hiveconf:$accession});

if $sampleMut > 0 then
	exit(0)
fi

`perl consumer.pl $accession $queryFile $subjectFile`

`pig loadMutationsIntoHive.pig`

