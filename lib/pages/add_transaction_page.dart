import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AddTransactionPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const AddTransactionPage({super.key, this.initialData});

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String _type = 'Pemasukan';
  String _category = 'Lainnya';

  final List<String> _categories = [
    'Gaji',
    'Makanan',
    'Transportasi',
    'Belanja',
    'Hiburan',
    'Kesehatan',
    'Pendidikan',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.initialData != null) {
      _titleController.text = widget.initialData!['title'] ?? '';
      _type = widget.initialData!['type'] ?? 'Pemasukan';
      _category = widget.initialData!['category'] ?? 'Lainnya';

      final amount = widget.initialData!['amount'];
      if (amount != null) {
        _amountController.text = _formatCurrency(amount);
      }
    }

    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
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

  int _parseAmountFromFormatted(String formatted) {
    final raw = formatted.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(raw) ?? 0;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final amount = _parseAmountFromFormatted(_amountController.text);

      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nominal harus lebih dari 0'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Navigator.of(context).pop({
        'title': _titleController.text.trim(),
        'amount': amount,
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
              Navigator.of(context)
                  .pop({'action': 'delete'}); // Kirim sinyal hapus
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
        elevation: 2,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Transaksi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Judul Transaksi',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Judul tidak boleh kosong';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Nominal',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                        helperText: 'Masukkan angka tanpa titik atau koma',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan nominal';
                        }
                        final amount = _parseAmountFromFormatted(value);
                        if (amount <= 0) {
                          return 'Nominal harus lebih dari 0';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _type,
                      decoration: InputDecoration(
                        labelText: 'Tipe Transaksi',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.swap_vert),
                      ),
                      items: ['Pemasukan', 'Pengeluaran']
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Row(
                                  children: [
                                    Icon(
                                      type == 'Pemasukan'
                                          ? Icons.arrow_downward
                                          : Icons.arrow_upward,
                                      color: type == 'Pemasukan'
                                          ? Colors.green
                                          : Colors.red,
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Text(type),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => _type = value!),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _categories
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => _category = value!),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(
                isEdit ? 'Simpan Perubahan' : 'Tambah Transaksi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            if (isEdit) ...[
              SizedBox(height: 16),
              OutlinedButton(
                onPressed: _deleteTransaction,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red),
                ),
                child: Text(
                  'Hapus Transaksi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
