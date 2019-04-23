# ADD THIS IN THE WINDOWSAUTOPILOT.PS1 FILE FROM THE MODULE

Function Set-AutoPilotProfile(){
<#
.SYNOPSIS
Sets Windows Autopilot profile properties.

.DESCRIPTION
The Set-AutoPilotProfile cmdlet sets properties on an existing Autopilot profile.

.PARAMETER id
Type: Integer - The ID (GUID) of the profile to be updated.

.PARAMETER language
Type: String - The language identifier (e.g. "en-us") to be configured in the profile.

.PARAMETER description
Type: String - The description to be configured in the profile.

.PARAMETER ConvertDeviceToAutopilot
Type: Boolean - Configure the value "Convert all targeted devices to Autopilot"  

.PARAMETER OOBE_HideEULA
Type: Boolean - Configure the OOBE option to hide or not the EULA

.PARAMETER OOBE_hidePrivacySettings
Type: Boolean - Configure the OOBE option to hide or not the privacy settings

.PARAMETER OOBE_HideChangeAccountOpts
Type: Boolean - Configure the OOBE option to hide or not the change account options

.PARAMETER OOBE_userTypeAdmin
Type: Switch - Configure the user account type as administrator. 

.PARAMETER OOBE_userTypeUser
Type: Switch - Configure the user account type as standard. 

.PARAMETER OOBE_NameTemplate
Type: String - Configure the OOBE option to apply a device name template

.PARAMETER OOBE_SkipKeyboard
Type: String - Configure the OOBE option to skip or not the keyboard selection page

.EXAMPLE
Get a list of all Windows Autopilot profiles.

Set-AutoPilotProfile -ID <guid> -Language "en-us"
Set-AutoPilotProfile -ID <guid> -Language "en-us" -displayname "My testing profile" -Description "Description of my profile" -OOBE_HideEULA $True -OOBE_hidePrivacySettings $True


#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$True)] $id,
	[string]$language,
	[string]$displayname,
	[string]$description,
	[bool]$ConvertDeviceToAutopilot,
	[bool]$OOBE_HideEULA,	
	[bool]$OOBE_hidePrivacySettings,
	[bool]$OOBE_HideChangeAccountOpts,		
	[Switch]$OOBE_userTypeAdmin,
	[Switch]$OOBE_userTypeUser,		
	[string]$OOBE_NameTemplate,	
	[bool]$OOBE_SkipKeyboard	
)

	# LIST EXISTING VALUES FOR THE SELECTING PROFILE
	# Default profile values
	$Profile_Values = Get-AutoPilotProfile -ID $id
	$Profile_DisplayName = $Profile_Values.displayName
	$Profile_Description = $Profile_Values.description
	$Profile_language = $Profile_Values.language
	$Profile_ConvertDeviceToAutopilot = $Profile_Values.extractHardwareHash
	$Profile_enableWhiteGlove = $Profile_Values.enableWhiteGlove
	$Profile_deviceType = $Profile_Values.deviceType
	$Profile_deviceNameTemplate = $Profile_Values.deviceNameTemplate
	
	# OOBE profile values
	$Profile_OOBE_NameTemplate = $Profile_Values.deviceNameTemplate	
	$Profile_OOBE_HideEULA = $Profile_Values.outOfBoxExperienceSettings.hideEULA
	$Profile_OOBE_hidePrivacySettings = $Profile_Values.outOfBoxExperienceSettings.hidePrivacySettings
	$Profile_OOBE_userTypeAdmin = $Profile_Values.outOfBoxExperienceSettings.userType	
	$Profile_OOBE_SkipKeyboard = $Profile_Values.outOfBoxExperienceSettings.skipKeyboardSelectionPage
	$Profile_OOBE_HideChangeAccountOpts = $Profile_Values.outOfBoxExperienceSettings.hideEscapeLink

	
	# If user has selected admin mode
	If($OOBE_userTypeAdmin)
		{		
			$OOBE_userType = "Administrator"
		}
		
	If($OOBE_userTypeUser)
		{		
			$OOBE_userType = "Standard"
		}		
		
	If(($OOBE_userTypeAdmin) -and ($OOBE_userTypeUser)) 	
		{
			write-warning "Please select OOBE_userTypeAdmin OR OOBE_userTypeUser, not both !!!"
			break
		}			
		
	If((!($OOBE_userTypeAdmin)) -and (!($OOBE_userTypeUser))) 	
		{
			$OOBE_userType = $Profile_OOBE_userTypeAdmin
		}			

	If(($displayname -eq "")) # If user hasn't typed a display name
		{
			$displayname = $Profile_DisplayName # We will used the existing value
		}
	Else # If user has typed a display name
		{
			$displayname = $displayname # We will use the typed display name		
		}

	If(($OOBE_NameTemplate -eq $null))
		{
			$OOBE_NameTemplate = $Profile_deviceNameTemplate
		}
	ElseIf(($OOBE_NameTemplate -eq ""))
		{
			$OOBE_NameTemplate = ""		
		}		
		
	If(($language -eq ""))
		{
			$language = $Profile_language
		}

	If(($description -eq ""))
		{
			$description = $Profile_Description
		}

	If(($ConvertDeviceToAutopilot -eq $null))
		{
			$ConvertDeviceToAutopilot = $Profile_ConvertDeviceToAutopilot
		}
		
	If(($OOBE_HideEULA -eq $null))
		{
			$OOBE_HideEULA = $Profile_OOBE_HideEULA
		}

	If(($OOBE_hidePrivacySettings -eq $null))
		{
			$OOBE_hidePrivacySettings = $Profile_OOBE_hidePrivacySettings
		}
	
	If(($OOBE_SkipKeyboard -eq ""))
		{
			$OOBE_SkipKeyboard = $Profile_OOBE_SkipKeyboard
		}	

	If(($OOBE_HideChangeAccountOpts -eq $null))
		{
			$OOBE_HideChangeAccountOpts = $Profile_OOBE_HideChangeAccountOpts
		}			
		
		
    # Defining Variables
    $graphApiVersion = "beta"
    $Resource = "deviceManagement/windowsAutopilotDeploymentProfiles"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$Resource/$id"
    $json = @"
{
    "@odata.type": "#microsoft.graph.azureADWindowsAutopilotDeploymentProfile",
    "displayName": "$displayname",
    "description": "$description",
    "language": "$language",
    "extractHardwareHash": "$ConvertDeviceToAutopilot",
    "deviceNameTemplate": "$OOBE_NameTemplate",
    "deviceType": "$Profile_deviceType",
    "enableWhiteGlove": false,
    "outOfBoxExperienceSettings": {
		"@odata.type": "microsoft.graph.outOfBoxExperienceSettings",	
        "hidePrivacySettings": "$OOBE_hidePrivacySettings",
        "hideEULA": "$OOBE_HideEULA",
        "userType": "$OOBE_userType",
        "deviceUsageType": "singleUser",
        "skipKeyboardSelectionPage": "$OOBE_SkipKeyboard",
        "hideEscapeLink": "$OOBE_HideChangeAccountOpts"
    }
}
"@

    Write-Host $json
    try {
        Invoke-RestMethod -Uri $uri -Headers $authToken -Method Patch -Body $json -ContentType "application/json"
    }
    catch {

        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();

        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"

        break
    }

}







