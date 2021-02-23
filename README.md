This will be the repo for setting up test data for the bifrost_components related to single sample testing. The initial toy data set can be found at https://www.ebi.ac.uk/ena/browser/view/PRJEB39131. As the read files are large they aren't in the repo but can be aquired via the download scripts (i.e. download_one_sample.sh)


# Testing bifrost
```
export BIFROST_DB_KEY=<mongo_db_key>
./test_bifrost.sh
```
or
```
./test_bifrost.sh <mongo_db_key>
```

