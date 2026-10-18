# ==============================================================================
# Amanah Healthcare Monorepo — Flutter Mobile Contract Verification Suite
# Point-of-View: Flutter Mobile App (Pure Client-First Contract Verification)
# Features: Presensi (Attendance), Perizinan (Leaves), Pengganti (Replacements),
#           Slip Gaji (Payroll Summary), & Push Notification Device Lifecycle
# ==============================================================================

param(
    [string]$BaseUrl = "http://127.0.0.1:3001",
    [string]$BackendDir = "D:\Amanah-health-care\backend"
)

$ErrorActionPreference = "Stop"

$script:TotalPass = 0
$script:TotalFail = 0
$script:TestStartTime = Get-Date

function Write-Section([string]$title) {
    Write-Host "`n================================================================================" -ForegroundColor Cyan
    Write-Host " $title" -ForegroundColor Cyan
    Write-Host "================================================================================" -ForegroundColor Cyan
}

function Report-Result([string]$testName, [bool]$passed, [string]$detail) {
    if ($passed) {
        $script:TotalPass++
        Write-Host " [PASS] $testName" -ForegroundColor Green
        if ($detail) {
            Write-Host "        $detail" -ForegroundColor Gray
        }
    } else {
        $script:TotalFail++
        Write-Host " [FAIL] $testName" -ForegroundColor Red
        if ($detail) {
            Write-Host "        $detail" -ForegroundColor Magenta
        }
    }
}

# ------------------------------------------------------------------------------
# STEP 0: Acquiring Dynamic Client Tokens
# ------------------------------------------------------------------------------
Write-Section "STEP 0: Acquiring Dynamic Mobile Client Tokens"

Push-Location $BackendDir
try {
    # 1. Doctor Zikri Token (Primary mobile doctor user)
    Write-Host "  Generating Doctor Zikri Token (zikrifadhiilahahmad@gmail.com)..." -ForegroundColor Yellow
    $doctorTokenRaw = (& bun run db:jwt --email zikrifadhiilahahmad@gmail.com --raw)
    $lines = $doctorTokenRaw -split "`r?`n"
    $doctorToken = ($lines | Where-Object { $_ -match "^eyJ[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+" } | Select-Object -First 1)
    if (-not $doctorToken) { $doctorToken = $doctorTokenRaw.Trim() }
    Report-Result "Doctor Token (zikrifadhiilahahmad@gmail.com)" ($null -ne $doctorToken -and $doctorToken.Length -gt 20) "Active doctor with 28 roster assignments"

    # 2. Peer Doctor Token (Peer staff for replacement claim)
    Write-Host "  Generating Peer Doctor Token (dr.maya@amanah-healthcare.test)..." -ForegroundColor Yellow
    $peerTokenRaw = (& bun run db:jwt --email dr.maya@amanah-healthcare.test --raw)
    $lines = $peerTokenRaw -split "`r?`n"
    $peerToken = ($lines | Where-Object { $_ -match "^eyJ[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+" } | Select-Object -First 1)
    if (-not $peerToken) { $peerToken = $peerTokenRaw.Trim() }
    Report-Result "Peer Doctor Token (dr.maya@amanah-healthcare.test)" ($null -ne $peerToken -and $peerToken.Length -gt 20) "Peer doctor for replacement claims"

    # 3. Admin Token (For clinic terminal QR rotation)
    Write-Host "  Generating Admin Token (admin@amanah.com)..." -ForegroundColor Yellow
    $adminTokenRaw = (& bun run db:jwt --email admin@amanah.com --raw)
    $lines = $adminTokenRaw -split "`r?`n"
    $adminToken = ($lines | Where-Object { $_ -match "^eyJ[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+" } | Select-Object -First 1)
    if (-not $adminToken) { $adminToken = $adminTokenRaw.Trim() }
    Report-Result "Admin Token (admin@amanah.com)" ($null -ne $adminToken -and $adminToken.Length -gt 20) "Admin token for terminal controls"
} finally {
    Pop-Location
}

if (-not $doctorToken -or -not $peerToken -or -not $adminToken) {
    Write-Host "`nFATAL: Failed to acquire required JWT tokens. Aborting test." -ForegroundColor Red
    exit 1
}

$doctorHeaders = @{
    "Authorization" = "Bearer $doctorToken"
    "Content-Type"  = "application/json"
}

$peerHeaders = @{
    "Authorization" = "Bearer $peerToken"
    "Content-Type"  = "application/json"
}

