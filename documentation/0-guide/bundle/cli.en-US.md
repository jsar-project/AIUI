# aix-cli Tool

`aix` is the official command line tool for managing, packaging, and inspecting AIX files.

## Installation

If you already have the source code, you can install it with npm or cargo:

```bash
npm install -g @yodaos-pkg/aix-cli
```

```bash
cargo install --path packages/aix-cli
```

## Core Commands

### 1. Pack
Package a development directory into an `.aix` file:

```bash
# Basic packaging
aix pack <source-directory>

# Specify the output filename
aix pack <source-directory> -o my-agent.aix

# Enable asset optimization (compress images and JSON)
aix pack <source-directory> --optimize

# Specify the optimization level (1-3)
aix pack <source-directory> -O --opt-level 3
```

### 2. List Contents
View the file list and sizes inside an AIX package without extracting it:

```bash
aix list <AIX-file>
# Or use the alias
aix ls <AIX-file>
```

## Ignore Files (.aixignore)

The packaging tool recognizes the `.aixignore` file in the source root directory. You can use syntax similar to `.gitignore` to exclude files that should not be packaged.
