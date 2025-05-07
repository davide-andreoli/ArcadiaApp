# 1.7

## Bug fixes

- Fixed the Document Folder having one additional level (e.g. Documents/Arcadia)
- Renamed the App to Arcadia as is not anymore on the App Store

# 1.6

## Features

- Added rumble support: for the cores and content that support it (only PokeMini as of right now), if you have haptic feedback enabled you'll also get haptics based on in game events as if you were playing on the actual console
- Added customization options for button dimension, spacing and opacity

## Bug fixes

- Fixed the top part of the game view being hidden by the menu bar on macOS
- Fixed save files issues for Pokemon Mini

# 1.5.1

## Bug fixes

- Temporarily removed .fds support from NES as a BIOS file would be required

# 1.5

## Cores

- Added Pokemom Mini support

## Features

- Added a console info view to the library, which shows important information about the console you're viewing
- Added audio controls

## Improvements

- Image aspect ratio will respect the original console aspect ratio
- Added a new App icon on iOS, that has the same coloring as the houseplant from which this app takes its name
- Cores support more file types, in addition to the one already supported you'll be able to play with the following files
    - Atari 2600
        - bin
    - Atari 7800
        - bin
    - GameBoy (Color)
        - dmg
    - NES
        - fds
        - unf
        - unif
    - SNES
        - swc
        - fig
        - bs
        - st
    - Sega Game Gear
        - bin
    - Sega Master System
        - bin
    - Sega Genesis
        - bin
    
    

# 1.4.2

## Bug Fixes

- Fixed a bug that caused the app to crash when switching to cores with different audio sample rates. Sorry about that, it took quite long to catch because it didn't happen in debug builds.

# 1.4.1

Arcadia becomes Altea. Due to some conflicts with other apps naming, Arcadia's name is now Altea.

# 1.4

## Features

- Added the possibility to open game files with Arcadia from the file's share sheet
- Added the possibility to share games and export save files

## Improvements

- Improved the aspect of the empty library view
- Added the possibility to refresh the empty library view
- Made the UI more consistent
- Made the icons compatible with iOS 18
- Now the audio will follow the mute switch by default - more advanced audio controls coming the next update

## Bug fixes

- Added start and select button to Atari 2600 and 7800 cores, to allow to play games that start in preview mode and need to be reset. Sorry about that!
- Fixed an issue that could cause the app to crash if buttons were pressed very quickly


# 1.3

## Features
- Added a featured games section
- Added search bar in game list
- Added game validity check: if you somehow manage to load a game that is not compatible with the system you are loading it in, you get an alert and the game view is dismissed
- Added the possibility to redownload the default cover image

## Improvements
- Improved recommendation results retrieval speed
- Improved L and R buttons shape

## Bug fixes
- Controller shoulder buttons are correctly managed

# 1.2

## Cores
- Sega Genesis

## Features
- Added the possibility to hide buttons
- Added an Advanced DPad option with diagonal movements
- Added the possibility to pull to refresh the game collection

## Improvements
- Updated button spacing

## Localization
- Added Italian localization

## Accessibility
- Improved accessibility

## Bug fixes
- Fixed screenshot feature not working on some cores
- Removed the export save button from swiping on the game list. The button was not triggering anything, the function will come but as of right now you can find all the save files in the storage folder (you can access it from the Files app or from Arcadia's storage settings)
- Fixed iCloud Sync being triggered also when not enabled in some cases
- Fixed renaming being prevented on some cases when iCloud Sync is enabled
- Cloud Sync button is now disabled if Cloud Sync is disabled

## Internals
- Code refactoring to help in interface modifications
- Code refactoring for file management
- Minor adjustments in SNES core compilation

# 1.1

## Cores
- NeoGeo Pocket (Color)
- Sega MS - SG1000
- Sega Game Gear

## Features
- Added a share screenshot button in the overlay menu
- Added a save screenshot button in the overlay menu
- Added a game recommendation page, that will suggest you other game that you might like based on the metadata of your game library

## Improvements
- Improved the iCloud Sync logic to only copy the data from the cloud, rather than using it as a source directly. This translates in better performances and less possibility to launch a game that is not actually downloaded (if you had no data for example)

## Bug fixes
- Changed Atari 7800 icon to the Atari 7800 controller

# 1.0

Initial release