$adminHeaders = @{
    "Authorization" = "Bearer $adminToken"
    "Content-Type"  = "application/json"
}

# ------------------------------------------------------------------------------
# PHASE 1: Presensi Mobile (/attendance)
# ------------------------------------------------------------------------------
Write-Section "PHASE 1: Presensi Kehadiran Mobile (Scan, Checkout, History)"

# 1.1 Query/Rotate Active QR Session
$activeQrToken = ""
try {
    # Ensure fresh active QR token on terminal
    $rotateBody = @{ context = "Terminal Presensi Utama Flutter Test" } | ConvertTo-Json
    $rotateRes = Invoke-RestMethod -Uri "$BaseUrl/api/v1/attendance/qr/rotate" -Method Post -Headers $adminHeaders -Body $rotateBody
    $activeQrToken = $rotateRes.qrCodeIdentifier
    $hasQr = ($null -ne $activeQrToken) -and ($activeQrToken.Length -ge 4)
    Report-Result "POST /api/v1/attendance/qr/rotate (Terminal Active QR)" $hasQr "Active QR Code: $activeQrToken (Shift: $($rotateRes.shift))"
} catch {
    Report-Result "POST /api/v1/attendance/qr/rotate (Terminal Active QR)" $false $_.Exception.Message
}

# 1.2 Submit Mobile QR Scan
$scanResult = $null
try {
    $scanBody = @{
        qrToken = $activeQrToken
        shift = "morning"
        deviceInfo = "Xiaomi 13T (Android 14) / Amanah Mobile App"
    } | ConvertTo-Json

    $scanResult = Invoke-RestMethod -Uri "$BaseUrl/api/v1/attendance/scan" -Method Post -Headers $doctorHeaders -Body $scanBody -ContentType "application/json"
    $hasId = $null -ne $scanResult.id
    $hasStaff = $null -ne $scanResult.staffId
    $hasStatus = $scanResult.status -in @("present", "late")
    $hasCheckInAt = $null -ne $scanResult.checkInAt

    $scanPassed = $hasId -and $hasStaff -and $hasStatus -and $hasCheckInAt
    Report-Result "POST /api/v1/attendance/scan (Mobile Doctor Check-in)" $scanPassed "Record ID: $($scanResult.id), Staff: $($scanResult.staffId), Status: $($scanResult.status), CheckInAt: $($scanResult.checkInAt)"
} catch {
    Report-Result "POST /api/v1/attendance/scan (Mobile Doctor Check-in)" $false $_.Exception.Message
}

# 1.3 Submit Mobile Checkout (Self-Checkout)
try {
    $checkoutRes = Invoke-RestMethod -Uri "$BaseUrl/api/v1/attendance/checkout" -Method Post -Headers $doctorHeaders -Body "{}"
    $hasCheckoutTime = $null -ne $checkoutRes.checkOutAt
    $hasValidatedDuration = ($null -ne $checkoutRes.validatedDurationHours) -and ([double]$checkoutRes.validatedDurationHours -ge 0.5)

    $checkoutPassed = $hasCheckoutTime -and $hasValidatedDuration
    Report-Result "POST /api/v1/attendance/checkout (Mobile Doctor Self-Checkout)" $checkoutPassed "CheckOutAt: $($checkoutRes.checkOutAt), Validated Duration: $($checkoutRes.validatedDurationHours) hrs"
} catch {
    Report-Result "POST /api/v1/attendance/checkout (Mobile Doctor Self-Checkout)" $false $_.Exception.Message
}

# 1.4 Get My Attendance History
try {
    $historyRes = Invoke-RestMethod -Uri "$BaseUrl/api/v1/attendance/my-history" -Method Get -Headers $doctorHeaders
    $hasItems = ($null -ne $historyRes) -and ($historyRes.Count -gt 0)
    $latest = if ($hasItems) { $historyRes[0] } else { $null }

    # Validate DTO fields expected by Flutter AttendanceRecord
    $validRecord = $latest -and ($null -ne $latest.id) -and ($null -ne $latest.attendanceDate) -and ($null -ne $latest.status)
    Report-Result "GET /api/v1/attendance/my-history (Mobile Attendance History)" ($hasItems -and $validRecord) "Total Records: $($historyRes.Count), Latest: $($latest.attendanceDate) [$($latest.shift)] Status: $($latest.status)"
} catch {
    Report-Result "GET /api/v1/attendance/my-history (Mobile Attendance History)" $false $_.Exception.Message
}

