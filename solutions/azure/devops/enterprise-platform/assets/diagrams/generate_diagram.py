#!/usr/bin/env python3
"""
Azure DevOps Enterprise Platform - Architecture Diagram Generator

Generates a simplified 6-8 component architecture diagram showing the DevOps Pipeline Factory.
Creates both DrawIO XML and PNG outputs.

Usage:
    python3 generate_diagram.py
"""

import os
import json
from pathlib import Path


def generate_drawio_xml():
    """Generate a DrawIO XML diagram with 6-8 Azure DevOps components."""

    # DrawIO XML structure with components
    drawio_xml = '''<?xml version="1.0" encoding="UTF-8"?>
<mxfile host="Electron" modified="2025-11-15T00:00:00.000Z" agent="Mozilla/5.0" version="24.0.0" type="device">
  <diagram name="Azure DevOps Enterprise Platform" id="diagram1">
    <mxGraphModel dx="1200" dy="800" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="960" pageHeight="600" math="0" shadow="0">
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />

        <!-- Layer 1: Source Control (Blue) -->
        <mxCell id="layer1" value="Layer 1: Source Control" style="text;fontSize=12;fontStyle=bold;fillColor=#E8F4FD;rounded=1" vertex="1" parent="1">
          <mxGeometry x="20" y="20" width="200" height="30" as="geometry" />
        </mxCell>

        <!-- Azure DevOps Repos -->
        <mxCell id="repos" value="Azure DevOps&#10;Repos (Git)" style="rounded=1;whiteSpace=wrap;html=1;fontSize=14;fontStyle=bold;fillColor=#0078D4;fontColor=#FFFFFF;strokeWidth=2;strokeColor=#003F7F;" vertex="1" parent="1">
          <mxGeometry x="40" y="80" width="160" height="80" as="geometry" />
        </mxCell>

        <!-- Layer 2: Build & Container (Orange) -->
        <mxCell id="layer2" value="Layer 2: Build &amp; Container" style="text;fontSize=12;fontStyle=bold;fillColor=#FEF0E8;rounded=1" vertex="1" parent="1">
          <mxGeometry x="280" y="20" width="220" height="30" as="geometry" />
        </mxCell>

        <!-- Azure DevOps Pipelines -->
        <mxCell id="pipelines" value="Azure DevOps&#10;Pipelines (CI/CD)" style="rounded=1;whiteSpace=wrap;html=1;fontSize=14;fontStyle=bold;fillColor=#FF8C00;fontColor=#FFFFFF;strokeWidth=2;strokeColor=#CC6600;" vertex="1" parent="1">
          <mxGeometry x="280" y="80" width="160" height="80" as="geometry" />
        </mxCell>

        <!-- Azure Container Registry -->
        <mxCell id="acr" value="Azure Container&#10;Registry (ACR)" style="rounded=1;whiteSpace=wrap;html=1;fontSize=14;fontStyle=bold;fillColor=#FF8C00;fontColor=#FFFFFF;strokeWidth=2;strokeColor=#CC6600;" vertex="1" parent="1">
          <mxGeometry x="480" y="80" width="160" height="80" as="geometry" />
        </mxCell>

        <!-- Layer 3: Deployment & Operations (Green) -->
        <mxCell id="layer3" value="Layer 3: Deployment &amp; Operations" style="text;fontSize=12;fontStyle=bold;fillColor=#E8F4E8;rounded=1" vertex="1" parent="1">
          <mxGeometry x="700" y="20" width="240" height="30" as="geometry" />
        </mxCell>

        <!-- Azure Kubernetes Service -->
        <mxCell id="aks" value="Azure Kubernetes&#10;Service (AKS)" style="rounded=1;whiteSpace=wrap;html=1;fontSize=14;fontStyle=bold;fillColor=#107C10;fontColor=#FFFFFF;strokeWidth=2;strokeColor=#064A0E;" vertex="1" parent="1">
          <mxGeometry x="700" y="80" width="160" height="80" as="geometry" />
        </mxCell>

        <!-- Layer 2-3 Support Services -->
        <mxCell id="keyvault" value="Azure Key Vault&#10;(Secrets Management)" style="rounded=1;whiteSpace=wrap;html=1;fontSize=12;fontStyle=bold;fillColor=#9C27B0;fontColor=#FFFFFF;strokeWidth=2;strokeColor=#6A1B9A;" vertex="1" parent="1">
          <mxGeometry x="280" y="220" width="160" height="70" as="geometry" />
        </mxCell>

        <!-- Azure Monitor -->
        <mxCell id="monitor" value="Azure Monitor&#10;(Logging &amp; Alerts)" style="rounded=1;whiteSpace=wrap;html=1;fontSize=12;fontStyle=bold;fillColor=#D83B01;fontColor=#FFFFFF;strokeWidth=2;strokeColor=#A63200;" vertex="1" parent="1">
          <mxGeometry x="480" y="220" width="160" height="70" as="geometry" />
        </mxCell>

        <!-- Data Flow Arrows -->

        <!-- Flow 1: Code Commit -->
        <mxCell id="flow1" value="Code Commit" style="edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;fontSize=11;fontColor=#666;strokeColor=#333;strokeWidth=2;dashed=0;" edge="1" parent="1" source="repos" target="pipelines">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>

        <!-- Flow 2: Pipeline Trigger -->
        <mxCell id="flow2" value="Build &amp; Test" style="edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;fontSize=11;fontColor=#666;strokeColor=#333;strokeWidth=2;dashed=0;" edge="1" parent="1" source="pipelines" target="acr">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>

        <!-- Flow 3: Push Image -->
        <mxCell id="flow3" value="Push Image" style="edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;fontSize=11;fontColor=#666;strokeColor=#333;strokeWidth=2;dashed=0;" edge="1" parent="1" source="acr" target="aks">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>

        <!-- Flow 4: Secrets Access -->
        <mxCell id="flow4" value="Secrets &amp; Keys" style="edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;fontSize=11;fontColor=#666;strokeColor=#333;strokeWidth=2;dashed=1;" edge="1" parent="1" source="keyvault" target="aks">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>

        <!-- Flow 5: Monitoring -->
        <mxCell id="flow5" value="Logs &amp; Metrics" style="edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;fontSize=11;fontColor=#666;strokeColor=#333;strokeWidth=2;dashed=1;" edge="1" parent="1" source="aks" target="monitor">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>

        <!-- Title -->
        <mxCell id="title" value="Azure DevOps Enterprise Platform - DevOps Pipeline Factory" style="text;fontSize=18;fontStyle=bold;fillColor=none;rounded=0" vertex="1" parent="1">
          <mxGeometry x="20" y="350" width="900" height="40" as="geometry" />
        </mxCell>

        <!-- Description -->
        <mxCell id="description" value="3-Layer Architecture with 6 Core Azure Services: Source Control (Repos) → Build (Pipelines &amp; ACR) → Deploy (AKS) with Security (Key Vault) &amp; Operations (Monitor)" style="text;fontSize=11;fillColor=none;rounded=0;align=center" vertex="1" parent="1">
          <mxGeometry x="20" y="400" width="900" height="40" as="geometry" />
        </mxCell>

      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
'''

    return drawio_xml


