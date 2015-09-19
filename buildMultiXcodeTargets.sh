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
	xcodebuild -scheme $line clean -project ProjectName.xcodeproj

	#Build Target
	xcodebuild -scheme $line build -project ProjectName.xcodeproj

	#Archive Target Build
	xcodebuild -scheme $line archive -project ProjectName.xcodeproj

	#Remember Current Directory for later
	projDir=$(pwd)

	#Change Directory to where Target's Archive is stored
	cd ~/Users/denniszinzi/Library/Developer/Xcode/Archive/$(date +%F)/

	#Create ipa file from Target's archive
	xcodebuild -exportArchive -archivePath $line**.xcarchive -exportPath $line -exportFormat ipa -exportProvisioningProfile "$line App Store" #(Provisioning Profile Used for App Store Distribution)

	#Upload your app to iTunes Connect Store (replace word afer -u with your Connect username, and word -p with your Connect password)
	/Applications/Xcode.app/Contents/Applications/Application\ Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool --upload-app -f $line.ipa -u username@email.com -p myPassword

	#Go back to Project directory to Rebuild remaining Targets
	cd $projDir

	#Submit Rebuilt Target to Fabric (is used for Testing else delete following lines) for testing 
	#<API_KEY> <BUILD_SECRET> found on Fabric.io -> Settings -> Organizations -> OrganizationName -> Below Name click
	#Will work only if project is active on Fabric
	Core/Frameworks/Crashlytics.framework/submit <API_KEY> <BUILD_SECRET> \
	-ipaPath ~/Users/denniszinzi/Library/Developer/Xcode/Archive/$(date +%F)/$line.ipa \
	-emails tester@email.com,tester2@email.com,tester3@email.com,tester4@email.com \
	-notifications YES

done <XcodeTargets.txt
