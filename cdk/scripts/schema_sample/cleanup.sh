#!/bin/bash

# please modify
ADMIN_USERNAME=admin_user
ADMIN_PASSWORD=Shinkubo1022
DB_ENDPOINT=myoracle.cpb0addajvao.ap-northeast-1.rds.amazonaws.com
DB_PORT=1521
DB_NAME=ORCL

# Basically, the default value is fine
DB_USERNAME=SCHEMA_SAMPLE
DB_0032_USERNAME=T_0032_USER

sqlplus ${ADMIN_USERNAME}/${ADMIN_PASSWORD}@//${DB_ENDPOINT}:${DB_PORT}/${DB_NAME} <<- EOF
	DROP USER ${DB_0032_USERNAME} CASCADE;
	DROP USER ${DB_USERNAME} CASCADE;
EOF
