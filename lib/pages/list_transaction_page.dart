import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/models/transaction.dart';

class ListTransactionPage extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(int) onTapItem;

  const ListTransactionPage({
    required this.transactions,
    required this.onTapItem,
    super.key,
  });

  String _formatCurrency(double amount) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: transactions.isEmpty
          ? Center(
              child: Text(
                'Belum ada transaksi.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.separated(
              itemCount: transactions.length,
              separatorBuilder: (_, __) => SizedBox(height: 8),
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final isIncome = tx.type == 'Pemasukan';

                return GestureDetector(
                  onTap: () => onTapItem(index),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: isIncome ? Colors.green[100] : Colors.red[100],
                        child: Icon(
                          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isIncome ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(
                        tx.title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${tx.category} • ${DateFormat('dd MMM yyyy').format(tx.date)}',
                      ),
                      trailing: Text(
                        _formatCurrency(tx.amount),
                        style: TextStyle(
                          color: isIncome ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
