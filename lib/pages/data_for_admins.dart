class AdminData {
  static const noActiveUserSelected = "[[CURRENTLY NO ACTIVE USER IS SELECTED AT THIS MOMENT]]";

  static Map<String, String> users = {
    "None": noActiveUserSelected,
  };

  static void updateUserRoster() {
    users = {
      "None": noActiveUserSelected,
    };

    // Temporary.
    // Will need to set up server request here.

    // Some example test users
    // Display Name = Internal User ID
    users["Mr. Forrest"] = "mrf28";
    users["John Snow"] = "johns23";
    users["Sick Burn"] = "adamj29";
    users["Harold Loungebottom-Bankman"] = "haroldlb32";
    users["Joshua William Loungebottom-Bankman"] = "joshuawlb32";
  }

  static List<String> getDisplayNames() {
    return users.keys.toList();
  }

  static List<String> getUserIDs() {
    return users.values.toList();
  }
}