#/bin/bash
# Per sample script example
echo "Running $sample.name from $run.name";
BIFROST_RAW_DATA_MNT="/bifrost_test_data/data/";

mkdir $sample.name;
cd $sample.name;

# Currently runs assuming you're in directory
docker run --mount type=bind,source=$BIFROST_RAW_DATA_MNT,target=$BIFROST_RAW_DATA_MNT ssidk/bifrost-min_read_check:2.0.7 -id $sample._id
docker run --mount type=bind,source=$BIFROST_RAW_DATA_MNT,target=$BIFROST_RAW_DATA_MNT ssidk/bifrost-whats_my_species:2.0.7 -id $sample._id

cd ..;
