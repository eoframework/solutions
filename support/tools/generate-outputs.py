#!/usr/bin/env python3
"""
Generate professional output files from raw source files.

Converts:
- Markdown (.md) → Word (.docx) or PowerPoint (.pptx)
- CSV (.csv) → Excel (.xlsx) with formatting

Usage:
    python3 generate-outputs.py --path solutions/provider/category/solution
    python3 generate-outputs.py --path solution-template/
"""

import argparse
import os
import sys
from pathlib import Path
import pandas as pd
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils.dataframe import dataframe_to_rows
from docx import Document
from docx.shared import Pt, RGBColor, Inches
from docx.enum.text import WD_ALIGN_PARAGRAPH
from pptx import Presentation
from pptx.util import Inches as PptxInches, Pt as PptxPt
from pptx.enum.text import PP_ALIGN
from markdown_it import MarkdownIt
import re


class OutputGenerator:
    """Generate professional output files from raw source files."""

    def __init__(self, base_path):
        self.base_path = Path(base_path)
        self.stats = {
            'csv_to_xlsx': 0,
            'md_to_docx': 0,
            'md_to_pptx': 0,
            'errors': []
        }

    def generate_all(self):
        """Generate all output files from raw directories."""
        print(f"🔍 Scanning: {self.base_path}")

        # Find all raw directories
        raw_dirs = list(self.base_path.rglob('raw'))

        if not raw_dirs:
            print("❌ No 'raw' directories found.")
            return False

        print(f"📁 Found {len(raw_dirs)} raw directories\n")

        for raw_dir in raw_dirs:
            self.process_raw_directory(raw_dir)

        self.print_summary()
        return len(self.stats['errors']) == 0

    def process_raw_directory(self, raw_dir):
        """Process all files in a raw directory."""
        output_dir = raw_dir.parent

        print(f"📂 Processing: {raw_dir.relative_to(self.base_path)}")

        # Process CSV files
        for csv_file in raw_dir.glob('*.csv'):
            self.convert_csv_to_xlsx(csv_file, output_dir)

        # Process Markdown files
        for md_file in raw_dir.glob('*.md'):
            if 'presentation' in md_file.stem.lower():
                self.convert_md_to_pptx(md_file, output_dir)
            else:
                self.convert_md_to_docx(md_file, output_dir)

        print()

    def convert_csv_to_xlsx(self, csv_file, output_dir):
        """Convert CSV to styled Excel file."""
        try:
            output_file = output_dir / f"{csv_file.stem}.xlsx"

            # Read CSV
            df = pd.read_csv(csv_file)

            # Create Excel file with styling
            wb = Workbook()
            ws = wb.active
            ws.title = "Data"

            # Write data
            for r_idx, row in enumerate(dataframe_to_rows(df, index=False, header=True), 1):
                for c_idx, value in enumerate(row, 1):
                    cell = ws.cell(row=r_idx, column=c_idx, value=value)

                    # Style header row
                    if r_idx == 1:
                        cell.font = Font(bold=True, color="FFFFFF", size=11)
                        cell.fill = PatternFill(start_color="4472C4", end_color="4472C4", fill_type="solid")
                        cell.alignment = Alignment(horizontal="center", vertical="center")
                    else:
                        cell.alignment = Alignment(vertical="top", wrap_text=True)

                    # Add borders
                    thin_border = Border(
                        left=Side(style='thin'),
                        right=Side(style='thin'),
                        top=Side(style='thin'),
                        bottom=Side(style='thin')
                    )
                    cell.border = thin_border

            # Auto-adjust column widths
            for column in ws.columns:
                max_length = 0
                column_letter = column[0].column_letter
                for cell in column:
                    try:
                        if cell.value:
                            max_length = max(max_length, len(str(cell.value)))
                    except:
                        pass
                adjusted_width = min(max_length + 2, 50)
                ws.column_dimensions[column_letter].width = adjusted_width

            # Freeze header row
            ws.freeze_panes = ws['A2']

            wb.save(output_file)
            print(f"  ✅ {csv_file.name} → {output_file.name}")
            self.stats['csv_to_xlsx'] += 1

        except Exception as e:
            error_msg = f"Error converting {csv_file.name}: {str(e)}"
            print(f"  ❌ {error_msg}")
            self.stats['errors'].append(error_msg)

    def convert_md_to_docx(self, md_file, output_dir):
        """Convert Markdown to styled Word document."""
        try:
            output_file = output_dir / f"{md_file.stem}.docx"

            # Read markdown
            with open(md_file, 'r', encoding='utf-8') as f:
                md_content = f.read()

            # Parse markdown
            md = MarkdownIt()
            tokens = md.parse(md_content)

            # Create Word document
            doc = Document()

            # Process tokens
            self._process_md_tokens(doc, tokens, md_content)

            doc.save(output_file)
            print(f"  ✅ {md_file.name} → {output_file.name}")
            self.stats['md_to_docx'] += 1

        except Exception as e:
            error_msg = f"Error converting {md_file.name}: {str(e)}"
            print(f"  ❌ {error_msg}")
            self.stats['errors'].append(error_msg)

    def _process_md_tokens(self, doc, tokens, md_content):
        """Process markdown tokens and add to Word document."""
        i = 0
        while i < len(tokens):
            token = tokens[i]

            if token.type == 'heading_open':
                level = int(token.tag[1])  # h1 -> 1, h2 -> 2, etc.
                i += 1
                if i < len(tokens) and tokens[i].type == 'inline':
                    text = tokens[i].content
                    doc.add_heading(text, level=level)
                i += 1  # Skip heading_close

            elif token.type == 'paragraph_open':
                i += 1
                if i < len(tokens) and tokens[i].type == 'inline':
                    text = tokens[i].content
                    # Simple text formatting
                    text = re.sub(r'\*\*(.+?)\*\*', r'\1', text)  # Remove bold markers
                    text = re.sub(r'\*(.+?)\*', r'\1', text)      # Remove italic markers
                    if text.strip():
                        doc.add_paragraph(text)
                i += 1  # Skip paragraph_close

            elif token.type == 'bullet_list_open':
                i += 1
                while i < len(tokens) and tokens[i].type != 'bullet_list_close':
                    if tokens[i].type == 'list_item_open':
                        i += 1
                        if i < len(tokens) and tokens[i].type == 'paragraph_open':
                            i += 1
                            if i < len(tokens) and tokens[i].type == 'inline':
                                text = tokens[i].content
                                text = re.sub(r'\*\*(.+?)\*\*', r'\1', text)
                                text = re.sub(r'\*(.+?)\*', r'\1', text)
                                doc.add_paragraph(text, style='List Bullet')
                    i += 1
            else:
                i += 1

    def convert_md_to_pptx(self, md_file, output_dir):
        """Convert Markdown to PowerPoint presentation."""
        try:
            output_file = output_dir / f"{md_file.stem}.pptx"

            # Read markdown
            with open(md_file, 'r', encoding='utf-8') as f:
                md_content = f.read()

            # Create presentation
            prs = Presentation()
            prs.slide_width = PptxInches(10)
            prs.slide_height = PptxInches(7.5)

            # Parse markdown into slides
            slides_data = self._parse_md_for_slides(md_content)

            for slide_data in slides_data:
                if slide_data['type'] == 'title':
                    self._add_title_slide(prs, slide_data)
                else:
                    self._add_content_slide(prs, slide_data)

            prs.save(output_file)
            print(f"  ✅ {md_file.name} → {output_file.name}")
            self.stats['md_to_pptx'] += 1

        except Exception as e:
            error_msg = f"Error converting {md_file.name}: {str(e)}"
            print(f"  ❌ {error_msg}")
            self.stats['errors'].append(error_msg)

    def _parse_md_for_slides(self, md_content):
        """Parse markdown content into slide data."""
        slides = []
        lines = md_content.split('\n')
        current_slide = None

        for line in lines:
            line = line.strip()

            # H1 creates title slide
            if line.startswith('# '):
                if current_slide:
                    slides.append(current_slide)
                current_slide = {
                    'type': 'title',
                    'title': line[2:].strip(),
                    'subtitle': ''
                }

            # H2 creates content slide
            elif line.startswith('## '):
                if current_slide:
                    slides.append(current_slide)
                current_slide = {
                    'type': 'content',
                    'title': line[3:].strip(),
                    'bullets': []
                }

            # Bullet points
            elif line.startswith('- ') or line.startswith('* '):
                if current_slide and current_slide['type'] == 'content':
                    bullet_text = line[2:].strip()
                    # Remove markdown formatting
                    bullet_text = re.sub(r'\*\*(.+?)\*\*', r'\1', bullet_text)
                    bullet_text = re.sub(r'\*(.+?)\*', r'\1', bullet_text)
                    current_slide['bullets'].append(bullet_text)

            # Regular text for subtitle in title slides
            elif line and current_slide and current_slide['type'] == 'title' and not current_slide['subtitle']:
                current_slide['subtitle'] = line

        if current_slide:
            slides.append(current_slide)

        return slides

    def _add_title_slide(self, prs, slide_data):
        """Add title slide to presentation."""
        slide_layout = prs.slide_layouts[0]  # Title slide layout
        slide = prs.slides.add_slide(slide_layout)

        title = slide.shapes.title
        subtitle = slide.placeholders[1]

        title.text = slide_data['title']
        if slide_data.get('subtitle'):
            subtitle.text = slide_data['subtitle']

    def _add_content_slide(self, prs, slide_data):
        """Add content slide to presentation."""
        slide_layout = prs.slide_layouts[1]  # Title and content layout
        slide = prs.slides.add_slide(slide_layout)

        title = slide.shapes.title
        title.text = slide_data['title']

        if slide_data['bullets']:
            body = slide.placeholders[1]
            tf = body.text_frame
            tf.clear()

            for i, bullet in enumerate(slide_data['bullets']):
                if i == 0:
                    tf.text = bullet
                else:
                    p = tf.add_paragraph()
                    p.text = bullet
                    p.level = 0

    def print_summary(self):
        """Print generation summary."""
        print("\n" + "="*60)
        print("📊 Generation Summary")
        print("="*60)
        print(f"✅ CSV → Excel:      {self.stats['csv_to_xlsx']} files")
        print(f"✅ MD → Word:        {self.stats['md_to_docx']} files")
        print(f"✅ MD → PowerPoint:  {self.stats['md_to_pptx']} files")

        total = self.stats['csv_to_xlsx'] + self.stats['md_to_docx'] + self.stats['md_to_pptx']
        print(f"\n📁 Total generated:  {total} files")

        if self.stats['errors']:
            print(f"\n❌ Errors: {len(self.stats['errors'])}")
            for error in self.stats['errors']:
                print(f"   • {error}")
        else:
            print("\n✨ All files generated successfully!")
        print("="*60)


def main():
    parser = argparse.ArgumentParser(
        description='Generate professional output files from raw source files.'
    )
    parser.add_argument(
        '--path',
        type=str,
        required=True,
        help='Path to solution directory or solution-template'
    )

    args = parser.parse_args()

    # Validate path exists
    path = Path(args.path)
    if not path.exists():
        print(f"❌ Error: Path does not exist: {path}")
        sys.exit(1)

    # Generate outputs
    generator = OutputGenerator(path)
    success = generator.generate_all()

    sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()
