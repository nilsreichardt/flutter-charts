import 'dart:math';
import 'dart:ui';

import 'package:charts_painter/chart.dart';
import 'package:example/widgets/chart_options.dart';
import 'package:example/widgets/toggle_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScrollableChartScreen extends StatefulWidget {
  ScrollableChartScreen({Key key}) : super(key: key);

  @override
  _ScrollableChartScreenState createState() => _ScrollableChartScreenState();
}

class _ScrollableChartScreenState extends State<ScrollableChartScreen> {
  List<double> _values = <double>[];
  double targetMax;
  bool _showValues = false;
  bool _smoothPoints = false;
  bool _showBars = true;
  bool _isScrollable = true;
  bool _fixedAxis = false;
  int minItems = 30;
  int _selected;

  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _updateValues();
  }

  void _updateValues() {
    final Random _rand = Random();
    final double _difference = _rand.nextDouble() * 15;

    targetMax = 3 +
        ((_rand.nextDouble() * _difference * 0.75) - (_difference * 0.25))
            .roundToDouble();
    _values.addAll(List.generate(minItems, (index) {
      return 2 + _rand.nextDouble() * _difference;
    }));
  }

  void _addValues() {
    _values = List.generate(minItems, (index) {
      if (_values.length > index) {
        return _values[index];
      }

      return 2 + Random().nextDouble() * targetMax;
    });
  }

  @override
  Widget build(BuildContext context) {
    final targetArea = TargetAreaDecoration(
      targetMax: targetMax + 2,
      targetMin: targetMax,
      colorOverTarget: Theme.of(context)
          .colorScheme
          .error
          .withOpacity(_showBars ? 1.0 : 0.0),
      targetAreaFillColor: Theme.of(context).colorScheme.error.withOpacity(0.2),
      targetLineColor: Theme.of(context).colorScheme.error,
      targetAreaRadius: BorderRadius.circular(12.0),
    );

    final _chartState = ChartState(
      ChartData.fromList(
        _values.map((e) => BarValue<void>(e)).toList(),
        axisMax: 20,
        axisMin: -10,
      ),
      itemOptions: BarItemOptions(
        padding: EdgeInsets.symmetric(horizontal: _isScrollable ? 12.0 : 2.0),
        minBarWidth: _isScrollable ? 36.0 : 4.0,
        // isTargetInclusive: true,
        color: Theme.of(context)
            .colorScheme
            .primary
            .withOpacity(_showBars ? 1.0 : 0.0),
        radius: const BorderRadius.vertical(
          top: Radius.circular(24.0),
        ),
        colorForValue: targetArea.getTargetItemColor(),
      ),
      behaviour: ChartBehaviour(
        isScrollable: _isScrollable,
        onItemClicked: (item) {
          setState(() {
            _selected = item;
          });
        },
      ),
      backgroundDecorations: [
        HorizontalAxisDecoration(
          endWithChart: false,
          lineWidth: 2.0,
          axisStep: 2,
          lineColor:
              Theme.of(context).colorScheme.primaryVariant.withOpacity(0.2),
        ),
        VerticalAxisDecoration(
          endWithChart: false,
          lineWidth: 2.0,
          axisStep: 7,
          lineColor:
              Theme.of(context).colorScheme.primaryVariant.withOpacity(0.8),
        ),
        GridDecoration(
          endWithChart: false,
          showVerticalGrid: true,
          showHorizontalValues: _fixedAxis ? false : _showValues,
          showVerticalValues: _fixedAxis ? true : _showValues,
          verticalValuesPadding: const EdgeInsets.symmetric(vertical: 12.0),
          verticalAxisStep: 1,
          horizontalAxisStep: 1,
          textStyle: Theme.of(context).textTheme.caption,
          gridColor:
              Theme.of(context).colorScheme.primaryVariant.withOpacity(0.2),
        ),
        targetArea,
        SparkLineDecoration(
          fill: true,
          lineColor: Theme.of(context)
              .primaryColor
              .withOpacity(!_showBars ? 0.2 : 0.0),
          smoothPoints: _smoothPoints,
        ),
      ],
      foregroundDecorations: [
        ValueDecoration(
          alignment: _showBars ? Alignment.bottomCenter : Alignment(0.0, -1.0),
          textStyle: Theme.of(context).textTheme.button.copyWith(
              color: (_showBars
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.primary)
                  .withOpacity(_isScrollable ? 1.0 : 0.0)),
        ),
        SparkLineDecoration(
          lineWidth: 2.0,
          lineColor: Theme.of(context)
              .primaryColor
              .withOpacity(!_showBars ? 1.0 : 0.0),
          smoothPoints: _smoothPoints,
        ),
        SelectedItemDecoration(
          _selected,
          animate: true,
          selectedColor: Theme.of(context).colorScheme.secondary,
          backgroundColor: Theme.of(context)
              .scaffoldBackgroundColor
              .withOpacity(_isScrollable ? 0.5 : 0.8),
        ),
        BorderDecoration(
          endWithChart: true,
          color: Theme.of(context).colorScheme.primaryVariant,
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scrollable chart',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: _isScrollable
                        ? ScrollPhysics()
                        : NeverScrollableScrollPhysics(),
                    controller: _controller,
                    scrollDirection: Axis.horizontal,
                    child: Chart(
                      width: MediaQuery.of(context).size.width - 24.0,
                      height: MediaQuery.of(context).size.height * 0.4,
                      state: _chartState,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 350),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.0),
                        ],
                        stops: [
                          0.5,
                          1.0
                        ]),
                  ),
                  width: _fixedAxis ? 14.0 : 0.0,
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: DecorationsRenderer(
                    _fixedAxis
                        ? [
                            HorizontalAxisDecoration(
                              lineWidth: 1.0,
                              axisStep: 1,
                              showValues: true,
                              legendFontStyle:
                                  Theme.of(context).textTheme.caption,
                              valuesAlign: TextAlign.center,
                              lineColor: Theme.of(context)
                                  .colorScheme
                                  .primaryVariant
                                  .withOpacity(0.2),
                            )
                          ]
                        : [],
                    _chartState,
                  ),
                )
              ],
            ),
          ),
          Flexible(
            child: ChartOptionsWidget(
              onRefresh: () {
                setState(() {
                  _values.clear();
                  _updateValues();
                });
              },
              onAddItems: () {
                setState(() {
                  minItems += 4;
                  _addValues();
                });
              },
              onRemoveItems: () {
                setState(() {
                  if (_values.length > 4) {
                    minItems -= 4;
                    _values.removeRange(_values.length - 4, _values.length);
                  }
                });
              },
              toggleItems: [
                ToggleItem(
                  title: 'Axis values',
                  value: _showValues,
                  onChanged: (value) {
                    setState(() {
                      _showValues = value;
                    });
                  },
                ),
                ToggleItem(
                  title: 'Fixed axis',
                  value: _fixedAxis,
                  onChanged: (value) {
                    setState(() {
                      _fixedAxis = value;
                    });
                  },
                ),
                ToggleItem(
                  value: _showBars,
                  title: 'Show bar items',
                  onChanged: (value) {
                    setState(() {
                      _showBars = value;
                    });
                  },
                ),
                ToggleItem(
                  value: _smoothPoints,
                  title: 'Smooth line curve',
                  onChanged: (value) {
                    setState(() {
                      _smoothPoints = value;
                    });
                  },
                ),
                ToggleItem(
                  value: _isScrollable,
                  title: 'Scrollable',
                  onChanged: (value) {
                    setState(() {
                      _isScrollable = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
