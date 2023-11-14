#!/usr/bin/env bash

docker run \
	--name pg1 \
	-e POSTGRES_PASSWORD=password \
	-v "$(pwd)/pgdata":/var/lib/postgresql/data \
	postgres:14.7
