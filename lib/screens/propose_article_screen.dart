import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

/// Formulaire pour proposer un nouvel article — fonctionnalité optionnelle.
class ProposeArticleScreen extends StatefulWidget {
  const ProposeArticleScreen({super.key});

  @override
  State<ProposeArticleScreen> createState() => _ProposeArticleScreenState();
}

class _ProposeArticleScreenState extends State<ProposeArticleScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  int? _selectedCategoryId;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchCategories();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Validation
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    final priceStr = _priceController.text.trim();

    if (title.isEmpty || desc.isEmpty || priceStr.isEmpty || _selectedCategoryId == null) {
      setState(() => _error = 'Veuillez remplir tous les champs.');
      return;
    }
    final price = double.tryParse(priceStr);
    if (price == null || price <= 0) {
      setState(() => _error = 'Prix invalide.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await context.read<ProductProvider>().createProduct(
            title: title,
            price: price,
            description: desc,
            categoryId: _selectedCategoryId!,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article proposé avec succès !')),
      );
      context.go('/articles');
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proposer un article')),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Prix (€) *',
                    border: OutlineInputBorder(),
                    prefixText: '€ ',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie *',
                    border: OutlineInputBorder(),
                  ),
                  items: provider.categories.map((cat) {
                    return DropdownMenuItem<int>(
                      value: cat['id'] as int,
                      child: Text(cat['name'] as String? ?? ''),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedCategoryId = v),
                ),
                const SizedBox(height: 8),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Publier l\'article'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
