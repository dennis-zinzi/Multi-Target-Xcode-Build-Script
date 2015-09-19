# Multi-Target-Xcode-Build-Script

Shell Scripts to allow the building on several targets of an Xcode project 

Purpose of the Three Scripts provided is to allow the building of multiple Targets (Apps) without having to manually do so in Xcode

## buildMultiXcodeTargets.sh

Simplest script of the Three, simply reads every line in the XcodeTargets.txt file and performs a clean, build and archive action for each one, and then uploads build to iTunesConnect and Fabric.io for testing (if used). Will work only given the Targets exist/spelt correctly

## updateBuildNumberMultiBuild.sh

Increments the each Target's build number according to the build number in the Info.plist file and then performs a clean, build and archive action for the Targets with their updated build number

## updateVersionNumberMultiBuild.sh

Increments the Target's version number by 0.1 and resets the build number to 1, and then performs the clean, build and archive action with the updated version number for each of the Targets

### XcodeTargets.txt

Simple text file that contains all the targets to rebuild, MUST be spelt exactly the same as in Xcode or it won't work.
<b> MUST </b> end with an empty line, or else won't recognize last target on the file
