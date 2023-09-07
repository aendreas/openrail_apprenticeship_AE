{% docs train_id %}

# Train id
The 10-character identity for this train. If the schedule is due to run over multiple months, the identifier can be used on the same date every month (12th Feb, 12th March, etc).
This is used in other TRUST messages to identify the train. The train activation message links the *train_id* with a particular schedule. *train_id* is of the format *AABBBBCDEE* where:

* *AA* is the first two digits of the origin STANOX, and represents the area where the train starts
* *BBBB* is the signalling ID (headcode) used within the data feeds to represent the train - for passenger trains this is the actual service headcode, but an obfuscated number is given for freight services. This is used by other feeds, e.g. the TD feed, to track trains.
* *C* is the TSPEED value of the train (see valid TSPEED values below) - note: this does not refer to the actual speed (velocity) of the train
* *D* is the Call Code of the train - a letter or number based on the departure time from the origin
* *EE* is the day of the month on which the train originated


## TSPEED
The train status code (TSPEED) is the 7th character of the 10-character unique TRUST identity.

The possible values are as follows:

| **Status**                       | **Code**           |
|------------------------------|----------------|
| Passenger and Parcels in WTT | M, N, O        |
| Freight trains in WTT        | C, D, E, F, G  |
| Trips and agreed pathways    | A, B, H-L, P-Z |
| All Short-Term Planned       | 0-9            |

{% enddocs %}