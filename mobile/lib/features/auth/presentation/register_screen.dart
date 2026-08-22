import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/api_error.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/google_sign_in_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _asPartner = false;
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      await ref.read(authProvider.notifier).register(
            name: _name.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
            role: _asPartner ? 'partner' : null,
          );
      if (!mounted) return;
      context.go(_asPartner ? '/partner' : '/home');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyErrorMessage(context, error))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AuthScaffold(
      title: l10n.registerTitle,
      subtitle: l10n.registerSubtitle,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: l10n.registerNameLabel),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.registerEnterName;
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(labelText: l10n.authEmailLabel),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return l10n.authEnterEmail;
                if (!email.contains('@')) return l10n.authEnterValidEmail;
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: l10n.registerPhoneLabel,
                hintText: '+9617...',
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _password,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: l10n.authPasswordLabel,
                suffixIcon: IconButton(
                  tooltip: _obscure ? l10n.authShowPassword : l10n.authHidePassword,
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.length < 8) {
                  return l10n.registerPasswordMinLength;
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirm,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: l10n.registerConfirmPasswordLabel,
              ),
              validator: (value) {
                if (value != _password.text) {
                  return l10n.registerPasswordsDoNotMatch;
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "I'm a clinic or store owner",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Create a partner account to list your business',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTokens.of(context).textMuted,
                            ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _asPartner,
                  onChanged: (value) => setState(() => _asPartner = value),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  : Text(l10n.registerCreateAccountButton),
            ),
            const AuthOrDivider(),
            ContinueWithGoogleButton(
              enabled: !_submitting,
              onIdToken: (idToken) async {
                await ref.read(authProvider.notifier).loginWithGoogle(
                      idToken: idToken,
                      role: _asPartner ? 'partner' : null,
                    );
                if (!context.mounted) return;
                context.go(_asPartner ? '/partner' : '/home');
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/login'),
              child: Text(l10n.registerAlreadyHaveAccount),
            ),
          ],
        ),
      ),
    );
  }
}
