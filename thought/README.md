# Thought Service
The thought service is responsible for sending and receiving thoughts from
users of Thoughtlyify.io.

The thought service should handle a larger amount of reads and writes since
not all users are expected to share their thoughts.

## Data Attributes
* Thoughts are chronological
* Thoughts have degrees of popularity
* Sending thoughts is more frequent than receiving them
* Recent thoughts get largest traffic
* Thoughts are received one at a time
* Thoughts are sent in batches
* 