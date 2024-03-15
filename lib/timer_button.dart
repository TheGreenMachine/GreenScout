import 'dart:async';

import 'package:flutter/material.dart';
import 'globals.dart';

// The amount of milliseconds the imter should wait until calling the next
// callback
class TimerButton extends StatefulWidget {
	const TimerButton({super.key, this.width, this.height, this.initialTime = 0.0, this.onEnd, this.lap});

	final double? width;
	final double? height;

	final void Function(double)? onEnd;

	final double initialTime;

	final bool? lap;

	@override
	// ignore: no_logic_in_create_state
	State<TimerButton> createState() { 
		if (lap != null && lap!) {
			return _TimerButtonLap();
		}

		return _TimerButton();
	}
}

class _TimerButtonLap extends State<TimerButton> {
	final Stopwatch watch = Stopwatch();
	bool periodicFinished = true;

	double currentElaspedTime = 0.0;

	List<String> timestamps = <String>[];

	void timerLoop(Timer timer) {
		if (!timer.isActive) {
			return;
		}

		if (periodicFinished) {
			timer.cancel();
			return;
		}

		setState(() {
			currentElaspedTime = watch.elapsedMilliseconds.toDouble() / 1000;
		});
	}

	void resetButtonOnPressed() {
		setState(() {
			periodicFinished = true;
			timestamps = <String>[];

			currentElaspedTime = 0.0;
			watch.reset();
		});
	}

	void playOnPressed() {
		periodicFinished = !periodicFinished;

		if (!periodicFinished) {
			watch.start();
			Timer.periodic(const Duration(milliseconds: timerPeriodicMilliseconds), timerLoop);
		} else {
			watch.stop();
		}
	}

	void lapButtonOnPressed() {
		setState(() {
			if (periodicFinished && currentElaspedTime <= 0.01) {
				periodicFinished = false;
				watch.start();
			}

			if (widget.onEnd != null) {
				timestamps.add(currentElaspedTime.toString());
				widget.onEnd!(currentElaspedTime);
			}
		});

		if (!periodicFinished && currentElaspedTime <= 0.01) {
			Timer.periodic(const Duration(milliseconds: timerPeriodicMilliseconds), timerLoop);
		}
	}

	@override
	Widget build(BuildContext context) {
		var timestampWidgets = <Widget>[];

		for (var timestamp in timestamps) {
			timestampWidgets.add(Text(timestamp));
		}

		return DecoratedBox( 
			decoration: BoxDecoration(
				border: Border.all(),
			),
			child: SizedBox(
				width: widget.width,
				height: widget.height,
				child: Column(
					// mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Row(
							children: [
								SizedBox(width: (widget.width ?? 1) / 3, height: (widget.height ?? 1) / 3, child: FloatingActionButton(onPressed: lapButtonOnPressed, child: const Text("Lap"),)),
								SizedBox(width: (widget.width ?? 1) / 3, height: (widget.height ?? 1) / 3, child: FloatingActionButton(onPressed: playOnPressed, child: Text(periodicFinished ? "Play" : "Pause"),)),
								SizedBox(width: (widget.width ?? 1) / 3, height: (widget.height ?? 1) / 3, child: FloatingActionButton(onPressed: resetButtonOnPressed, child: const Text("Reset"),)),
							],
						),
						SizedBox(width: (widget.width ?? 1), height: (widget.height ?? 1) / 8, child: Text("${currentElaspedTime.toStringAsPrecision(2)}s", textAlign: TextAlign.center,)),
						SizedBox(
							height: (widget.height ?? 1) / 2,
							width: widget.width,
							child: ListView(children: timestampWidgets,),
						)
					],
				),
			),
		);
	}
}

class _TimerButton extends State<TimerButton> {
	final Stopwatch watch = Stopwatch();
	bool wasPressed = false;
	bool periodicFinished = true;

	double currentElapsedTime = 0.0;

	bool initialized = false;

	void onPressed() {
		setState(() {
			periodicFinished = false;

			Timer.periodic(const Duration(milliseconds: timerPeriodicMilliseconds), (timer) {
				if (timer.isActive) {
					if (periodicFinished) {
						timer.cancel();
					}

					setState(() {
						if (!periodicFinished) {
							currentElapsedTime = watch.elapsedMilliseconds.toDouble() / 1000;
						}
					});

					if (!wasPressed && !periodicFinished) {
						timer.cancel();
					}
				}
			});

			if (!wasPressed) {
				watch.start();

				if (widget.lap != null && !widget.lap!) {			
					watch.reset();
				}
			}

			if (wasPressed && !periodicFinished) {
				currentElapsedTime = watch.elapsedMilliseconds.toDouble() / 1000;
				widget.onEnd!(currentElapsedTime);

				periodicFinished = true;
			}

			wasPressed = !wasPressed;
		});
	}

	@override
	Widget build(BuildContext context) {
		if (!initialized) {
			currentElapsedTime = widget.initialTime;
			initialized = true;
		}

	 	FloatingActionButton button = FloatingActionButton(
			onPressed: onPressed, 
			backgroundColor: 
				!wasPressed
				? const Color.fromARGB(255, 123, 123, 123)
				: greenMachineGreen
				,
			child: Column( 
				mainAxisAlignment: MainAxisAlignment.center,
				children: [ 
					Text(
						"${currentElapsedTime ~/ 60}m ${(currentElapsedTime % 60).toStringAsPrecision(3)}s", 
						overflow: TextOverflow.clip, 
						softWrap: false,
						style: Theme.of(context).textTheme.labelMedium,
						// textScaler: TextScaler.linear((widget.height ?? 1) / (widget.width ?? 1) * 2 / 3),
					),
					const Icon(Icons.timer),
				],
			),
		);

		return SizedBox(
			width: widget.width,
			height: widget.height,
			child: button,
		);
	}
}