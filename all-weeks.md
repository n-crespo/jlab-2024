# Day 4

- begun working on "Learn CodeFusion in a Week" training
  - start/close the server
  - manipulate/output/dump variables
  - datatypes (dates, arrays, structs, queries)
  - commenting
  - scripts syntax vs using tags
  - conditionals
    - if/else
    - switch/case
    - ternary operator
  - data handling
    - dumping/outputting the query
    - grouping output
    - avoiding SQL injection
- continued "Learn CodeFusion in a Week" training
  - learned how to
    - create custom tags
    - create/use components (in the best way)
- continued working on "Learn CodeFusion in a Week" training

  - OOP, ORM
  - Mail, Document Handling
  - Caching, advanced caching

- overview about the relational databases and how they work

  - talked about primary and foreign keys
  - talked about what the barcode scanner does (gets Transaction ID)
  - gave us some work to do for today (get a query working with the Transaction ID as input)

- implemented session persistent cookies to store previously selected options
  for traveler information (location, location acronym, action, action acronym)

  - edited SQL query to concatenate location and location acronym for better
    looking drop-down output
  - edited other SQL query to concatenate action and action acronym for better
    looking drop-down output

- worked on building the traveler ID properly with the transaction ID
- added drop-down to get work center and action and store the values in cookies
- encountered an issue with the default value of the drop-downs

  - although the default value is supposed to be the value of the stored cookie,
    the browser's cache overrides this and sometimes shows a different, previously
    entered default value
  - this shouldn't be a problem in actual use because the page's cache will have
    refreshed and the cookie drop-down will only need to be accessed once

- met with mike to discuss problems with testing my code for getting the max
  revision number
- separated code into multiple files so data stored in cookies is stored
  properly

- had a meeting with mike to discuss testing our traveler ID generation code
  - we learned that the data/IDs in the dev database are not the same as the
    production database due to the data being old
  - mike created a new traveler in the dev database with the new format, our
    code properly found it, thus our code is working properly
- edited our traveler ID generation code to remove `SN` from the end of the
  part acronym section of the traveler ID
- edited our code to properly retrieve the maximum revision number from the
  travelers database using the generated traveler ID

- talked with Valerie about moving cookies out of .cfm page to a custom
  component page
- implemented solution for cookies in custom component with ColdFusion script
- learned that cookies cannot be set in a ColdFusion script
- correctly implemented cookies in a custom component with ColdFusion tags
  instead
- redirected form submission to custom script rather than function to get around
  cookies only being availed in function scope

- researched how to duplicate rows in SQL

- completed query to update transaction log with new traveler information
- completed query to update inventory table with new location
- refactored and consolidated all team's code into custom component and
  specialized, modularized functions
- added check for existing record to avoid redundant insert/updating of transaction log

- successfully reverse engineered query to search inventory for transaction ID for testing purposes
- added a function with special conditional and more descriptive inventory query that:
  - returns true if the logs should be updated, false if they shouldn't
  - displays the reason for not updating the logs if false (part has already
    been issued/no longer in inventory, )
- repaired function to update inventory with an inner join
- repaired function to update the transaction log with new function for getting
  existing data
