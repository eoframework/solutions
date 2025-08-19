# ROI Calculator Template - AWS Disaster Recovery

## Excel Workbook Structure

### Sheet 1: Executive Summary

**Project Overview:**
- Project Name: AWS Disaster Recovery Implementation
- Client: [Client Name]
- Prepared By: [Name]
- Date: [Date]
- Analysis Period: 5 Years

**Financial Summary:**
| Metric | Value | Formula Reference |
|--------|-------|-------------------|
| Total Investment | $[Amount] | =SUM(Costs!B:B) |
| Total Benefits (Risk Avoidance) | $[Amount] | =SUM(Benefits!B:B) |
| Net Present Value (NPV) | $[Amount] | =NPV(Assumptions!B2,Cashflow!B:B) |
| Risk-Adjusted ROI | [%] | =(Benefits-Costs)/Costs |
| Payback Period | [Months] | Custom formula |
| Cost of Downtime Avoided | $[Amount]/year | =Assumptions!DowntimeHours*HourlyCost |

**Recommendation:**
[Automatic recommendation based on risk-adjusted NPV and downtime avoidance]

---

### Sheet 2: Assumptions

**Financial Assumptions:**
| Parameter | Value | Notes |
|-----------|-------|-------|
| Discount Rate | 8% | Corporate cost of capital |
| Risk-Free Rate | 3% | Treasury rate |
| Inflation Rate | 2.5% | Annual inflation assumption |
| Analysis Period | 5 Years | DR investment lifecycle |

**Business Assumptions:**
| Parameter | Value | Notes |
|-----------|-------|-------|
| Current RTO | [Hours] | Recovery Time Objective |
| Target RTO | 15 Minutes | AWS multi-region target |
| Current RPO | [Hours] | Recovery Point Objective |
| Target RPO | 1 Hour | Replication frequency |
| Application Availability SLA | 99.9% | Current availability target |
| Revenue per Hour | $[Amount] | Hourly revenue at risk |
| Cost per Hour of Downtime | $[Amount] | Total business impact cost |

**Disaster Risk Assumptions:**
| Risk Type | Annual Probability | Duration (Hours) | Business Impact |
|-----------|-------------------|------------------|-----------------|
| Data Center Outage | 5% | 12 | $[Amount] |
| Natural Disaster | 2% | 48 | $[Amount] |
| Cyber Attack | 10% | 8 | $[Amount] |
| Human Error | 15% | 4 | $[Amount] |
| Hardware Failure | 20% | 6 | $[Amount] |

**Growth Assumptions:**
| Parameter | Year 1 | Year 2 | Year 3 | Year 4 | Year 5 |
|-----------|--------|--------|--------|--------|--------|
| Revenue Growth | 10% | 10% | 8% | 8% | 5% |
| Cost Inflation | 3% | 3% | 3% | 3% | 3% |
| Risk Exposure Growth | 5% | 5% | 5% | 5% | 5% |

---

### Sheet 3: Investment Costs

**Initial Implementation Costs (Year 0):**
| Category | Description | Amount | Source/Calculation |
|----------|-------------|--------|--------------------|
| AWS Infrastructure Setup | Secondary region setup | $[Amount] | AWS estimate |
| Professional Services | DR implementation | $[Amount] | Partner quote |
| Internal Resources | Staff time (320 hours × $150/hr) | $[Amount] | =Hours*HourlyRate |
| Training | AWS DR training | $[Amount] | Training provider |
| DR Testing Tools | Chaos engineering tools | $[Amount] | Tool licensing |
| Documentation | Runbooks and procedures | $[Amount] | Internal estimate |
| Project Management | 16 weeks PM | $[Amount] | PM contractor |
| Contingency | 10% of above costs | $[Amount] | =SUM(above)*0.10 |
| **Total Year 0** | | **$[Amount]** | =SUM(B2:B9) |

**Ongoing Annual Costs:**
| Category | Description | Year 1 | Year 2 | Year 3 | Year 4 | Year 5 |
|----------|-------------|--------|--------|--------|--------|--------|
| AWS DR Infrastructure | Standby resources, data transfer | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] |
| Monitoring Tools | CloudWatch, third-party | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] |
| DR Testing | Quarterly DR tests | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] |
| Training & Certification | Annual AWS training | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] |
| **Annual Totals** | | **$[Amount]** | **$[Amount]** | **$[Amount]** | **$[Amount]** | **$[Amount]** |

