import os
import sys
import requests

BASE = os.environ.get("COMUNIAPP_API_BASE", "http://localhost:8000/api")


def main() -> int:
    r = requests.post(
        f"{BASE}/auth/login",
        json={"email": "admin1@tfg.com", "password": "Test1234"},
        timeout=15,
    )
    r.raise_for_status()
    token = r.json().get("access_token")
    if not token:
        print("FAIL login: sin access_token")
        return 1

    headers = {"Authorization": f"Bearer {token}"}
    orgs = requests.get(f"{BASE}/organizations/my", headers=headers, timeout=15)
    orgs.raise_for_status()
    org_list = orgs.json()
    if not org_list:
        print("FAIL organizations/my: vacío")
        return 1

    headers["X-Organization-ID"] = org_list[0]["organization_id"]

    checks = []

    def add(name: str, ok: bool, detail: str = ""):
        checks.append((name, ok, detail))

    r1 = requests.get(f"{BASE}/admin/export/zones?format=csv&max_rows=3", headers=headers, timeout=20)
    add("export zones csv", r1.status_code == 200 and "text/csv" in r1.headers.get("content-type", ""), f"status={r1.status_code}")

    r2 = requests.get(f"{BASE}/admin/export/users?format=json&max_rows=2", headers=headers, timeout=20)
    body2 = r2.json() if "application/json" in r2.headers.get("content-type", "") else []
    add("export users json + max_rows", r2.status_code == 200 and isinstance(body2, list) and len(body2) <= 2, f"status={r2.status_code}, len={len(body2) if isinstance(body2, list) else 'n/a'}")

    r3 = requests.get(f"{BASE}/admin/export/users?format=xlsx", headers=headers, timeout=20)
    add("export invalid format", r3.status_code == 400, f"status={r3.status_code}")

    csv_data = "email;nombre;rol;password\ncorreo-invalido;Usuario Malo;NEIGHBOR;Test1234\nqa_import_ok@tfg.com;Usuario QA;NEIGHBOR;weak\n"
    files = {"file": ("import_users_runtime_check.csv", csv_data.encode("utf-8"), "text/csv")}
    r4 = requests.post(f"{BASE}/admin/import/users", headers=headers, files=files, timeout=30)
    body4 = r4.json() if "application/json" in r4.headers.get("content-type", "") else {}
    add(
        "import users robust errors",
        r4.status_code == 200 and body4.get("total_rows") == 2 and isinstance(body4.get("errors"), list) and len(body4.get("errors", [])) >= 1,
        f"status={r4.status_code}, imported={body4.get('imported')}, errors={len(body4.get('errors', []))}",
    )

    r5 = requests.get(f"{BASE}/notifications?limit=5", headers=headers, timeout=20)
    body5 = r5.json() if "application/json" in r5.headers.get("content-type", "") else {}
    add("notifications list", r5.status_code == 200 and isinstance(body5.get("notifications", []), list), f"status={r5.status_code}")

    failed = False
    for name, ok, detail in checks:
        print(("OK  " if ok else "FAIL") + name + (f" | {detail}" if detail else ""))
        failed = failed or (not ok)

    return 1 if failed else 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"FAIL smoke tests: {exc}")
        raise SystemExit(1)
