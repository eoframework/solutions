#!/usr/bin/env python3
"""
Generate Azure Virtual Desktop Architecture Diagram
Creates both PNG and Draw.io XML files with a simple, clear design.
"""

import io
import base64
from pathlib import Path
from typing import Tuple, List

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    Image = None
    ImageDraw = None
    ImageFont = None

# Color definitions
COLORS = {
    'azure_blue': '#0078D4',
    'light_blue': '#D4E6FF',
    'dark_blue': '#003366',
    'green': '#107C10',
    'gray': '#F5F5F5',
    'dark_gray': '#333333',
    'white': '#FFFFFF',
    'light_gray': '#EEEEEE',
}

def create_diagram_drawio() -> str:
    """Create a Draw.io XML diagram for Azure Virtual Desktop architecture."""

    drawio_xml = '''<?xml version="1.0" encoding="UTF-8"?>
<mxfile host="app.diagrams.net" modified="2025-11-15" agent="5.0" version="24.0.0" type="device">
  <diagram id="diagram-avd-architecture" name="AVD Architecture">
    <mxGraphModel dx="1200" dy="800" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="1920" pageHeight="1200" math="0" shadow="0">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>

        <!-- VNet Background -->
        <mxCell id="vnet-bg" value="Azure Virtual Network" style="rounded=1;whiteSpace=wrap;html=1;strokeWidth=2;strokeDasharray=5,5;fillColor=none;strokeColor=#0078D4;fontSize=14;fontStyle=bold;arcSize=10;" vertex="1" parent="1">
          <mxGeometry x="50" y="50" width="1820" height="1100" as="geometry"/>
        </mxCell>

        <!-- Users (Top-Left) -->
        <mxCell id="users" value="100 Users&#10;(Global)" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#F5F5F5;strokeColor=#333333;strokeWidth=2;fontSize=14;fontStyle=bold;" vertex="1" parent="1">
          <mxGeometry x="100" y="100" width="180" height="120" as="geometry"/>
        </mxCell>

        <!-- Azure AD (Top-Center) -->
        <mxCell id="aad" value="Azure AD&#10;Authentication &amp; SSO" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#0078D4;strokeColor=#003366;strokeWidth=2;fontSize=13;fontStyle=bold;fontColor=#FFFFFF;" vertex="1" parent="1">
          <mxGeometry x="450" y="100" width="200" height="120" as="geometry"/>
        </mxCell>

        <!-- M365 Apps (Top-Right) -->
        <mxCell id="apps" value="M365 Apps&#10;&amp; Services" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#0078D4;strokeColor=#003366;strokeWidth=2;fontSize=13;fontStyle=bold;fontColor=#FFFFFF;" vertex="1" parent="1">
          <mxGeometry x="1600" y="100" width="200" height="120" as="geometry"/>
        </mxCell>

        <!-- AVD Host Pool (Center) -->
        <mxCell id="hostpool-container" value="AVD Host Pool&#10;20 x D4s_v5 VMs (Windows 11 Multi-Session)" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#D4E6FF;strokeColor=#0078D4;strokeWidth=3;fontSize=13;fontStyle=bold;" vertex="1" parent="1">
          <mxGeometry x="400" y="350" width="1100" height="320" as="geometry"/>
        </mxCell>

        <!-- VM Boxes inside Host Pool -->
        <mxCell id="vm1" value="Session Host VM&#n5 users/VM" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#0078D4;strokeColor=#003366;strokeWidth=2;fontSize=11;fontColor=#FFFFFF;" vertex="1" parent="1">
          <mxGeometry x="440" y="390" width="140" height="100" as="geometry"/>
        </mxCell>

        <mxCell id="vm2" value="Session Host VM&#n5 users/VM" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#0078D4;strokeColor=#003366;strokeWidth=2;fontSize=11;fontColor=#FFFFFF;" vertex="1" parent="1">
          <mxGeometry x="620" y="390" width="140" height="100" as="geometry"/>
        </mxCell>

        <mxCell id="vm3" value="Session Host VM&#n5 users/VM" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#0078D4;strokeColor=#003366;strokeWidth=2;fontSize=11;fontColor=#FFFFFF;" vertex="1" parent="1">
          <mxGeometry x="800" y="390" width="140" height="100" as="geometry"/>
        </mxCell>

        <mxCell id="vm-more" value="...&#10;(17 more VMs)" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#0078D4;strokeColor=#003366;strokeWidth=2;fontSize=11;fontColor=#FFFFFF;" vertex="1" parent="1">
          <mxGeometry x="980" y="390" width="140" height="100" as="geometry"/>
        </mxCell>

        <!-- Load Balancer info -->
        <mxCell id="lb-info" value="Session Broker&#n(Load Balancing)" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#107C10;strokeColor=#003366;strokeWidth=2;fontSize=11;fontColor=#FFFFFF;" vertex="1" parent="1">
          <mxGeometry x="600" y="520" width="160" height="80" as="geometry"/>
        </mxCell>

        <!-- Azure Files (Bottom-Left) -->
        <mxCell id="files" value="Azure Files Premium&#n500GB - FSLogix Profiles" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#0078D4;strokeColor=#003366;strokeWidth=2;fontSize=13;fontStyle=bold;fontColor=#FFFFFF;" vertex="1" parent="1">
          <mxGeometry x="100" y="820" width="220" height="130" as="geometry"/>
        </mxCell>

        <!-- Azure Monitor (Bottom-Right) -->
        <mxCell id="monitor" value="Azure Monitor&#n&amp; Log Analytics" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#0078D4;strokeColor=#003366;strokeWidth=2;fontSize=13;fontStyle=bold;fontColor=#FFFFFF;" vertex="1" parent="1">
          <mxGeometry x="1580" y="820" width="220" height="130" as="geometry"/>
        </mxCell>

        <!-- Data Flows -->

        <!-- Flow 1: Users to Azure AD -->
        <mxCell id="flow1-line" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#003366;strokeWidth=2.5;dashed=0;endArrow=classic;endFill=1;" edge="1" parent="1" source="users" target="aad">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>
        <mxCell id="flow1-label" value="Authentication Request" style="edgeLabel;html=1;align=center;verticalAlign=middle;resizable=0;points=[];fontSize=11;fontStyle=italic;" vertex="1" connectedEdge="flow1-line" parent="1">
          <mxGeometry x="275" y="80" as="geometry"/>
        </mxCell>

        <!-- Flow 2: Azure AD to Host Pool -->
        <mxCell id="flow2-line" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#003366;strokeWidth=2.5;dashed=0;endArrow=classic;endFill=1;" edge="1" parent="1" source="aad" target="hostpool-container">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>
        <mxCell id="flow2-label" value="Session Broker Assignment" style="edgeLabel;html=1;align=center;verticalAlign=middle;resizable=0;points=[];fontSize=11;fontStyle=italic;" vertex="1" connectedEdge="flow2-line" parent="1">
          <mxGeometry x="475" y="280" as="geometry"/>
        </mxCell>

        <!-- Flow 3: Apps to Host Pool -->
        <mxCell id="flow3-line" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#107C10;strokeWidth=2.5;dashed=0;endArrow=classic;endFill=1;" edge="1" parent="1" source="apps" target="hostpool-container">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>
        <mxCell id="flow3-label" value="Apps &amp; Data Access" style="edgeLabel;html=1;align=center;verticalAlign=middle;resizable=0;points=[];fontSize=11;fontStyle=italic;" vertex="1" connectedEdge="flow3-line" parent="1">
          <mxGeometry x="1545" y="280" as="geometry"/>
        </mxCell>

        <!-- Flow 4: Host Pool to Files (Bidirectional) -->
        <mxCell id="flow4-line" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#003366;strokeWidth=2.5;dashed=0;endArrow=classic;endFill=1;" edge="1" parent="1" source="hostpool-container" target="files">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>
        <mxCell id="flow4-label" value="FSLogix Profile Sync" style="edgeLabel;html=1;align=center;verticalAlign=middle;resizable=0;points=[];fontSize=11;fontStyle=italic;" vertex="1" connectedEdge="flow4-line" parent="1">
          <mxGeometry x="250" y="720" as="geometry"/>
        </mxCell>

        <!-- Flow 5: Host Pool to Monitor -->
        <mxCell id="flow5-line" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#107C10;strokeWidth=2.5;dashed=0;endArrow=classic;endFill=1;" edge="1" parent="1" source="hostpool-container" target="monitor">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>
        <mxCell id="flow5-label" value="Telemetry &amp; Audit Logs" style="edgeLabel;html=1;align=center;verticalAlign=middle;resizable=0;points=[];fontSize=11;fontStyle=italic;" vertex="1" connectedEdge="flow5-line" parent="1">
          <mxGeometry x="1490" y="720" as="geometry"/>
        </mxCell>

        <!-- Legend -->
        <mxCell id="legend-bg" value="Legend: Blue = Azure Service | Green = Flow | Gray = External" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#EEEEEE;strokeColor=#999999;strokeWidth=1;fontSize=11;" vertex="1" parent="1">
          <mxGeometry x="100" y="1000" width="1720" height="40" as="geometry"/>
        </mxCell>

      </root>
    </mxGraphModel>
  </diagram>
</mxfile>'''

    return drawio_xml


