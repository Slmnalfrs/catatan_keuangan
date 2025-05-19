import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/models/transaction.dart';

class ListTransactionPage extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(int) onTapItem;

  const ListTransactionPage({
    required this.transactions,
    required this.onTapItem,
  });

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: transactions.isEmpty
          ? Center(child: Text('Belum ada transaksi.'))
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      tx.type == 'Pemasukan' ? Icons.arrow_downward : Icons.arrow_upward,
                      color: tx.type == 'Pemasukan' ? Colors.green : Colors.red,
                    ),
                    title: Text(tx.title),
                    subtitle: Text('${tx.category} • ${DateFormat('dd/MM/yyyy').format(tx.date)}'),
                    trailing: Text(
                      _formatCurrency(tx.amount),
                      style: TextStyle(
                        color: tx.type == 'Pemasukan' ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => onTapItem(index),
                  ),
                );
              },
            ),
    );
  }
}
