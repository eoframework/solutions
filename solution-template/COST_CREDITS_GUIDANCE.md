# Cloud Provider & Partner Credits Guidance

## ⚠️ IMPORTANT: This is the ONLY Supported Format

**All cost-breakdown.csv files must use the 9-column format documented in this guide.**

This format shows both list prices and partner/cloud provider credits, providing transparency and demonstrating value from partner programs and cloud incentives.

## Overview

When creating cost breakdowns for cloud solutions, include provider and partner credits to show both list prices and net costs. This provides transparency and demonstrates value from partner programs and cloud incentives.

## Cost Table Format

Use the **9-column format** for cost-breakdown.csv files:

```csv
Cost Category,Description,Year 1 List,Provider/Partner Credit,Year 1 Net,Year 2,Year 3,3-Year Total,Credit Comments
```

### Column Definitions

| Column | Purpose | Example |
|--------|---------|---------|
| **Cost Category** | High-level grouping | Professional Services, Cloud Infrastructure, Software Licenses |
| **Description** | Detailed line item description | Azure VM Standard_D4s_v5 - Web tier (4 vCPU, 16GB RAM) |
| **Year 1 List** | Full list price before credits | $10,000 |
| **Provider/Partner Credit** | Credits applied (negative value) | ($1,500) or $0 |
| **Year 1 Net** | Actual Year 1 cost after credits | $8,500 |
| **Year 2** | Year 2 recurring cost (no credits) | $10,000 |
| **Year 3** | Year 3 recurring cost (no credits) | $10,000 |
| **3-Year Total** | Sum of net Year 1 + Year 2 + Year 3 | $28,500 |
| **Credit Comments** | Explanation of credit source | AWS AI Services Credit - 30% Year 1 |

## Solution Briefing Table Format

In solution-briefing.md, use the **7-column format**:

```markdown
| Cost Category | Year 1 List | Provider/Partner Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|-------------------------|------------|---------|---------|--------------|
| Professional Services | $100,000 | ($10,000) | $90,000 | $0 | $0 | $90,000 |
| Cloud Infrastructure | $25,000 | ($3,000) | $22,000 | $25,000 | $25,000 | $72,000 |
| **TOTAL INVESTMENT** | **$125,000** | **($13,000)** | **$112,000** | **$25,000** | **$25,000** | **$162,000** |
```

Always include a credit breakdown section:

```markdown
**Provider/Partner Credits Breakdown (Year 1 Only):**
- **Partner Services Credit:** $10,000 (applied to architecture & implementation)
- **Cloud Consumption Credit:** $3,000 (first-year usage incentives)
```

## Provider-Specific Credit Programs

### AWS Credits

**AWS Partner Credits:**
- **AWS Partner Services Credit:** Up to $15,000 for consulting partner engagements
- **AWS MAP (Migration Acceleration Program):** Up to $50,000 for migrations
- **AWS AI/ML Services Credit:** 10-35% discount on AI services (Year 1 consumption)

**Where to Apply:**
- Partner Services Credit → Professional Services (architecture, implementation)
- AI/ML Credit → Cloud Infrastructure (Textract, Comprehend, Rekognition)

**Example:**
```csv
Professional Services,Solution Architecture & Design,$15000,$5000,$10000,$0,$0,$10000,AWS Partner Services Credit
Cloud Infrastructure,Amazon Textract Analysis,$10000,$3000,$7000,$10000,$10000,$27000,AWS AI Services Credit - 30% Year 1
```

### Azure Credits

**Microsoft Partner Credits:**
- **Microsoft Partner Services Credit:** Up to $15,000 for Microsoft partners
- **Azure Consumption Credits:** $2,500-$10,000 for new Azure customers
- **Azure AI Services Discount:** 20-30% discount on Cognitive Services (Year 1)

**Where to Apply:**
- Partner Services Credit → Professional Services (architecture, compliance setup)
- AI Services Discount → Cloud Infrastructure (Document Intelligence, Cognitive Services)

**Example:**
```csv
Professional Services,Enterprise Architecture & Design,$25000,$10000,$15000,$0,$0,$15000,Microsoft Partner Services Credit
Cloud Infrastructure,Azure AI Document Intelligence,$12000,$3600,$8400,$12000,$12000,$32400,Azure AI Services Credit - 30% Year 1
```

### GCP Credits

