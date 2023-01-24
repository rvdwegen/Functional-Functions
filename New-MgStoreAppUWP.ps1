Connect-MgGraph -Scopes "DeviceManagementApps.ReadWrite.All"

function New-MgStoreAppUWP {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$AppId,

        [Parameter(Mandatory=$false)]
        [ValidateSet("AllUsers", "AllDevices")]
        [string]$Assignment = "AllUsers"
    )

    Try {
        If ((Get-MgContext) -eq $null) {
            Throw 'Please connect to Graph first with Connect-MGGraph -scopes "DeviceManagementApps.ReadWrite.All"'
        }

        If (!(Get-MgContext).Scopes.Contains("DeviceManagementApps.ReadWrite.All")) {
            Throw "Graph connection scope does not include DeviceManagementApps.ReadWrite.All"
        }

        $App = Invoke-RestMethod -Method "GET" -uri "https://storeedgefd.dsx.mp.microsoft.com/v9.0/packageManifests/$AppId"

        $appBody = @{
            '@odata.type'         = "#microsoft.graph.winGetApp"
            description           = $app.Data.Versions[-1].DefaultLocale.ShortDescription
            developer             = $app.Data.Versions[-1].DefaultLocale.Publisher
            displayName           = $app.Data.Versions[-1].DefaultLocale.packageName
            informationUrl        = $app.Data.Versions[-1].DefaultLocale.PublisherSupportUrl
            largeIcon             = @{
                "@odata.type"= "#microsoft.graph.mimeContent"
                type = "image/png"
                value = [Convert]::ToBase64String(((Invoke-WebRequest -Uri ((Invoke-RestMethod -Method "Get" -Uri ("https://apps.microsoft.com/store/api/ProductsDetails/GetProductDetailsById/" + $AppId + "?hl=en-US&gl=US")).IconUrl)).Content))
            }
            installExperience     = @{
                runAsAccount = $app.Data.Versions[-1].Installers.scope
            }
            isFeatured            = $false
            packageIdentifier     = $app.Data.PackageIdentifier
            privacyInformationUrl = $app.Data.Versions[-1].DefaultLocale.PrivacyUrl
            publisher             = $app.Data.Versions[-1].DefaultLocale.publisher
            repositoryType        = "microsoftStore"
            roleScopeTagIds       = @()
        } | ConvertTo-Json
        
        $appDeploy = Invoke-MgGraphRequest -uri "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps" -Method POST -Body $appBody
        
        $assignBody = @{
            mobileAppAssignments = @(
                @{
                    "@odata.type" = "#microsoft.graph.mobileAppAssignment"
                    target        = @{
                        "@odata.type" = "#microsoft.graph.allDevicesAssignmentTarget" #allLicensedUsersAssignmentTarget
                    }
                    intent        = "Required"
                    settings      = @{
                        "@odata.type"       = "#microsoft.graph.winGetAppAssignmentSettings"
                        notifications       = "showAll"
                        installTimeSettings = $null
                        restartSettings     = $null
                    }
                }
            )
        }

        switch ($Assignment) {
            "AllUsers" {
                $assignBody.mobileAppAssignments.Target."@odata.type" = "#microsoft.graph.allLicensedUsersAssignmentTarget"

                Invoke-MgGraphRequest -uri ("https://graph.microsoft.com/beta/deviceAppManagement/mobileApps/" + $appDeploy.id + "/assign") -Method POST -Body ($assignBody | ConvertTo-Json -Depth 8)
            }
            "AllDevices" {
                $assignBody.mobileAppAssignments.Target."@odata.type" = "#microsoft.graph.allDevicesAssignmentTarget"

                Invoke-MgGraphRequest -uri ("https://graph.microsoft.com/beta/deviceAppManagement/mobileApps/" + $appDeploy.id + "/assign") -Method POST -Body ($assignBody | ConvertTo-Json -Depth 8)
            }
            Default { Write-Output "No assignment requested"}
        }
        
    } Catch {
        Write-Host $_.Exception.GetType().FullName -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Write-Host $_.Exception -ForegroundColor Red
    }
}

New-MgStoreAppUWP -AppId "9WZDNCRFJBB1"