Function Add-AutoPilotProfile(){
<#
.SYNOPSIS
Sets Windows Autopilot profile properties.

.DESCRIPTION
The Add-AutoPilotProfile cmdlet sets properties on an existing Autopilot profile.

.PARAMETER id
The ID (GUID) of the profile to be updated.

.PARAMETER language
Type: String - The language identifier (e.g. "en-us") to be configured in the profile.

.PARAMETER description
Type: String - The description to be configured in the profile.

.PARAMETER ConvertDeviceToAutopilot
Type: Boolean - Configure the value "Convert all targeted devices to Autopilot"  

.PARAMETER OOBE_HideEULA
Type: Boolean - Configure the OOBE option to hide or not the EULA

.PARAMETER OOBE_hidePrivacySettings
Type: Boolean - Configure the OOBE option to hide or not the privacy settings

.PARAMETER OOBE_HideChangeAccountOpts
Type: Boolean - Configure the OOBE option to hide or not the change account options

.PARAMETER OOBE_userTypeAdmin
Type: Switch - Configure the user account type as administrator. 

.PARAMETER OOBE_userTypeUser
Type: Switch - Configure the user account type as standard. 

.PARAMETER ModeUserDriven
Type: Switch - Configure the deployment mode to user driven

.PARAMETER ModeSelfDeploying
Type: Switch - Configure the deployment mode to self deploying

.PARAMETER OOBE_NameTemplate
Type: String - Configure the OOBE option to apply a device name template

.PARAMETER OOBE_SkipKeyboard
Type: Boolean - Configure the OOBE option to skip or not the keyboard selection page

.EXAMPLE
Get a list of all Windows Autopilot profiles.

Add-AutoPilotProfile -Language "en-us" -displayname "My testing profile" -Description "Description of my profile" -OOBE_HideEULA $True -OOBE_hidePrivacySettings $True


#>
[cmdletbinding()]
param
(
	[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$True)][string]$displayname,
	[string]$language,
	[string]$description,
	[bool]$ConvertDeviceToAutopilot,
	[bool]$OOBE_HideEULA,	
	[bool]$OOBE_hidePrivacySettings,
	[bool]$OOBE_HideChangeAccountOpts,		
	[Switch]$ModeUserDriven,
	[Switch]$ModeSelfDeploying,	
	[Switch]$OOBE_userTypeAdmin,
	[Switch]$OOBE_userTypeUser,		
	[string]$OOBE_NameTemplate	
)

	# If user has selected admin mode
	If($OOBE_userTypeAdmin)
		{		
			$OOBE_userType = "Administrator"
		}
		
	If($OOBE_userTypeUser)
		{		
			$OOBE_userType = "Standard"
		}		
		
	If(($OOBE_userTypeAdmin) -and ($OOBE_userTypeUser)) 	
		{
			write-warning "Please select OOBE_userTypeAdmin OR OOBE_userTypeUser, not both !!!"
			break
		}			

	If((!($OOBE_userTypeAdmin)) -and (!($OOBE_userTypeUser))) 	
		{
			$OOBE_userType = "Standard"
		}		

	If($ModeUserDriven)
		{		
			$Deployment_Mode = "singleUser"
		}
		
	If($ModeSelfDeploying)
		{		
			$Deployment_Mode = "Shared"
		}		
		
	If(($ModeUserDriven) -and ($ModeSelfDeploying)) 	
		{
			write-warning "Please select ModeUserDriven OR ModeSelfDeploying, not both !!!"
			break
		}			

	If((!($ModeUserDriven)) -and (!($ModeSelfDeploying))) 	
		{
			$Deployment_Mode = "singleUser"
		}		
		

	If(($displayname -eq "")) # If user hasn't typed a display name
		{
			$displayname = $Profile_DisplayName # We will used the existing value
		}
	Else # If user has typed a display name
		{
			$displayname = $displayname # We will use the typed display name		
		}

		
    # Defining Variables
    $graphApiVersion = "beta"
    $Resource = "deviceManagement/windowsAutopilotDeploymentProfiles"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$Resource"
    $json = @"
{
    "@odata.type": "#microsoft.graph.azureADWindowsAutopilotDeploymentProfile",
    "displayName": "$displayname",
    "description": "$description",
    "language": "$language",
    "extractHardwareHash": "$ConvertDeviceToAutopilot",
    "deviceNameTemplate": "$OOBE_NameTemplate",
    "deviceType": "windowsPc",
    "enableWhiteGlove": false,
    "outOfBoxExperienceSettings": {
		"@odata.type": "microsoft.graph.outOfBoxExperienceSettings",	
        "hidePrivacySettings": "$OOBE_hidePrivacySettings",
        "hideEULA": "$OOBE_HideEULA",
        "userType": "$OOBE_userType",
        "deviceUsageType": "$Deployment_Mode",
        "skipKeyboardSelectionPage": "false",
        "hideEscapeLink": "$OOBE_HideChangeAccountOpts",
    }
}
"@

    Write-Host $json
    try {
        Invoke-RestMethod -Uri $uri -Headers $authToken -Method Post -Body $json -ContentType "application/json"
    }
    catch {

        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();

        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"

        break
    }

}