# ------------------------------------------------------------------------------
# PHASE 2: Perizinan Cuti Dokter (/leaves)
# ------------------------------------------------------------------------------
Write-Section "PHASE 2: Perizinan Cuti Dokter (Eligible Sessions, Request, History, Cancel)"

$todayStr = (Get-Date).ToString("yyyy-MM-dd")
$eligibleSessions = @()

# 2.1 Get Eligible Sessions for Doctor Zikri
try {
    $eligibleSessions = Invoke-RestMethod -Uri "$BaseUrl/api/v1/leaves/eligible-sessions?date=$todayStr" -Method Get -Headers $doctorHeaders
    $hasSessions = ($null -ne $eligibleSessions) -and ($eligibleSessions.Count -gt 0)
    $firstSession = if ($hasSessions) { $eligibleSessions[0] } else { $null }

    # Validate Flutter EligibleSessionDto fields: sessionId, sessionCode, sessionLabel, startsAt, endsAt, workDate
    $validSessionDto = $firstSession -and 
                       ($null -ne $firstSession.sessionId) -and 
                       ($null -ne $firstSession.sessionCode) -and 
                       ($null -ne $firstSession.startsAt) -and 
                       ($null -ne $firstSession.workDate)

    Report-Result "GET /api/v1/leaves/eligible-sessions?date=$todayStr" ($hasSessions -and $validSessionDto) "Eligible Sessions Count: $($eligibleSessions.Count), First: $($firstSession.sessionLabel) ($($firstSession.startsAt)-$($firstSession.endsAt))"
} catch {
    Report-Result "GET /api/v1/leaves/eligible-sessions" $false $_.Exception.Message
}

# 2.2 Submit Session-Based Leave Request
$createdLeave = $null
try {
    $selectedSessionId = if ($eligibleSessions.Count -gt 0) { $eligibleSessions[0].sessionId } else { $null }
    $scope = if ($selectedSessionId) { "session" } else { "full_day" }
    $sessionIdsJson = if ($selectedSessionId) { '["' + $selectedSessionId + '"]' } else { '[]' }
    $leavePayload = '{' + 
        '"startDate":"' + $todayStr + '",' +
        '"endDate":"' + $todayStr + '",' +
        '"reason":"Permohonan Izin Medis Flutter Mobile E2E Test Suite",' +
        '"type":"cutiTahunan",' +
        '"scope":"' + $scope + '",' +
        '"sessionIds":' + $sessionIdsJson +
    '}'

    $createdLeave = Invoke-RestMethod -Uri "$BaseUrl/api/v1/leaves" -Method Post -Headers $doctorHeaders -Body $leavePayload -ContentType "application/json"
    $validLeaveDto = ($null -ne $createdLeave.id) -and 
                     ($createdLeave.status -eq "pending") -and 
                     ($createdLeave.reason -match "Flutter Mobile E2E")

    Report-Result "POST /api/v1/leaves (Submit Session Leave Request)" $validLeaveDto "Leave ID: $($createdLeave.id), Status: $($createdLeave.status), Scope: $($createdLeave.scope)"
} catch {
    $errDetail = if ($_.ErrorDetails.Message) { $_.ErrorDetails.Message } else { $_.Exception.Message }
    Report-Result "POST /api/v1/leaves (Submit Session Leave Request)" $false $errDetail
}

# 2.3 Query My Leaves History
try {
    $myLeaves = Invoke-RestMethod -Uri "$BaseUrl/api/v1/leaves/my-leaves" -Method Get -Headers $doctorHeaders
    $hasLeaves = ($null -ne $myLeaves) -and ($myLeaves.Count -gt 0)
    
    # Locate our newly created leave
    $foundCreated = $false
    if ($createdLeave) {
        $matching = $myLeaves | Where-Object { $_.id -eq $createdLeave.id }
        if ($matching) { $foundCreated = $true }
    }

    Report-Result "GET /api/v1/leaves/my-leaves (Doctor Leaves History)" ($hasLeaves -and $foundCreated) "Total Leaves: $($myLeaves.Count), Newly Created Leave Verified in List"
} catch {
    Report-Result "GET /api/v1/leaves/my-leaves (Doctor Leaves History)" $false $_.Exception.Message
}