---

### Sheet 4: Benefits Analysis

**Risk Avoidance Benefits:**

**Downtime Cost Avoidance:**
| Benefit Category | Description | Year 1 | Year 2 | Year 3 | Year 4 | Year 5 | Calculation Method |
|------------------|-------------|--------|--------|--------|--------|--------|--------------------|
| Revenue Protection | Lost revenue during outages | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | Risk probability × duration × revenue/hour |
| Productivity Loss | Employee downtime costs | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | Affected employees × hours × rate |
| Customer Impact | Customer satisfaction/retention | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | Churn rate × customer value |
| SLA Penalties | Service level agreement penalties | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | Contract penalties avoided |

**Business Continuity Benefits:**
| Benefit Category | Description | Year 1 | Year 2 | Year 3 | Year 4 | Year 5 | Calculation Method |
|------------------|-------------|--------|--------|--------|--------|--------|--------------------|
| Brand Protection | Reputation damage avoidance | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | Brand value at risk |
| Compliance Value | Regulatory requirement fulfillment | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | Audit costs + penalties avoided |
| Insurance Premium Reduction | Business interruption insurance | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | Premium reduction |
| Competitive Advantage | Market position protection | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | Market share protection |

**Operational Benefits:**
| Benefit Category | Description | Year 1 | Year 2 | Year 3 | Year 4 | Year 5 | Calculation Method |
|------------------|-------------|--------|--------|--------|--------|--------|--------------------|
| Faster Recovery | RTO improvement value | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | (Current RTO - Target RTO) × cost/hour |
| Data Protection | RPO improvement value | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | Data loss cost avoidance |
| Automation Benefits | Reduced manual effort | $[Amount] | $[Amount] | $[Amount] | $[Amount] | $[Amount] | Manual hours × hourly rate |

**Total Annual Benefits:**
| Year | Total Benefits | Growth Rate |
|------|----------------|-------------|
| 1 | $[Amount] | -- |
| 2 | $[Amount] | [%] |
| 3 | $[Amount] | [%] |
| 4 | $[Amount] | [%] |
| 5 | $[Amount] | [%] |

---

### Sheet 5: Cash Flow Analysis

**Annual Cash Flow Summary:**
| Year | Investment | Benefits | Net Cash Flow | Cumulative Cash Flow | Discounted Cash Flow |
|------|------------|----------|---------------|-------------------|-------------------|
| 0 | ($[Amount]) | $0 | ($[Amount]) | ($[Amount]) | ($[Amount]) |
| 1 | ($[Amount]) | $[Amount] | $[Amount] | ($[Amount]) | $[Amount] |
| 2 | ($[Amount]) | $[Amount] | $[Amount] | $[Amount] | $[Amount] |
| 3 | ($[Amount]) | $[Amount] | $[Amount] | $[Amount] | $[Amount] |
| 4 | ($[Amount]) | $[Amount] | $[Amount] | $[Amount] | $[Amount] |
| 5 | ($[Amount]) | $[Amount] | $[Amount] | $[Amount] | $[Amount] |

**Financial Metrics:**
- Net Present Value (NPV): $[Amount]
- Risk-Adjusted ROI: [%]
- Payback Period: [Months]
- Cost of Risk: $[Amount] annually

---

### Sheet 6: Sensitivity Analysis

**Variable Impact Analysis:**
Test how changes in key variables affect NPV:

| Variable | -20% | -10% | Base Case | +10% | +20% |
|----------|------|------|-----------|------|------|
| Downtime Cost/Hour | $[NPV] | $[NPV] | $[NPV] | $[NPV] | $[NPV] |
| Disaster Probability | $[NPV] | $[NPV] | $[NPV] | $[NPV] | $[NPV] |
| Implementation Cost | $[NPV] | $[NPV] | $[NPV] | $[NPV] | $[NPV] |
| Ongoing Costs | $[NPV] | $[NPV] | $[NPV] | $[NPV] | $[NPV] |

**Scenario Analysis:**
| Scenario | Description | NPV | Risk-Adjusted ROI | Payback |
|----------|-------------|-----|-------------------|---------|
| Optimistic | High disaster risk, low costs | $[Amount] | [%] | [Months] |
| Most Likely | Base case assumptions | $[Amount] | [%] | [Months] |
| Pessimistic | Low disaster risk, high costs | $[Amount] | [%] | [Months] |

