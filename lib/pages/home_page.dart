import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/models/transaction.dart';
import 'add_transaction_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Transaction> _transactions = [];

  void _navigateToAddTransaction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTransactionPage()),
    );

    if (result != null) {
      final newTx = Transaction(
        id: DateTime.now().toString(),
        title: result['title'],
        amount: result['amount'],
        type: result['type'],
        category: result['category'],
        date: DateTime.now(),
      );
      setState(() => _transactions.add(newTx));
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }

  double _calculateTotalByType(String type) {
    return _transactions
        .where((tx) => tx.type == type)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double _calculateTotalBalance() {
    double income = _calculateTotalByType('Pemasukan');
    double expense = _calculateTotalByType('Pengeluaran');
    return income - expense;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Catatan Keuangan'), centerTitle: true),
      body: Padding(
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
            Text('Transaksi Terbaru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  final tx = _transactions[index];
                  return ListTile(
                    leading: CircleAvatar(child: Icon(Icons.monetization_on)),
                    title: Text(tx.title),
                    subtitle:
                        Text('${_formatCurrency(tx.amount)} - ${tx.type} • ${tx.category}'),
                    trailing: Text(DateFormat('dd/MM/yyyy').format(tx.date)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTransaction,
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
        ],
      ),
    );
  }
}
