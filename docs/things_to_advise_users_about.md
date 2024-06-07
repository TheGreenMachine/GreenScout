## DO NOT RUN THE APP IN INCOGNITO

Make sure that nobody runs the app using incognito mode during competition. We learned this out the hard way when running into issues related to the server. When trying to correct the issue, it turned out that some people were using incognito, which made the match data irrecoverable. 

## Make sure to connect to internet first.

The app requires an initial internet connection to function. This is due to the fact that it's a web app hosted on a github page. This is a limitation that can be solved, but hasn't yet, mainly for the fact that distribution for mobile platforms (Android and IOS) is a lot of effort. 

However, thankfully after getting the initial connection, the main part of the app, the match form, should work. Sending the matches scouted to the server will still require a connection, but in the meantime you'll be able to scout, which is what's most important.

## Data not getting sent to the server?

You should check out the debug info tab in the settings page. That's where we store all the matches that the user has ever scouted, which means you can recover data that has somehow not made it's way to the server.

Additionally, the debug info page contains information relating to the ip address of the user, which can help with pinpointing who's having trouble connecting. The same can be applied to the UUID stored there.

## Should I be worried if there's been no data send to the spreadsheet?

No. The most likely scenario is that scouters are working on scouting offline. This means that as soon as they have the opportunity to connect to the internet, all the matches scouted will be sent to the server and processed into the spreadsheet. So, don't worry if the scouted data doesn't immediately get pushed, it'll take a while especially when there's limited wifi or cellular at competition venues.