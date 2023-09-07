{% docs schedule_location %}

Field containing an array of location records.
# Location records
Location records contain information about the locations that the train service originates at, passes, stops at and terminates at. The schedule_location field contains an ordered JSON list of location records, each with the following fields:

|         Field         |                                                                                               Description                                                                                              |
|:---------------------:|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
| record_identity       | The type of location record.                  |
|        |  *LO* - Originating location - location where the train service starts from                  |
|        |  *LI* - Intermediate location                  |
|        |  *LT* - Terminating location - where the service terminates                 |
| tiploc_code           | The TIPLOC code of the location.                                                                                                                                                                        |
| tiploc_instance       | The nth occurrence of the location.                                                                                                                                                                    |
| arrival               | WTT arrival time (*LI* and *LT* records)                                    |
|                | Format: HHMM*H* - time given by the 24-hour clock. Optional H indicates half-minute. In local time (i.e. adjusted for BST / GMT.)                                   |
| departure             | WTT departure time (*LO* and *LI* records)                                  |
|              |  Format: HHMM*H* - time given by the 24-hour clock. Optional H indicates half-minute. In local time (i.e. adjusted for BST / GMT.)                                 |
| pass                  | WTT passing time (*LI* records)                                           |
|                   |  Format: HHMM*H* - time given by the 24-hour clock. Optional H indicates half-minute. In local time (i.e. adjusted for BST / GMT.)                                          |
| public_arrival        | Public timetable arrival time (*LI* and *LT* records)                                                          |
|         | Format: HHMM - time given by the 24-hour clock. In local time (i.e. adjusted for BST / GMT.)                                                         |
| public_departure      | Public timetable departure time (*LO* and *LI* records)                                                        |
|       |  Format: HHMM - time given by the 24-hour clock. In local time (i.e. adjusted for BST / GMT.)                                                       |
| platform              | Platform                                                                                                               |
|               | A 3-character field used to denote the platform or line that the service uses.                                                                                                                |
| line                  | Departure line                                                                 |
|                   | A 3-character field representing the line to be used on departure from the location. The line abbreviation will be used.                                                                |
| path                  | Arrival path                                                                       |
|                   | A 3-character field representing the line to be used on arrival at the location. The line abbreviation will be used.                                                                      |
| engineering_allowance | Time allowed for recovery from engineering activities  |
|  |  *H* - Half a minute  |
|  |   *1,1H* ... *9, 9H* - One, one-and-a-half through to nine, nine-and-a-half minutes  |
|  |   *10* to *59* - 10 to 59 minutes (whole minutes only) |
| pathing_allowance     | Time allowed for pathing requirements                 |
|      |  *H* - Half a minute                 |
|      |  *1,1H* ... *9, 9H* - One, one-and-a-half through to nine, nine-and-a-half minutes                 |
|      |  *10* to *59* - 10 to 59 minutes (whole minutes only)                 |
| performance_allowance | Performance allowance                                                                                   |
|  | *H* - Half a minute                                                                                   |
|  | *1,1H* ... *9, 9H *- One, one-and-a-half through to nine, nine-and-a-half minutes                                                                                  |
| location_type         | Same as record_identity (*LO*, *LI* or *LT*)                                                                                                                                                                 |

{% enddocs %}