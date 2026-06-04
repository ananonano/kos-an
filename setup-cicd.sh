#!/bin/bash
# Setup CI/CD - Create GCP Service Account for GitHub Actions

PROJECT_ID="g-43-491016"
SA_NAME="github-actions"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "🚀 Setting up CI/CD for Kos Terpadu..."
echo ""

# 1. Create Service Account
echo "📝 Creating service account..."
gcloud iam service-accounts create $SA_NAME \
  --display-name="GitHub Actions CI/CD" \
  --project=$PROJECT_ID

# 2. Grant Permissions
echo "🔐 Granting permissions..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/run.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/storage.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/cloudbuild.builds.builder"

# 3. Create & Download Key
echo "🔑 Creating service account key..."
gcloud iam service-accounts keys create ./gcp-key.json \
  --iam-account=$SA_EMAIL \
  --project=$PROJECT_ID

echo ""
echo "✅ Service account created successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Copy the content of 'gcp-key.json' file"
echo "2. Go to GitHub repository → Settings → Secrets and variables → Actions"
echo "3. Click 'New repository secret'"
echo "4. Name: GCP_SA_KEY"
echo "5. Value: Paste the entire JSON content"
echo ""
echo "🔒 Required GitHub Secrets:"
echo "  - GCP_SA_KEY (from gcp-key.json)"
echo "  - GCP_PROJECT_ID: g-43-491016"
echo "  - DB_HOST: 34.50.122.143"
echo "  - DB_NAME: kosterpadu_db"
echo "  - DB_USER: admin"
echo "  - DB_PASSWORD: KosanPassword123"
echo "  - JWT_SECRET: kos_terpadu_secret_key_2026_production_ready"
echo "  - CORS_ORIGIN: https://kosan-web-670153358279.asia-southeast2.run.app"
echo ""
echo "⚠️  IMPORTANT: Delete 'gcp-key.json' after copying to GitHub!"
echo "    DO NOT commit this file to git!"
