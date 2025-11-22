# Dell VxRail HCI Platform - Architecture Diagram

## Current Status

✅ **Draw.io Source File:** `architecture-diagram.drawio` (complete)
⚠️ **PNG Export:** `architecture-diagram.png` (needs export - see instructions below)

## Export Instructions

### Step 1: Open Draw.io
- Visit https://app.diagrams.net OR install Draw.io Desktop
- Open `architecture-diagram.drawio` from this directory

### Step 2: Verify Diagram Components

Ensure the diagram includes all required components (see DIAGRAM_REQUIREMENTS.md):

**Management Layer:**
- ✓ VMware vCenter Server
- ✓ Dell VxRail Manager

**VxRail Cluster:**
- ✓ VxRail E560 nodes (4-8 nodes shown)
- ✓ Per-node specs: Dual Xeon, 768GB RAM, NVMe storage
- ✓ ESXi hypervisor on each node

**Storage Layer (vSAN):**
- ✓ vSAN distributed datastore
- ✓ RAID-5 erasure coding (FTT=1)
- ✓ Deduplication/compression features

**Network Infrastructure:**
- ✓ Dell PowerSwitch ToR switches (redundant pair)
- ✓ 25GbE connections to nodes
- ✓ VLAN segmentation (Management, vMotion, vSAN, VM Networks)

**VM Workloads:**
- ✓ Database servers, app servers, web servers

### Step 3: Export to PNG

1. **Select All Elements** (Ctrl+A / Cmd+A)
2. **File → Export as → PNG**
3. **Export Settings:**
   - **Zoom:** 100%
   - **Border Width:** 10 pixels
   - **Transparent Background:** ✓ Checked
   - **Include a copy of my diagram:** ✗ Unchecked
4. **Click Export**
5. **Save as:** `architecture-diagram.png` (in this directory)

### Step 4: Replace Placeholder

- Delete `architecture-diagram.png.txt` (placeholder file)
- Save your exported PNG in its place

### Step 5: Regenerate Documents

```bash
cd /mnt/c/projects/wsl/eof-tools/converters/presales/scripts
python3 solution-presales-converter.py \
  --path /mnt/c/projects/wsl/solutions/solutions/dell/cloud/vxrail-hci \
  --force
```

## Architecture Summary

**Dell VxRail HCI Platform** provides hyperconverged infrastructure combining:
- **Compute:** Dell VxRail nodes with VMware ESXi
- **Storage:** VMware vSAN all-flash distributed storage
- **Network:** Dell PowerSwitch 25GbE fabric
- **Management:** Integrated vCenter + VxRail Manager

**Key Features:**
- 4-16 node elastic clusters
- VMware vSphere + vSAN integration
- Automated lifecycle management
- Built-in high availability (HA) and fault tolerance (FT)

**Typical Use Cases:**
- Virtual desktop infrastructure (VDI)
- Database consolidation
- Private cloud infrastructure
- Development/test environments

## Dell/VMware Icons

**Required Icons:**
- Dell VxRail logo
- VMware vSphere logo
- VMware vSAN icon
- Dell PowerSwitch icon
- ESXi hypervisor icon

**Icon Resources:**
- Dell EMC Icons: https://www.dell.com/learn/us/en/uscorp1/design-resources
- VMware Brand: https://www.vmware.com/brand.html

## Tips

**For Presentation Quality:**
- Export at 200% zoom for sharper images
- Adjust border to 20px for higher zoom

**For Documentation:**
- 100% zoom is ideal for Word/PDF
- 10px border provides good spacing

---

**Last Updated:** November 22, 2025
**Diagram Version:** 1.0
**Status:** Draw.io complete, PNG export pending
