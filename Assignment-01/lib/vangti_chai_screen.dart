import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'change_calculator.dart';
import 'ui_constants.dart';

class VangtiChaiScreen extends StatefulWidget {
  const VangtiChaiScreen({super.key});

  @override
  State<VangtiChaiScreen> createState() => _VangtiChaiScreenState();
}

class _VangtiChaiScreenState extends State<VangtiChaiScreen>
    with RestorationMixin {
  final _digits = RestorableString('');

  @override
  String get restorationId => 'change_screen';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_digits, 'entered_digits');
  }

  @override
  void dispose() {
    _digits.dispose();
    super.dispose();
  }

  void _enterDigit(String digit) {
    setState(() {
      _digits.value = _digits.value == '0' ? digit : '${_digits.value}$digit';
    });
  }

  void _clear() {
    setState(() => _digits.value = '');
  }

  @override
  Widget build(BuildContext context) {
    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final tablet =
        MediaQuery.sizeOf(context).shortestSide >= UiConstants.tabletBreakpoint;
    final scaler = MediaQuery.textScalerOf(context);
    final fontSize = tablet
        ? UiConstants.tabletFontSize
        : UiConstants.phoneFontSize;
    final amountFontSize = tablet
        ? UiConstants.tabletAmountFontSize
        : UiConstants.phoneAmountFontSize;
    final padding = tablet
        ? UiConstants.tabletPadding
        : landscape
        ? UiConstants.gap
        : UiConstants.phonePadding;
    final sectionGap = tablet
        ? UiConstants.tabletSectionGap
        : landscape
        ? UiConstants.gap
        : UiConstants.sectionGap;
    final textHeight = scaler.scale(fontSize) * UiConstants.lineHeight;
    final noteHeight = math.max(
      tablet ? UiConstants.tabletNoteHeight : UiConstants.phoneNoteHeight,
      textHeight + UiConstants.gap * 2,
    );
    final keyHeight = math.max(
      tablet ? UiConstants.tabletKeyHeight : UiConstants.phoneKeyHeight,
      textHeight + UiConstants.gap * 2,
    );
    final amountHeight = math.max(
      tablet
          ? UiConstants.tabletAmountHeight
          : landscape
          ? UiConstants.phoneLandscapeAmountHeight
          : UiConstants.phoneAmountHeight,
      scaler.scale(amountFontSize) * UiConstants.lineHeight,
    );
    final counts = calculateChange(
      _digits.value.isEmpty ? BigInt.zero : BigInt.parse(_digits.value),
    );
    final keypadRows = landscape ? 3 : 4;
    final minimumKeypadHeight =
        keyHeight * keypadRows + UiConstants.gap * (keypadRows - 1);
    final minimumBodyHeight = math.max(
      noteHeight * (landscape ? 4 : 8),
      minimumKeypadHeight,
    );

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: math.max(
          kToolbarHeight,
          scaler.scale(UiConstants.titleFontSize) * UiConstants.lineHeight +
              UiConstants.gap * 2,
        ),
        title: const Text('VangtiChai', maxLines: 1),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: landscape
                  ? UiConstants.landscapeMaxWidth
                  : UiConstants.portraitMaxWidth,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableHeight =
                    constraints.maxHeight -
                    padding * 2 -
                    amountHeight -
                    sectionGap;
                final bodyHeight = math.max(
                  minimumBodyHeight,
                  math.min(
                    availableHeight,
                    landscape
                        ? UiConstants.landscapeMaxBodyHeight
                        : UiConstants.portraitMaxBodyHeight,
                  ),
                );

                // Small windows and large accessibility text can scroll vertically.
                return SingleChildScrollView(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: amountHeight,
                        child: Center(
                          child: Semantics(
                            liveRegion: true,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              reverse: true,
                              child: Text(
                                _digits.value.isEmpty
                                    ? 'Taka:'
                                    : 'Taka: ${_digits.value}',
                                key: const ValueKey('amount'),
                                semanticsLabel:
                                    'Amount: ${_digits.value.isEmpty ? '0' : _digits.value} Taka',
                                style: TextStyle(
                                  color: UiConstants.foreground,
                                  fontSize: amountFontSize,
                                  height: UiConstants.lineHeight,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: sectionGap),
                      SizedBox(
                        height: bodyHeight,
                        child: Row(
                          children: [
                            Expanded(
                              flex: landscape ? 1 : 2,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _noteColumn(
                                      landscape
                                          ? takaDenominations.take(4)
                                          : takaDenominations,
                                      counts,
                                      fontSize,
                                    ),
                                  ),
                                  if (landscape) ...[
                                    const SizedBox(width: UiConstants.gap),
                                    Expanded(
                                      child: _noteColumn(
                                        takaDenominations.skip(4),
                                        counts,
                                        fontSize,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            SizedBox(width: sectionGap),
                            Expanded(
                              flex: landscape ? 1 : 5,
                              child: _keypad(
                                landscape: landscape,
                                fontSize: fontSize,
                                rowHeight: landscape
                                    ? (bodyHeight -
                                              UiConstants.gap *
                                                  (keypadRows - 1)) /
                                          keypadRows
                                    : keyHeight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _noteColumn(
    Iterable<int> denominations,
    Map<int, BigInt> counts,
    double fontSize,
  ) {
    // Preserve full counts at any input length or text scale, without ellipses.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final note in denominations)
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '$note: ${counts[note]}',
                  key: ValueKey('note-$note'),
                  semanticsLabel: '${counts[note]} notes of $note Taka',
                  softWrap: false,
                  style: TextStyle(
                    color: UiConstants.foreground,
                    fontSize: fontSize,
                    height: UiConstants.lineHeight,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _keypad({
    required bool landscape,
    required double fontSize,
    required double rowHeight,
  }) {
    final rows = landscape
        ? const [
            ['1', '2', '3', '4'],
            ['5', '6', '7', '8'],
            ['9', '0', 'CLEAR'],
          ]
        : const [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
            ['0', 'CLEAR'],
          ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = landscape ? 4 : 3;
        final keyWidth =
            (constraints.maxWidth - UiConstants.gap * (columns - 1)) / columns;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var row = 0; row < rows.length; row++) ...[
              if (row > 0) const SizedBox(height: UiConstants.gap),
              SizedBox(
                height: rowHeight,
                child: Row(
                  children: [
                    for (
                      var column = 0;
                      column < rows[row].length;
                      column++
                    ) ...[
                      if (column > 0) const SizedBox(width: UiConstants.gap),
                      SizedBox(
                        width: rows[row][column] == 'CLEAR'
                            ? keyWidth * 2 + UiConstants.gap
                            : keyWidth,
                        child: _key(rows[row][column], fontSize),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _key(String label, double fontSize) {
    return SizedBox.expand(
      child: TextButton(
        key: ValueKey('key-$label'),
        onPressed: label == 'CLEAR' ? _clear : () => _enterDigit(label),
        style: TextButton.styleFrom(
          foregroundColor: UiConstants.foreground,
          backgroundColor: UiConstants.keyBackground,
          minimumSize: const Size.square(UiConstants.minimumTouchTarget),
          padding: const EdgeInsets.all(UiConstants.gap),
          shape: const RoundedRectangleBorder(),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: TextStyle(
            fontFamily: UiConstants.fontFamily,
            fontSize: fontSize,
            height: UiConstants.lineHeight,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            semanticsLabel: label == 'CLEAR' ? 'Clear amount' : label,
          ),
        ),
      ),
    );
  }
}
