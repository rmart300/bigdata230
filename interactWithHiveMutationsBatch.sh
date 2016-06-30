#!/usr/bin/bash
#https://www.mapr.com/blog/quick-tips-using-hive-shell-inside-scripts

accessionsToProcess=()
sampleMuts=()
accExists=0

checkForExistingAccession()
{
    accessionToCheck=$1
    for acc in sampleMuts; do
        if [ "$acc" = "$accessionToCheck" ]; then
            return 1
        fi
    done

    return 0
}

`sudo echo "" > /tmp/bigdata230/batch_mutation.csv` #clear contents of batch file
`sudo cp loadMutationsIntoHive.pig /tmp/bigdata230/`

sampleMuts=$(sudo -su hdfs hive -S -e "select accession from sample_mutation group by accession")

count=0

for file in /tmp/bigdata230/alignmentOutput/*_mutation.csv; do
    arrIN=(${file//_/ })
    accessionWithPath=${arrIN[0]}
    arrIN2=(${accessionWithPath//// })
    accession=${arrIN2[3]}
    #echo "processing $accession"

    checkForExistingAccession $accession
    accExists=$? #capture return value

    #if does not exist, append to batch file
    if [ "$accExists" -eq 0 ]; then
        `cat /tmp/bigdata230/alignmentOutput/$accession\_mutation.csv >> /tmp/bigdata230/batch_mutation.csv`
        count+=1
    else
        echo "$accession not added to batch file"
    fi

    #if [ "$count" -gt 500 ]; then
    #    break;
    #fi
done


    `sudo -su hdfs hdfs dfs -copyFromLocal -f /tmp/bigdata230/batch_mutation.csv /user/guest/batch_mutation.csv`
    `sudo -su hdfs pig -f /tmp/bigdata230/loadMutationsIntoHive.pig -param alignmentOutputFile="/user/guest/batch_mutation.csv" -useHCatalog &>/tmp/bigdata230/pig/batch_mutations.pig.log`
