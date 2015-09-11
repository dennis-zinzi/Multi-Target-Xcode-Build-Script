# Author: Dennis Zinzi
#
# NOTE: Script will work IF AND ONLY IF the target's Folder name is them same as the name
# 		of the Target on Xcode minus "fanapp" AND/OR "FC" at the end, for any other instance
#		the script will not run for the given Target (e.g. Not run if Target name "LutonTownFCfanapp"
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

	echo "$line"

	#Get current Target version
	currVersion=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" $curDir/SpontlyTeams/Resources/Customisation/$line/Info.plist)

	#Get current Target version's decimal part e.g. (2.1 would retrieve the 1) 
	newVersDecimal=$(echo $currVersion | awk -F "." '{print $2}')
	#Increment Decimal part by 1
	newVersDecimal=$(($newVersDecimal + 1))

	#Set new version number
	newVers=$(echo ${currVersion%.*}"."$newVersDecimal)
	echo $newVers

	#Overwrite new version number
	defaults write $curDir/SpontlyTeams/Resources/Customisation/$line/Info CFBundleShortVersionString $newVers

	#Set Build number back to 1
	defaults write $curDir/SpontlyTeams/Resources/Customisation/$line/Info CFBundleVersion 1

	#Output Build number for Target
	defaults read $curDir/SpontlyTeams/Resources/Customisation/$line/Info CFBundleVersion

done <XcodeTargets.txt

#Initialise build for all targets specified with new version number
. buildMultiXcodeTargets.sh
