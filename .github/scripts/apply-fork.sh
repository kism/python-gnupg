#!/usr/bin/env bash
# Apply the fork's typing/packaging changes on top of an upstream checkout.
# Expects fork files saved in /tmp/fork-files (see merge-original.yml).
set -euo pipefail

# Restore fork-specific files
mkdir -p gnupg
# -T: copy into .github itself, not nested as .github/.github
cp -rT /tmp/fork-files/.github .github
cp /tmp/fork-files/gnupg/__init__.pyi gnupg/
cp /tmp/fork-files/gnupg/py.typed gnupg/
cp /tmp/fork-files/README_TYPED.rst . || true

# Remove undesired upstream workflow
rm -f .github/workflows/python-package.yml

# Rename gnupg.py to gnupg/__init__.py (package layout)
if [ -f gnupg.py ]; then
  mv gnupg.py gnupg/__init__.py
fi

# Update setup.cfg: py_modules → packages with package_data
sed -i '/^py_modules = gnupg$/{
    s/^py_modules = gnupg$/packages = gnupg\npackage_dir =\n    = .\n\n[options.package_data]\ngnupg = py.typed, *.pyi/
}' setup.cfg

# Update .gitignore
grep -qxF '*.egg-info' .gitignore || echo '*.egg-info' >> .gitignore
grep -qxF '.coverage' .gitignore || echo '.coverage' >> .gitignore
sed -i '/^$/d' .gitignore && printf '\n' >> .gitignore
