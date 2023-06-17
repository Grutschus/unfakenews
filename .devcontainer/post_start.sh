#!/bin/bash
# FILEPATH: /workspaces/unfakenews/.devcontainer/post_create.sh

echo "Updating frontend python environment"
conda env update --file frontend/env.yaml --prune

echo "Updating backend javascript environment"
npm install

echo "Updating wallet-connect component"
(cd frontend/streamlit-unfakenews-metamask/wallet_connect/frontend/ && npm install)

echo "Deploying contracts..."
(cd backend && truffle deploy --network development)
