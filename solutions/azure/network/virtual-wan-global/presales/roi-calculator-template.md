# Azure Virtual WAN Global - ROI Calculator Template

## Overview

This ROI calculator provides a comprehensive framework for quantifying the financial benefits of implementing Azure Virtual WAN Global. The calculator includes detailed cost modeling, benefit quantification, and risk analysis to support informed decision-making and business case development.

## Executive Summary Template

### Investment Overview
- **Total Solution Investment**: $[CALCULATED]
- **3-Year ROI**: [CALCULATED]%
- **Payback Period**: [CALCULATED] months
- **Net Present Value (NPV)**: $[CALCULATED]
- **Internal Rate of Return (IRR)**: [CALCULATED]%

### Key Financial Benefits
- **Annual Cost Savings**: $[CALCULATED]
- **Productivity Gains**: $[CALCULATED] annually
- **Risk Mitigation Value**: $[CALCULATED]
- **Total 3-Year Benefits**: $[CALCULATED]

---

## Section 1: Current State Cost Analysis

### 1.1 Baseline Network Costs

#### WAN Connectivity Costs
| Cost Category | Monthly Cost | Annual Cost | Notes |
|---------------|--------------|-------------|-------|
| MPLS Circuits | $[INPUT] | $[CALC] | Primary WAN connectivity |
| Internet Circuits | $[INPUT] | $[CALC] | Local internet breakout |
| Backup Circuits | $[INPUT] | $[CALC] | Redundancy and DR |
| Data Overage Charges | $[INPUT] | $[CALC] | Usage-based charges |
| **Total Connectivity** | **$[CALC]** | **$[CALC]** | |

#### Equipment and Infrastructure Costs
| Cost Category | Annual Cost | Depreciation | Maintenance | Total Annual |
|---------------|-------------|--------------|-------------|--------------|
| WAN Routers | $[INPUT] | $[CALC] | $[INPUT] | $[CALC] |
| Firewalls | $[INPUT] | $[CALC] | $[INPUT] | $[CALC] |
| SD-WAN Appliances | $[INPUT] | $[CALC] | $[INPUT] | $[CALC] |
| Other Network Equipment | $[INPUT] | $[CALC] | $[INPUT] | $[CALC] |
| **Total Equipment** | **$[CALC]** | **$[CALC]** | **$[CALC]** | **$[CALC]** |

#### Operational Costs
| Cost Category | FTEs | Annual Salary | Benefits | Total Cost |
|---------------|------|---------------|----------|------------|
| Network Engineers | [INPUT] | $[INPUT] | $[INPUT] | $[CALC] |
| Security Engineers | [INPUT] | $[INPUT] | $[INPUT] | $[CALC] |
| Operations Staff | [INPUT] | $[INPUT] | $[INPUT] | $[CALC] |
| Management Tools | - | - | - | $[INPUT] |
| Training and Certification | - | - | - | $[INPUT] |
| **Total Operations** | **[CALC]** | **$[CALC]** | **$[CALC]** | **$[CALC]** |

#### Software and Licensing Costs
| Software Category | Annual Cost | Growth Rate | 3-Year Total |
|-------------------|-------------|-------------|--------------|
| Network Management | $[INPUT] | [INPUT]% | $[CALC] |
| Security Software | $[INPUT] | [INPUT]% | $[CALC] |
| Monitoring Tools | $[INPUT] | [INPUT]% | $[CALC] |
| Other Licenses | $[INPUT] | [INPUT]% | $[CALC] |
| **Total Software** | **$[CALC]** | | **$[CALC]** |

### 1.2 Hidden and Indirect Costs

#### Downtime and Outage Costs
| Metric | Value | Calculation | Annual Impact |
|--------|-------|-------------|---------------|
| Average Outages per Year | [INPUT] | | |
| Average Duration (hours) | [INPUT] | | |
| Cost per Hour of Downtime | $[INPUT] | | |
| **Total Downtime Cost** | | | **$[CALC]** |

#### Performance Impact Costs
| Performance Issue | Frequency | Impact Hours | Cost per Hour | Annual Cost |
|-------------------|-----------|--------------|---------------|-------------|
| Slow Application Response | [INPUT] | [INPUT] | $[INPUT] | $[CALC] |
| Video Conference Issues | [INPUT] | [INPUT] | $[INPUT] | $[CALC] |
| File Transfer Delays | [INPUT] | [INPUT] | $[INPUT] | $[CALC] |
| **Total Performance Cost** | | | | **$[CALC]** |

