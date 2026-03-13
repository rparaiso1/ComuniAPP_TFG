#!/usr/bin/env python3
"""
Test COMPLETO de TODOS los endpoints con TODOS los roles y datos del seed.
=========================================================================
Usuarios de prueba (todos con password Test1234):
  - admin1@tfg.com      → ADMIN    (Org1=Jardines, Org2=Palmeras)
  - admin2@tfg.com      → ADMIN    (Org3=Mirador, Org4=PuertaSol)
  - presidente1@tfg.com → PRESIDENT (Org1=Jardines)
  - presidente2@tfg.com → PRESIDENT (Org2=Palmeras)
  - vecino1@tfg.com     → NEIGHBOR  (Org1=Jardines, propietario)
  - vecino4@tfg.com     → NEIGHBOR  (Org2=Palmeras, propietario)
  - inquilino1@tfg.com  → NEIGHBOR  (Org1=Jardines, inquilino)
  - inquilino3@tfg.com  → NEIGHBOR  (Org2=Palmeras, inquilino)

Ejecutar:  python test_all_roles.py
"""
import requests
import json
import sys
import os
import time
os.environ.setdefault("PYTHONIOENCODING", "utf-8")
from datetime import datetime, timedelta

BASE = "http://localhost:8000"
TS = int(datetime.now().timestamp())
PASSWORD = "Test1234"

# ── Counters ──
PASS = 0
FAIL = 0
RESULTS = []
SECTION_STATS = {}
current_section = ""


def section(name):
    global current_section
    print(f"\n{'-'*60}")
    print(f"  {name}")
    print(f"{'-'*60}")
    SECTION_STATS[name] = {"pass": 0, "fail": 0}
    current_section = name
    return name


def test(name, method, path, expected_status=None, headers=None, json_data=None, params=None, files=None):
    global PASS, FAIL, current_section
    url = f"{BASE}{path}"
    try:
        kwargs = {"headers": headers, "timeout": 15}
        if files:
            kwargs["files"] = files
        else:
            kwargs["json"] = json_data
        kwargs["params"] = params
        resp = getattr(requests, method.lower())(url, **kwargs)

        if expected_status:
            ok = resp.status_code == expected_status
        else:
            ok = resp.status_code in (200, 201, 204)

        icon = "PASS" if ok else "FAIL"
        if ok:
            PASS += 1
            if current_section in SECTION_STATS: SECTION_STATS[current_section]["pass"] += 1
        else:
            FAIL += 1
            if current_section in SECTION_STATS: SECTION_STATS[current_section]["fail"] += 1

        try:
            body = resp.json()
            preview = json.dumps(body, ensure_ascii=False)[:120]
        except Exception:
            preview = resp.text[:120] if resp.text else "(empty)"

        RESULTS.append((icon, resp.status_code, f"{method.upper()} {path}", preview, name))
        status_mark = "OK " if ok else "ERR"
        print(f"    {status_mark} [{resp.status_code}] {name}")
        if not ok:
            print(f"        Expected {expected_status or '2xx'}, got {resp.status_code}: {preview[:80]}")
        return resp
    except Exception as e:
        FAIL += 1
        if current_section in SECTION_STATS: SECTION_STATS[current_section]["fail"] += 1
        RESULTS.append(("FAIL", "ERR", f"{method.upper()} {path}", str(e)[:100], name))
        print(f"    ERR [---] {name}: {e}")
        return None


def auth_h(token):
    return {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}


def login(email, password=PASSWORD):
    r = requests.post(f"{BASE}/api/auth/login", json={"email": email, "password": password}, timeout=10)
    if r.status_code == 200:
        return r.json()
    print(f"    WARNING: Login failed for {email}: {r.status_code} {r.text[:80]}")
    return {}


