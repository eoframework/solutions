#!/usr/bin/env python3
"""
Compute Solution Costs

This script calculates solution costs from cost-breakdown.csv and updates
markdown files with cost summary tables.

Usage:
    # Initialize with sizing (ONE TIME)
    python3 compute-costs.py --path <solution> --initsize [small|medium|large]

    # Calculate from working quantities (SAFE - ANYTIME)
    python3 compute-costs.py --path <solution>

    # Force re-initialization (overwrite customs)
    python3 compute-costs.py --path <solution> --initsize <size> --force

Author: EO Framework
"""

import argparse
import csv
import os
import sys
from decimal import Decimal, ROUND_HALF_UP

def read_cost_breakdown_csv(csv_path):
    """Read cost-breakdown.csv and return as list of dicts."""
    if not os.path.exists(csv_path):
        raise FileNotFoundError(f"Cost breakdown CSV not found: {csv_path}")

    with open(csv_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        return list(reader)

def write_cost_breakdown_csv(csv_path, data):
    """Write cost breakdown data back to CSV."""
    if not data:
        return

    fieldnames = data[0].keys()
    with open(csv_path, 'w', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(data)

def has_custom_quantities(data, size):
    """Check if Qty_Working differs from the specified size."""
    qty_column = f'Qty_{size.capitalize()}'

    for row in data:
        qty_working = row.get('Qty_Working', '').strip()
        qty_reference = row.get(qty_column, '').strip()

        # Skip if either is empty
        if not qty_working or not qty_reference:
            continue

        try:
            if float(qty_working) != float(qty_reference):
                return True
        except ValueError:
            continue

    return False

def show_differences(data, size):
    """Show differences between Qty_Working and reference size."""
    qty_column = f'Qty_{size.capitalize()}'
    differences = []

    for row in data:
        item = row.get('Item', 'Unknown')
        qty_working = row.get('Qty_Working', '').strip()
        qty_reference = row.get(qty_column, '').strip()

        if not qty_working or not qty_reference:
            continue

        try:
            working = float(qty_working)
            reference = float(qty_reference)
            if working != reference:
                differences.append(f"  - {item}: Current={working} → {size.capitalize()}={reference}")
        except ValueError:
            continue

    if differences:
        print("\n".join(differences))

def initialize_quantities(csv_path, size, force=False):
    """Initialize Qty_Working column with specified size."""
    data = read_cost_breakdown_csv(csv_path)
    qty_column = f'Qty_{size.capitalize()}'

    # Check for custom quantities
    if has_custom_quantities(data, size) and not force:
        print(f"\n⚠️  WARNING: Qty_Working contains custom quantities.")
        print(f"Re-initializing with --initsize {size} will overwrite:\n")
        show_differences(data, size)

        confirm = input("\nContinue? This cannot be undone. [y/N]: ")
        if confirm.lower() != 'y':
            print("❌ Aborted. No changes made.")
            sys.exit(0)

    # Copy Qty_{size} → Qty_Working
    for row in data:
        qty_reference = row.get(qty_column, '')
        row['Qty_Working'] = qty_reference
        # Clear calculated fields
        row['Year_1'] = ''
        row['Year_2'] = ''
        row['Year_3'] = ''

    write_cost_breakdown_csv(csv_path, data)
    print(f"✓ Initialized Qty_Working with {size} sizing.")

    return data

def calculate_costs(data):
    """Calculate Year 1/2/3 costs based on Qty_Working and Billing_Cycle."""
    for row in data:
        try:
            qty = Decimal(row.get('Qty_Working', '0') or '0')
            unit_cost = Decimal(row.get('Unit_Cost', '0') or '0')
            billing_cycle = row.get('Billing_Cycle', '').strip()

            subtotal = qty * unit_cost

            if billing_cycle == 'One-Time':
                row['Year_1'] = str(subtotal.quantize(Decimal('0.01'), rounding=ROUND_HALF_UP))
                row['Year_2'] = '0'
                row['Year_3'] = '0'
            elif billing_cycle == 'Monthly':
                annual_cost = subtotal * 12
                row['Year_1'] = str(annual_cost.quantize(Decimal('0.01'), rounding=ROUND_HALF_UP))
                row['Year_2'] = str(annual_cost.quantize(Decimal('0.01'), rounding=ROUND_HALF_UP))
                row['Year_3'] = str(annual_cost.quantize(Decimal('0.01'), rounding=ROUND_HALF_UP))
            elif billing_cycle == 'Annual':
                row['Year_1'] = str(subtotal.quantize(Decimal('0.01'), rounding=ROUND_HALF_UP))
                row['Year_2'] = str(subtotal.quantize(Decimal('0.01'), rounding=ROUND_HALF_UP))
                row['Year_3'] = str(subtotal.quantize(Decimal('0.01'), rounding=ROUND_HALF_UP))
            elif billing_cycle == 'Quarterly':
                annual_cost = subtotal * 4
                row['Year_1'] = str(annual_cost.quantize(Decimal('0.01'), rounding=ROUND_HALF_UP))
                row['Year_2'] = str(annual_cost.quantize(Decimal('0.01'), rounding=ROUND_HALF_UP))
                row['Year_3'] = str(annual_cost.quantize(Decimal('0.01'), rounding=ROUND_HALF_UP))
            else:
                # Unknown billing cycle
                row['Year_1'] = '0'
                row['Year_2'] = '0'
                row['Year_3'] = '0'

        except (ValueError, TypeError, KeyError) as e:
            # Skip rows with invalid data
            row['Year_1'] = '0'
            row['Year_2'] = '0'
            row['Year_3'] = '0'

    return data

def generate_summary_table(data, include_loe=True, loe_year_1=364000):
    """Generate cost summary table by category."""
    # Sum by category
    categories = {}

    for row in data:
        category = row.get('Category', 'Other')
        year_1 = Decimal(row.get('Year_1', '0') or '0')
        year_2 = Decimal(row.get('Year_2', '0') or '0')
        year_3 = Decimal(row.get('Year_3', '0') or '0')

        if category not in categories:
            categories[category] = {'Year_1': Decimal('0'), 'Year_2': Decimal('0'), 'Year_3': Decimal('0')}

        categories[category]['Year_1'] += year_1
        categories[category]['Year_2'] += year_2
        categories[category]['Year_3'] += year_3

    # Build markdown table
    lines = []
    lines.append("| Cost Category | Year 1 | Year 2 | Year 3 | 3-Year Total |")
    lines.append("|---------------|---------|---------|---------|--------------|")

    # Add Professional Services if requested
    if include_loe:
        loe_y1 = Decimal(str(loe_year_1))
        loe_total = loe_y1
        lines.append(f"| Professional Services | ${loe_y1:,.0f} | $0 | $0 | ${loe_total:,.0f} |")

    # Add infrastructure categories
    total_y1 = Decimal('0')
    total_y2 = Decimal('0')
    total_y3 = Decimal('0')

    if include_loe:
        total_y1 += Decimal(str(loe_year_1))

    for category in sorted(categories.keys()):
        y1 = categories[category]['Year_1']
        y2 = categories[category]['Year_2']
        y3 = categories[category]['Year_3']
        total = y1 + y2 + y3

        lines.append(f"| {category} | ${y1:,.0f} | ${y2:,.0f} | ${y3:,.0f} | ${total:,.0f} |")

        total_y1 += y1
        total_y2 += y2
        total_y3 += y3

    # Add total row
    grand_total = total_y1 + total_y2 + total_y3
    lines.append(f"| **TOTAL SOLUTION INVESTMENT** | **${total_y1:,.0f}** | **${total_y2:,.0f}** | **${total_y3:,.0f}** | **${grand_total:,.0f}** |")

    return "\n".join(lines), categories, {'Year_1': total_y1, 'Year_2': total_y2, 'Year_3': total_y3}

def generate_sow_summary_table(data, loe_year_1=364000):
    """Generate simplified SOW summary table (Professional Services + Infrastructure & Materials)."""
    # Calculate infrastructure totals
    infra_y1 = Decimal('0')
    infra_y2 = Decimal('0')
    infra_y3 = Decimal('0')

    for row in data:
        infra_y1 += Decimal(row.get('Year_1', '0') or '0')
        infra_y2 += Decimal(row.get('Year_2', '0') or '0')
        infra_y3 += Decimal(row.get('Year_3', '0') or '0')

    # Professional services (LOE)
    prof_y1 = Decimal(str(loe_year_1))

    # Totals
    total_y1 = prof_y1 + infra_y1
    total_y2 = infra_y2
    total_y3 = infra_y3
    grand_total = total_y1 + total_y2 + total_y3

    lines = []
    lines.append("| Cost Category | Year 1 | Year 2 | Year 3 | 3-Year Total |")
    lines.append("|---------------|---------|---------|---------|--------------|")
    lines.append(f"| Professional Services | ${prof_y1:,.0f} | $0 | $0 | ${prof_y1:,.0f} |")
    lines.append(f"| Infrastructure & Materials | ${infra_y1:,.0f} | ${infra_y2:,.0f} | ${infra_y3:,.0f} | ${infra_y1 + infra_y2 + infra_y3:,.0f} |")
    lines.append(f"| **TOTAL SOLUTION INVESTMENT** | **${total_y1:,.0f}** | **${total_y2:,.0f}** | **${total_y3:,.0f}** | **${grand_total:,.0f}** |")

    return "\n".join(lines)

def update_markdown_file(md_path, summary_table):
    """Update markdown file by replacing content between BEGIN/END markers."""
    if not os.path.exists(md_path):
        print(f"⚠️  Warning: Markdown file not found: {md_path}")
        return False

    with open(md_path, 'r', encoding='utf-8') as f:
        content = f.read()

    begin_marker = "<!-- BEGIN COST_SUMMARY_TABLE -->"
    end_marker = "<!-- END COST_SUMMARY_TABLE -->"

    begin_pos = content.find(begin_marker)
    end_pos = content.find(end_marker)

    if begin_pos == -1 or end_pos == -1:
        print(f"⚠️  Warning: COST_SUMMARY_TABLE markers not found in {os.path.basename(md_path)}")
        return False

    # Replace content between markers
    updated_content = (
        content[:begin_pos + len(begin_marker)] +
        "\n" + summary_table + "\n" +
        content[end_pos:]
    )

    with open(md_path, 'w', encoding='utf-8') as f:
        f.write(updated_content)

    return True

def read_loe_total(presales_path):
    """Read total professional services cost from level-of-effort-estimate.csv."""
    loe_path = os.path.join(presales_path, 'raw', 'level-of-effort-estimate.csv')

    if not os.path.exists(loe_path):
        print(f"⚠️  Warning: LOE file not found, using default $364,000")
        return 364000

    try:
        with open(loe_path, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            total = Decimal('0')

            for row in reader:
                # Look for Total or Cost column
                cost_value = row.get('Total', row.get('Cost', row.get('Subtotal', '0')))
                try:
                    total += Decimal(str(cost_value).replace('$', '').replace(',', '') or '0')
                except (ValueError, TypeError):
                    continue

            return float(total) if total > 0 else 364000
    except Exception as e:
        print(f"⚠️  Warning: Error reading LOE file: {e}, using default $364,000")
        return 364000

def main():
    parser = argparse.ArgumentParser(
        description='Compute solution costs from cost-breakdown.csv',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Initialize with medium sizing
  python3 compute-costs.py --path solutions/aws/cloud/migration --initsize medium

  # Calculate costs from current working quantities
  python3 compute-costs.py --path solutions/aws/cloud/migration

  # Force re-initialization (overwrite customs)
  python3 compute-costs.py --path solutions/aws/cloud/migration --initsize large --force
        """
    )

    parser.add_argument('--path', required=True, help='Path to solution directory')
    parser.add_argument('--initsize', choices=['small', 'medium', 'large'],
                        help='Initialize Qty_Working column with specified size (small/medium/large)')
    parser.add_argument('--force', action='store_true',
                        help='Force re-initialization without confirmation prompt')

    args = parser.parse_args()

    # Resolve paths
    solution_path = os.path.abspath(args.path)
    presales_path = os.path.join(solution_path, 'presales')
    csv_path = os.path.join(presales_path, 'raw', 'cost-breakdown.csv')

    # Validate paths
    if not os.path.exists(solution_path):
        print(f"❌ Error: Solution path not found: {solution_path}")
        sys.exit(1)

    if not os.path.exists(presales_path):
        print(f"❌ Error: Presales directory not found: {presales_path}")
        sys.exit(1)

    if not os.path.exists(csv_path):
        print(f"❌ Error: cost-breakdown.csv not found: {csv_path}")
        print(f"   Expected location: presales/raw/cost-breakdown.csv")
        sys.exit(1)

    # INITIALIZATION MODE
    if args.initsize:
        print(f"\n🔧 Initialization Mode: {args.initsize.capitalize()}")
        data = initialize_quantities(csv_path, args.initsize, args.force)
        data = calculate_costs(data)
        write_cost_breakdown_csv(csv_path, data)

    # CALCULATION MODE (always runs after init or standalone)
    else:
        print(f"\n📊 Calculation Mode")
        data = read_cost_breakdown_csv(csv_path)

        # Check if Qty_Working is populated
        has_working_qty = any(row.get('Qty_Working', '').strip() for row in data)
        if not has_working_qty:
            print("⚠️  Warning: Qty_Working column is empty. Run with --initsize to initialize.")
            print("   Example: python3 compute-costs.py --path . --initsize medium")
            sys.exit(1)

        data = calculate_costs(data)
        write_cost_breakdown_csv(csv_path, data)
        print("✓ Calculated costs from Qty_Working.")

    # Read LOE total
    loe_total = read_loe_total(presales_path)

    # Generate summary tables
    briefing_table, categories, totals = generate_summary_table(data, include_loe=True, loe_year_1=loe_total)
    sow_table = generate_sow_summary_table(data, loe_year_1=loe_total)

    # Update markdown files
    solution_briefing_path = os.path.join(presales_path, 'raw', 'solution-briefing.md')
    statement_of_work_path = os.path.join(presales_path, 'raw', 'statement-of-work.md')

    updated_briefing = update_markdown_file(solution_briefing_path, briefing_table)
    updated_sow = update_markdown_file(statement_of_work_path, sow_table)

    if updated_briefing:
        print(f"✓ Updated solution-briefing.md")
    if updated_sow:
        print(f"✓ Updated statement-of-work.md")

    # Display summary
    print(f"\n💰 Cost Summary:")
    print(f"   Year 1: ${totals['Year_1']:,.0f}")
    print(f"   Year 2: ${totals['Year_2']:,.0f}")
    print(f"   Year 3: ${totals['Year_3']:,.0f}")
    print(f"   3-Year Total: ${totals['Year_1'] + totals['Year_2'] + totals['Year_3']:,.0f}")
    print(f"\n✅ Complete! Cost calculations updated.")

if __name__ == '__main__':
    main()
