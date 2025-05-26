import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTransactionPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  AddTransactionPage({this.initialData});

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  String _title = '';
  double _amount = 0;
  String _type = 'Pemasukan';
  String _category = 'Lainnya';

  final List<String> _categories = [
    'Gaji', 'Makanan', 'Transportasi', 'Belanja', 'Hiburan', 'Lainnya',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.initialData != null) {
      _title = widget.initialData!['title'] ?? '';
      _amount = widget.initialData!['amount']?.toDouble() ?? 0;
      _type = widget.initialData!['type'] ?? 'Pemasukan';
      _category = widget.initialData!['category'] ?? 'Lainnya';

      _amountController.text = _formatCurrency(_amount.toInt());
    }

    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    String value = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (value.isEmpty) return;

    final formatted = _formatCurrency(int.parse(value));
    if (_amountController.text != formatted) {
      _amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  String _formatCurrency(int value) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(value);
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final raw = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
      _amount = double.tryParse(raw) ?? 0;

      Navigator.of(context).pop({
        'title': _title,
        'amount': _amount,
        'type': _type,
        'category': _category,
        'action': widget.initialData != null ? 'save' : 'add',
      });
    }
  }

  void _deleteTransaction() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Hapus Transaksi'),
        content: Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            child: Text('Batal'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog
              Navigator.of(context).pop({'action': 'delete'}); // Kirim sinyal hapus
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialData != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Transaksi' : 'Tambah Transaksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: 'Judul'),
                validator: (value) =>
                    value!.isEmpty ? 'Judul tidak boleh kosong' : null,
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Nominal'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Masukkan nominal' : null,
              ),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: InputDecoration(labelText: 'Tipe'),
                items: ['Pemasukan', 'Pengeluaran']
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => setState(() => _type = value!),
              ),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(labelText: 'Kategori'),
                items: _categories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (value) => setState(() => _category = value!),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Simpan'),
              ),
              if (isEdit)
                TextButton(
                  onPressed: _deleteTransaction,
                  child: Text('Hapus', style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
