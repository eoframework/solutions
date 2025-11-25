---
presentation_title: Solution Briefing
solution_name: AWS Cloud Migration - On-Premise to Cloud
presenter_name: [Presenter Name]
client_logo: ../../assets/logos/client_logo.png
footer_logo_left: ../../assets/logos/consulting_company_logo.png
footer_logo_right: ../../assets/logos/eo-framework-logo-real.png
---

# AWS Cloud Migration - Solution Briefing

## Slide Deck Structure for PowerPoint
**10 Slides**

### Slide 1: Title Slide
**layout:** eo_title_slide

**Presentation Title:** Solution Briefing
**Subtitle:** AWS Cloud Migration - On-Premise to Cloud
**Presenter:** [Presenter Name] | [Current Date]
**Logos:**
- Client Logo (top center)
- Consulting Company Logo (footer left)
- EO Framework Logo (footer right)

---

### Business Opportunity
**layout:** eo_two_column

**Accelerating Digital Transformation Through Cloud Migration**

- **Opportunity**
  - Eliminate data center costs and redirect capital to business innovation and growth
  - Achieve operational agility with cloud-native scalability and global infrastructure
  - Modernize legacy applications while reducing technical debt and maintenance burden
- **Success Criteria**
  - Complete migration of production workloads within 6-9 months with zero data loss
  - Achieve 30-40% infrastructure cost reduction through right-sizing and optimization
  - Establish AWS landing zone foundation for future cloud-native development

---

### Engagement Scope
**layout:** eo_table

**Sizing Parameters for This Engagement**

This engagement is sized based on the following parameters:

<!-- BEGIN SCOPE_SIZING_TABLE -->
<!-- TABLE_CONFIG: widths=[18, 29, 5, 18, 30] -->
| Parameter | Scope | | Parameter | Scope |
|-----------|-------|---|-----------|-------|
| **Workloads to Migrate** | 5-10 VMs/applications | | **Availability Requirements** | Standard (99.5%) |
| **Migration Strategy** | Rehost (lift-and-shift) | | **Infrastructure Complexity** | EC2 RDS S3 standard |
| **Source Environment** | VMware vSphere on-premises | | **Security Requirements** | VPC Security Groups IAM |
| **Hybrid Connectivity** | AWS Direct Connect | | **Compliance Frameworks** | SOC2 |
| **Total Users** | 100 application users | | **Migration Window** | Weekend maintenance windows |
| **User Roles** | 3 roles (admin operator user) | | **Performance Requirements** | Match on-premises baseline |
| **Total Data to Migrate** | 500 GB | | **Deployment Environments** | 2 environments (dev prod) |
| **Database Migration** | 2 databases (MySQL PostgreSQL) | |  |  |
| **Target AWS Region** | us-east-1 | |  |  |
<!-- END SCOPE_SIZING_TABLE -->

*Note: Changes to these parameters may require scope adjustment and additional investment.*

---

### Solution Overview
**layout:** eo_visual_content

**Comprehensive Migration Journey to AWS**

![Architecture Diagram](assets/diagrams/architecture-diagram.png)

- **Migration Approach**
  - Discovery with Application Discovery Service maps dependencies and complexity
  - Migration tools: DMS for databases, SMS for servers, DataSync for data transfer
  - Migration Hub provides centralized tracking across all migration waves
- **AWS Landing Zone**
  - Multi-account structure with Control Tower and Organizations for governance
  - Production infrastructure: Auto Scaling EC2, RDS, S3, CloudFront, VPC networking
  - Site-to-Site VPN enables secure hybrid connectivity during phased migration

---

### Implementation Approach
**layout:** eo_single_column

**Proven AWS Migration Methodology**

- **Phase 1: Discovery & Assessment (Months 1-2)**
  - Application discovery and dependency mapping with AWS tools
  - Migration readiness assessment and wave planning (lift-shift vs replatform)
  - AWS landing zone design and account structure setup