#### Compliance and Security Costs
| Risk Category | Probability | Impact Cost | Risk Value |
|---------------|-------------|-------------|------------|
| Security Breach | [INPUT]% | $[INPUT] | $[CALC] |
| Compliance Violation | [INPUT]% | $[INPUT] | $[CALC] |
| Data Loss | [INPUT]% | $[INPUT] | $[CALC] |
| **Total Risk Cost** | | | **$[CALC]** |

### 1.3 Current State Total Cost Summary

| Cost Category | Year 1 | Year 2 | Year 3 | 3-Year Total |
|---------------|--------|--------|--------|--------------|
| Connectivity | $[CALC] | $[CALC] | $[CALC] | $[CALC] |
| Equipment | $[CALC] | $[CALC] | $[CALC] | $[CALC] |
| Operations | $[CALC] | $[CALC] | $[CALC] | $[CALC] |
| Software | $[CALC] | $[CALC] | $[CALC] | $[CALC] |
| Risk/Downtime | $[CALC] | $[CALC] | $[CALC] | $[CALC] |
| **TOTAL BASELINE** | **$[CALC]** | **$[CALC]** | **$[CALC]** | **$[CALC]** |

---

## Section 2: Azure Virtual WAN Solution Costs

### 2.1 Azure Infrastructure Costs

#### Azure Virtual WAN Core Services
| Service Component | Units | Unit Price | Monthly Cost | Annual Cost |
|-------------------|-------|------------|--------------|-------------|
| Virtual WAN (per hub) | [INPUT] | $0.25/hour | $[CALC] | $[CALC] |
| VPN Gateway Scale Units | [INPUT] | $0.15/hour | $[CALC] | $[CALC] |
| ExpressRoute Gateway | [INPUT] | $0.48/hour | $[CALC] | $[CALC] |
| Azure Firewall | [INPUT] | $1.25/hour | $[CALC] | $[CALC] |
| **Total Core Services** | | | **$[CALC]** | **$[CALC]** |

#### Data Processing and Bandwidth
| Data Category | Monthly Volume (GB) | Unit Price | Monthly Cost | Annual Cost |
|---------------|-------------------|------------|--------------|-------------|
| VPN Data Processing | [INPUT] | $0.045/GB | $[CALC] | $[CALC] |
| Firewall Data Processing | [INPUT] | $0.016/GB | $[CALC] | $[CALC] |
| Inter-Hub Data Transfer | [INPUT] | $0.02/GB | $[CALC] | $[CALC] |
| Internet Egress | [INPUT] | $0.087/GB | $[CALC] | $[CALC] |
| **Total Data Costs** | | | **$[CALC]** | **$[CALC]** |

#### Additional Azure Services
| Service | Quantity | Unit Cost | Monthly Cost | Annual Cost |
|---------|----------|-----------|--------------|-------------|
| Log Analytics | [INPUT] GB | $2.30/GB | $[CALC] | $[CALC] |
| Network Watcher | [INPUT] | $[INPUT] | $[CALC] | $[CALC] |
| Azure Monitor | [INPUT] | $[INPUT] | $[CALC] | $[CALC] |
| Key Vault | [INPUT] | $[INPUT] | $[CALC] | $[CALC] |
| **Total Additional** | | | **$[CALC]** | **$[CALC]** |

### 2.2 Implementation and Professional Services

#### Implementation Services
| Service Category | Hours | Rate | Total Cost | Notes |
|------------------|-------|------|------------|-------|
| Discovery and Design | [INPUT] | $[INPUT] | $[CALC] | Architecture and planning |
| Solution Deployment | [INPUT] | $[INPUT] | $[CALC] | Implementation services |
| Migration Services | [INPUT] | $[INPUT] | $[CALC] | Site migration |
| Testing and Validation | [INPUT] | $[INPUT] | $[CALC] | Performance testing |
| Training and Enablement | [INPUT] | $[INPUT] | $[CALC] | Knowledge transfer |
| Project Management | [INPUT] | $[INPUT] | $[CALC] | 15-20% of implementation |
| **Total Services** | **[CALC]** | | **$[CALC]** | |

#### Equipment and Software
| Category | Quantity | Unit Cost | Total Cost | Notes |
|----------|----------|-----------|------------|-------|
| Branch Office Equipment | [INPUT] | $[INPUT] | $[CALC] | SD-WAN appliances if needed |
| Management Software | [INPUT] | $[INPUT] | $[CALC] | Additional tools |
| Security Licenses | [INPUT] | $[INPUT] | $[CALC] | Third-party security |
| **Total Equipment/Software** | | | **$[CALC]** | |

