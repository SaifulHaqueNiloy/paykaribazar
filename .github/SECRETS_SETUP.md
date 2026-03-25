# CI/CD Secrets Setup Guide

This document outlines the required secrets for GitHub Actions to automate builds and releases.

## 🔑 Required Secrets

Add these in GitHub Repo -> Settings -> Secrets and variables -> Actions:

| Secret Name | Description |
| :--- | :--- |
| `GEMINI_API_KEY` | Primary Gemini 2.0 API Key |
| `FIREBASE_SERVICE_ACCOUNT` | JSON key from Firebase Console |
| `SLACK_WEBHOOK` | Slack incoming webhook for notifications |
| `SHOREBIRD_TOKEN` | Auth token for Shorebird CLI |

## 🛠️ Step-by-Step Instructions

### 1. Firebase Service Account
1. Go to Firebase Console -> Project Settings -> Service Accounts.
2. Click "Generate New Private Key".
3. Copy the entire JSON content and paste it as `FIREBASE_SERVICE_ACCOUNT`.

### 2. Slack Notification Setup
1. Create a Slack App in your workspace.
2. Enable "Incoming Webhooks".
3. Create a new webhook for your #releases channel.
4. Copy the URL (looks like `https://hooks.slack.com/services/Txxx/Bxxx/Xxxx`).
5. Add it as `SLACK_WEBHOOK`.

**Note:** Never commit the actual Webhook URL to this file. Use placeholders like:
`https://hooks.slack.com/services/REPLACE_WITH_REAL_TOKEN`

---

## ✅ Verification Checklist
- [ ] Gemini API responds with 200 OK.
- [ ] Firebase CLI can authenticate.
- [ ] Slack receives a "Build Started" ping.