- **Phase 2: Migration Execution (Months 3-6)**
  - Wave 1: Non-critical applications for validation and learning
  - Wave 2: Business-critical applications with tested migration patterns
  - Wave 3: Complex/legacy applications requiring refactoring
- **Phase 3: Optimization (Months 7-9)**
  - Right-sizing based on CloudWatch metrics and usage patterns
  - Cost optimization through Reserved Instances and Savings Plans
  - Security hardening and compliance validation

**SPEAKER NOTES:**

*Risk Mitigation:*
- Discovery phase identifies dependencies before migration starts
- Wave approach allows validation and learning with lower-risk apps first
- Hybrid connectivity maintains business continuity during migration

*Success Factors:*
- Application owners engaged for validation and cutover approval
- Maintenance windows available for migration activities
- Executive sponsorship for organizational change management

*Talking Points:*
- Start with discovery - you can't migrate what you don't understand
- Wave approach de-risks migration with incremental validation
- Optimization in Phase 3 delivers cost savings post-migration

---

### Timeline & Milestones
**layout:** eo_table

**Path to Cloud Migration**

<!-- TABLE_CONFIG: widths=[10, 25, 15, 50] -->
| Phase No | Phase Description | Timeline | Key Deliverables |
|----------|-------------------|----------|-----------------|
| Phase 1 | Discovery & Assessment | Months 1-2 | Application inventory completed, Migration waves defined, AWS landing zone operational |
| Phase 2 | Migration Execution | Months 3-6 | Wave 1-3 migrated to AWS, Applications validated in cloud, Hybrid connectivity established |
| Phase 3 | Optimization & Closure | Months 7-9 | Infrastructure right-sized, Costs optimized, On-premises decommissioned |

**SPEAKER NOTES:**

*Quick Wins:*
- AWS landing zone operational by Month 2
- First applications running in cloud by Month 3
- Cost savings visible from decommissioned hardware by Month 7

*Talking Points:*
- Discovery in Months 1-2 ensures accurate migration planning
- Migration Waves 1-3 deliver incremental progress with validation
- Optimization post-migration maximizes cloud economics

---

### Success Stories
**layout:** eo_single_column

**Proven Cloud Migration Results**

- **Client Success: Global Manufacturing Company**
  - **Client:** Mid-market manufacturer with 5,000 employees across 12 global facilities
  - **Challenge:** Aging data centers requiring $3M upgrade, 72-hour lead time for new environments
  - **Solution:** AWS migration of 150 servers, 20 databases, and 50TB data using DMS/SMS/DataSync
  - **Results:** 42% cost reduction ($1.8M annual savings), 95% faster provisioning, zero downtime, DC terminated
  - **Testimonial:** "The migration delivered beyond cost savings - we've fundamentally changed how we operate. New capabilities that took months now take hours, enabling business agility we never had before." — **Jennifer Wu, CIO**, GlobalManufacture Corp

---

### Our Partnership Advantage
**layout:** eo_two_column

**Why Partner with Us for AWS Migration**

- **What We Bring**
  - 12+ years delivering AWS migrations with 100% success rate
  - 150+ successful migrations totaling 10,000+ servers to AWS
  - AWS Migration Competency and Premier Consulting Partner status
  - Pre-built migration accelerators and automation tools
- **Value to You**
  - Proven migration methodology reduces risk and accelerates timeline
  - AWS Migration credits (10-25% of spend) offset migration costs
  - Direct AWS TAM support and best practices from 150+ migrations
  - Comprehensive training for cloud operations team

---

### Investment Summary
**layout:** eo_table

**Total Investment & Value with AWS MAP Program Credits**

