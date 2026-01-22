# ADR: GitHub Pages Deployment Configuration

**Date**: 2025-01-24
**Status**: Implemented
**Relates to**: [2025-09-08 - Platform Selection (mdBook + GitHub Pages)](2025-09-08-platform-selection.md)

## Context

After implementing mdBook with GitHub Pages, the site was returning 404 errors despite successful workflow runs. Investigation revealed GitHub Pages was configured to use "Deploy from a branch" with Jekyll processing instead of using the pre-built artifacts from GitHub Actions.

## Problem

- GitHub Pages was set to `build_type: legacy` (Jekyll)
- Source was set to branch `main` from root `/`
- This attempted to serve raw markdown files with Jekyll
- The mdBook workflow was building artifacts but they weren't being deployed
- Users received 404 errors when accessing the site

## Decision

Switch GitHub Pages configuration from branch-based deployment to GitHub Actions deployment.

## Implementation

1. **Repository Settings Change**:
   - Navigate to Settings > Pages
   - Change Source from "Deploy from a branch" to "GitHub Actions"
   - This enables the mdBook workflow to deploy built artifacts

2. **Workflow Configuration** (already in place):
   - `.github/workflows/mdbook.yml` handles build and deployment
   - Builds mdBook on push to main
   - Uploads artifacts via `actions/upload-pages-artifact`
   - Deploys via `actions/deploy-pages`

3. **Directory Structure**:
   - mdBook builds to `book/html/`
   - Workflow moves contents to `book/` root
   - Artifact is uploaded from `book/` directory

## Consequences

### Positive

- Site deploys correctly from pre-built HTML
- No Jekyll processing overhead
- Faster deployments
- Full control over build process
- mdBook features work as intended (search, navigation, etc.)

### Negative

- Requires manual configuration change in GitHub settings
- Not captured in version control (GitHub setting)
- New contributors need to be aware of this requirement

## Lessons Learned

1. GitHub Pages has two deployment modes that are fundamentally different
2. The `build_type` and source configuration is crucial for proper deployment
3. Workflow success doesn't guarantee site availability if Pages is misconfigured
4. Documentation should explicitly state GitHub Pages configuration requirements

## Related Files

- `.github/workflows/mdbook.yml` - Build and deployment workflow
- `.nojekyll` - Prevents Jekyll processing (still needed for asset handling)
- `README.md` - Updated with deployment configuration notes
