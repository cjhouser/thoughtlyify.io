# Logging
Language is useless unless all parties understand. Using a language incorrectly
or speaking a language that the other part doesn't understand will only cause
confusion.

Logging is the language that contributors use to communicate information about
their services's health to operators. Quick action can be taken by operators
when they understand the language the contributors used when writing a service.
Operators cannot take quick action if they must learn a new language for every
service written.

## WIP: Log Formats
### Servers
### Jobs

## Log Levels
### info
Informational logs communicate information about a transaction that was able to
reach an expected final state.

### warn
Warning logs communicate information about a transaction that was not able to
reach an expected final state.

### error
Error logs communicate information about a process where all the transactions
handled by the process are unable to reach an expected final state.

## Format
Logs are line delimited JSON objects. Objects must include the following fields.
* time
* level
* msg
Logs will not have nesting. Instead, field names will be dotted. Example:
`{"nested.field": "value"}`