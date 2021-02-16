#/bin/bash
#pass mongodb key as variable
export BIFROST_DB_KEY="${BIFROST_DB_KEY:-$1}"
export BIFROST_RUN_DIR="${BIFROST_RUN_DIR:-$PWD}"; \
export BIFROST_CONFIG_DIR="${BIFROST_CONFIG_DIR:-$PWD}"; \
export BIFROST_DIR=$BIFROST_RUN_DIR; \

# Probably not necessary
cd $BIFROST_RUN_DIR; \

echo "Generating run_script.sh..."
docker run \
    --env BIFROST_DB_KEY \
    --mount type=bind,source=$BIFROST_RUN_DIR,target=$BIFROST_RUN_DIR \
    ssidk/bifrost_run_launcher:latest \
        -pre $BIFROST_CONFIG_DIR/pre.sh \
        -per $BIFROST_CONFIG_DIR/per_sample.sh \
        -post $BIFROST_CONFIG_DIR/post.sh \
        -reads $BIFROST_RUN_DIR/samples \
        -meta $BIFROST_RUN_DIR/run_metadata.tsv \
        -name "`date`" \
        -out $BIFROST_RUN_DIR/bifrost_test_output; 

read -p "Press enter to continue"
echo "Running run_script.sh..."
cd  $BIFROST_RUN_DIR/bifrost_test_output;
bash run_script.sh;
