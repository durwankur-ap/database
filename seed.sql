-- SEED DATA
-- Using hardcoded UUIDs for reproducibility and simpler referencing in a single script

-- 1. Insert a Lawyer (The Admin/User)
INSERT INTO lawyers (id, email, hashed_password, law_firm_name)
VALUES (
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', -- Known UUID
    'demo@lawfirm.com',
    'hashed_secret_password_placeholder', -- In a real app, use a proper bcrypt hash
    'Justice League Partners'
) ON CONFLICT (id) DO NOTHING;

-- 2. Insert a Client
INSERT INTO clients (id, lawyer_id, full_name, contact_info, address)
VALUES (
    'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', -- Known UUID
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', -- References Lawyer above
    'John Doe',
    '{"phone": "+1-555-0101", "email": "johndoe@example.com"}',
    '123 Main St, Springfield'
) ON CONFLICT (id) DO NOTHING;

-- 3. Insert a Case
INSERT INTO cases (id, client_id, lawyer_id, case_number, case_name, case_type, status)
VALUES (
    'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c33', -- Known UUID
    'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', -- References Client above
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', -- References Lawyer above
    'CASE-2024-001',
    'State vs John Doe',
    'Criminal Defense',
    'open'
) ON CONFLICT (id) DO NOTHING;

-- 4. Insert a Template
INSERT INTO templates (lawyer_id, case_type, content_structure)
VALUES (
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'Criminal Defense',
    '{"sections": ["Client Info", "Charge Details", "Evidence List", "Strategy Notes"]}'
);
