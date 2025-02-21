import 'package:flutter/material.dart';

class ResizableLogOutput extends StatelessWidget {
    final TextEditingController logController;

    const ResizableLogOutput({super.key, required this.logController});

    @override
    Widget build(BuildContext context) {
        return DraggableScrollableSheet(
            initialChildSize: 0.6, // Initial height as a fraction of the screen height
            minChildSize: 0.2, // Minimum height fraction of the screen height
            maxChildSize: 0.6, // Maximum height fraction of the screen height
            builder: (BuildContext context, ScrollController scrollController) {
                return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        color: Colors.white,
                    ),
                    child: ListView(
                        children: [
                            TextField(
                                controller: logController,
                                readOnly: true,
                                maxLines: null,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    labelText: 'Log Output',
                                ),
                            ),
                        ],
                    ),
                );
            },
        );
    }
}
