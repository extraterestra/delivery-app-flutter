import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

import '../providers/locale_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  void _loadSavedCredentials() async {
    // We need to wait for the next frame to use context/Provider
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final lastEmail = await authProvider.getLastEmail();
      final lastPassword = await authProvider.getLastPassword();
      
      setState(() {
        _rememberMe = authProvider.rememberMe;
        if (_rememberMe) {
          if (lastEmail != null) _emailController.text = lastEmail;
          if (lastPassword != null) _passwordController.text = lastPassword;
        }
      });
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      if (_isLogin) {
        await authProvider.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          rememberMe: _rememberMe,
        );
      } else {
        await authProvider.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _fullNameController.text.trim(),
          _phoneController.text.trim(),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () => localeProvider.toggleLocale(),
            icon: const Icon(LucideIcons.languages, size: 20, color: Colors.orange),
            label: Text(
              localeProvider.locale.languageCode.toUpperCase(),
              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Logo
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.orange, Colors.deepOrange],
                        ),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(LucideIcons.truck, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.appTitle,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      l10n.driverPanel,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Toggle
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLogin = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isLogin ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _isLogin ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
                          ),
                          child: Center(
                            child: Text(
                              l10n.login,
                              style: TextStyle(
                                fontWeight: _isLogin ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLogin = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isLogin ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: !_isLogin ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
                          ),
                          child: Center(
                            child: Text(
                              l10n.register,
                              style: TextStyle(
                                fontWeight: !_isLogin ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          labelText: l10n.fullName,
                          prefixIcon: const Icon(LucideIcons.user),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? l10n.errorFullName : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: l10n.phone,
                          prefixIcon: const Icon(LucideIcons.phone),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: l10n.email,
                        prefixIcon: const Icon(LucideIcons.mail),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? l10n.errorEmail : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        prefixIcon: const Icon(LucideIcons.lock),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() => _isPasswordVisible = !_isPasswordVisible);
                          },
                          icon: Icon(
                            _isPasswordVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                          ),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) => v!.length < 6 ? l10n.errorPassword : null,
                    ),
                    if (_isLogin) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (v) => setState(() => _rememberMe = v ?? false),
                              activeColor: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => setState(() => _rememberMe = !_rememberMe),
                            child: Text(
                              l10n.rememberMe,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(_isLogin ? l10n.signIn : l10n.signUp, style: const TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_isLogin)
                TextButton(
                  onPressed: () {
                    // TODO: Reset password
                  },
                  child: Text(l10n.forgotPassword),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
