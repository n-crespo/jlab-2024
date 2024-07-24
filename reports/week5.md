# Monday

- successfully reverse engineered query to search inventory for transaction ID for testing purposes
- added a function with special conditional and more descriptive inventory query that:
  - returns true if the logs should be updated, false if they shouldn't
  - displays the reason for not updating the logs if false (part has already
    been issued/no longer in inventory, )
