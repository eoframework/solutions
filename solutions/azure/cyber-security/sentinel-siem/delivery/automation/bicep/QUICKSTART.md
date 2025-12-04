# Microsoft Sentinel SIEM - Quick Start Guide

Get your Sentinel SIEM deployed in 5 steps!

## Prerequisites

- Azure CLI installed (`az version`)
- Azure subscription with Owner/Contributor access
- Logged in to Azure (`az login`)

## Step 1: Update Parameters

Edit the parameter file for your environment:

```bash
# For production
vi parameters/prod.parameters.json

# For test
vi parameters/test.parameters.json
```

Update these required placeholders:
```json
{
  "alertEmail": "[ALERT_EMAIL]",              // e.g., "soc-team@company.com"
  "socAdGroupId": "[SOC_GROUP_ID]",           // Azure AD group ID
  "socAdminGroupId": "[ADMIN_GROUP_ID]",      // Azure AD group ID
  "serviceNowEndpoint": "[SERVICENOW_URL]",   // e.g., "https://instance.service-now.com"
  "teamsWebhookUrl": "[TEAMS_WEBHOOK]"        // Teams webhook URL
}
```

## Step 2: Validate Templates

Run the validation script:

```bash
# Validate test environment
./scripts/validate.sh test

# Validate all environments
./scripts/validate.sh all
```

## Step 3: Deploy

Deploy to your environment:

```bash
# Deploy to test (recommended first)
./scripts/deploy.sh test [SUBSCRIPTION_ID]

# Deploy to production
./scripts/deploy.sh prod [SUBSCRIPTION_ID]

# Deploy to DR
./scripts/deploy.sh dr [SUBSCRIPTION_ID]
```

The script will:
1. Validate prerequisites
2. Show what-if analysis
3. Ask for confirmation
4. Deploy all resources
5. Save outputs to JSON file

## Step 4: Configure Data Connectors

After deployment, in Azure Portal:

1. Navigate to Sentinel workspace
2. Go to **Data connectors**
3. For each enabled connector:
   - Click **Open connector page**
   - Follow authentication steps
   - Grant admin consent if needed
   - Verify connection status

## Step 5: Test and Monitor

1. **Check Incidents Dashboard**
   ```
   Sentinel > Incidents
   ```

2. **Review Analytics Rules**
   ```
   Sentinel > Analytics > Active rules
   ```

3. **Test Playbooks**
   ```
   Sentinel > Automation > Active playbooks
   ```

4. **View Workbooks**
   ```
   Sentinel > Workbooks > My workbooks
   ```

## Quick Commands

```bash
# Check deployment status
az deployment sub list --query "[?contains(name,'sentinel')]" -o table

# View resources
az resource list --resource-group rg-sentinel-prod-001 -o table

# Check Sentinel workspace
az sentinel workspace show \
  --workspace-name log-sentinel-prod-001 \
  --resource-group rg-sentinel-prod-001
```

## Deployment Times

- **Test Environment:** ~15-20 minutes
- **Production Environment:** ~20-30 minutes
- **DR Environment:** ~20-30 minutes

## Default Configurations

### Production
- 90-day retention, 500GB/day cap
- All 9 data connectors enabled
- 50 analytics rules (30 built-in + 20 custom)
- 12 automation playbooks
- UEBA enabled

### Test
- 30-day retention, 5GB/day cap
- 3 basic data connectors
- 15 analytics rules (10 built-in + 5 custom)
- 5 automation playbooks
- UEBA disabled

### DR
- Same as production
- Deployed to westus2
- Standby for failover

## Troubleshooting

### Issue: Validation fails
```bash
# Check Azure CLI login
az account show

# Verify bicep installation
az bicep version

# Check parameter file syntax
cat parameters/prod.parameters.json | jq .
```

### Issue: Deployment fails
```bash
# Check deployment errors
az deployment sub show --name [DEPLOYMENT_NAME] --query properties.error

# View operation details
az deployment sub operation list --name [DEPLOYMENT_NAME]
```

### Issue: Data connector not working
- Verify admin consent was granted
- Check service principal permissions
- Review connector logs in Azure Portal

## Support Resources

- **Full Documentation:** See README.md
- **Validation Summary:** See VALIDATION_SUMMARY.md
- **Azure Sentinel Docs:** https://docs.microsoft.com/en-us/azure/sentinel/
- **Bicep Docs:** https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/

## What's Deployed?

- ✅ Log Analytics Workspace
- ✅ Sentinel Solution
- ✅ Key Vault
- ✅ 9 Data Connectors
- ✅ 8 Analytics Rules
- ✅ 5 Automation Playbooks
- ✅ 5 Workbooks
- ✅ RBAC Assignments

## Next Steps After Deployment

1. Complete data connector authentication
2. Tune analytics rules for your environment
3. Test automation playbooks
4. Configure UEBA (prod/DR)
5. Customize workbooks
6. Set up incident response procedures
7. Train SOC team on new platform

---

**Ready to deploy?** Start with test environment first!

```bash
./scripts/validate.sh test && ./scripts/deploy.sh test
```
