# Authentication Screen Integration Guide

## Overview

The `AuthScreen` provides a complete authentication module with tabbed Login and Register interfaces for the iLab+ application.

## Features

### ✅ Login Tab

- Email or Phone Number input
- Password input with show/hide toggle
- "Remember Me" checkbox
- "Forgot Password" link
- Form validation
- Loading state during authentication

### ✅ Register Tab

- Full Name input
- Email Address input
- Phone Number input
- Password input with show/hide toggle
- Confirm Password input with matching validation
- Form validation
- Loading state during registration

### ✅ Design Features

- Matches iLab+ theme (gradient background, brand colors)
- Smooth tab transitions
- Touch-friendly input fields (mobile optimized)
- Real-time form validation
- Error messages for invalid inputs
- Responsive layout (works on all screen sizes)
- Loading indicators for async operations

## How to Use

### 1. Import in your main.dart or initial route

```dart
import 'screens/auth_screen.dart';
```

### 2. Set as your initial route (if no user is logged in)

```dart
void main() {
  runApp(const ILabPlusApp());
}

class ILabPlusApp extends StatelessWidget {
  const ILabPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iLab+ Eye Health',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // Set AuthScreen as home if user is not logged in
      home: const AuthScreen(), // Change this based on login state

      // Or use routes
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/dashboard': (context) => const NewDashboardScreen(),
      },
    );
  }
}
```

### 3. Check Authentication State

```dart
// In a real app, check if user is logged in
Future<bool> isUserLoggedIn() async {
  // TODO: Implement your authentication check
  // Check SharedPreferences, secure storage, or backend token
  return false; // Return true if logged in
}

@override
Widget build(BuildContext context) {
  return MaterialApp(
    home: FutureBuilder<bool>(
      future: isUserLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == true) {
          return const NewDashboardScreen(); // User is logged in
        } else {
          return const AuthScreen(); // User needs to login
        }
      },
    ),
  );
}
```

## Implementation TODOs

The AuthScreen has placeholder comments marked with `// TODO:` for features you need to implement:

### Login Implementation (\_handleLogin method)

```dart
Future<void> _handleLogin() async {
  // TODO: Implement actual login logic here
  // Example:
  // final email = _loginEmailController.text;
  // final password = _loginPasswordController.text;
  // await AuthService.login(email, password);
  // Store token in secure storage
  // Navigate to dashboard
}
```

### Register Implementation (\_handleRegister method)

```dart
Future<void> _handleRegister() async {
  // TODO: Implement actual registration logic here
  // Example:
  // final userData = {
  //   'name': _registerNameController.text,
  //   'email': _registerEmailController.text,
  //   'phone': _registerPhoneController.text,
  //   'password': _registerPasswordController.text,
  // };
  // await AuthService.register(userData);
}
```

### Forgot Password

```dart
// In the "Forgot Password?" button onPressed
TextButton(
  onPressed: () {
    // TODO: Implement forgot password
    // Navigator.push(context, MaterialPageRoute(
    //   builder: (_) => ForgotPasswordScreen()
    // ));
  },
```

### Navigation After Login

```dart
// After successful login, navigate to dashboard:
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => const NewDashboardScreen()),
);
```

## Example Authentication Service

Create a new file: `lib/services/auth_service.dart`

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const String baseUrl = 'http://localhost:5000'; // Your backend URL

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Login failed');
    }
  }

  static Future<Map<String, dynamic>> register(Map<String, String> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Registration failed');
    }
  }
}
```

## Form Validation Rules

### Email

- Required field
- Must match email format: `example@domain.com`

### Phone Number

- Required field
- Minimum 10 digits
- Accepts: `+1234567890`, `(123) 456-7890`, `123-456-7890`

### Password

- Required field
- Minimum 8 characters
- Should contain uppercase, lowercase, numbers (implement custom validation if needed)

### Confirm Password

- Required field
- Must match the Password field

### Full Name

- Required field
- Minimum 3 characters

## Customization

### Change Colors

Edit the AppTheme colors in `lib/theme/app_theme.dart`:

```dart
static const Color accentBlue = Color(0xFF8BA8FD); // Login button color
static const Color accentGreen = Color(0xFF10B981); // Register button color
```

### Change Tab Labels

```dart
tabs: const [
  Tab(text: 'Login'),        // Change this
  Tab(text: 'Sign Up'),      // Change this
],
```

### Adjust Input Fields

Modify the TextFormField decorations in `_buildLoginTab()` or `_buildRegisterTab()` methods.

## Testing the Screen

1. Add to your routes
2. Navigate to `/auth` or set as home
3. Test form validation by:
   - Leaving fields empty
   - Entering invalid email
   - Entering mismatched passwords
   - Using short password (<8 chars)
4. Test tab switching
5. Test password visibility toggles
6. Test Remember Me checkbox

## Security Recommendations

1. **Never** store passwords in plain text
2. Use HTTPS for all API calls
3. Store auth tokens in secure storage (not SharedPreferences)
4. Implement JWT or OAuth2 for authentication
5. Add rate limiting on backend
6. Implement CAPTCHA for register/login after failed attempts
7. Use bcrypt or similar for password hashing on backend

## Next Steps

1. ✅ Create authentication screen (Done)
2. Create `AuthService` for API calls
3. Implement backend endpoints (`/auth/login`, `/auth/register`)
4. Add token storage (use `flutter_secure_storage` package)
5. Implement authentication state management (Provider, Riverpod, or Bloc)
6. Add "Forgot Password" screen
7. Add email verification flow
8. Add social login (Google, Facebook, etc.)
