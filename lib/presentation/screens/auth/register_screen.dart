import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../../l10n/generated/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      final success = await authProvider.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      );

      if (mounted) {
        if (success) {
          // Navigate to home or dashboard
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? AppLocalizations.of(context)!.registrationFailed),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  l10n.createAccount,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.registerSubtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 40),

                // Name Field
                CustomTextField(
                  hintText: l10n.fullNameHint,
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: colorScheme.onSurface.withOpacity(0.5),
                    size: 20,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.nameRequired;
                    }
                    if (value.length < 3) {
                      return l10n.nameMinLength;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email Field
                CustomTextField(
                  hintText: l10n.emailHint,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: colorScheme.onSurface.withOpacity(0.5),
                    size: 20,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.emailRequired;
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return l10n.emailInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                CustomTextField(
                  hintText: l10n.passwordHint,
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: colorScheme.onSurface.withOpacity(0.5),
                    size: 20,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.passwordRequired;
                    }
                    if (value.length < 6) {
                      return l10n.passwordMinLength;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password Field
                CustomTextField(
                  hintText: l10n.confirmPasswordHint,
                  controller: _confirmPasswordController,
                  isPassword: true,
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: colorScheme.onSurface.withOpacity(0.5),
                    size: 20,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.confirmPasswordRequired;
                    }
                    if (value != _passwordController.text) {
                      return l10n.passwordMismatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Register Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return CustomButton(
                      text: l10n.signUp,
                      onPressed: _handleRegister,
                      isLoading: authProvider.status == AuthStatus.loading,
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: colorScheme.onSurface.withOpacity(0.2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.or,
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: colorScheme.onSurface.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.alreadyHaveAccount,
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        l10n.login,
                        style: TextStyle(
                          color: colorScheme.secondary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
