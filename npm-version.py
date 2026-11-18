import json
import os
import sys


def main():
    if len(sys.argv) < 3:
        print("Error: Missing arguments.", file=sys.stderr)
        print("Usage: python3 npm-version.py <VERSION> <ROOT_DIR>", file=sys.stderr)
        sys.exit(1)
        
    v = sys.argv[1]
    rd = sys.argv[2]
    
    for fn in ["package.json", "package-lock.json"]:
        ptfnx = os.path.join(rd, fn)
        if os.path.exists(ptfnx):
            with open(ptfnx, "r+") as f:
                d = json.load(f)
                old_v = d.get("version", "unknown")
                d["version"] = v
                if fn == "package-lock.json" and "packages" in d and "" in d["packages"]:
                    d["packages"][""]["version"] = v
                f.seek(0)
                json.dump(d, f, indent=2)
                f.truncate()
            print(f"Updated: {ptfnx} -> {old_v} -> {v}")


if __name__ == "__main__":
    main()
