#!/usr/bin/env python3
"""Convert Excel files to CSV format, replacing ssconvert functionality"""

import pandas as pd
import sys
import os

def convert_excel_to_csv(excel_file, output_prefix):
    """Convert all sheets in an Excel file to separate CSV files"""
    try:
        # Read all sheets from the Excel file
        excel_data = pd.read_excel(excel_file, sheet_name=None, engine='openpyxl')

        sheets_converted = 0
        for sheet_name, df in excel_data.items():
            # Create output filename: prefix-SheetName.csv
            output_file = f"{output_prefix}-{sheet_name}.csv"

            # Write to CSV
            df.to_csv(output_file, index=False, encoding='utf-8')
            sheets_converted += 1
            print(f"Converted sheet '{sheet_name}' to {output_file}")

        return sheets_converted
    except Exception as e:
        print(f"Error converting {excel_file}: {e}", file=sys.stderr)
        return 0

if __name__ == "__main__":
    # Change to sheets directory
    os.chdir('/Users/vikas.naidu/code/rzp/ifsc/scraper/scripts/sheets')

    # Convert RTGS file
    print("Converting RTGS file...")
    rtgs_count = convert_excel_to_csv('RTGEB0815.xlsx', 'RTGS')
    print(f"Converted {rtgs_count} sheets from RTGS file")

    # Convert NEFT file
    print("\nConverting NEFT file...")
    neft_count = convert_excel_to_csv('68774.xlsx', 'NEFT')
    print(f"Converted {neft_count} sheets from NEFT file")

    print(f"\nTotal: {rtgs_count + neft_count} sheets converted")
