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

done <XcodeTargets.txt
