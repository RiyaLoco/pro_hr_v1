# Attendance endpoint and QR matching

## Scanned action validation

The office QR contains a resolved attendance URL, for example:

```text
http://192.168.1.11:8000/api/v1/employee/attendance/1/11.547273130564294, 104.90898218012883
```

The scanner and the API service now reject unrelated text, other servers,
other routes, invalid type IDs, and invalid coordinates before an attendance
request. A path beginning with the configured API prefix and an `action=`
parameter containing that URL are also supported. Resolve the placeholders
when generating the QR; literal `{attendance_type_id}` and `{check_location}`
are not valid scanned values.

The QR's coordinates identify the office location represented by the QR.
They must never be submitted as the employee's current GPS position. The app
continues to choose the check-in/out type from `/attendance/types` for the
selected action, so the same office QR can be used for both directions even
when its URL contains type `1`.

For example, scanning the URL above from phone GPS `11.5,104.9` with selected
type `3` submits `/api/v1/employee/attendance/3/11.5,104.9` and includes the
original scanned URL in `qr_code`. The app does not open the scanned URL as a
GET request or send credentials to a server supplied by the QR.

**Action validation alone is not office authorization.** The backend patch
below now binds the QR's coordinates to a branch in the employee's primary
branch or `allow_branch`, using the trusted `Branch.location` from the database.
Coordinates that do not match a permitted branch are rejected before creating
an attendance row. A tolerance of `0.000001` degrees compensates for decimal
rounding of branch coordinates; it does not define the phone's GPS allowance.

Phone GPS is then compared with that QR branch using the employee's policy
radius. For example, a phone at permitted branch B cannot use branch A's QR
when it is outside A's radius. A copy of the same static office URL represents
the same QR; authenticating an issuer or rotating codes would require a signed
or registered token format beyond the current URL.

The Laravel project is not available locally. The replacement source and patch
are prepared in this Flutter repository and must be installed in Laravel to
change live server behavior. Old check-ins made without a stored QR hash need
administrator handling rather than bypassing QR validation at check-out.

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

The patched API checks the employee's `policy.radius_allowance` in meters
against the permitted branch identified by the scanned QR. Being far from the
primary branch is allowed when the QR belongs to a permitted secondary branch
and the phone is inside that secondary branch's radius.
The app reads that branch's distance from `accuracy_meter` or `Matched Branch`,
and the allowance from `policyRadius` or the saved `compared_values`. It never
uses a fixed radius for attendance acceptance.

The supplied Laravel controller defines these outcomes for both directions:

| Location | Employee time allowance | Outcome |
| --- | --- | --- |
| Outside the scanned QR branch radius | Any | Failed, HTTP 422 |
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
`qr_code`. Its old branch loop also ignores the QR location. Apply
[attendance-qr-backend.patch](attendance-qr-backend.patch) in the Laravel project;
it targets the exact controller you supplied:

```sh
git apply --check /path/to/pro_hr_app/docs/attendance-qr-backend.patch
git apply /path/to/pro_hr_app/docs/attendance-qr-backend.patch
```

The patch updates the controller and adds `app/Support/AttendanceQr.php`.
Alternatively, copy these replacement files into the matching Laravel paths:

- [EmployeeAttendanceController.php](backend/app/Http/Controllers/API/Employee/EmployeeAttendanceController.php)
- [AttendanceQr.php](backend/app/Support/AttendanceQr.php)

Configure Laravel's `.env` so `APP_URL` is the same server origin used by the QR
and Flutter, including the port. For the supplied QR:

```dotenv
APP_URL=http://192.168.1.11:8000
```

Then rebuild Laravel configuration using `php artisan config:cache`. The
parser expects the `/api/v1` prefix from this application. The stored
`Branch.location` must match the office coordinates encoded in its QR. The
QR's attendance type must exist and identify an IN or OUT type; the requested
attendance type still determines the actual check-in/out action.

The patch preserves and requires `qr_code`, validates its origin, route, type,
and coordinates, binds it to a permitted branch, and saves its SHA-256 hash,
branch ID, and location in `compared_values`. Check-out compares the hash with
today's accepted check-in inside the employee transaction. A matching QR never
skips the fresh GPS radius check. No migration is needed. Existing work schedule,
late/early allowance, failed-attempt logging, and approval behavior still run.

This must be installed to enforce QR checks for requests outside this app.
Check-ins recorded before the patch have no QR hash and need administrator
handling for check-out. Without local QR data, the app directs users to the
device they checked in with or their administrator.

The prepared PHP controller regression harness can be run from this repository:

```sh
php docs/backend/tests/attendance_qr_test.php
```

It executes the replacement controller using in-memory substitutes for Laravel,
Carbon, the database, and the distance helper. Its 13 scenarios cover invalid QR
codes, unknown types, unauthorized offices, GPS at a different permitted branch,
allowed secondary offices, and check-out matching/radius checks. It does not
verify Laravel routing, authentication, actual model casts, locking, or the live
distance helper. Run the Laravel project's tests after installing the patch.

Verify on a real device: scan in and out with the same QR inside the allowed
radius; scan A's QR while standing at another permitted office B; try a QR with
unrelated coordinates; try another QR for scan-out; try both directions outside
the radius; and restart the app between scans. Automated Flutter tests use simulated API
responses and storage; they do not verify live GPS, camera, or Laravel setup.
