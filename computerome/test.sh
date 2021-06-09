#DON'T RUN THIS DIRECTLY, SUBMIT VIA run_test.sh
module load tools
module load anaconda3/4.4.0
# Assuming base directory is root of bifrost_test_data (set by qsub)

TEST_ROOT=$PWD
TEST_FOLDER_NAME="./deployment_test"
BIFROST_TEST_CONFIG_DIR=$PWD/computerome

#### CONFIG
# Hopefully the only hardcoded value
#BIFROST_TEST_CONFIG_DIR="/home/projects/ssi_disease_surveillance/apps/bifrost_config"
export TEST_DB_VARS=/home/projects/ssi_disease_surveillance/apps/bifrost_config/env_vars_testdb.sh
export PROD_DB_VARS=/home/projects/ssi_disease_surveillance/apps/bifrost_config/env_vars.sh
#### CONFIG
source $TEST_DB_VARS


### Download latest image versions
module load singularity/3.6.4
module load jq/1.6
cd $BIFROST_IMAGE_DIR
[ -d test_images ] && rm -drf test_images
mkdir -p test_images
cd test_images
echo "Checking if any image needs updating"
downloaded=() #Array
VERSION="latest"
for IMAGE in bifrost_min_read_check bifrost_ssi_stamper bifrost_cge_mlst bifrost_cge_resfinder bifrost_ariba_mlst bifrost_ariba_resfinder bifrost_ariba_plasmidfinder bifrost_ariba_virulencefinder bifrost_whats_my_species bifrost_run_launcher
do
    echo "Checking if $IMAGE has a new version"
    
    #singularity build -F --sandbox ${IMAGE}__$1 docker://ssidk/${IMAGE}:$1
    DIGEST_FILE=../$IMAGE.digest
    echo "Fetching Docker Hub token..."
    token=$(curl --silent "https://auth.docker.io/token?scope=repository:ssidk/$IMAGE:pull&service=registry.docker.io" | jq -r '.token')

    echo -n "Fetching remote digest... "
    digest=$(curl --silent -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
    -H "Authorization: Bearer $token" \
    "https://registry.hub.docker.com/v2/ssidk/$IMAGE/manifests/latest" | jq -r '.config.digest')

    # If local digest file not found, create an empty file (it'll download and update the new version)
    if [ ! -f "$DIGEST_FILE" ]; then
        touch $DIGEST_FILE
    fi

    local_digest=`cat $DIGEST_FILE`

    if [ "$digest" != "$local_digest" ] ; then
        echo "Update available. Executing update command..."
        if bash ../download_image_version.sh $IMAGE $VERSION ; then
            downloaded+=($IMAGE)
            echo "Updating digest file $DIGEST_FILE"
            echo $digest > $DIGEST_FILE
        fi
    else
        echo "Already up to date. Copying to test singularity folder."
        cp -r ../${IMAGE}__${VERSION} .
    fi

done

if [ ${#downloaded[@]} -eq 0 ]; then
   echo "No images downloaded, nothing to be done";
   exit;
fi

# Install downloaded images in test db
for image in "${downloaded[@]}"
do
  bash install_image_version.sh $image ${VERSION}
done


### - Clear test db
echo "Clearing test DB"
module load mongodb/4.4.1
mongo $BIFROST_DB_KEY --eval="db = db.getSiblingDB('bifrost_test');db.getCollectionNames().forEach(function(n){db[n].remove({})});"

### - Clear test folder
cd $TEST_ROOT
[ -d $TEST_FOLDER_NAME ] && rm -drf $TEST_FOLDER_NAME
### - Clear old logs
rm -dr test.sh.e*
rm -dr test.sh.o*
### - Set up folder

echo "Setting up test folder at $TEST_FOLDER_NAME"
mkdir $TEST_FOLDER_NAME
cd $TEST_FOLDER_NAME
TEST_RUN_DIR=$PWD
mkdir $TEST_RUN_DIR/samples
cp ../read_data/download_S1.sh $TEST_RUN_DIR/samples/.
cd $TEST_RUN_DIR/samples

echo "Downloading Samples"
bash download_S1.sh
cd ..

echo "Copying metadata"
cp ../run_metadata.tsv .

### - Create conda environment
echo "Creating conda environment"
conda create --prefix $TEST_RUN_DIR/.condaenv 
source /services/tools/anaconda2/4.4.0/etc/profile.d/conda.sh # Need this to activate
conda activate $TEST_RUN_DIR/.condaenv

## NOTE: We'll append the rest of the script to the post.sh so it runs after the jobs are finished
### - Check db against success test db
### - Email if issues appear

cat $BIFROST_TEST_CONFIG_DIR/launcher_scripts/post.sh \
$BIFROST_TEST_CONFIG_DIR/launcher_scripts/extra_for_post.sh > $BIFROST_TEST_CONFIG_DIR/launcher_scripts/test_post.sh 




### - Start run
# Normally this is done via launch_bifrost.sh but some settings are different so done manually here


BIFROST_RUN_NAME="deployment_test_run"
#source $BIFROST_CONFIG_DIR/env_vars_testdb.sh
#These are used in the post script to install new downloaded images in the non test db
BF_DB_INSTALL_IMAGES=$downloaded
BF_DB_INSTALL_VERSION=$VERSION
# Run on test image
BIFROST_IMAGE_DIR=${BIFROST_IMAGE_DIR}/test_images



singularity run \
    -B $TEST_RUN_DIR,$BIFROST_TEST_CONFIG_DIR \
    --userns \
    /home/projects/ssi_10003/apps/singularity/bifrost_run_launcher__latest \
        -pre $BIFROST_TEST_CONFIG_DIR/launcher_scripts/pre.sh \
        -per $BIFROST_TEST_CONFIG_DIR/launcher_scripts/per.sh \
        -post $BIFROST_TEST_CONFIG_DIR/launcher_scripts/test_post.sh \
        -colmap $BIFROST_TEST_CONFIG_DIR/colmap.json \
        -reads $TEST_RUN_DIR/samples \
        -meta $TEST_RUN_DIR/run_metadata.tsv \
        -name $BIFROST_RUN_NAME \
        -out $TEST_RUN_DIR \

bash run_script.sh

