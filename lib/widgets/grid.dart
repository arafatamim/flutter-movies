import 'package:flutter/material.dart';

class Grid extends StatelessWidget {
  final int columnCount;
  final double? gap;
  final EdgeInsets? padding;
  final List<Widget> children;

  const Grid({
    super.key,
    this.columnCount = 4,
    this.gap,
    this.padding,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: FocusTraversalGroup(
        policy: ReadingOrderTraversalPolicy(),
        child: Column(
          children: _createRows(),
        ),
      ),
    );
  }

  List<Widget> _createRows() {
    final List<Widget> rows = [];
    final rowCount = (children.length / columnCount).ceil();

    for (int rowIndex = 0; rowIndex < rowCount; rowIndex++) {
      final List<Widget> columns = _createRowCells(rowIndex);
      rows.add(Row(children: columns));
      if (rowIndex != rowCount - 1) {
        rows.add(SizedBox(height: gap));
      }
    }
    return rows;
  }

  List<Widget> _createRowCells(int rowIndex) {
    final List<Widget> columns = [];

    for (int columnIndex = 0; columnIndex < columnCount; columnIndex++) {
      final cellIndex = rowIndex * columnCount + columnIndex;
      if (cellIndex <= children.length - 1) {
        columns.add(Expanded(child: children[cellIndex]));
      } else {
        columns.add(Expanded(child: Container()));
      }
      if (columnIndex != columnCount - 1) {
        columns.add(SizedBox(width: gap));
      }
    }
    return columns;
  }
}
