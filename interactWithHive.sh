#!/usr/bin/bash
#https://www.mapr.com/blog/quick-tips-using-hive-shell-inside-scripts

accession=$0
queryFile=$1
subjectFile=$2
referenceFile=$3

sampleMut=$(hive -S -e -hiveconf accession=$accession "use default; select count(*) from sample_mutation where accession = ${hiveconf:$accession});

if $sampleMut = 0 then
	`perl consumer.pl $accession $queryFile $subjectFile $referenceFile`

    #copy to output alignment files to tmp directory and load pig script
    #sudo to hdfs user to copy files to hdfs /user/guest/ and then execute script

    `sudo -su hdfs hdfs dfs -copyFromLocal /tmp/bigdata230/$accession\_sequenceOutput.csv /user/guest/$accession\_sequenceOutput.csv`
    `sudo -su hdfs hdfs dfs -copyFromLocal /tmp/bigdata230/$accession\_mutation.csv /user/guest/$accession\_mutation.csv`

	`sudo -su hdfs pig -f $BIGDATA230/loadMutationsIntoHive.pig -param sequenceOutputFile="/user/guest/$accession\_sequenceOutput.csv" -param alignmentOutputFile="/user/guest/$accession\_mutation.csv" -param accession="$accession" -useHCatalog`
else
	echo "$accession already in database"
fi
