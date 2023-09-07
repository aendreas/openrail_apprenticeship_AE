{% docs tp_origin %}

The date, in YYYY-MM-DD format, that the train runs. For trains activated before midnight that run after midnight, this date will be tomorrow's date.

**Note:** there is currently a problem with the *tp_origin_timestamp* field due to the truncation of the timestamp. This only occurs during daylight savings for trains which start their journey between 0001 and 0200 the next day. To work around this problem, use the date in the *origin_dep_timestamp* field.

{% enddocs %}