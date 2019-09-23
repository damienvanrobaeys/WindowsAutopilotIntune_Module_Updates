# My updates on the module WindowsAutopilotIntune
![alt text](https://github.com/damienvanrobaeys/WindowsAutopilotIntune_Module_Updates/blob/master/manage_autopilot_preview.jpg)

**More cmdlet for the Windows Autopilot Intune module**

- Update 23/09/19: Add the possibility to enable white glove in a deployment profile

You will first to install the original module from MS from the PowerShell Gallery:
install-module WindowsAutopilotIntune

The repo is composed of one script:
WindowsAutopilotIntune_Updates.ps1: Cmdlets I added in the existing module

In this file I added the below functions:
* Set-AutopilotProfile: Change deployment profile options
* Remove-AutoPilotProfile: Remove a Deployment Profile
* Add-AutoPilotProfile: Create a Deployment Profile
* Set-AutoPilotProfileAssignedGroup: Assign a group to a Deployment Profile 
* Remove-AutoPilotProfileAssignments: Remove a group from a Deployment profile
* Get-AutoPilotProfileAssignedDevice: List assigned devices for a Deployment Profile
* Get-AutoPilotProfileAssignments: List assigned groups for a Deployment Profile
* Add-EnrollmentStatusPage: Create an Enrollment Status Page
* Get-EnrollmentStatusPage: List Enrollment Status Page
* Set-EnrollmentStatusPage: Change Enrollment Status Page option
* Remove-EnrollmentStatusPage: Remove an Enrollment Status Page

If you want to add test or add those functions, add part from the second file in the WindowsAutopilotIntune.ps1 file from the module.

/!\ Those functions are not official, I added them in my own environment; don't hesitate if you have any feedback.
damien.vanrobaeys@gmail.com

