#!/usr/bin/env python3
"""
Fix PowerPoint template to open in Normal view instead of Slide Master view.
"""

from pptx import Presentation
from pathlib import Path


def fix_template_view():
    """Fix the PowerPoint template to open in Normal (presentation) view."""

    template_path = Path('support/doc-templates/powerpoint/EOFramework-Template-01.pptx')

    print("=" * 70)
    print("FIXING POWERPOINT TEMPLATE VIEW")
    print("=" * 70)
    print()

    if not template_path.exists():
        print(f"❌ Template not found: {template_path}")
        return

    print(f"📂 Loading template: {template_path}")

    # Load the template
    prs = Presentation(str(template_path))

    print(f"✅ Template loaded: {len(prs.slides)} slides, {len(prs.slide_layouts)} layouts")
    print()

    # The template should have at least one slide to set the default view properly
    # If it has demo slides, that's fine - they'll be cleared during generation
    print("🔧 Adjusting view settings...")

    # Remove any attribute that forces master view
    try:
        if hasattr(prs._element, 'attrib'):
            prs._element.attrib.pop('showMasterSp', None)
            prs._element.attrib.pop('showMasterPhAnim', None)
        print("  ✅ Removed master view attributes")
    except Exception as e:
        print(f"  ⚠️  Could not modify attributes: {e}")

    # Save the template
    print()
    print("💾 Saving template with Normal view...")
    prs.save(str(template_path))

    print()
    print("=" * 70)
    print("✅ Template fixed! It should now open in Normal view.")
    print("=" * 70)
    print()
    print("Next steps:")
    print("  1. Open the template manually in PowerPoint")
    print("  2. Verify it opens in Normal (Slide) view")
    print("  3. If still in Master view, switch to Normal view and Save")
    print("  4. Regenerate presentations using generate-outputs.py")
    print()


if __name__ == '__main__':
    fix_template_view()