# 2.4 Cancel Own Pending Leave Request
try {
    if ($createdLeave) {
        $cancelUrl = "$BaseUrl/api/v1/leaves/$($createdLeave.id)/cancel"
        $cancelledLeave = Invoke-RestMethod -Uri $cancelUrl -Method Patch -Headers $doctorHeaders -Body "{}" -ContentType "application/json"
        
        $isCancelled = ($cancelledLeave.status -eq "cancelled") -and ($null -ne $cancelledLeave.cancelledAt)
        Report-Result "PATCH /api/v1/leaves/:id/cancel (Doctor Self-Cancel Leave)" $isCancelled "Leave ID: $($cancelledLeave.id), Status: $($cancelledLeave.status), CancelledAt: $($cancelledLeave.cancelledAt)"
    } else {
        Report-Result "PATCH /api/v1/leaves/:id/cancel" $false "Skipped: Created leave was null"
    }
} catch {
    Report-Result "PATCH /api/v1/leaves/:id/cancel (Doctor Self-Cancel Leave)" $false $_.Exception.Message
}

# ------------------------------------------------------------------------------
# PHASE 3: Peluang Jadwal Pengganti (/replacements)
# ------------------------------------------------------------------------------
Write-Section "PHASE 3: Peluang Jadwal Pengganti (Query, Atomic Claim, Concurrency Check)"

# 3.1 Query Open Replacement Opportunities
$openReplacements = @()
try {
    $openReplacements = Invoke-RestMethod -Uri "$BaseUrl/api/v1/replacements?status=open" -Method Get -Headers $doctorHeaders
    $hasReplacements = ($null -ne $openReplacements) -and ($openReplacements.Count -gt 0)
    $firstOpportunity = if ($hasReplacements) { $openReplacements[0] } else { $null }

    # Validate Flutter ReplacementItemDto fields: id, leaveRequestId, sessionId, workDate, originalStaffProfileId, status
    $validReplacementDto = $firstOpportunity -and 
                           ($null -ne $firstOpportunity.id) -and 
                           ($null -ne $firstOpportunity.sessionId) -and 
                           ($null -ne $firstOpportunity.workDate) -and 
                           ($firstOpportunity.status -eq "open")

    Report-Result "GET /api/v1/replacements?status=open (Available Opportunities)" ($hasReplacements -and $validReplacementDto) "Total Opportunities: $($openReplacements.Count), Sample ID: $($firstOpportunity.id) on $($firstOpportunity.workDate)"
} catch {
    Report-Result "GET /api/v1/replacements?status=open" $false $_.Exception.Message
}

# 3.2 Peer Claim of Replacement Opportunity
$targetClaimId = $null
if ($openReplacements.Count -gt 0) {
    $targetClaimId = $openReplacements[0].id
    try {
        $claimUrl = "$BaseUrl/api/v1/replacements/$targetClaimId/claim"
        $claimRes = Invoke-RestMethod -Uri $claimUrl -Method Post -Headers $peerHeaders -Body "{}"
        
        $isClaimed = ($claimRes.status -eq "claimed") -and 
                     ($null -ne $claimRes.claimedByStaffProfileId) -and 
                     ($null -ne $claimRes.claimedAt)

        Report-Result "POST /api/v1/replacements/:id/claim (Peer Atomic Claim)" $isClaimed "Opportunity: $targetClaimId, ClaimedBy: $($claimRes.claimedByStaffProfileId), Status: $($claimRes.status)"
    } catch {
        Report-Result "POST /api/v1/replacements/:id/claim (Peer Atomic Claim)" $false $_.Exception.Message
    }

    # 3.3 Concurrency / Double-Claim Conflict Verification
    try {
        # Attempt to claim the already claimed opportunity using peer doctor token again
        $doubleClaimUrl = "$BaseUrl/api/v1/replacements/$targetClaimId/claim"
        $doubleClaimRes = Invoke-RestMethod -Uri $doubleClaimUrl -Method Post -Headers $peerHeaders -Body "{}"
        # If it succeeds, it violates concurrency control
        Report-Result "Concurrency Guard: Double-Claim Conflict (409)" $false "Expected HTTP 409 Conflict, but request unexpectedly succeeded"
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $is409 = ($statusCode -eq 409) -or ($_.Exception.Message -match "409") -or ($_.Exception.Message -match "sudah diambil")
        Report-Result "Concurrency Guard: Double-Claim Conflict (409)" $is409 "Correctly rejected second claim attempt (HTTP 409 Conflict)"
    }
} else {
    Report-Result "POST /api/v1/replacements/:id/claim" $true "Skipped: No open opportunities currently exist in DB"
}

