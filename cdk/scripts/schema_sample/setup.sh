#!/bin/bash

# please modify
ADMIN_USERNAME=$(aws secretsmanager get-secret-value --secret-id oracle-credentials --query SecretString --output text | jq -r .username)
ADMIN_PASSWORD=$(aws secretsmanager get-secret-value --secret-id oracle-credentials --query SecretString --output text | jq -r .password)
DB_ENDPOINT=localhost
DB_PORT=1521
DB_NAME=XEPDB1

# Basically, the default value is fine
DB_USERNAME=SCHEMA_SAMPLE
DB_PASSWORD=PASSWORD
DB_0032_USERNAME=T_0032_USER
DB_0032_PASSWORD=PASSWORD

sqlplus -S ${ADMIN_USERNAME}/${ADMIN_PASSWORD}@//${DB_ENDPOINT}:${DB_PORT}/${DB_NAME} <<- EOF
	CREATE USER ${DB_USERNAME} IDENTIFIED BY ${DB_PASSWORD};
	GRANT CREATE SESSION TO ${DB_USERNAME};
	GRANT DBA TO ${DB_USERNAME};
EOF

#36 53
for i in $(seq 1 77); do
	script=$(printf "%04d\n" $i).sql
	echo ${script}
	if [ ${i} -eq 36 ] || [ ${i} -eq 53 ]; then
		script="${script} ${DB_USERNAME} ${DB_PASSWORD} ${DB_ENDPOINT} ${DB_PORT} ${DB_NAME}"
	elif [ ${i} -eq 32 ]; then
		script="${script} ${DB_0032_USERNAME} ${DB_0032_PASSWORD}"
	fi
	sqlplus -S ${DB_USERNAME}/${DB_PASSWORD}@//${DB_ENDPOINT}:${DB_PORT}/${DB_NAME} <<- EOF
		@${script}
EOF
done
