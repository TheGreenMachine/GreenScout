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

class Reference<T> {
	Reference(this.value);

	T value;
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
	String matchNum = "";
	final _teamController = TextEditingController();
	String teamNum = "";
	bool isReplay = false;

	final cycleWatch = Stopwatch();
	bool cycleTimerStartDisabled = false;
	bool cycleTimerLocationDisabled = true; 

	Reference<SpeakerPosition> speakerPosition = Reference(SpeakerPosition.middle);
	Reference<bool> canShootIntoSpeaker = Reference(false);
	Reference<bool> canShootIntoAmp = Reference(false);

	Reference<bool> canDistanceShoot = Reference(false);
	final _distanceShootingAccuracyController = TextEditingController();
	Reference<String> distanceShootingAccuracyNum = Reference("");

	Reference<bool> canDoAuto = Reference(false);
	Reference<bool> canDoAutoSuccessfully = Reference(false);
	final _autoScoresController = TextEditingController();
	Reference<String> autoScoresNum = Reference("");
	final _autoMissesController = TextEditingController();
	Reference<String> autoMissesNum = Reference("");
	final _autoEjectsController = TextEditingController();
	Reference<String> autoEjectsNum = Reference("");

	Reference<bool> canClimb = Reference(false);
	Reference<bool> canTrap = Reference(false);
	Reference<bool> canPark = Reference(false);
	Reference<bool> canTrapSuccessfully = Reference(false);

	Reference<bool> cooperates = Reference(false);

	List<CycleTimeInfo> timestamps = [];

