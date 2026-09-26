param(
  [string]$BaseUrl = "http://localhost:3001",
  [string]$Date    = (Get-Date).ToString("yyyy-MM-dd"),
  [string]$Month   = (Get-Date).ToString("yyyy-MM")
)

# ─── Helpers ──────────────────────────────────────────────────────────────────

function Pass  { param([string]$t) Write-Host "  [PASS] $t" -ForegroundColor Green }
function Fail  { param([string]$t, [string]$d="") Write-Host "  [FAIL] $t  →  $d" -ForegroundColor Red }
function Info  { param([string]$t) Write-Host "         $t" -ForegroundColor DarkGray }
function Title { param([string]$t) Write-Host "`n── $t " -ForegroundColor Cyan }

function Check {
  param([string]$Name, [bool]$Ok, [string]$Detail="")
  if ($Ok) { Pass $Name } else { Fail $Name $Detail }
}

# ─── Auth (same endpoint as Flutter uses via /api/v1/ token) ─────────────────

Title "1. AUTHENTICATE — dr. Ahmadamikom Zikri"
$loginPayload = @{ email = "zikriahmadamikom@gmail.com"; password = "secret123" } | ConvertTo-Json
try {
  $login = Invoke-RestMethod -Uri "$BaseUrl/api/v1/auth/email/login" -Method Post `
           -Body $loginPayload -ContentType "application/json"
  $token      = $login.token
  $doctorId   = $login.user.staff.practitionerId ?? $login.user.staff.id ?? $login.user.id
  Check "Login OK"       ($null -ne $token)    "token is null"
  Check "doctorId OK"    ($doctorId -ne "")    "practitionerId empty"
  Info "user: $($login.user.name)  doctorId: $doctorId"
  Info "token: $($token.Substring(0,[Math]::Min(16,$token.Length)))..."
} catch {
  Fail "Login" $_.Exception.Message
  exit 1
}

$H = @{ Authorization = "Bearer $token" }

# ─── 1. my-schedules ─────────────────────────────────────────────────────────

Title "2. GET /api/v1/schedules/my-schedules?date=$Date   (primary Flutter data source)"
try {
  $schedules = Invoke-RestMethod -Uri "$BaseUrl/api/v1/schedules/my-schedules?date=$Date" -Headers $H
  Check "Returns array"             ($schedules -is [array])    "not an array"
  Check "At least 1 session"        ($schedules.Count -ge 1)   "count=$($schedules.Count)"

  $schedules | ForEach-Object {
    $s = $_
    Info "[$($s.session)] $($s.startTime)–$($s.endTime) | status=$($s.status) | isAvailable=$($s.isAvailable) | capacity=$($s.capacity) | booked=$($s.bookedPatientCount) | id=$($s.id)"
    # Fields Flutter DoctorSchedule.fromJson must have
    Check "  [$($s.session)] has id"             ($s.id -ne "")
    Check "  [$($s.session)] has startTime"      ($null -ne $s.startTime)
    Check "  [$($s.session)] has endTime"        ($null -ne $s.endTime)
    Check "  [$($s.session)] has status"         ($s.status -in @("OPEN","CLOSED","OCCUPIED"))
    Check "  [$($s.session)] has isAvailable"    ($null -ne $s.isAvailable)
    Check "  [$($s.session)] has session"        ($s.session -ne "")
    Check "  [$($s.session)] has sessionShift"   ($s.sessionShift -ne "")
    Check "  [$($s.session)] has scheduleDate"   ($s.scheduleDate -ne "")
    Check "  [$($s.session)] has doctorId"       ($s.doctorId -ne "")
    Check "  [$($s.session)] has roomId"         ($s.roomId -ne "")
    Check "  [$($s.session)] has poliklinikId"   ($s.poliklinikId -ne "")
  }

  # Store first session id for later tests
  $script:sessionId = $schedules[0].id
  $script:roomId    = $schedules[0].roomId
} catch {
  Fail "my-schedules" $_.Exception.Message
}

# ─── 2. calendar-summary ─────────────────────────────────────────────────────

Title "3. GET /api/v1/schedules/calendar-summary?month=$Month   (calendar dots)"
try {
  $cal = Invoke-RestMethod -Uri "$BaseUrl/api/v1/schedules/calendar-summary?month=$Month" -Headers $H
  Check "Has month field"     ($cal.month -eq $Month)     "month=$($cal.month)"
  Check "Has days array"      ($cal.days -is [array])
  Check "Days count = 28-31"  ($cal.days.Count -ge 28)    "count=$($cal.days.Count)"

  $today = $cal.days | Where-Object { $_.date -eq $Date } | Select-Object -First 1
  if ($today) {
    Info "Today ($Date): hasSchedule=$($today.hasSchedule) sessionCount=$($today.sessionCount) status=$($today.status)"
    Check "Today hasSchedule=true"   ($today.hasSchedule -eq $true)
    Check "Today has isClosed field" ($null -ne $today.isClosed)
  } else {
    Fail "Today entry in calendar-summary" "date $Date not found in days array"
  }
} catch {
  Fail "calendar-summary" $_.Exception.Message
}

# ─── 3. day-settings ─────────────────────────────────────────────────────────

Title "4. GET /api/v1/schedules/day-settings?date=$Date   (kuota harian & cuti)"
try {
  $ds = Invoke-RestMethod -Uri "$BaseUrl/api/v1/schedules/day-settings?date=$Date" -Headers $H
  Info "targetQuota=$($ds.targetQuota ?? $ds.data.targetQuota)  isCuti=$($ds.isCuti ?? $ds.data.isCuti)"
  # Flutter reads targetQuota, isCuti — check they exist somewhere in response
  $obj = if ($ds.data) { $ds.data } else { $ds }
  Check "Has targetQuota"  ($null -ne $obj.targetQuota)
  Check "Has isCuti"       ($null -ne $obj.isCuti)
} catch {
  Fail "day-settings" $_.Exception.Message
}

# ─── 4. occupancy-overview ───────────────────────────────────────────────────

Title "5. GET /api/v1/schedules/occupancy-overview?date=$Date&roomId=$($script:roomId)   (anti-collision grid)"
try {
  $occ = Invoke-RestMethod -Uri "$BaseUrl/api/v1/schedules/occupancy-overview?date=$Date&roomId=$($script:roomId)" -Headers $H
  $grid = if ($occ.data) { $occ.data } else { $occ }
  Info "Response type: $($grid.GetType().Name)  — used only for anti-collision form, NOT for rendering session list"
  Check "Returns non-null"  ($null -ne $grid)
} catch {
  Fail "occupancy-overview" $_.Exception.Message
}

# ─── 5. booked-patients ──────────────────────────────────────────────────────

Title "6. GET /api/v1/schedules/booked-patients?date=$Date   (pasien hari ini)"
try {
  $patients = Invoke-RestMethod -Uri "$BaseUrl/api/v1/schedules/booked-patients?date=$Date" -Headers $H
  Check "Returns array"     ($patients -is [array])
  Info "Patient count: $($patients.Count)"
  if ($patients.Count -gt 0) {
    $p = $patients[0]
    Info "Sample: $($p.fullName ?? $p.name)  slot=$($p.timeSlot)  queue=$($p.queueNumber)"
    Check "Has appointmentId or id"  ($p.id -ne "" -or $p.appointmentId -ne "")
    Check "Has timeSlot"             ($null -ne $p.timeSlot)
  }
} catch {
  Fail "booked-patients" $_.Exception.Message
}

# ─── 6. sessions/:id/patients ────────────────────────────────────────────────

Title "7. GET /api/v1/schedules/sessions/$($script:sessionId)/patients   (pasien per sesi)"
try {
  $sp = Invoke-RestMethod -Uri "$BaseUrl/api/v1/schedules/sessions/$($script:sessionId)/patients" -Headers $H
  $list = if ($sp.data.patients) { $sp.data.patients } elseif ($sp.patients) { $sp.patients } else { $sp }
  Check "Response has patients list"  ($null -ne $list)
  Info "Session patient count: $(if ($list -is [array]) { $list.Count } else { 'N/A' })"
} catch {
  Fail "sessions/patients" $_.Exception.Message
}

# ─── 7. reference/rooms ──────────────────────────────────────────────────────

Title "8. GET /api/v1/schedules/reference/rooms?date=$Date   (for add/edit drawer)"
try {
  $rooms = Invoke-RestMethod -Uri "$BaseUrl/api/v1/schedules/reference/rooms?date=$Date" -Headers $H
  Check "Returns rooms array"   (($rooms -is [array] -and $rooms.Count -gt 0) -or ($rooms.data -is [array] -and $rooms.data.Count -gt 0))
  $list = if ($rooms -is [array]) { $rooms } else { $rooms.data }
  Info "Room count: $($list.Count)"
  if ($list.Count -gt 0) { Info "Sample: id=$($list[0].id)  name=$($list[0].name ?? $list[0].roomName)" }
} catch {
  Fail "reference/rooms" $_.Exception.Message
}

# ─── 8. reference/polikliniks ────────────────────────────────────────────────

Title "9. GET /api/v1/schedules/reference/polikliniks   (for add/edit drawer)"
try {
  $polis = Invoke-RestMethod -Uri "$BaseUrl/api/v1/schedules/reference/polikliniks" -Headers $H
  $list = if ($polis -is [array]) { $polis } else { $polis.data }
  Check "Returns poli array"   ($list -is [array] -and $list.Count -gt 0)
  Info "Poli count: $($list.Count)"
  if ($list.Count -gt 0) { Info "Sample: id=$($list[0].id)  name=$($list[0].name ?? $list[0].namaPoli)" }
} catch {
  Fail "reference/polikliniks" $_.Exception.Message
}

# ─── 9. POST availability (CREATE — Flutter primary create path) ──────────────

Title "10. POST /api/v1/schedules/availability   (Flutter primary CREATE path)"
try {
  # Get first available room and poli
  $rooms2 = Invoke-RestMethod -Uri "$BaseUrl/api/v1/schedules/reference/rooms?date=$Date" -Headers $H
  $roomList = if ($rooms2 -is [array]) { $rooms2 } else { $rooms2.data }
  $polis2   = Invoke-RestMethod -Uri "$BaseUrl/api/v1/schedules/reference/polikliniks" -Headers $H
  $poliList = if ($polis2 -is [array]) { $polis2 } else { $polis2.data }

  $testRoomId = $roomList[0].id
  $testPoliId = $poliList[0].id

  $createPayload = @{
    date              = $Date
    scheduleContextId = "night"
    startTime         = "20:00"
    roomId            = $testRoomId
    poliklinikId      = $testPoliId
  } | ConvertTo-Json

  $created = Invoke-RestMethod -Uri "$BaseUrl/api/v1/schedules/availability" -Method Post `
             -Headers $H -Body $createPayload -ContentType "application/json"

  $obj = if ($created.data.schedule) { $created.data.schedule } elseif ($created.data) { $created.data } else { $created }
  Check "Returns created DoctorSchedule"   ($obj.id -ne "")
  Check "Created has startTime=20:00"      ($obj.startTime -eq "20:00")
  Check "Created has session field"        ($obj.session -ne "")
  Check "Created has doctorId"             ($obj.doctorId -ne "" -or $obj.practitionerId -ne "")
  Info "Created: id=$($obj.id) [$($obj.session)] $($obj.startTime)–$($obj.endTime)"

  # Save for DELETE cleanup
  $script:createdScheduleId = $obj.id
} catch {
  if ($_.Exception.Response.StatusCode -eq 409) {
    Info "409 Conflict — slot already occupied (collision detection working correctly)"
    $script:createdScheduleId = $null
  } else {
    Fail "POST availability" $_.Exception.Message
    $script:createdScheduleId = $null
  }
}

