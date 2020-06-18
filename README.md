# Readme



## iOS Workfinder 3



This readme describes what you need to know and do in order to build an iOS Workfinder 3 release. 



1. Brief product description

2. Development Computer

3. Development Environment

4. Language

5. Target Device and iOS version

6. Sourcecode repository

7. Branching strategy

8. Step-by-step guide to building a release


### Product Description

iOS Workfinder is a native iPhone-only app written exclusively in Swift 5.2. It is part of the Workfinder LTD portfolio. iOS Workfinder's main use case is to enable students to quickly find work experience placements with businesses in their area.

### Development Computer

Development should be done on a Mac running macOS Cataline or later. 

Warning: Do not use a beta version of the operating system if you intend to build a release. A build built with a beta version of macOS can be uploaded to Testflight for beta testing but cannot be released to the Appstore.

### Development Environment

Xcode is the single absolutely required tool. Various other tools might be helpful in various contexts and for various purposes but none are strictly required. Xcode 11.2.1 or later is required. Later versions might incur the cost of having to eliminate build warnings.  Earlier versions will not build the code.

Warning: Do not use a beta version of Xcode if you intend to build a release. A build built with a beta version of Xcode can be uploaded to Testflight for beta testing but cannot be released to the Appstore.

### Language

The main project which includes all in-house written code is exclusively Swift 5.1. In contrast, the external 3rd party libraries use a variety of earlier versions of Swift and Objective C. 

### Target device and iOS version

The target devices are iPhone 5s or later.
The target version of iOS is iOS 11.0 or later

### Sourcecode Repository

The iOS Workfinder repo is https://github.com/workfinder/iOSApp

### Branching strategy

Standard Gitflow is used with two ever-present branches: a *master* branch representing production and a *develop* branch. 

The *master* branch can be used to build the current production release. *Master* also serves as the source branch for live patches. The *develop* branch is the main working branch from which feature branches are taken.

When a feature branch is completed it is merged (typiclly with rebase) into *develop* and then deleted. When a development phase comes to an end, the *develop* branch is merged into *master* but is not deleted.

### Step-by-step guid to building a release

1. You will need to have an Apple developer account which is also a member of the Workfinder iOS team. 

2. Use a computer running macOS Catalina. More or less any machine will do in a pinch, from a 2013 MacBook Air up, but you will experience far less frustration if you have a machine with 16GB+ RAM and a multi-core processor.

3. Install Xcode from the Mac Appstore if not already installed.

4. In the Xcode  preferences pane, add the developer's account if not already done

5. In the Xcode preferences pane, add an appropriate Gitlab account with access to https://github.com/workfinder/iOSApp if not already done. Ensure that HTTPS is selected rather than SSH.

6. All other Xcode settings can be safely left at their default values.

7. Switch to a browser and go to  https://github.com/workfinder/iOSApp

8. Click on the green "clone or download" button, and then "Open in Xcode", 

9. ![Screenshot 2018-10-24 at 15.53.32](/Users/keithdev/Desktop/Screenshot 2018-10-24 at 15.53.32.png)

10. Confirm the "Allow Xcode to open" alert

11. Xcode will open to receive the project. It will then prompt you to specify a location, so choose a suitable location on your local machine (e.g, /Desktop/Dev)

12. Perform these sanity checks (which will help you introduce yourself to the project):

1. Make sure that the scheme dropdown in Xcode has the f4s_f4s_staging scheme selected rather than f4s_f4s_live. If this is not the case, select the staging scheme. You want to build and release to the staging environment first, not production.
2. Use the Xcode control navigator to explore Xcode's current understanding of the branches. Under "Branches", You should see the local master branch. Under "Remotes", you should see "origin/master". If there are additional branches under "Branches", take this opportunity to select the one you wish to work on.
2a. Open a terminal at the Xcode project folder and issue the command: `pod install` to download and configure the 3rd party dependencies from cocoapods.
3. Built the app "cmd + B". The build should complete successfully. There might be build warnings (yellow) but there shouldn't be any errors (red). You might wonder how this worked straight away without having to go through cocoapods to install the 3rd party libraries that the project depends on. The answer is that all the code required to build the 3rd party libraries is already included in the Git repo, so building the app from the repo is essentially trivial. The counterside to this convenience however is that more work needs to be done when the 3rd party libraries are updated, or when new libraries are added. However, if you are patching a live fault, this is unlikely to be of concern to you and you will probably welcome the convenience of a "no-brainer" first time build.
4. At this stage it is worthwhile to examine the warnings that will have been issued by Xcode during the build. Use Xcode's issue navigator to do this. At the time of writing there are four build warnings (down from 70+ in builds earlier 2019). If you do see a build warning, drill deeper and you will find they arise from 3rd party libraries. Our in-house code is currently clean. The build warnings against the 3rd party frameworks represent technical debt incurred by them, and, while annoying, can they can usually be safely ignored. Any warning from the in-house code can also, for the moment at least, be safely ignored. 
5. Use Xcode's project navigator to explore the project structure. You will see that the internal name for the project is f4s-workexperience. Under this top level project you will find a number of folders that hold the in-house source code and various configuration files. You will also see a number of subprojects in the "Pods" folder. The pods represent the 3rd party frameworks that the project depends on, and typically you will not need to touch them.
6. Now it is time to actually run the app. Immediately to the right of Xcode's scheme selector, you will see the device selector. Choose the latest iPhone simulator from the list, then build and run (cmd+r). It is typically much quicker to develop against a simulator than a real device, but there are some limitations. For example, push notifcation will not be received, and you will need to specify your location manually. Alternatively, plug an iOS device into your computer and trust the computer. Xcode will configure your device to support debugging. This can take quite a while but only needs to be done once. Once you have your device trusted and equipped for debugging under Xcode, you can select it from the device list and run the app 

