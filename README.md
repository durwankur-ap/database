# Database Guide for Backend Developers

## 🚀 Quick Start
To spin up the database and apply the correct schema:

1. **Start the Container**:
   ```bash
   docker-compose up -d --build
   ```
   *This starts Postgres on port `5433` (to avoid conflicts with default 5432).*

2. **Verify Initialization**:
   The container maps `./migrations` to `/docker-entrypoint-initdb.d`. Postgres automatically runs these `.sql` files in alphabetical order on the **first startup**.
   - `001_init.sql`: Creates tables (Lawyers, Clients, Cases, Documents).
   - `001_init_roles.sql`: Creates the `app_user` for your API.

3. **Seeding (Optional but Recommended)**:
   If you need dummy data, run:
   ```bash
   cat seed.sql | docker exec -i postgres-law psql -U law_admin -d law_db
   ```
   *(On Windows PowerShell: `Get-Content seed.sql | docker exec -i postgres-law psql -U law_admin -d law_db`)*

---

## 🔌 Connection Details

### Admin Access
- **User**: `law_admin`
- **Pass**: `law_admin_123`
- **DB**: `law_db`
- **URL**: `postgresql://law_admin:law_admin_123@localhost:5433/law_db`
- *Use this for running migrations or direct DB management.*

### Application Access (FastAPI)
- **User**: `app_user`
- **Pass**: `AppUser123!`
- **DB**: `law_db`
- **URL**: `postgresql://app_user:AppUser123!@localhost:5433/law_db`
- *Use this inside your FastAPI `.env` file.*

---

## 🛠 Schema Overview

The schema assumes a hierarchical data model:
1. **Lawyers**: Top-level entity (Auth). ID is `UUID`.
2. **Clients**: Belong to a Lawyer.
3. **Cases**: Belong to a Client AND a Lawyer.
   - Includes `case_number` (Human readable, e.g., 'CASE-2024-001').
   - Includes `status` (Enum: open, closed, pending, archived).
4. **Documents**: Belong to a Case.

### Key Features
- **UUIDs everywhere**: All primary keys are UUIDs.
- **Foreign Keys**: `ON DELETE CASCADE` is set for deep cleanup (Delete Lawyer -> Deletes Clients -> Deletes Cases).
- **Audit**: `created_at` and `updated_at` (auto-updating trigger) on Cases.

## ⚠️ Troubleshooting
**"Table does not exist" or "Relation not found"**
This usually means the container didn't initialize fresh.
1. `docker-compose down -v` (The `-v` is crucial to delete the old volume).
2. `docker-compose up -d`
