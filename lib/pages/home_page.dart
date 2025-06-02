import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction.dart';
import 'add_transaction_page.dart';
import 'list_transaction_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await supabase
          .from('transactions')
          .select()
          .order('date', ascending: false);

      if (mounted) {
        setState(() {
          _transactions = (response as List)
              .map((map) => Transaction.fromMap(map as Map<String, dynamic>))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Gagal Memuat Transaksi: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Gagal'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _navigateToAddTransaction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTransactionPage()),
    );

    if (result != null && result['action'] == 'add') {
      try {
        await supabase.from('transactions').insert({
          'title': result['title'],
          'amount': result['amount'],
          'type': result['type'],
          'category': result['category'],
          'date': DateTime.now().toIso8601String(),
        });

        _showSuccessSnackbar('Transaksi berhasil ditambahkan');
        await _loadTransactions();
      } catch (e) {
        _showErrorDialog('Gagal Menambahkan Transaksi: $e');
      }
    }
  }

  Future<void> _navigateToEditTransaction(int index) async {
    final tx = _transactions[index];

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionPage(
          initialData: {
            'title': tx.title,
            'amount': tx.amount,
            'type': tx.type,
            'category': tx.category,
          },
        ),
      ),
    );

    if (result != null) {
      try {
        if (result['action'] == 'delete') {
          await supabase.from('transactions').delete().eq('id', tx.id);
          _showSuccessSnackbar('Transaksi berhasil dihapus');
        } else if (result['action'] == 'save') {
          await supabase.from('transactions').update({
            'title': result['title'],
            'amount': result['amount'],
            'type': result['type'],
            'category': result['category'],
          }).eq('id', tx.id);
          _showSuccessSnackbar('Transaksi berhasil diperbarui');
        }

        await _loadTransactions();
      } catch (e) {
        _showErrorDialog('Gagal Memperbarui Transaksi: $e');
      }
    }
  }

  double _calculateTotalByType(String type) {
    return _transactions
        .where((tx) => tx.type == type)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double _calculateTotalBalance() {
    final income = _calculateTotalByType('Pemasukan');
    final expense = _calculateTotalByType('Pengeluaran');
    return income - expense;
  }

  String _formatCurrency(double amount) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.green[100],
              elevation: 4,
              child: ListTile(
                title: Text('Total Saldo',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  _formatCurrency(_calculateTotalBalance()),
                  style: TextStyle(fontSize: 24, color: Colors.green[900]),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.blue[100],
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text('Pemasukan',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text(
                            _formatCurrency(_calculateTotalByType('Pemasukan')),
                            style: TextStyle(
                                fontSize: 16, color: Colors.blue[900]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Card(
                    color: Colors.red[100],
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text('Pengeluaran',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text(
                            _formatCurrency(
                                _calculateTotalByType('Pengeluaran')),
                            style:
                                TextStyle(fontSize: 16, color: Colors.red[900]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('Transaksi Terbaru',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _transactions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long,
                                  size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('Belum ada transaksi',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _transactions.length > 5
                              ? 5
                              : _transactions.length,
                          itemBuilder: (context, index) {
                            final tx = _transactions[index];
                            return Card(
                              elevation: 2,
                              margin: EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: tx.type == 'Pemasukan'
                                      ? Colors.green[100]
                                      : Colors.red[100],
                                  child: Icon(
                                    tx.type == 'Pemasukan'
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color: tx.type == 'Pemasukan'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                title: Text(tx.title),
                                subtitle: Text(
                                    '${_formatCurrency(tx.amount.toDouble())} - ${tx.type} • ${tx.category}'),
                                trailing: Text(
                                    DateFormat('dd/MM/yyyy').format(tx.date)),
                                onTap: () => _navigateToEditTransaction(index),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListTransactionPage(
      transactions: _transactions,
      isLoading: _isLoading,
      onRefresh: _loadTransactions,
      onTapItem: (tx) {
        final index = _transactions.indexWhere((t) => t.id == tx.id);
        if (index != -1) {
          _navigateToEditTransaction(index);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [_buildHomeTab(), _buildHistoryTab()];

    return Scaffold(
      appBar: AppBar(
        title: Text('Catatan Keuangan'),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadTransactions,
          ),
        ],
      ),
      body: tabs[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTransaction,
        child: Icon(Icons.add),
        tooltip: 'Tambah Transaksi',
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
        ],
      ),
    );
  }
}
