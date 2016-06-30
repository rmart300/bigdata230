#!/usr/bin/bash

for file in tmp/*; do

    aws s3 cp $file s3://uwprojectbigdata/viralsequenceFastaFiles/

    `rm $file`
done

