# ROI Calculator Template - AWS Cloud Migration

## Excel Workbook Structure

### Sheet 1: Executive Summary

**Project Overview:**
- Project Name: AWS Cloud Migration
- Client: [Client Name]
- Prepared By: [Name]
- Date: [Date]
- Analysis Period: 5 Years

**Financial Summary:**
| Metric | Value | Formula Reference |
|--------|-------|-------------------|
| Total Migration Investment | $[Amount] | =SUM(Costs!B:B) |
| Total 5-Year Benefits | $[Amount] | =SUM(Benefits!B:B) |
| Net Present Value (NPV) | $[Amount] | =NPV(Assumptions!B2,Cashflow!B:B) |
| Internal Rate of Return (IRR) | [%] | =IRR(Cashflow!B:B) |
| Payback Period | [Months] | Custom formula |
| TCO Reduction | [%] | =(OnPremTCO-CloudTCO)/OnPremTCO |

**Recommendation:**
[Automatic recommendation based on NPV/IRR thresholds and TCO analysis]

---

### Sheet 2: Assumptions

**Financial Assumptions:**
| Parameter | Value | Notes |
|-----------|-------|-------|
| Discount Rate | 8% | Corporate cost of capital |
| Tax Rate | 25% | Corporate tax rate |
| Inflation Rate | 2.5% | Annual inflation assumption |
| Analysis Period | 5 Years | Migration ROI timeframe |

**Current Environment Assumptions:**
| Parameter | Value | Notes |
|-----------|-------|-------|
| Current Servers | [Number] | Physical and virtual servers |
| Current Annual IT Cost | $[Amount] | Total infrastructure cost |
| Data Center Cost | $[Amount]/year | Facility, power, cooling |
| IT Staff FTE | [Number] | Infrastructure team size |
| Average Staff Cost | $[Amount]/year | Fully loaded cost per FTE |
| Hardware Refresh Cycle | 4 years | Server replacement frequency |

**Migration Assumptions:**
| Parameter | Value | Notes |
|-----------|-------|-------|
| Migration Timeline | [Months] | Total migration duration |
| Applications to Migrate | [Number] | Total application portfolio |
| Migration Success Rate | 95% | Successfully migrated apps |
| Performance Improvement | 15% | Expected performance gain |
| Deployment Speed Improvement | 80% | Faster deployment cycles |

**Growth Assumptions:**
| Parameter | Year 1 | Year 2 | Year 3 | Year 4 | Year 5 |
|-----------|--------|--------|--------|--------|--------|
| Business Growth | 10% | 10% | 8% | 8% | 5% |
| Cost Inflation | 3% | 3% | 3% | 3% | 3% |
| Cloud Cost Optimization | 5% | 10% | 15% | 20% | 25% |

---

### Sheet 3: Investment Costs

**Migration Investment (Years 0-1):**
| Category | Description | Amount | Source/Calculation |
|----------|-------------|--------|--------------------|
| AWS Migration Services | MGN, DMS, professional services | $[Amount] | AWS quote |
| Professional Services | Migration consulting | $[Amount] | Partner quote |
| Internal Resources | Staff time (2000 hours × $150/hr) | $[Amount] | =Hours*HourlyRate |
| Training & Certification | AWS skills development | $[Amount] | Training provider |
| Migration Tools | Assessment and automation tools | $[Amount] | Tool licensing |
| Network Connectivity | Direct Connect setup | $[Amount] | Network provider |
| Testing & Validation | Migration testing | $[Amount] | Internal estimate |
| Project Management | Program management office | $[Amount] | PM contractor |
| Contingency | 15% of above costs | $[Amount] | =SUM(above)*0.15 |
| **Total Migration Investment** | | **$[Amount]** | =SUM(B2:B10) |

**Current On-Premise Costs (Annual):**
| Category | Description | Annual Amount | Notes |
|----------|-------------|---------------|-------|
| Hardware Depreciation | Server and storage refresh | $[Amount] | 4-year refresh cycle |
| Data Center | Colocation, power, cooling | $[Amount] | Facility costs |
| Software Licensing | OS, virtualization, databases | $[Amount] | On-premise licenses |
| Personnel | Infrastructure and operations | $[Amount] | [X] FTE fully loaded |
| Maintenance & Support | Hardware/software support | $[Amount] | Annual contracts |
| **Total Current Annual Costs** | | **$[Amount]** | =SUM(B2:B6) |

