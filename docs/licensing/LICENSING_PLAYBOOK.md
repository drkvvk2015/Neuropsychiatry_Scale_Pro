# Scale Licensing Playbook

Company: drkvvk2015
Product: NeuroScale Pro
Audience: Startup operations + product engineering

This document is process guidance only and not legal advice.

## Goal
Acquire lawful rights for psychiatric scales used in NeuroScale Pro and maintain an audit trail for app store, enterprise, and clinical compliance reviews.

## Step 1: Freeze Risky Content
- Keep placeholder item wording for scales without explicit permission.
- Do not publish full copyrighted item text until approved in writing.
- Keep scoring shells configurable so approved text can be swapped in later.

## Step 2: Build Licensing Inventory
Use SCALE_LICENSE_TRACKER.csv and fill these fields first:
- Rights holder
- Contact form/email
- Commercial app permission status
- Redistribution status
- Required attribution text
- Fee and term

## Step 3: Outreach Cadence
- Day 0: Send initial request.
- Day 7: Send follow-up.
- Day 14: Escalate to alternate contact or institutional licensing office.
- Day 21: Mark as blocked and plan replacement if no response.

## Step 4: Decision Rules
- Approved in writing: move scale to Allowed.
- Ambiguous response: stay Restricted until clarified.
- Denied or too expensive: keep placeholder or remove from release branch.

## Step 5: Engineering Controls
- Add per-scale flag in config: allowedFullText true/false.
- Add attribution block in app settings/about page.
- Add release checklist item: verify active license period.

## Step 6: Legal Evidence Folder Structure
Recommended local folder structure:
- docs/licensing/evidence/[Scale]/emails/
- docs/licensing/evidence/[Scale]/contracts/
- docs/licensing/evidence/[Scale]/invoices/
- docs/licensing/evidence/[Scale]/attribution/

## Step 7: Release Gate (Must pass)
Before each production release, verify:
1. Every enabled scale has a status of Approved.
2. Attribution text is present where required.
3. License term is still active.
4. Region limits are respected.
5. Any usage cap (users/sites) is within contract limits.

## Suggested Priority For drkvvk2015
- Phase A (already in app): PHQ-9, GAD-7, HAM-D, BPRS, YMRS, Y-BOCS, MMSE, C-SSRS
- Phase B (newly added): HADS, MDQ, COWS, EPDS, GDS-15
- Phase C (future): PANSS, SAPS/SANS, AIMS, ORT, MADRS, BDI, HAM-A, ASRM

## Quick Start Checklist
1. Fill the first 8 columns in SCALE_LICENSE_TRACKER.csv.
2. Send 5 high-priority requests this week using CONTACT_EMAIL_TEMPLATES.md.
3. Track response dates and set follow-up reminders.
4. Keep unapproved scales on placeholder wording until legal confirmation.