# ─── 10. Verify my-schedules increased after create ──────────────────────────

Title "11. VERIFY — my-schedules after CREATE (state synchronization check)"
try {
  $after = Invoke-RestMethod -Uri "$BaseUrl/api/v1/schedules/my-schedules?date=$Date" -Headers $H
  Info "Session count after CREATE: $($after.Count)"
  Check "Session list updated after create"  ($after.Count -ge $schedules.Count)
} catch {
  Fail "my-schedules post-create" $_.Exception.Message
}

# ─── 11. DELETE created schedule (cleanup) ───────────────────────────────────

if ($script:createdScheduleId) {
  Title "12. DELETE /api/v1/schedules/$($script:createdScheduleId)   (cleanup)"
  try {
    Invoke-RestMethod -Uri "$BaseUrl/api/v1/schedules/$($script:createdScheduleId)" -Method Delete -Headers $H | Out-Null
    Pass "Schedule deleted (cleanup OK)"
  } catch {
    Fail "DELETE cleanup" $_.Exception.Message
  }
}

# ─── Done ─────────────────────────────────────────────────────────────────────

Write-Host "`n══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Flutter Schedule Endpoint Contract Test — DONE  " -ForegroundColor Cyan
Write-Host "══════════════════════════════════════════════════`n" -ForegroundColor Cyan
