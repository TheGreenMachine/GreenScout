import 'package:GreenScout/widgets/floating_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../globals.dart';
import 'navigation_layout.dart';
import '../widgets/toggle_floating_button.dart';

class MatchFormPage extends StatefulWidget {
	const MatchFormPage({
		super.key,
		this.matchNum,
		this.teamNum,
	});

	final String? matchNum;
	final String? teamNum;

	@override
	State<MatchFormPage> createState() => _MatchFormPage();
}

enum SpeakerPosition {
	top,
	middle,
	bottom,
}

enum CycleTimeLocationType {
	speaker,
	amp,
	
	none,
}

class CycleTimeInfo {
	CycleTimeInfo({
		this.time = 0.0,
		this.location = CycleTimeLocationType.none,
	});

	double time;
	CycleTimeLocationType location;
}

class _MatchFormPage extends State<MatchFormPage> {
	final _matchController = TextEditingController();
	final _teamController = TextEditingController();
	final cycleWatch = Stopwatch();
	bool isReplay = false;

	bool cycleTimerStartDisabled = false;
	bool cycleTimerLocationDisabled = true; 

	List<CycleTimeInfo> timestamps = [];

	SpeakerPosition speakerPosition = SpeakerPosition.middle;

	@override 
	void dispose() {
		_matchController.dispose();
		_teamController.dispose();

		super.dispose();
	}

	@override 
	Widget build(BuildContext context) {
		final windowSize = MediaQuery.of(context).size;

		const mobileViewWidth = 450.0;

		Widget bodyContent;
		if (windowSize.width > mobileViewWidth) {
			bodyContent = buildDesktopView(context);
		} else {
			bodyContent = buildMobileView(context);
		}

		_matchController.text = widget.matchNum ?? "";
		_teamController.text = widget.teamNum ?? "";

		return Scaffold(
			appBar: AppBar(
				backgroundColor: Theme.of(context).colorScheme.inversePrimary,

				actions: const [
					NavigationMenu(),
					Spacer(),
				],
			),
			body: bodyContent,
		);
	}

	Widget buildMobileView(BuildContext context) {
		final ampColor = Theme.of(context).colorScheme.inversePrimary.withRed(255);
		final speakerColor = Theme.of(context).colorScheme.inversePrimary.withBlue(255);

		const bufferTimeMs = 700;

		return ListView(
			children: [
				const Padding(padding: EdgeInsets.all(8)),
				Row(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Column( 
							children: [
								SizedBox( 
									width: 150,
									height: 35,

									child: TextField(
										controller: _matchController,

										keyboardType: const TextInputType.numberWithOptions(decimal: false),
										style: Theme.of(context).textTheme.titleMedium,

										textAlign: TextAlign.center,

										inputFormatters: [
											FilteringTextInputFormatter.digitsOnly,
											LengthLimitingTextInputFormatter(2),
										],

										decoration: InputDecoration(
											border: const OutlineInputBorder(),
											labelText: "Match #",
											floatingLabelAlignment: FloatingLabelAlignment.center,
											floatingLabelBehavior: FloatingLabelBehavior.always,
											labelStyle: Theme.of(context).textTheme.titleLarge,
										),
									),
								),

								const Padding(padding: EdgeInsets.symmetric(vertical: 5)),

								SizedBox(
									width: 150,
									height: 35,

									child: TextField(
										controller: _teamController,

										keyboardType: const TextInputType.numberWithOptions(decimal: false),
										style: Theme.of(context).textTheme.titleMedium,

										textAlign: TextAlign.center,

										inputFormatters: [
											FilteringTextInputFormatter.digitsOnly,
											LengthLimitingTextInputFormatter(5),
										],

										decoration: InputDecoration(
											border: const OutlineInputBorder(),
											labelText: "Team #",
											floatingLabelAlignment: FloatingLabelAlignment.center,
											floatingLabelBehavior: FloatingLabelBehavior.always,
											labelStyle: Theme.of(context).textTheme.titleLarge,
										),
									),
								),
							],
						),

						const Padding(padding: EdgeInsets.symmetric(horizontal: 6.5)),

						SizedBox(
							width: 75,
							height: 70,
							child: FloatingToggleButton(
								labelText: "Replay?",
								initialColor: greenMachineGreen.withRed(255),
								pressedColor: greenMachineGreen,
								initialIcon: const Icon(Icons.public_off_sharp),
								// initialIcon: const Text("NO"),
								pressedIcon: const Icon(Icons.public),
								// pressedIcon: const Text("YES"),
								onPressed: (a) { print("$a"); isReplay = a; },

								initialValue: isReplay,
							),
						),
					],
				),

				const Padding(padding: EdgeInsets.all(14)),

				Padding(
					padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85), vertical: 5),

					child: Text(
						"Cycles",
						style: Theme.of(context).textTheme.headlineSmall,
						textAlign: TextAlign.center,
					),
				),