**Projected AWS Costs (Annual):**
| Category | Year 1 | Year 2 | Year 3 | Year 4 | Year 5 | Notes |
|----------|--------|--------|--------|--------|--------|-------|
| Compute (EC2) | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | Right-sized instances |
| Storage (S3/EBS) | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | Optimized storage |
| Database (RDS) | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | Managed databases |
| Network | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | Data transfer costs |
| Management Tools | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | CloudWatch, etc. |
| Support | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | AWS support plan |
| **Total AWS Annual Costs** | **$[Amount]** | **$[Amount]** | **$[Amount]** | **$[Amount]** | **$[Amount]** | |

---

### Sheet 4: Benefits Analysis

**Cost Reduction Benefits:**

**Infrastructure Cost Savings:**
| Benefit Category | Description | Year 1 | Year 2 | Year 3 | Year 4 | Year 5 | Calculation Method |
|------------------|-------------|--------|--------|--------|--------|--------|--------------------|
| Hardware Elimination | No server refresh needed | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | Avoided capex investment |
| Data Center Savings | Facility cost reduction | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | Current facility cost |
| Software License Optimization | Cloud-native licensing | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | License cost difference |
| Maintenance Elimination | No hardware maintenance | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | Current maintenance costs |

**Operational Efficiency Benefits:**
| Benefit Category | Description | Year 1 | Year 2 | Year 3 | Year 4 | Year 5 | Calculation Method |
|------------------|-------------|--------|--------|--------|--------|--------|--------------------|
| Staff Redeployment | Infrastructure team efficiency | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | FTE cost reallocation |
| Automation Benefits | Reduced manual tasks | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | Hours saved × hourly rate |
| Faster Deployments | Improved time-to-market | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | Revenue acceleration |
| Reduced Downtime | Higher availability | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | Downtime cost reduction |

**Strategic Benefits:**
| Benefit Category | Description | Year 1 | Year 2 | Year 3 | Year 4 | Year 5 | Calculation Method |
|------------------|-------------|--------|--------|--------|--------|--------|--------------------|
| Scalability Value | Elastic capacity | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | Peak capacity cost avoidance |
| Innovation Enablement | New service capabilities | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | Revenue from new features |
| Global Reach | Multi-region capabilities | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | Market expansion value |
| Disaster Recovery | Improved business continuity | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | Risk mitigation value |

**Total Annual Benefits:**
| Year | Total Benefits | Growth Rate |
|------|----------------|-------------|
| 1 | $[Amount] | -- |
| 2 | $[Amount] | [%] |
| 3 | $[Amount] | [%] |
| 4 | $[Amount] | [%] |
| 5 | $[Amount] | [%] |

---

### Sheet 5: TCO Comparison

**5-Year Total Cost of Ownership:**

**On-Premise TCO:**
| Category | Year 1 | Year 2 | Year 3 | Year 4 | Year 5 | Total |
|----------|--------|--------|--------|--------|--------|-------|
| Hardware Refresh | $[Amount] | $0 | $0 | $[Amount] | $0 | $[Amount] |
| Data Center | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] |
| Software Licensing | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] |
| Personnel | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] |
| Maintenance | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] |
| **On-Premise Total** | **$[Amount]** | **$[Amount]** | **$[Amount]** | **$[Amount]** | **$[Amount]** | **$[Amount]** |

**AWS Cloud TCO:**
| Category | Year 1 | Year 2 | Year 3 | Year 4 | Year 5 | Total |
|----------|--------|--------|--------|--------|--------|-------|
| Migration Investment | $[Amount] | $0 | $0 | $0 | $0 | $[Amount] |
| AWS Infrastructure | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] |
| Reduced Personnel | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] |
| Training & Support | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] |
| **Cloud Total** | **$[Amount]** | **$[Amount]** | **$[Amount]** | **$[Amount]** | **$[Amount]** | **$[Amount]** |

**TCO Savings:** $[Amount] over 5 years ([X]% reduction)

---

### Sheet 6: Cash Flow Analysis

**Annual Cash Flow Summary:**
| Year | On-Premise Cost | Cloud Cost | Net Savings | Cumulative Savings | Discounted Savings |
|------|----------------|------------|-------------|-------------------|-------------------|
| 0 | $0 | ($[Migration Cost]) | ($[Amount]) | ($[Amount]) | ($[Amount]) |
| 1 | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] |
| 2 | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] |
| 3 | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] |
| 4 | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] |
| 5 | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] |

