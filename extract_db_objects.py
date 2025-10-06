#!/usr/bin/env python3
import csv
import re
from pathlib import Path


def extract_db_objects(sql_content, filename):
    """Extract database object names from SQL content"""
    objects = []

    # Patterns for different object types
    patterns = {
        "PROCEDURE": r"CREATE\s+(?:OR\s+REPLACE\s+)?PROCEDURE\s+(\w+)",
        "FUNCTION": r"CREATE\s+(?:OR\s+REPLACE\s+)?FUNCTION\s+(\w+)",
        "TABLE": r"CREATE\s+TABLE\s+(\w+)",
        "TYPE": r"CREATE\s+(?:OR\s+REPLACE\s+)?TYPE\s+(\w+)",
        "TYPE_BODY": r"CREATE\s+(?:OR\s+REPLACE\s+)?TYPE\s+BODY\s+(\w+)",
        "VIEW": r"CREATE\s+(?:OR\s+REPLACE\s+)?VIEW\s+(\w+)",
        "INDEX": r"CREATE\s+(?:UNIQUE\s+)?INDEX\s+(\w+)",
        "SEQUENCE": r"CREATE\s+SEQUENCE\s+(\w+)",
        "TRIGGER": r"CREATE\s+(?:OR\s+REPLACE\s+)?TRIGGER\s+(\w+)",
        "PACKAGE": r"CREATE\s+(?:OR\s+REPLACE\s+)?PACKAGE\s+(\w+)",
        "PACKAGE_BODY": r"CREATE\s+(?:OR\s+REPLACE\s+)?PACKAGE\s+BODY\s+(\w+)",
    }

    # Remove comments and normalize whitespace
    sql_content = re.sub(r"--.*$", "", sql_content, flags=re.MULTILINE)
    sql_content = re.sub(r"/\*.*?\*/", "", sql_content, flags=re.DOTALL)
    sql_content = re.sub(r"\s+", " ", sql_content)

    for object_type, pattern in patterns.items():
        matches = re.findall(pattern, sql_content, re.IGNORECASE)
        for match in matches:
            objects.append(
                {
                    "filename": filename,
                    "object_type": object_type,
                    "object_name": match.upper(),
                }
            )

    return objects


def main():
    schema_dir = Path(
        "/Users/gokazu/Desktop/code/ora2pg-conv-w-strands/cdk/scripts/schema_sample"
    )
    all_objects = []

    # Process all SQL files
    for sql_file in sorted(schema_dir.glob("*.sql")):
        try:
            with open(sql_file, "r", encoding="utf-8") as f:
                content = f.read()
                objects = extract_db_objects(content, sql_file.name)
                all_objects.extend(objects)
        except Exception as e:
            print(f"Error processing {sql_file}: {e}")

    # Write to CSV
    csv_file = "/Users/gokazu/Desktop/code/ora2pg-conv-w-strands/db_objects_summary.csv"
    with open(csv_file, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(
            f, fieldnames=["filename", "object_type", "object_name"]
        )
        writer.writeheader()
        writer.writerows(all_objects)

    print(f"Extracted {len(all_objects)} database objects to {csv_file}")

    # Print summary by type
    type_counts = {}
    for obj in all_objects:
        obj_type = obj["object_type"]
        type_counts[obj_type] = type_counts.get(obj_type, 0) + 1

    print("\nSummary by object type:")
    for obj_type, count in sorted(type_counts.items()):
        print(f"  {obj_type}: {count}")


if __name__ == "__main__":
    main()
