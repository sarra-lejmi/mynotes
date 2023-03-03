import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: "LogOut",
    content: "Are you sure you want to logout?",
    optionBuilder: () => {
      "cancel": false,
      "LogOut": true,
    },
  ).then((value) => value ?? false);
}
