#/bin/bash
#pass mongodb key as variable
BIFROST_DB_KEY="${BIFROST_DB_KEY:$1}"
BIFROST_DIR=$PWD; \
cd read_data; \
bash download_S1.sh; \
cd $BIFROST_DIR/output; \
docker run --mount type=bind,source=$BIFROST_DIR,target=$BIFROST_DIR ssidk/ bifrost_run_launcher:latest --install; 