Function Remove-AutoPilotProfile(){
<#
.SYNOPSIS
Remove a Deployment Profile

.DESCRIPTION
The Remove-AutoPilotProfile allows you to remove a specific deployment profile

.PARAMETER id
Mandatory, the ID (GUID) of the profile to be removed.

.EXAMPLE
Remove-AutoPilotProfile -id $id
#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True)] $id
)

    # Defining Variables
    $graphApiVersion = "beta"
    $Resource = "deviceManagement/windowsAutopilotDeploymentProfiles"
	$uri = "https://graph.microsoft.com/$graphApiVersion/$Resource/$id"

    Try 
		{
			$response = Invoke-RestMethod -Uri $uri -Headers $authToken -Method Delete
			if ($id) {
				$response
			}
			else {
				$response.Value
			}
		}
    catch 
		{

			$ex = $_.Exception
			$errorResponse = $ex.Response.GetResponseStream()
			$reader = New-Object System.IO.StreamReader($errorResponse)
			$reader.BaseStream.Position = 0
			$reader.DiscardBufferedData()
			$responseBody = $reader.ReadToEnd();

			Write-Host "Response content:`n$responseBody" -f Red
			Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"

			break
		}
}


Function Get-AutoPilotProfileAssignedDevice(){
<#
.SYNOPSIS
List all assigned devices for a specific profile ID

.DESCRIPTION
The Get-AutoPilotProfileAssignedDevice cmdlet returns the list of devices that are assigned to a deployment profile

.PARAMETER id
Type: Integer - Mandatory, the ID (GUID) of the profile to be retrieved.

.EXAMPLE
Get a list of all Windows Autopilot profiles.
Get-AutoPilotProfileAssignedDevice -id $id
#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$true)] $id
)
    # Defining Variables
    $graphApiVersion = "beta"
    $Resource = "deviceManagement/windowsAutopilotDeploymentProfiles"

    if ($id) {
        $uri = "https://graph.microsoft.com/$graphApiVersion/$Resource/$id/assignedDevices"
    }
    else {
        $uri = "https://graph.microsoft.com/$graphApiVersion/$Resource"
    }
    try {
        $response = Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get
        if ($id) {
            $response.Value
        }
        else {
            $response.Value
        }
    }
    catch {

        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();

        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"

        break
    }

}




