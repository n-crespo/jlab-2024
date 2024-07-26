# Monday

- successfully reverse engineered query to search inventory for transaction ID for testing purposes
- added a function with special conditional and more descriptive inventory query that:
  - returns true if the logs should be updated, false if they shouldn't
  - displays the reason for not updating the logs if false (part has already been issued/no longer in inventory, part does not exist, etc.)

# Tuesday

- attended Pansophy Team Meeting where we discussed the work I did on Monday
- worked on the pictures for my poster
- began working on creating a flow chart/logic diagram that will describe the flow of my code
- restructured a lot of code to make debugging easier

# Wednesday

- attended Safety and Health meeting with rest of HSSP group
- got a query for Mike that will match more traveler IDs
- used the query to add a validation check to account for strange edge case in
  formatting of traveler IDs

# Thursday

- wrote introduction and objective section of poster
- began writing final report detailing project
- first received barcode scanner from Mike, confirmed that it worked properly and easily integrated into our system
- added some checks to ensure proper entry of the TID
- attended Extreme High Vacuum Seminar/presentation

# Friday

- added functionality to allow for direct redirection to the traveler page from TID entry
- added very important conditional checks to ensure the TID is valid to avoid walls of text (errors) to be seen by the user
- attended poster session where I gave and received feedback on the current state of our posters
- cleaned up all of our code to remove debug information and abstract away almost everything from the end user
- making our code production ready
