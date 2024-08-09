import 'package:flutter/material.dart';
import 'package:flutter_movies/models/models.dart';

class SlimCover extends StatelessWidget {
  final String title;
  final String? subtitle1;
  final String? subtitle2;
  final ImageUris? imageUris;
  final void Function()? onPressed;
  final void Function()? onLongPress;
  final FocusNode? focusNode;

  const SlimCover({
    super.key,
    required this.title,
    this.subtitle1,
    this.subtitle2,
    this.imageUris,
    this.onPressed,
    this.onLongPress,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(),
      child: RawMaterialButton(
        focusNode: focusNode,
        onLongPress: onLongPress,
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        fillColor: Colors.white10,
        elevation: 0,
        disabledElevation: 0,
        hoverElevation: 0,
        focusElevation: 0,
        highlightElevation: 0,
        child: Container(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(width: 1, color: Colors.white12),
            ),
            child: Row(
              children: [
                if (imageUris?.backdrop != null)
                  ClipRRect(
                    child: SizedBox(
                      height: 100,
                      width: 150,
                      child: Image.network(
                        imageUris!.backdrop!,
                        fit: BoxFit.cover,
                      ),
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 20),
                      ),
                      if (subtitle1 != null)
                        Text(
                          subtitle1!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      if (subtitle2 != null)
                        Text(
                          subtitle2!.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