def create_diagram_png() -> bytes:
    """Create a PNG image of the AVD architecture diagram using PIL."""

    if Image is None or ImageDraw is None:
        return None

    # Image dimensions
    width, height = 1920, 1200

    # Create image with white background
    img = Image.new('RGB', (width, height), color=COLORS['white'])
    draw = ImageDraw.Draw(img)

    # Try to use a nice font, fall back to default if not available
    try:
        title_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 24)
        header_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 16)
        text_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 13)
        label_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Oblique.ttf", 11)
    except:
        title_font = ImageFont.load_default()
        header_font = ImageFont.load_default()
        text_font = ImageFont.load_default()
        label_font = ImageFont.load_default()

    # Helper function to draw rounded rectangle
    def rounded_rect(draw, xy, radius=20, **kwargs):
        x1, y1, x2, y2 = xy
        # Draw main rectangle
        draw.rectangle([x1+radius, y1, x2-radius, y2], **kwargs)
        draw.rectangle([x1, y1+radius, x2, y2-radius], **kwargs)
        # Draw corners
        for i, (corner_x, corner_y) in enumerate([
            (x1+radius, y1+radius),  # Top-left
            (x2-radius, y1+radius),  # Top-right
            (x2-radius, y2-radius),  # Bottom-right
            (x1+radius, y2-radius),  # Bottom-left
        ]):
            if i == 0:
                draw.pieslice([corner_x-radius, corner_y-radius, corner_x+radius, corner_y+radius], 180, 270, **kwargs)
            elif i == 1:
                draw.pieslice([corner_x-radius, corner_y-radius, corner_x+radius, corner_y+radius], 270, 360, **kwargs)
            elif i == 2:
                draw.pieslice([corner_x-radius, corner_y-radius, corner_x+radius, corner_y+radius], 0, 90, **kwargs)
            else:
                draw.pieslice([corner_x-radius, corner_y-radius, corner_x+radius, corner_y+radius], 90, 180, **kwargs)

    # Helper function to draw box with text
    def draw_box(draw, x, y, w, h, text, bg_color, border_color, text_color='#000000'):
        # Draw rectangle
        draw.rectangle([x, y, x+w, y+h], fill=bg_color, outline=border_color, width=2)
        # Draw text
        text_x = x + w // 2
        text_y = y + h // 2
        draw.text((text_x, text_y), text, fill=text_color, font=text_font, anchor="mm")

    def hex_to_rgb(hex_color):
        hex_color = hex_color.lstrip('#')
        return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

    # VNet Background (dashed border)
    vnet_box = [50, 50, 1870, 1150]
    draw.rectangle(vnet_box, outline=hex_to_rgb(COLORS['azure_blue']), width=2)

    # Title
    draw.text((960, 30), "Azure Virtual Desktop Architecture", fill=hex_to_rgb(COLORS['dark_blue']),
              font=title_font, anchor="mm")

    # Users Box
    draw.rectangle([100, 100, 280, 220], fill=hex_to_rgb(COLORS['gray']),
                   outline=hex_to_rgb(COLORS['dark_gray']), width=2)
    draw.text((190, 160), "100 Users\n(Global)", fill=hex_to_rgb(COLORS['dark_gray']),
              font=text_font, anchor="mm")

    # Azure AD Box
    draw.rectangle([450, 100, 650, 220], fill=hex_to_rgb(COLORS['azure_blue']),
                   outline=hex_to_rgb(COLORS['dark_blue']), width=2)
    draw.text((550, 160), "Azure AD\nAuthentication & SSO", fill=hex_to_rgb(COLORS['white']),
              font=text_font, anchor="mm")

    # M365 Apps Box
    draw.rectangle([1600, 100, 1800, 220], fill=hex_to_rgb(COLORS['azure_blue']),
                   outline=hex_to_rgb(COLORS['dark_blue']), width=2)
    draw.text((1700, 160), "M365 Apps\n& Services", fill=hex_to_rgb(COLORS['white']),
              font=text_font, anchor="mm")

    # AVD Host Pool Container
    draw.rectangle([400, 350, 1500, 670], fill=hex_to_rgb(COLORS['light_blue']),
                   outline=hex_to_rgb(COLORS['azure_blue']), width=3)
    draw.text((950, 365), "AVD Host Pool - 20 x D4s_v5 VMs (Windows 11 Multi-Session)",
              fill=hex_to_rgb(COLORS['dark_blue']), font=header_font, anchor="mm")

    # VMs inside host pool
    vm_positions = [(440, 390), (620, 390), (800, 390), (980, 390)]
    for i, (vm_x, vm_y) in enumerate(vm_positions):
        draw.rectangle([vm_x, vm_y, vm_x+140, vm_y+100], fill=hex_to_rgb(COLORS['azure_blue']),
                       outline=hex_to_rgb(COLORS['dark_blue']), width=2)
        if i < 3:
            draw.text((vm_x+70, vm_y+50), f"Session Host\n5 users/VM",
                      fill=hex_to_rgb(COLORS['white']), font=label_font, anchor="mm")
        else:
            draw.text((vm_x+70, vm_y+50), "... (17 more)",
                      fill=hex_to_rgb(COLORS['white']), font=label_font, anchor="mm")

    # Session Broker info
    draw.rectangle([600, 520, 760, 600], fill=hex_to_rgb(COLORS['green']),
                   outline=hex_to_rgb(COLORS['dark_blue']), width=2)
    draw.text((680, 560), "Session Broker\n(Load Balancing)", fill=hex_to_rgb(COLORS['white']),
              font=label_font, anchor="mm")

    # Azure Files Box
    draw.rectangle([100, 820, 320, 950], fill=hex_to_rgb(COLORS['azure_blue']),
                   outline=hex_to_rgb(COLORS['dark_blue']), width=2)
    draw.text((210, 885), "Azure Files Premium\n500GB - FSLogix Profiles",
              fill=hex_to_rgb(COLORS['white']), font=text_font, anchor="mm")

    # Azure Monitor Box
    draw.rectangle([1580, 820, 1800, 950], fill=hex_to_rgb(COLORS['azure_blue']),
                   outline=hex_to_rgb(COLORS['dark_blue']), width=2)
    draw.text((1690, 885), "Azure Monitor\n& Log Analytics", fill=hex_to_rgb(COLORS['white']),
              font=text_font, anchor="mm")

    # Data Flow Arrows and Labels
    # Flow 1: Users -> Azure AD
    draw.line([(280, 160), (450, 160)], fill=hex_to_rgb(COLORS['dark_blue']), width=3)
    draw.polygon([(450, 160), (435, 155), (435, 165)], fill=hex_to_rgb(COLORS['dark_blue']))
    draw.text((365, 145), "Authentication", fill=hex_to_rgb(COLORS['dark_blue']),
              font=label_font, anchor="mm")

    # Flow 2: Azure AD -> Host Pool
    draw.line([(550, 220), (550, 350)], fill=hex_to_rgb(COLORS['dark_blue']), width=3)
    draw.polygon([(550, 350), (545, 335), (555, 335)], fill=hex_to_rgb(COLORS['dark_blue']))
    draw.text((480, 285), "Session\nBroker", fill=hex_to_rgb(COLORS['dark_blue']),
              font=label_font, anchor="mm")

    # Flow 3: Apps -> Host Pool
    draw.line([(1600, 160), (1500, 380)], fill=hex_to_rgb(COLORS['green']), width=3)
    draw.polygon([(1500, 380), (1505, 365), (1495, 365)], fill=hex_to_rgb(COLORS['green']))
    draw.text((1580, 270), "Apps &\nData", fill=hex_to_rgb(COLORS['green']),
              font=label_font, anchor="mm")

    # Flow 4: Host Pool -> Files (FSLogix)
    draw.line([(400, 650), (210, 820)], fill=hex_to_rgb(COLORS['dark_blue']), width=3)
    draw.polygon([(210, 820), (215, 805), (205, 805)], fill=hex_to_rgb(COLORS['dark_blue']))
    draw.text((280, 735), "FSLogix\nProfiles", fill=hex_to_rgb(COLORS['dark_blue']),
              font=label_font, anchor="mm")

    # Flow 5: Host Pool -> Monitor
    draw.line([(1500, 650), (1690, 820)], fill=hex_to_rgb(COLORS['green']), width=3)
    draw.polygon([(1690, 820), (1685, 805), (1695, 805)], fill=hex_to_rgb(COLORS['green']))
    draw.text((1620, 735), "Telemetry &\nLogs", fill=hex_to_rgb(COLORS['green']),
              font=label_font, anchor="mm")

    # Legend
    draw.rectangle([100, 1000, 1820, 1050], fill=hex_to_rgb(COLORS['light_gray']),
                   outline=hex_to_rgb('#999999'), width=1)
    draw.text((960, 1025), "Azure Services (Blue) | Data Flows (Dark Blue & Green) | External (Gray) | VNet Boundary (Dashed)",
              fill=hex_to_rgb(COLORS['dark_blue']), font=label_font, anchor="mm")

    # Save to bytes
    img_bytes = io.BytesIO()
    img.save(img_bytes, format='PNG')
    return img_bytes.getvalue()


