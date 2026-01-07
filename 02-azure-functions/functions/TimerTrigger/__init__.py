import logging
import azure.functions as func
from datetime import datetime
import os
import json

def main(timer: func.TimerRequest) -> None:
    """
    Timer Trigger Function - Health Check / Scheduled Job
    
    Schedule: Every 5 minutes (0 */5 * * * *)
    Purpose: Demonstrate scheduled execution and generate metrics
    """
    utc_timestamp = datetime.utcnow().isoformat()
    
    logging.info(f'TimerTrigger function executed at: {utc_timestamp}')
    
    # Check if timer is past due
    if timer.past_due:
        logging.warning('The timer is past due!')
    
    # Simulate health check or maintenance task
    function_name = os.environ.get('WEBSITE_SITE_NAME', 'local')
    environment = os.environ.get('ENVIRONMENT', 'unknown')
    
    # Log structured data for Application Insights
    health_status = {
        "timestamp": utc_timestamp,
        "function": function_name,
        "environment": environment,
        "triggerType": "timer",
        "pastDue": timer.past_due,
        "status": "healthy",
        "checksPerformed": {
            "storage": "ok",
            "connectivity": "ok"
        }
    }
    
    logging.info(f'Health check completed: {json.dumps(health_status)}')
    
    # Could send message to queue, write to storage, etc.
    # For POC, just logging is sufficient
    
    logging.info('TimerTrigger function completed successfully')