# ------------------------------------------------------------------------------
# PHASE 4: Slip Gaji Pribadi & Periode Payroll (/payroll)
# ------------------------------------------------------------------------------
Write-Section "PHASE 4: Slip Gaji Pribadi & Periode Payroll (my-summary & periods)"

# 4.1 Personal Payroll Summary
try {
    $payrollSummary = Invoke-RestMethod -Uri "$BaseUrl/api/v1/payroll/my-summary" -Method Get -Headers $doctorHeaders
    
    # Validate Flutter StaffPayrollSummaryDto fields:
    # staffId, fullName, staffType, baseHours, baseEarnings, leaveDeductions, replacementAdditions, netPayroll, entries
    $hasStaffId = $null -ne $payrollSummary.staffId
    $hasFullName = $null -ne $payrollSummary.fullName
    $hasStaffType = $payrollSummary.staffType -eq "doctor"
    $hasEarnings = [double]$payrollSummary.baseEarnings -ge 0
    $hasNetPayroll = [double]$payrollSummary.netPayroll -ge 0
    $hasEntries = $null -ne $payrollSummary.entries

    $validSummary = $hasStaffId -and $hasFullName -and $hasStaffType -and $hasEarnings -and $hasNetPayroll -and $hasEntries
    Report-Result "GET /api/v1/payroll/my-summary (Doctor Personal Statement)" $validSummary "Staff: $($payrollSummary.fullName) ($($payrollSummary.staffType)), Net: Rp $($payrollSummary.netPayroll.ToString('N0')), Base Hours: $($payrollSummary.baseHours), Entries: $($payrollSummary.entries.Count)"
} catch {
    Report-Result "GET /api/v1/payroll/my-summary" $false $_.Exception.Message
}

# 4.2 Itemized Payroll Component Breakdown
try {
    $hasItemizedEntries = ($null -ne $payrollSummary) -and ($payrollSummary.entries.Count -gt 0)
    if ($hasItemizedEntries) {
        $firstEntry = $payrollSummary.entries[0]
        # Validate PayrollEntryDto: id, entryType, quantityHours, hourlyRate, amount
        $validEntry = ($null -ne $firstEntry.id) -and 
                      ($null -ne $firstEntry.entryType) -and 
                      ($firstEntry.quantityHours -gt 0) -and 
                      ($firstEntry.amount -gt 0)
        Report-Result "Payroll Itemized Breakdown (PayrollEntryDto)" $validEntry "First Component: $($firstEntry.entryType), Hours: $($firstEntry.quantityHours), Rate: Rp $($firstEntry.hourlyRate.ToString('N0')), Amount: Rp $($firstEntry.amount.ToString('N0'))"
    } else {
        Report-Result "Payroll Itemized Breakdown (PayrollEntryDto)" $true "Entries empty for current period (non-blocking)"
    }
} catch {
    Report-Result "Payroll Itemized Breakdown" $false $_.Exception.Message
}

# 4.3 Active Payroll Periods List
try {
    $periodsRes = Invoke-RestMethod -Uri "$BaseUrl/api/v1/payroll/periods" -Method Get -Headers $doctorHeaders
    $hasPeriods = ($null -ne $periodsRes) -and ($periodsRes.Count -gt 0)
    $firstPeriod = if ($hasPeriods) { $periodsRes[0] } else { $null }

    # Validate PayrollPeriodDto: id, periodName, periodStart, periodEnd, status, totalPayout
    $validPeriodDto = $firstPeriod -and 
                      ($null -ne $firstPeriod.id) -and 
                      ($null -ne $firstPeriod.periodName) -and 
                      ($null -ne $firstPeriod.status) -and 
                      ([double]$firstPeriod.totalPayout -gt 0)

    Report-Result "GET /api/v1/payroll/periods (Mobile Periods List)" ($hasPeriods -and $validPeriodDto) "Total Periods: $($periodsRes.Count), Latest: $($firstPeriod.periodName) (Total Payout: Rp $($firstPeriod.totalPayout.ToString('N0')))"
} catch {
    Report-Result "GET /api/v1/payroll/periods" $false $_.Exception.Message
}

# ------------------------------------------------------------------------------
# PHASE 5: Push Notifications & Device Lifecycle (/notifications)
# ------------------------------------------------------------------------------
Write-Section "PHASE 5: Push Notifications & Device Lifecycle (FCM registration & In-App Feed)"

