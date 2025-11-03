# EOFramework PowerPoint Template
## Professional Template with 3 Logo Placeholders

---

## ✨ What's New: 3 Logo Support!

**Title Slide now has 3 logo placeholders:**
- 🏢 Customer Logo (left)
- 💼 Consulting Company Logo (center)  
- 🎯 EO Framework Logo (right)

**Content slides stay CLEAN:**
- No logo clutter on slides 2, 3, 4
- Maximum space for your content
- Professional appearance

---

## 📦 Main File

### **EOFramework-Template-3Logos.pptx**

This template includes:

✅ **8 Reference Slides** - Shows all design patterns
✅ **5 Slide Master Layouts** - For scripting
✅ **3 Logo Placeholders** - Only on title slide (smart!)

---

## 🚀 Quick Start

### Adding Logos to Title Slide

```python
from pptx import Presentation

prs = Presentation('EOFramework-Template-3Logos.pptx')

# Create title slide
slide = prs.slides.add_slide(prs.slide_layouts[1])
slide.shapes.title.text = "Project Proposal"
slide.placeholders[2].text = "Q4 Initiative"

# Add the 3 logos
slide.placeholders[1].insert_picture('customer-logo.png')      # Left
slide.placeholders[3].insert_picture('consulting-logo.png')    # Center
slide.placeholders[4].insert_picture('eo-framework-logo.png')  # Right

prs.save('presentation.pptx')
```

### Creating Content Slides (No Logos)

```python
# Content slides are clean - no logo placeholders!
slide = prs.slides.add_slide(prs.slide_layouts[2])
slide.shapes.title.text = "Key Benefits"

content = slide.placeholders[1]
content.text_frame.text = "Accelerated delivery"

prs.save('presentation.pptx')
```

---

## 📋 Layout Guide

### Layout 1: Title Slide
**Logo Placeholders:**
- `placeholder[1]` - Customer Logo (footer left)
- `placeholder[3]` - Consulting Company Logo (footer center)
- `placeholder[4]` - EO Framework Logo (footer right)

**Text Placeholders:**
- `shapes.title` - Main title (centered)
- `placeholder[2]` - Subtitle

### Layouts 2, 3, 4: Content Slides
**NO logo placeholders** - Clean and professional!

- Layout 2: Title and Content
- Layout 3: Two Column
- Layout 4: Section Header

---

## 💡 Logo Strategy

**Why logos only on title slide?**
- ✅ Professional: Not cluttered
- ✅ Clean: More space for content
- ✅ Smart: Shows partnerships upfront
- ✅ Flexible: Easy to customize

**Typical use case:**
1. Title slide shows all 3 logos (Customer + Consulting + EOFramework)
2. All content slides focus on the message
3. Closing slide can repeat logos if needed

---

## 📁 What's Included

- **EOFramework-Template-3Logos.pptx** - Main template
- **demo_3logos.py** - Example script showing how to use logos
- **README-3Logos.md** - This file
- **eo-framework-logo.png** - EO logo file

---

## 🎨 Logo Sizes & Positions

All 3 logos on title slide:
- **Size**: ~1.25" wide × 0.5" tall
- **Position**: Footer area (bottom of slide)
- **Spacing**: Evenly distributed across width

```
┌──────────────────────────────────────────┐
│                                          │
│          PRESENTATION TITLE              │
│              Subtitle                    │
│                                          │
├──────────────────────────────────────────┤
│  [Customer]   [Consulting]   [EO]       │
└──────────────────────────────────────────┘
```

---

## ✅ Run the Demo

```bash
# Create demo presentation
python3 demo_3logos.py

# Show logo positions
python3 demo_3logos.py --info
```

---

## 💻 Complete Example

```python
from pptx import Presentation

def create_partner_presentation():
    # Load template with 3 logo support
    prs = Presentation('EOFramework-Template-3Logos.pptx')
    
    # Title slide with all 3 logos
    slide = prs.slides.add_slide(prs.slide_layouts[1])
    slide.shapes.title.text = "Digital Transformation"
    slide.placeholders[2].text = "Strategic Partnership Initiative"
    
    # Add partner logos
    try:
        slide.placeholders[1].insert_picture('acme-corp-logo.png')      # Customer
        slide.placeholders[3].insert_picture('consulting-co-logo.png')  # Consultant
        slide.placeholders[4].insert_picture('eo-framework-logo.png')   # EO
    except FileNotFoundError:
        print("Add logo files to insert them")
    
    # Clean content slide (no logos)
    slide = prs.slides.add_slide(prs.slide_layouts[2])
    slide.shapes.title.text = "Project Objectives"
    
    tf = slide.placeholders[1].text_frame
    tf.text = "Transform operations"
    tf.add_paragraph().text = "Accelerate delivery"
    tf.add_paragraph().text = "Reduce costs by 30%"
    
    # Save
    prs.save('partner-presentation.pptx')
    print("✓ Created presentation with 3 logos!")

create_partner_presentation()
```

---

## ❓ FAQ

**Q: Do I need to use all 3 logo placeholders?**
A: No! Leave any empty and they won't show up.

**Q: Can I add logos to content slides?**
A: Content slides don't have logo placeholders (by design - keeps them clean). If needed, manually add images.

**Q: What if I only need 2 logos?**
A: Just fill 2 placeholders, leave the third empty.

**Q: Where exactly are the logos positioned?**
A: Run `python3 demo_3logos.py --info` to see positions.

**Q: Can I change logo sizes?**
A: Yes! In PowerPoint: View → Slide Master → adjust placeholders.

---

## 🎯 Best Practices

1. **Use consistent logo files** (same format, good quality)
2. **PNG with transparency** works best
3. **Similar heights** for all 3 logos look professional
4. **Add logos programmatically** for automation
5. **Keep content slides clean** - no manual logo additions

---

Made for EOFramework • www.eoframework.org
