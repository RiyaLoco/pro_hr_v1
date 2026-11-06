# Attendance endpoint and QR matching

The Flutter app now sends:

```http
POST /api/v1/employee/attendance/{attendance_type_id}/{latitude,longitude}
Authorization: Bearer <token>
Content-Type: application/json

{"qr_code":"<scanned office QR contents>"}
```

The coordinates are the phone's fresh GPS position. The comma is URL encoded.
Laravel selects check-in or check-out using the attendance type's name, then its
`short_name`. Configure one type for `Check In`/`IN` and one for `Check Out`/`OUT`.
Neutral types such as `bcbv`/`vg` cannot select a direction with this controller.

Ensure this **POST** route exists in the authenticated employee API group,
using the group's existing prefix:

```php
Route::post('attendance/{attendance_type_id}/{check_location}', [EmployeeAttendanceController::class, 'check']);
```

The app saves the accepted check-in QR on this device, keyed by API server,
employee ID, and attendance record ID. Scan-out requires that exact QR and a
fresh server location check. A failed location check never saves the QR.
Pending attendance counts as accepted, as in the supplied controller.

## Employee work policy and location failures

The API checks the employee's `policy.radius_allowance` in meters against the
nearest branch among the primary branch and `allow_branch`. Being far from the
primary branch is allowed when another permitted branch is within the radius.
The app reads the nearest distance from `accuracy_meter` or `Matched Branch`,
and the allowance from `policyRadius` or the saved `compared_values`. It never
uses a fixed radius for attendance acceptance.

The supplied Laravel controller defines these outcomes for both directions:

| Location | Employee time allowance | Outcome |
| --- | --- | --- |
| Outside all permitted branch radii | Any | Failed, HTTP 422 |
| Inside a permitted radius | Within the check-in/out time allowance | Success |
| Inside a permitted radius | Late check-in or early check-out beyond the allowance | Pending approval |
| Missing radius policy or expected work schedule | Any | Configuration error, HTTP 422 |

For flexible schedules, Laravel uses today's dated schedule with the policy
start/end times as its fallback. Server time determines lateness and early
departure. A pending response is displayed as **Pending approval**. Time
allowances and a matching QR never override a failed radius check.

The app rejects contradictory success responses whose returned distance exceeds
the allowance, and does not accept a scan without location confirmation and an
accepted attendance status. Today’s card also checks each record's saved
location policy before using the `checked_in` / `checked_out` flags. Failed
attempts cannot complete attendance or hide the retry button.
Records explicitly changed to `Success(Via Approval)` still count in today's
attendance, as they do in Laravel; their original location snapshot describes
the earlier attempt. That approval never authorizes a new scan outside the
current radius.

The reported example (`5591.497` meters from the office with a `150` meter
allowance) is correctly rejected by Laravel: `success: false`,
`isCheckinRange: false`, and `data.status: Failed`. The returned `data` row is a
logged failed attempt, not a successful check-in. The app displays approximately
`5.59 km` against the allowed `150 m`, without changing attendance state. This
response is covered by a regression test for both HTTP 422 and HTTP 200.

If the actual API still stores `Success` for a distance greater than the saved
radius, the deployed Laravel code or its location calculation differs from the
supplied controller and must also be corrected. Check the response's
`compared_values` for `Work Policy`, `Matched Branch`, `Radius Allowance(M)`,
and `Location Summary`. The Flutter app cannot undo an accepted server record.

## Required Laravel change

The pasted controller's `check()` replaces all request input, discarding
`qr_code`. It also never validates or stores QR contents. Apply
[attendance-qr-backend.patch](attendance-qr-backend.patch) in the Laravel project;
it targets the exact controller you supplied:

```sh
git apply --check /path/to/pro_hr_app/docs/attendance-qr-backend.patch
git apply /path/to/pro_hr_app/docs/attendance-qr-backend.patch
```

The patch preserves and requires `qr_code`, stores its SHA-256 hash in the
existing `compared_values` JSON, and compares it with today's accepted check-in
inside the employee transaction before recording check-out. No migration is
needed. The existing branch radius and work schedule checks still run.

This must be deployed to enforce QR matching for requests outside this app.
Check-ins recorded before the patch have no QR hash and need administrator
handling for check-out. Without local QR data, the app directs users to the
device they checked in with or their administrator.

Verify on a real device: scan in and out with the same QR inside the allowed
radius; try another QR for scan-out; try both directions outside the radius;
and restart the app between scans. Automated Flutter tests use simulated API
responses and storage; they do not verify live GPS, camera, or Laravel setup.
