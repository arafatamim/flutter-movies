import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerList extends StatelessWidget {
  final int itemCount;

  const ShimmerList({super.key, this.itemCount = 10});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (int i = 0; i < itemCount; i++)
            const ShimmerItem(child: CoverShimmer())
        ],
      ),
    );
    // child: GridView.builder(
    //   shrinkWrap: true,
    //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    //     crossAxisCount: 5,
    //     childAspectRatio: 0.55,
    //   ),
    //   itemCount: itemCount,
    //   itemBuilder: (context, index) => const ShimmerItem(
    //     child: CoverShimmer(),
    //   ),
    // ),
  }
}

class ShimmerItem extends StatelessWidget {
  final Widget child;
  const ShimmerItem({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      child: child,
      baseColor: Colors.grey.shade700,
      highlightColor: Colors.grey.shade600,
    );
  }
}

class CoverShimmer extends StatelessWidget {
  final Color color = Colors.white;

  const CoverShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Container(
        width: 200,
        height: 150,
      ),
    );
  }
}

class SlimCoverShimmer extends StatelessWidget {
  const SlimCoverShimmer({super.key});

  final color = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerItem(child: Container(height: 25, width: 500, color: color)),
          const SizedBox(height: 8),
          Row(
            children: [
              ShimmerItem(
                  child: Container(color: color, width: 200, height: 150)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerItem(
                      child: Container(width: 250, color: color, height: 25),
                    ),
                    const SizedBox(height: 8),
                    ShimmerItem(
                      child: Container(width: 200, color: color, height: 25),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class SpotlightShimmer extends StatelessWidget {
  final color = Colors.white;
  const SpotlightShimmer();
  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 500,
      // height: 500,
      color: color,
    );
  }
}
