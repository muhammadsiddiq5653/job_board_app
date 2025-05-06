import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'job_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Create demo users if first time running the app
    _initializeDemoAccounts();
  }

  Future<void> _initializeDemoAccounts() async {
    // Get auth service instance
    final authService =
        Provider.of<UserProvider>(context, listen: false).authService;
    await authService.addDemoUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Board - Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Job Board',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  // Basic email validation
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return ElevatedButton(
                    onPressed: userProvider.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                final success = await userProvider.signIn(
                                  _usernameController.text,
                                  _passwordController.text,
                                );
                                if (success) {
                                  // Navigate to job list page
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const JobListScreen(),
                                    ),
                                  );
                                } else {
                                  // Show error
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Invalid credentials. Please check your email and password.'),
                                    ),
                                  );
                                }
                              } catch (e) {
                                // Handle specific Firebase Auth errors
                                String errorMessage =
                                    'An error occurred. Please try again.';
                                if (e.toString().contains('user-not-found')) {
                                  errorMessage =
                                      'No user found with this email.';
                                } else if (e
                                    .toString()
                                    .contains('wrong-password')) {
                                  errorMessage = 'Incorrect password.';
                                } else if (e
                                    .toString()
                                    .contains('invalid-email')) {
                                  errorMessage = 'Invalid email format.';
                                } else if (e
                                    .toString()
                                    .contains('user-disabled')) {
                                  errorMessage =
                                      'This account has been disabled.';
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(errorMessage)),
                                );
                              }
                            }
                          },
                    child: userProvider.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Login'),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Navigate to sign up page
                  // This would be implemented in a real app
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Sign up functionality would be implemented in a complete app'),
                    ),
                  );
                },
                child: const Text('Create an account'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Demo Credentials:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Recruiter: recruiter@test.com / password123'),
              const Text('Job Seeker: jobseeker@test.com / password123'),
            ],
          ),
        ),
      ),
    );
  }
}