<!-- BEGIN COST_SUMMARY_TABLE -->
<!-- TABLE_CONFIG: widths=[25, 15, 15, 15, 12, 12, 15] -->
| Cost Category | Year 1 List | Year 1 Credits | Year 1 Net | Year 2 | Year 3 | 3-Year Total |
|---------------|-------------|----------------|------------|--------|--------|--------------|
| Professional Services | $0 | $0 | $0 | $0 | $0 | $0 |
| Cloud Services | $10,572 | ($3,317) | $7,255 | $10,472 | $10,472 | $28,199 |
| Software Licenses | $3,132 | $0 | $3,132 | $3,132 | $3,132 | $9,396 |
| Support & Maintenance | $1,462 | $0 | $1,462 | $1,462 | $1,462 | $4,386 |
| **TOTAL** | **$15,166** | **($3,317)** | **$11,849** | **$15,066** | **$15,066** | **$41,981** |
<!-- END COST_SUMMARY_TABLE -->

**AWS MAP Program Credits Breakdown (Year 1 Only):**
- **AWS MAP Assessment Credit:** $12,000 (100% funding for migration discovery and planning)
- **AWS MAP Mobilize/Migrate Credit:** $10,000 (partial funding for migration execution)
- **AWS MAP Consumption Credit:** $8,117 (35% of Year 1 cloud infrastructure ARR)
- **Total Credits Applied:** $30,117

**Net Client Investment:**
- **Year 1:** $109,199 (after $30,117 in MAP program credits)
- **3-Year Total:** $137,331 (vs. $167,448 list price)
- **You Save:** $30,117 (22% discount through AWS MAP program)
<!-- END COST_SUMMARY_TABLE -->

**Small Scope Migration Specifications:**
- **Workloads:** 15-25 VMs/applications migrated to AWS
- **Migration Strategy:** Lift-and-shift (rehost) - not refactoring
- **Infrastructure:** 3x t3.large EC2, db.t3.large RDS Multi-AZ, 1TB storage, single region
- **Timeline:** 4-6 months from assessment to cutover

**Annual Operating Costs (Years 2-3):** $14,066/year
- Cloud Infrastructure: $9,472/year (EC2, RDS, storage, networking)
- Software Licenses: $3,132/year (Datadog, PagerDuty)
- Support & Maintenance: $1,462/year (ongoing optimization)

**Total 3-Year TCO:** $137,331

**Cost Comparison (Small Scope):**
- On-Premises 3-Year Cost: $420K (25 VMs × $5.6K/year + maintenance)
- AWS 3-Year TCO: $137K (after MAP credits)
- **Net Savings: $283K over 3 years** (67% reduction in infrastructure costs)

**Professional Services Breakdown (548 hours):**
- Assessment & Planning (140 hours): Discovery, migration strategy, AWS landing zone
- Migration Execution (330 hours): App migration, DB migration, security, testing, cutover
- Training & Support (78 hours): Knowledge transfer, documentation, 60-day hypercare

Detailed infrastructure costs including AWS consumption, cloud services, and support is provided in infrastructure-costs.xlsx.

**SPEAKER NOTES:**

*Value Positioning:*
- Total 3-year investment of $145,131 delivers 67% cost reduction vs. on-premises infrastructure
- Year 1 net cost of $114,999 after AWS MAP credits eliminates ongoing data center costs
- Ongoing costs only $15,066/year provide enterprise cloud infrastructure and support
- Investment delivers cost savings, agility, innovation capability, and business transformation

*Credit Program Talking Points:*
- AWS MAP Assessment Credit ($12,000) covers 100% of migration discovery and planning
- AWS MAP Mobilize/Migrate Credit ($10,000) partially funds migration execution
- AWS MAP Consumption Credit ($8,117) offsets 35% of Year 1 cloud infrastructure costs
- Total $30,117 in credits represent 22% discount on Year 1 investment
- Credits available through AWS Migration Acceleration Program for qualified migrations