13.  Use Xcode's plethora of debugging tools to reproduce, identify, and fix the fault you need to address. 

14. Now it is time to build and release your fix to the Appstore. This assumes you have been doing this work in total isolation and you have been working on the *master* branch. If this is not the case, then you will need to follow standard Xcode procedures to branch from *master* onto a feature branch, rebase on *master* when you are ready,  and finally to merge.

1. Make one final change to the project to bump the build number appropriately. 
2. Tag the changes in Xcode's source control navigator with the build number.
3. Use Xcode's source control menu to commit your changes to the local Git repo. While doing this, take the opportunity to tick "push" to push them to the remote repo and to push the tags too.
4. Select Generic iOS device from Xcode's device selector (simulators cannot be used to build releases).
5. Ensure you have the staging scheme selected in Xcode 
6. Use the Product/Archive menu to archive the build on your computer. This will take a few minutes.
7. When the archive completes, click the "Distribute App" button to move to the next step
8. Make sure the iOS App Store option is selected, then click "Next" to move to the next screen
9. Make sure "Upload (send to App Store Connect)" is selected, then click "Next" to move to the next step.
10. Ensure that "include bitcode", "strip swift symbols", and "upload your app's symbols" are all selected, then  click "Next" to move to the next step
11. Review the ipa content and click "upload" to begin the upload process. If all goes well, the app will upload in about 5 or 10 minutes on the office internet. If you try from a standard home internet connection where upload speeds are sacrificed for dowload speed, it will take significantly longer.
12. Eventually if all goes well, you will be told that the upload succeeded. Typically, the most likely reason for failure is that you forgot to bump the version number. If so, go back to step 1 and repeat all the steps.
13. You have now uploaded the staging version of the app to Apple. This is not intended for release, but is, after a very short Apple review (typically an hour or so) suitable for testing on Testflight
14. Now switch the Xcode scheme to f4s-f4s_live repeat steps 6 to 13 to archive and upload the production build. You are now done with Xcode 
15. Switch to your browser and go to App Store Connect https://appstoreconnect.apple.com. You will need an appropriate F4S iOS dev account in order to sign in.
16. Select "My Apps"
17. Select "Workfinder" (the one with the green icon, not the yellow icon)
18. Click the + version button to add a new version, and choose iOS rather than tvOS. (Note that it is possible that someone before you has already configured a placeholder for the next release, and if this is the case, the + version button will not be enabled). The remainder of this document assumes that it is enabled.
19. In the popover, enter the version number as you want it to appear on the App Store and click "Create"
20. Add some text in the "what's new" area. Choose your words carefully becasue they will appear on the App Store.
21. Scroll down the page until you get to the Build section. Click the button to attach the production build you uploaded earlier to the release
22. Scroll back to the top and click "Save".
23. Click "Submit"
24. You will be asked some questions about advertising identifiers. It is vital you answer these questions accurately, otherwise your build will be rejected out of hand. TICK "Does this app use the Advertising Identifier (IDFA)?", then leave "Serve advertisements within the app" UNTICKED, and TICK "Attribute this app installation to a previously served advertisement" and "Attribute an action taken within this app to a previously served advertisement".  These IDFA options are required and a consequence of the inclusion of the SEGMENT 3rd party framework within the app.
25. Your build has now been submitted to for Apple review, and if it passes, it will go live on the AppStore. Good luck!

