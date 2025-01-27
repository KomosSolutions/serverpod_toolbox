import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

///
/// A default button for the app.  Contains style and progress indicator
///
class DefaultButton extends StatelessWidget {
    final String text;
    final bool isLoading;
    final VoidCallback? onPressed;

    const DefaultButton({
        super.key,
        required this.text,
        required this.onPressed,
        this.isLoading = false,
    });

    @override
    Widget build(BuildContext context) {
        return ElevatedButton(
            onPressed: isLoading ? null : onPressed, // Disable button when loading
            style: isLoading
                ? AppTheme.standardButtonStyle().copyWith(
                    backgroundColor: WidgetStateProperty.all(Colors.grey), // Grey out background
                    foregroundColor: WidgetStateProperty.all(Colors.white54) // Optional: Lighten text color
                )
                : AppTheme.standardButtonStyle(),
            child: Text(text), // Always show the text
        );
    }
}
