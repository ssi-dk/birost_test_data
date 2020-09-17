#/bin/bash
#pass mongodb key as variable
export BIFROST_DB_KEY="${BIFROST_DB_KEY:-$1}"
BIFROST_DIR=$PWD; \
cd read_data; \
bash download_S1.sh; \
cd $BIFROST_DIR; \
docker run \
    --env BIFROST_DB_KEY \
    --mount type=bind,source=$BIFROST_DIR,target=$BIFROST_DIR \
    ssidk/bifrost_run_launcher:latest \
        -pre $BIFROST_DIR/pre.sh \
        -per $BIFROST_DIR/per_sample.sh \
        -post $BIFROST_DIR/post.sh \
        -reads $BIFROST_DIR/read_data \
        -meta $BIFROST_DIR/run_metadata.tsv \
        -name bifrost_test \
        -out $BIFROST_DIR/output; 
# for IMAGE in bifrost_min_read_check
for IMAGE in bifrost_min_read_check bifrost_whats_my_species bifrost_assemblatron bifrost_ssi_stamper bifrost_ariba_mlst bifrost_ariba_resfinder bifrost_ariba_virulencefinder bifrost_ariba_plasmidfinder
do
    echo "Downloading and installing $IMAGE"
    docker run \
        --env BIFROST_DB_KEY \
        ssidk/$IMAGE:latest \
        --install;
done

cd output;
bash run_script.sh;