**Financial Metrics:**
- Net Present Value (NPV): $[Amount]
- Internal Rate of Return (IRR): [%]
- Payback Period: [Months]
- 5-Year TCO Reduction: [%]

---

### Sheet 7: Sensitivity Analysis

**Variable Impact Analysis:**
Test how changes in key variables affect NPV:

| Variable | -20% | -10% | Base Case | +10% | +20% |
|----------|------|------|-----------|------|------|
| Migration Costs | $[NPV] | $[NPV] | $[NPV] | $[NPV] | $[NPV] |
| AWS Costs | $[NPV] | $[NPV] | $[NPV] | $[NPV] | $[NPV] |
| On-Premise Costs | $[NPV] | $[NPV] | $[NPV] | $[NPV] | $[NPV] |
| Business Growth | $[NPV] | $[NPV] | $[NPV] | $[NPV] | $[NPV] |
| Migration Timeline | $[NPV] | $[NPV] | $[NPV] | $[NPV] | $[NPV] |

**Scenario Analysis:**
| Scenario | Description | NPV | IRR | TCO Reduction |
|----------|-------------|-----|-----|---------------|
| Optimistic | Fast migration, high optimization | $[Amount] | [%] | [%] |
| Most Likely | Base case assumptions | $[Amount] | [%] | [%] |
| Pessimistic | Migration delays, higher costs | $[Amount] | [%] | [%] |

---

### Sheet 8: Migration Strategy Comparison

**Migration Approach Comparison:**
| Approach | Investment | Timeline | Year 1 Savings | 5-Year NPV | Risk Level |
|----------|------------|----------|---------------|------------|------------|
| Lift & Shift (Rehost) | $[Amount] | 6 months | $[Amount] | $[Amount] | Low |
| Replatform | $[Amount] | 12 months | $[Amount] | $[Amount] | Medium |
| Refactor/Re-architect | $[Amount] | 18 months | $[Amount] | $[Amount] | High |
| Hybrid Approach | $[Amount] | 12 months | $[Amount] | $[Amount] | Medium |

**Application Migration Analysis:**
| Migration Pattern | Applications | Effort Level | Cost Impact | Benefit Level |
|-------------------|-------------|--------------|-------------|---------------|
| Rehost | [Number] | Low | Low | Medium |
| Replatform | [Number] | Medium | Medium | High |
| Refactor | [Number] | High | High | Very High |
| Repurchase | [Number] | Low | Medium | High |
| Retire | [Number] | Very Low | Very Low | Medium |
| Retain | [Number] | None | None | None |

---

## Excel Formula Library

**Key Formulas to Include:**

**TCO Calculation:**
```excel
=SUM(hardware_costs, facility_costs, software_costs, personnel_costs, maintenance_costs)
```

**Migration ROI:**
```excel
=(total_5year_savings - migration_investment) / migration_investment
```

**Break-even Analysis:**
```excel
=migration_investment / average_annual_savings
```

**Right-sizing Optimization:**
```excel
=current_capacity * utilization_factor * optimization_percentage
```

**Business Growth Impact:**
```excel
=base_savings * (1 + growth_rate)^year
```

---

## Data Validation Rules

**Input Validation:**
- Server counts: Positive integers only
- Cost fields: Positive currency values
- Growth rates: -25% to 100%
- Utilization: 0% to 100%

**Error Checking:**
- Migration timeline is realistic (6-24 months)
- AWS costs scale with business growth
- Total benefits > Total costs in most scenarios
- Staff redeployment is feasible

---

## Chart Specifications

**Required Charts:**
1. **TCO Comparison** - On-premise vs Cloud costs over 5 years
2. **Migration Timeline & Cash Flow** - Investment and savings by quarter
3. **Cost Breakdown Analysis** - Current vs future cost categories
4. **Sensitivity Analysis** - Tornado chart of key variables
5. **Migration Strategy Comparison** - Different approaches and their ROI

---

## Instructions for Use

1. **Input Current Environment** - Complete all on-premise cost categories
2. **Define Migration Scope** - Specify applications and timeline
3. **Calculate AWS Costs** - Use AWS pricing tools for estimates
4. **Quantify Benefits** - Include both cost savings and business value
5. **Analyze Scenarios** - Test different migration approaches
6. **Validate Assumptions** - Review with stakeholders and validate inputs
7. **Generate Business Case** - Executive summary auto-populates

**File Format:** .xlsx
**Protection:** Lock formula cells, allow input in designated areas
**Version Control:** Include version tracking and assumption changes