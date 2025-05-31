### ENUM DEFINITIONS ###
enum SEMSTypes {
    # Security Event Message String Types
    logonType = 1
    sourceNetworkAddress
    accountName
    accountDomain
}

enum SEMSCultures {
    # Security Event Message String Cultures
    en_US = 1033
    fr_FR = 1036
}


### ABSTRACT CLASS DEFINITIONS ###
class AbstractSEMS {
    # Abstract Security Event Message Strings Class
    [cultureinfo]$cultureInfo
    [String]$logonType
    [String]$sourceNetworkAddress
    [String]$accountName
    [String]$accountDomain

    AbstractSEMS() {}
    AbstractSEMS([String]$cultureInfoName) {
        $this.cultureInfo = [cultureinfo]::GetCultureInfo($cultureInfoName)
    }

    [String]getSEMS([int]$code) {
        # Return a string for the given enum code of the SEMS
        [String]$messageString = ""
        switch ($code) {
            1 {$messageString = $this.logonType}
            2 {$messageString = $this.sourceNetworkAddress}
            3 {$messageString = $this.accountName}
            4 {$messageString = $this.accountDomain}
            default {throw("SEMS code unknown.")}
        }
        return $messageString
    }
        
    [String]getSEMS([String]$SEMSType) {
        return $this.getSEMS([int]([SEMSTypes]::$SEMSType))
    }
}

### CLASS DEFINITIONS
class SEMS_en_US : AbstractSEMS {
    # SEMS using en_US culture
    SEMS_en_US([String]$cultureInfoName) : base($cultureInfoName) {
        $this.logonType = "Logon Type"
        $this.sourceNetworkAddress = "Source Network Address"
        $this.accountName = "Account Name"
        $this.accountDomain = "Account Domain"
    }
}

class SEMS_fr_FR : AbstractSEMS {
    # SEMS using en_US culture
    SEMS_fr_FR([String]$cultureInfoName) : base($cultureInfoName) {
        $this.logonType = "Type d.ouverture de session"
        $this.sourceNetworkAddress = "Adresse du r.seau source"
        $this.accountName = "Nom du compte"
        $this.accountDomain = "Domaine du compte"
    }
}

class SEMSFactory {
    [AbstractSEMS]getSEMS([String]$cultureInfoName) {
        [AbstractSEMS]$SEMS = $null
        switch ($cultureInfoName) {
            "en-US" { $SEMS = [SEMS_en_US]::new($cultureInfoName)}
            "fr-FR" { $SEMS = [SEMS_fr_FR]::new($cultureInfoName)}
            default { $SEMS = [AbstractSEMS]::new()}
        }
        return $SEMS
    }
}

class SecurityEventsParser {
    [System.DateTime]$fromDate
    [System.DateTime]$toDate
    [int[]]$eventsId

    SecurityEventsParser([System.DateTime]$fromDate, [System.DateTime]$toDate, [int[]]$eventsId ) {
        $this.fromDate = $fromDate
        $this.toDate = $toDate
        $this.eventsId = $eventsId
    }

    SecurityEventsParser([System.DateTime]$fromDate, [int[]]$eventsId ) {
        $this.fromDate = $fromDate
        $this.toDate = Get-Date
        $this.eventsId = $eventsId
    }

    [System.Diagnostics.EventLogEntry[]]getEvents() {
        [System.Diagnostics.EventLogEntry[]]$events = Get-EventLog -LogName Security -After $this.fromDate -Before $this.toDate | Where-Object {
            $this.eventsId -contains $_.EventID
        }
        return $events
    }
}

