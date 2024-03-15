class MatchInfo {
	const MatchInfo(this.matchNum, this.team, this.isBlue, this.driveTeamNum);

	final int matchNum;
	final int team;

	final bool isBlue;
	final int driveTeamNum;
}

class MatchesData {
	static List<MatchInfo> allParsedMatches = [];

	void getAllMatchesFromServer() {
		
	}
}