def main():
    """Generate both Draw.io and PNG diagram files."""

    base_path = Path("/mnt/c/projects/wsl/solutions/solutions/azure/modern-workspace/virtual-desktop/presales")

    print("Generating Azure Virtual Desktop Architecture Diagrams...")

    # Generate Draw.io XML
    print("\n1. Creating Draw.io diagram (architecture-diagram.drawio)...")
    drawio_content = create_diagram_drawio()
    drawio_path = base_path / "architecture-diagram.drawio"
    drawio_path.write_text(drawio_content, encoding='utf-8')
    print(f"   SUCCESS: {drawio_path}")
    print(f"   Size: {len(drawio_content)} bytes")

    # Generate PNG image
    print("\n2. Creating PNG diagram (architecture-diagram.png)...")
    try:
        png_bytes = create_diagram_png()
        if png_bytes:
            png_path = base_path / "architecture-diagram.png"
            png_path.write_bytes(png_bytes)
            print(f"   SUCCESS: {png_path}")
            print(f"   Size: {len(png_bytes)} bytes")
        else:
            print("   WARNING: PIL not available, PNG generation skipped")
            print("   To generate PNG: Install Pillow (pip install Pillow)")
    except Exception as e:
        print(f"   ERROR generating PNG: {e}")
        print("   To generate PNG: Install Pillow (pip install Pillow)")

    print("\n" + "="*60)
    print("Diagram Generation Complete!")
    print("="*60)
    print("\nGenerated Files:")
    print("  - architecture-diagram.drawio (editable in Draw.io)")
    print("  - architecture-diagram.png (1920x1200 PNG image)")
    print("\nTo open in Draw.io:")
    print("  1. Go to https://app.diagrams.net")
    print("  2. Click File > Open > and select the .drawio file")
    print("  3. Or upload to your Draw.io instance")


if __name__ == "__main__":
    main()
