# Per sample script example
echo "Running $sample.name from $run.name";

mkdir $sample.name;
cd $sample.name;

# Currently runs assuming you're in directory
docker run --mount type=bind,source=$BIFROST_DIR,target=$BIFROST_DIR ssidk/bifrost_min_read_check:latest -id $sample._id
docker run --mount type=bind,source=$BIFROST_DIR,target=$BIFROST_DIR ssidk/bifrost_whats_my_species:latest -id $sample._id

cd ..;
