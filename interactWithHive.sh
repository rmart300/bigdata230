#!/usr/bin/bash
#https://www.mapr.com/blog/quick-tips-using-hive-shell-inside-scripts

accession=$1
queryFile=$2
subjectFile=$3
referenceFile=$4

#sampleMut=$(sudo -su hdfs hive -S -hiveconf accession=$accession -e "select count(*) from sample_mutation where accession='${hiveconf:accession}';")
sampleMut=$(sudo -u hdfs hive -S -e "select count(*) from sample_mutation where accession='$accession';")

echo "$accession has $sampleMut mutations"

if [ "$sampleMut" -eq "0" ]; then
	`perl consumer.pl $accession tmp/$queryFile $subjectFile $referenceFile`

    #copy to output alignment files to tmp directory and load pig script
    #sudo to hdfs user to copy files to hdfs /user/guest/ and then execute script

    `sudo -u hdfs hdfs dfs -copyFromLocal /tmp/bigdata230/alignmentOutput/$accession\_sequenceOutput.csv /user/guest/$accession\_sequenceOutput.csv`
    `sudo -u hdfs hdfs dfs -copyFromLocal /tmp/bigdata230/alignmentOutput/$accession\_mutation.csv /user/guest/$accession\_mutation.csv`

    `cp loadMutationsIntoHive.pig /tmp/bigdata230/`

	`sudo -u hdfs pig -f /tmp/bigdata230/loadMutationsIntoHive.pig -param sequenceOutputFile="/user/guest/$accession\_sequenceOutput.csv" -param alignmentOutputFile="/user/guest/$accession\_mutation.csv" -param accession="$accession" -useHCatalog &>/tmp/bigdata230/pig/$accession.pig.log`

else
	echo "$accession already in database"
fi
