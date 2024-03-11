import 'package:GreenScout/pages/preference_helpers.dart';
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
	bottom;

	@override 
	String toString() {
		return switch (this) {
			SpeakerPosition.top => "top",
			SpeakerPosition.middle => "middle",
			SpeakerPosition.bottom => "bottom",

			// ignore: unreachable_switch_case
			_ => "unknown",
		};	
	}
}

enum CycleTimeLocationType {
	speaker,
	amp,
	
	none;

	@override
	String toString() {
		return switch (this) {
			CycleTimeLocationType.speaker => "Speaker",
			CycleTimeLocationType.amp => "Amp",

			_ => "None",	
		};
	}
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

	Reference<bool> speakerTop    = Reference(false);
	Reference<bool> speakerMiddle = Reference(false);
	Reference<bool> speakerBottom = Reference(false);

	// Reference<SpeakerPosition> speakerPosition = Reference(SpeakerPosition.middle);
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
	Reference<bool> canClimbSuccessfully = Reference(false);
	final _climbAttemptsController = TextEditingController();
	Reference<String> climbAttemptsNum = Reference("");

	Reference<bool> canTrap = Reference(false);
	Reference<bool> canTrapSuccessfully = Reference(false);
	final _trapAttemptsController = TextEditingController();
	Reference<String> trapAttemptsNum = Reference("");
	final _trapScoreController = TextEditingController();
	Reference<String> trapScoreNum = Reference("");

	Reference<bool> canPark = Reference(false);

	Reference<bool> cooperates = Reference(false);

	final _notesController = TextEditingController();
	Reference<String> notes = Reference("");

	List<CycleTimeInfo> cycleTimestamps = [];

	final bufferTimeMs = 450;

	@override 
	void dispose() {
		_matchController.dispose();
		_teamController.dispose();

		_autoScoresController.dispose();
		_autoMissesController.dispose();
		_autoEjectsController.dispose();

		_climbAttemptsController.dispose();
		_trapAttemptsController.dispose();
		_trapScoreController.dispose();

		_notesController.dispose();

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

		_climbAttemptsController.text = climbAttemptsNum.value;
		
		_trapAttemptsController.text = trapAttemptsNum.value;
		_trapScoreController.text = trapScoreNum.value;

		_notesController.text = notes.value;

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
								onPressed: (_) { print(this.toJson()); },

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

				createSectionHeader("Shooting Info"),

				createLabelAndCheckBox("Can Shoot Into Speaker?", canShootIntoSpeaker),

				createLabelAndCheckBox("Can Shoot Into Amp?", canShootIntoAmp),



				const Padding(padding: EdgeInsets.all(16),),

				createSectionHeader("Shooting Position (Speaker)"),

				createLabelAndCheckBox("Top", speakerTop),
				createLabelAndCheckBox("Middle", speakerMiddle),
				createLabelAndCheckBox("Bottom", speakerBottom),



				const Padding(padding: EdgeInsets.all(16)),

				createSectionHeader("Auto Mode"),

				createLabelAndCheckBox("Can They Do It?", canDoAuto),
				createLabelAndCheckBox("Is It Successful?", canDoAutoSuccessfully),
				createLabelAndNumberField("Scores", autoScoresNum, "#", _autoScoresController, 2, false),
				createLabelAndNumberField("Misses", autoMissesNum, "#", _autoMissesController, 2, false),
				createLabelAndNumberField("Ejects", autoEjectsNum, "#", _autoEjectsController, 2, false),

				

				const Padding(padding: EdgeInsets.all(14),),

				createSectionHeader("Distance Shooting"),

				createLabelAndCheckBox("Can They Do It?", canDistanceShoot),
				createLabelAndNumberField("How Accurate?", distanceShootingAccuracyNum, "%", _distanceShootingAccuracyController, 5, true),



				const Padding(padding: EdgeInsets.all(16)),

				createSectionHeader("Climbing"),
				
				createLabelAndCheckBox("Can They Do It?", canClimb),
				createLabelAndCheckBox("Are They Successful?", canClimbSuccessfully),
				createLabelAndNumberField("Attempts", climbAttemptsNum, "#", _climbAttemptsController, 2, false),



				const Padding(padding: EdgeInsets.all(16)),

				createSectionHeader("Trap"),

				createLabelAndCheckBox("Can They Do It?", canTrap),
				createLabelAndCheckBox("Are They Successful?", canClimbSuccessfully),
				createLabelAndNumberField("Attempts", trapAttemptsNum, "#", _trapAttemptsController, 2, false),
				createLabelAndNumberField("Score Count", trapScoreNum, "#", _trapScoreController, 1, false),



				const Padding(padding: EdgeInsets.all(16)),

				createSectionHeader("Misc."),

				createLabelAndCheckBox("Do They Park?", canPark),
				createLabelAndCheckBox("Do They Cooperate?", cooperates),



				const Padding(padding: EdgeInsets.all(24)),

				createSectionHeader("Notes"),

				Padding(
					padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85)),

