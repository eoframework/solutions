# Delivery Documentation

Implementation materials for the **Sample Solution**.

## Documents

| File | Output | Purpose |
|------|--------|---------|
| [project-plan.csv](raw/project-plan.csv) | .xlsx | Timeline, milestones, RACI matrix, communications |
| [detailed-design.md](raw/detailed-design.md) | .docx | Technical architecture and component design |
| [implementation-guide.md](raw/implementation-guide.md) | .docx | Step-by-step deployment procedures with training |
| [configuration.csv](raw/configuration.csv) | .xlsx | Environment configuration parameters |
| [test-plan.csv](raw/test-plan.csv) | .xlsx | Functional, non-functional, and UAT test cases |
| [closeout-presentation.md](raw/closeout-presentation.md) | .pptx | Project closeout presentation slides |

## Quick Start

**For Project Managers**
1. Start with `project-plan.csv` for timeline and RACI
2. Review communications plan section for stakeholder meetings

**For Technical Leads**
1. Read `detailed-design.md` for architecture understanding
2. Follow `implementation-guide.md` for deployment steps
3. Configure using `configuration.csv` parameters

**For QA Teams**
1. Execute tests from `test-plan.csv`
2. Track results in Status and Pass/Fail columns

## Structure

```
delivery/
├── raw/                    # Source files (CSV, Markdown)
│   ├── project-plan.csv    # Timeline + Milestones + RACI + Comms
│   ├── detailed-design.md  # Technical design document
│   ├── implementation-guide.md  # Deployment procedures + Training
│   ├── configuration.csv   # Configuration parameters
│   ├── test-plan.csv       # Test cases (3 sections)
│   └── closeout-presentation.md  # Closeout slides
├── scripts/                # Automation tools
│   └── terraform/          # Infrastructure as Code
└── README.md               # This file
```

## Conversion

Convert raw files to Office formats:

```bash
# From eof-tools/converters/delivery/scripts
python solution-delivery-converter.py /path/to/solution
```

## Related

- [Presales Documentation](../presales/) - SOW, briefing, costs
- [Assets](../assets/) - Logos and diagrams
