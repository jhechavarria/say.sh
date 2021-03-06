# say.sh

This script enables any debian based GNU/Linux distribution to talk! Based on Google's text to speach Android application, it gives you a few commands to ease your TTS experience on Linux.

## Setup

### Prerequisites

Before installing the script, you will need to install a few dependencies:

- libttspico-utils
- sox
- zenity
- xsel

To install all of them at once type the following command:

```
sudo apt-get install -y libttspico-utils sox zenity xsel
```

**Warning:** As libttspico-utils is a non-free package, it may not be available in your default packqge repositories.

## Install

To start installing the script simply type:

```
./say.sh install
```

This will go through a few operations required for it to work properly:

- creating a /home/user_name/.local/bin/say directory
- copying the scripts to newly created directory
- creating and setting config file within newly created directory
- adding an instruction to /gome/user/.bashrc file
- reloading .bashrc file

## Uninstall

As easy as installing, to remove everything type:

```
./say.sh uninstall
```

This operation does not remove dependencies as some of them might be native.

## Configuration

During setup a default configuration will be set. You still can change it using the **saycfg** command. This command takes 3 arguments: language, volume and speed.

Example:

This command sets language to US English, volume to 1.2 and speed to 0.8

```
saycfg en-US 1.2 0.8
```

The script supports over to 6 different languages. Volume variates from 0 to 2 and speed from 0.5 to 1.5.

### Available languages

**en-GB** British English

**en-US** US English

**fr-FR** French

**de-DE** German

**es-ES** Spanish

**it-IT** Italiam

## Keyboard shortcuts

A keyboard shortcut can be set to use TTS functionnalities puside terminal. Simply set a new keyboard shortcut with the following command:

```
./.local/bin/say/say.sh say
```

This command will start reading any text selected with your mouse. To stop reading, press the keyboard shortcut again.

### Other useful commands

In order to make your end experience even better a few additional commands related to graphical interfaces were made available. You can use then within keyboard shortcuts to open them indipendently.

Open a new window with program settings and graphical TTS reader

```
./.local/bin/say/say.sh gui
```

Open a new window with program language settings

```
./.local/bin/say/say.sh gui lng
```

Open a new window with program volume settings

```
./.local/bin/say/say.sh gui vol
```

Open a new window with program speed settings

```
./.local/bin/say/say.sh gui spd
```

## Commands

The following commands are available in command line

### say

Start text interpretation and reading.

#### Basic usage

```
say Hello World!
```

#### Live changing language

If default configuration language doesn't fit with given text, you can overwrite it in command call.

```
say it-IT Buongiorno a tutti!
```

#### Using standard input

```
echo "Salut tout le monde!" | say
```

Even using standard input, language can still be overwritten:

```
echo "I love this app!" | say en-GB
```

### saygui

Provides a GUI window that allows you to manage TTS with your mouse

```
saygui
```

You can choose to open a specific window by using an option

```
saygui tts
```

Available options are:

- tts
- lng
- vol
- spd

### saycfg

Set full configuration

```
saycfg es-ES 1 1
```

**-d** option can be set instead of language to reset system default language

```
saycfg -d 2 1.5
```

### saylng

Sets current language in configuration

```
saylng de-DE
```

**-d** option can be set instead of language to reset system default language

```
saylng -d
```

### sayvol

Sets current volume in configuration. Volume can be set from 0 up tu 2

```
sayvol 2
```

### sayspd

Sets current speed in configuration. Speed can be set from 0.5 to 1.5

```
sayspd 1.2
```
