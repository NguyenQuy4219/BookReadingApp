import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_manager.dart';
import '../shared/dialog_utils.dart';

enum AuthMode { signup, login }

class AuthCard extends StatefulWidget {
  const AuthCard({super.key});

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.login;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
    'username': ''
  };
  final _isSubmitting = ValueNotifier<bool>(false);
  final _passwordController = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    _isSubmitting.value = true;

    try {
      if (_authMode == AuthMode.login) {
        await context.read<AuthManager>().login(
              _authData['email']!,
              _authData['password']!,
              context,
            );
      } else {
        await context.read<AuthManager>().signup(
              _authData['email']!,
              _authData['password']!,
              _authData['username']!,
              context,
            );
        _switchAuthMode();
      }
    } catch (error) {
      if (mounted) {
        showErrorDialog(context, error.toString());
      }
    }
    _isSubmitting.value = false;
  }

  void _switchAuthMode() {
    setState(() {
      _authMode =
          _authMode == AuthMode.login ? AuthMode.signup : AuthMode.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (_authMode == AuthMode.signup)
            TextFormField(
              decoration: const InputDecoration(
                  labelText: 'Username', prefixIcon: Icon(Icons.person)),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Username is required!';
                }
                return null;
              },
              onSaved: (value) => _authData['username'] = value!,
            ),
          TextFormField(
            decoration: const InputDecoration(
                labelText: 'Email', prefixIcon: Icon(Icons.email)),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value!.isEmpty || !value.contains('@')) {
                return 'Invalid email!';
              }
              return null;
            },
            onSaved: (value) => _authData['email'] = value!,
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(
                labelText: 'Password', prefixIcon: Icon(Icons.lock)),
            obscureText: true,
            controller: _passwordController,
            validator: (value) {
              if (value == null || value.length < 5) {
                return 'Password too short!';
              }
              return null;
            },
            onSaved: (value) => _authData['password'] = value!,
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<bool>(
            valueListenable: _isSubmitting,
            builder: (context, isSubmitting, child) {
              return ElevatedButton(
                onPressed: isSubmitting ? null : _submit,
                child: Text(_authMode == AuthMode.login ? 'Login' : 'Sign Up'),
              );
            },
          ),
          TextButton(
            onPressed: _switchAuthMode,
            child: Text(_authMode == AuthMode.login
                ? 'Create an account'
                : 'Already have an account? Login'),
          ),
        ],
      ),
    );
  }
}
