source /home/projects/ssi_disease_surveillance/apps/bifrost_config/env_vars_testdb.sh
cd ..
qsub \
-A $BIFROST_JOB_ACCOUNT \
-l nodes=1:ppn=$BIFROST_JOB_CPUS,mem=$BIFROST_JOB_MEM,walltime=$BIFROST_JOB_TIME \
-W group_list=$BIFROST_JOB_ACCOUNT \
-W x=advres:$BIFROST_RESNODES \
-d $PWD \
computerome/test.sh