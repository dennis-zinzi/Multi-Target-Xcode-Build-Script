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

#Change according to project multibuild
projName=YOUR_PROJ_NAME

#Change according to where Xcode Archives are stored (if default location, ONLY change username part of path)
archiveDir=/PATH/TO/XCODE/ARCHIVES

while read line
do
	#Ignore target if commented out
	if [[ ${line:0:1} == "#" ]]; then
		continue
	fi

	#Display all the Targets that will be rebuilt
	echo -e $line
done <XcodeTargets.txt

while read line
do
	#Ignore target if commented out
	if [[ ${line:0:1} == "#" ]]; then
		continue
	fi

	#Target to be built
	echo -e "\n\nBuilding $line Now\n\n"

	#Check list of schemes for target
	existNum=$(xcodebuild -list -project $projName.xcodeproj | grep -c $line)

	#Check scheme exists in project (2 as output includes both scheme and target name)
	if [ $existNum != 2 ]; then
		echo "NO MATCHING SCHEME/TARGET FOUND FOR: $line"

		#Remove Target from Target list on File
		sed -i '' "/$line/d" XcodeTargets.txt

		#Add Target to Failed File
		echo "ERROR: no matching scheme or target found for $line" >> FailedXcodeTargets.txt

		continue
	fi

	#Clean Target
	xcodebuild -scheme $line clean -project $projName.xcodeproj

	#Build Target (Comment if archiving as build is part of archive process)
	# xcodebuild -scheme $line build -project $projName.xcodeproj

	#Archive Target Build
	xcodebuild -scheme $line archive -project $projName.xcodeproj


	#Remember Current Directory for later
	projDir=$(pwd)

	#Change Directory to where Target's Archive is stored
	cd $archiveDir/$(date +%F)/

	#Check archive created for target
	if [ ! -e $line**.xcarchive ]; then
		echo "ARCHIVE FAILED FOR TARGET:" $line
		
		#Remove Target from Target list on File
		#sed -i '' "/$line/d" $projDir/XcodeTargets.txt

		#Add Target to Failed File
		echo "ERROR: archive failed for $line" >> $projDir/FailedXcodeTargets.txt

		#Go back to the project directory
		cd $projDir

		continue
	fi

	#Create ipa file from Target's archive (will be saved in IPAs directory, will be created if it doesn't exists)
	xcodebuild -exportArchive -archivePath $line**.xcarchive -exportPath IPAs -exportOptionsPlist $projDir/BuildOptions.plist


	#Check ipa file created correctly for target
	if [ ! -e IPAs/$line**.ipa ]; then
		echo "IPA CREATION FAILED FOR TARGET:" $line
		
		#Remove Target from Target list on File
		#sed -i '' "/$line/d" $projDir/XcodeTargets.txt

		#Add Target to Failed File
		echo "ERROR: ipa creation failed for $line" >> $projDir/FailedXcodeTargets.txt

		#Go back to the project directory
		cd $projDir

		continue
	fi


	#Upload your app to iTunes Connect Store
	/Applications/Xcode.app/Contents/Applications/Application\ Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool \
	--upload-app -f IPAs/$line.ipa -u <YOUR_APPLE_ACCOUNT@email.com> -p <YOUR_APPLE_PASSWORD>

	#Go back to Project directory to Rebuild remaining Targets
	cd $projDir

	#Submit Rebuilt Target to Fabric (is used for Testing else delete following lines) for testing 
	#<API_KEY> <BUILD_SECRET> found on Fabric.io -> Settings -> Organizations -> OrganizationName -> Below Name click
	#Will work only if project is active on Fabric

	/PATH/TO/CRASHLYTICS/Crashlytics.framework/submit <API_KEY> <BUILD_SECRET> \
	-ipaPath $archiveDir/$(date +%F)/IPAs/$line.ipa \
	-emails tester@email.com,tester2@email.com,tester3@email.com,tester4@email.com \
	-notifications YES

done <XcodeTargets.txt
