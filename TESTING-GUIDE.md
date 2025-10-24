# Testing Guide - Git-Based Publishing

## ✅ Prerequisites Complete

- [x] PUBLIC_ASSETS_TOKEN configured
- [x] All 35 solutions are "In Review" status (will be published)
- [x] Workflows and scripts created

---

## 🧪 Test 1: Single Solution (Recommended First)

### Run Test

**Option A: Using GitHub Web Interface**

1. Go to: https://github.com/eoframework/solutions/actions
2. Click **"Publish Solutions to Public Assets"** workflow
3. Click **"Run workflow"** button (top right)
4. Fill in:
   - **publish_mode:** `single`
   - **solution_path:** `solutions/aws/ai/intelligent-document-processing`
5. Click **"Run workflow"** (green button)

**Option B: Using GitHub CLI**

```bash
gh workflow run publish-solutions-folders.yml \
  -f publish_mode=single \
  -f solution_path=solutions/aws/ai/intelligent-document-processing
```

### Monitor Progress

```bash
# Watch live
gh run watch

# Or check status
gh run list --workflow=publish-solutions-folders.yml
```

### Verify Results

**1. Check Workflow Completed**
- Go to: https://github.com/eoframework/solutions/actions
- Latest run should be ✅ green

**2. Check Solution in public-assets**
- Go to: https://github.com/eoframework/public-assets/tree/main/solutions/aws/ai/intelligent-document-processing
- You should see:
  - README.md
  - metadata.yml
  - CHANGELOG.md
  - presales/
  - delivery/

**3. Check Git Tag Created**
```bash
# Clone public-assets (if not already)
git clone https://github.com/eoframework/public-assets.git
cd public-assets

# List tags
git tag | grep "aws/ai/intelligent-document-processing"

# Should show: aws/ai/intelligent-document-processing-v1.0.0
```

**4. Check Catalog Updated**
- View: https://raw.githubusercontent.com/eoframework/public-assets/main/catalog/solutions.csv
- Should contain AWS AI solution with Git URLs

---

## 🧪 Test 2: Test User Download

### Test Sparse Checkout

```bash
# In a different directory
cd /tmp

# Clone with sparse checkout
git clone --filter=blob:none --sparse https://github.com/eoframework/public-assets.git
cd public-assets

# Checkout solution
git sparse-checkout set solutions/aws/ai/intelligent-document-processing

# Verify files
ls -la solutions/aws/ai/intelligent-document-processing/
cat solutions/aws/ai/intelligent-document-processing/README.md
```

### Test Download Script

```bash
cd /tmp

# Download the helper script
curl -O https://raw.githubusercontent.com/eoframework/public-assets/main/download-solution.sh
chmod +x download-solution.sh

# Download solution
./download-solution.sh aws/ai/intelligent-document-processing

# Verify
ls -la intelligent-document-processing/
```

---

## 🚀 Test 3: Publish All Solutions

**⚠️ Only run this after Test 1 succeeds!**

### Run Full Publish

**Option A: GitHub Web Interface**

1. Go to: https://github.com/eoframework/solutions/actions
2. Click **"Publish Solutions to Public Assets"**
3. Click **"Run workflow"**
4. Fill in:
   - **publish_mode:** `all`
5. Click **"Run workflow"**

**Option B: GitHub CLI**

```bash
gh workflow run publish-solutions-folders.yml -f publish_mode=all
```

### Monitor Progress

```bash
gh run watch
```

**Note:** This will publish all 35 solutions. May take 10-15 minutes.

### Verify All Published

```bash
# Clone public-assets
git clone https://github.com/eoframework/public-assets.git
cd public-assets

# Count solutions
find solutions -mindepth 4 -maxdepth 4 -type d | wc -l
# Should show: 35

# List all tags
git tag | wc -l
# Should show: 35 (one per solution)

# View catalog
cat catalog/solutions.csv | wc -l
# Should show: 36 (35 solutions + 1 header)
```

---

## 🧪 Test 4: Automatic Publishing (Push Trigger)

### Make a Small Change

```bash
cd /mnt/c/projects/wsl/solutions

# Update a solution's README
echo "" >> solutions/aws/ai/intelligent-document-processing/README.md
echo "Updated on $(date)" >> solutions/aws/ai/intelligent-document-processing/README.md

# Commit and push
git add solutions/aws/ai/intelligent-document-processing/README.md
git commit -m "Test: Update AWS IDP README"
git push origin main
```

### Verify Auto-Trigger

1. Workflow should automatically trigger
2. Check: https://github.com/eoframework/solutions/actions
3. Should see new run starting
4. Only `aws/ai/intelligent-document-processing` should be published

---

## 🔍 Troubleshooting

### Workflow Fails with "Authentication Error"

**Check:**
```bash
# Verify secret exists
gh secret list | grep PUBLIC_ASSETS_TOKEN
```

**Fix:**
- Re-check token in GitHub Secrets
- Regenerate token if needed
- See: `support/docs/SETUP-GITHUB-TOKEN.md`

---

### Workflow Succeeds But No Files in public-assets

**Check workflow logs:**
1. Go to failed run
2. Expand "Sync solution folder to public-assets"
3. Look for error messages

**Common causes:**
- Solution status is "Draft" (check metadata.yml)
- Metadata validation failed
- Path typo in solution_path

**Debug locally:**
```bash
python3 support/tools/sync-solution.py \
  --solution solutions/aws/ai/intelligent-document-processing \
  --target /tmp/test-public-assets \
  --create-tag

# Check output
ls -la /tmp/test-public-assets/solutions/
```

---

### Tag Not Created

**Check:**
- Look in workflow logs for "Created and pushed tag"
- Verify version in metadata.yml is valid semver (e.g., 1.0.0)

**Manual tag creation:**
```bash
cd public-assets
git tag aws/ai/intelligent-document-processing-v1.0.0
git push origin aws/ai/intelligent-document-processing-v1.0.0
```

---

### Catalog Not Updated

**Check:**
```bash
# View catalog in public-assets
curl https://raw.githubusercontent.com/eoframework/public-assets/main/catalog/solutions.csv
```

**Manual catalog update:**
```bash
cd solutions
python3 support/tools/export-templates-csv.py --output-type public --git-based

# Copy to public-assets
cp support/exports/solutions.csv ../public-assets/catalog/
cd ../public-assets
git add catalog/solutions.csv
git commit -m "Update catalog"
git push
```

---

## ✅ Success Criteria

After all tests pass, you should have:

- [x] 35 solutions published to public-assets
- [x] 35 Git tags created (one per solution v1.0.0)
- [x] Catalog CSV with 35 entries + Git URLs
- [x] All solutions browsable on GitHub
- [x] Sparse checkout working
- [x] Download script working
- [x] Automatic publishing on push working

---

## 📊 Expected Results Summary

| Item | Expected Value |
|------|----------------|
| **Solutions Published** | 35 |
| **Git Tags** | 35 (format: provider/category/solution-v1.0.0) |
| **Catalog Entries** | 35 + 1 header row |
| **Repository Size** | ~8-10 MB |
| **Published Statuses** | In Review (35), Active (0), Beta (0) |
| **Excluded** | Draft solutions only |

---

## 🎯 Next Steps After Testing

1. ✅ Verify all solutions published correctly
2. ✅ Test user download workflows
3. ✅ Update website to use new catalog CSV
4. ✅ Announce to users/community
5. ✅ Monitor for issues

---

**Ready to start testing!** Begin with Test 1 (single solution).
