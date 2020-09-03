#/bin/bash
#pass mongodb key as variable
export BIFROST_DB_KEY=$1; \
git clone https://github.com/ssi-dk/bifrost_test_data.git bifrost_test_data; \
BIFROST_DIR=$PWD; \
cd bifrost_test_data/read_data; \
bash download_S1.sh; \
cd ../output; \
docker run --mount type=bind,source=$BIFROST_DIR,target=$BIFROST_DIR ssidk/ bifrost_run_launcher:latest --install; 