Function Get-AutoPilotProfileAssignments(){
<#
.SYNOPSIS
List all assigned devices for a specific profile ID

.DESCRIPTION
The Get-AutoPilotProfileAssignments cmdlet returns the list of groups that ae assigned to a spcific deployment profile

.PARAMETER id
Type: Integer - Mandatory, the ID (GUID) of the profile to be retrieved.

.EXAMPLE
Get-AutoPilotProfileAssignments -id $id
#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$true)] $id
)
    # Defining Variables
    $graphApiVersion = "beta"
    $Resource = "deviceManagement/windowsAutopilotDeploymentProfiles"

    if ($id) {
        $uri = "https://graph.microsoft.com/$graphApiVersion/$Resource/$id/assignments"
    }
    else {
        $uri = "https://graph.microsoft.com/$graphApiVersion/$Resource"
    }
    try {
        $response = Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get
		$Group_ID = $response.Value.target.groupId
		ForEach($Group in $Group_ID)
			{
				Try
					{
						get-azureadgroup | where {$_.ObjectId -like $Group}	
					}
				Catch
					{
						$Group
					}			
			}
    }
    catch {

        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();

        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"

        break
    }

}


Function Remove-AutoPilotProfileAssignments(){
<#
.SYNOPSIS
Removes a specific group assigntion for a specifc deployment profile

.DESCRIPTION
The Remove-AutoPilotProfileAssignments cmdlet allows you to remove a group assignation for a deployment profile 

.PARAMETER id
Type: Integer - Mandatory, the ID (GUID) of the profile

.PARAMETER groupid
Type: Integer - Mandatory, the ID of the group

.EXAMPLE
Remove-AutoPilotProfileAssignments -id $id
#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$true)]$id,
    [Parameter(Mandatory=$true)]$groupid
)
    # Defining Variables
    $graphApiVersion = "beta"
    $Resource = "deviceManagement/windowsAutopilotDeploymentProfiles"
	
	$full_assignment_id = $id + "_" + $groupid + "_0"

    $uri = "https://graph.microsoft.com/$graphApiVersion/$Resource/$id/assignments/$full_assignment_id"

    try {
        $response = Invoke-RestMethod -Uri $uri -Headers $authToken -Method Delete
		$response.Value
    }
    catch {

        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();

        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"

        break
    }

}