Class RDPSEP : SecurityEventsParser {
    # RDP Security Events Parser
    [int[]]$eventsId = (4624, 4778)
    [AbstractSEMS]$SEMS

    RDPSEP([System.DateTime]$fromDate, [System.DateTime]$toDate, [String]$cultureInfoName) : base($fromDate, $toDate, (4624, 4778)) {
        [SEMSFactory]$SEMSFactory = [SEMSFactory]::new()
        $this.SEMS = $SEMSFactory.getSEMS($cultureInfoName)
    }
    RDPSEP([System.DateTime]$fromDate, [String]$cultureInfoName) : base($fromDate, (4624, 4778)) {
        [SEMSFactory]$SEMSFactory = [SEMSFactory]::new()
        $this.SEMS = $SEMSFactory.getSEMS($cultureInfoName)
    }

    [System.Object[]]getEvents() {
        [System.Object[]]$events = Get-EventLog -LogName Security -After $this.fromDate -Before $this.toDate | Where-Object {
            $this.eventsId -contains $_.EventID
        } | ForEach-Object {
            [RDPEventData]::new($_.Message, $this.SEMS, $_.TimeGenerated)
        } | Sort-Object timeGenerated -Descending | Select-Object timeGenerated, sourceNetworkAddress `
        , @{N='Username';E={'{0}\{1}' -f $_.accountDomain, $_.accountName}} `
        , @{N='LogType';E={
            switch ($_.logonType) {
                2 {'Interactive - local logon'}
                3 {'Network connection to shared folder'}
                4 {'Batch'}
                5 {'Service'}
                7 {'Unlock (after screensaver)'}
                8 {'NetworkCleartext'}
                9 {'NewCredentials (local impersonation process under existing connection)'}
                10 {'RDP'}
                11 {'CachedInteractive'}
                default {"LogType Not Recognised: $($_.logonType)"}
            }
        }}
        return $events
    }
}

class RDPEventData {
    hidden [String]$message
    hidden [AbstractSEMS]$SEMS
    [String]$logonType
    [String]$sourceNetworkAddress
    [String]$accountName
    [String]$accountDomain
    [System.DateTime]$timeGenerated

    RDPEventData([String]$message, [AbstractSEMS]$SEMS, [System.DateTime]$timeGenerated) {
        $this.message = $message
        $this.logonType = $this.extractDataInMessage($SEMS.getSEMS(1))
        $this.sourceNetworkAddress = $this.extractDataInMessage($SEMS.getSEMS(2))
        $this.accountName = $this.extractDataInMessage($SEMS.getSEMS(3))
        $this.accountDomain = $this.extractDataInMessage($SEMS.getSEMS(4))
        $this.timeGenerated = $timeGenerated
    }

    hidden [String]extractDataInMessage([String]$SEMS) {
        $this.message -match '(?msi).*{0}\s*:\s*([^\s]+)' -f $SEMS
        return $Matches[1]
    }
}

### MAIN ###
[String[]]$excludedAddresses = ('-', '::1', '127.0.0.1')
[System.DateTime]$startTime = Get-Date
[System.DateTime]$toDate = $startTime
[System.DateTime]$fromDate = $toDate.AddHours(-12)
[System.DateTime]$stopTime = Get-Date -Year 2022 -Month 1 -Day 1 -Hour 00 -Minute 00 -Second 00

While ($fromDate -ge $stopTime) {
    Write-Host -BackgroundColor DarkRed ("From: {0}, To: {1}" -f $fromDate, $toDate)
    [SecurityEventsParser]$RDPSEP = [RDPSEP]::new($fromDate, $toDate, ([cultureinfo]::CurrentCulture).Name)
    #$RDPSEP.getEvents() | Where-Object { $excludedAddresses -notcontains $_.sourceNetworkAddress }
    $RDPSEP.getEvents() | Where-Object { $_.sourceNetworkAddress -like '193.37.224.15' }
    $toDate = $fromDate
    $fromDate = $fromDate.AddHours(-6)
}
Write-Host -BackgroundColor DarkRed ("From: {0}, To: {1}" -f $fromDate, $toDate)
[SecurityEventsParser]$RDPSEP = [RDPSEP]::new($fromDate, $toDate, ([cultureinfo]::CurrentCulture).Name)
$RDPSEP.getEvents() | Where-Object { $_.sourceNetworkAddress -like '193.37.224.15' }
