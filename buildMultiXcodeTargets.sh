# Author: Dennis Zinzi
#
# Shell Script that will Clean, Build and Archive sequentially all Targets specified
# on the XcodeTargets.txt file
#
# NOTE: Targets MUST be spelt exactly as in Xcode, and XcodeTargets.txt final Target 
# MUST be followed by an empty line, or else final Target won't be recognized
#
#!/bin/bash       

echo -e "\nApps that will be rebuilt\n"


while read line
do
	#Display all the Targets that will be rebuilt
	echo -e $line
done <XcodeTargets.txt

while read line
do
	#Target to be built
	echo -e "\n\nBuilding $line Now\n\n" 

	#Clean Target
	xcodebuild -scheme $line clean -project Spontly_Teams.xcodeproj

	#Build Target
	xcodebuild -scheme $line build -project Spontly_Teams.xcodeproj

	#Archive Target Build
	xcodebuild -scheme $line archive -project Spontly_Teams.xcodeproj

	#Remember Current Directory for later
	projDir=$(pwd)

	#Change Directory to where Target's Archive is stored
	cd /Volumes/DennisZinziEXT/Development/Xcode/Archives/$(date +%F)/${line%fanapp}**/Products/Applications/

	#Get Name of Target's generated file
	appName=$(ls -t ${line%fanapp}**.app | head -n 1)

	#Create a zip file of the generated output (required .zip or .ipa to upload to store)
	zip -r $appName.zip $appName.app

	#Get Directory of altool (command line tool for Application Loader)
	altool=$(/Applications/Xcode.app/Contents/Applications/Application\ Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool)

	#Upload your app to iTunes Connect Store (replace word afer -u with your Connect username, and word -p with your Connect password)
	$altool --upload-app -f $appName.zip -u username@email.com -p myPassword

	#Go back to directory to Rebuild remaining Targets
	cd $projDir

done <XcodeTargets.txt
