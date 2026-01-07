import logging
import azure.functions as func
import json
from datetime import datetime
import os
import time

def main(msg: func.QueueMessage) -> None:
    """
    Queue Trigger Function - Order Processor
    
    Queue: queue-orders
    Purpose: Demonstrate async message processing pattern
    """
    start_time = time.time()
    
    logging.info(f'QueueTrigger function started processing message: {msg.id}')
    
    # Get message content
    message_body = msg.get_body().decode('utf-8')
    logging.info(f'Message body: {message_body}')
    
    try:
        # Parse message as JSON
        order_data = json.loads(message_body)
        
        # Simulate order processing
        order_id = order_data.get('orderId', 'unknown')
        customer = order_data.get('customer', 'unknown')
        amount = order_data.get('amount', 0)
        
        logging.info(f'Processing order {order_id} for customer {customer}, amount: ${amount}')
        
        # Simulate some processing time
        time.sleep(0.5)  # 500ms processing
        
        # Log processing completion
        processing_time = (time.time() - start_time) * 1000  # milliseconds
        
        result = {
            "orderId": order_id,
            "customer": customer,
            "amount": amount,
            "status": "processed",
            "processingTimeMs": processing_time,
            "timestamp": datetime.utcnow().isoformat(),
            "function": os.environ.get('WEBSITE_SITE_NAME', 'local')
        }
        
        logging.info(f'Order processed successfully: {json.dumps(result)}')
        
    except json.JSONDecodeError as e:
        logging.error(f'Failed to parse message as JSON: {e}')
        logging.error(f'Raw message: {message_body}')
    except Exception as e:
        logging.error(f'Error processing order: {e}')
        raise  # Re-raise to trigger retry logic
    
    logging.info(f'QueueTrigger function completed in {(time.time() - start_time)*1000:.2f}ms')
