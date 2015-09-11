# Author: Dennis Zinzi
#
# NOTE: Script will work IF AND ONLY IF the target's Folder name is them same as the name
# 		of the Target on Xcode minus "fanapp" AND/OR "FC" at the end, for any other instance
#		the script will not run for the given Target (e.g. Not work if Target name "LutonTownFCfanapp"
#		and folder name just "Luton" [Will work if Folder name is "LutonTown" OR "LutonTownFC"])
#
#!/bin/bash

while read line
do
	#Deletes fanapp from Target name
	line=${line%fanapp}

	#Find current directory
    curDir=$(pwd)

    #Check Directory exists for target
	if [ ! -d $curDir/SpontlyTeams/Resources/Customisation/$line ]; then

		#Remove FC from Target name
		line=${line%FC}

		#If still no Directory found for the Target, skip to next one
		if [ ! -d $curDir/SpontlyTeams/Resources/Customisation/$line ]; then
			echo "NO FOLDER FOUND FOR TARGET:" $line
			continue
		fi

	fi

	#Get current Build number
	currBuild=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" $curDir/SpontlyTeams/Resources/Customisation/$line/Info.plist)

	#Increment Build number by 1
	newBuildVers=$(($currBuild + 1))
	echo $newBuildVers

	#Output current Version number
	defaults read $curDir/SpontlyTeams/Resources/Customisation/$line/Info CFBundleShortVersionString

	#Overwrite Build number to new one
	defaults write $curDir/SpontlyTeams/Resources/Customisation/$line/Info CFBundleVersion $newBuildVers

	#Output Build number for Target
	defaults read $curDir/SpontlyTeams/Resources/Customisation/$line/Info CFBundleVersion

done <XcodeTargets.txt

#Rebuild all targets with new Build numbers
. buildMultiXcodeTargets.sh
