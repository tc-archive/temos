#!/bin/bash

SCRIPTS_DIR=${TEMOS_HOME}/macosx/scripts

for file in ${SCRIPTS_DIR}/*.sh
do
	echo `basename ${file}`
	source ${file} 	
done
