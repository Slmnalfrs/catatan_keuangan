import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/models/transaction.dart';
import 'add_transaction_page.dart';
import 'list_transaction_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Transaction> _transactions = [];

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final response = await supabase
        .from('transactions')
        .select()
        .order('date', ascending: false);

    setState(() {
      _transactions = response
          .map((map) => Transaction.fromMap(map))
          .toList()
          .cast<Transaction>();
    });
  }

  Future<void> _navigateToAddTransaction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTransactionPage()),
    );

    if (result != null && result['action'] == 'add') {
      await supabase.from('transactions').insert({
        'title': result['title'],
        'amount': result['amount'],
        'type': result['type'],
        'category': result['category'],
        'date': DateTime.now().toIso8601String(),
      });

      _loadTransactions();
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
      if (result['action'] == 'delete') {
        await supabase.from('transactions').delete().eq('id', tx.id);
      } else if (result['action'] == 'save') {
        await supabase.from('transactions').update({
          'title': result['title'],
          'amount': result['amount'],
          'type': result['type'],
          'category': result['category'],
          'date': DateTime.now().toIso8601String(),
        }).eq('id', tx.id);
      }

      _loadTransactions();
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.green[100],
            child: ListTile(
              title: Text('Total Saldo', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text('Pemasukan', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(
                          _formatCurrency(_calculateTotalByType('Pemasukan')),
                          style: TextStyle(fontSize: 16, color: Colors.blue[900]),
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
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text('Pengeluaran', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(
                          _formatCurrency(_calculateTotalByType('Pengeluaran')),
                          style: TextStyle(fontSize: 16, color: Colors.red[900]),
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
            child: _transactions.isEmpty
                ? Center(child: Text('Belum ada transaksi'))
                : ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final tx = _transactions[index];
                      return ListTile(
                        leading: CircleAvatar(child: Icon(Icons.monetization_on)),
                        title: Text(tx.title),
                        subtitle: Text(
                            '${_formatCurrency(tx.amount)} - ${tx.type} • ${tx.category}'),
                        trailing: Text(DateFormat('dd/MM/yyyy').format(tx.date)),
                        onTap: () => _navigateToEditTransaction(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
  return ListTransactionPage(
    transactions: _transactions,
    onTapItem: (tx) {
      final index = _transactions.indexWhere((t) => t.id == tx.id);
      _navigateToEditTransaction(index);
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final tabs = [_buildHomeTab(), _buildHistoryTab()];

    return Scaffold(
      appBar: AppBar(title: Text('Catatan Keuangan'), centerTitle: true),
      body: tabs[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTransaction,
        child: Icon(Icons.add),
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
