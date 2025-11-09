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
├── assets/
│   ├── logos/                                # Common logo assets
│   │   ├── client_logo.png                   # Client branding
│   │   ├── consulting_company_logo.png       # Consulting company branding
│   │   └── eo-framework-logo-real.png        # EO Framework logo
│   └── README.md                             # Asset documentation
├── powerpoint/
│   ├── EOFramework-Template-01.pptx          # Master presentation template
│   └── README.md                             # PowerPoint template docs
├── word/
│   ├── EOFramework-Word-Template-01.docx     # Master Word template
│   └── README.md                             # Word template docs
└── excel/
    ├── EOFramework-Excel-Template-01.xlsx    # Master Excel template
    └── README.md                             # Excel template docs (pending)
```

## PowerPoint Templates

### EOFramework-Template-01.pptx

Professional presentation template with 7 custom layouts including title slide, content slides, and two-column layouts.

**Features:**
- Format: 16:9 widescreen (10" x 7.5")
- Professional EO Framework branding
- Logo placeholders for client and consulting company
- Calibri font family
- Auto-layout selection from Markdown

**See:** [powerpoint/README.md](powerpoint/README.md) for detailed documentation.

## Word Templates

### EOFramework-Word-Template-01.docx

Professional Word document template with branded cover page, table of contents, and footer.

**Structure:**
- **Page 1**: Cover page with consulting company logo, title, subtitle, metadata
- **Page 2**: Table of contents (auto-generated from headings)
- **Page 3+**: Document content from Markdown
- **Footer**: Page numbers (center) + EO Framework logo (right)

**Features:**
- Calibri font, professional color scheme
- Dynamic TOC generation
- Branded footer on all pages
- Metadata tracking (date, solution, version)

**See:** [word/README.md](word/README.md) for detailed documentation.

## Excel Templates

### EOFramework-Excel-Template-01.xlsx

Professional Excel template with branded cover sheet and styled data presentation.

**Structure:**
- **Cover Sheet**: 3 logos (client, consulting company, EO Framework), metadata fields
- **Data Sheet**: Professional styling with gray header, alternating rows

**Features:**
- Gray header (#808080), 12pt font
- Alternating row colors for readability
- Auto-filter, freeze panes
- Currency formatting with numeric values
- Dynamic sheet naming based on file type
- Auto-adjusted column widths

**See:** Excel template documentation (pending) for detailed information.

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
- ✅ ~~Word document templates for reports and guides~~ **COMPLETED**
- ✅ ~~Excel templates for calculators and data sheets~~ **COMPLETED**
- Additional PowerPoint layouts for specialized content
- Template versioning and changelog
- Multi-language template variants
- Advanced Excel features (charts, pivot tables)
- Word styles library for consistent formatting

## Support

- **Issues**: Report template issues via [GitHub Issues](https://github.com/eoframework/solutions/issues)
- **Documentation**: See `support/docs/` for standards and guidelines
- **Script Documentation**: See `support/tools/generate-outputs.py` for generation details
