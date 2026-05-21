# Contributing to Kos Terpadu

Terima kasih atas minat Anda untuk berkontribusi pada Kos Terpadu! 🎉

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Bug Reports](#bug-reports)
- [Feature Requests](#feature-requests)

## Code of Conduct

Proyek ini mengikuti [Code of Conduct](CODE_OF_CONDUCT.md). Dengan berpartisipasi, Anda diharapkan untuk menjunjung kode etik ini.

## How Can I Contribute?

### 1. Reporting Bugs

Sebelum membuat bug report:
- Cek apakah bug sudah dilaporkan di [Issues](https://github.com/kosterpadu/mobile-app/issues)
- Pastikan Anda menggunakan versi terbaru
- Kumpulkan informasi sebanyak mungkin tentang bug

Bug report yang baik harus mencakup:
- **Judul yang jelas dan deskriptif**
- **Langkah-langkah untuk reproduce bug**
- **Hasil yang diharapkan**
- **Hasil yang sebenarnya terjadi**
- **Screenshots** (jika applicable)
- **Environment details** (OS, Flutter version, device)

### 2. Suggesting Features

Feature request yang baik harus mencakup:
- **Judul yang jelas dan deskriptif**
- **Penjelasan detail tentang fitur**
- **Alasan mengapa fitur ini berguna**
- **Contoh penggunaan**
- **Mockup atau wireframe** (jika ada)

### 3. Code Contributions

#### Development Setup

1. Fork repository
2. Clone fork Anda:
```bash
git clone https://github.com/YOUR_USERNAME/kos-terpadu.git
cd kos-terpadu
```

3. Add upstream remote:
```bash
git remote add upstream https://github.com/kosterpadu/mobile-app.git
```

4. Install dependencies:
```bash
flutter pub get
```

5. Create a branch:
```bash
git checkout -b feature/your-feature-name
```

## Coding Standards

### Dart/Flutter Style Guide

Ikuti [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines:

#### Naming Conventions

```dart
// Classes: PascalCase
class UserModel { }
class AuthController { }

// Files: snake_case
user_model.dart
auth_controller.dart

// Variables & Functions: camelCase
String userName;
void getUserData() { }

// Constants: SCREAMING_SNAKE_CASE
const String API_BASE_URL = '...';
const int MAX_RETRY_COUNT = 3;

// Private members: _leadingUnderscore
String _privateVariable;
void _privateMethod() { }
```

#### Code Organization

```dart
// 1. Imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 2. Class declaration
class MyWidget extends StatelessWidget {
  // 3. Constants
  static const String title = 'My Widget';
  
  // 4. Fields
  final String name;
  final int age;
  
  // 5. Constructor
  const MyWidget({
    Key? key,
    required this.name,
    required this.age,
  }) : super(key: key);
  
  // 6. Lifecycle methods
  @override
  Widget build(BuildContext context) {
    return Container();
  }
  
  // 7. Public methods
  void publicMethod() { }
  
  // 8. Private methods
  void _privateMethod() { }
}
```

#### Comments

```dart
/// Documentation comment untuk public API
/// Gunakan triple slash dan markdown
class UserModel {
  /// User's unique identifier
  final String id;
  
  /// User's email address
  final String email;
}

// Regular comment untuk internal notes
// Gunakan untuk menjelaskan "why", bukan "what"
void complexFunction() {
  // Calculate discount based on user tier
  // This is needed because...
  final discount = _calculateDiscount();
}
```

### Architecture Guidelines

#### MVC + Service Layer

```dart
// ❌ BAD: View calling API directly
class MyView extends StatelessWidget {
  Future<void> loadData() async {
    final response = await http.get('...');
    // Process response
  }
}

// ✅ GOOD: View → Controller → Service → API
class MyView extends StatelessWidget {
  Future<void> loadData() async {
    final controller = context.read<MyController>();
    await controller.loadData();
  }
}

class MyController extends ChangeNotifier {
  Future<void> loadData() async {
    _data = await MyService.getData();
    notifyListeners();
  }
}

class MyService {
  static Future<List<Model>> getData() async {
    final response = await HttpService.get('...');
    return response.map((json) => Model.fromJson(json)).toList();
  }
}
```

#### Error Handling

```dart
// ✅ GOOD: Proper error handling
Future<void> loadData() async {
  try {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    _data = await MyService.getData();
    
    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _isLoading = false;
    _errorMessage = e.toString();
    notifyListeners();
  }
}
```

#### State Management

```dart
// ✅ GOOD: Clean controller
class MyController extends ChangeNotifier {
  List<Model> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<Model> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Methods
  Future<void> loadItems() async {
    // Implementation
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
```

## Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

#### Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, etc)
- **refactor**: Code refactoring
- **test**: Adding or updating tests
- **chore**: Maintenance tasks

#### Examples

```bash
feat(auth): add login functionality

- Implement login form
- Add email/password validation
- Integrate with auth API
- Add error handling

Closes #123

---

fix(kamar): fix null pointer exception in kamar list

The kamar list was crashing when no data was available.
Added null check and empty state handling.

Fixes #456

---

docs(readme): update setup instructions

Added more detailed Firebase setup steps
```

## Pull Request Process

### Before Submitting

1. **Update your branch** with latest upstream:
```bash
git fetch upstream
git rebase upstream/main
```

2. **Run tests**:
```bash
flutter test
```

3. **Check for linting errors**:
```bash
flutter analyze
```

4. **Format code**:
```bash
flutter format .
```

### PR Checklist

- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings
- [ ] Tests added/updated
- [ ] All tests passing
- [ ] Commit messages follow guidelines
- [ ] PR description is clear

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
How has this been tested?

## Screenshots (if applicable)
Add screenshots here

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Tests added/updated
- [ ] Documentation updated
```

## Code Review Process

### For Reviewers

- Be respectful and constructive
- Focus on code, not the person
- Explain the "why" behind suggestions
- Approve when ready, request changes if needed

### For Contributors

- Be open to feedback
- Respond to all comments
- Make requested changes
- Ask questions if unclear

## Development Workflow

```bash
# 1. Create feature branch
git checkout -b feature/my-feature

# 2. Make changes
# ... code ...

# 3. Commit changes
git add .
git commit -m "feat(scope): description"

# 4. Push to your fork
git push origin feature/my-feature

# 5. Create Pull Request on GitHub

# 6. Address review comments
# ... make changes ...
git add .
git commit -m "fix: address review comments"
git push origin feature/my-feature

# 7. Merge when approved
```

## Questions?

Feel free to ask questions by:
- Opening an issue
- Joining our Discord server
- Emailing dev@kosterpadu.com

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to Kos Terpadu! 🙏
