This will be the repo for setting up test data for the bifrost_components related to single sample testing. The initial toy data set can be found at https://www.ebi.ac.uk/ena/browser/view/PRJEB39131. As the read files are large they aren't in the repo but can be aquired via the download scripts (i.e. download_one_sample.sh)


# Testing bifrost
```
export BIFROST_DB_KEY=mongodb://<your credentials here>; \
git clone https://github.com/ssi-dk/bifrost_test_data.git bifrost_test_data; \
BIFROST_DIR=$PWD; \
cd bifrost_test_data/read_data; \
bash download_S1.sh; \
cd ../output; \
docker run --mount type=bind,source=$BIFROST_DIR,target=$BIFROST_DIR ssidk/ bifrost_run_launcher:latest --install; 

```