### 2.3 Solution Total Cost Summary

| Cost Category | Year 0 | Year 1 | Year 2 | Year 3 | 3-Year Total |
|---------------|--------|--------|--------|--------|--------------|
| Azure Infrastructure | $0 | $[CALC] | $[CALC] | $[CALC] | $[CALC] |
| Implementation | $[CALC] | $0 | $0 | $0 | $[CALC] |
| Equipment/Software | $[CALC] | $[CALC] | $[CALC] | $[CALC] | $[CALC] |
| **TOTAL SOLUTION COST** | **$[CALC]** | **$[CALC]** | **$[CALC]** | **$[CALC]** | **$[CALC]** |

---

## Section 3: Benefits Quantification

### 3.1 Direct Cost Savings

#### Network Connectivity Savings
| Savings Category | Current Annual | Future Annual | Annual Savings | 3-Year Savings |
|------------------|----------------|---------------|----------------|----------------|
| MPLS Circuit Elimination | $[FROM_1.1] | $[CALC] | $[CALC] | $[CALC] |
| Internet Circuit Optimization | $[FROM_1.1] | $[CALC] | $[CALC] | $[CALC] |
| Backup Circuit Reduction | $[FROM_1.1] | $[CALC] | $[CALC] | $[CALC] |
| Data Overage Elimination | $[FROM_1.1] | $[CALC] | $[CALC] | $[CALC] |
| **Total Connectivity Savings** | **$[CALC]** | **$[CALC]** | **$[CALC]** | **$[CALC]** |

#### Equipment and Maintenance Savings
| Savings Category | Current Annual | Future Annual | Annual Savings | 3-Year Savings |
|------------------|----------------|---------------|----------------|----------------|
| Hardware Refresh Avoidance | $[FROM_1.1] | $[CALC] | $[CALC] | $[CALC] |
| Maintenance Contract Savings | $[FROM_1.1] | $[CALC] | $[CALC] | $[CALC] |
| Power and Cooling Savings | $[INPUT] | $[CALC] | $[CALC] | $[CALC] |
| Data Center Space Savings | $[INPUT] | $[CALC] | $[CALC] | $[CALC] |
| **Total Equipment Savings** | **$[CALC]** | **$[CALC]** | **$[CALC]** | **$[CALC]** |

#### Operational Cost Savings
| Savings Category | Current FTE | Future FTE | Savings per FTE | Annual Savings |
|------------------|-------------|------------|-----------------|----------------|
| Network Operations | [FROM_1.1] | [INPUT] | $[INPUT] | $[CALC] |
| Security Management | [FROM_1.1] | [INPUT] | $[INPUT] | $[CALC] |
| Incident Resolution | [INPUT] | [INPUT] | $[INPUT] | $[CALC] |
| **Total Operational Savings** | | | | **$[CALC]** |

### 3.2 Productivity and Performance Benefits

#### Application Performance Improvements
| Performance Metric | Current Value | Target Value | Improvement | Productivity Gain |
|-------------------|---------------|--------------|-------------|-------------------|
| Application Response Time | [INPUT]ms | [INPUT]ms | [CALC]% | $[CALC]/year |
| Network Latency | [INPUT]ms | [INPUT]ms | [CALC]% | $[CALC]/year |
| Throughput | [INPUT]Mbps | [INPUT]Mbps | [CALC]% | $[CALC]/year |
| **Total Performance Benefits** | | | | **$[CALC]/year** |

#### User Experience and Productivity
| User Category | Count | Hours Saved/Day | Value per Hour | Annual Value |
|---------------|-------|-----------------|----------------|--------------|
| Knowledge Workers | [INPUT] | [INPUT] | $[INPUT] | $[CALC] |
| Sales Representatives | [INPUT] | [INPUT] | $[INPUT] | $[CALC] |
| Customer Service | [INPUT] | [INPUT] | $[INPUT] | $[CALC] |
| Field Workers | [INPUT] | [INPUT] | $[INPUT] | $[CALC] |
| **Total Productivity Benefits** | | | | **$[CALC]** |

