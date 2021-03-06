#!/usr/bin/env bash

# Setup the infrastructure.
for script in "infrastructure-mongo.sh" "infrastructure-rabbitmq.sh" "infrastructure-redis.sh"; do
    source "$PWD/devops/${script}"
done

# Link the infrastructure and run the image.
# Stop the containers even if the tests fail.
docker run --link mongodb:mongo --link rabbitmq:rabbitmq --link redis:redis --rm idearium-lib

# Store the exit status of the tests.
exitWith=$?

# Clean up.
source $PWD/devops/clean.sh

# Now we can exit, with the status of the tests.
exit $exitWith