				Row(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						SizedBox(
							width: 85,
							height: 50,

							child: FloatingButton(
								labelText: "Amp",
								icon: const Icon(Icons.amp_stories),
								color: ampColor,

								onPressed: () => 
								setState(() {
									if (cycleWatch.elapsedMilliseconds < bufferTimeMs) {
										return;
									}

									cycleWatch.stop();
									cycleTimerLocationDisabled = true;
									cycleTimerStartDisabled = false;

									timestamps.add(
										CycleTimeInfo(
											time: cycleWatch.elapsedMilliseconds.toDouble() / 1000, 
											location: CycleTimeLocationType.amp,
										),
									);
								}),

								disabled: cycleTimerLocationDisabled,
							),
						),
						SizedBox( 
							width: 85,
							height: 50,

							child: FloatingButton(
								labelText: "Start",
								icon: const Icon(Icons.timer_sharp),
								color: Theme.of(context).colorScheme.primaryContainer,

								onPressed: () =>
								setState(() {
									cycleTimerStartDisabled = true;
									cycleTimerLocationDisabled = false;

									cycleWatch.reset();
									cycleWatch.start();
								}),

								disabled: cycleTimerStartDisabled,
							),
						),
						SizedBox( 
							width: 85,
							height: 50,

							child: FloatingButton(
								labelText: "Speaker",
								icon: const Icon(Icons.speaker),
								color: speakerColor,

								onPressed: () =>
								setState(() {
									if (cycleWatch.elapsedMilliseconds < bufferTimeMs) {
										return;
									}

									cycleWatch.stop();
									cycleTimerLocationDisabled = true;
									cycleTimerStartDisabled = false;

									timestamps.add(
										CycleTimeInfo(
											time: cycleWatch.elapsedMilliseconds.toDouble() / 1000, 
											location: CycleTimeLocationType.speaker,
										),
									);
								}),

								disabled: cycleTimerLocationDisabled,
							),
						),
					],
				),

				const Padding(padding: EdgeInsets.all(4)),

				Padding( 
					padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1.0 - 0.80) * MediaQuery.of(context).size.aspectRatio),

					child: SizedBox( 
						width: 250,
						height: 200,

						child: ListView.builder(
							itemCount: timestamps.length,
							itemBuilder: (context, index) {
								return Container(
									alignment: Alignment.center,

									child: Row(
										mainAxisAlignment: MainAxisAlignment.center,

										children: [
											SizedBox( 
												width: 125,
												height: 35,

												child: FittedBox(
													fit: BoxFit.contain,
													alignment: Alignment.centerLeft,

													child: Text(
														timestamps[index].time.toStringAsPrecision(3),
														style: Theme.of(context).textTheme.labelMedium,
													),
												),
											),

											SizedBox(
												width: 100,
												height: 35,

												child: Container(
													alignment: Alignment.center,

													color: switch (timestamps[index].location) {
														CycleTimeLocationType.amp => ampColor,
														CycleTimeLocationType.speaker => speakerColor,
														_ => Theme.of(context).colorScheme.inversePrimary,
													},

													child: Text(
														switch (timestamps[index].location) {
															CycleTimeLocationType.amp => "Amp",
															CycleTimeLocationType.speaker => "Speaker",
															_ => "None",
														},

														style: Theme.of(context).textTheme.labelMedium,
														textAlign: TextAlign.center,
													),
												),
											),

											// SizedBox(
											// 	width: 25,
											// 	height: 35,

											// 	child: FloatingButton(
											// 		color: Theme.of(context).colorScheme.background,
											// 		icon: const Icon(Icons.remove_circle_outline_sharp),

											// 		shadow: false,

											// 		onPressed: () =>
											// 		setState(() {
											// 			timestamps.removeAt(index);
											// 		}),
											// 	),
											// )
										],
									),
								);
							},

							clipBehavior: Clip.antiAlias,
						),
					),
				),

				const Padding(padding: EdgeInsets.all(16)),

				Padding(
					padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85), vertical: 5),

					child: Text(
						"General Info",
						style: Theme.of(context).textTheme.headlineSmall,
						textAlign: TextAlign.center,
					),
				),

				// DropdownButton<SpeakerPosition>(
				// 	items: const [
				// 		DropdownMenuItem(value: SpeakerPosition.top, child: Text("Top")),
				// 		DropdownMenuItem(value: SpeakerPosition.middle, child: Text("Middle")),
				// 		DropdownMenuItem(value: SpeakerPosition.bottom, child: Text("Bottom")),
				// 	], 
				// 	value: speakerPosition,

				// 	onChanged: (newSpeakerPosition) =>
				// 	setState(() {
				// 		speakerPosition = newSpeakerPosition ?? SpeakerPosition.middle;
				// 	}),
				// ),
			],
		);
	}

	Widget buildDesktopView(BuildContext context) {
		return ListView(
			children: [
				Padding( 
					padding: EdgeInsets.only(
						right: MediaQuery.of(context).size.width * (1 - 0.72), 
						left: MediaQuery.of(context).size.width * (1 - 0.72), 
						top: 25,
						bottom: 5,
					),

					child: SizedBox( 
						width: null,
						height: 40,

						child: TextField(
							controller: _matchController,

							keyboardType: const TextInputType.numberWithOptions(decimal: false),
							style: Theme.of(context).textTheme.titleLarge,

							textAlign: TextAlign.center,

							inputFormatters: [
								FilteringTextInputFormatter.digitsOnly,
								LengthLimitingTextInputFormatter(2),
							],

							decoration: InputDecoration(
								border: const OutlineInputBorder(),
								labelText: "Match #",
								floatingLabelAlignment: FloatingLabelAlignment.center,
								floatingLabelBehavior: FloatingLabelBehavior.always,
								labelStyle: Theme.of(context).textTheme.titleLarge,
							),
						),
					),
				),

				Padding( 
					padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1 - 0.72), vertical: 5),

					child: FloatingToggleButton(
						labelText: "Replay?",
						initialColor: greenMachineGreen.withRed(255),
						pressedColor: greenMachineGreen,
						initialIcon: const Icon(Icons.public_off_sharp),
						pressedIcon: const Icon(Icons.public),
						onPressed: (a) { print("$a"); isReplay = a; },

						initialValue: isReplay,
					),
				),
			],
		);
	}
}