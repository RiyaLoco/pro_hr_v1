# Attendance QR branch identity and GPS radius

## What caused the regressions

The same QR text at every branch contains no branch identity:

```text
api/v1/employee/attendance/{attendance_type_id}/{check_location}
```

It tells the app which action to execute, but cannot identify the office where
the QR was printed. The API previously chose the nearest permitted office.
Consequently, a QR printed at a distant office could be evaluated against a
different office a few kilometers away.

The Flutter changes also incorrectly restricted check-in to the primary office
and required optional coordinate metadata on historical records. Those
restrictions have been removed. Both check-in and check-out can use branches
in `employee.branch_id` and `employee.allow_branch`, subject to the GPS radius.

## Generate a different QR for each branch

Keep both runtime placeholders and add the branch's actual ID:

```text
api/v1/employee/attendance/{attendance_type_id}/{check_location}?branch_id=1
api/v1/employee/attendance/{attendance_type_id}/{check_location}?branch_id=2
```

Laravel generates this text using the current branch record:

```php
$qrText = \App\Support\AttendanceQr::forBranch(
    (int) $branch->id,
    rtrim((string) config('app.url'), '/').'/api/v1',
);
```

The running Laravel project was located at:

```text
/Applications/XAMPP/xamppfiles/htdocs/INFINITE-OS
```

Its branch details and printable QR views now generate branch-specific QR text
directly from their branch records. The details view also uses `$record`, the
variable its controller supplies, instead of the undefined `$previewInfo`.
Existing stored branch rows do not need a migration. Previously printed QR
codes must be reprinted from the updated branch page to include branch identity.

The unscoped legacy template remains supported for compatibility. It selects
the nearest permitted office and cannot establish which branch a printed copy
belongs to. It cannot enforce scanning branch B while standing at branch A.

## Request and server validation

Flutter fills `attendance_type_id` from the selected API attendance type and
`check_location` from a fresh phone GPS fix for every scan. Branch coordinates
never replace phone GPS. The existing authenticated POST route is unchanged:

```http
POST /api/v1/employee/attendance/1/11.54732899907136%2C104.9089653152003
Authorization: Bearer <token>
Content-Type: application/json

{"qr_code":"api/v1/employee/attendance/{attendance_type_id}/{check_location}?branch_id=1"}
```

Laravel parses `branch_id` from `qr_code`, checks employee branch permissions,
loads that branch's stored coordinates, and evaluates:

```text
distanceMeters(branch.latitude, branch.longitude, phone.latitude, phone.longitude)
    <= employee.policy.radius_allowance
```

Distances and policy radii are meters. Comparisons use unrounded Haversine
distance; display formatting alone converts meters to kilometers. A nearby
permitted branch cannot authorize a QR that identifies a different branch.
An outside-radius attempt can be saved as `Failed`, returns HTTP 422 and
`success: false`, and does not complete attendance. Work schedule allowances
still decide whether an in-range attempt is successful or pending approval.

The API still requires check-in before check-out and allows one accepted event
of each direction per day. Check-out may scan a different valid branch QR after
travelling to another permitted office. The obsolete same-QR-hash restriction
has been removed; event hashes remain available for audit.

## Flutter response handling

Both directions use `data.compared_values['Matched Branch']`, rather than
substituting `primaryLocation` or `WithPrimary`. For an identified branch QR,
the returned matched branch ID must equal the scanned branch ID. If the server
returns another branch, its distance is not displayed as the scanned branch's
distance.

When coordinates are available, Flutter recomputes distance against the exact
GPS submitted for the scan. Identified QR responses must include their matched
branch coordinates. Legacy unscoped responses can use the server's validated
distance and radius when optional coordinates are absent. Accepted historical
records are not rejected solely because optional coordinate metadata is missing.
Explicit administrator approvals retain their previous behavior.

Existing fixed-coordinate QR URLs remain supported. Their office coordinates
constrain the target office; the phone still sends its own fresh GPS. A fixed
QR's office cannot be silently replaced by a nearer primary office.

Debug builds emit `[Attendance GPS]` and `[Attendance location]` lines with the
actual GPS fix, accuracy, timestamp, scanned branch ID, matched branch ID,
branch coordinates, calculated distance, server distance and radius. These
diagnostics do not include authorization tokens or complete API responses.

## Changed backend files

The changes have been applied to the running Laravel project, with original
files backed up under `/private/tmp/attendance-backend-backup-*`:

- `app/Support/AttendanceQr.php`: branch-aware parser and QR text generator.
- `app/Helpers/Qr/AttendanceQr.php`: compatibility wrapper with the correct namespace.
- `app/Http/Controllers/API/Employee/EmployeeAttendanceController.php`: branch ID,
  permission and GPS validation; cross-branch check-out.
- `resources/views/coreHR/branch/show.blade.php`: generate the current branch QR.
- `resources/views/print/branchQr.blade.php`: print the identified branch QR.
- `tests/Feature/EmployeeAttendanceApiTest.php`: real Laravel HTTP regressions
  with SQLite and cache isolated in memory.
- `tests/attendance_check_in_policy_test.php`: compatibility command for those
  real Laravel tests, replacing obsolete framework substitutes.

Copies are in `docs/backend`. The original-controller patch is
`docs/attendance-qr-backend.patch`. The snapshot patch applied to the discovered
Laravel project is `docs/attendance-running-backend.patch`; do not apply it again
to the already updated project.

## Verification

From the Flutter repository:

```sh
flutter test --no-pub test/attendance_api_test.dart test/attendance_qr_payload_test.dart test/distant_helpers_test.dart test/app_url_service_test.dart test/attendance_responsive_test.dart
```

From the Laravel project:

```sh
php vendor/bin/phpunit --do-not-cache-result tests/Feature/EmployeeAttendanceApiTest.php
```

The HTTP regressions cover valid secondary-office check-in, a branch 200.15 km
away while the primary is 5 km away, a nearby third office that must not authorize
that distant QR, different branch QRs at IN and OUT, unpermitted offices,
authentication and radius precision. Tests use an isolated SQLite database and
do not create real attendance records. Actual camera/GPS scanning requires the
updated app and freshly generated branch QR. Incorrect old `Success` records
are preserved for administrator review and can still trigger duplicate guards.
