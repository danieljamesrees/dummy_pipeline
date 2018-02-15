#!/bin/sh

echo "dummy_repo_a was manually triggered with the secret ${SECRET_SAUCE}"
apt-get update && apt-get install --yes git
git clone input_repo output_repo
cd output_repo
echo >> README.md
echo "manual_trigger running at $(date -R)" >> README.md
git config user.name "Dummy"
git config user.email "dummy@ci"
git add README.md
git commit -m "Update date."
exit ((return_code))
