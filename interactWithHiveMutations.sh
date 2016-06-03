#!/usr/bin/bash
#https://www.mapr.com/blog/quick-tips-using-hive-shell-inside-scripts

`cp loadMutationsIntoHive.pig /tmp/bigdata230/`

for file in /tmp/bigdata230/alignmentOutput/*_sequenceOutput.csv; do
    arrIN=(${file//_/ })
    accessionWithPath=${arrIN[0]}
    arrIN2=(${accessionWithPath//// })
    accession=${arrIN2[3]}
    echo "processing $accession"

    sampleSeq=$(sudo -su hdfs hive -S -e "select count(*) from sample_mutation where accession='$accession';")

    echo "$accession has $sampleSeq mutations loaded"

    if [ "$sampleSeq" = 0 ]; then
        #copy to output alignment files to tmp directory and load pig script

        `sudo -su hdfs hdfs dfs -copyFromLocal -f /tmp/bigdata230/alignmentOutput/$accession\_mutation.csv /user/guest/$accession\_mutation.csv`

	    `sudo -su hdfs pig -f /tmp/bigdata230/loadMutationsIntoHive.pig -param alignmentOutputFile="/user/guest/$accession\_mutation.csv" -param accession="$accession" -useHCatalog &>/tmp/bigdata230/pig/$accession.mutations.pig.log`


    else
	    echo "$accession already in database"
    fi

done

