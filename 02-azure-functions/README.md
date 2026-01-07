# 🚀 Escenario 2: Azure Functions + Serverless Monitoring

**Estado:** ✅ LISTO PARA DEPLOYMENT  
**Fecha:** 7 de enero de 2026  
**Duración estimada:** 30 minutos

---

## 📋 DESCRIPCIÓN

Este escenario demuestra monitoreo de arquitectura serverless event-driven con:
- ✅ Azure Functions (Consumption Plan)
- ✅ 4 triggers diferentes (HTTP, Timer, Queue, Blob)
- ✅ Application Insights integration
- ✅ Pay-per-execution cost model

---

## 🏗️ ARQUITECTURA

```
Log Analytics Workspace (Escenario 0)
         ↓
Application Insights (Functions)
         ↓
Storage Account
  ├── Blobs (uploads, processed)
  └── Queues (orders, notifications)
         ↓
Function App (Consumption Y1)
  ├── HttpTrigger  (/api/HttpTrigger)
  ├── TimerTrigger (every 5 min)
  ├── QueueTrigger (queue-orders)
  └── BlobTrigger  (uploads container)
```

---

## 📦 COMPONENTES

### **Infraestructura (Terraform)**
1. Storage Account (`stazmon<random>`)
   - 2 Containers: uploads, processed
   - 2 Queues: queue-orders, queue-notifications

2. Application Insights (`appi-azmon-functions-<random>`)
   - Linked to LAW from Scenario 0
   - Automatic telemetry collection

3. Function App (`func-azmon-demo-<random>`)
   - Plan: Consumption (Y1)
   - Runtime: Python 3.11
   - 4 Functions deployed

### **Functions (Python)**
1. **HttpTrigger** - Hello API
   - Endpoint: GET/POST /api/HttpTrigger?name=YourName
   - Purpose: REST API demonstration

2. **TimerTrigger** - Health Check
   - Schedule: Every 5 minutes
   - Purpose: Scheduled job pattern

3. **QueueTrigger** - Order Processor
   - Queue: queue-orders
   - Purpose: Async processing pattern

4. **BlobTrigger** - File Processor
   - Container: uploads
   - Purpose: Event-driven file processing

---

## 🚀 DEPLOYMENT

### **Prerequisites**
- ✅ Scenario 0 deployed (Log Analytics Workspace)
- ✅ Azure CLI authenticated
- ✅ Terraform >= 1.4.0

### **Step 1: Deploy Infrastructure (5-8 min)**
```powershell
cd 02-azure-functions

# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Deploy
terraform apply -auto-approve

# Save outputs
terraform output > outputs.txt
```

### **Step 2: Deploy Functions (3-5 min)**
```powershell
# Option 1: PowerShell (Recommended for Windows)
.\deploy_functions.ps1

# Option 2: Bash (WSL/Linux/Mac)
bash deploy_functions.sh
```

### **Step 3: Test Functions (2 min)**
```powershell
.\test_functions.ps1
```

---

## 🧪 TESTING

### **Test HttpTrigger**
```powershell
$url = terraform output -raw function_app_url
Invoke-WebRequest -Uri "$url/api/HttpTrigger?name=POC" | Select-Object -ExpandProperty Content
```

### **Generate Queue Messages**
```powershell
$storageAccount = terraform output -raw storage_account_name
$queueName = "queue-orders"

# Send test message
$message = '{"orderId":"ORDER-1001","customer":"Test","amount":150}' | ConvertTo-Json
az storage message put --queue-name $queueName --account-name $storageAccount --content $message
```

### **Upload Test File to Blob**
```powershell
$storageAccount = terraform output -raw storage_account_name
$containerName = "uploads"

# Create and upload test file
"Test content" | Out-File test.txt
az storage blob upload --account-name $storageAccount --container-name $containerName --name test.txt --file test.txt
```

---

## 📊 MONITORING

### **Application Insights**

**Access:**
```powershell
# Get Application Insights name
terraform output app_insights_name

# Open in Azure Portal
# Search for the App Insights resource
```

