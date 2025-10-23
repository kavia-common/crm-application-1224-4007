#!/bin/bash
cd /home/kavia/workspace/code-generation/crm-application-1224-4007/IntegrationAPIGateway
npm run build
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
   exit 1
fi