*Value Positioning (Small Scope):*
- This is a **department-level migration** of 15-25 workloads using lift-and-shift strategy
- Small scope = proven approach before scaling to enterprise migration
- Year 1 net investment of $109K (after $30K MAP credits) eliminates ongoing data center costs
- 67% cost reduction vs. keeping workloads on-premises
- Highlight Year 1 includes full migration (one-time)
- Ongoing costs (Years 2-3) significantly lower than data center operations
- Net savings of $283K over 3 years demonstrates clear ROI

*AWS MAP Program Credits Strategy:*
- **Assessment Credit:** $12K covers 100% of migration discovery and planning
- **Mobilize/Migrate Credit:** $10K partial funding for migration execution
- **Consumption Credit:** $8.1K (35% of Year 1 cloud spend)
- Total $30K in credits reduces Year 1 by 22%
- Frame as AWS partnership investment in client's cloud journey
- MAP credits are non-dilutive - don't impact AWS pricing post-Year 1

*Cost Breakdown Strategy:*
- Professional services net cost $103K after MAP credits (from $125K list)
- Cloud costs Year 1 net $1.4K after consumption credit (from $9.6K list)
- AWS MAP program makes migration investment significantly more affordable
- No hidden costs - transparent pricing model

*Handling Objections:*
- "Can we migrate ourselves?" - Highlight MAP credits require partner engagement
- "Why professional services?" - Show proven methodology + $22K MAP funding
- "What if migration fails?" - Point to wave approach and AWS TAM support
- "How do we control cloud costs?" - Explain optimization in Phase 3 and FinOps
- "Do credits expire?" - MAP credits are one-time Year 1, must be utilized during migration

*Talking Points:*
- MAP program reduces Year 1 net investment to $109K (from $139K list)
- Compare $137K 3-year TCO to $420K on-prem equivalent
- Migration pays for itself through hardware/facility cost elimination
- AWS MAP partnership de-risks migration and accelerates timeline
- $30K in credits demonstrates AWS commitment to successful migration

---

### Next Steps
**layout:** eo_bullet_points

**Your Path Forward**

- **Decision:** Executive approval for discovery and migration planning by [specific date]
- **Kickoff:** Discovery phase start date [30 days from approval]
- **Team Formation:** Application owners, infrastructure team, migration project manager
- **AWS Setup:** Account creation, landing zone provisioning, and network connectivity
- **Discovery Tools:** Deploy AWS Application Discovery Service for workload assessment

**SPEAKER NOTES:**

*Transition from Investment:*
- "Now that we've covered the investment and demonstrated cost savings, let's discuss getting started"
- Emphasize discovery validates business case before full migration commitment
- Show clear path from decision to first workloads in cloud

*Walking Through Next Steps:*
- Discovery phase identifies all applications and dependencies
- Assessment reveals actual migration effort (not estimates)
- Wave planning allows phased approach with validation points
- AWS landing zone provides secure foundation from day one

*Talking Points:*
- Discovery can start within 2 weeks of approval
- You'll have complete application inventory by Month 2
- First applications migrated to AWS by Month 3
- Validate approach with Wave 1 before committing to Wave 2-3
- Data center decommissioning delivers cost savings by Month 9

*Call to Action:*
- Get executive approval for migration discovery and planning
- Schedule kickoff meeting with application owners and infrastructure team
- Begin AWS account setup and landing zone provisioning
- Deploy AWS Application Discovery Service for workload assessment

---

### Thank You
**layout:** eo_thank_you


- **Your Account Manager:** [Name, Title] | [Email] | [Phone]

**SPEAKER NOTES:**

*Closing Strong:*
- Thank them for considering cloud transformation
- Reiterate commitment to successful migration with zero business disruption
- Emphasize partnership throughout journey and post-migration optimization
- Offer to provide AWS reference architectures or customer site visits
- Confirm next steps and decision timeline

*Call to Action:*
- Schedule discovery kickoff workshop
- Identify application stakeholders for interviews
- Review and approve migration timeline
- Set date for executive decision and project start
- Request preliminary application inventory if available
