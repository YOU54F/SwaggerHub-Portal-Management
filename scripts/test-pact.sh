#!/bin/bash
set -e

# start the master mock server
pact_mock_server_cli_v2 start --server-key 1234 &

# load the mock server with our expections 
# and grab the dynamically generated port
port=$(pact_mock_server_cli_v2 create -f pacts/swaggerhub-portal-management-client-swaggerhub-portal-service.json | awk '/started on port/ {print $NF}')
echo $port

# arrange our environment 
export PORTAL_URL=http://localhost:$port
export SWAGGERHUB_API_KEY=Foo
export SWAGGERHUB_PORTAL_SUBDOMAIN=fooSubDomain

# act against our system under test
./scripts/publish-portal-content.sh

# verify the consumer issued the correct requests
# write out pact files to current directory
pact_mock_server_cli_v2 verify --mock-server-port "$port"

# shutdown master server
pact_mock_server_cli_v2 shutdown-master --server-key 1234