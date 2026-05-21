# 🚀 Git Setup Guide - Upload ke GitHub

## 📋 Step-by-Step Upload Project ke GitHub

### STEP 1: Persiapan (5 menit)

#### 1.1 Install Git (kalau belum)
```bash
# Check apakah Git sudah installed
git --version

# Kalau belum, download dari: https://git-scm.com/
```

#### 1.2 Configure Git (first time only)
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

---

### STEP 2: Create GitHub Repository (3 menit)

#### 2.1 Via GitHub Website:
1. Go to https://github.com/
2. Login ke account lu
3. Click tombol **"New"** atau **"+"** → **"New repository"**
4. Fill in:
   - **Repository name:** `kos-terpadu` atau `ProyekPrakTCC`
   - **Description:** "Sistem Manajemen Kos Terpadu - Proyek Praktikum TCC"
   - **Visibility:** 
     - ✅ **Public** (recommended untuk project akademik)
     - atau **Private** (kalau mau private)
   - **Initialize:** 
     - ❌ **JANGAN** centang "Add a README file"
     - ❌ **JANGAN** centang "Add .gitignore"
     - ❌ **JANGAN** centang "Choose a license"
     - (Karena kita udah punya file-file ini)
5. Click **"Create repository"**

#### 2.2 Copy Repository URL:
Setelah repo dibuat, copy URL-nya:
```
https://github.com/username/kos-terpadu.git
```

---

### STEP 3: Initialize Git di Local (2 menit)

```bash
# 1. Navigate ke project folder
cd "d:\Kuliah\Semester 6\PraktikumTCC\ProyekPrakTCC"

# 2. Initialize Git
git init

# 3. Check status
git status
```

Output:
```
Initialized empty Git repository in d:/Kuliah/Semester 6/PraktikumTCC/ProyekPrakTCC/.git/
```

---

### STEP 4: Add Files ke Git (2 menit)

```bash
# 1. Add all files
git add .

# 2. Check what will be committed
git status
```

Output akan show semua files yang akan di-commit (hijau).

**Files yang akan di-commit:**
- ✅ All source code
- ✅ Documentation (*.md files)
- ✅ Configuration files
- ❌ node_modules/ (ignored by .gitignore)
- ❌ .env files (ignored by .gitignore)
- ❌ build/ folders (ignored by .gitignore)

---

### STEP 5: Commit Changes (1 menit)

```bash
git commit -m "Initial commit: Backend foundation + Mobile app + Web setup + Documentation"
```

Output:
```
[main (root-commit) abc1234] Initial commit: Backend foundation + Mobile app + Web setup + Documentation
 150 files changed, 15000 insertions(+)
 create mode 100644 README.md
 create mode 100644 .gitignore
 ...
```

---

### STEP 6: Connect to GitHub (1 menit)

```bash
# 1. Add remote repository
git remote add origin https://github.com/username/kos-terpadu.git

# 2. Verify remote
git remote -v
```

Output:
```
origin  https://github.com/username/kos-terpadu.git (fetch)
origin  https://github.com/username/kos-terpadu.git (push)
```

---

### STEP 7: Push to GitHub (2 menit)

```bash
# 1. Rename branch to main (if needed)
git branch -M main

# 2. Push to GitHub
git push -u origin main
```

**First time push akan minta credentials:**
- Username: `your-github-username`
- Password: **JANGAN pakai password biasa!** Use **Personal Access Token**

