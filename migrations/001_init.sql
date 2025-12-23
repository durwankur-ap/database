-- EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ENUMS
CREATE TYPE document_type AS ENUM ('audio', 'pdf', 'text');
CREATE TYPE case_status AS ENUM ('open', 'closed', 'pending', 'archived');

-- LAWYERS (Users)
CREATE TABLE lawyers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    hashed_password TEXT NOT NULL,
    law_firm_name TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- CLIENTS
CREATE TABLE clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lawyer_id UUID NOT NULL REFERENCES lawyers(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    contact_info JSONB,
    address TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- CASES
CREATE TABLE cases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_number VARCHAR(50) NOT NULL, -- Human readable ID (e.g. CASE-2024-001)
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    lawyer_id UUID NOT NULL REFERENCES lawyers(id) ON DELETE CASCADE,
    case_name TEXT NOT NULL,
    case_type TEXT NOT NULL,
    status case_status DEFAULT 'open',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    CONSTRAINT cases_case_number_key UNIQUE (case_number, lawyer_id) -- Case numbers unique per lawyer/firm usually, or globally? Making it unique per lawyer for safer multi-tenant feel, or just unique if single tenant intent. Let's go with Global based on previous files.
);

-- DOCUMENTS
CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id UUID NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
    s3_key TEXT NOT NULL,
    summary TEXT,
    doc_type document_type NOT NULL,
    uploaded_at TIMESTAMPTZ DEFAULT now()
);

-- TEMPLATES
CREATE TABLE templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lawyer_id UUID REFERENCES lawyers(id) ON DELETE SET NULL,
    case_type TEXT NOT NULL,
    content_structure JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- INDEXES (Performance Optimization)
CREATE INDEX idx_clients_lawyer_id ON clients(lawyer_id);
CREATE INDEX idx_cases_client_id ON cases(client_id);
CREATE INDEX idx_cases_lawyer_id ON cases(lawyer_id);
CREATE INDEX idx_cases_status ON cases(status);
CREATE INDEX idx_documents_case_id ON documents(case_id);
CREATE INDEX idx_templates_case_type ON templates(case_type);

-- TRIGGERS
-- Auto-update updated_at for cases
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_cases_updated_at
BEFORE UPDATE ON cases
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
