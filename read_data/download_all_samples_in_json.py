#!/usr/bin/env python3
import json
import os
import sys
import subprocess
import traceback

with open("all_samples.json", "r") as all_samples_stream:
    all_samples = json.load(all_samples_stream)

for sample in all_samples:
    reads = sample["submitted_ftp"].split(";")
    if len(reads) == 2:
        sample = (reads[0].split("/")[-1].replace(".","_",1), reads[1].split("/")[-1].replace(".","_",1))
    for i in range(len(sample)):
        if not os.path.isfile(sample[i]):
            try:
                process: subprocess.Popen = subprocess.Popen(
                    f"wget -O {sample[i]} {reads[i]}",
                    stdout=sys.stdout,
                    stderr=sys.stderr,
                    shell=True
                )
                process.communicate()
            except:
                print(traceback.format_exc())
    pass
