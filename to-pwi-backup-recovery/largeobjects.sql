create schema largeretail;

CREATE TABLE largeretail.toast_example (
    id SERIAL PRIMARY KEY,
    large_text TEXT
);

DO $$ 
DECLARE
    v_large_text TEXT;
BEGIN
    -- Generate a string of 5 MB of text (5 * 1024 * 1024 bytes)
    v_large_text := repeat('A', 5 * 1024 * 1024);  -- 5 MB string
    -- Insert it into the table
    INSERT INTO largeretail.toast_example (large_text) VALUES (v_large_text);
END $$;

CREATE TABLE largeretail.images (
    id SERIAL PRIMARY KEY,
    data BYTEA
);

\lo_import 'elephant.png';
INSERT INTO largeretail.images (data) SELECT lo_get(oid) FROM pg_largeobject_metadata;
