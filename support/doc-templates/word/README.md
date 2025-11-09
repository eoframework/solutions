# Word Document Templates

This directory contains branded Word document templates for the EO Framework™.

## Template Files

### **EOFramework-Word-Template-01.docx**

Professional Word document template with branded cover page, table of contents, and footer.

**Structure:**

```
Page 1: Cover Page
├── Consulting Company Logo (top left)
├── Document Title (placeholder)
├── Document Subtitle (placeholder)
└── Metadata
    ├── Generated: [Date]
    ├── Solution: [Solution Name]
    └── Version: 1.0

Page 2: Table of Contents
├── TOC Title
└── TOC Entries (generated from headings)

Page 3+: Document Content
└── Content from Markdown files

Footer (All Pages):
├── Page Number (center)
└── EO Framework Logo (right)
```

**Features:**
- **Branded Cover Page**: Consulting company logo, professional title and subtitle styling
- **Dynamic Table of Contents**: Auto-generated from document headings
- **Professional Footer**: Page numbers (center) + EO Framework logo (right)
- **Consistent Styling**: Calibri font, professional color scheme
- **Metadata Section**: Date, solution name, version tracking

## Usage in Generation

The template is used by `support/tools/generate-outputs.py` when converting Markdown to Word:

```python
# Load template
template_path = 'support/doc-templates/word/EOFramework-Word-Template-01.docx'
doc = Document(template_path)

# Update cover page with document title and metadata
_update_word_cover(doc, md_file, md_content)

# Generate table of contents from headings
_generate_word_toc(doc, tokens)

# Add content from Markdown
_process_md_tokens(doc, tokens, md_content)
```

## Template Customization

To customize the Word template:

1. **Update Cover Page**:
   - Edit title/subtitle styling in `create-word-template.py`
   - Modify colors (RGB values)
   - Adjust spacing and layout

2. **Modify Footer**:
   - Change page number format
   - Adjust logo size and position
   - Update font styling

3. **Regenerate Template**:
   ```bash
   python3 support/tools/create-word-template.py
   ```

4. **Test with Sample Documents**:
   ```bash
   python3 support/tools/generate-outputs.py --path solution-template
   ```

## Logo Assets

Logos are loaded from: `support/doc-templates/assets/logos/`

- **consulting_company_logo.png**: Cover page (left aligned)
- **eo-framework-logo-real.png**: Footer (right aligned)

To update logos, replace the PNG files in the assets directory and regenerate the template.

## Color Scheme

- **Primary Blue**: #1F4E78 (Title, H1 headings)
- **Secondary Blue**: #44546A (Subtitle, H2 headings, metadata)
- **Gray**: #808080 (H3+ headings, TOC)

## Font Specifications

- **Font Family**: Calibri
- **Title**: 28pt, Bold
- **Subtitle**: 16pt, Regular
- **Headings**:
  - H1: Built-in Heading 1 style
  - H2: Built-in Heading 2 style
  - H3+: Built-in styles
- **Body Text**: 11pt, Regular
- **Footer**: 10pt, Gray

## Page Setup

- **Margins**: Default Word margins (1" all sides)
- **Page Size**: Letter (8.5" x 11")
- **Orientation**: Portrait
- **Footer**: Appears on all pages

## Updating the Template

When making changes to the template:

1. Update `create-word-template.py` with your changes
2. Run the script to regenerate the template
3. Test with sample documents to verify
4. Update this README if structure changes
5. Commit both the script and generated template

## Generated Document Examples

See `solution-template/sample-provider/sample-category/sample-solution/` for examples:

- **Presales**:
  - `business-case.docx`
  - `statement-of-work.docx`

- **Delivery**:
  - `detailed-design.docx`
  - `implementation-guide.docx`

Each document includes:
- ✅ Branded cover page with metadata
- ✅ Table of contents
- ✅ Professional content formatting
- ✅ Page numbers and EO Framework logo in footer
