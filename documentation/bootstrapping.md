# Bootstrapping
The platform that runs ontop of Kubernetes requires a bit of bootstrapping to get to a final state.

## Postgres
A custom certificate authority and certificates are required the first time the persistence layer is set up. Any services that rely on postgres as a persistence layer must be configured to trust the custom authority until a well-known authority can be used or private key infastructure is set up.