#### Business Process Improvements
| Process Category | Current Cost | Improved Cost | Annual Savings | 3-Year Savings |
|------------------|--------------|---------------|----------------|----------------|
| Remote Access Support | $[INPUT] | $[CALC] | $[CALC] | $[CALC] |
| Site Provisioning | $[INPUT] | $[CALC] | $[CALC] | $[CALC] |
| Network Changes | $[INPUT] | $[CALC] | $[CALC] | $[CALC] |
| Troubleshooting | $[INPUT] | $[CALC] | $[CALC] | $[CALC] |
| **Total Process Improvements** | | | **$[CALC]** | **$[CALC]** |

### 3.3 Risk Mitigation and Compliance Benefits

#### Downtime Reduction Benefits
| Metric | Current Value | Future Value | Improvement | Annual Value |
|--------|---------------|--------------|-------------|--------------|
| Network Uptime | [INPUT]% | [INPUT]% | [CALC]% | $[CALC] |
| Mean Time to Recovery | [INPUT]hours | [INPUT]hours | [CALC]hours | $[CALC] |
| Planned Maintenance Windows | [INPUT] | [INPUT] | [CALC] | $[CALC] |
| **Total Uptime Benefits** | | | | **$[CALC]** |

#### Security and Compliance Benefits
| Risk Category | Current Risk Cost | Reduced Risk Cost | Annual Value |
|---------------|-------------------|-------------------|--------------|
| Security Breach Risk | $[FROM_1.2] | $[CALC] | $[CALC] |
| Compliance Violation Risk | $[FROM_1.2] | $[CALC] | $[CALC] |
| Data Loss Risk | $[FROM_1.2] | $[CALC] | $[CALC] |
| **Total Risk Mitigation** | | | **$[CALC]** |

### 3.4 Strategic and Innovation Benefits

#### Business Agility Benefits
| Business Capability | Current Timeline | Future Timeline | Value per Month | Annual Value |
|---------------------|-----------------|-----------------|----------------|--------------|
| New Site Deployment | [INPUT] months | [INPUT] months | $[INPUT] | $[CALC] |
| Service Deployment | [INPUT] months | [INPUT] months | $[INPUT] | $[CALC] |
| Capacity Scaling | [INPUT] months | [INPUT] months | $[INPUT] | $[CALC] |
| **Total Agility Benefits** | | | | **$[CALC]** |

#### Innovation Enablement
| Innovation Category | Estimated Value | Notes |
|---------------------|----------------|-------|
| Cloud Migration Acceleration | $[INPUT] | Faster cloud adoption |
| Digital Workplace Enablement | $[INPUT] | Remote work productivity |
| AI/Analytics Platform | $[INPUT] | Data-driven insights |
| Customer Experience Improvement | $[INPUT] | Better service delivery |
| **Total Innovation Value** | **$[CALC]** | |

### 3.5 Total Benefits Summary

| Benefit Category | Year 1 | Year 2 | Year 3 | 3-Year Total |
|------------------|--------|--------|--------|--------------|
| Direct Cost Savings | $[CALC] | $[CALC] | $[CALC] | $[CALC] |
| Productivity Benefits | $[CALC] | $[CALC] | $[CALC] | $[CALC] |
| Risk Mitigation | $[CALC] | $[CALC] | $[CALC] | $[CALC] |
| Strategic Benefits | $[CALC] | $[CALC] | $[CALC] | $[CALC] |
| **TOTAL BENEFITS** | **$[CALC]** | **$[CALC]** | **$[CALC]** | **$[CALC]** |

---

## Section 4: Financial Analysis

### 4.1 Net Present Value (NPV) Analysis

#### Cash Flow Projection
| Year | Investment | Benefits | Net Cash Flow | Discounted Cash Flow |
|------|------------|----------|---------------|---------------------|
| 0 | $[CALC] | $0 | $[CALC] | $[CALC] |
| 1 | $[CALC] | $[CALC] | $[CALC] | $[CALC] |
| 2 | $[CALC] | $[CALC] | $[CALC] | $[CALC] |
| 3 | $[CALC] | $[CALC] | $[CALC] | $[CALC] |
| **Total** | **$[CALC]** | **$[CALC]** | **$[CALC]** | **$[CALC]** |

#### NPV Calculation Parameters
- **Discount Rate**: [INPUT]%
- **NPV**: $[CALC]
- **Present Value of Benefits**: $[CALC]
- **Present Value of Costs**: $[CALC]

### 4.2 Return on Investment (ROI) Analysis

#### ROI Calculations
- **Total Investment**: $[CALC]
- **Total Benefits (3-year)**: $[CALC]
- **Net Benefits**: $[CALC]
- **3-Year ROI**: [CALC]%
- **Annualized ROI**: [CALC]%

