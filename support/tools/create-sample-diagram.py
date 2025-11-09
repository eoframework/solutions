#!/usr/bin/env python3
"""
Create a sample diagram image for the template.
"""

from PIL import Image, ImageDraw, ImageFont
from pathlib import Path

# Create a simple diagram placeholder
width = 600
height = 400

# Create image with white background
img = Image.new('RGB', (width, height), color='white')
draw = ImageDraw.Draw(img)

# Draw border
draw.rectangle([10, 10, width-10, height-10], outline='#1F4E78', width=3)

# Draw title box
draw.rectangle([50, 40, width-50, 80], fill='#E8F0F8', outline='#1F4E78', width=2)

# Draw architecture boxes
box_height = 80
box_width = 150
y_start = 120

# Box 1 - Left
draw.rectangle([50, y_start, 50+box_width, y_start+box_height],
               fill='#E8F0F8', outline='#1F4E78', width=2)

# Box 2 - Center
draw.rectangle([250, y_start, 250+box_width, y_start+box_height],
               fill='#E8F0F8', outline='#1F4E78', width=2)

# Arrow from Box 1 to Box 2
arrow_y = y_start + box_height//2
draw.line([50+box_width, arrow_y, 250, arrow_y], fill='#1F4E78', width=3)
# Arrow head
draw.polygon([250, arrow_y, 240, arrow_y-5, 240, arrow_y+5], fill='#1F4E78')

# Box 3 - Bottom
draw.rectangle([150, y_start+120, 150+box_width, y_start+120+box_height],
               fill='#E8F0F8', outline='#1F4E78', width=2)

# Arrow from Box 2 to Box 3
draw.line([250+box_width//2, y_start+box_height, 150+box_width//2, y_start+120],
          fill='#1F4E78', width=3)
# Arrow head
arrow_x = 150+box_width//2
draw.polygon([arrow_x, y_start+120, arrow_x-5, y_start+110, arrow_x+5, y_start+110],
             fill='#1F4E78')

# Add text
try:
    # Try to use a default font
    font_large = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 16)
    font_normal = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 14)
except:
    # Fallback to default font
    font_large = ImageFont.load_default()
    font_normal = ImageFont.load_default()

# Title
draw.text((width//2, 60), "Sample Architecture Diagram", fill='#1F4E78',
          anchor="mm", font=font_large)

# Box labels
draw.text((50+box_width//2, y_start+box_height//2), "Component A",
          fill='#1F4E78', anchor="mm", font=font_normal)
draw.text((250+box_width//2, y_start+box_height//2), "Component B",
          fill='#1F4E78', anchor="mm", font=font_normal)
draw.text((150+box_width//2, y_start+120+box_height//2), "Component C",
          fill='#1F4E78', anchor="mm", font=font_normal)

# Save
output_path = Path('support/doc-templates/assets/sample-diagram.png')
img.save(output_path)
print(f"✅ Sample diagram created: {output_path}")
print(f"   Dimensions: {width}x{height}px")
