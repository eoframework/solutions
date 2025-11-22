# Dell PowerSwitch Datacenter Networking - Architecture Diagram

## Current Status

✅ **Draw.io Source File:** `architecture-diagram.drawio` (complete)
⚠️ **PNG Export:** `architecture-diagram.png` (needs export)

## Export Instructions

### Step 1: Open Draw.io
- https://app.diagrams.net or Draw.io Desktop
- Open `architecture-diagram.drawio`

### Step 2: Verify Leaf-Spine Topology

**Spine Layer (Top):**
- ✓ Dell PowerSwitch S5232F-ON spine switches (2-4 units)
- ✓ 100GbE QSFP28 ports
- ✓ OSPF/BGP routing
- ✓ ECMP load balancing

**Leaf Layer (Middle):**
- ✓ Dell PowerSwitch S5248F-ON leaf switches (6-20 units)
- ✓ 48x 25GbE SFP28 ports (server connectivity)
- ✓ 6x 100GbE QSFP28 uplinks (to spine)
- ✓ VLT pairs (2 leaf switches bonded for HA)

**Server Layer (Bottom):**
- ✓ Compute servers (dual 25GbE NICs)
- ✓ Storage servers (25GbE or 100GbE)
- ✓ LACP bonding for redundancy

**Network Services (Side/Labels):**
- ✓ VLANs (Management, Production, Storage, vMotion)
- ✓ VXLAN overlay (optional)
- ✓ OS10 / SONiC labels

**Monitoring (Corner):**
- ✓ Dell OpenManage Enterprise
- ✓ sFlow/NetFlow monitoring
- ✓ Grafana dashboards

### Step 3: Export PNG

1. Select All (Ctrl+A)
2. File → Export as → PNG
3. Settings:
   - Zoom: 100%
   - Border: 10px
   - Transparent: ✓
4. Save as `architecture-diagram.png`

### Step 4: Regenerate Documents

```bash
cd /mnt/c/projects/wsl/eof-tools/converters/presales/scripts
python3 solution-presales-converter.py \
  --path /mnt/c/projects/wsl/solutions/solutions/dell/network/powerswitch-datacenter \
  --force
```

## Leaf-Spine Architecture

**Topology:** Clos network (3-hop maximum)

**East-West Traffic (Server-to-Server):**
- Source server → Leaf (25GbE) → Spine (100GbE) → Leaf (100GbE) → Target server (25GbE)
- 3-hop latency: < 1 microsecond

**North-South Traffic (External):**
- Server → Leaf → Spine → Border Leaf → Firewall → Internet

**Redundancy:**
- VLT leaf pairs (active-active)
- ECMP across spine uplinks
- Dual-homed servers (LACP)
- Zero packet loss on link/switch failure

## Network Performance

**Capacity:**
- Spine: 3.2 Tbps per switch
- Leaf: 1.6 Tbps per switch
- Oversubscription: 2:1 (typical) or 1:1 (non-blocking)

**Scalability:**
- Add leaf switches for horizontal growth
- Each leaf supports 48 servers (25GbE) or 12 servers (100GbE)

**OS10 Features:**
- Open networking (Dell Enterprise SONiC)
- BGP/OSPF routing
- VXLAN overlay
- REST API automation

---

**Last Updated:** November 22, 2025
**Status:** Ready for PNG export
