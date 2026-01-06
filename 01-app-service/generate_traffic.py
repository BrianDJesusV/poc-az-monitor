#!/usr/bin/env python3
"""
Traffic Generator Script
Propósito: Generar tráfico sintético al App Service para observar métricas/logs
"""

import requests
import time
import random
import sys
from datetime import datetime

# Configuración
APP_URL = sys.argv[1] if len(sys.argv) > 1 else "https://your-app-service.azurewebsites.net"
DURATION_MINUTES = 10  # Duración del test
REQUEST_INTERVAL = 2   # Segundos entre requests

# Endpoints a probar
ENDPOINTS = [
    {'path': '/', 'weight': 30},
    {'path': '/api/success', 'weight': 40},  # ✅ Corregido: era /api/data (POST)
    {'path': '/api/slow', 'weight': 10},
    {'path': '/api/error', 'weight': 10},
    {'path': '/api/notfound', 'weight': 10}  # ✅ Corregido: era /api/random (no existe)
]

def generate_traffic():
    """Genera tráfico sintético"""
    print(f"🚀 Iniciando generación de tráfico")
    print(f"📍 URL: {APP_URL}")
    print(f"⏱️  Duración: {DURATION_MINUTES} minutos")
    print(f"🔄 Intervalo: {REQUEST_INTERVAL} segundos\n")
    
    start_time = time.time()
    end_time = start_time + (DURATION_MINUTES * 60)
    request_count = 0
    success_count = 0
    error_count = 0
    
    try:
        while time.time() < end_time:
            # Seleccionar endpoint aleatorio (weighted random)
            weights = [e['weight'] for e in ENDPOINTS]
            endpoint = random.choices(ENDPOINTS, weights=weights)[0]
            url = f"{APP_URL}{endpoint['path']}"
            
            try:
                # Hacer request
                response = requests.get(url, timeout=10)
                request_count += 1
                
                if response.status_code < 400:
                    success_count += 1
                    status = "✅"
                else:
                    error_count += 1
                    status = "❌"
                
                print(f"{status} [{datetime.now().strftime('%H:%M:%S')}] "
                      f"GET {endpoint['path']} - {response.status_code} "
                      f"({response.elapsed.total_seconds():.2f}s)")
                
            except requests.exceptions.RequestException as e:
                error_count += 1
                print(f"❌ [{datetime.now().strftime('%H:%M:%S')}] "
                      f"GET {endpoint['path']} - ERROR: {str(e)}")
            
            # Esperar antes del próximo request
            time.sleep(REQUEST_INTERVAL)

    except KeyboardInterrupt:
        print("\n⏹️  Deteniendo generación de tráfico...")
    
    # Resumen final
    duration = time.time() - start_time
    print(f"\n📊 Resumen:")
    print(f"   Total requests: {request_count}")
    print(f"   Exitosos: {success_count} ({success_count/request_count*100:.1f}%)")
    print(f"   Errores: {error_count} ({error_count/request_count*100:.1f}%)")
    print(f"   Duración: {duration:.1f} segundos")
    print(f"   Rate: {request_count/duration:.2f} req/s")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("❌ Error: Debes proporcionar la URL del App Service")
        print(f"\nUso: python {sys.argv[0]} <APP_SERVICE_URL>")
        print(f"Ejemplo: python {sys.argv[0]} https://app-azmon-appservice-poc-abc123.azurewebsites.net")
        sys.exit(1)
    
    generate_traffic()
