"""Build a clean upload candidate; never include the reference addon or tests."""
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile

root = Path(__file__).resolve().parents[1]
manifest = (root / "PBsSuperStar.addon").read_text()
version = next(line.split(":", 1)[1].strip() for line in manifest.splitlines() if line.startswith("## Version:"))
output = root / "dist" / f"PBsSuperStar-{version}.zip"
output.parent.mkdir(exist_ok=True)
files = ["PBsSuperStar.addon", "Data.lua", "UI.lua", "PBsSuperStar.lua", "README.md"]
with ZipFile(output, "w", ZIP_DEFLATED) as archive:
    for name in files:
        archive.write(root / name, "PBsSuperStar/" + name)
print(output)
