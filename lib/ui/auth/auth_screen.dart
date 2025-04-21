import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_manager.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';

  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final email = _emailController.text;
      final password = _passwordController.text;
      final username = _usernameController.text;

      if (_isLogin) {
        await Provider.of<AuthManager>(context, listen: false)
            .login(email, password, context);
      } else {
        await Provider.of<AuthManager>(context, listen: false)
            .signup(email, password, username, context);
      }
    } catch (error) {
      _showErrorDialog(error.toString());
    }

    setState(() => _isLoading = false);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Authentication Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/book_background.webp'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.white.withOpacity(0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: _isLogin ? _buildLoginForm() : _buildSignupForm(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey(1),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.brown[700],
          ),
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
          ),
          validator: (value) {
            if (value == null || !value.contains('@')) {
              return 'Invalid email!';
            }
            return null;
          },
        ),
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock),
          ),
          obscureText: true,
          validator: (value) {
            if (value == null || value.length < 6) {
              return 'Password must be at least 6 characters!';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    const Text('Login', style: TextStyle(color: Colors.white)),
              ),
        TextButton(
          onPressed: () => setState(() => _isLogin = !_isLogin),
          child: const Text('Create an account',
              style: TextStyle(color: Colors.brown)),
        ),
      ],
    );
  }

  Widget _buildSignupForm() {
    return Column(
      key: const ValueKey(2),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Create an Account',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.brown[700],
          ),
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: _usernameController,
          decoration: InputDecoration(
            labelText: 'Username',
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Username is required!';
            }
            return null;
          },
        ),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
          ),
          validator: (value) {
            if (value == null || !value.contains('@')) {
              return 'Invalid email!';
            }
            return null;
          },
        ),
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock),
          ),
          obscureText: true,
          validator: (value) {
            if (value == null || value.length < 6) {
              return 'Password must be at least 6 characters!';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Sign Up',
                    style: TextStyle(color: Colors.white)),
              ),
        TextButton(
          onPressed: () => setState(() => _isLogin = !_isLogin),
          child: const Text('Already have an account? Login',
              style: TextStyle(color: Colors.brown)),
        ),
      ],
    );
  }
}