**Google Cloud Credits:**
- **Google Cloud Partner Credit:** Up to $10,000 for consulting partners
- **GCP Free Tier Credits:** $300 for new customers (first 90 days)
- **Committed Use Discounts:** 25-52% for 1-3 year commitments (apply to Year 2-3 pricing, not credits)

**Where to Apply:**
- Partner Credit → Professional Services
- AI/ML Credits → Cloud Infrastructure (Vertex AI, Document AI)

**Example:**
```csv
Professional Services,Solution Design & Architecture,$18000,$8000,$10000,$0,$0,$10000,Google Cloud Partner Credit
Cloud Infrastructure,Vertex AI Document Processing,$8000,$1600,$6400,$8000,$8000,$22400,GCP AI Credit - 20% Year 1
```

## Best Practices

### 1. Credit Timing
- **Year 1 Only:** Most credits apply only to Year 1
- **Exceptions:** Some consumption credits may extend to Year 2 (specify in comments)

### 2. Credit Allocation
- **Professional Services:** Partner engagement credits (10-35% of services cost)
- **Cloud Infrastructure:** AI/ML consumption credits (10-35% of specific service usage)
- **NO credits on:** Software licenses (third-party), support contracts, standard compute/storage

### 3. Total Row Calculation
```csv
Total Investment,,$150000,($15000),$135000,$30000,$30000,$195000,Year 1 credits reduce net investment by 10%
```

Include percentage reduction in comment field.

### 4. Realistic Credit Amounts

**Typical Ranges:**
- **Small Projects ($100K-$300K):** $5K-$15K total credits (5-10%)
- **Medium Projects ($300K-$1M):** $15K-$40K total credits (8-12%)
- **Large Projects ($1M+):** $40K-$100K+ total credits (10-15%)

### 5. Documentation Requirements

Always add to solution-briefing.md:

```markdown
**Provider/Partner Credits Breakdown (Year 1 Only):**
- **[Partner Name] Services Credit:** $X,XXX (applied to [specific services])
- **[Cloud Provider] Consumption Credit:** $X,XXX ([service names] first-year usage)

**Note:** Credits are one-time Year 1 benefits. Year 2-3 costs reflect standard list pricing.
```

## Example: Complete Cost Breakdown

```csv
Cost Category,Description,Year 1 List,Provider/Partner Credit,Year 1 Net,Year 2,Year 3,3-Year Total,Credit Comments
Professional Services,Solution Architecture & Design (60 hrs @ $225/hr),$13500,$5000,$8500,$0,$0,$8500,AWS Partner Services Credit
Professional Services,Infrastructure Deployment (60 hrs @ $200/hr),$12000,$0,$12000,$0,$0,$12000,
Cloud Infrastructure,Amazon Textract Document Analysis (50k pages/month),$9000,$3150,$5850,$9000,$9000,$23850,AWS AI Services Credit - 35% Year 1
Cloud Infrastructure,AWS Lambda processing (500k GB-sec/month),$100,$0,$100,$100,$100,$300,
Software Licenses,Datadog Pro monitoring (3 hosts),$828,$0,$828,$828,$828,$2484,No credits on third-party software
Support & Maintenance,AWS managed services (15% of infrastructure),$1365,$0,$1365,$1365,$1365,$4095,
Total Investment,,$36793,$8150,$28643,$11293,$11293,$51229,Year 1 credits reduce net investment by 22%
```

## Common Mistakes to Avoid

❌ **Don't:**
- Apply credits to third-party software licenses (Datadog, PagerDuty, etc.)
- Apply credits to Years 2-3 (unless explicitly multi-year program)
- Use unrealistic credit amounts (>20% of total without justification)
- Forget to update 3-Year Total column after applying credits

✅ **Do:**
- Document credit source in comments column
- Show both list and net pricing for transparency
- Apply credits only to eligible services (cloud native, professional services)
- Include credit breakdown in solution-briefing.md

## Template Files Updated

The following template files have been updated with credit structure:

- ✅ `solution-template/.../solution-briefing.md` - 7-column investment table with credits
- ✅ `All production solutions` - Use 9-column format (MANDATORY)

## Creating New Solutions

When creating new solutions, you MUST:

1. ✅ Use the **9-column format** for cost-breakdown.csv
2. ✅ Include partner/vendor credits in solution-briefing.md Investment Summary table
3. ✅ Document credit sources in the "Credit Comments" column
4. ✅ Run `compute-costs.py` to automatically update markdown files after modifying cost-breakdown.csv
