# GitHub Advanced Security - Architecture Diagrams

## Diagram Instructions

### Overview
This directory contains architecture diagrams for the GitHub Advanced Security solution, showing the security scanning workflow and integration points.

### Required Diagrams

#### 1. architecture-diagram.drawio
**Purpose:** Primary architecture diagram showing GitHub Advanced Security components and workflow

**Components to Include:**

**Developer Workflow (Left Side):**
- Developer workstation with code editor
- Git commit and push to GitHub
- Pull request creation

**GitHub Platform (Center):**
- GitHub Enterprise Cloud logo/header
- Repository with branches (main, feature branches)
- Pull Request interface

**Security Scanning Layer (Center-Right):**
- **Code Scanning Box:**
  - CodeQL analysis engine
  - 300+ CWE patterns
  - SQL injection, XSS, CSRF detection
  - Custom query execution
- **Secret Scanning Box:**
  - Partner pattern matching
  - Custom pattern matching
  - Push protection shield
- **Dependency Scanning Box:**
  - Dependabot alerts
  - CVE database
  - Auto-update PRs

**CI/CD Integration (Right Side):**
- GitHub Actions workflow
- Build and test pipeline
- Security status checks
- Merge protection gates

**Security Operations (Bottom):**
- Security dashboard
- Alert triage interface
- SIEM integration (Splunk/Azure Sentinel)
- Vulnerability tracking (JIRA/ServiceNow)

**Data Flow Arrows:**
1. Developer commits code → GitHub repository
2. Pull request triggers → Code scanning + Secret scanning + Dependency scanning
3. Security findings → Pull request checks (pass/fail)
4. Alerts → Security dashboard + SIEM
5. Critical findings → Block merge (red X)
6. Passed checks → Allow merge (green checkmark)

**Color Scheme:**
- GitHub colors: Black (#24292e) for headers, Purple (#6f42c1) for actions
- Security: Red (#d73a49) for vulnerabilities, Orange (#fb8532) for warnings
- Success: Green (#28a745) for passed checks
- Info: Blue (#0366d6) for informational items

**Labels and Annotations:**
- "Shift-Left Security" badge
- "DevSecOps" label
- "Automated SAST/SCA" annotation
- "90% Detection Rate" metric callout
- "Zero Secret Leaks" badge

**Security Policy Enforcement (Callout Box):**
- Branch protection rules
- Required status checks
- Required reviewers for security findings
- Merge blocking on critical vulnerabilities

#### 2. security-workflow.drawio (Optional - if time permits)
**Purpose:** Detailed security workflow from commit to remediation

**Workflow Steps:**
1. Developer commits code with potential vulnerability
2. CodeQL scanning triggered automatically
3. Vulnerability detected (e.g., SQL injection)
4. Alert appears in pull request
5. Developer reviews finding and fix recommendation
6. Developer applies fix
7. Re-scan shows vulnerability resolved
8. Security check passes, merge allowed

### Diagram Creation Instructions

**Using draw.io:**
1. Open https://app.diagrams.net/
2. Create new diagram named `architecture-diagram.drawio`
3. Use AWS Architecture icons or GitHub-themed shapes
4. Follow the component layout described above
5. Use consistent colors per the color scheme
6. Add clear labels and data flow arrows
7. Save as `architecture-diagram.drawio` in this directory
8. Export as `architecture-diagram.png` (300 DPI, transparent background)

**Style Guidelines:**
- Use rounded rectangles for services/components
- Use cylinders for data stores
- Use arrows with labels for data flow
- Use dashed lines for optional/conditional flows
- Use different colors to distinguish component types
- Include GitHub logo and GitHub Advanced Security branding
- Keep text readable (minimum 12pt font)
- Maintain consistent spacing and alignment

**Technical Accuracy:**
- Show CodeQL as semantic analysis (not simple regex)
- Differentiate between code scanning, secret scanning, and dependency scanning
- Show GitHub Actions as the CI/CD orchestrator
- Include branch protection and merge protection mechanisms
- Display integration points for external systems (SIEM, issue tracking)

**Reference Examples:**
- AWS IDP architecture diagrams in `/solutions/aws/ai/intelligent-document-processing/assets/diagrams/`
- GitHub documentation: https://docs.github.com/en/code-security/code-scanning/introduction-to-code-scanning/about-code-scanning
- GitHub Advanced Security overview: https://docs.github.com/en/enterprise-cloud@latest/get-started/learning-about-github/about-github-advanced-security

### Files in This Directory

After creation, this directory should contain:
- `README.md` (this file)
- `architecture-diagram.drawio` - Editable draw.io source
- `architecture-diagram.png` - Exported PNG for documentation
- `security-workflow.drawio` (optional) - Detailed workflow diagram
- `security-workflow.png` (optional) - Exported PNG

### Usage in Documentation

The architecture diagram is referenced in:
- `presales/raw/solution-briefing.md` - Slide 4 (Solution Overview)
- `presales/README.md` - Solution overview section
- `README.md` - Main solution documentation

**Markdown Reference:**
```markdown
![Architecture Diagram](assets/diagrams/architecture-diagram.png)
```

**Relative Path from presales/raw/:**
```markdown
![Architecture Diagram](../../assets/diagrams/architecture-diagram.png)
```

---

**Last Updated:** 2025-11-22
**Solution:** GitHub Advanced Security
**Status:** Architecture diagrams pending creation
