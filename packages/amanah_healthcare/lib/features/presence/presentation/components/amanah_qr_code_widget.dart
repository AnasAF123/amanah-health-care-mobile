import 'package:flutter/material.dart';

class AmanahQrCodeWidget extends StatelessWidget {
  const AmanahQrCodeWidget({
    required this.value,
    super.key,
    this.size = 152.0,
    this.fgColor = const Color(0xFF0A0E1A),
    this.bgColor = Colors.white,
    this.borderRadius = 16.0,
  });

  final String value;
  final double size;
  final Color fgColor;
  final Color bgColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final List<List<bool>> matrix = _generateQrMatrix(value);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: CustomPaint(
            size: Size(size - 24, size - 24),
            painter: _QrMatrixPainter(
              matrix: matrix,
              fgColor: fgColor,
            ),
          ),
        ),
      ),
    );
  }

  static List<List<bool>> _generateQrMatrix(String text) {
    const int matrixSize = 25;
    final List<List<bool?>> matrix = List<List<bool?>>.generate(
      matrixSize,
      (_) => List<bool?>.filled(matrixSize, null),
    );

    void setModule(int r, int c, bool val) {
      if (r >= 0 && r < matrixSize && c >= 0 && c < matrixSize) {
        matrix[r][c] = val;
      }
    }

    void drawFinder(int startRow, int startCol) {
      for (int r = 0; r < 7; r++) {
        for (int c = 0; c < 7; c++) {
          if (r == 0 ||
              r == 6 ||
              c == 0 ||
              c == 6 ||
              (r >= 2 && r <= 4 && c >= 2 && c <= 4)) {
            setModule(startRow + r, startCol + c, true);
          } else {
            setModule(startRow + r, startCol + c, false);
          }
        }
      }
      for (int i = 0; i < 8; i++) {
        setModule(startRow - 1, startCol + i, false);
        setModule(startRow + 7, startCol + i, false);
        setModule(startRow + i, startCol - 1, false);
        setModule(startRow + i, startCol + 7, false);
      }
    }

    // 1. Finder patterns
    drawFinder(0, 0);
    drawFinder(0, matrixSize - 7);
    drawFinder(matrixSize - 7, 0);

    // 2. Alignment pattern at (18, 18)
    const int alignRow = 18;
    const int alignCol = 18;
    for (int r = -2; r <= 2; r++) {
      for (int c = -2; c <= 2; c++) {
        if (r.abs() == 2 || c.abs() == 2 || (r == 0 && c == 0)) {
          setModule(alignRow + r, alignCol + c, true);
        } else {
          setModule(alignRow + r, alignCol + c, false);
        }
      }
    }

    // 3. Timing patterns
    for (int i = 8; i < matrixSize - 8; i++) {
      final bool val = i.isEven;
      if (matrix[6][i] == null) {
        setModule(6, i, val);
      }
      if (matrix[i][6] == null) {
        setModule(i, 6, val);
      }
    }

    // 4. Dark module
    setModule(matrixSize - 8, 8, true);

    // 5. Seed data hash distribution based on payload string
    int hash = 0x811c9dc5;
    for (int i = 0; i < text.length; i++) {
      hash ^= text.codeUnitAt(i);
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }

    // Populate data area
    int bitIndex = 0;
    for (int col = matrixSize - 1; col > 0; col -= 2) {
      if (col == 6) {
        col--;
      }
      for (int count = 0; count < matrixSize; count++) {
        for (int cOffset = 0; cOffset < 2; cOffset++) {
          final int c = col - cOffset;
          final int row =
              (col ~/ 2).isEven ? count : matrixSize - 1 - count;

          if (matrix[row][c] == null) {
            final int charCode =
                text.codeUnitAt(bitIndex % text.length);
            final bool mask = (row + c).isEven;
            final int pseudoBit = ((hash >> (bitIndex % 31)) & 1) ^
                ((charCode >> (bitIndex % 8)) & 1);
            setModule(row, c, (pseudoBit == 1) != mask);
            bitIndex++;
          }
        }
      }
    }

    return matrix
        .map((List<bool?> row) =>
            row.map((bool? cell) => cell ?? false).toList())
        .toList();
  }
}

class _QrMatrixPainter extends CustomPainter {
  const _QrMatrixPainter({
    required this.matrix,
    required this.fgColor,
  });

  final List<List<bool>> matrix;
  final Color fgColor;

  @override
  void paint(Canvas canvas, Size size) {
    final int matrixSize = matrix.length;
    if (matrixSize == 0) {
      return;
    }

    final double cellSize = size.width / matrixSize;
    final Paint paint = Paint()
      ..color = fgColor
      ..style = PaintingStyle.fill;

    const double cornerRadius = 1.5;

    for (int r = 0; r < matrixSize; r++) {
      for (int c = 0; c < matrixSize; c++) {
        if (matrix[r][c]) {
          final Rect rect = Rect.fromLTWH(
            c * cellSize,
            r * cellSize,
            cellSize,
            cellSize,
          );
          final RRect rrect = RRect.fromRectAndRadius(
            rect,
            const Radius.circular(cornerRadius),
          );
          canvas.drawRRect(rrect, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrMatrixPainter oldDelegate) {
    return oldDelegate.matrix != matrix || oldDelegate.fgColor != fgColor;
  }
}
