#!/usr/bin/env python3
"""
Simple Traffic Generator for Azure Monitor POC
"""

import requests
import time
import random
import sys
from datetime import datetime

# Configuration
APP_URL = sys.argv[1] if len(sys.argv) > 1 else ""
DURATION_MINUTES = 5
REQUEST_INTERVAL = 2

# Endpoints to test
ENDPOINTS = [
    {'path': '/', 'weight': 30, 'name': 'Home'},
    {'path': '/api/success', 'weight': 40, 'name': 'Success'},
    {'path': '/api/slow', 'weight': 10, 'name': 'Slow'},
    {'path': '/api/error', 'weight': 10, 'name': 'Error'},
    {'path': '/api/notfound', 'weight': 10, 'name': 'NotFound'}
]

def generate_traffic():
    print("=" * 70)
    print("  Traffic Generator - Azure Monitor POC")
    print("=" * 70)
    print("")
    print(f"URL: {APP_URL}")
    print(f"Duration: {DURATION_MINUTES} minutes")
    print(f"Interval: {REQUEST_INTERVAL} seconds")
    print("")
    
    start_time = time.time()
    end_time = start_time + (DURATION_MINUTES * 60)
    request_count = 0
    success_count = 0
    error_count = 0
    
    try:
        while time.time() < end_time:
            # Select random endpoint (weighted)
            weights = [e['weight'] for e in ENDPOINTS]
            endpoint = random.choices(ENDPOINTS, weights=weights)[0]
            url = f"{APP_URL}{endpoint['path']}"
            
            try:
                response = requests.get(url, timeout=10)
                request_count += 1
                
                if response.status_code < 400:
                    success_count += 1
                    status = "[OK]"
                else:
                    error_count += 1
                    status = "[ERR]"
                
                elapsed_ms = int(response.elapsed.total_seconds() * 1000)
                timestamp = datetime.now().strftime('%H:%M:%S')
                
                print(f"{status} [{timestamp}] {endpoint['name']:12} GET {endpoint['path']:20} "
                      f"HTTP {response.status_code} | {elapsed_ms}ms")
                
            except requests.exceptions.RequestException as e:
                error_count += 1
                timestamp = datetime.now().strftime('%H:%M:%S')
                print(f"[ERR] [{timestamp}] {endpoint['name']:12} GET {endpoint['path']:20} "
                      f"ERROR: {str(e)[:50]}")
            
            time.sleep(REQUEST_INTERVAL)

    except KeyboardInterrupt:
        print("\nStopping traffic generation...")
    
    # Summary
    duration = time.time() - start_time
    success_rate = (success_count/request_count*100) if request_count > 0 else 0
    error_rate = (error_count/request_count*100) if request_count > 0 else 0
    
    print("")
    print("=" * 70)
    print("  TRAFFIC SUMMARY")
    print("=" * 70)
    print("")
    print(f"Total requests:   {request_count}")
    print(f"Successful:       {success_count} ({success_rate:.1f}%)")
    print(f"Errors:           {error_count} ({error_rate:.1f}%)")
    print(f"Duration:         {duration:.1f} seconds")
    print(f"Request rate:     {request_count/duration:.2f} req/s")
    print("")
    print("Data should appear in Application Insights in 1-2 minutes")
    print("")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("ERROR: You must provide the App Service URL")
        print(f"\nUsage: python {sys.argv[0]} <APP_SERVICE_URL>")
        print(f"Example: python {sys.argv[0]} https://app-azmon-demo-h45p6r.azurewebsites.net")
        sys.exit(1)
    
    generate_traffic()