Function Set-AutoPilotProfileAssignedGroup(){
<#
.SYNOPSIS
Assigns a group to a Windows Autopilot profile.

.DESCRIPTION
The Set-AutoPilotProfileAssignedGroup cmdlet allows you to assign a specific group to a specific deployment profile

.PARAMETER id
Type: Integer - Mandatory, the ID (GUID) of the profile

.PARAMETER groupid
Type: Integer - Mandatory, the ID of the group

.EXAMPLE
Set-AutoPilotProfileAssignedGroup -id $id -groupid $groupid
#>
    [cmdletbinding()]
    param
    (
		[Parameter(Mandatory=$true)]$id,
		[Parameter(Mandatory=$true)]$groupid
    )
		$full_assignment_id = $id + "_" + $groupid + "_0"  
  
        # Defining Variables
        $graphApiVersion = "beta"
		$Resource = "deviceManagement/windowsAutopilotDeploymentProfiles"		
		$uri = "https://graph.microsoft.com/$graphApiVersion/$Resource/$id/assignments"		

$json = @"
{
	"id": "$full_assignment_id",
	"target": {
		"@odata.type": "#microsoft.graph.groupAssignmentTarget",
		"groupId": "$groupid"
	}
}
"@


        try {
            Invoke-RestMethod -Uri $uri -Headers $authToken -Method Post -Body $json -ContentType "application/json"
        }
        catch {
    
            $ex = $_.Exception
            $errorResponse = $ex.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorResponse)
            $reader.BaseStream.Position = 0
            $reader.DiscardBufferedData()
            $responseBody = $reader.ReadToEnd();
    
            Write-Host "Response content:`n$responseBody" -f Red
            Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
    
            break
        }
    
}




Function Get-EnrollmentStatusPage(){
<#
.SYNOPSIS
List enrollment status page

.DESCRIPTION
The Get-EnrollmentStatusPage cmdlet returns available enrollment status page with their options

.PARAMETER id
Mandatory, the ID (GUID) of the status page

.EXAMPLE
Get-EnrollmentStatusPage
#>

[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True)] $id
)

    # Defining Variables
    $graphApiVersion = "beta"
    $Resource = "deviceManagement/deviceEnrollmentConfigurations"

    if ($id) {
        $uri = "https://graph.microsoft.com/$graphApiVersion/$Resource/$id"
    }
    else {
        $uri = "https://graph.microsoft.com/$graphApiVersion/$Resource"
    }
    try {
        $response = Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get
        if ($id) {
            $response
        }
        else {
            $response.Value
        }
    }
    catch {

        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();

        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"

        break
    }

}