#### Payback Period Analysis
| Month | Cumulative Investment | Cumulative Benefits | Net Position |
|-------|---------------------|-------------------|--------------|
| 6 | $[CALC] | $[CALC] | $[CALC] |
| 12 | $[CALC] | $[CALC] | $[CALC] |
| 18 | $[CALC] | $[CALC] | $[CALC] |
| 24 | $[CALC] | $[CALC] | $[CALC] |
| 30 | $[CALC] | $[CALC] | $[CALC] |
| 36 | $[CALC] | $[CALC] | $[CALC] |

**Payback Period**: [CALC] months

### 4.3 Internal Rate of Return (IRR)

#### IRR Calculation
- **Internal Rate of Return**: [CALC]%
- **Minimum Required Return**: [INPUT]%
- **Excess Return**: [CALC]%

### 4.4 Sensitivity Analysis

#### Key Variable Sensitivity
| Variable | Base Case | -20% | -10% | +10% | +20% |
|----------|-----------|------|------|------|------|
| Implementation Cost | $[BASE] | [CALC]% | [CALC]% | [CALC]% | [CALC]% |
| Annual Azure Costs | $[BASE] | [CALC]% | [CALC]% | [CALC]% | [CALC]% |
| Connectivity Savings | $[BASE] | [CALC]% | [CALC]% | [CALC]% | [CALC]% |
| Productivity Benefits | $[BASE] | [CALC]% | [CALC]% | [CALC]% | [CALC]% |

#### Break-Even Analysis
- **Break-Even Investment**: $[CALC]
- **Break-Even Benefits**: $[CALC]
- **Break-Even Timeframe**: [CALC] months
- **Risk Tolerance**: [CALC]%

---

## Section 5: Risk Assessment and Scenarios

### 5.1 Risk Factors and Mitigation

#### Implementation Risks
| Risk Category | Probability | Impact | Risk Score | Mitigation Cost |
|---------------|-------------|--------|------------|-----------------|
| Project Delays | [INPUT]% | $[INPUT] | [CALC] | $[INPUT] |
| Cost Overruns | [INPUT]% | $[INPUT] | [CALC] | $[INPUT] |
| Performance Issues | [INPUT]% | $[INPUT] | [CALC] | $[INPUT] |
| Security Vulnerabilities | [INPUT]% | $[INPUT] | [CALC] | $[INPUT] |
| **Total Risk Cost** | | | | **$[CALC]** |

#### Operational Risks
| Risk Category | Probability | Annual Impact | Risk Value |
|---------------|-------------|---------------|------------|
| Service Disruption | [INPUT]% | $[INPUT] | $[CALC] |
| Performance Degradation | [INPUT]% | $[INPUT] | $[CALC] |
| Compliance Issues | [INPUT]% | $[INPUT] | $[CALC] |
| Vendor Dependency | [INPUT]% | $[INPUT] | $[CALC] |
| **Total Operational Risk** | | | **$[CALC]** |

### 5.2 Scenario Analysis

#### Conservative Scenario (70% of projected benefits)
| Metric | Conservative Value |
|--------|-------------------|
| Total Benefits | $[CALC] |
| Net Benefits | $[CALC] |
| ROI | [CALC]% |
| Payback Period | [CALC] months |

#### Optimistic Scenario (130% of projected benefits)
| Metric | Optimistic Value |
|--------|------------------|
| Total Benefits | $[CALC] |
| Net Benefits | $[CALC] |
| ROI | [CALC]% |
| Payback Period | [CALC] months |

#### Worst Case Scenario
- **Benefit Realization**: 50%
- **Cost Overrun**: 150%
- **ROI**: [CALC]%
- **Risk Mitigation**: Required

---

## Section 6: Executive Summary and Recommendations

### 6.1 Financial Summary

#### Investment Overview
- **Total 3-Year Investment**: $[CALC]
- **Total 3-Year Benefits**: $[CALC]
- **Net Present Value**: $[CALC]
- **Return on Investment**: [CALC]%
- **Payback Period**: [CALC] months
- **Internal Rate of Return**: [CALC]%

#### Key Financial Metrics
| Metric | Value | Industry Benchmark | Assessment |
|--------|-------|-------------------|------------|
| NPV | $[CALC] | > $0 | [PASS/FAIL] |
| ROI | [CALC]% | > 20% | [PASS/FAIL] |
| Payback | [CALC] months | < 24 months | [PASS/FAIL] |
| IRR | [CALC]% | > 15% | [PASS/FAIL] |

