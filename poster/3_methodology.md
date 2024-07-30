# Methodology

Before the scanning of a barcode and thus introduction of a Transaction ID, some preliminary information is required. By allowing an admin user to set session-persistent cookies on every computer on the floor of the Test Lab, the system can retain the work center, action, and location ID values. The work center variable contains the precise location of the user's machine, the action variable defines the procedure the user is doing at that location, and the location ID is used to more precisely identify the current location. This information is crucial to selecting the correct traveler page to display to the user.

Since the barcode scanner inserts the transaction ID as if it was typed manually, a single text entry box is all that is needed for acquiring the Transaction ID.
