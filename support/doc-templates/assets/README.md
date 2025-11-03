# Common Assets for Document Templates

This directory contains shared assets used across all document template types (Excel, PowerPoint, Word).

## Directory Structure

```
assets/
├── logos/                    # Logo files used in all templates
│   ├── client_logo.png      # Client logo (placeholder)
│   ├── consulting_company_logo.png  # Consulting company logo
│   └── eo-framework-logo-real.png   # EO Framework logo
└── README.md
```

## Logo Specifications

### client_logo.png
- **Size**: ~14KB
- **Usage**: Client branding across all generated documents
- **Dimensions**: Optimized for template placeholders
- **Description**: Generic client logo placeholder - should be replaced with actual client logo

### consulting_company_logo.png
- **Size**: ~20KB
- **Usage**: Consulting company branding
- **Dimensions**: Optimized for template placeholders
- **Description**: Consulting company brand identity

### eo-framework-logo-real.png
- **Size**: ~118KB
- **Format**: PNG (converted from WEBP for compatibility)
- **Usage**: EO Framework branding on cover pages
- **Dimensions**: High resolution for professional presentations

## Usage in Templates

### PowerPoint Templates
- Path: `support/doc-templates/powerpoint/`
- Logos inserted via `insert_picture()` on picture placeholders
- Code reference: `generate-outputs.py::_insert_logos()`

### Excel Templates
- Path: `support/doc-templates/excel/`
- Logos embedded in Cover sheet
- Code reference: `generate-outputs.py::convert_csv_to_xlsx()`

### Word Templates (Future)
- Path: `support/doc-templates/word/`
- Will use same logo assets

## Updating Logos

To update logo files:

1. Replace the PNG file in this directory
2. Ensure same filename is maintained
3. Recommended dimensions:
   - Client logo: 150-200px width
   - Consulting logo: 150-200px width
   - EO Framework logo: 200-300px width
4. Use PNG format for best compatibility
5. Regenerate templates if needed

## Adding New Assets

To add new shared assets:

1. Create subdirectory (e.g., `icons/`, `images/`)
2. Document specifications in this README
3. Update code references in `generate-outputs.py`
4. Test with all template types
