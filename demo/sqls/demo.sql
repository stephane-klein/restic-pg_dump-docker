SET client_min_messages = error;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;

DROP TABLE IF EXISTS public.contacts CASCADE;

CREATE TABLE public.contacts (
    id             UUID PRIMARY KEY DEFAULT uuid_generate_v4() NOT NULL,
    email          VARCHAR(255) NOT NULL,
    firstname      VARCHAR(255),
    lastname       VARCHAR(255),
    created_at     TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX contacts_email_index ON public.contacts (email);

SET client_min_messages = INFO;

TRUNCATE public.contacts CASCADE;

INSERT INTO public.contacts
    (
        id,
        email,
        firstname,
        lastname
    )
    SELECT
        ('1de9c987-08ab-32fe-e218-89c124cd' || to_char(seqnum, 'FM0000'))::uuid,
        'firstname' || to_char(seqnum, 'FM0000') || '@example.com',
        'firstname' || to_char(seqnum, 'FM0000'),
        'lastname' || to_char(seqnum, 'FM0000')
    FROM 
        GENERATE_SERIES(1, 50) seqnum;