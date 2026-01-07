import logging
import azure.functions as func
from datetime import datetime
import os
import time

def main(blob: func.InputStream) -> None:
    """
    Blob Trigger Function - File Processor
    
    Container: uploads
    Purpose: Demonstrate event-driven file processing
    """
    start_time = time.time()
    
    logging.info(f'BlobTrigger function processing blob: {blob.name}')
    logging.info(f'Blob size: {blob.length} bytes')
    
    try:
        # Read blob content
        blob_content = blob.read()
        content_size = len(blob_content)
        
        # Determine file type
        file_extension = os.path.splitext(blob.name)[1].lower()
        
        # Log file processing
        function_name = os.environ.get('WEBSITE_SITE_NAME', 'local')
        
        processing_info = {
            "fileName": blob.name,
            "fileSize": content_size,
            "fileExtension": file_extension,
            "timestamp": datetime.utcnow().isoformat(),
            "function": function_name,
            "triggerType": "blob"
        }
        
        logging.info(f'File processed: {processing_info}')
        
        # Simulate processing based on file type
        if file_extension in ['.txt', '.log']:
            logging.info(f'Processing text file: {blob.name}')
            # Could parse log file, extract data, etc.
        elif file_extension in ['.json']:
            logging.info(f'Processing JSON file: {blob.name}')
            # Could validate JSON, extract fields, etc.
        elif file_extension in ['.csv']:
            logging.info(f'Processing CSV file: {blob.name}')
            # Could load into database, generate report, etc.
        else:
            logging.info(f'Processing generic file: {blob.name}')
        
        # Simulate processing time proportional to file size
        processing_time_ms = (time.time() - start_time) * 1000
        
        logging.info(f'File processing completed in {processing_time_ms:.2f}ms')
        
        # Could write processed file to another container
        # Could send notification via queue
        # Could update database with processing status
        
    except Exception as e:
        logging.error(f'Error processing blob {blob.name}: {e}')
        raise  # Re-raise to trigger retry logic
    
    logging.info(f'BlobTrigger function completed for: {blob.name}')
