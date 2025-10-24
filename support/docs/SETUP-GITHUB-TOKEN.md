# Setting Up PUBLIC_ASSETS_TOKEN for GitHub Actions

This guide walks you through creating and configuring the `PUBLIC_ASSETS_TOKEN` secret needed for the publishing workflow.

---

## Quick Summary

1. Create a GitHub Personal Access Token (PAT) with `repo` and `workflow` scopes
2. Add it as a repository secret named `PUBLIC_ASSETS_TOKEN` in `eoframework/solutions`
3. Verify it has write access to `eoframework/public-assets`

---

## Step-by-Step Instructions

### **Step 1: Create Personal Access Token**

#### 1.1 Navigate to GitHub Token Settings

```
https://github.com/settings/tokens
```

Or manually:
- Click your **profile picture** (top-right corner)
- Click **Settings**
- Scroll to **Developer settings** (bottom of left sidebar)
- Click **Personal access tokens** → **Tokens (classic)**

#### 1.2 Generate New Token

- Click **Generate new token** button
- Select **Generate new token (classic)**
- Authenticate if prompted (password or 2FA)

#### 1.3 Configure Token

Fill in the following:

**Note (Description):**
```
EO Framework - Public Assets Publishing
```

**Expiration:**
```
No expiration (recommended for automation)
```
Or select appropriate timeframe (requires rotation when expired)

**Select scopes (permissions):**

✅ **repo** - Full control of private repositories
  - ✅ repo:status
  - ✅ repo_deployment
  - ✅ public_repo
  - ✅ repo:invite
  - ✅ security_events

✅ **workflow** - Update GitHub Action workflows (optional but recommended)

❌ Other scopes are NOT needed

#### 1.4 Generate and Copy Token

- Click **Generate token** at the bottom
- **⚠️ CRITICAL:** Copy the token immediately!
- Token format: `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` (40 characters after `ghp_`)
- **You won't be able to see it again!**

