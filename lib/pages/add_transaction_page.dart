import 'package:flutter/material.dart';

class AddTransactionPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  AddTransactionPage({this.initialData});

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
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
      _amount = widget.initialData!['amount'] ?? 0;
      _type = widget.initialData!['type'] ?? 'Pemasukan';
      _category = widget.initialData!['category'] ?? 'Lainnya';
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.of(context).pop({
        'title': _title,
        'amount': _amount,
        'type': _type,
        'category': _category,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialData == null ? 'Tambah Transaksi' : 'Edit Transaksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: 'Judul'),
                validator: (value) => value!.isEmpty ? 'Judul tidak boleh kosong' : null,
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                initialValue: _amount != 0 ? _amount.toString() : '',
                decoration: InputDecoration(labelText: 'Nominal'),
                keyboardType: TextInputType.number,
                validator: (value) => double.tryParse(value!.replaceAll('.', '')) == null
                    ? 'Masukkan nominal valid'
                    : null,
                onSaved: (value) => _amount = double.parse(value!.replaceAll('.', '')),
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
              ElevatedButton(onPressed: _submitForm, child: Text('Simpan')),
            ],
          ),
        ),
      ),
    );
  }
}