Function Add-EnrollmentStatusPage(){
<#
.SYNOPSIS
Adds a new Windows Autopilot Enrollment Status Page.

.DESCRIPTION
The Add-EnrollmentStatusPage cmdlet sets properties on an existing Autopilot profile.

.PARAMETER DisplayName
Type: String - Configure the display name of the enrollment status page

.PARAMETER description
Type: String - Configure the description of the enrollment status page

.PARAMETER HideProgress
Type: Boolean - Configure the option: Show app and profile installation progress

.PARAMETER AllowCollectLogs
Type: Boolean - Configure the option: Allow users to collect logs about installation errors

.PARAMETER Message
Type: String - Configure the option: Show custom message when an error occurs

.PARAMETER AllowUseOnFailure
Type: Boolean - Configure the option: Allow users to use device if installation error occurs

.PARAMETER AllowResetOnError
Type: Boolean - Configure the option: Allow users to reset device if installation error occurs

.PARAMETER BlockDeviceUntilComplete
Type: Boolean - Configure the option: Block device use until all apps and profiles are installed

.PARAMETER TimeoutInMinutes
Type: Integer - Configure the option: Show error when installation takes longer than specified number of minutes

.EXAMPLE
Add-EnrollmentStatusPage -Message "Oops an error occured, please contact your support" -HideProgress $True -AllowResetOnError $True
#>


[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True)][string]$DisplayName,
	[string]$Description,		
    [bool]$HideProgress,	
	[bool]$AllowCollectLogs,
	[bool]$blockDeviceSetupRetryByUser,	
	[string]$Message,	
	[bool]$AllowUseOnFailure,
	[bool]$AllowResetOnError,	
	[bool]$BlockDeviceUntilComplete,				
	[Int]$TimeoutInMinutes		
)

	If($HideProgress -eq $False)
		{
			$blockDeviceSetupRetryByUser = $true
		}

	If(($Description -eq $null))
		{
			$Description = $EnrollmentPage_Description
		}		

	If(($DisplayName -eq $null))
		{
			$DisplayName = ""
		}	

	If(($TimeoutInMinutes -eq ""))
		{
			$TimeoutInMinutes = "60"
		}				

    # Defining Variables
    $graphApiVersion = "beta"
    $Resource = "deviceManagement/deviceEnrollmentConfigurations"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$Resource"
    $json = @"
{
	"@odata.type": "#microsoft.graph.windows10EnrollmentCompletionPageConfiguration",
	"displayName": "$DisplayName",
	"description": "$description",
	"showInstallationProgress": "$hideprogress",
	"blockDeviceSetupRetryByUser": "$blockDeviceSetupRetryByUser",
	"allowDeviceResetOnInstallFailure": "$AllowResetOnError",
	"allowLogCollectionOnInstallFailure": "$AllowCollectLogs",
	"customErrorMessage": "$Message",
	"installProgressTimeoutInMinutes": "$TimeoutInMinutes",
	"allowDeviceUseOnInstallFailure": "$AllowUseOnFailure",
}
"@

    Write-Host $json
    try {
        Invoke-RestMethod -Uri $uri -Headers $authToken -Method Post -Body $json -ContentType "application/json"
    }
    catch {

        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();

        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"

        break
    }

}


