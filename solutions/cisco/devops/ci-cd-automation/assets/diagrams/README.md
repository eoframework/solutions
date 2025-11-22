# Cisco Network CI/CD Automation - Architecture Diagram

## 📊 **Create with Draw.io**

### Required Components

**Version Control & CI/CD:**
- GitLab Premium server (self-hosted)
- GitLab CI/CD Runners (2x VMs)
- Git repository structure (Ansible playbooks, Terraform modules)

**Automation Tools:**
- Ansible control node
- Ansible AWX (optional controller)
- Terraform engine
- Python scripts and validators

**Source of Truth:**
- NetBox IPAM server (device inventory, IPAM, DCIM)
- Dynamic inventory integration with Ansible

**Network Infrastructure:**
- 100 Cisco devices (IOS-XE, NX-OS, ASA)
- Switches, routers, firewalls (grouped by platform)
- Management network connectivity

**Secrets Management:**
- HashiCorp Vault (or GitLab Secrets)
- Credential storage and rotation

**Testing Environment:**
- GNS3 or Cisco CML lab (20-node topology)
- Pre-production validation network

**Integration Points:**
- ServiceNow ITSM (optional - change management automation)
- SIEM integration (optional - audit logging)

### Architecture Layout

**Left:** GitLab (version control, CI/CD pipelines, merge requests)
**Top-Center:** Automation engines (Ansible, Terraform, Python)
**Right:** NetBox IPAM (source of truth, dynamic inventory)
**Bottom:** Network devices (100 devices grouped by type)
**Bottom-Right:** Testing lab (GNS3/CML environment)

### Key Data Flows

1. **Git Workflow:**
   - Developer → Git commit → GitLab merge request
   - CI/CD pipeline → Syntax validation → Lab testing
   - Approval → Production deployment

2. **Automation Flow:**
   - Ansible playbook → NetBox dynamic inventory → Device configuration
   - Terraform → API calls → Network orchestration (ACI, Meraki, DCNM)

3. **Validation:**
   - Pre-commit hooks → Linting (ansible-lint, yamllint)
   - CI pipeline → Lab testing in GNS3/CML
   - Post-deployment → Configuration backup to Git

### Export Settings
- 300 DPI PNG
- Transparent background
- Save as: `architecture-diagram.png`

### Color Coding
- **Purple:** GitLab/CI-CD components
- **Blue:** Automation tools (Ansible, Terraform)
- **Green:** Network devices
- **Orange:** NetBox IPAM
- **Gray:** Secrets management and testing

---

## 🎯 **Key Architectural Principles**

- **GitOps:** All configurations version-controlled in Git
- **Infrastructure as Code:** Declarative network automation
- **CI/CD:** Automated testing before production
- **Source of Truth:** NetBox as single source for network data
- **Secrets Security:** Vault-managed credentials, no plaintext passwords

---

## 📚 **References**

- **GitLab CI/CD:** https://docs.gitlab.com/ee/ci/
- **Ansible Network Automation:** https://docs.ansible.com/ansible/latest/network/
- **NetBox:** https://netbox.readthedocs.io/
- **Cisco DevNet:** https://developer.cisco.com/