**Key Metrics to Watch:**
- Function execution count
- Average execution time
- Success rate
- Cold start percentage

### **KQL Queries**

**All Function Executions**
```kusto
requests
| where cloud_RoleName contains "func-azmon"
| summarize count() by operation_Name
| order by count_ desc
```

**Cold Start Analysis**
```kusto
requests
| where cloud_RoleName contains "func-azmon"
| extend IsColdStart = tobool(customDimensions.isColdStart)
| summarize 
    Total = count(),
    ColdStarts = countif(IsColdStart),
    ColdStartPct = round(countif(IsColdStart) * 100.0 / count(), 2)
```

**Performance by Function**
```kusto
requests
| where cloud_RoleName contains "func-azmon"
| summarize 
    Executions = count(),
    AvgDuration = avg(duration),
    P95 = percentile(duration, 95)
    by operation_Name
| order by P95 desc
```

---

## 💰 COSTS

```
Storage Account:     ~$0.50/month
Function App (Y1):   ~$0.20/month (within free tier)
App Insights:        $0 (shared with Scenario 1)
────────────────────────────────────────────
TOTAL Scenario 2:    ~$0.70/month

POC Complete:        ~$13.84/month (all scenarios)
```

**Free Tier Includes:**
- 1 million executions/month
- 400,000 GB-s compute/month

---

## 🎓 LEARNING OBJECTIVES

### **What You'll Learn**

1. **Serverless Patterns**
   - HTTP APIs without servers
   - Scheduled jobs (cron)
   - Async message processing
   - Event-driven file processing

2. **Cost Optimization**
   - Pay-per-execution vs always-on
   - Cold start mitigation
   - Performance tuning

3. **Monitoring**
   - Function-specific telemetry
   - Distributed tracing
   - Custom metrics
   - Alert configuration

4. **Comparison**
   - App Service vs Functions
   - When to use each
   - Trade-offs

---

## 🔥 CLEANUP

### **Destroy All Resources**
```powershell
cd 02-azure-functions
terraform destroy -auto-approve
```

**Time:** 3-5 minutes  
**Cost after destroy:** $0

---

## 📚 NEXT STEPS

1. **Generate Traffic**
   ```powershell
   .\test_functions.ps1 -TestIterations 50
   ```

2. **Explore Application Insights**
   - Live Metrics
   - Performance dashboard
   - Failures analysis

3. **Run KQL Queries**
   - Copy queries from this README
   - Analyze cold starts
   - Compare function performance

4. **Proceed to Scenario 3**
   - Container Apps (coming soon)

---

## 📁 FILES

```
02-azure-functions/
├── main.tf                  Terraform infrastructure
├── variables.tf             Variables
├── outputs.tf               Outputs
├── terraform.tfvars         Active configuration
├── deploy_functions.ps1     Deploy script (PowerShell)
├── deploy_functions.sh      Deploy script (Bash)
├── test_functions.ps1       Test script
└── functions/              Function code
    ├── host.json
    ├── requirements.txt
    ├── HttpTrigger/
    ├── TimerTrigger/
    ├── QueueTrigger/
    └── BlobTrigger/
```

---

## 🆘 TROUBLESHOOTING

**Functions not appearing after deploy:**
- Wait 2-3 minutes for deployment to complete
- Check `az functionapp list` to verify

**HttpTrigger returns 503:**
- Function App is starting (cold start)
- Wait 30 seconds and retry

**Queue messages not processing:**
- Verify queue name in function.json matches Terraform output
- Check function logs: `az functionapp log tail --name <name> --resource-group <rg>`

**Blob trigger not firing:**
- Ensure blob is uploaded to correct container
- Check storage connection string in app settings

---

## 📞 SUPPORT

**Documentation:**
- Main: `PLAN_ESCENARIO_2.md`
- Knowledge Transfer: (to be created after testing)

**Queries:**
- See `docs/` directory for KQL query examples

---

**Created:** 7 de enero de 2026  
**Status:** ✅ Ready for deployment  
**Author:** Brian Poch
