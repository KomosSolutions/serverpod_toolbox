import 'package:flutter/material.dart';

///
/// A scrollable area widget that shows the scrollbar if the content is scrollable.
///
class ScrollableArea extends StatefulWidget {
    final Widget child;

    const ScrollableArea({super.key, required this.child});

    @override
    State<ScrollableArea> createState() => _ScrollableAreaState();
}

class _ScrollableAreaState extends State<ScrollableArea> {
    final ScrollController _scrollController = ScrollController();

    @override
    void dispose() {
        _scrollController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        const double scrollbarThickness = 10.0; // wider scrollbar

        return ScrollbarTheme(
            data: ScrollbarThemeData(
                thumbColor: WidgetStateProperty.all(Colors.grey.shade300), // light grey
                trackColor: WidgetStateProperty.all(Colors.transparent),
                trackBorderColor: WidgetStateProperty.all(Colors.transparent),
                thickness: WidgetStateProperty.all(scrollbarThickness),
                radius: const Radius.circular(0), // square top/bottom
                crossAxisMargin: 0,
                mainAxisMargin: 0,
                minThumbLength: 48.0,
            ),
            child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                trackVisibility: true,
                child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(right: scrollbarThickness+5),
                    child: widget.child,
                ),
            ),
        );
    }
}