#### How to create Personal Access Token:
1. Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Give it a name: "Kos Terpadu Project"
4. Select scopes: ✅ **repo** (full control)
5. Click "Generate token"
6. **COPY TOKEN** (you won't see it again!)
7. Use this token as password when pushing

Output:
```
Enumerating objects: 150, done.
Counting objects: 100% (150/150), done.
Delta compression using up to 8 threads
Compressing objects: 100% (120/120), done.
Writing objects: 100% (150/150), 500 KiB | 5 MiB/s, done.
Total 150 (delta 30), reused 0 (delta 0)
To https://github.com/username/kos-terpadu.git
 * [new branch]      main -> main
Branch 'main' set up to track remote branch 'main' from 'origin'.
```

---

### STEP 8: Verify Upload (1 menit)

1. Go to `https://github.com/username/kos-terpadu`
2. Check:
   - ✅ All files uploaded
   - ✅ README.md displayed
   - ✅ Folder structure correct
   - ✅ No sensitive files (.env, node_modules)

---

## ✅ DONE! Repository is Live! 🎉

---

## 📝 Daily Workflow (untuk development)

### Setiap kali ada perubahan:

```bash
# 1. Check status
git status

# 2. Add changes
git add .

# 3. Commit with message
git commit -m "Add: payment verification feature"

# 4. Push to GitHub
git push
```

### Commit Message Best Practices:

```bash
# Good commit messages:
git commit -m "Add: user authentication with JWT"
git commit -m "Fix: payment verification bug"
git commit -m "Update: room model with new fields"
git commit -m "Refactor: clean up auth controller"
git commit -m "Docs: update API documentation"

# Bad commit messages:
git commit -m "update"
git commit -m "fix bug"
git commit -m "changes"
```

---

## 🌿 Branching Strategy (Optional tapi Recommended)

### Create feature branch:

```bash
# 1. Create new branch
git checkout -b feature/payment-system

# 2. Work on feature
# ... make changes ...

# 3. Commit changes
git add .
git commit -m "Add: payment verification"

# 4. Push branch
git push -u origin feature/payment-system

# 5. Create Pull Request di GitHub
# 6. Merge to main after review
```

### Branch naming convention:

```
feature/feature-name    # New feature
fix/bug-name           # Bug fix
docs/doc-name          # Documentation
refactor/refactor-name # Code refactoring
```

---

## 👥 Team Collaboration

### Pull latest changes:

```bash
# Before starting work, always pull latest
git pull origin main
```

### Resolve conflicts:

```bash
# If there's conflict:
# 1. Git will mark conflicts in files
# 2. Open file and resolve manually
# 3. Remove conflict markers (<<<<, ====, >>>>)
# 4. Add and commit

git add .
git commit -m "Resolve merge conflict"
git push
```

---

## 🔒 Security Checklist

### ❌ NEVER commit these files:

- `.env` files (credentials)
- `node_modules/` (dependencies)
- `build/` or `dist/` (build outputs)
- `*.log` files
- Database dumps
- API keys
- Passwords
- Private keys

### ✅ Always commit these:

- Source code
- Documentation
- Configuration templates (`.env.example`)
- README files
- .gitignore

---

## 🚨 Common Issues & Solutions

### Issue 1: "Permission denied (publickey)"

**Solution:**
```bash
# Use HTTPS instead of SSH
git remote set-url origin https://github.com/username/kos-terpadu.git
```

### Issue 2: "Failed to push some refs"

**Solution:**
```bash
# Pull first, then push
git pull origin main --rebase
git push origin main
```

### Issue 3: "Large files detected"

**Solution:**
```bash
# Remove large files from commit
git rm --cached path/to/large/file
git commit --amend
git push
```

### Issue 4: "Accidentally committed .env file"

**Solution:**
```bash
# Remove from Git but keep local
git rm --cached .env
git commit -m "Remove .env from tracking"
git push

# Add to .gitignore
echo ".env" >> .gitignore
git add .gitignore
git commit -m "Add .env to gitignore"
git push
```

---

## 📊 Repository Statistics

After upload, your repo will have:
- **~150 files**
- **~15,000 lines of code**
- **8 database models**
- **40+ API endpoints**
- **Complete documentation**

---

## 🎯 Next Steps After Upload

1. **Share repo link** dengan tim
2. **Add collaborators:**
   - Go to repo → Settings → Collaborators
   - Add team members
3. **Setup branch protection** (optional):
   - Settings → Branches → Add rule
   - Protect `main` branch
4. **Setup GitHub Actions** (optional):
   - For CI/CD automation
5. **Add project board** (optional):
   - For task management

---

## 📞 Need Help?

### Git Resources:
- Git Documentation: https://git-scm.com/doc
- GitHub Guides: https://guides.github.com/
- Git Cheat Sheet: https://education.github.com/git-cheat-sheet-education.pdf

### Common Commands:

```bash
# Check status
git status

# View commit history
git log --oneline

# View remote URL
git remote -v

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Discard all local changes
git reset --hard HEAD

# View differences
git diff

# Create branch
git checkout -b branch-name

# Switch branch
git checkout branch-name

# Delete branch
git branch -d branch-name
```

---

## ✅ Checklist

```
[ ] Git installed
[ ] Git configured (name & email)
[ ] GitHub account created
[ ] Repository created on GitHub
[ ] Local git initialized
[ ] Files added to git
[ ] First commit created
[ ] Remote added
[ ] Pushed to GitHub
[ ] Verified on GitHub
[ ] Team members added as collaborators
[ ] .gitignore working (no sensitive files uploaded)
```

---

**Ready to push? Let's go! 🚀**

```bash
cd "d:\Kuliah\Semester 6\PraktikumTCC\ProyekPrakTCC"
git init
git add .
git commit -m "Initial commit: Backend foundation + Mobile app + Web setup + Documentation"
git remote add origin https://github.com/username/kos-terpadu.git
git branch -M main
git push -u origin main
```

**Done! Your project is now on GitHub! 🎉**