---

### Sheet 7: Risk Analysis

**Disaster Risk Assessment:**
| Disaster Type | Historical Frequency | Business Impact | Risk Score | Mitigation Value |
|---------------|---------------------|-----------------|------------|------------------|
| System Outage | 2 times/year | $[Amount]/hour | High | $[Amount] |
| Natural Disaster | 0.1 times/year | $[Amount]/day | Medium | $[Amount] |
| Cyber Attack | 0.5 times/year | $[Amount]/hour | High | $[Amount] |
| Human Error | 4 times/year | $[Amount]/hour | Medium | $[Amount] |

**Implementation Risks:**
| Risk Factor | Impact | Probability | Risk Adjustment | Adjusted Benefit |
|-------------|--------|-------------|-----------------|------------------|
| Complex Implementation | 20% cost increase | 15% | $[Amount] | $[Amount] |
| Performance Issues | Slower failover | 10% | $[Amount] | $[Amount] |
| Staff Adoption | Operational errors | 20% | $[Amount] | $[Amount] |

---

### Sheet 8: Benchmark Comparison

**Industry Benchmarks:**
| Metric | Our Project | Industry Average | Industry Best |
|--------|-------------|------------------|---------------|
| RTO Achievement | 15 minutes | 4 hours | 5 minutes |
| RPO Achievement | 1 hour | 24 hours | 15 minutes |
| DR Implementation Time | 4 months | 9 months | 3 months |
| Annual DR Cost | $[Amount] | $[Amount] | $[Amount] |

**DR Solution Comparison:**
| Option | Investment | Annual Cost | RTO | RPO | Risk Mitigation |
|--------|------------|-------------|-----|-----|-----------------|
| AWS Multi-Region DR | $[Amount] | $[Amount] | 15 min | 1 hour | 95% |
| Traditional DR Site | $[Amount] | $[Amount] | 4 hours | 24 hours | 80% |
| Backup Only | $[Amount] | $[Amount] | 48 hours | 24 hours | 60% |
| Do Nothing | $0 | $0 | N/A | N/A | 0% |

---

## Excel Formula Library

**Key Formulas to Include:**

**Risk-Adjusted NPV:**
```excel
=SUMPRODUCT(disaster_probability_array, npv_scenario_array)
```

**Downtime Cost Calculation:**
```excel
=disaster_probability * duration_hours * (revenue_per_hour + operational_cost_per_hour)
```

**Risk Mitigation Value:**
```excel
=(current_risk_exposure - future_risk_exposure) * probability_of_occurrence
```

**Payback Period with Risk Adjustment:**
```excel
=MATCH(TRUE, cumulative_risk_adjusted_cashflow>=0, 0)
```

**Business Continuity Value:**
```excel
=brand_value_at_risk * reputation_impact_percentage * disaster_probability
```

---

## Data Validation Rules

**Input Validation:**
- Probability fields: 0% to 100%
- Currency fields: Positive values only
- RTO/RPO: Realistic time ranges
- Growth rates: -20% to 50%

**Error Checking:**
- Total risk mitigation value > Total costs
- RTO improvement is measurable
- Disaster probabilities sum to reasonable total
- Benefits scale with revenue growth

---

## Chart Specifications

**Required Charts:**
1. **Risk Exposure Over Time** - Shows current vs future risk
2. **Cost vs Risk Mitigation** - Compares investment to risk reduction
3. **Disaster Impact Analysis** - Shows cost of different disaster types
4. **RTO/RPO Improvement** - Before and after comparison
5. **Scenario Analysis** - Risk-adjusted returns under different scenarios

---

## Instructions for Use

1. **Start with Risk Assessment** - Define disaster scenarios and probabilities
2. **Input Business Impact** - Quantify cost of downtime and business disruption
3. **Complete Cost Analysis** - Enter DR implementation and operational costs
4. **Calculate Risk Mitigation** - Quantify value of improved RTO/RPO
5. **Analyze Scenarios** - Test different risk and cost assumptions
6. **Generate Recommendation** - Executive summary auto-populates with risk-adjusted ROI

**File Format:** .xlsx
**Protection:** Lock formula cells, allow input in designated areas
**Version Control:** Include version tracking and disaster risk updates