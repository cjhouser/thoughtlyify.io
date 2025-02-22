# Exceptions
Exceptions are classified as expected, unexpected, or unhandled based on the
impact the exception has on present and future transactions handled by the
process. Classification determines severity and the logging level where the
exception appears.

## Expected
* Transaction where the exception occurred can reach an expected final state
* Appears in `info` logs

## Unexpected
* Transaction where the exception occurred cannot reach an expected final state
* Appears in `info` and `warn` logs

## Unhandled
* All transactions cannot reach an expected final state
* Appears in `info`, `warn`, and `error` logs