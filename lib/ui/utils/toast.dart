import "package:flutter/material.dart";
import "package:telemed_chat/src/colors.dart";

void showSnackBarMessage({
  required String message,
  required BuildContext context,
  Widget? icon,
  Color messageColor = black900,
}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      content: Row(
        children: [
          if (icon != null) icon,
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                color: messageColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    ),
  );
}
