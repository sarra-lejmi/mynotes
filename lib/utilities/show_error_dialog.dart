import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, error) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("An Error Occured"),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}
