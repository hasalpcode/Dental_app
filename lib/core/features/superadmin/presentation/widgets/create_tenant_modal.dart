import 'package:flutter/material.dart';

const _teal = Color(0xff0b5260);

class CreateTenantModal extends StatefulWidget {
  final Future<bool> Function(String name, String subdomain) onSubmit;
  const CreateTenantModal({super.key, required this.onSubmit});

  @override
  State<CreateTenantModal> createState() => _CreateTenantModalState();
}

class _CreateTenantModalState extends State<CreateTenantModal> {
  final _nameCtrl = TextEditingController();
  final _subdomainCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _subdomainCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _subdomainCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Nom et sous-domaine requis');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final ok = await widget.onSubmit(_nameCtrl.text.trim(), _subdomainCtrl.text.trim());
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() {
        _submitting = false;
        _error = 'Erreur lors de la création';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nouvelle caisse',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nom de la caisse'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subdomainCtrl,
              decoration: const InputDecoration(
                labelText: 'Sous-domaine',
                helperText: 'minuscules, chiffres et tirets uniquement',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Créer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
