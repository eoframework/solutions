# Dell Precision AI Workstation - Architecture Diagram

This directory contains the architecture diagram for Dell Precision AI Workstation Infrastructure.

## Current Status

✅ **Draw.io Source File:** `architecture-diagram.drawio` (complete)
⚠️ **PNG Export:** `architecture-diagram.png` (needs export - see instructions below)

## Required: Export PNG from Draw.io

The `.drawio` file is complete and ready to export. Follow these steps to generate the PNG:

### Steps to Export

1. **Open in Draw.io:**
   - Option A: Visit https://app.diagrams.net
   - Option B: Install Draw.io Desktop from https://github.com/jgraph/drawio-desktop/releases
   - Open `architecture-diagram.drawio`

2. **Verify Diagram Content:**
   - ✓ Data Scientists layer (Jupyter, VS Code, TensorBoard, PyTorch/TensorFlow)
   - ✓ Dell Precision 7960 workstations (10 units with specs)
   - ✓ NVIDIA RTX A6000 GPUs (48GB highlighted)
   - ✓ PowerScale F600 shared storage (100TB NAS)
   - ✓ 10GbE network connectivity
   - ✓ Datadog monitoring layer

3. **Export as PNG:**
   - Select all elements (Ctrl+A / Cmd+A)
   - File → Export as → PNG
   - **Settings:**
     - Zoom: 100%
     - Border Width: 10 pixels
     - Transparent Background: ✓ Checked
     - Include a copy of my diagram: ✗ Unchecked (reduces file size)
   - Click "Export"
   - Save as: `architecture-diagram.png` (in this same directory)

4. **Replace Placeholder:**
   - Delete `architecture-diagram.png.txt` (the placeholder file)
   - Save your exported `architecture-diagram.png` in its place

5. **Regenerate Office Documents:**
   ```bash
   cd /mnt/c/projects/wsl/eof-tools/converters/presales/scripts
   python3 solution-presales-converter.py \
     --path /mnt/c/projects/wsl/solutions/solutions/dell/ai/precision-ai-workstation \
     --force
   ```

## Architecture Overview

**Dell Precision AI Workstation Infrastructure**

### Layers

**Compute Layer:**
- 10x Dell Precision 7960 Tower workstations
- Dual Intel Xeon Gold 6430 (64 cores total per workstation)
- 512GB DDR5 RAM per workstation
- 4TB NVMe SSD (7000MB/s read) per workstation
- NVIDIA RTX A6000 48GB GPU per workstation
- Ubuntu 22.04 LTS with CUDA 12.2

**Storage Layer:**
- Dell PowerScale F600 NAS
- 100TB usable capacity
- NFS/SMB file sharing
- 10GbE connectivity

**Network Layer:**
- 10GbE switching infrastructure
- Dedicated storage VLAN
- High-speed data transfer between workstations and PowerScale

**Monitoring:**
- Datadog infrastructure monitoring
- GPU utilization tracking
- Performance metrics and alerting

### Data Flow

1. Data scientists access workstations (SSH/remote desktop)
2. Training datasets stored on PowerScale NAS (centralized repository)
3. Datasets loaded to local NVMe for high-speed training
4. GPU executes PyTorch/TensorFlow training workloads
5. Model checkpoints saved back to PowerScale for team sharing
6. Datadog collects metrics and performance telemetry

## Dell-Specific Icons

If customizing the diagram, use Dell EMC official icons:
- Dell Precision workstation icon
- Dell PowerScale/Isilon storage icon
- Dell PowerSwitch networking icon
- NVIDIA GPU icon (if available)

**Icon Resources:**
- Dell EMC Product Icons: https://www.dell.com/learn/us/en/uscorp1/design-resources
- NVIDIA Branding: https://www.nvidia.com/en-us/about-nvidia/logo-brand-usage/

## Troubleshooting

**Issue: PNG export is blurry**
- Solution: Use 300 DPI in export settings for higher resolution (adjust border to 30px)

**Issue: PNG is too large (file size)**
- Solution: Uncheck "Include a copy of my diagram" in export settings

**Issue: Colors look washed out**
- Solution: Ensure "Transparent Background" is enabled, not "White Background"

## Tips for Presentation

**For PowerPoint/Slides:**
- Export at 200% zoom for crisp presentation quality
- Adjust border width to 20px when using higher zoom

**For Documentation:**
- 100% zoom is sufficient for Word documents
- 10px border provides good spacing

---

**Last Updated:** November 22, 2025
**Diagram Version:** 1.0
**Status:** Draw.io complete, PNG export pending
