# Monday

- worked on building the traveler ID properly with the transaction ID
- added drop-down to get work center and action and store the values in cookies
- encountered an issue with the default value of the drop-downs
  - although the default value is supposed to be the value of the stored cookie,
    the browser's cache overrides this and sometimes shows a different, previously
    entered default value
  - this shouldn't be a problem in actual use because the page's cache will have
    refreshed and the cookie drop-down will only need to be accessed once

# Tuesday

- continued working on building the traveler ID
- met with mike to discuss problems with testing my code for getting the max
  revision number
- Pansophy Team meeting discussing our progress
- separated code into multiple files so data stored in cookies is stored
  properly

# Wednesday

- had a meeting with mike to discuss testing our traveler ID generation code
  - we learned that the data/IDs in the dev database are not the same as the
    production database due to the data being old
  - mike created a new traveler in the dev database with the new format, our
    code properly found it, thus our code is working properly
- edited our traveler ID generation code to remove `SN` from the end of the
  part acronym section of the traveler ID
- edited our code to properly retrieve the maximum revision number from the
  travelers database using the generated traveler ID

# Thursday

- wrote my weekly report
- began working on the poster presentation
- building an ERD (entity relationship diagram)
- had lunch and board games with Carol

# Friday

- talked with Valerie about moving cookies out of .cfm page to a custom
  component page
- implemented solution for cookies in custom component with ColdFusion script
- learned that cookies cannot be set in a ColdFusion script
- correctly implemented cookies in a custom component with ColdFusion tags
  instead
- redirected form submission to custom script rather than function to get around
  cookies only being availed in function scope