	final bufferTimeMs = 450;

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
		}
			bodyContent = buildMobileView(context);

		_matchController.text = widget.matchNum ?? matchNum;
		_teamController.text = widget.teamNum ?? teamNum;

		_autoScoresController.text = autoScoresNum.value;
		_autoMissesController.text = autoMissesNum.value;
		_autoEjectsController.text = autoEjectsNum.value;

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

										onChanged: (value) => matchNum = value,

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

									child: TextFormField(
										controller: _teamController,

										keyboardType: const TextInputType.numberWithOptions(decimal: false),
										style: Theme.of(context).textTheme.titleMedium,

										onChanged: (value) => teamNum = value,

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
								onPressed: (_) {},

								initialValue: isReplay,
							),
						),
					],
				),



				const Padding(padding: EdgeInsets.all(14)),

				createSectionHeader("Cycles"),

				createCycleTimers(ampColor, speakerColor),

				const Padding(padding: EdgeInsets.all(4)),

				createCycleListView(ampColor, speakerColor),



				const Padding(padding: EdgeInsets.all(16)),

				createSectionHeader("General Info"),

				createLabelAndDropdown<SpeakerPosition>(
					"Speaker Position", 
					{
						"Top": SpeakerPosition.top,
						"Middle": SpeakerPosition.middle,
						"Bottom": SpeakerPosition.bottom,
					},

					speakerPosition, 
					SpeakerPosition.middle,
				),

				createLabelAndCheckBox("Can Shoot Into Speaker?", canShootIntoSpeaker),

				createLabelAndCheckBox("Can Shoot Into Amp?", canShootIntoAmp),



				const Padding(padding: EdgeInsets.all(16)),

				createSectionHeader("Auto Mode"),

				createLabelAndCheckBox("Can They Do It?", canDoAuto),
				createLabelAndCheckBox("Mostly Successfully?", canDoAutoSuccessfully),
				createLabelAndNumberField("Scores", autoScoresNum, "#", _autoScoresController, 2, false),
				createLabelAndNumberField("Misses", autoMissesNum, "#", _autoMissesController, 2, false),
				createLabelAndNumberField("Ejects", autoEjectsNum, "#", _autoEjectsController, 2, false),

				

				const Padding(padding: EdgeInsets.all(14),),

				createSectionHeader("Distance Shooting"),

				createLabelAndCheckBox("Can They Do It?", canDistanceShoot),
				createLabelAndNumberField("How Accurate?", distanceShootingAccuracyNum, "%", _distanceShootingAccuracyController, 6, true),



				const Padding(padding: EdgeInsets.all(16)),

				createSectionHeader("Climbing"),
				
				createLabelAndCheckBox("Can They Do It?", canClimb),
				createLabelAndCheckBox("Are They Successful?", canClimb),

				// Extra padding for the bottom
				const Padding(padding: EdgeInsets.all(28)),
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

	Widget createSectionHeader(String headline) {
		return Padding(
			padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85), vertical: 5),

			child: Text(
				headline,
				style: Theme.of(context).textTheme.headlineSmall,
				textAlign: TextAlign.center,
			),
		);
	}

	Widget createLabelAndCheckBox(String question, Reference<bool> condition) {
		return Padding(
			padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85), vertical: 5),

			child: Row( 
				mainAxisAlignment: MainAxisAlignment.spaceBetween,

				children: [
					Text(
						question,
						style: Theme.of(context).textTheme.labelLarge,
					),

					Checkbox(
						value: condition.value, 
						onChanged: (_) => 
						setState(() {
							condition.value = !condition.value;
						}),
					),
				],
			),
		);
	}

	Widget createLabelAndNumberField(String label, Reference<String> numstr, String hintText, TextEditingController controller, int numberLengthLimit, bool decimal) {
		return Padding(
			padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85), vertical: 5),

			child: Row( 
				mainAxisAlignment: MainAxisAlignment.spaceBetween,

				children: [
					Text(
						label,
						style: Theme.of(context).textTheme.labelLarge,
					),

					SizedBox( 
						width: 75,
						height: 35,

						child: TextField(
							controller: controller,

							keyboardType: TextInputType.numberWithOptions(decimal: decimal),
							style: Theme.of(context).textTheme.titleMedium,

							textAlign: TextAlign.center,

							onChanged: (value) => numstr.value = value,

							inputFormatters: [
								decimal 
								? FilteringTextInputFormatter.allow(RegExp(r"[0-9.]"))
								: FilteringTextInputFormatter.digitsOnly,
								LengthLimitingTextInputFormatter(numberLengthLimit),
							],

							decoration: InputDecoration(
								border: const OutlineInputBorder(),
								hintText: hintText,
								hintStyle: Theme.of(context).textTheme.labelMedium,
							),
						),
					),
				],
			),
		);
	} 

	Widget createLabelAndDropdown<V>(String label, Map<String, V> entries, Reference<V> inValue, V defaultValue,) {
		List<DropdownMenuItem<V>> items = [];

		for (var entry in entries.entries) {
			items.add(
				DropdownMenuItem(
					value: entry.value, 
					child: Text(
						entry.key,
						style: Theme.of(context).textTheme.labelMedium,
					),
				),
			);
		}
		
		return Padding(
			padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85), vertical: 5),

			child: Row( 
				mainAxisAlignment: MainAxisAlignment.spaceBetween,

				children: [
					Text(
						label,
						style: Theme.of(context).textTheme.labelLarge,
					),

					DropdownButton<V>(
						padding: const EdgeInsets.only(left: 5),

						items: items,
						value: inValue.value,

						onChanged: (newValue) =>
						setState(() {
							inValue.value = newValue ?? defaultValue;
						}),
					),
				],
			),
		);
	}

	Widget createCycleTimers(Color ampColor, Color speakerColor) {
		return Row(
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
		);
	}

	Widget createCycleListView(Color ampColor, Color speakerColor) {
		return Padding( 
			padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1.0 - 0.80) * MediaQuery.of(context).size.aspectRatio),

			child: SizedBox( 
				width: 250,
				height: 200,

				child: ListView.builder(
					itemCount: timestamps.length,
					itemBuilder: (context, index) {
						return Row(
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
						);
					},
				),
			),
		);
	}
}