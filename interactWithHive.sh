#!/usr/bin/bash
#https://www.mapr.com/blog/quick-tips-using-hive-shell-inside-scripts

accession=$0
queryFile=$1
subjectFile=$2
referenceFile=$3

sampleMut=$(hive -S -e -hiveconf accession=$accession "use default; select count(*) from sample_mutation where accession = ${hiveconf:$accession});

if $sampleMut = 0 then
	`perl consumer.pl $accession $queryFile $subjectFile $referenceFile`

	`pig loadMutationsIntoHive.pig`
else
	echo "$accession already in database"
fi
