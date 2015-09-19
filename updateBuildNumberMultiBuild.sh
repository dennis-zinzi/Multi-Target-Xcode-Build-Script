# Author: Dennis Zinzi
#
# Script that first increments the current build number of ALL the targets specified in the XcodeTargets.txt
# file by 1, and then cleans, builds, archives, and uploads to iTunes each of the Targets sequentially
#
#
# NOTE: Script will work IF AND ONLY IF the target's Folder name is them same as the name
# 		of the Target on Xcode minus "fanapp" AND/OR "FC" at the end, for any other instance
#		the script will not run for the given Target (e.g. Not work if Target name "LutonTownFCfanapp"
#		and folder name just "Luton" [Will work if Folder name is "LutonTown" OR "LutonTownFC" 
#		given "fanapp" and/or "FC" are common endpatterns])
#
#!/bin/bash

while read line
do
	#Deletes endpattern from Target name (in case Folder have different name from Target)
	line=${line%endpattern}

	#Remember current directory
    curDir=$(pwd)

    #Check Directory exists for target's customization files/images
	if [ ! -d $curDir/ProjectName/Resources/Customisation/$line ]; then

		#Remove secondary endpattern from Target name (if needed, repeat this step by copying line 23 and 26 until an endpattern exists)
		line=${line%endpattern2}

		#If still no Directory found for the Target, skip to next one
		if [ ! -d $curDir/ProjectName/Resources/Customisation/$line ]; then
				
			echo "NO FOLDER FOUND FOR TARGET:" $line

			#Remove Target from Target list on File
			sed -i '' "/$line/d" XcodeTargets.txt

			#Skip to next Target
			continue
		fi

	fi

	#Output Target you are modifying
	echo "$line"

	#Get current Build number
	currBuild=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" $curDir/ProjectName/Resources/Customisation/$line/Info.plist)

	#Increment Build number by 1
	newBuildVers=$(($currBuild + 1))
	echo $newBuildVers

	#Output current Version number
	defaults read $curDir/ProjectName/Resources/Customisation/$line/Info CFBundleShortVersionString

	#Overwrite Build number to new one
	defaults write $curDir/ProjectName/Resources/Customisation/$line/Info CFBundleVersion $newBuildVers

	#Output Build number for Target
	defaults read $curDir/ProjectName/Resources/Customisation/$line/Info CFBundleVersion

done <XcodeTargets.txt

#Rebuild all targets with new Build numbers
. buildMultiXcodeTargets.sh
