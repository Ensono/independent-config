# Independent Config

This repository details the idea of having an Independent Configuration system. This does not rely on Azure DevOps or GitHub Actions secrets and provides a way for people to get configuration to run pipelines locally without setting up lots of environment variables.

This is at the PoC stage at the moment.

## Documenation

The documentation is in AsciiDoc format in the `docs/` directory.

> [!IMPORTANT]
> The repo uses Ensono Independent runner to generate the docs, however version 2.x of `taskctl` needs to be used.

To generate the documentaion in PDF format run the following commands.

```
# Run the generation command
taskctl docs
```
