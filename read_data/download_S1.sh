#/bin/bash
[ ! -e "S1_R1.fastq.gz"] && wget -O S1_R1.fastq.gz "ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR430/ERR4301030/S1.R1.fastq.gz"
[ ! -e "S1_R2.fastq.gz"] && wget -O S1_R2.fastq.gz "ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR430/ERR4301030/S1.R2.fastq.gz"