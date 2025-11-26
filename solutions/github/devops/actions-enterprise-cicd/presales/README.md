# Presales Resources

This folder contains all presales materials for customer engagement and business case development.

## Documents

### Source Files (`raw/`)

| File | Purpose | Output |
|------|---------|--------|
| `solution-briefing.md` | Executive presentation content | `solution-briefing.pptx` |
| `statement-of-work.md` | Project scope and terms | `statement-of-work.docx` |
| `discovery-questionnaire.csv` | Requirements gathering | `discovery-questionnaire.xlsx` |
| `level-of-effort-estimate.csv` | Resource and cost estimation | `level-of-effort-estimate.xlsx` |
| `infrastructure-costs.csv` | 3-year infrastructure costs | `infrastructure-costs.xlsx` |

### Generated Files

The `.pptx`, `.docx`, and `.xlsx` files are generated from source files using [eof-tools](https://github.com/eoframework/eof-tools). To regenerate:

```bash
cd /path/to/eof-tools
python3 converters/presales/solution-presales-converter.py \
  --solution-path /path/to/this/solution
```

## How to Use

### For Discovery

1. Start with `discovery-questionnaire.xlsx` to gather customer requirements
2. Review responses to understand scope and constraints
3. Use findings to customize other documents

### For Business Case

1. Review `solution-briefing.pptx` for executive presentation
2. Customize slides with customer-specific information
3. Use `infrastructure-costs.xlsx` for financial discussions

### For Proposal

1. Customize `statement-of-work.docx` with customer details
2. Update pricing in `level-of-effort-estimate.xlsx`
3. Include `infrastructure-costs.xlsx` for total cost of ownership

## Customization

All source files in `raw/` can be edited:
- **Markdown files** - Edit in any text editor
- **CSV files** - Edit in Excel or text editor
- Regenerate outputs after making changes

---

**[EO Framework](https://eoframework.org)** - Exceptional Outcome Framework
