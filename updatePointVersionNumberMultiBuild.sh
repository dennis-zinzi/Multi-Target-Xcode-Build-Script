# Author: Dennis Zinzi
#
# Script that first increments the current version number of ALL the targets specified in the XcodeTargets.txt
# file by 0.0.1, and then cleans, builds, and archives each of the Targets sequentially
#
#
# NOTE: Script will work IF AND ONLY IF the target's Folder name is them same as the name
# 		of the Target on Xcode minus the specified endpatterns, for any other instance
#		the script will not run for the given Target (e.g. Not work if Target name "LutonTownFCfanapp"
#		and folder name just "Luton" [Will work if Folder name is "LutonTown" OR "LutonTownFC" 
#		given "fanapp" and/or "FC" are the specified endpatterns])
#
#!/bin/bash

#Change according to project multibuild
projFolder=YOUR_PROJ_NAME

while read line
do
	#Ignore target if commented out
	if [[ ${line:0:1} == "#" ]]; then
		continue
	fi

	#Deletes endpattern from Target name (in case Folder have different name from Target)
	line=${line%endpattern}

	#Remember current directory
    curDir=$(pwd)

    #Check Directory exists for target's customization files/images
	if [ ! -d $curDir/$projFolder/Resources/$line ]; then

		#Remove secondary endpattern from Target name (if needed, repeat this step by copying line 23 and 26 until an endpattern exists)
		line=${line%endpattern2}

		#If still no Directory found for the Target, skip to next one
		if [ ! -d $curDir/$projFolder/Resources/$line ]; then
			echo "NO FOLDER FOUND FOR TARGET:" $line

			#Remove Target from Target list on File
			sed -i '' "/$line/d" XcodeTargets.txt

			#Add Target to Failed File
			echo "ERROR: no folder found for $line" >> FailedXcodeTargets.txt

			#Skip to next Target
			continue
		fi
	fi

	echo "$line"

	#Get current Target version
	currVersion=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" $curDir/$projFolder/Resources/$line/Info.plist)

	#Get current Target version's point part e.g. (2.1.3 would retrieve the 3) 
	newVersPoint=$(echo $currVersion | awk -F "." '{print $3}')
	#Increment Point part by 1
	newVersPoint=$(($newVersPoint + 1))

	#Set new version number
	newVers=$(echo $currVersion | awk -F "." '{print $1 "." $2 ".'$newVersPoint'" }')
	echo $newVers

	#Overwrite new version number
	defaults write $curDir/$projFolder/Resources/$line/Info CFBundleShortVersionString $newVers

	#Set Build number back to 1
	defaults write $curDir/$projFolder/Resources/$line/Info CFBundleVersion 1

	#Output Build number for Target
	defaults read $curDir/$projFolder/Resources/$line/Info CFBundleVersion

	#Go to Target's directory
	cd $curDir/$projFolder/Resources/$line/


	#Perform Image Optimisation of all Images in the Target's Directory (ImageOptim app must be installed)
	# cd $curDir/$projFolder/Resources/$line/
	# /Applications/ImageOptim.app/Contents/MacOS/ImageOptim .
	# cd $curDir

done <XcodeTargets.txt

#Initialise build for all targets specified with new version number
. buildMultiXcodeTargets.sh