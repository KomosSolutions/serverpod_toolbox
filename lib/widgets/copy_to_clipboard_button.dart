import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///
/// A button to copy the text to the clipboard
///
class CopyToClipboardButton extends StatelessWidget {
    final String textToCopy;

    const CopyToClipboardButton({super.key, required this.textToCopy});

    @override
    Widget build(BuildContext context) {
        return IconButton(
            icon: const Icon(Icons.copy, color: Colors.blue),
            tooltip: 'Copy command to clipboard',
            onPressed: () async {
                await Clipboard.setData(ClipboardData(text: textToCopy));
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Copied to clipboard: $textToCopy'),
                        duration: const Duration(seconds: 2),
                    ),
                );
            },
        );
    }
}
