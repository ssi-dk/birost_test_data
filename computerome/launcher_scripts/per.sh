# Per sample script example
echo "Running $sample.name from $run.name";

# BIFROST_JOB_MEM is set in Prescript
# BIFROST_JOB_CPUS is set in Prescript 
# BIFROST_JOB_PARTITION is set in Prescript
# BIFROST_SAMPLE_JOB_IDS is set in Prescript

SAMPLE=$sample.name;

mkdir $SAMPLE;
cd $SAMPLE;

# First job is dependant on start, second job on first job and so on
SAMPLE_PIPELINE_ID=$BIFROST_SAMPLE_START_ID
#for PIPELINE in bifrost_min_read_check__dev bifrost_whats_my_species__dev 
for PIPELINE in bifrost_min_read_check__latest bifrost_whats_my_species__latest bifrost_assemblatron__latest bifrost_ssi_stamper__latest bifrost_ariba_mlst__latest bifrost_ariba_resfinder__latest bifrost_ariba_plasmidfinder__latest
do
# PIPELINE=bifrost_whats_my_species__dev
echo "SAMPLE_PIPELINE_ID: $SAMPLE_PIPELINE_ID"
SAMPLE_PIPELINE_ID=$(\
echo "\
module load tools; \
module load singularity/3.6.2; \
export BIFROST_DB_KEY="$BIFROST_DB_KEY"; \
singularity run -B \
$PWD,\
$BIFROST_RAW_DATA_MNT,\
$sample.properties.paired_reads.summary.data[0],\
$sample.properties.paired_reads.summary.data[1],\
/scratch \
$BIFROST_PIPELINE_TOOLS/$PIPELINE \
-id $sample._id
"| \
qsub -d $PWD \
-A $BIFROST_JOB_ACCOUNT \
-W depend=afterany:$SAMPLE_PIPELINE_ID \
-N "${SAMPLE}_${PIPELINE}_bf" \
-W x=advres:$BIFROST_RESNODES \
-l nodes=1:ppn=$BIFROST_JOB_CPUS,mem=$BIFROST_JOB_MEM,walltime=$BIFROST_JOB_TIME \
);
done;
cd ..;
# Add last job id to the list.
BIFROST_SAMPLE_JOB_IDS=$BIFROST_SAMPLE_JOB_IDS:$SAMPLE_PIPELINE_ID;
echo "BIFROST_SAMPLE_JOB_IDS: $BIFROST_SAMPLE_JOB_IDS"
