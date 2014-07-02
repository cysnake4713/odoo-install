#!/usr/bin/env bash

DB_NAME=develop
#dropdb ${DB_NAME}
#createdb ${DB_NAME}
pg_restore --create -d ${DB_NAME}



