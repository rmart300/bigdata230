#!/usr/bin/bash
#https://www.mapr.com/blog/quick-tips-using-hive-shell-inside-scripts

accessionsToProcess=()
sampleSeqs=()
accExists=0

checkForExistingAccession()
{
    accessionToCheck=$1
    for acc in sampleSeqs; do
        if [ "$acc" = "$accessionToCheck" ]; then
            return 1
        fi
    done

    return 0
}

`sudo cp loadSequencesIntoHive.pig /tmp/bigdata230/`

#$sampleSeqs=$(sudo -su hdfs hive -S -e "select accession from sample_sequence")

for file in /tmp/bigdata230/alignmentOutput/M*_sequenceOutput.csv; do
    arrIN=(${file//_/ })
    accessionWithPath=${arrIN[0]}
    arrIN2=(${accessionWithPath//// })
    accession=${arrIN2[3]}
    echo "processing $accession"

    checkForExistingAccession $accession
    accExists=$? #capture return value

    #if does not exist, append to batch file
    if [ "$accExists" -eq 0 ]; then
        `sudo -su hdfs hdfs dfs -copyFromLocal -f /tmp/bigdata230/alignmentOutput/$accession\_sequenceOutput.csv /user/guest/$accession\_sequenceOutput.csv`
        `sudo -su hdfs pig -f /tmp/bigdata230/loadSequencesIntoHive.pig -param sequenceOutputFile="/user/guest/$accession\_sequenceOutput.csv" -useHCatalog &>/tmp/bigdata230/pig/$accession\_sequences.pig.log`
        aws s3 cp $file s3://uwprojectbigdata/sequenceOutput/
        echo "$accession loaded into database"
    else
        echo "$accession not added to batch file"
    fi
done


