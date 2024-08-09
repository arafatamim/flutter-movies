import 'package:flutter/material.dart';
import 'package:ticker_text/ticker_text.dart';

class MetaLabel extends StatelessWidget {
  final String label;
  final Widget? leading;
  final bool hasBackground;
  final String? title;

  const MetaLabel(
    this.label, {
    super.key,
    this.hasBackground = false,
    this.leading,
    this.title,
  });

  Widget? _buildLeading() {
    if (leading is Icon) {
      final icon = leading as Icon;
      return Icon(
        icon.icon,
        color: Colors.grey.shade300,
        size: 20,
      );
    } else if (leading is Image) {
      final image = leading as Image;
      return Image(
        image: image.image,
        width: 30,
        height: 30,
      );
    } else {
      return leading;
    }
  }

  Widget _buildTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade300.withAlpha(200),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        title!.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade900,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (title != null) ...[
          _buildTitle(),
          const SizedBox(width: 10),
        ],
        if (_buildLeading() != null) ...[
          _buildLeading()!,
          const SizedBox(width: 10),
        ],
        Flexible(
          flex: 0,
          child: Container(
            padding: hasBackground
                ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
                : null,
            decoration: hasBackground
                ? BoxDecoration(
                    color: Colors.grey.shade300.withAlpha(200),
                    borderRadius: BorderRadius.circular(6),
                  )
                : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 300,
              ), // TODO don't hardcode width
              child: TickerText(
                scrollDirection: Axis.horizontal,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: hasBackground
                            ? Colors.grey.shade900
                            : Colors.grey.shade200,
                        fontWeight:
                            hasBackground ? FontWeight.bold : FontWeight.normal,
                        fontSize: hasBackground ? 14 : 16,
                      ),
                ),
              ),
            ),
          ),
        ),
        MediaQuery.of(context).size.width > 720
            ? const SizedBox(width: 30)
            : const SizedBox(width: 15),
      ],
    );
  }
}
