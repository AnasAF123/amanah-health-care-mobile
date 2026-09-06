#!/bin/bash
set -e

# Replaces package name for the F-Droid listing if needed
cd ../packages/amanah_healthcare/android/ && grep -rli 'com.amanah.healthcare' * | xargs -i@ sed -i 's/com.amanah.healthcare/com.amanah.healthcare/g' @