Function Set-EnrollmentStatusPage(){
<#
.SYNOPSIS
Sets Windows Autopilot Enrollment Status Page properties.

.DESCRIPTION
The Set-EnrollmentStatusPage cmdlet sets properties on an existing Autopilot profile.

.PARAMETER id
The ID (GUID) of the profile to be updated.

.PARAMETER DisplayName
Type: String - Configure the display name of the enrollment status page

.PARAMETER description
Type: String - Configure the description of the enrollment status page

.PARAMETER HideProgress
Type: Boolean - Configure the option: Show app and profile installation progress

.PARAMETER AllowCollectLogs
Type: Boolean - Configure the option: Allow users to collect logs about installation errors

.PARAMETER Message
Type: String - Configure the option: Show custom message when an error occurs

.PARAMETER AllowUseOnFailure
Type: Boolean - Configure the option: Allow users to use device if installation error occurs

.PARAMETER AllowResetOnError
Type: Boolean - Configure the option: Allow users to reset device if installation error occurs

.PARAMETER BlockDeviceUntilComplete
Type: Boolean - Configure the option: Block device use until all apps and profiles are installed

.PARAMETER TimeoutInMinutes
Type: Integer - Configure the option: Show error when installation takes longer than specified number of minutes

.EXAMPLE
Set-EnrollmentStatusPage -id $id -Message "Oops an error occured, please contact your support" -HideProgress $True -AllowResetOnError $True
#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$True)] $id,
	[string]$DisplayName,	
	[string]$Description,		
	[bool]$HideProgress,
	[bool]$AllowCollectLogs,
	[string]$Message,	
	[bool]$AllowUseOnFailure,
	[bool]$AllowResetOnError,	
	[bool]$AllowUseOnError,	
	[bool]$BlockDeviceUntilComplete,				
	[Int]$TimeoutInMinutes		
)

	# LIST EXISTING VALUES FOR THE SELECTING STAUS PAGE
	# Default profile values
	$EnrollmentPage_Values = Get-EnrollmentStatusPage -ID $id
	$EnrollmentPage_DisplayName = $EnrollmentPage_Values.displayName
	$EnrollmentPage_Description = $EnrollmentPage_Values.description
	$EnrollmentPage_showInstallationProgress = $EnrollmentPage_Values.showInstallationProgress
	$EnrollmentPage_blockDeviceSetupRetryByUser = $EnrollmentPage_Values.blockDeviceSetupRetryByUser
	$EnrollmentPage_allowDeviceResetOnInstallFailure = $EnrollmentPage_Values.allowDeviceResetOnInstallFailure
	$EnrollmentPage_allowLogCollectionOnInstallFailure = $EnrollmentPage_Values.allowLogCollectionOnInstallFailure
	$EnrollmentPage_customErrorMessage = $EnrollmentPage_Values.customErrorMessage
	$EnrollmentPage_installProgressTimeoutInMinutes = $EnrollmentPage_Values.installProgressTimeoutInMinutes
	$EnrollmentPage_allowDeviceUseOnInstallFailure = $EnrollmentPage_Values.allowDeviceUseOnInstallFailure

	If(!($HideProgress))
		{
			$HideProgress = $EnrollmentPage_showInstallationProgress
		}	
	
	If(!($BlockDeviceUntilComplete))	
		{
			$BlockDeviceUntilComplete = $EnrollmentPage_blockDeviceSetupRetryByUser
		}		
		
	If(!($AllowCollectLogs))	
		{
			$AllowCollectLogs = $EnrollmentPage_allowLogCollectionOnInstallFailure
		}			
	
	If(!($AllowUseOnFailure))	
		{
			$AllowUseOnFailure = $EnrollmentPage_allowDeviceUseOnInstallFailure
		}	

	If(($Message -eq ""))
		{
			$Message = $EnrollmentPage_customErrorMessage
		}		
		
	If(($Description -eq $null))
		{
			$Description = $EnrollmentPage_Description
		}		

	If(($DisplayName -eq $null))
		{
			$DisplayName = $EnrollmentPage_DisplayName
		}	

	If(!($AllowResetOnError))	
		{
			$AllowResetOnError = $EnrollmentPage_allowDeviceResetOnInstallFailure
		}	

	If(($TimeoutInMinutes -eq ""))
		{
			$TimeoutInMinutes = $EnrollmentPage_installProgressTimeoutInMinutes
		}				

    # Defining Variables
    $graphApiVersion = "beta"
    $Resource = "deviceManagement/deviceEnrollmentConfigurations"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$Resource/$id"
    $json = @"
{
	"@odata.type": "#microsoft.graph.windows10EnrollmentCompletionPageConfiguration",
	"displayName": "$DisplayName",
	"description": "$description",
	"showInstallationProgress": "$HideProgress",
	"blockDeviceSetupRetryByUser": "$BlockDeviceUntilComplete",
	"allowDeviceResetOnInstallFailure": "$AllowResetOnError",
	"allowLogCollectionOnInstallFailure": "$AllowCollectLogs",
	"customErrorMessage": "$Message",
	"installProgressTimeoutInMinutes": "$TimeoutInMinutes",
	"allowDeviceUseOnInstallFailure": "$AllowUseOnFailure"
}
"@


    Write-Host $json
    try {
        Invoke-RestMethod -Uri $uri -Headers $authToken -Method Patch -Body $json -ContentType "application/json"
    }
    catch {

        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();

        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"

        break
    }

}



Function Remove-EnrollmentStatusPage(){
<#
.SYNOPSIS
Remove a specific enrollment status page

.DESCRIPTION
The Remove-EnrollmentStatusPage allows you to remove a specific enrollment status page 

.PARAMETER id
Mandatory, the ID (GUID) of the profile to be retrieved.

.EXAMPLE
Remove-EnrollmentStatusPage -id $id
#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True)] $id
)

    # Defining Variables
    $graphApiVersion = "beta"
    $Resource = "deviceManagement/deviceEnrollmentConfigurations"

    if ($id) {
        $uri = "https://graph.microsoft.com/$graphApiVersion/$Resource/$id"
    }
    else {
        $uri = "https://graph.microsoft.com/$graphApiVersion/$Resource"
    }
    try {
        $response = Invoke-RestMethod -Uri $uri -Headers $authToken -Method Delete
        if ($id) {
            $response
        }
        else {
            $response.Value
        }
    }
    catch {

        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();

        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"

        break
    }

}
