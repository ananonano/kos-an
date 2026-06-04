@echo off
REM Setup CI/CD - Create GCP Service Account for GitHub Actions

set PROJECT_ID=g-43-491016
set SA_NAME=github-actions
set SA_EMAIL=%SA_NAME%@%PROJECT_ID%.iam.gserviceaccount.com

echo ========================================
echo Setting up CI/CD for Kos Terpadu...
echo ========================================
echo.

echo [1/3] Creating service account...
gcloud iam service-accounts create %SA_NAME% --display-name="GitHub Actions CI/CD" --project=%PROJECT_ID%
echo.

echo [2/3] Granting permissions...
gcloud projects add-iam-policy-binding %PROJECT_ID% --member="serviceAccount:%SA_EMAIL%" --role="roles/run.admin"
gcloud projects add-iam-policy-binding %PROJECT_ID% --member="serviceAccount:%SA_EMAIL%" --role="roles/storage.admin"
gcloud projects add-iam-policy-binding %PROJECT_ID% --member="serviceAccount:%SA_EMAIL%" --role="roles/iam.serviceAccountUser"
gcloud projects add-iam-policy-binding %PROJECT_ID% --member="serviceAccount:%SA_EMAIL%" --role="roles/cloudbuild.builds.builder"
echo.

echo [3/3] Creating service account key...
gcloud iam service-accounts keys create gcp-key.json --iam-account=%SA_EMAIL% --project=%PROJECT_ID%
echo.

echo ========================================
echo Service account created successfully!
echo ========================================
echo.
echo Next steps:
echo 1. Open 'gcp-key.json' file
echo 2. Copy the entire JSON content
echo 3. Go to GitHub repository ^> Settings ^> Secrets and variables ^> Actions
echo 4. Click 'New repository secret'
echo 5. Name: GCP_SA_KEY
echo 6. Value: Paste the JSON content
echo.
echo Required GitHub Secrets:
echo   - GCP_SA_KEY (from gcp-key.json)
echo   - GCP_PROJECT_ID: g-43-491016
echo   - DB_HOST: 34.50.122.143
echo   - DB_NAME: kosterpadu_db
echo   - DB_USER: admin
echo   - DB_PASSWORD: KosanPassword123
echo   - JWT_SECRET: kos_terpadu_secret_key_2026_production_ready
echo   - CORS_ORIGIN: https://kosan-web-670153358279.asia-southeast2.run.app
echo.
echo WARNING: Delete 'gcp-key.json' after copying to GitHub!
echo          DO NOT commit this file to git!
echo.
pause
