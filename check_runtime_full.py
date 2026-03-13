import os
import sys
import subprocess
import time
import requests

ROOT = os.path.dirname(os.path.abspath(__file__))
API_BASE = os.environ.get("COMUNIAPP_API_BASE", "http://localhost:8000/api")


def run(cmd, cwd=None):
    return subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, shell=False)


def log_step(msg):
    print(f"\n[CHECK] {msg}")


def ok(msg):
    print(f"  OK   {msg}")


def fail(msg):
    print(f"  FAIL {msg}")


def ensure_docker_engine():
    log_step("Verificando Docker Engine")
    r = run(["docker", "version"])
    if r.returncode != 0:
        fail("Docker Engine no disponible. Abre Docker Desktop y vuelve a ejecutar.")
        return False
    ok("Docker Engine activo")
    return True


def ensure_db_up():
    log_step("Levantando PostgreSQL + pgAdmin")
    r = run(["docker", "compose", "up", "-d", "postgres", "pgadmin"], cwd=ROOT)
    if r.returncode != 0:
        fail("No se pudo ejecutar docker compose up -d postgres pgadmin")
        return False
    ok("Contenedores postgres/pgadmin levantados")

    log_step("Esperando PostgreSQL")
    for _ in range(30):
        rr = run(["docker", "exec", "tfg_postgres", "pg_isready", "-U", "tfg_user", "-d", "tfg_db"])
        if rr.returncode == 0:
            ok("PostgreSQL listo")
            return True
        time.sleep(2)

    fail("PostgreSQL no respondió a tiempo")
    return False


def ensure_backend_alive():
    log_step("Verificando backend /health")
    try:
        r = requests.get("http://localhost:8000/health", timeout=10)
        if r.status_code == 200 and r.json().get("status") == "healthy":
            ok("Backend saludable")
            return True
    except Exception:
        pass
    fail("Backend no responde bien en /health")
    return False


def check_openapi_version():
    log_step("Verificando OpenAPI actualizada")
    try:
        r = requests.get("http://localhost:8000/openapi.json", timeout=15)
        if r.status_code == 200 and "max_rows" in r.text:
            ok("OpenAPI incluye max_rows")
            return True
    except Exception:
        pass
    fail("OpenAPI no incluye max_rows (posible backend antiguo en 8000)")
    return False


def smoke_api():
    log_step("Smoke tests runtime (API)")
    try:
        login = requests.post(
            f"{API_BASE}/auth/login",
            json={"email": "admin1@tfg.com", "password": "Test1234"},
            timeout=15,
        )
        login.raise_for_status()
        token = login.json().get("access_token")
        if not token:
            fail("login sin access_token")
            return False

        headers = {"Authorization": f"Bearer {token}"}
        orgs = requests.get(f"{API_BASE}/organizations/my", headers=headers, timeout=15)
        orgs.raise_for_status()
        org_list = orgs.json()
        if not org_list:
            fail("organizations/my vacío")
            return False

        headers["X-Organization-ID"] = org_list[0]["organization_id"]

        checks = []

        def add(name, cond, detail):
            checks.append((name, cond, detail))

        r1 = requests.get(f"{API_BASE}/admin/export/zones?format=csv&max_rows=3", headers=headers, timeout=20)
        add("export zones csv", r1.status_code == 200 and "text/csv" in r1.headers.get("content-type", ""), f"status={r1.status_code}")

        r2 = requests.get(f"{API_BASE}/admin/export/users?format=json&max_rows=2", headers=headers, timeout=20)
        b2 = r2.json() if "application/json" in r2.headers.get("content-type", "") else []
        add("export users json + max_rows", r2.status_code == 200 and isinstance(b2, list) and len(b2) <= 2, f"status={r2.status_code}, len={len(b2) if isinstance(b2, list) else 'n/a'}")

        r3 = requests.get(f"{API_BASE}/admin/export/users?format=xlsx", headers=headers, timeout=20)
        add("export invalid format", r3.status_code == 400, f"status={r3.status_code}")

        csv_data = "email;nombre;rol;password\ncorreo-invalido;Usuario Malo;NEIGHBOR;Test1234\nqa_import_ok@tfg.com;Usuario QA;NEIGHBOR;weak\n"
        files = {"file": ("import_users_runtime_check.csv", csv_data.encode("utf-8"), "text/csv")}
        r4 = requests.post(f"{API_BASE}/admin/import/users", headers=headers, files=files, timeout=30)
        b4 = r4.json() if "application/json" in r4.headers.get("content-type", "") else {}
        add(
            "import users robust errors",
            r4.status_code == 200 and b4.get("total_rows") == 2 and isinstance(b4.get("errors"), list) and len(b4.get("errors", [])) >= 1,
            f"status={r4.status_code}, imported={b4.get('imported')}, errors={len(b4.get('errors', []))}",
        )

        r5 = requests.get(f"{API_BASE}/notifications?limit=5", headers=headers, timeout=20)
        b5 = r5.json() if "application/json" in r5.headers.get("content-type", "") else {}
        add("notifications list", r5.status_code == 200 and isinstance(b5.get("notifications", []), list), f"status={r5.status_code}")

        failed = False
        for name, cond, detail in checks:
            if cond:
                ok(f"{name} | {detail}")
            else:
                fail(f"{name} | {detail}")
                failed = True

        return not failed

    except Exception as exc:
        fail(f"smoke tests: {exc}")
        return False


def main():
    all_ok = True

    if not ensure_docker_engine():
        return 1
    if not ensure_db_up():
        return 1
    if not ensure_backend_alive():
        return 1

    if not check_openapi_version():
        all_ok = False
    if not smoke_api():
        all_ok = False

    if all_ok:
        print("\n============================================")
        print("  VERIFICACIÓN RUNTIME COMPLETA: OK")
        print("============================================")
        return 0

    print("\n============================================")
    print("  VERIFICACIÓN RUNTIME: CON FALLOS")
    print("============================================")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
