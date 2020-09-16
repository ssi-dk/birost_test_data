# Per sample script example
echo "Running $sample.name from $run.name";

mkdir $sample.name;
cd $sample.name;

# for IMAGE in bifrost_min_read_check
for IMAGE in bifrost_min_read_check bifrost_whats_my_species bifrost_assemblatron bifrost_ssi_stamper bifrost_ariba_mlst bifrost_ariba_resfinder bifrost_ariba_virulencefinder bifrost_ariba_plasmidfinder
do
    docker run -w $BIFROST_DIR/output/$sample.name --env BIFROST_DB_KEY --mount type=bind,source=$BIFROST_DIR,target=$BIFROST_DIR ssidk/$IMAGE:latest -id $sample._id
done

cd ..;
