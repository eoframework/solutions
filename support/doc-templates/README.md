# Document Templates

Professional templates used by the `generate-outputs.py` script to create high-quality deliverables from raw source files.

## Overview

This directory contains master templates for generating professional outputs:

- **PowerPoint** - Presentation templates with EO Framework branding and layouts
- **Word** - Document templates for professional reports and guides
- **Excel** - Spreadsheet templates for structured data presentation

## Template Structure

```
doc-templates/
├── powerpoint/
│   ├── EOFramework-Template-3Logos.pptx    # Master presentation template
│   ├── README.md                            # PowerPoint template documentation
│   └── eo-framework-logo.png                # Example logo asset
├── word/
│   └── (Word templates - coming soon)
└── excel/
    └── (Excel templates - coming soon)
```

## PowerPoint Templates

### EOFramework-Template-3Logos.pptx

Professional presentation template with 4 custom layouts:

| Layout | Placeholders | Use Case |
|--------|--------------|----------|
| **EO Title Slide** | Title, Subtitle, 3 Logos | Opening slides, section covers |
| **EO Title and Content** | Title, Content | Standard content slides with bullets |
| **EO Two Content** | Title, 2 Content columns | Comparison slides, side-by-side content |
| **EO Section Header** | Title, Text | Section transitions, chapter breaks |

**Specifications:**
- Format: 16:9 widescreen (10" x 7.5")
- Color scheme: Professional EO Framework branding
- Fonts: Calibri family for consistency
- Logo placeholders: Three customizable positions

**See:** [powerpoint/README.md](powerpoint/README.md) for detailed documentation.

## Usage

Templates are automatically used by the generation script:

```bash
# Generate outputs using templates
python3 support/tools/generate-outputs.py --path solution-template/

# Generate for specific solution
python3 support/tools/generate-outputs.py --path solutions/aws/ai/intelligent-document-processing/
```

The script will:
1. Find raw source files (`.md`, `.csv`) in `raw/` directories
2. Apply appropriate templates based on file type
3. Generate professional outputs (`.pptx`, `.docx`, `.xlsx`)
4. Save outputs in the parent directory

## Template Customization

### For Contributors

Templates can be customized for specific branding needs:

1. **Copy the template** to preserve the original
2. **Edit in PowerPoint/Word/Excel** to modify branding, colors, fonts
3. **Test with generation script** to verify compatibility
4. **Update template path** in generate-outputs.py if using custom location

### Requirements

Templates must maintain:
- Compatible placeholder structure for script automation
- Professional quality and consistency
- Accessibility standards (contrast, alt text)
- File format compatibility (.pptx, .docx, .xlsx)

## Template Quality Standards

All templates must meet:
- **Professional Design** - Enterprise-grade visual quality
- **Brand Consistency** - Aligned with EO Framework standards
- **Script Compatible** - Works with automated generation
- **Accessibility** - WCAG 2.1 AA compliance
- **Format Standards** - Standard Office file formats

## Future Enhancements

Planned additions:
- Word document templates for reports and guides
- Excel templates for calculators and data sheets
- Additional PowerPoint layouts for specialized content
- Template versioning and changelog
- Multi-language template variants

## Support

- **Issues**: Report template issues via [GitHub Issues](https://github.com/eoframework/solutions/issues)
- **Documentation**: See `support/docs/` for standards and guidelines
- **Script Documentation**: See `support/tools/generate-outputs.py` for generation details
