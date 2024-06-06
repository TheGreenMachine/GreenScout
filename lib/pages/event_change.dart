import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:green_scout/utils/action_bar.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/utils/general_utils.dart';
import 'package:green_scout/utils/reference.dart';
import 'package:green_scout/widgets/dropdown.dart';
import 'package:green_scout/widgets/header.dart';
import 'package:green_scout/widgets/subheader.dart';

class EventConfigPage extends StatefulWidget {
  const EventConfigPage({super.key});

  @override
  State<EventConfigPage> createState() => _EventConfigPage();
}

class _EventConfigPage extends State<EventConfigPage> {
  late StreamController<MapEntry<String, String>> eventDataController;
  late Stream<MapEntry<String, String>> eventData;

  late StreamController<Map<String, String>> allEventsController;
  late Stream<Map<String, String>> allEvents;

  Map<String, String> eventsMapped = {};

  @override
  void initState() {
    super.initState();

    eventDataController = StreamController();
    eventData = eventDataController.stream;

    allEventsController = StreamController();
    allEvents = allEventsController.stream;
  }

  Reference<String> currentEvent = Reference("");

  @override
  Widget build(BuildContext context) {
    final (width, widthPadding) =
        screenScaler(MediaQuery.of(context).size.width, 670, 0.95, 0.95);

    eventData = eventDataController.stream;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await App.httpRequest("generalInfo", "", onGet: (response) {
        Map responseJson = jsonDecode(response.body);

        MapEntry<String, String>? keyFromJson = MapEntry(
            responseJson["EventKey"].toString(),
            responseJson["EventName"].toString());
        if (keyFromJson != null) {
          eventDataController.add(keyFromJson);
        }
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await App.httpRequest("allEvents", "", onGet: (response) {
        Map<dynamic, dynamic> eventsJson = jsonDecode(response.body);
        Map<String, String> properMap = {"Select a new event": ""};

        properMap.addAll(eventsJson.map((key, value) {
          return MapEntry(value.toString(), key.toString());
        }));

        properMap["Select a new event"] = "";

        allEventsController.add(properMap);
      });
    });

    //If you want to add searching/filtering/etc go ahead i just didn't care enough -Tag

    // Custom event setting is BACKEND ONLY for right now. Someone else can implement it on the frontend but idk how without creating the most confusing ui ever -Tag
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: createEmptyActionBar(),
      ),
      body: ListView(
        children: [
          StreamBuilder(
            stream: eventData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Center(
                    child: Card(
                        child: Column(children: [
                  const HeaderLabel("Server Event Data"),
                  SubheaderLabel("Key: ${snapshot.data!.key}"),
                  SubheaderLabel("Event Name: ${snapshot.data!.value}"),
                ])));
              }

              return buildUnloadedEventView(context);
            },
          ),
          StreamBuilder(
              stream: allEventsController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Dropdown<String>(
                    padding: const EdgeInsets.only(left: 10),
                    isExpanded: true,
                    entries: snapshot.data!,
                    inValue: currentEvent,
                    defaultValue: "",
                    textStyle: null,
                    alignment: Alignment.center,
                    menuMaxHeight: 600,
                    setState: () => setState(() {}),
                  );
                }
                return buildUnloadedEventView(context);
              }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: ElevatedButton(
              onPressed: () {
                bool success = false;
                if (currentEvent.value == "") {
                  App.showMessage(
                      context, "Please select an event before submitting!");
                }

                () async {
                  App.promptAlert(
                    context,
                    "Are you sure you want to change the event?",
                    "This will reset everyone's current score to 0 and change the schedule to reflect this event.",
                    [
                      (
                        "Yes",
                        () async {
                          Navigator.of(context).pop();

                          success = await App.httpRequest(
                            "keyChange", 
                            currentEvent.value,
                          );

                          if (!context.mounted) {
                            return;
                          }

                          if (success) {
                            App.showMessage(context,
                                "Successfully updated event to ${currentEvent.value}!");
                            super.setState(() {});
                          } else {
                            App.showMessage(context, "Unable to update event");
                          }
                        }
                      ),
                      (
                        "No",
                        () {
                          Navigator.of(context).pop();
                        }
                      ),
                    ],
                  );
                }();
              },
              child: const Text("Submit"),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUnloadedEventView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 40),
      child: Text(
        "Loading Event data...",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.displaySmall,
      ),
    );
  }
}
