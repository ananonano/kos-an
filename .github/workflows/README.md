# CI/CD Setup - GitHub Actions

Automatic deployment to Google Cloud Run menggunakan GitHub Actions.

## 🚀 Cara Kerja

Setiap kali push ke branch `main`:
- **Backend changes** → Auto deploy ke Cloud Run Backend
- **Web changes** → Auto deploy ke Cloud Run Web

## 🔐 Setup GitHub Secrets

Untuk CI/CD berfungsi, tambahkan secrets di GitHub repository:

### Cara Menambahkan Secrets:
1. Buka repository di GitHub
2. Go to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Tambahkan secrets berikut:

### Required Secrets:

#### 1. `GCP_SA_KEY` (Google Cloud Service Account Key)
```bash
# Di terminal, buat service account & download key:
gcloud iam service-accounts create github-actions \
  --display-name="GitHub Actions CI/CD"

# Berikan permission:
gcloud projects add-iam-policy-binding g-43-491016 \
  --member="serviceAccount:github-actions@g-43-491016.iam.gserviceaccount.com" \
  --role="roles/run.admin"

gcloud projects add-iam-policy-binding g-43-491016 \
  --member="serviceAccount:github-actions@g-43-491016.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

gcloud projects add-iam-policy-binding g-43-491016 \
  --member="serviceAccount:github-actions@g-43-491016.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

# Download JSON key:
gcloud iam service-accounts keys create ~/gcp-key.json \
  --iam-account=github-actions@g-43-491016.iam.gserviceaccount.com

# Copy isi file gcp-key.json ke GitHub secret GCP_SA_KEY
```

#### 2. `GCP_PROJECT_ID`
```
g-43-491016
```

#### 3. Backend Environment Variables
```
DB_HOST=34.50.122.143
DB_NAME=kosterpadu_db
DB_USER=admin
DB_PASSWORD=KosanPassword123
JWT_SECRET=kos_terpadu_secret_key_2026_production_ready
CORS_ORIGIN=https://kosan-web-670153358279.asia-southeast2.run.app
```

## 📋 Workflow Files

- **`.github/workflows/deploy-backend.yml`** - Auto deploy Backend
- **`.github/workflows/deploy-web.yml`** - Auto deploy Web

## 🧪 Testing CI/CD

Setelah setup secrets:

1. Push changes ke branch main:
```bash
git add .
git commit -m "Test CI/CD deployment"
git push origin main
```

2. Monitor deployment:
   - Go to **Actions** tab di GitHub repository
   - Lihat workflow running & logs

3. Check Cloud Run:
   - Backend: https://kosan-backend-670153358279.asia-southeast2.run.app
   - Web: https://kosan-web-670153358279.asia-southeast2.run.app

## 🔧 Troubleshooting

### Build Failed
- Check logs di **Actions** tab
- Pastikan Dockerfile & dependencies correct

### Permission Denied
- Verify service account permissions
- Re-create service account key jika perlu

### Environment Variables Not Set
- Double check GitHub secrets
- Pastikan nama secret sesuai dengan workflow file

## 📝 Notes

- Deployment otomatis hanya trigger kalau ada changes di folder `Backend/` atau `Web/`
- Build time ~3-5 menit per service
- Secrets **JANGAN** di-commit ke git!
- Service account key harus di-download sekali aja, simpan aman

## 🎯 Next Steps

Setelah CI/CD jalan:
1. ✅ Push changes otomatis deploy
2. ✅ No manual `gcloud run deploy` lagi
3. ✅ Monitor di Actions tab
4. ✅ Rollback easy via Cloud Run console

---

**Deployment URLs:**
- Backend: https://kosan-backend-670153358279.asia-southeast2.run.app
- Web: https://kosan-web-670153358279.asia-southeast2.run.app
- Database: PostgreSQL Cloud SQL (34.50.122.143)