### 6.2 Benefits Realization Timeline

#### Cumulative Benefits by Quarter
| Quarter | Investment | Benefits | Net Position | ROI to Date |
|---------|------------|----------|--------------|-------------|
| Q1 | $[CALC] | $[CALC] | $[CALC] | [CALC]% |
| Q2 | $[CALC] | $[CALC] | $[CALC] | [CALC]% |
| Q3 | $[CALC] | $[CALC] | $[CALC] | [CALC]% |
| Q4 | $[CALC] | $[CALC] | $[CALC] | [CALC]% |

### 6.3 Risk-Adjusted Returns

#### Monte Carlo Analysis Results
- **Mean ROI**: [CALC]%
- **Standard Deviation**: [CALC]%
- **90% Confidence Interval**: [CALC]% to [CALC]%
- **Probability of Positive ROI**: [CALC]%

#### Value at Risk (VaR)
- **95% VaR**: $[CALC]
- **99% VaR**: $[CALC]
- **Expected Shortfall**: $[CALC]

### 6.4 Recommendations

#### Investment Recommendation
Based on the financial analysis:
- **Recommendation**: [PROCEED/DEFER/REJECT]
- **Rationale**: [DETAILED_EXPLANATION]
- **Conditions**: [CONDITIONS_IF_ANY]

#### Implementation Approach
- **Recommended Approach**: [PHASED/BIG_BANG]
- **Priority Locations**: [SITE_LIST]
- **Timeline**: [RECOMMENDED_TIMELINE]
- **Budget Authorization**: $[AMOUNT]

#### Success Metrics and Governance
- **Key Performance Indicators**: [KPI_LIST]
- **Review Schedule**: [REVIEW_FREQUENCY]
- **Governance Structure**: [GOVERNANCE_MODEL]
- **Risk Management**: [RISK_APPROACH]

---

## Section 7: Calculator Usage Guide

### 7.1 Data Collection Requirements

#### Required Information Sources
- **Financial Data**: Annual network budgets, staff costs, equipment depreciation
- **Performance Data**: Network utilization, outage frequency, response times
- **Business Data**: User counts, productivity metrics, growth projections
- **Technical Data**: Current architecture, capacity requirements, integration needs

#### Data Quality Guidelines
- **Accuracy**: Use actual historical data where available
- **Completeness**: Fill all applicable fields for accurate calculations
- **Consistency**: Ensure data aligns across different sections
- **Validation**: Cross-reference with multiple sources

### 7.2 Customization Guidelines

#### Industry-Specific Adjustments
- **Manufacturing**: Emphasize operational technology integration
- **Financial Services**: Focus on compliance and security benefits
- **Healthcare**: Highlight data protection and availability requirements
- **Retail**: Emphasize customer experience and seasonal scalability

#### Regional Considerations
- **Labor Costs**: Adjust based on geographic location
- **Connectivity Costs**: Account for regional pricing variations
- **Regulatory Requirements**: Include region-specific compliance costs
- **Currency**: Convert to appropriate local currency

### 7.3 Validation and Quality Assurance

#### Internal Validation Checklist
- [ ] All input fields completed with actual data
- [ ] Calculations verified using alternative methods
- [ ] Assumptions documented and validated
- [ ] Stakeholder review completed
- [ ] Financial team approval obtained

#### External Validation
- [ ] Vendor pricing confirmed
- [ ] Implementation estimates validated
- [ ] Benefit projections benchmarked
- [ ] Risk assessments peer-reviewed

---

## Document Control

**Calculator Information:**
- **Version**: 1.0
- **Created by**: [NAME]
- **Creation date**: [DATE]
- **Last modified**: [DATE]
- **Review cycle**: Quarterly

**Approval Workflow:**
- **Financial Review**: [NAME/DATE]
- **Technical Review**: [NAME/DATE]
- **Business Review**: [NAME/DATE]
- **Executive Approval**: [NAME/DATE]

**Supporting Documentation:**
- [ ] Current state cost analysis
- [ ] Technical requirements document
- [ ] Vendor proposals and pricing
- [ ] Risk assessment report
- [ ] Implementation plan
- [ ] Business case presentation

---

**ROI Calculator Template**  
**Document Version**: 1.0  
**Last Updated**: August 2024  
**Next Review**: November 2024

*This ROI calculator template is designed to provide comprehensive financial analysis for Azure Virtual WAN Global implementations. All calculations should be validated with actual data and reviewed by appropriate stakeholders before making investment decisions.*