def save_drawio_file(xml_content):
    """Save DrawIO XML to file."""
    output_path = Path(__file__).parent / "architecture-diagram.drawio"

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(xml_content)

    print(f"Created: {output_path}")
    return output_path


def generate_png_from_drawio():
    """
    Attempt to generate PNG from DrawIO file using available tools.
    This requires either:
    - drawio CLI tool installed
    - Python libraries: cairosvg, Pillow, or similar

    For now, provides instructions for manual export.
    """
    drawio_path = Path(__file__).parent / "architecture-diagram.drawio"
    png_path = Path(__file__).parent / "architecture-diagram.png"

    print("\nGenerating PNG from DrawIO file...")
    print(f"DrawIO Source: {drawio_path}")
    print(f"PNG Target: {png_path}")

    # Check if drawio CLI is available
    import subprocess
    try:
        result = subprocess.run(['which', 'drawio'], capture_output=True, text=True, timeout=5)
        if result.returncode == 0:
            # drawio CLI found, use it
            cmd = [
                'drawio',
                '-x',  # Export as PNG
                '-o', str(png_path),
                '-w', '1920',
                '-h', '1200',
                str(drawio_path)
            ]
            subprocess.run(cmd, check=True)
            print(f"Successfully generated: {png_path}")
            return True
    except (subprocess.CalledProcessError, FileNotFoundError, TimeoutError):
        pass

    # Alternative: Try using Python libraries
    try:
        from PIL import Image, ImageDraw, ImageFont
        import textwrap

        # Create a simple PNG representation if drawio CLI not available
        print("\ndrawio CLI not found. Creating simplified diagram image...")

        width, height = 1920, 1200
        img = Image.new('RGB', (width, height), color='white')
        draw = ImageDraw.Draw(img)

        # Try to load a nice font, fall back to default
        try:
            font_large = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 36)
            font_medium = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 24)
            font_small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 16)
        except:
            font_large = ImageFont.load_default()
            font_medium = ImageFont.load_default()
            font_small = ImageFont.load_default()

        # Draw title
        title = "Azure DevOps Enterprise Platform - DevOps Pipeline Factory"
        draw.text((100, 50), title, fill='black', font=font_large)

        # Draw subtitle
        subtitle = "3-Layer Architecture with 6 Core Azure Services"
        draw.text((100, 120), subtitle, fill='#666666', font=font_medium)

        # Draw layer boxes with components
        y_start = 200
        box_height = 150
        box_width = 280
        spacing = 40

        # Layer 1: Source Control
        draw.rectangle([50, y_start, 50+box_width, y_start+box_height], fill='#E8F4FD', outline='#0078D4', width=3)
        draw.text((80, y_start+40), "Azure DevOps\nRepos (Git)", fill='#0078D4', font=font_medium)

        # Layer 2: Build & Container
        x_pos = 50 + box_width + spacing
        draw.rectangle([x_pos, y_start, x_pos+box_width, y_start+box_height], fill='#FFE8CC', outline='#FF8C00', width=3)
        draw.text((x_pos+30, y_start+40), "Azure DevOps\nPipelines (CI/CD)", fill='#FF8C00', font=font_medium)

        x_pos += box_width + spacing
        draw.rectangle([x_pos, y_start, x_pos+box_width, y_start+box_height], fill='#FFE8CC', outline='#FF8C00', width=3)
        draw.text((x_pos+30, y_start+40), "Azure Container\nRegistry (ACR)", fill='#FF8C00', font=font_medium)

        # Layer 3: Deployment
        x_pos += box_width + spacing
        draw.rectangle([x_pos, y_start, x_pos+box_width, y_start+box_height], fill='#E8F4E8', outline='#107C10', width=3)
        draw.text((x_pos+20, y_start+40), "Azure Kubernetes\nService (AKS)", fill='#107C10', font=font_medium)

        # Support Services
        y_support = y_start + box_height + spacing + 50

        # Key Vault
        draw.rectangle([50, y_support, 50+box_width, y_support+120], fill='#F3E5FF', outline='#9C27B0', width=3)
        draw.text((80, y_support+40), "Azure Key Vault\nSecrets", fill='#9C27B0', font=font_medium)

        # Monitor
        x_pos = 50 + box_width + spacing
        draw.rectangle([x_pos, y_support, x_pos+box_width, y_support+120], fill='#FFE8CC', outline='#D83B01', width=3)
        draw.text((x_pos+40, y_support+40), "Azure Monitor\nLogs & Alerts", fill='#D83B01', font=font_medium)

        # Data Flows
        y_flows = y_support + 180
        flows_text = "Principal Data Flows:"
        draw.text((50, y_flows), flows_text, fill='black', font=font_medium)

        flows = [
            "1. Code Commit → Azure DevOps Repos",
            "2. CI/CD Pipeline Trigger → Build & Test",
            "3. Container Push → Azure Container Registry",
            "4. Image Pull & Deploy → Azure Kubernetes Service",
            "5. Secrets Access → Azure Key Vault",
            "6. Observability → Azure Monitor"
        ]

        y_flow_item = y_flows + 50
        for flow in flows:
            draw.text((70, y_flow_item), flow, fill='#333333', font=font_small)
            y_flow_item += 40

        # Save image
        img.save(png_path, 'PNG')
        print(f"Successfully generated simplified diagram: {png_path}")
        return True

    except ImportError:
        print("\nWarning: PIL not available. Cannot generate PNG.")
        print("To export as PNG, please:")
        print(f"1. Open {drawio_path} in draw.io (https://draw.io)")
        print(f"2. File → Export As → PNG")
        print(f"3. Set dimensions to 1920x1200")
        return False


def main():
    """Main execution function."""
    print("Azure DevOps Enterprise Platform - Diagram Generator")
    print("=" * 60)

    # Generate DrawIO XML
    print("\nGenerating DrawIO XML diagram...")
    xml_content = generate_drawio_xml()
    drawio_path = save_drawio_file(xml_content)

    # Generate PNG
    try:
        png_generated = generate_png_from_drawio()
    except Exception as e:
        print(f"Error generating PNG: {e}")
        png_generated = False

    # Summary
    print("\n" + "=" * 60)
    print("Diagram Generation Complete!")
    print("=" * 60)
    print(f"\nGenerated Files:")
    print(f"  - DrawIO (editable): {drawio_path}")

    if png_generated:
        png_path = Path(__file__).parent / "architecture-diagram.png"
        print(f"  - PNG (for presentations): {png_path}")

    print("\nNext Steps:")
    print("  1. DrawIO: Open in draw.io for editing")
    print("  2. PNG: Use in presentations and documentation")
    print("  3. Share: Add to solution briefing slides")


if __name__ == "__main__":
    main()
