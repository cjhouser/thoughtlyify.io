# Infrastructure Management
Resources are managed via Terraform

## Why Terraform?
* well known
* strong community = strong support for products which we may need
* extensible through custom providers

## Terraform Project Files
* data.tf - datasoures
* variables.tf - inputs, variables, locals
* versions.tf - provider definitions, versioning
* outputs.tf - outputs
* *.tf - project specific defintions
* modules/ - modules

## Block Standards
* Non-collection attributes are defined before any collection attributes
* Non-collection attributes alphabetized as a group
* Collection attributes alphabetized as a group

## FAQ
* Why not alphabetize all attributes as a whole?
    * `tf fmt` will not add the appropriate whitespace to attributes that are defined below a collection attribute