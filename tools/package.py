"""Build a clean upload candidate; never include the reference addon or tests."""
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile

root = Path(__file__).resolve().parents[1]
manifest = (root / "PBsUltraDetailedStats.addon").read_text()
version = next(line.split(":", 1)[1].strip() for line in manifest.splitlines() if line.startswith("## Version:"))
output = root / "dist" / f"PBsUltraDetailedStats-{version}.zip"
output.parent.mkdir(exist_ok=True)
files = ["PBsUltraDetailedStats.addon", "Data.lua", "UI.lua", "PBsUltraDetailedStats.lua", "README.md"]
with ZipFile(output, "w", ZIP_DEFLATED) as archive:
    for name in files:
        archive.write(root / name, "PBsUltraDetailedStats/" + name)
print(output)