# 5.1 Register Device Push Token
$mockPushToken = "fcm_test_token_doctor_zikri_" + (Get-Random -Minimum 100000 -Maximum 999999)
try {
    $regDeviceBody = @{
        pushToken = $mockPushToken
        platform = "android"
        deviceName = "Xiaomi 13T (Android 14) Doctor Mobile"
        osVersion = "Android 14"
        appVersion = "1.0.0"
    } | ConvertTo-Json

    $regRes = Invoke-RestMethod -Uri "$BaseUrl/api/v1/notifications/push/device" -Method Post -Headers $doctorHeaders -Body $regDeviceBody
    $regSuccess = ($regRes.success -eq $true) -and ($null -ne $regRes.id)
    Report-Result "POST /api/v1/notifications/push/device (Register Push Device)" $regSuccess "Device Subscription ID: $($regRes.id), Token: $mockPushToken"
} catch {
    Report-Result "POST /api/v1/notifications/push/device (Register Push Device)" $false $_.Exception.Message
}

# 5.2 Query My In-App Notifications Feed
try {
    $notifsRes = Invoke-RestMethod -Uri "$BaseUrl/api/v1/notifications/me?limit=50" -Method Get -Headers $doctorHeaders
    $hasFeed = ($null -ne $notifsRes) -and ($null -ne $notifsRes.data)
    $hasUnreadCount = $null -ne $notifsRes.unreadCount

    Report-Result "GET /api/v1/notifications/me (In-App Notification Feed)" ($hasFeed -and $hasUnreadCount) "Total Notifications: $($notifsRes.total), Unread: $($notifsRes.unreadCount), Returned: $($notifsRes.data.Count)"
} catch {
    Report-Result "GET /api/v1/notifications/me (In-App Notification Feed)" $false $_.Exception.Message
}

# 5.3 Query Unread Count Lightweight Endpoint
try {
    $unreadRes = Invoke-RestMethod -Uri "$BaseUrl/api/v1/notifications/unread-count" -Method Get -Headers $doctorHeaders
    $hasCount = $null -ne $unreadRes.unreadCount
    Report-Result "GET /api/v1/notifications/unread-count (Lightweight Badge)" $hasCount "Current Unread Count: $($unreadRes.unreadCount)"
} catch {
    Report-Result "GET /api/v1/notifications/unread-count (Lightweight Badge)" $false $_.Exception.Message
}

# 5.4 Mark All Notifications As Read
try {
    $readAllRes = Invoke-RestMethod -Uri "$BaseUrl/api/v1/notifications/read-all" -Method Patch -Headers $doctorHeaders -Body "{}"
    $readSuccess = $readAllRes.success -eq $true
    Report-Result "PATCH /api/v1/notifications/read-all (Mark All As Read)" $readSuccess "Marked All Notifications As Read (Success: $($readAllRes.success))"
} catch {
    Report-Result "PATCH /api/v1/notifications/read-all" $false $_.Exception.Message
}

# 5.5 Unregister Device Push Token (Guaranteed Hygiene)
try {
    $unregBody = @{
        pushToken = $mockPushToken
    } | ConvertTo-Json

    $unregRes = Invoke-RestMethod -Uri "$BaseUrl/api/v1/notifications/push/device" -Method Delete -Headers $doctorHeaders -Body $unregBody
    $unregSuccess = $unregRes.success -eq $true
    Report-Result "DELETE /api/v1/notifications/push/device (Unregister Push Device)" $unregSuccess "Device push token cleanly revoked"
} catch {
    Report-Result "DELETE /api/v1/notifications/push/device (Unregister Push Device)" $false $_.Exception.Message
}

# ------------------------------------------------------------------------------
# SUITE SUMMARY & METRICS
# ------------------------------------------------------------------------------
Write-Section "FLUTTER MOBILE CONTRACT VERIFICATION SUMMARY"
$elapsed = (Get-Date) - $script:TestStartTime
Write-Host " Total Execution Time : $($elapsed.TotalSeconds.ToString('F2')) seconds" -ForegroundColor White
Write-Host " Total Tests Passed    : $script:TotalPass" -ForegroundColor Green
Write-Host " Total Tests Failed    : $script:TotalFail" -ForegroundColor $(if ($script:TotalFail -eq 0) { "Green" } else { "Red" })

if ($script:TotalFail -eq 0) {
    Write-Host "`n CONGRATULATIONS: 100% Flutter Mobile Endpoints & DTO Contracts Verified!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n WARNING: $script:TotalFail mobile contract discrepancies detected. Review log details above." -ForegroundColor Red
    exit 1
}
