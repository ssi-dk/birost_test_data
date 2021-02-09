echo \
"\
module load tools
module load mongodb/4.4.1
mkdir db_export
cd db_export
mongoexport --uri=\"$BIFROST_DB_KEY\" --pretty --collection=samples --out samples.json
mongoexport --uri=\"$BIFROST_DB_KEY\" --pretty --collection=components --out components.json
mongoexport --uri=\"$BIFROST_DB_KEY\" --pretty --collection=runs --out runs.json
mongoexport --uri=\"$BIFROST_DB_KEY\" --pretty --collection=sample_components --out sample_components.json
cd ../..


DIFFOUT=$(/usr/bin/diff -I '$oid' -I '$date' -r computerome/expected_db/ deployment_test/db_export/)
if [ -n \"$DIFFOUT\" ]
then
    mail -s \"Bifrost computerome deployment test\" mbas@ssi.dk kimn@ssi.dk <<< \"$DIFFOUT\"
else
    echo \"Test successful. Installing new images in prod db.\"
    # Switching to prod db.
    source $PROD_DB_VARS
    for image in "${BF_DB_INSTALL_IMAGES[@]}"
    do
        bash download_image_version.sh $image $BF_DB_INSTALL_VERSION
    done
fi

 " | \
qsub \
-W x=advres:$BIFROST_RESNODES \
-W depend=afterany:$BIFROST_SAMPLE_JOB_IDS \
-A $BIFROST_JOB_ACCOUNT \
-N "post_$run.name" \
-d $PWD \
-l nodes=1:ppn=$BIFROST_JOB_CPUS,mem=$BIFROST_JOB_MEM,walltime=$BIFROST_JOB_TIME \