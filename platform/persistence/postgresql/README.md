# todo
- deletion of PVC should not delete the underlying EBS volume
    - storageclass configuration
- EBS volumes should be associated with ordinal pods
    - ordinals reuse the same volume if they disappear and come back
- new storageclass for gp3 EBS volumes