# ══════════════════════════════════════════════════════════════
#                      MAIN EXECUTION
# ══════════════════════════════════════════════════════════════
def main():
    global PASS, FAIL

    print("=" * 60)
    print("  TEST COMPLETO — Todos los endpoints x Todos los roles")
    print("=" * 60)

    # ── 1. LOGINS ──
    section("1. Login de todos los usuarios")

    # Use a single login call per user (avoids rate limit: 10 auth reqs/60s)
    users_to_login = [
        ("admin1@tfg.com", "admin1"),
        ("admin2@tfg.com", "admin2"),
        ("presidente1@tfg.com", "presidente1"),
        ("presidente2@tfg.com", "presidente2"),
        ("vecino1@tfg.com", "vecino1 (propietario)"),
        ("vecino4@tfg.com", "vecino4 (propietario org2)"),
        ("inquilino1@tfg.com", "inquilino1 (tenant org1)"),
        ("inquilino3@tfg.com", "inquilino3 (tenant org2)"),
    ]

    tokens = {}
    for email, label in users_to_login:
        r = requests.post(f"{BASE}/api/auth/login", json={"email": email, "password": PASSWORD}, timeout=10)
        if r.status_code == 200:
            PASS += 1
            SECTION_STATS[current_section]["pass"] += 1
            data = r.json()
            tokens[email] = data
            print(f"    OK  [200] Login {label}")
            RESULTS.append(("PASS", 200, f"POST /api/auth/login", f"Login {label}", f"Login {label}"))
        else:
            FAIL += 1
            SECTION_STATS[current_section]["fail"] += 1
            tokens[email] = {}
            print(f"    ERR [{r.status_code}] Login {label}")
            print(f"        {r.text[:80]}")
            RESULTS.append(("FAIL", r.status_code, f"POST /api/auth/login", r.text[:80], f"Login {label}"))

    admin1 = tokens["admin1@tfg.com"]
    admin2 = tokens["admin2@tfg.com"]
    pres1 = tokens["presidente1@tfg.com"]
    pres2 = tokens["presidente2@tfg.com"]
    vec1 = tokens["vecino1@tfg.com"]
    vec4 = tokens["vecino4@tfg.com"]
    inq1 = tokens["inquilino1@tfg.com"]
    inq3 = tokens["inquilino3@tfg.com"]

    # Tokens
    a1h = auth_h(admin1.get("access_token", ""))
    a2h = auth_h(admin2.get("access_token", ""))
    p1h = auth_h(pres1.get("access_token", ""))
    p2h = auth_h(pres2.get("access_token", ""))
    v1h = auth_h(vec1.get("access_token", ""))
    v4h = auth_h(vec4.get("access_token", ""))
    i1h = auth_h(inq1.get("access_token", ""))
    i3h = auth_h(inq3.get("access_token", ""))

    # ── 2. AUTH — /me, refresh, update profile ──
    section("2. Auth: /me, profile, change-password")

    r = test("admin1 GET /me", "get", "/api/auth/me", 200, a1h)
    admin1_id = r.json()["id"] if r and r.status_code == 200 else None

    r = test("presidente1 GET /me", "get", "/api/auth/me", 200, p1h)
    pres1_id = r.json()["id"] if r and r.status_code == 200 else None

    r = test("vecino1 GET /me", "get", "/api/auth/me", 200, v1h)
    vec1_id = r.json()["id"] if r and r.status_code == 200 else None

    r = test("inquilino1 GET /me", "get", "/api/auth/me", 200, i1h)
    inq1_id = r.json()["id"] if r and r.status_code == 200 else None

    r = test("admin2 GET /me", "get", "/api/auth/me", 200, a2h)
    admin2_id = r.json()["id"] if r and r.status_code == 200 else None

    r = test("vecino4 GET /me", "get", "/api/auth/me", 200, v4h)
    vec4_id = r.json()["id"] if r and r.status_code == 200 else None

    test("vecino1 update profile", "put", "/api/auth/me", 200, v1h,
         json_data={"full_name": "Jose Lopez Navarro", "phone": "600330101"})

    test("inquilino1 update profile", "put", "/api/auth/me", 200, i1h,
         json_data={"full_name": "Pablo Rios Cano", "phone": "600440101"})

    # Refresh token (JSON body)
    if admin1.get("refresh_token"):
        test("admin1 refresh token", "post", "/api/auth/refresh", 200,
             json_data={"refresh_token": admin1["refresh_token"]})

    # Bad login — wait briefly to avoid hitting auth rate limit (10 req/60s)
    time.sleep(1)
    test("Login bad credentials", "post", "/api/auth/login", 401,
         json_data={"email": "noexiste@tfg.com", "password": "wrong"})

    # No auth
    test("GET /me sin token", "get", "/api/auth/me", 401)

    # ── 3. ORGANIZATIONS ──
    section("3. Organizations")

    # Admin-only: list all orgs
    r = test("admin1 list all orgs", "get", "/api/organizations/", 200, a1h)
    all_orgs = r.json() if r and r.status_code == 200 else []
    org1_id = org2_id = org3_id = org4_id = None
    for o in all_orgs:
        if o["code"] == "JARDINES": org1_id = o["id"]
        elif o["code"] == "PALMERAS": org2_id = o["id"]
        elif o["code"] == "MIRADOR": org3_id = o["id"]
        elif o["code"] == "PUERTASOL": org4_id = o["id"]

    test("admin2 list all orgs", "get", "/api/organizations/", 200, a2h)

    # President can't list all orgs (admin-only endpoint)
    test("presidente1 list all orgs -> 403", "get", "/api/organizations/", 403, p1h)
    test("vecino1 list all orgs -> 403", "get", "/api/organizations/", 403, v1h)
    test("inquilino1 list all orgs -> 403", "get", "/api/organizations/", 403, i1h)

    # My organizations
    r = test("admin1 GET /my orgs", "get", "/api/organizations/my", 200, a1h)
    if r and r.status_code == 200:
        admin1_orgs = [o["organization_code"] for o in r.json()]
        assert "JARDINES" in admin1_orgs and "PALMERAS" in admin1_orgs, f"admin1 should have JARDINES+PALMERAS"

    r = test("presidente1 GET /my orgs", "get", "/api/organizations/my", 200, p1h)
    if r and r.status_code == 200:
        p1_orgs = [o["organization_code"] for o in r.json()]
        assert "JARDINES" in p1_orgs, f"pres1 should have JARDINES"

    test("vecino1 GET /my orgs", "get", "/api/organizations/my", 200, v1h)
    test("inquilino1 GET /my orgs", "get", "/api/organizations/my", 200, i1h)

    # Get specific org
    if org1_id:
        test("admin1 GET org1 (su org)", "get", f"/api/organizations/{org1_id}", 200, a1h)
        test("presidente1 GET org1 (su org)", "get", f"/api/organizations/{org1_id}", 200, p1h)
        test("vecino1 GET org1 (su org)", "get", f"/api/organizations/{org1_id}", 200, v1h)

    if org3_id:
        test("admin2 GET org3 (su org)", "get", f"/api/organizations/{org3_id}", 200, a2h)

    # Create org (admin-only)
    new_org_data = {"name": f"Test Org {TS}", "code": f"TEST{TS}", "address": "Test St 1"}
    r = test("admin1 create org", "post", "/api/organizations/", 201, a1h, json_data=new_org_data)
    test_org_id = r.json()["id"] if r and r.status_code == 201 else None

    test("presidente1 create org -> 403", "post", "/api/organizations/", 403, p1h,
         json_data={"name": "Fail Org", "code": "FAIL1", "address": "N/A"})
    test("vecino1 create org -> 403", "post", "/api/organizations/", 403, v1h,
         json_data={"name": "Fail Org", "code": "FAIL2", "address": "N/A"})

    # Update org (admin-only)
    if org1_id:
        test("admin1 PATCH org1", "patch", f"/api/organizations/{org1_id}", 200, a1h,
             json_data={"address": "Avda. de la Constitucion 24, Sevilla"})

    # Delete test org
    if test_org_id:
        test("admin1 DELETE test org", "delete", f"/api/organizations/{test_org_id}", 204, a1h)

    # ── 4. ZONES ──
    section("4. Zones (zonas comunes)")

    # All users can list zones in their org
    r = test("admin1 list zones", "get", "/api/zones/", 200, a1h)
    zones = r.json() if r and r.status_code == 200 else []
    zone_pool_org1 = zone_padel_org1 = zone_bbq_org1 = None
    for z in zones:
        if z.get("zone_type") == "pool" and z.get("organization_id") == org1_id:
            zone_pool_org1 = z["id"]
        elif z.get("zone_type") == "court" and z.get("organization_id") == org1_id:
            zone_padel_org1 = z["id"]
        elif z.get("zone_type") == "bbq" and z.get("organization_id") == org1_id:
            zone_bbq_org1 = z["id"]

    test("presidente1 list zones", "get", "/api/zones/", 200, p1h)
    test("vecino1 list zones", "get", "/api/zones/", 200, v1h)
    test("inquilino1 list zones", "get", "/api/zones/", 200, i1h)

    # Get specific zone
    if zone_pool_org1:
        test("vecino1 GET pool zone", "get", f"/api/zones/{zone_pool_org1}", 200, v1h)

    # Create zone (admin/president only)
    new_zone = {"name": f"Test Zone {TS}", "zone_type": "room", "description": "Sala test",
                "max_capacity": 20, "max_booking_hours": 3}
    r = test("presidente1 create zone", "post", "/api/zones/", 201, p1h, json_data=new_zone)
    test_zone_id = r.json()["id"] if r and r.status_code == 201 else None

    test("vecino1 create zone -> 403", "post", "/api/zones/", 403, v1h, json_data=new_zone)
    test("inquilino1 create zone -> 403", "post", "/api/zones/", 403, i1h, json_data=new_zone)

    # Update zone
    if test_zone_id:
        test("presidente1 update zone", "put", f"/api/zones/{test_zone_id}", 200, p1h,
             json_data={"name": f"Updated Zone {TS}"})

    # Delete zone
    if test_zone_id:
        test("admin1 delete zone", "delete", f"/api/zones/{test_zone_id}", 204, a1h)

    # ── 5. POSTS (tablon) ──
    section("5. Posts (Tablon de anuncios)")

    # List posts (any authenticated user)
    r = test("admin1 list posts", "get", "/api/posts/", 200, a1h)
    posts = r.json() if r and r.status_code == 200 else []
    post_org1_id = None
    for p in posts:
        if p.get("organization_id") == org1_id:
            post_org1_id = p["id"]
            break

    test("presidente1 list posts", "get", "/api/posts/", 200, p1h)
    test("vecino1 list posts", "get", "/api/posts/", 200, v1h)
    test("inquilino1 list posts", "get", "/api/posts/", 200, i1h)

    # Get specific post
    if post_org1_id:
        test("vecino1 GET post", "get", f"/api/posts/{post_org1_id}", 200, v1h)
        test("inquilino1 GET post", "get", f"/api/posts/{post_org1_id}", 200, i1h)

    # Create post — any user can create
    new_post = {"title": f"Test Post {TS}", "content": "Contenido de prueba"}
    r = test("vecino1 create post", "post", "/api/posts/", 201, v1h, json_data=new_post)
    vec1_post_id = r.json()["id"] if r and r.status_code == 201 else None

    r = test("inquilino1 create post", "post", "/api/posts/", 201, i1h,
             json_data={"title": f"Post Inquilino {TS}", "content": "Soy inquilino"})
    inq1_post_id = r.json()["id"] if r and r.status_code == 201 else None

    r = test("presidente1 create pinned post", "post", "/api/posts/", 201, p1h,
             json_data={"title": f"Aviso Importante {TS}", "content": "Aviso del presidente", "is_pinned": True})
    pres1_post_id = r.json()["id"] if r and r.status_code == 201 else None

    # Update own post
    if vec1_post_id:
        test("vecino1 update own post", "put", f"/api/posts/{vec1_post_id}", 200, v1h,
             json_data={"content": "Contenido actualizado"})

    # President can update any post in org
    if vec1_post_id:
        test("presidente1 update vecino's post", "put", f"/api/posts/{vec1_post_id}", 200, p1h,
             json_data={"content": "Editado por presidente"})

    # Neighbor can't update other's post
    if pres1_post_id:
        test("vecino1 update pres1 post -> 403", "put", f"/api/posts/{pres1_post_id}", 403, v1h,
             json_data={"content": "Intento de edicion"})

    # Delete own post
    if inq1_post_id:
        test("inquilino1 delete own post", "delete", f"/api/posts/{inq1_post_id}", 204, i1h)

    # Admin can delete any
    if pres1_post_id:
        test("admin1 delete pres1 post", "delete", f"/api/posts/{pres1_post_id}", 204, a1h)

    # Clean up
    if vec1_post_id:
        test("vecino1 delete own post", "delete", f"/api/posts/{vec1_post_id}", 204, v1h)

    # ── 6. INCIDENTS ──
    section("6. Incidents (Incidencias)")

    # List incidents
    r = test("admin1 list incidents", "get", "/api/incidents/", 200, a1h)
    incidents = r.json() if r and r.status_code == 200 else []
    inc_org1_id = None
    for inc in incidents:
        if inc.get("organization_id") == org1_id and inc.get("status") == "open":
            inc_org1_id = inc["id"]
            break

    test("presidente1 list incidents", "get", "/api/incidents/", 200, p1h)
    test("vecino1 list incidents", "get", "/api/incidents/", 200, v1h)
    test("inquilino1 list incidents", "get", "/api/incidents/", 200, i1h)

    # Filter by status
    test("vecino1 list open incidents", "get", "/api/incidents/", 200, v1h,
         params={"status_filter": "open"})
    test("vecino1 my incidents only", "get", "/api/incidents/", 200, v1h,
         params={"my_only": "true"})

    # Get specific incident
    if inc_org1_id:
        test("vecino1 GET incident", "get", f"/api/incidents/{inc_org1_id}", 200, v1h)

    # Create incident — any user can report
    new_inc = {"title": f"Test Incident {TS}", "description": "Tuberia rota en pasillo",
               "priority": "medium"}
    r = test("vecino1 create incident", "post", "/api/incidents/", 201, v1h, json_data=new_inc)
    vec1_inc_id = r.json()["id"] if r and r.status_code == 201 else None

    r = test("inquilino1 create incident", "post", "/api/incidents/", 201, i1h,
             json_data={"title": f"Inc Inquilino {TS}", "description": "Problema de ruido", "priority": "low"})
    inq1_inc_id = r.json()["id"] if r and r.status_code == 201 else None

    # Update own incident (text fields)
    if vec1_inc_id:
        test("vecino1 update own incident (text)", "put", f"/api/incidents/{vec1_inc_id}", 200, v1h,
             json_data={"description": "Tuberia rota en pasillo, urgente"})

    # Neighbor can't change status
    if vec1_inc_id:
        test("vecino1 change status -> 403", "put", f"/api/incidents/{vec1_inc_id}", 403, v1h,
             json_data={"status": "in_progress"})

    # President CAN change status
    if vec1_inc_id:
        test("presidente1 change status -> OK", "put", f"/api/incidents/{vec1_inc_id}", 200, p1h,
             json_data={"status": "in_progress"})

    # Admin CAN change status
    if vec1_inc_id:
        test("admin1 change status -> OK", "put", f"/api/incidents/{vec1_inc_id}", 200, a1h,
             json_data={"status": "resolved"})

    # Reopen incident so comments can be added (resolved incidents reject comments)
    if vec1_inc_id:
        test("admin1 reopen incident for comments", "put", f"/api/incidents/{vec1_inc_id}", 200, a1h,
             json_data={"status": "in_progress"})

    # Comments
    if vec1_inc_id:
        r = test("vecino1 add comment", "post", f"/api/incidents/{vec1_inc_id}/comments", 201, v1h,
                 json_data={"content": "Ya se ve peor"})

        test("presidente1 add comment", "post", f"/api/incidents/{vec1_inc_id}/comments", 201, p1h,
             json_data={"content": "Contactare al fontanero"})

        test("inquilino1 add comment", "post", f"/api/incidents/{vec1_inc_id}/comments", 201, i1h,
             json_data={"content": "Hay goteras en mi piso tambien"})

        test("vecino1 GET comments", "get", f"/api/incidents/{vec1_inc_id}/comments", 200, v1h)

    # Delete: owner can delete own incident
    if inq1_inc_id:
        test("inquilino1 delete own incident", "delete", f"/api/incidents/{inq1_inc_id}", 204, i1h)

    # Admin can delete any
    if vec1_inc_id:
        test("admin1 delete incident", "delete", f"/api/incidents/{vec1_inc_id}", 204, a1h)

    # ── 7. BOOKINGS ──
    section("7. Bookings (Reservas)")

    # List bookings
    r = test("admin1 list bookings", "get", "/api/bookings/", 200, a1h)
    bookings = r.json() if r and r.status_code == 200 else []

    test("presidente1 list bookings", "get", "/api/bookings/", 200, p1h)
    test("vecino1 list bookings", "get", "/api/bookings/", 200, v1h)
    test("inquilino1 list bookings", "get", "/api/bookings/", 200, i1h)

    # My bookings only
    test("vecino1 my bookings", "get", "/api/bookings/", 200, v1h, params={"my_only": "true"})

    # Create booking — any user on zone in their org
    tomorrow = (datetime.now() + timedelta(days=2)).strftime("%Y-%m-%d")
    vec1_booking_id = inq1_booking_id = pending_booking_id = None

    if zone_padel_org1:
        # Vecino books padel
        booking_data = {
            "zone_id": zone_padel_org1,
            "start_time": f"{tomorrow}T10:00:00",
            "end_time": f"{tomorrow}T12:00:00",
        }
        r = test("vecino1 create booking (padel)", "post", "/api/bookings/", 201, v1h,
                 json_data=booking_data)
        vec1_booking_id = r.json()["id"] if r and r.status_code == 201 else None

        # Inquilino books padel different time
        booking_data2 = {
            "zone_id": zone_padel_org1,
            "start_time": f"{tomorrow}T14:00:00",
            "end_time": f"{tomorrow}T16:00:00",
        }
        r = test("inquilino1 create booking (padel)", "post", "/api/bookings/", 201, i1h,
                 json_data=booking_data2)
        inq1_booking_id = r.json()["id"] if r and r.status_code == 201 else None

    if zone_bbq_org1:
        # BBQ requires approval -> should be "pending"
        day_after = (datetime.now() + timedelta(days=3)).strftime("%Y-%m-%d")
        bbq_data = {
            "zone_id": zone_bbq_org1,
            "start_time": f"{day_after}T12:00:00",
            "end_time": f"{day_after}T15:00:00",
        }
        r = test("vecino1 create booking (bbq, pending approval)", "post", "/api/bookings/", 201, v1h,
                 json_data=bbq_data)
        if r and r.status_code == 201:
            pending_booking_id = r.json()["id"]
            booking_status = r.json().get("status", "")
            if booking_status != "pending":
                print(f"    WARNING: BBQ booking should be pending, got {booking_status}")

    # Get specific booking
    if vec1_booking_id:
        test("vecino1 GET own booking", "get", f"/api/bookings/{vec1_booking_id}", 200, v1h)

    # Approve booking (admin/president only)
    if pending_booking_id:
        test("vecino1 approve booking -> 403", "post", f"/api/bookings/{pending_booking_id}/approve", 403, v1h)
        test("presidente1 approve booking", "post", f"/api/bookings/{pending_booking_id}/approve", 200, p1h)

    # Cancel booking
    if inq1_booking_id:
        test("inquilino1 cancel own booking", "post", f"/api/bookings/{inq1_booking_id}/cancel", 200, i1h,
             json_data={"reason": "Ya no puedo"})

    # President can cancel any booking in org
    if vec1_booking_id:
        test("presidente1 cancel vecino's booking", "post", f"/api/bookings/{vec1_booking_id}/cancel", 200, p1h,
             json_data={"reason": "Mantenimiento"})

    # Clean approved BBQ booking
    if pending_booking_id:
        test("admin1 cancel bbq booking", "post", f"/api/bookings/{pending_booking_id}/cancel", 200, a1h)

    # ── 8. DOCUMENTS ──
    section("8. Documents (Documentos)")

    # List docs — admin/pres see all, neighbors see only approved
    r = test("admin1 list docs", "get", "/api/documents/", 200, a1h)
    docs = r.json() if r and r.status_code == 200 else []
    approved_doc_id = pending_doc_id = None
    for d in docs:
        if d.get("approval_status") == "approved" and d.get("organization_id") == org1_id and not approved_doc_id:
            approved_doc_id = d["id"]
        if d.get("approval_status") == "pending_approval" and not pending_doc_id:
            pending_doc_id = d["id"]

    r_pres = test("presidente1 list docs (all statuses)", "get", "/api/documents/", 200, p1h)
    r_vec = test("vecino1 list docs (approved only)", "get", "/api/documents/", 200, v1h)
    test("inquilino1 list docs (approved only)", "get", "/api/documents/", 200, i1h)

    # Verify neighbor only sees approved
    if r_vec and r_vec.status_code == 200:
        vec_docs = r_vec.json()
        non_approved = [d for d in vec_docs if d.get("approval_status") != "approved"]
        if non_approved:
            print(f"    WARNING: vecino1 sees non-approved docs: {[d['approval_status'] for d in non_approved]}")

    # Get specific
    if approved_doc_id:
        test("vecino1 GET approved doc", "get", f"/api/documents/{approved_doc_id}", 200, v1h)

    # Create doc — admin/president only
    new_doc = {"title": f"Test Doc {TS}", "file_url": "/test/doc.pdf", "file_type": "pdf",
               "category": "documento", "description": "Doc de prueba"}
    r = test("presidente1 create doc", "post", "/api/documents/", 201, p1h, json_data=new_doc)
    test_doc_id = r.json()["id"] if r and r.status_code == 201 else None

    test("vecino1 create doc -> 403", "post", "/api/documents/", 403, v1h, json_data=new_doc)
    test("inquilino1 create doc -> 403", "post", "/api/documents/", 403, i1h, json_data=new_doc)

    # Approve doc
    if pending_doc_id:
        test("presidente2 approve doc (her org)", "post", f"/api/documents/{pending_doc_id}/approve", 200, p2h,
             json_data={"approved": True})

    # Delete doc
    if test_doc_id:
        test("presidente1 delete own doc", "delete", f"/api/documents/{test_doc_id}", 204, p1h)

    # ── 9. NOTIFICATIONS ──
    section("9. Notifications")

    # Each user sees their own
    r = test("vecino1 GET notifications", "get", "/api/notifications", 200, v1h)
    notifs = []
    notif_id = None
    if r and r.status_code == 200:
        notifs = r.json().get("notifications", [])
        notif_id = notifs[0]["id"] if notifs else None

    test("inquilino1 GET notifications", "get", "/api/notifications", 200, i1h)
    test("presidente1 GET notifications", "get", "/api/notifications", 200, p1h)
    test("admin1 GET notifications", "get", "/api/notifications", 200, a1h)

    # Mark as read
    if notif_id:
        test("vecino1 mark notification read", "post", f"/api/notifications/{notif_id}/read", 200, v1h)

    # Mark all read
    test("vecino1 mark all read", "post", "/api/notifications/read-all", 200, v1h)

    # Delete single
    if notifs and len(notifs) > 0:
        test("vecino1 delete notification", "delete", f"/api/notifications/{notifs[0]['id']}", 200, v1h)

    # Clear all
    test("inquilino1 clear all notifications", "delete", "/api/notifications", 200, i1h)

    # ── 10. INVITATIONS ──
    section("10. Invitations")

    # Create invitation (admin/president only)
    inv_data = {
        "email": f"invitado_{TS}@test.com",
        "full_name": "Invitado Test",
        "dwelling": "Bloque C - 1A",
        "role": "NEIGHBOR",
    }
    r = test("presidente1 create invitation", "post", "/api/invitations/", 201, p1h, json_data=inv_data)
    inv_token = r.json().get("token") if r and r.status_code == 201 else None
    inv_id = r.json().get("id") if r and r.status_code == 201 else None

    test("vecino1 create invitation -> 403", "post", "/api/invitations/", 403, v1h, json_data=inv_data)
    test("inquilino1 create invitation -> 403", "post", "/api/invitations/", 403, i1h, json_data=inv_data)

    # Verify invitation (public)
    if inv_token:
        test("verify invitation token", "get", f"/api/invitations/verify/{inv_token}", 200)

    # List invitations
    test("presidente1 list invitations", "get", "/api/invitations/", 200, p1h)
    test("admin1 list invitations", "get", "/api/invitations/", 200, a1h)

    # Register with invitation
    if inv_token:
        reg_data = {
            "token": inv_token,
            "email": f"invitado_{TS}@test.com",
            "password": "Test1234",
            "full_name": "Invitado Test",
            "phone": "600999999",
        }
        test("register with invitation", "post", "/api/invitations/register", 201, json_data=reg_data)

    # Delete invitation
    inv_data2 = {
        "email": f"invitado2_{TS}@test.com",
        "full_name": "Invitado Delete",
        "dwelling": "Bloque C - 2B",
        "role": "NEIGHBOR",
    }
    r2 = test("admin1 create invitation to delete", "post", "/api/invitations/", 201, a1h, json_data=inv_data2)
    inv2_id = r2.json().get("id") if r2 and r2.status_code == 201 else None
    if inv2_id:
        test("admin1 delete invitation", "delete", f"/api/invitations/{inv2_id}", 204, a1h)

    # ── 11. ADMIN PANEL ──
    section("11. Admin Panel")

    # Dashboard (admin/president)
    test("admin1 admin dashboard", "get", "/api/admin/dashboard", 200, a1h)
    test("admin2 admin dashboard", "get", "/api/admin/dashboard", 200, a2h)
    test("presidente1 admin dashboard", "get", "/api/admin/dashboard", 200, p1h)
    test("vecino1 admin dashboard -> 403", "get", "/api/admin/dashboard", 403, v1h)
    test("inquilino1 admin dashboard -> 403", "get", "/api/admin/dashboard", 403, i1h)

    # List users
    r = test("admin1 list users", "get", "/api/admin/users", 200, a1h)
    users_list = r.json() if r and r.status_code == 200 else []
    target_user_id = None
    for u in users_list:
        if isinstance(u, dict) and u.get("email") == "vecino3@tfg.com":
            target_user_id = u.get("id")
            break

    test("presidente1 list users", "get", "/api/admin/users", 200, p1h)
    test("vecino1 list users -> 403", "get", "/api/admin/users", 403, v1h)

    # Filter by role
    test("admin1 list NEIGHBOR users", "get", "/api/admin/users", 200, a1h,
         params={"role": "NEIGHBOR"})

    # Get specific user
    if target_user_id:
        test("admin1 get user detail", "get", f"/api/admin/users/{target_user_id}", 200, a1h)

    # Change role
    if target_user_id:
        test("admin1 change user role", "put", f"/api/admin/users/{target_user_id}/role", 200, a1h,
             json_data={"role": "PRESIDENT"})
        # Restore
        test("admin1 restore user role", "put", f"/api/admin/users/{target_user_id}/role", 200, a1h,
             json_data={"role": "NEIGHBOR"})

    # Toggle active
    if target_user_id:
        test("admin1 toggle user active", "put", f"/api/admin/users/{target_user_id}/toggle", 200, a1h)
        # Restore
        test("admin1 restore user active", "put", f"/api/admin/users/{target_user_id}/toggle", 200, a1h)

    # Reset password
    if target_user_id:
        test("admin1 reset user password", "put", f"/api/admin/users/{target_user_id}/reset-password", 200, a1h,
             json_data={"new_password": "Test1234"})

    # Can't modify self
    if admin1_id:
        test("admin1 can't change own role -> 400", "put", f"/api/admin/users/{admin1_id}/role", 400, a1h,
             json_data={"role": "NEIGHBOR"})
        test("admin1 can't toggle self -> 400", "put", f"/api/admin/users/{admin1_id}/toggle", 400, a1h)

    # ── 12. STATS ──
    section("12. Stats")

    test("admin1 dashboard stats", "get", "/api/stats/dashboard", 200, a1h)
    test("presidente1 dashboard stats", "get", "/api/stats/dashboard", 200, p1h)
    test("vecino1 dashboard stats", "get", "/api/stats/dashboard", 200, v1h)
    test("inquilino1 dashboard stats", "get", "/api/stats/dashboard", 200, i1h)

    test("admin1 bookings stats", "get", "/api/stats/bookings", 200, a1h)
    test("vecino1 bookings stats", "get", "/api/stats/bookings", 200, v1h)

    test("admin1 incidents stats", "get", "/api/stats/incidents", 200, a1h)
    test("vecino1 incidents stats", "get", "/api/stats/incidents", 200, v1h)

    # ── 13. CALENDAR ──
    section("13. Calendar")

    now = datetime.now()
    test("vecino1 calendar events", "get", "/api/calendar/events", 200, v1h,
         params={"start": now.strftime("%Y-%m-%d"), "end": (now + timedelta(days=30)).strftime("%Y-%m-%d")})
    test("vecino1 calendar today", "get", "/api/calendar/today", 200, v1h)
    test("vecino1 calendar upcoming", "get", "/api/calendar/upcoming", 200, v1h)
    test("vecino1 calendar month", "get", f"/api/calendar/month/{now.year}/{now.month}", 200, v1h)

    test("inquilino1 calendar events", "get", "/api/calendar/events", 200, i1h,
         params={"start": now.strftime("%Y-%m-%d"), "end": (now + timedelta(days=30)).strftime("%Y-%m-%d")})
    test("admin1 calendar today", "get", "/api/calendar/today", 200, a1h)

    # ── 14. CROSS-ORG ISOLATION ──
    section("14. Cross-Org Isolation (seguridad multi-tenant)")

    # vecino4 is in org2, should NOT see org1 data
    r = test("vecino4 list zones (only org2)", "get", "/api/zones/", 200, v4h)
    if r and r.status_code == 200:
        v4_zones = r.json()
        org1_zones_leaked = [z for z in v4_zones if z.get("organization_id") == org1_id]
        if org1_zones_leaked:
            print(f"    SECURITY WARNING: vecino4 sees org1 zones! {len(org1_zones_leaked)} leaked")

    r = test("vecino4 list posts (only org2)", "get", "/api/posts/", 200, v4h)
    if r and r.status_code == 200:
        v4_posts = r.json()
        org1_posts_leaked = [p for p in v4_posts if p.get("organization_id") == org1_id]
        if org1_posts_leaked:
            print(f"    SECURITY WARNING: vecino4 sees org1 posts! {len(org1_posts_leaked)} leaked")

    r = test("vecino4 list incidents (only org2)", "get", "/api/incidents/", 200, v4h)
    if r and r.status_code == 200:
        v4_incidents = r.json()
        org1_inc_leaked = [i for i in v4_incidents if i.get("organization_id") == org1_id]
        if org1_inc_leaked:
            print(f"    SECURITY WARNING: vecino4 sees org1 incidents! {len(org1_inc_leaked)} leaked")

    r = test("inquilino3 list bookings (only org2)", "get", "/api/bookings/", 200, i3h)
    if r and r.status_code == 200:
        i3_bookings = r.json()
        org1_book_leaked = [b for b in i3_bookings if b.get("organization_id") == org1_id]
        if org1_book_leaked:
            print(f"    SECURITY WARNING: inquilino3 sees org1 bookings! {len(org1_book_leaked)} leaked")

    # admin2 should only see org3+org4 data
    r = test("admin2 list zones (org3+org4 only)", "get", "/api/zones/", 200, a2h)
    if r and r.status_code == 200:
        a2_zones = r.json()
        wrong_orgs = [z for z in a2_zones if z.get("organization_id") not in (org3_id, org4_id)]
        if wrong_orgs:
            print(f"    SECURITY WARNING: admin2 sees wrong org zones! {len(wrong_orgs)} leaked")

    # ── 15. EDGE CASES ──
    section("15. Edge Cases")

    # Non-existent resource
    fake_uuid = "00000000-0000-0000-0000-000000000000"
    test("GET non-existent incident -> 404", "get", f"/api/incidents/{fake_uuid}", 404, v1h)
    test("GET non-existent post -> 404", "get", f"/api/posts/{fake_uuid}", 404, v1h)
    test("GET non-existent zone -> 404", "get", f"/api/zones/{fake_uuid}", 404, v1h)
    test("GET non-existent booking -> 404", "get", f"/api/bookings/{fake_uuid}", 404, v1h)
    test("GET non-existent doc -> 404", "get", f"/api/documents/{fake_uuid}", 404, v1h)

    # Invalid data
    test("Create post without title -> 422", "post", "/api/posts/", 422, v1h,
         json_data={"content": "no title"})
    test("Create incident without description -> 422", "post", "/api/incidents/", 422, v1h,
         json_data={"title": "no desc"})
    test("Register with short password -> 422", "post", "/api/auth/register", 422,
         json_data={"email": "short@test.com", "password": "ab", "full_name": "Short Pass"})

    # Logout
    test("vecino1 logout", "post", "/api/auth/logout", 200, v1h)

    # ══════════════════════════════════════════════════════════
    #                      SUMMARY
    # ══════════════════════════════════════════════════════════
    print("\n" + "=" * 60)
    print("  RESULTADOS POR SECCION")
    print("=" * 60)
    for s, stats in SECTION_STATS.items():
        total = stats["pass"] + stats["fail"]
        status_icon = "OK" if stats["fail"] == 0 else "FAIL"
        print(f"  {status_icon} {s}: {stats['pass']}/{total} pass")

    print("\n" + "=" * 60)
    total = PASS + FAIL
    if FAIL == 0:
        print(f"  ALL TESTS PASSED: {PASS}/{total}")
    else:
        print(f"  FAILURES: {FAIL}/{total}")
        print("\n  Failed tests:")
        for icon, code, path, preview, name in RESULTS:
            if icon == "FAIL":
                print(f"    [{code}] {name}: {path}")
                print(f"           {preview[:80]}")
    print("=" * 60)

    return FAIL


if __name__ == "__main__":
    sys.exit(main())