					child: TextField(
						controller: _notesController,

						style: Theme.of(context).textTheme.bodyMedium,

						onChanged: (value) => notes.value = value,

						maxLines: 10,

						decoration: const InputDecoration(
							border: OutlineInputBorder(
								borderRadius: BorderRadius.all(Radius.circular(1.0)),
							),
							// contentPadding: EdgeInsets.symmetric(vertical: 125),
							isDense: false,
						),
					),
				),

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

							cycleTimestamps.add(
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

							cycleTimestamps.add(
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
					itemCount: cycleTimestamps.length,
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
											cycleTimestamps[index].time.toStringAsPrecision(3),
											style: Theme.of(context).textTheme.labelMedium,
										),
									),
								),

								SizedBox(
									width: 100,
									height: 35,

									child: Container(
										alignment: Alignment.center,

										color: switch (cycleTimestamps[index].location) {
											CycleTimeLocationType.amp => ampColor,
											CycleTimeLocationType.speaker => speakerColor,
											_ => Theme.of(context).colorScheme.inversePrimary,
										},

										child: Text(
											cycleTimestamps[index].location.toString(),

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

	String toJson() {
		String expandCycles() {
			StringBuffer builder = StringBuffer();

			for (int i = 0; i < cycleTimestamps.length; i++) {
				builder.write(
					'{ "Time": ${cycleTimestamps[i].time}, "Type": "${cycleTimestamps[i].location}" }',
				);

				if (i != cycleTimestamps.length - 1) {
					builder.writeln(',');
				}
			}

			return builder.toString();
		}

		String unwrapNumberString(Reference<String> reference) {
			if (reference.value.isEmpty) {
				return "0";
			} 

			return reference.value;
		}

		String scouterName = getScouterName();

		return '''		
		{
			"Team": ${teamNum.isEmpty ? "0" : teamNum},
			"Match": {
				"Number": ${matchNum.isEmpty ? "0" : matchNum},
				"isReplay": $isReplay,
			},

			"Driver Station": {
				"Is Blue": false,
				"Number": 1
			},

			"Scouter": "$scouterName",

			"Cycles": [
				${expandCycles()}
			],

			"Amp": ${canShootIntoAmp.value},
			"Speaker": ${canShootIntoSpeaker.value},

			"Speaker Positions": {
				"top": ${speakerTop.value},
				"middle": ${speakerMiddle.value},
				"bottom": ${speakerBottom.value}
			},

			"Distance Shooting": {
				"Can": ${canDistanceShoot.value},
				"Accuracy": ${unwrapNumberString(distanceShootingAccuracyNum)}
			},

			"Auto": {
				"Can": ${canDoAuto.value},
				"Succeeded": ${canDoAutoSuccessfully.value},
				"Scores": ${unwrapNumberString(autoScoresNum)},
				"Misses": ${unwrapNumberString(autoMissesNum)},
				"Ejects": ${unwrapNumberString(autoEjectsNum)}
			},

			"EndGame": {
				"Can Climb": ${canClimb.value},
				"Climb Succeeded": ${canClimbSuccessfully.value},
				"Climb Attempts": ${unwrapNumberString(climbAttemptsNum)},
				"Parked": ${canPark.value}
			},

			"Trap": {
				"Can": ${canTrap.value},
				"Succeeded": ${canTrapSuccessfully.value},
				"Attempts": ${unwrapNumberString(trapAttemptsNum)},
				"Number Of Scores": ${unwrapNumberString(trapScoreNum)} 
			},

			"Coopertition": ${cooperates.value},

			"Penalities": [

			],

			"Notes": "${notes.value}"
		}
		''';
	}
}