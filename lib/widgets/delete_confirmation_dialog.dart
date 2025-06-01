import 'package:flutter/material.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String itemName;
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.itemName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Deletion'),
      content: Text(
          'Are you sure you want to delete "$itemName"? This action cannot be undone.'),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: onConfirm,
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