**Save it securely temporarily** (you'll use it in next step)

---

### **Step 2: Test Token (Optional but Recommended)**

Before adding to GitHub, verify the token works:

```bash
# Set token as environment variable
export PUBLIC_ASSETS_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Run verification script
cd /mnt/c/projects/wsl/solutions
./support/tools/verify-token.sh
```

**Expected output:**
```
✅ Token authenticated as: YOUR_USERNAME
✅ Repository access confirmed
✅ Push permission: Enabled ✓
✅ Branch access confirmed (main branch)
✅ Scope 'repo': Present ✓
✅ Scope 'workflow': Present ✓
✅ All checks passed!
```

**If any checks fail:** Review token scopes and regenerate if necessary.

---

### **Step 3: Add Token to GitHub Secrets**

#### 3.1 Navigate to Solutions Repository

```
https://github.com/eoframework/solutions/settings/secrets/actions
```

Or manually:
- Go to `https://github.com/eoframework/solutions`
- Click **Settings** tab (top navigation)
- In left sidebar, expand **Secrets and variables**
- Click **Actions**

#### 3.2 Create New Secret

- Click **New repository secret** button

- Fill in:
  ```
  Name: PUBLIC_ASSETS_TOKEN
  Secret: ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  ```
  (Paste the token from Step 1.4)

- Click **Add secret**

#### 3.3 Verify Secret Added

You should see:
```
PUBLIC_ASSETS_TOKEN
Updated X seconds ago
```

**⚠️ Note:** You cannot view the token value after saving (security feature)

---

### **Step 4: Test the Workflow**

#### 4.1 Manual Test Run (Recommended)

Test with a single solution first:

```bash
# Using GitHub CLI
gh workflow run publish-solutions-folders.yml \
  -f publish_mode=single \
  -f solution_path=solutions/aws/ai/intelligent-document-processing

# Monitor the run
gh run watch
```

Or via GitHub web interface:
1. Go to `https://github.com/eoframework/solutions/actions`
2. Click **Publish Solutions to Public Assets** workflow
3. Click **Run workflow** button
4. Select:
   - **publish_mode:** `single`
   - **solution_path:** `solutions/aws/ai/intelligent-document-processing`
5. Click **Run workflow**

#### 4.2 Check Results

The workflow should:
1. ✅ Detect the solution
2. ✅ Sync folder to public-assets
3. ✅ Create Git tag
4. ✅ Update catalog

**Verify in public-assets:**
```
https://github.com/eoframework/public-assets/tree/main/solutions/aws/ai/intelligent-document-processing
```

---

## Troubleshooting

### Issue: "Error 401 - Bad credentials"

**Cause:** Token is invalid or expired

**Solution:**
1. Regenerate token in GitHub settings
2. Update `PUBLIC_ASSETS_TOKEN` secret with new value

---

### Issue: "Error 403 - Resource not accessible"

**Cause:** Token doesn't have access to `public-assets` repository

**Solution:**
1. Verify token has `repo` scope
2. Check if `eoframework/public-assets` repository exists
3. Ensure your GitHub account has write access to both repos

**Check repository exists:**
```bash
curl -H "Authorization: Bearer $PUBLIC_ASSETS_TOKEN" \
  https://api.github.com/repos/eoframework/public-assets
```

---

### Issue: "Error 404 - Repository not found"

**Cause:** `eoframework/public-assets` repository doesn't exist or token can't access it

**Solution:**
1. Create the `public-assets` repository:
   - Go to `https://github.com/organizations/eoframework/repositories/new`
   - Name: `public-assets`
   - Description: "EO Framework™ Public Solution Assets"
   - Visibility: **Public**
   - Click **Create repository**

2. Initialize with README:
   ```bash
   git clone https://github.com/eoframework/public-assets.git
   cd public-assets
   echo "# EO Framework™ Public Assets" > README.md
   mkdir -p solutions catalog
   git add .
   git commit -m "Initial commit"
   git push origin main
   ```

---

### Issue: "Workflow runs but files aren't published"

**Check workflow logs:**
1. Go to `https://github.com/eoframework/solutions/actions`
2. Click on latest workflow run
3. Expand job steps to see errors

**Common causes:**
- Solution status is not "Active" or "Beta"
- Metadata.yml is invalid
- Git conflicts in public-assets

**Debug locally:**
```bash
# Test sync script directly
python3 support/tools/sync-solution.py \
  --solution solutions/aws/ai/intelligent-document-processing \
  --target /tmp/test-output \
  --create-tag

# Check output
ls -la /tmp/test-output/solutions/
```

---

### Issue: "Token works but push fails"

**Cause:** Branch protection rules or permission issues

**Solution:**
1. Check public-assets branch protection:
   - Go to `https://github.com/eoframework/public-assets/settings/branches`
   - Ensure GitHub Actions can push to `main` branch

2. Add bypass for GitHub Actions:
   - Edit `main` branch protection
   - Under "Allow specified actors to bypass required pull requests"
   - Add: `github-actions[bot]`

---

## Token Security Best Practices

### ✅ Do's

- Store token only in GitHub Secrets (never commit to code)
- Use minimal required scopes (`repo` and optionally `workflow`)
- Set expiration if required by your security policy
- Rotate tokens periodically
- Use different tokens for different workflows if possible

### ❌ Don'ts

- Never commit token to repository
- Don't share token via email/chat
- Don't use personal tokens for multiple organizations
- Don't grant unnecessary scopes (e.g., `delete_repo`, `admin:org`)
- Don't print token in workflow logs (GitHub auto-masks, but still avoid)

---

## Token Rotation

When token expires or needs rotation:

1. **Generate new token** (Step 1)
2. **Update secret:**
   - Go to `https://github.com/eoframework/solutions/settings/secrets/actions`
   - Click **PUBLIC_ASSETS_TOKEN**
   - Click **Update secret**
   - Paste new token value
   - Click **Update secret**
3. **Test workflow** (Step 4)
4. **Revoke old token:**
   - Go to `https://github.com/settings/tokens`
   - Find old token
   - Click **Delete**

---

## Alternative: GitHub App (Advanced)

For production/enterprise use, consider using a GitHub App instead of PAT:

**Benefits:**
- More granular permissions
- Better audit logging
- No user association
- Automatic rotation

**Setup:**
1. Create GitHub App: `https://github.com/organizations/eoframework/settings/apps/new`
2. Grant repository access and permissions
3. Install app on repositories
4. Use app authentication in workflow

**Note:** This is more complex but recommended for production systems.

---

## Quick Reference

| Item | Value |
|------|-------|
| **Secret Name** | `PUBLIC_ASSETS_TOKEN` |
| **Token Type** | Personal Access Token (Classic) |
| **Required Scopes** | `repo` (full), `workflow` (optional) |
| **Added To** | `eoframework/solutions` repository secrets |
| **Used By** | `.github/workflows/publish-solutions-folders.yml` |
| **Gives Access To** | `eoframework/public-assets` repository |
| **Verification Script** | `support/tools/verify-token.sh` |

---

## Support

If you encounter issues:

1. **Check workflow logs:** `https://github.com/eoframework/solutions/actions`
2. **Run verification script:** `./support/tools/verify-token.sh`
3. **Review this guide:** Look for your specific error in Troubleshooting section
4. **Contact:** Open an issue in the repository

---

**Status:** Ready to implement
**Last Updated:** 2025-10-23
**Next Step:** Create token and add to GitHub Secrets
