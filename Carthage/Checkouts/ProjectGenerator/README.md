[![GitHub tag](https://img.shields.io/github/tag/XCEssentials/ProjectGenerator.svg)](https://github.com/XCEssentials/FunctionalState/releases)
[![license](https://img.shields.io/github/license/XCEssentials/ProjectGenerator.svg)](https://opensource.org/licenses/MIT)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# Introduction

Describe Xcode project declaratively in pure Swift.

# Problem

Xcode uses an undocumented proprietary format for describing project structure, settings, etc. in **`*.xcodeproj`** files. That kind of file is hard to read and understand for a human, impossible to merge without merge conflicts if changes were made on two different local copies of the same repo/project, or even on different branches inside the same repo on the same workstation. That makes working together on the same Xcode project file a nightmare, when you need to merge changes "*.xcodeproj" always has conflicts and developers have to resolve them manually, wasting lots of time for routine that might be done by computer. We need a better solution!

# Existing solution

There is a command line tool that allows developer to write project specification in a form of plain text configuration file (using Ruby or YAML) and then generate **`*.xcodeproj`** file on the fly from this specification - [Struct](https://github.com/workshop/struct).

The specification file format features very concise hierarchic notation that's easy and intuitive, and you only need to specify explicitly settings which can not be inferred somehow or you need a value that differs from defaults (provided by the tool itself or, most often, by Xcode).

For vast majority of iOS developers, this tool should be already a good enough solution, but there are still few inconveniences:

- you have to learn a new language/syntax (not every iOS developer knows Ruby and feel comfortable to deal with it on daily basis);
- you need to leave Xcode and switch to another text editor with proper syntax highlight for Ruby/YAML to edit the specification file, because Xcode does not support YAML and have limited syntax highligh for Ruby;
- due to nature of Ruby/YAML, you do not have development time syntax check, you have to try to run the tool in order to disciover a syntax error in your specification.

# Wishlist

Based on the downsides of Struct listed above, here is a list of wishes for an "ideal" tool like that:

- write project specification in pure Swift;
- use Xcode to edit specification file;
- get full syntax highlight and real time syntax check in specification file.

# About this tool

To archive the goals listed above, this project has been made. Think of it as a thin wrapper on top of [Struct](https://github.com/workshop/struct) CLI tool. It brings no extra functionality in comparison with [Struct](https://github.com/workshop/struct), but adds some convenience to writing project file specification.

# How to install

Use [Carthage](https://github.com/Carthage/Carthage) to install the tool into your project. Put into your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

```ruby
github "XCEssentials/ProjectGenerator" ~> 2.1
```

The project folder will be downloaded by [Carthage](https://github.com/Carthage/Carthage), but nothing will be built, that's expected behavior, ignor warnings from Carthage.

# How it is organized

**Remember**, you are not supposed to make any changes in the project, except your project specification file.

The poject consists of 3 main parts, each of them has its own scheme:

1. Scheme **"Fwk"** - macOS framework that implements functionality related to parsing your Swift specification file and writing target specification file in YAML for [Struct](https://github.com/workshop/struct).
2. Scheme **"Launcher"** - a command line tool that gets the job done. It includes the framework module as dependency and starts the process of parsing your Swift specification file into [Struct](https://github.com/workshop/struct) YAML spec file. This target contains just 2 source files. First one is the **`main.swift`** file, it will be executed when the target will be run in Xcode. Second file is **`Project.Struct.swift`** and it's missing in the project out of the box intentinonally. It's expected location is in your project root directory (given that `ProjectGenerator` is installed with [Carthage](https://github.com/Carthage/Carthage)) and it's your responsibility to put this file there.
3. Scheme **"Example"** - very similar to the "Launcher" scheme, with only difference that it contains a sample Swift project specification file with all the necessery statements isnside. Use this sample Swift specification file as starting point for your project specification.

# How to start using

If using first time:

1. copy the [sample file](https://github.com/XCEssentials/ProjectGenerator/blob/master/Example/Spec.swift) from [Example](https://github.com/XCEssentials/ProjectGenerator/tree/master/Example) folder to your project root folder and rename it with **`Project.Struct.swift`**;
2. open the project (from your project root folder, go to `./Carthage/Checkouts/ProjectGenerator`, open file `ProjectGenerator.xcodeproj`), make sure that you have the `Launcher` scheme selected (notice, that if you've done everything correctly at the previous step, the `Project.Struct.swift` under `Launcher` group on Project Navigator panel will be in place, not missing);
3. make initial editing of the `Project.Struct.swift` file to describe at least basic structure for your project;
4. when project specification is ready, just hit "Cmd+R" hotkey in Xcode (Run the scheme), Xcode will build and run the scheme, a new file named `project.yml` will be created at project root folder. That's it!

To actually generate project file from the created `project.yml` file - use Struct itself from your project root folder.

# How to use

When yoiu need to make a change into your project configuration:

1. open the project (from your project root folder, go to `./Carthage/Checkouts/ProjectGenerator`, open file `ProjectGenerator.xcodeproj`), make sure that you have the `Launcher` scheme selected;
2. make the necessary changes in the `Project.Struct.swift` file;
3. run the scheme, a new file named `project.yml` will be created at project root folder (will override previous version).

To actually (re)generate project file from the newly created `project.yml` file - use Struct itself from your project root folder.

# Notes on versioning

This project follows [Semantic Versioning](http://semver.org), its MAJOR (and MINOR, when possible) version number is syncronized with corresponding version numbers of the [Struct](https://github.com/workshop/struct) specification format, which is used as blueprint for the output YAML project specification file.

For example, if this project has version number `2.1.0`, that means the output specification file `project.yml` will be generated using [Spec format: v2.0](https://github.com/workshop/struct/wiki/Spec-format:-v2.0).

## Future plans

This project will be kept up to date with latest MAJOR version of [Struct](https://github.com/workshop/struct). Also there is a chance that the execution of [Struct](https://github.com/workshop/struct) CLI tool after (re)generation of `project.yml` file will by automated as well, but so far it seems to be a bit out of scope for the tool.

## Contribution, feedback, questions...

If you want to contirbute to the project - feel free to open a pull request.

If you have any questions, suggestions, feedback or believe you found a bug - feel free to create an issue.
