# Template Review Process

This document outlines the review process for all template submissions.

## Review Stages

### 1. Automated Validation (Required)
**Automated checks performed on every PR:**
- File structure validation
- Metadata schema compliance
- License header verification
- Security scanning (no secrets)
- File format verification
- Size limit compliance

**Failure handling:**
- PR blocked until issues resolved
- Automated feedback provided
- Re-validation on updates

### 2. Provider Review (Required)
**Performed by provider team members:**
- Technical accuracy validation
- Provider best practices compliance
- Solution completeness assessment
- Script functionality verification
- Documentation quality review

**Review criteria:**
- Solution follows provider guidelines
- All required components present
- Scripts tested and functional
- Documentation complete and accurate

### 3. Category Review (Required)
**Performed by category subject matter experts:**
- Cross-provider consistency
- Category standards compliance
- Business value assessment
- Template reusability evaluation
- Knowledge transfer quality

**Review criteria:**
- Consistent with other category solutions
- Meets business requirements
- Provides clear value proposition
- Includes comprehensive materials

### 4. Core Team Approval (Required)
**Final review by EO Framework™ maintainers:**
- Framework alignment assessment
- Community impact evaluation
- Strategic fit analysis
- Final quality assurance
- Publication approval

**Review criteria:**
- Aligns with EO Framework™ principles
- Adds value to community
- Meets quality standards
- Ready for production use

## Review Timeline

### Standard Timeline
- **Automated validation:** Immediate
- **Provider review:** 3-5 business days
- **Category review:** 3-5 business days  
- **Core team approval:** 2-3 business days
- **Total estimated time:** 8-13 business days

### Expedited Review
Available for:
- Critical security updates
- Bug fixes for active templates
- High-priority business requirements

### Extended Review
May be required for:
- Complex enterprise solutions
- New provider integrations
- Significant template updates
- Compliance-sensitive content

## Review Assignments

### Automatic Assignment
- Provider teams auto-assigned via CODEOWNERS
- Category teams auto-assigned via CODEOWNERS
- Core team always assigned

### Manual Assignment
- For cross-cutting concerns
- When expertise needed outside normal teams
- For escalated reviews
- For complex technical solutions

## Review Feedback

### Feedback Categories
- **Blocking:** Must be addressed before approval
- **Non-blocking:** Suggestions for improvement
- **Enhancement:** Future improvement opportunities
- **Question:** Clarification requests

### Response Requirements
- Address all blocking feedback
- Respond to all questions
- Consider non-blocking suggestions
- Update documentation as needed

## Approval Criteria

### Must Have
- All automated checks pass
- All blocking feedback addressed
- Required approvals received
- Documentation complete
- Scripts tested and functional

### Nice to Have
- Performance optimizations
- Enhanced error handling
- Additional examples
- Advanced features
- Integration capabilities

## Post-Approval Process

### Merge Requirements
- All approvals received
- CI/CD pipeline successful
- Final validation complete
- Branch up to date with main

### Post-Merge Actions
- Catalog automatically updated
- Website sync triggered
- Community notification sent
- Metrics updated
- Documentation published

## Review Quality Standards

### Reviewer Responsibilities
- Thorough technical review
- Constructive feedback
- Timely responses
- Knowledge sharing
- Continuous improvement

### Review Metrics
- Review completion time
- Feedback quality scores
- Template success rates
- Community satisfaction
- Usage analytics

## Escalation Process

### When to Escalate
- Disagreement between reviewers
- Extended review delays
- Technical complexity issues
- Business priority conflicts
- Resource constraints

### Escalation Path
1. **Team Lead:** Initial escalation
2. **Category Lead:** Cross-team issues
3. **Core Maintainer:** Strategic decisions
4. **Steering Committee:** Final authority

## Appeals Process

### Appeal Grounds
- Process not followed correctly
- Technical disagreement
- Business case misunderstood
- Reviewer bias concerns
- Timeline issues

### Appeal Procedure
1. Submit appeal with detailed reasoning
2. Review by different team members
3. Technical committee evaluation
4. Final decision with documentation
5. Process improvement recommendations