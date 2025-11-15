#!/usr/bin/env python3
"""
Generate Azure Virtual WAN Architecture Diagram
Simple 6-8 component diagram showing hub-and-spoke topology
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
import numpy as np

# Create figure and axis
fig, ax = plt.subplots(1, 1, figsize=(16, 10))
ax.set_xlim(0, 10)
ax.set_ylim(0, 10)
ax.axis('off')

# Define colors
color_azure = '#0078D4'
color_hub = '#2E8B57'
color_vnets = '#20B2AA'
color_branch = '#FF6B6B'
color_datacenter = '#FFB84D'
color_firewall = '#FF1744'

# Title
ax.text(5, 9.5, 'Azure Virtual WAN - Unified Global Network Architecture',
        fontsize=18, fontweight='bold', ha='center')
ax.text(5, 9.1, '10 Branch Offices + 2 Data Centers + 3 Azure VNets',
        fontsize=12, ha='center', style='italic', color='gray')

# VIRTUAL WAN HUB US (Center-Left)
hub_us_box = FancyBboxPatch((0.5, 5.5), 2.5, 2.5,
                            boxstyle="round,pad=0.1",
                            edgecolor=color_hub, facecolor='#E8F5E9',
                            linewidth=2.5)
ax.add_patch(hub_us_box)
ax.text(1.75, 7.5, 'Virtual WAN Hub', fontsize=11, fontweight='bold', ha='center')
ax.text(1.75, 7.1, '(US East)', fontsize=10, ha='center', style='italic')
ax.text(1.75, 6.7, '◆ VPN Gateway', fontsize=9, ha='center')
ax.text(1.75, 6.4, '◆ ExpressRoute GW', fontsize=9, ha='center')
ax.text(1.75, 6.1, '◆ Azure Firewall', fontsize=9, ha='center')
ax.text(1.75, 5.8, '◆ Route Tables', fontsize=9, ha='center')

# VIRTUAL WAN HUB EU (Center-Right)
hub_eu_box = FancyBboxPatch((6.8, 5.5), 2.5, 2.5,
                            boxstyle="round,pad=0.1",
                            edgecolor=color_hub, facecolor='#E8F5E9',
                            linewidth=2.5)
ax.add_patch(hub_eu_box)
ax.text(8.05, 7.5, 'Virtual WAN Hub', fontsize=11, fontweight='bold', ha='center')
ax.text(8.05, 7.1, '(EU West)', fontsize=10, ha='center', style='italic')
ax.text(8.05, 6.7, '◆ VPN Gateway', fontsize=9, ha='center')
ax.text(8.05, 6.4, '◆ ExpressRoute GW', fontsize=9, ha='center')
ax.text(8.05, 6.1, '◆ Azure Firewall', fontsize=9, ha='center')
ax.text(8.05, 5.8, '◆ Route Tables', fontsize=9, ha='center')

# Hub-to-Hub Connection (Backbone)
arrow_hub = FancyArrowPatch((3.2, 6.75), (6.6, 6.75),
                           arrowstyle='<->', mutation_scale=25,
                           color=color_azure, linewidth=2.5, linestyle='--')
ax.add_patch(arrow_hub)
ax.text(4.9, 6.95, 'Backbone', fontsize=9, ha='center',
        bbox=dict(boxstyle='round', facecolor='white', edgecolor='gray', alpha=0.8))

# BRANCH OFFICES (Left side - 6 branches)
branch_positions = [
    (0.3, 3.5, 'Branch 1\n(HQ)'),
    (0.3, 2.5, 'Branch 2\n(Remote)'),
    (0.3, 1.5, 'Branch 3\n(Regional)'),
    (0.3, 0.5, 'Branch 4\n(Site)'),
]

eu_branch_positions = [
    (9.2, 3.5, 'Branch 5\n(EU)'),
    (9.2, 2.5, 'Branch 6\n(EU)'),
]

# Draw US branches
for x, y, label in branch_positions:
    branch_box = FancyBboxPatch((x, y-0.3), 1.2, 0.6,
                               boxstyle="round,pad=0.05",
                               edgecolor=color_branch, facecolor='#FFEBEE',
                               linewidth=1.5)
    ax.add_patch(branch_box)
    ax.text(x+0.6, y, label, fontsize=8, ha='center', va='center', fontweight='bold')

    # VPN connections to US Hub
    arrow = FancyArrowPatch((x+1.2, y), (0.5, 6),
                           arrowstyle='->', mutation_scale=15,
                           color=color_branch, linewidth=1.5, alpha=0.6)
    ax.add_patch(arrow)

# Draw EU branches
for x, y, label in eu_branch_positions:
    branch_box = FancyBboxPatch((x, y-0.3), 1.2, 0.6,
                               boxstyle="round,pad=0.05",
                               edgecolor=color_branch, facecolor='#FFEBEE',
                               linewidth=1.5)
    ax.add_patch(branch_box)
    ax.text(x+0.6, y, label, fontsize=8, ha='center', va='center', fontweight='bold')

    # VPN connections to EU Hub
    arrow = FancyArrowPatch((x, y), (8.3, 5.5),
                           arrowstyle='->', mutation_scale=15,
                           color=color_branch, linewidth=1.5, alpha=0.6)
    ax.add_patch(arrow)

# Add more branches notation
ax.text(0.9, 0.15, '+ 4 more\nbranches', fontsize=7, ha='center',
        style='italic', color='gray')
ax.text(9.8, 0.15, '+ 2 more\nbranches', fontsize=7, ha='center',
        style='italic', color='gray')

# AZURE VNETS (Upper center)
vnet_positions = [
    (0.5, 8.5, 'US VNet 1\n(Apps)'),
    (2.5, 8.5, 'US VNet 2\n(Data)'),
    (4.5, 8.5, 'EU VNet\n(GDPR)'),
]

for x, y, label in vnet_positions:
    vnet_box = FancyBboxPatch((x, y-0.35), 1.5, 0.7,
                             boxstyle="round,pad=0.05",
                             edgecolor=color_vnets, facecolor='#E0F2F1',
                             linewidth=1.5)
    ax.add_patch(vnet_box)
    ax.text(x+0.75, y, label, fontsize=8, ha='center', va='center', fontweight='bold')

# VNet connections to Hubs
# US VNets to US Hub
arrow_vnet1 = FancyArrowPatch((1.25, 8.15), (1.5, 8.0),
                             arrowstyle='<->', mutation_scale=15,
                             color=color_vnets, linewidth=1.5)
ax.add_patch(arrow_vnet1)

arrow_vnet2 = FancyArrowPatch((3.25, 8.15), (2.3, 8.0),
                             arrowstyle='<->', mutation_scale=15,
                             color=color_vnets, linewidth=1.5)
ax.add_patch(arrow_vnet2)

# EU VNet to EU Hub
arrow_vnet3 = FancyArrowPatch((5.25, 8.15), (7.5, 7.5),
                             arrowstyle='<->', mutation_scale=15,
                             color=color_vnets, linewidth=1.5)
ax.add_patch(arrow_vnet3)

# DATA CENTERS (Right side)
dc_positions = [
    (9.2, 4.8, 'Data Center 1\n(On-Prem)'),
    (9.2, 3.8, 'Data Center 2\n(DR Site)'),
]

for x, y, label in dc_positions:
    dc_box = FancyBboxPatch((x, y-0.35), 1.2, 0.7,
                           boxstyle="round,pad=0.05",
                           edgecolor=color_datacenter, facecolor='#FFF8E1',
                           linewidth=1.5)
    ax.add_patch(dc_box)
    ax.text(x+0.6, y, label, fontsize=8, ha='center', va='center', fontweight='bold')

# ExpressRoute connections (US Hub to DC1, EU Hub to DC2)
arrow_er1 = FancyArrowPatch((3.0, 6.2), (9.1, 4.8),
                           arrowstyle='<->', mutation_scale=20,
                           color=color_datacenter, linewidth=2, linestyle=':',
                           label='ExpressRoute')
ax.add_patch(arrow_er1)

arrow_er2 = FancyArrowPatch((7.3, 6.2), (9.1, 3.8),
                           arrowstyle='<->', mutation_scale=20,
                           color=color_datacenter, linewidth=2, linestyle=':')
ax.add_patch(arrow_er2)

# Legend box
legend_y = 0.8
ax.text(5, legend_y + 0.8, 'Legend', fontsize=10, fontweight='bold', ha='center')

# VPN connection label
ax.plot([4.5, 5.2], [legend_y + 0.4, legend_y + 0.4], 'o-',
        color=color_branch, linewidth=1.5, markersize=5)
ax.text(5.8, legend_y + 0.4, 'VPN Connections (10 branches)', fontsize=8, va='center')

# ExpressRoute label
ax.plot([4.5, 5.2], [legend_y, legend_y], 'o:', color=color_datacenter,
        linewidth=2, markersize=5)
ax.text(5.8, legend_y, 'ExpressRoute (2 circuits)', fontsize=8, va='center')

# Add statistics box
stats_text = (
    'Key Components (7-8 Total)\n'
    '• 2 Virtual WAN Hubs (US + EU)\n'
    '• 10 Branch VPN Connections\n'
    '• 2 ExpressRoute Circuits\n'
    '• 3 Azure VNets (Direct Links)\n'
    '• 2 Azure Firewalls (Premium)\n'
    '• Automatic Hub-to-Hub Failover'
)
ax.text(5, -0.8, stats_text, fontsize=9, ha='center',
        bbox=dict(boxstyle='round', facecolor='#E3F2FD',
                 edgecolor=color_azure, linewidth=1.5, pad=0.5))

# Add metrics
metrics_text = (
    'Metrics: <100ms latency • 99.5%+ uptime • Centralized security\n'
    'Cost: $128K Year 1 (net) • ROI: 40% vs MPLS • Scalable to 20k+ sites'
)
ax.text(5, -1.5, metrics_text, fontsize=8, ha='center', style='italic', color='#444')

# Add footer
ax.text(5, -1.95, 'Azure Virtual WAN Solution - Global Network Unification',
        fontsize=9, ha='center', fontweight='bold', color=color_azure)

plt.tight_layout()
plt.savefig('/mnt/c/projects/wsl/solutions/solutions/azure/network/virtual-wan-global/presales/architecture-diagram.png',
            dpi=300, bbox_inches='tight', facecolor='white')
print("Architecture diagram saved: architecture-diagram.png")

# Also create a data flow diagram showing the 5 main connections
fig2, ax2 = plt.subplots(1, 1, figsize=(14, 10))
ax2.set_xlim(0, 10)
ax2.set_ylim(0, 10)
ax2.axis('off')

# Title
ax2.text(5, 9.5, 'Azure Virtual WAN - Traffic Flows & Connections',
         fontsize=16, fontweight='bold', ha='center')
ax2.text(5, 9.1, '5 Core Connection Patterns in Hub-and-Spoke Architecture',
         fontsize=11, ha='center', style='italic', color='gray')

# Draw hub in center
hub_center = FancyBboxPatch((3.5, 4.5), 3, 2,
                           boxstyle="round,pad=0.15",
                           edgecolor=color_hub, facecolor='#E8F5E9',
                           linewidth=3)
ax2.add_patch(hub_center)
ax2.text(5, 5.8, 'Virtual WAN Hubs', fontsize=13, fontweight='bold', ha='center')
ax2.text(5, 5.3, '(US + EU)', fontsize=10, ha='center', style='italic')
ax2.text(5, 4.9, 'Hub-to-Hub Backbone', fontsize=9, ha='center')

# Connection 1: Branch VPN to Hub
branch_left = FancyBboxPatch((0.3, 5), 1.2, 1,
                            boxstyle="round,pad=0.05",
                            edgecolor=color_branch, facecolor='#FFEBEE',
                            linewidth=2)
ax2.add_patch(branch_left)
ax2.text(0.9, 5.5, 'Branch\nOffices\n(10x)', fontsize=9, ha='center', va='center', fontweight='bold')

arrow1 = FancyArrowPatch((1.5, 5.5), (3.5, 5.5),
                        arrowstyle='<->', mutation_scale=20,
                        color=color_branch, linewidth=2.5)
ax2.add_patch(arrow1)
ax2.text(2.5, 5.8, 'Flow 1: VPN\nTunnels', fontsize=8, ha='center',
        bbox=dict(boxstyle='round', facecolor='white', alpha=0.9))

# Connection 2: Azure VNets to Hub
vnets_top = FancyBboxPatch((3.5, 7.5), 3, 0.8,
                          boxstyle="round,pad=0.05",
                          edgecolor=color_vnets, facecolor='#E0F2F1',
                          linewidth=2)
ax2.add_patch(vnets_top)
ax2.text(5, 7.9, 'Azure VNets (3x) - Direct Integration', fontsize=9, ha='center', fontweight='bold')

arrow2 = FancyArrowPatch((5, 7.5), (5, 6.5),
                        arrowstyle='<->', mutation_scale=20,
                        color=color_vnets, linewidth=2.5)
ax2.add_patch(arrow2)
ax2.text(5.5, 7.0, 'Flow 2:\nVNet Links', fontsize=8, ha='center',
        bbox=dict(boxstyle='round', facecolor='white', alpha=0.9))

# Connection 3: Data Center ExpressRoute
dc_right = FancyBboxPatch((8.5, 4.5), 1.2, 2,
                         boxstyle="round,pad=0.05",
                         edgecolor=color_datacenter, facecolor='#FFF8E1',
                         linewidth=2)
ax2.add_patch(dc_right)
ax2.text(9.1, 5.5, 'Data\nCenters\n(2x)', fontsize=9, ha='center', va='center', fontweight='bold')

arrow3 = FancyArrowPatch((6.5, 5.5), (8.5, 5.5),
                        arrowstyle='<->', mutation_scale=20,
                        color=color_datacenter, linewidth=2.5, linestyle=':')
ax2.add_patch(arrow3)
ax2.text(7.5, 5.8, 'Flow 3: ExpressRoute\n(Dual Circuits)', fontsize=8, ha='center',
        bbox=dict(boxstyle='round', facecolor='white', alpha=0.9))

# Connection 4: Branch-to-Branch via Hub
branch_bottom = FancyBboxPatch((3.5, 2.5), 3, 0.8,
                              boxstyle="round,pad=0.05",
                              edgecolor=color_branch, facecolor='#FFEBEE',
                              linewidth=2)
ax2.add_patch(branch_bottom)
ax2.text(5, 2.9, 'Branch ↔ Branch Connectivity', fontsize=9, ha='center', fontweight='bold')

arrow4_left = FancyArrowPatch((1.5, 5.0), (4.5, 3.3),
                             arrowstyle='->', mutation_scale=15,
                             color=color_branch, linewidth=1.5, alpha=0.6)
ax2.add_patch(arrow4_left)

arrow4_right = FancyArrowPatch((5.5, 3.3), (8.5, 5.0),
                              arrowstyle='->', mutation_scale=15,
                              color=color_branch, linewidth=1.5, alpha=0.6)
ax2.add_patch(arrow4_right)

ax2.text(5, 3.6, 'Flow 4: Auto Routing', fontsize=8, ha='center',
        bbox=dict(boxstyle='round', facecolor='white', alpha=0.9))

# Connection 5: All traffic through Firewall
firewall_box = FancyBboxPatch((4, 1.3), 2, 0.6,
                             boxstyle="round,pad=0.05",
                             edgecolor=color_firewall, facecolor='#FFEBEE',
                             linewidth=2)
ax2.add_patch(firewall_box)
ax2.text(5, 1.6, '◆ Azure Firewall Premium', fontsize=9, ha='center', fontweight='bold')

# Firewall connections
for source_x, source_y in [(0.9, 5.5), (5, 7.5), (9.1, 5.5)]:
    arrow_fw = FancyArrowPatch((source_x, source_y-0.3), (5, 1.9),
                              arrowstyle='->', mutation_scale=12,
                              color=color_firewall, linewidth=1, alpha=0.3, linestyle='--')
    ax2.add_patch(arrow_fw)

ax2.text(6.5, 1.6, 'Flow 5: Security', fontsize=8, ha='center',
        bbox=dict(boxstyle='round', facecolor='white', alpha=0.9))

# Add flow descriptions
flow_text = (
    '1. Branch VPN: 10 sites connect via redundant VPN tunnels to nearest hub\n'
    '2. VNet Links: 3 Azure VNets integrated directly with no manual peering\n'
    '3. ExpressRoute: 2 data center circuits provide private on-prem connectivity\n'
    '4. Branch-to-Branch: Automatic routing via hub (no direct site-to-site)\n'
    '5. Firewall Inspection: All traffic processed through Azure Firewall Premium'
)
ax2.text(5, 0.5, flow_text, fontsize=9, ha='center',
        bbox=dict(boxstyle='round', facecolor='#F5F5F5',
                 edgecolor='#999', linewidth=1, pad=0.8))

plt.tight_layout()
plt.savefig('/mnt/c/projects/wsl/solutions/solutions/azure/network/virtual-wan-global/presales/traffic-flows-diagram.png',
            dpi=300, bbox_inches='tight', facecolor='white')
print("Traffic flows diagram saved: traffic-flows-diagram.png")

print("\nDiagrams generated successfully!")
print("Files created:")
print("  1. architecture-diagram.png")
print("  2. traffic-flows-diagram.png")
