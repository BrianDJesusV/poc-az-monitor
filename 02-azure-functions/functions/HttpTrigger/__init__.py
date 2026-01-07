import logging
import json
import azure.functions as func
from datetime import datetime
import os

def main(req: func.HttpRequest) -> func.HttpResponse:
    """
    HTTP Trigger Function - Simple Hello API
    
    Endpoint: GET/POST /api/HttpTrigger?name=YourName
    Purpose: Demonstrate HTTP trigger with Application Insights telemetry
    """
    logging.info('HttpTrigger function processed a request.')
    
    # Get name from query params or request body
    name = req.params.get('name')
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            req_body = None
        
        if req_body:
            name = req_body.get('name')
    
    # Get environment info
    function_name = os.environ.get('WEBSITE_SITE_NAME', 'local')
    environment = os.environ.get('ENVIRONMENT', 'unknown')
    
    # Generate response
    if name:
        response_data = {
            "message": f"Hello, {name}!",
            "timestamp": datetime.utcnow().isoformat(),
            "function": function_name,
            "environment": environment,
            "triggerType": "http"
        }
        
        logging.info(f'Successfully processed request for name: {name}')
        
        return func.HttpResponse(
            json.dumps(response_data, indent=2),
            mimetype="application/json",
            status_code=200
        )
    else:
        error_data = {
            "error": "Please pass a name on the query string or in the request body",
            "timestamp": datetime.utcnow().isoformat(),
            "function": function_name
        }
        
        logging.warning('Request missing name parameter')
        
        return func.HttpResponse(
            json.dumps(error_data, indent=2),
            mimetype="application/json",
            status_code=400
        )
