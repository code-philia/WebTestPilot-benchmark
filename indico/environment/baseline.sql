--
-- PostgreSQL database dump
--

\restrict gHxUjfVDfVpsMB1igawKIiDhcv5d0d2C0GtntIGHbqSP1etdz352f7dC2HTW828

-- Dumped from database version 15.18 (Debian 15.18-1.pgdg12+1)
-- Dumped by pg_dump version 15.18 (Debian 15.18-1.pgdg12+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: attachments; Type: SCHEMA; Schema: -; Owner: indico
--

CREATE SCHEMA attachments;


ALTER SCHEMA attachments OWNER TO indico;

--
-- Name: categories; Type: SCHEMA; Schema: -; Owner: indico
--

CREATE SCHEMA categories;


ALTER SCHEMA categories OWNER TO indico;

--
-- Name: event_abstracts; Type: SCHEMA; Schema: -; Owner: indico
--

CREATE SCHEMA event_abstracts;


ALTER SCHEMA event_abstracts OWNER TO indico;

--
-- Name: event_editing; Type: SCHEMA; Schema: -; Owner: indico
--

CREATE SCHEMA event_editing;


ALTER SCHEMA event_editing OWNER TO indico;

--
-- Name: event_paper_reviewing; Type: SCHEMA; Schema: -; Owner: indico
--

CREATE SCHEMA event_paper_reviewing;


ALTER SCHEMA event_paper_reviewing OWNER TO indico;

--
-- Name: event_registration; Type: SCHEMA; Schema: -; Owner: indico
--

CREATE SCHEMA event_registration;


ALTER SCHEMA event_registration OWNER TO indico;

--
-- Name: event_surveys; Type: SCHEMA; Schema: -; Owner: indico
--

CREATE SCHEMA event_surveys;


ALTER SCHEMA event_surveys OWNER TO indico;

--
-- Name: events; Type: SCHEMA; Schema: -; Owner: indico
--

CREATE SCHEMA events;


ALTER SCHEMA events OWNER TO indico;

--
-- Name: indico; Type: SCHEMA; Schema: -; Owner: indico
--

CREATE SCHEMA indico;


ALTER SCHEMA indico OWNER TO indico;

--
-- Name: oauth; Type: SCHEMA; Schema: -; Owner: indico
--

CREATE SCHEMA oauth;


ALTER SCHEMA oauth OWNER TO indico;

--
-- Name: roombooking; Type: SCHEMA; Schema: -; Owner: indico
--

CREATE SCHEMA roombooking;


ALTER SCHEMA roombooking OWNER TO indico;

--
-- Name: users; Type: SCHEMA; Schema: -; Owner: indico
--

CREATE SCHEMA users;


ALTER SCHEMA users OWNER TO indico;

--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: check_consistency_deleted(); Type: FUNCTION; Schema: categories; Owner: indico
--

CREATE FUNCTION categories.check_consistency_deleted() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    rows int;
BEGIN
    CREATE TEMP TABLE IF NOT EXISTS _categories_consistency_deleted_checked (dummy bool) ON COMMIT DROP;
    IF EXISTS (SELECT 1 FROM _categories_consistency_deleted_checked) THEN
        RETURN NULL;
    ELSE
        INSERT INTO _categories_consistency_deleted_checked VALUES (true);
    END IF;
    -- use dynamic sql to prevent pg from preparing the statement with a crappy query plan
    EXECUTE $$
        WITH RECURSIVE chains(id, path, is_deleted) AS (
            SELECT id, ARRAY[id], is_deleted
            FROM categories.categories
            WHERE parent_id IS NULL

            UNION ALL

            SELECT cat.id, chains.path || cat.id, chains.is_deleted OR cat.is_deleted
            FROM categories.categories cat, chains
            WHERE cat.parent_id = chains.id
        )
        SELECT 1
        FROM events.events e
        JOIN chains ON (chains.id = e.category_id)
        WHERE NOT e.is_deleted AND chains.is_deleted;
    $$;
    GET DIAGNOSTICS rows = ROW_COUNT;
    IF rows != 0 THEN
        RAISE EXCEPTION SQLSTATE 'INDX1' USING
            MESSAGE = 'Categories inconsistent',
            DETAIL = 'Event inside deleted category';
    END IF;

    EXECUTE $$
        SELECT 1
        FROM categories.categories cat
        JOIN categories.categories parent ON (parent.id = cat.parent_id)
        WHERE NOT cat.is_deleted AND parent.is_deleted;
    $$;
    GET DIAGNOSTICS rows = ROW_COUNT;
    IF rows != 0 THEN
        RAISE EXCEPTION SQLSTATE 'INDX1' USING
            MESSAGE = 'Categories inconsistent',
            DETAIL = 'Subcategory inside deleted category';
    END IF;
    RETURN NULL;
END;
$_$;


ALTER FUNCTION categories.check_consistency_deleted() OWNER TO indico;

--
-- Name: check_cycles(); Type: FUNCTION; Schema: categories; Owner: indico
--

CREATE FUNCTION categories.check_cycles() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    rows int;
BEGIN
    -- use dynamic sql to prevent pg from preparing the statement with a crappy query plan
    EXECUTE $$
        WITH RECURSIVE chains(id, path, is_cycle) AS (
            SELECT id, ARRAY[id], false
            FROM categories.categories

            UNION ALL

            SELECT cat.id, chains.path || cat.id, cat.id = ANY(chains.path)
            FROM categories.categories cat, chains
            WHERE cat.parent_id = chains.id AND NOT chains.is_cycle
        )
        SELECT 1 FROM chains WHERE is_cycle;
    $$;
    GET DIAGNOSTICS rows = ROW_COUNT;
    IF rows != 0 THEN
        RAISE EXCEPTION SQLSTATE 'INDX2' USING
            MESSAGE = 'Categories inconsistent',
            DETAIL = 'Cycle detected';
    END IF;

    RETURN NULL;
END;
$_$;


ALTER FUNCTION categories.check_cycles() OWNER TO indico;

--
-- Name: check_timetable_consistency(); Type: FUNCTION; Schema: events; Owner: indico
--

CREATE FUNCTION events.check_timetable_consistency() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    src varchar;
    trigger_event_id int;
BEGIN
src := TG_ARGV[0];

IF src = 'break' THEN
    SELECT tte.event_id INTO STRICT trigger_event_id
    FROM events.timetable_entries tte
    WHERE tte.break_id = NEW.id;
ELSIF src = 'session_block' THEN
    SELECT s.event_id INTO STRICT trigger_event_id
    FROM events.sessions s
    WHERE s.id = NEW.session_id;
ELSIF src = 'event' THEN
    trigger_event_id := NEW.id;
ELSE
    trigger_event_id := NEW.event_id;
END IF;

IF EXISTS (
    SELECT 1
    FROM events.timetable_entries te
    WHERE te.parent_id IS NULL AND te.type = 2 AND EXISTS (
        SELECT 1
        FROM events.contributions c
        WHERE c.id = te.contribution_id AND (c.session_id IS NOT NULL or c.session_block_id IS NOT NULL)
    ) AND te.event_id = trigger_event_id
) THEN
    RAISE EXCEPTION SQLSTATE 'INDX0' USING
        MESSAGE = 'Timetable inconsistent',
        DETAIL = 'Top-level entry for contribution in a session';
END IF;

IF EXISTS (
    SELECT 1
    FROM events.timetable_entries te
    JOIN events.timetable_entries tep ON (tep.id = te.parent_id)
    JOIN events.session_blocks sb ON (sb.id = tep.session_block_id)
    WHERE te.parent_id IS NOT NULL AND te.type = 2 AND EXISTS (
        SELECT 1
        FROM events.contributions c
        WHERE (
            c.id = te.contribution_id AND (COALESCE(c.session_id, -1) != COALESCE(sb.session_id, -1) OR
            COALESCE(c.session_block_id, -1) != COALESCE(tep.session_block_id, -1))
        )
    ) AND te.event_id = trigger_event_id
) THEN
    RAISE EXCEPTION SQLSTATE 'INDX0' USING
        MESSAGE = 'Timetable inconsistent',
        DETAIL = 'Child entry for contribution in a session does not match the parent session';
END IF;

IF EXISTS (
    SELECT 1
    FROM events.timetable_entries te
    JOIN events.timetable_entries tep ON (tep.id = te.parent_id)
    WHERE te.event_id = trigger_event_id AND te.parent_id IS NOT NULL AND tep.start_dt > te.start_dt
) THEN
    RAISE EXCEPTION SQLSTATE 'INDX0' USING
        MESSAGE = 'Timetable inconsistent',
        DETAIL = 'Entry starts before its parent block';
END IF;

IF EXISTS (
    SELECT 1
    FROM events.timetable_entries te
    JOIN events.timetable_entries tep ON (tep.id = te.parent_id)
    JOIN events.session_blocks bl ON (bl.id = tep.session_block_id)
    LEFT JOIN events.contributions c ON (c.id = te.contribution_id)
    LEFT JOIN events.breaks b ON (b.id = te.break_id)
    WHERE te.event_id = trigger_event_id AND te.parent_id IS NOT NULL AND te.type IN (2, 3) AND
          (te.start_dt + COALESCE(c.duration, b.duration)) > (tep.start_dt + bl.duration)
) THEN
    RAISE EXCEPTION SQLSTATE 'INDX0' USING
        MESSAGE = 'Timetable inconsistent',
        DETAIL = 'Entry ends after its parent block';
END IF;

IF EXISTS (
    SELECT 1
    FROM events.timetable_entries te
    JOIN events.events e ON (e.id = te.event_id)
    WHERE te.event_id = trigger_event_id AND te.start_dt < e.start_dt
) THEN
    RAISE EXCEPTION SQLSTATE 'INDX0' USING
        MESSAGE = 'Timetable inconsistent',
        DETAIL = 'Entry starts before the event';
END IF;

IF EXISTS (
    SELECT 1
    FROM events.timetable_entries te
    JOIN events.events e ON (e.id = te.event_id)
    LEFT JOIN events.session_blocks bl ON (bl.id = te.session_block_id)
    LEFT JOIN events.contributions c ON (c.id = te.contribution_id)
    LEFT JOIN events.breaks b ON (b.id = te.break_id)
    WHERE te.event_id = trigger_event_id AND
          (te.start_dt + COALESCE(c.duration, b.duration, bl.duration)) > e.end_dt
) THEN
    RAISE EXCEPTION SQLSTATE 'INDX0' USING
        MESSAGE = 'Timetable inconsistent',
        DETAIL = 'Entry ends after the event';
END IF;

RETURN NULL;
END;
$$;


ALTER FUNCTION events.check_timetable_consistency() OWNER TO indico;

--
-- Name: array_is_unique(text[]); Type: FUNCTION; Schema: indico; Owner: indico
--

CREATE FUNCTION indico.array_is_unique(value text[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
        SELECT COALESCE(COUNT(DISTINCT a) = array_length(value, 1), true)
        FROM unnest(value) a
    $$;


ALTER FUNCTION indico.array_is_unique(value text[]) OWNER TO indico;

--
-- Name: indico_unaccent(text); Type: FUNCTION; Schema: indico; Owner: indico
--

CREATE FUNCTION indico.indico_unaccent(value text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    SET search_path TO 'public', 'pg_temp'
    AS $$
    BEGIN
        RETURN unaccent('unaccent', value);
    END;
    $$;


ALTER FUNCTION indico.indico_unaccent(value text) OWNER TO indico;

--
-- Name: natsort(text); Type: FUNCTION; Schema: indico; Owner: indico
--

CREATE FUNCTION indico.natsort(value text) RETURNS bytea
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
    SELECT string_agg(
        convert_to(coalesce(r[2], length(length(r[1])::text) || length(r[1])::text || r[1]), 'SQL_ASCII'),
        ' '
    )
    FROM regexp_matches(value, '0*([0-9]+)|([^0-9]+)', 'g') r;
    $$;


ALTER FUNCTION indico.natsort(value text) OWNER TO indico;

--
-- Name: text_array_append(text[], text); Type: FUNCTION; Schema: indico; Owner: indico
--

CREATE FUNCTION indico.text_array_append(arr text[], item text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
    BEGIN
        RETURN array_append(arr, item);
    END;
    $$;


ALTER FUNCTION indico.text_array_append(arr text[], item text) OWNER TO indico;

--
-- Name: text_array_to_string(text[], text); Type: FUNCTION; Schema: indico; Owner: indico
--

CREATE FUNCTION indico.text_array_to_string(arr text[], sep text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
    BEGIN
        RETURN array_to_string(arr, sep);
    END;
    $$;


ALTER FUNCTION indico.text_array_to_string(arr text[], sep text) OWNER TO indico;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: attachment_principals; Type: TABLE; Schema: attachments; Owner: indico
--

CREATE TABLE attachments.attachment_principals (
    id integer NOT NULL,
    attachment_id integer NOT NULL,
    type smallint NOT NULL,
    user_id integer,
    local_group_id integer,
    mp_group_provider character varying,
    mp_group_name character varying,
    event_role_id integer,
    category_role_id integer,
    registration_form_id integer,
    CONSTRAINT ck_attachment_principals_valid_category_role CHECK (((type <> 7) OR ((event_role_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NULL) AND (category_role_id IS NOT NULL)))),
    CONSTRAINT ck_attachment_principals_valid_enum_type CHECK ((type = ANY (ARRAY[1, 2, 3, 6, 7, 8]))),
    CONSTRAINT ck_attachment_principals_valid_event_role CHECK (((type <> 6) OR ((category_role_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NULL) AND (event_role_id IS NOT NULL)))),
    CONSTRAINT ck_attachment_principals_valid_local_group CHECK (((type <> 2) OR ((category_role_id IS NULL) AND (event_role_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NULL) AND (local_group_id IS NOT NULL)))),
    CONSTRAINT ck_attachment_principals_valid_multipass_group CHECK (((type <> 3) OR ((category_role_id IS NULL) AND (event_role_id IS NULL) AND (local_group_id IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NULL) AND (mp_group_name IS NOT NULL) AND (mp_group_provider IS NOT NULL)))),
    CONSTRAINT ck_attachment_principals_valid_registration_form CHECK (((type <> 8) OR ((category_role_id IS NULL) AND (event_role_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (user_id IS NULL) AND (registration_form_id IS NOT NULL)))),
    CONSTRAINT ck_attachment_principals_valid_user CHECK (((type <> 1) OR ((category_role_id IS NULL) AND (event_role_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NOT NULL))))
);


ALTER TABLE attachments.attachment_principals OWNER TO indico;

--
-- Name: attachment_principals_id_seq; Type: SEQUENCE; Schema: attachments; Owner: indico
--

CREATE SEQUENCE attachments.attachment_principals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE attachments.attachment_principals_id_seq OWNER TO indico;

--
-- Name: attachment_principals_id_seq; Type: SEQUENCE OWNED BY; Schema: attachments; Owner: indico
--

ALTER SEQUENCE attachments.attachment_principals_id_seq OWNED BY attachments.attachment_principals.id;


--
-- Name: attachments; Type: TABLE; Schema: attachments; Owner: indico
--

CREATE TABLE attachments.attachments (
    id integer NOT NULL,
    folder_id integer NOT NULL,
    user_id integer NOT NULL,
    is_deleted boolean NOT NULL,
    description text NOT NULL,
    modified_dt timestamp without time zone NOT NULL,
    type smallint NOT NULL,
    link_url character varying,
    title character varying NOT NULL,
    protection_mode smallint NOT NULL,
    file_id integer,
    CONSTRAINT ck_attachments_link_or_file CHECK (((link_url IS NULL) OR (file_id IS NULL))),
    CONSTRAINT ck_attachments_valid_enum_protection_mode CHECK ((protection_mode = ANY (ARRAY[1, 2]))),
    CONSTRAINT ck_attachments_valid_enum_type CHECK ((type = ANY (ARRAY[1, 2]))),
    CONSTRAINT ck_attachments_valid_link CHECK (((type <> 2) OR ((link_url IS NOT NULL) AND (file_id IS NULL))))
);


ALTER TABLE attachments.attachments OWNER TO indico;

--
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: attachments; Owner: indico
--

CREATE SEQUENCE attachments.attachments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE attachments.attachments_id_seq OWNER TO indico;

--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: attachments; Owner: indico
--

ALTER SEQUENCE attachments.attachments_id_seq OWNED BY attachments.attachments.id;


--
-- Name: files; Type: TABLE; Schema: attachments; Owner: indico
--

CREATE TABLE attachments.files (
    id integer NOT NULL,
    attachment_id integer NOT NULL,
    user_id integer NOT NULL,
    filename character varying NOT NULL,
    content_type character varying NOT NULL,
    size bigint NOT NULL,
    md5 character varying NOT NULL,
    storage_backend character varying NOT NULL,
    storage_file_id character varying NOT NULL,
    created_dt timestamp without time zone NOT NULL
);


ALTER TABLE attachments.files OWNER TO indico;

--
-- Name: files_id_seq; Type: SEQUENCE; Schema: attachments; Owner: indico
--

CREATE SEQUENCE attachments.files_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE attachments.files_id_seq OWNER TO indico;

--
-- Name: files_id_seq; Type: SEQUENCE OWNED BY; Schema: attachments; Owner: indico
--

ALTER SEQUENCE attachments.files_id_seq OWNED BY attachments.files.id;


--
-- Name: folder_principals; Type: TABLE; Schema: attachments; Owner: indico
--

CREATE TABLE attachments.folder_principals (
    id integer NOT NULL,
    folder_id integer NOT NULL,
    type smallint NOT NULL,
    user_id integer,
    local_group_id integer,
    mp_group_provider character varying,
    mp_group_name character varying,
    event_role_id integer,
    category_role_id integer,
    registration_form_id integer,
    CONSTRAINT ck_folder_principals_valid_category_role CHECK (((type <> 7) OR ((event_role_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NULL) AND (category_role_id IS NOT NULL)))),
    CONSTRAINT ck_folder_principals_valid_enum_type CHECK ((type = ANY (ARRAY[1, 2, 3, 6, 7, 8]))),
    CONSTRAINT ck_folder_principals_valid_event_role CHECK (((type <> 6) OR ((category_role_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NULL) AND (event_role_id IS NOT NULL)))),
    CONSTRAINT ck_folder_principals_valid_local_group CHECK (((type <> 2) OR ((category_role_id IS NULL) AND (event_role_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NULL) AND (local_group_id IS NOT NULL)))),
    CONSTRAINT ck_folder_principals_valid_multipass_group CHECK (((type <> 3) OR ((category_role_id IS NULL) AND (event_role_id IS NULL) AND (local_group_id IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NULL) AND (mp_group_name IS NOT NULL) AND (mp_group_provider IS NOT NULL)))),
    CONSTRAINT ck_folder_principals_valid_registration_form CHECK (((type <> 8) OR ((category_role_id IS NULL) AND (event_role_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (user_id IS NULL) AND (registration_form_id IS NOT NULL)))),
    CONSTRAINT ck_folder_principals_valid_user CHECK (((type <> 1) OR ((category_role_id IS NULL) AND (event_role_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NOT NULL))))
);


ALTER TABLE attachments.folder_principals OWNER TO indico;

--
-- Name: folder_principals_id_seq; Type: SEQUENCE; Schema: attachments; Owner: indico
--

CREATE SEQUENCE attachments.folder_principals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE attachments.folder_principals_id_seq OWNER TO indico;

--
-- Name: folder_principals_id_seq; Type: SEQUENCE OWNED BY; Schema: attachments; Owner: indico
--

ALTER SEQUENCE attachments.folder_principals_id_seq OWNED BY attachments.folder_principals.id;


--
-- Name: folders; Type: TABLE; Schema: attachments; Owner: indico
--

CREATE TABLE attachments.folders (
    id integer NOT NULL,
    title character varying,
    description text NOT NULL,
    is_deleted boolean NOT NULL,
    is_default boolean NOT NULL,
    is_always_visible boolean NOT NULL,
    is_hidden boolean NOT NULL,
    link_type smallint NOT NULL,
    category_id integer,
    event_id integer,
    linked_event_id integer,
    session_id integer,
    contribution_id integer,
    subcontribution_id integer,
    protection_mode smallint NOT NULL,
    CONSTRAINT ck_folders_default_inheriting CHECK ((NOT (is_default AND (protection_mode <> 1)))),
    CONSTRAINT ck_folders_default_not_deleted CHECK ((NOT (is_default AND is_deleted))),
    CONSTRAINT ck_folders_default_or_title CHECK ((is_default = (title IS NULL))),
    CONSTRAINT ck_folders_is_hidden_not_is_always_visible CHECK ((NOT (is_hidden AND is_always_visible))),
    CONSTRAINT ck_folders_valid_category_link CHECK (((link_type <> 1) OR ((contribution_id IS NULL) AND (linked_event_id IS NULL) AND (session_id IS NULL) AND (subcontribution_id IS NULL) AND (category_id IS NOT NULL)))),
    CONSTRAINT ck_folders_valid_contribution_link CHECK (((link_type <> 3) OR ((category_id IS NULL) AND (linked_event_id IS NULL) AND (session_id IS NULL) AND (subcontribution_id IS NULL) AND (contribution_id IS NOT NULL)))),
    CONSTRAINT ck_folders_valid_enum_link_type CHECK ((link_type = ANY (ARRAY[1, 2, 3, 4, 5]))),
    CONSTRAINT ck_folders_valid_enum_protection_mode CHECK ((protection_mode = ANY (ARRAY[1, 2]))),
    CONSTRAINT ck_folders_valid_event_id CHECK (((event_id IS NULL) = (link_type = 1))),
    CONSTRAINT ck_folders_valid_event_link CHECK (((link_type <> 2) OR ((category_id IS NULL) AND (contribution_id IS NULL) AND (session_id IS NULL) AND (subcontribution_id IS NULL) AND (linked_event_id IS NOT NULL)))),
    CONSTRAINT ck_folders_valid_session_link CHECK (((link_type <> 5) OR ((category_id IS NULL) AND (contribution_id IS NULL) AND (linked_event_id IS NULL) AND (subcontribution_id IS NULL) AND (session_id IS NOT NULL)))),
    CONSTRAINT ck_folders_valid_subcontribution_link CHECK (((link_type <> 4) OR ((category_id IS NULL) AND (contribution_id IS NULL) AND (linked_event_id IS NULL) AND (session_id IS NULL) AND (subcontribution_id IS NOT NULL))))
);


ALTER TABLE attachments.folders OWNER TO indico;

--
-- Name: folders_id_seq; Type: SEQUENCE; Schema: attachments; Owner: indico
--

CREATE SEQUENCE attachments.folders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE attachments.folders_id_seq OWNER TO indico;

--
-- Name: folders_id_seq; Type: SEQUENCE OWNED BY; Schema: attachments; Owner: indico
--

ALTER SEQUENCE attachments.folders_id_seq OWNED BY attachments.folders.id;


--
-- Name: legacy_attachment_id_map; Type: TABLE; Schema: attachments; Owner: indico
--

CREATE TABLE attachments.legacy_attachment_id_map (
    material_id character varying NOT NULL,
    resource_id character varying NOT NULL,
    attachment_id integer NOT NULL,
    event_id integer NOT NULL,
    session_id character varying,
    contribution_id character varying,
    subcontribution_id character varying
);


ALTER TABLE attachments.legacy_attachment_id_map OWNER TO indico;

--
-- Name: legacy_folder_id_map; Type: TABLE; Schema: attachments; Owner: indico
--

CREATE TABLE attachments.legacy_folder_id_map (
    material_id character varying NOT NULL,
    folder_id integer NOT NULL,
    event_id integer NOT NULL,
    session_id character varying,
    contribution_id character varying,
    subcontribution_id character varying
);


ALTER TABLE attachments.legacy_folder_id_map OWNER TO indico;

--
-- Name: categories; Type: TABLE; Schema: categories; Owner: indico
--

CREATE TABLE categories.categories (
    id integer NOT NULL,
    parent_id integer,
    is_deleted boolean NOT NULL,
    "position" integer NOT NULL,
    visibility integer,
    icon_metadata jsonb NOT NULL,
    icon bytea,
    logo_metadata jsonb NOT NULL,
    logo bytea,
    timezone character varying NOT NULL,
    default_event_themes jsonb NOT NULL,
    event_creation_mode smallint NOT NULL,
    event_creation_notification_emails character varying[] NOT NULL,
    event_message_mode smallint NOT NULL,
    event_message text NOT NULL,
    suggestions_disabled boolean NOT NULL,
    notify_managers boolean NOT NULL,
    show_future_months integer NOT NULL,
    google_wallet_mode smallint NOT NULL,
    google_wallet_settings jsonb NOT NULL,
    apple_wallet_mode smallint NOT NULL,
    apple_wallet_settings jsonb NOT NULL,
    is_flat_view_enabled boolean NOT NULL,
    default_ticket_template_id integer,
    default_badge_template_id integer,
    title character varying NOT NULL,
    description text NOT NULL,
    protection_mode smallint NOT NULL,
    no_access_contact character varying NOT NULL,
    CONSTRAINT ck_categories_ap_configured_if_enabled CHECK (((apple_wallet_mode <> 1) OR (apple_wallet_settings <> '{}'::jsonb))),
    CONSTRAINT ck_categories_gw_configured_if_enabled CHECK (((google_wallet_mode <> 1) OR (google_wallet_settings <> '{}'::jsonb))),
    CONSTRAINT ck_categories_root_not_deleted CHECK (((id <> 0) OR (NOT is_deleted))),
    CONSTRAINT ck_categories_root_not_inheriting CHECK (((id <> 0) OR (protection_mode <> 1))),
    CONSTRAINT ck_categories_root_not_inheriting_ap_mode CHECK (((id <> 0) OR (apple_wallet_mode <> 2))),
    CONSTRAINT ck_categories_root_not_inheriting_gw_mode CHECK (((id <> 0) OR (google_wallet_mode <> 2))),
    CONSTRAINT ck_categories_valid_enum_apple_wallet_mode CHECK ((apple_wallet_mode = ANY (ARRAY[0, 1, 2]))),
    CONSTRAINT ck_categories_valid_enum_event_creation_mode CHECK ((event_creation_mode = ANY (ARRAY[1, 2, 3]))),
    CONSTRAINT ck_categories_valid_enum_event_message_mode CHECK ((event_message_mode = ANY (ARRAY[0, 1, 2, 3]))),
    CONSTRAINT ck_categories_valid_enum_google_wallet_mode CHECK ((google_wallet_mode = ANY (ARRAY[0, 1, 2]))),
    CONSTRAINT ck_categories_valid_enum_protection_mode CHECK ((protection_mode = ANY (ARRAY[0, 1, 2]))),
    CONSTRAINT ck_categories_valid_icon CHECK (((icon IS NULL) = ((icon_metadata)::text = 'null'::text))),
    CONSTRAINT ck_categories_valid_logo CHECK (((logo IS NULL) = ((logo_metadata)::text = 'null'::text))),
    CONSTRAINT ck_categories_valid_parent CHECK (((parent_id IS NULL) = (id = 0))),
    CONSTRAINT ck_categories_valid_title CHECK (((title)::text <> ''::text)),
    CONSTRAINT ck_categories_valid_visibility CHECK (((visibility IS NULL) OR (visibility > 0)))
);


ALTER TABLE categories.categories OWNER TO indico;

--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: categories; Owner: indico
--

CREATE SEQUENCE categories.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE categories.categories_id_seq OWNER TO indico;

--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: categories; Owner: indico
--

ALTER SEQUENCE categories.categories_id_seq OWNED BY categories.categories.id;


--
-- Name: event_move_requests; Type: TABLE; Schema: categories; Owner: indico
--

CREATE TABLE categories.event_move_requests (
    id integer NOT NULL,
    event_id integer NOT NULL,
    category_id integer NOT NULL,
    requestor_id integer NOT NULL,
    state smallint NOT NULL,
    requestor_comment character varying NOT NULL,
    moderator_comment character varying NOT NULL,
    moderator_id integer,
    requested_dt timestamp without time zone NOT NULL,
    CONSTRAINT ck_event_move_requests_moderator_state CHECK ((((state = ANY (ARRAY[1, 2])) AND (moderator_id IS NOT NULL)) OR (moderator_id IS NULL))),
    CONSTRAINT ck_event_move_requests_valid_enum_state CHECK ((state = ANY (ARRAY[0, 1, 2, 3])))
);


ALTER TABLE categories.event_move_requests OWNER TO indico;

--
-- Name: event_move_requests_id_seq; Type: SEQUENCE; Schema: categories; Owner: indico
--

CREATE SEQUENCE categories.event_move_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE categories.event_move_requests_id_seq OWNER TO indico;

--
-- Name: event_move_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: categories; Owner: indico
--

ALTER SEQUENCE categories.event_move_requests_id_seq OWNED BY categories.event_move_requests.id;


--
-- Name: legacy_id_map; Type: TABLE; Schema: categories; Owner: indico
--

CREATE TABLE categories.legacy_id_map (
    legacy_category_id character varying NOT NULL,
    category_id integer NOT NULL
);


ALTER TABLE categories.legacy_id_map OWNER TO indico;

--
-- Name: logs; Type: TABLE; Schema: categories; Owner: indico
--

CREATE TABLE categories.logs (
    id integer NOT NULL,
    logged_dt timestamp without time zone NOT NULL,
    kind smallint NOT NULL,
    module character varying NOT NULL,
    type character varying NOT NULL,
    summary character varying NOT NULL,
    data json NOT NULL,
    meta jsonb NOT NULL,
    category_id integer NOT NULL,
    realm smallint NOT NULL,
    user_id integer,
    CONSTRAINT ck_logs_valid_enum_kind CHECK ((kind = ANY (ARRAY[1, 2, 3, 4]))),
    CONSTRAINT ck_logs_valid_enum_realm CHECK ((realm = ANY (ARRAY[1, 2])))
);


ALTER TABLE categories.logs OWNER TO indico;

--
-- Name: logs_id_seq; Type: SEQUENCE; Schema: categories; Owner: indico
--

CREATE SEQUENCE categories.logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE categories.logs_id_seq OWNER TO indico;

--
-- Name: logs_id_seq; Type: SEQUENCE OWNED BY; Schema: categories; Owner: indico
--

ALTER SEQUENCE categories.logs_id_seq OWNED BY categories.logs.id;


--
-- Name: principals; Type: TABLE; Schema: categories; Owner: indico
--

CREATE TABLE categories.principals (
    read_access boolean NOT NULL,
    full_access boolean NOT NULL,
    permissions character varying[] NOT NULL,
    id integer NOT NULL,
    category_id integer NOT NULL,
    type smallint NOT NULL,
    user_id integer,
    local_group_id integer,
    mp_group_provider character varying,
    mp_group_name character varying,
    ip_network_group_id integer,
    category_role_id integer,
    CONSTRAINT ck_principals_has_privs CHECK ((read_access OR full_access OR (array_length(permissions, 1) IS NOT NULL))),
    CONSTRAINT ck_principals_networks_read_only CHECK (((type <> 5) OR ((NOT full_access) AND (array_length(permissions, 1) IS NULL)))),
    CONSTRAINT ck_principals_valid_category_role CHECK (((type <> 7) OR ((ip_network_group_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (user_id IS NULL) AND (category_role_id IS NOT NULL)))),
    CONSTRAINT ck_principals_valid_enum_type CHECK ((type = ANY (ARRAY[1, 2, 3, 5, 7]))),
    CONSTRAINT ck_principals_valid_local_group CHECK (((type <> 2) OR ((category_role_id IS NULL) AND (ip_network_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (user_id IS NULL) AND (local_group_id IS NOT NULL)))),
    CONSTRAINT ck_principals_valid_multipass_group CHECK (((type <> 3) OR ((category_role_id IS NULL) AND (ip_network_group_id IS NULL) AND (local_group_id IS NULL) AND (user_id IS NULL) AND (mp_group_name IS NOT NULL) AND (mp_group_provider IS NOT NULL)))),
    CONSTRAINT ck_principals_valid_network CHECK (((type <> 5) OR ((category_role_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (user_id IS NULL) AND (ip_network_group_id IS NOT NULL)))),
    CONSTRAINT ck_principals_valid_user CHECK (((type <> 1) OR ((category_role_id IS NULL) AND (ip_network_group_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (user_id IS NOT NULL))))
);


ALTER TABLE categories.principals OWNER TO indico;

--
-- Name: principals_id_seq; Type: SEQUENCE; Schema: categories; Owner: indico
--

CREATE SEQUENCE categories.principals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE categories.principals_id_seq OWNER TO indico;

--
-- Name: principals_id_seq; Type: SEQUENCE OWNED BY; Schema: categories; Owner: indico
--

ALTER SEQUENCE categories.principals_id_seq OWNED BY categories.principals.id;


--
-- Name: role_members; Type: TABLE; Schema: categories; Owner: indico
--

CREATE TABLE categories.role_members (
    role_id integer NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE categories.role_members OWNER TO indico;

--
-- Name: roles; Type: TABLE; Schema: categories; Owner: indico
--

CREATE TABLE categories.roles (
    id integer NOT NULL,
    category_id integer NOT NULL,
    name character varying NOT NULL,
    code character varying NOT NULL,
    color character varying NOT NULL,
    CONSTRAINT ck_roles_uppercase_code CHECK (((code)::text = upper((code)::text)))
);


ALTER TABLE categories.roles OWNER TO indico;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: categories; Owner: indico
--

CREATE SEQUENCE categories.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE categories.roles_id_seq OWNER TO indico;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: categories; Owner: indico
--

ALTER SEQUENCE categories.roles_id_seq OWNED BY categories.roles.id;


--
-- Name: settings; Type: TABLE; Schema: categories; Owner: indico
--

CREATE TABLE categories.settings (
    id integer NOT NULL,
    module character varying NOT NULL,
    name character varying NOT NULL,
    value jsonb NOT NULL,
    category_id integer NOT NULL,
    CONSTRAINT ck_settings_lowercase_module CHECK (((module)::text = lower((module)::text))),
    CONSTRAINT ck_settings_lowercase_name CHECK (((name)::text = lower((name)::text)))
);


ALTER TABLE categories.settings OWNER TO indico;

--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: categories; Owner: indico
--

CREATE SEQUENCE categories.settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE categories.settings_id_seq OWNER TO indico;

--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: categories; Owner: indico
--

ALTER SEQUENCE categories.settings_id_seq OWNED BY categories.settings.id;


--
-- Name: abstract_comments; Type: TABLE; Schema: event_abstracts; Owner: indico
--

CREATE TABLE event_abstracts.abstract_comments (
    id integer NOT NULL,
    user_id integer NOT NULL,
    text text NOT NULL,
    modified_by_id integer,
    created_dt timestamp without time zone NOT NULL,
    modified_dt timestamp without time zone,
    is_deleted boolean NOT NULL,
    abstract_id integer NOT NULL,
    visibility smallint NOT NULL,
    CONSTRAINT ck_abstract_comments_valid_enum_visibility CHECK ((visibility = ANY (ARRAY[1, 2, 3, 4, 5])))
);


ALTER TABLE event_abstracts.abstract_comments OWNER TO indico;

--
-- Name: abstract_comments_id_seq; Type: SEQUENCE; Schema: event_abstracts; Owner: indico
--

CREATE SEQUENCE event_abstracts.abstract_comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_abstracts.abstract_comments_id_seq OWNER TO indico;

--
-- Name: abstract_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: event_abstracts; Owner: indico
--

ALTER SEQUENCE event_abstracts.abstract_comments_id_seq OWNED BY event_abstracts.abstract_comments.id;


--
-- Name: abstract_field_values; Type: TABLE; Schema: event_abstracts; Owner: indico
--

CREATE TABLE event_abstracts.abstract_field_values (
    data jsonb NOT NULL,
    abstract_id integer NOT NULL,
    contribution_field_id integer NOT NULL
);


ALTER TABLE event_abstracts.abstract_field_values OWNER TO indico;

--
-- Name: abstract_person_links; Type: TABLE; Schema: event_abstracts; Owner: indico
--

CREATE TABLE event_abstracts.abstract_person_links (
    abstract_id integer NOT NULL,
    is_speaker boolean NOT NULL,
    author_type smallint NOT NULL,
    id integer NOT NULL,
    person_id integer NOT NULL,
    first_name character varying,
    last_name character varying,
    title smallint,
    affiliation_id integer,
    affiliation character varying,
    address text,
    phone character varying,
    display_order integer NOT NULL,
    CONSTRAINT ck_abstract_person_links_valid_enum_author_type CHECK ((author_type = ANY (ARRAY[0, 1, 2]))),
    CONSTRAINT ck_abstract_person_links_valid_enum_title CHECK ((title = ANY (ARRAY[0, 1, 2, 3, 4, 5, 6])))
);


ALTER TABLE event_abstracts.abstract_person_links OWNER TO indico;

--
-- Name: abstract_person_links_id_seq; Type: SEQUENCE; Schema: event_abstracts; Owner: indico
--

CREATE SEQUENCE event_abstracts.abstract_person_links_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_abstracts.abstract_person_links_id_seq OWNER TO indico;

--
-- Name: abstract_person_links_id_seq; Type: SEQUENCE OWNED BY; Schema: event_abstracts; Owner: indico
--

ALTER SEQUENCE event_abstracts.abstract_person_links_id_seq OWNED BY event_abstracts.abstract_person_links.id;


--
-- Name: abstract_review_questions; Type: TABLE; Schema: event_abstracts; Owner: indico
--

CREATE TABLE event_abstracts.abstract_review_questions (
    id integer NOT NULL,
    event_id integer NOT NULL,
    field_type character varying NOT NULL,
    title text NOT NULL,
    no_score boolean NOT NULL,
    "position" integer NOT NULL,
    is_deleted boolean NOT NULL,
    is_required boolean NOT NULL,
    field_data jsonb NOT NULL,
    description text NOT NULL
);


ALTER TABLE event_abstracts.abstract_review_questions OWNER TO indico;

--
-- Name: abstract_review_questions_id_seq; Type: SEQUENCE; Schema: event_abstracts; Owner: indico
--

CREATE SEQUENCE event_abstracts.abstract_review_questions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_abstracts.abstract_review_questions_id_seq OWNER TO indico;

--
-- Name: abstract_review_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: event_abstracts; Owner: indico
--

ALTER SEQUENCE event_abstracts.abstract_review_questions_id_seq OWNED BY event_abstracts.abstract_review_questions.id;


--
-- Name: abstract_review_ratings; Type: TABLE; Schema: event_abstracts; Owner: indico
--

CREATE TABLE event_abstracts.abstract_review_ratings (
    id integer NOT NULL,
    question_id integer NOT NULL,
    review_id integer NOT NULL,
    value jsonb NOT NULL
);


ALTER TABLE event_abstracts.abstract_review_ratings OWNER TO indico;

--
-- Name: abstract_review_ratings_id_seq; Type: SEQUENCE; Schema: event_abstracts; Owner: indico
--

CREATE SEQUENCE event_abstracts.abstract_review_ratings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_abstracts.abstract_review_ratings_id_seq OWNER TO indico;

--
-- Name: abstract_review_ratings_id_seq; Type: SEQUENCE OWNED BY; Schema: event_abstracts; Owner: indico
--

ALTER SEQUENCE event_abstracts.abstract_review_ratings_id_seq OWNED BY event_abstracts.abstract_review_ratings.id;


--
-- Name: abstract_reviews; Type: TABLE; Schema: event_abstracts; Owner: indico
--

CREATE TABLE event_abstracts.abstract_reviews (
    id integer NOT NULL,
    abstract_id integer NOT NULL,
    user_id integer NOT NULL,
    track_id integer,
    created_dt timestamp without time zone NOT NULL,
    modified_dt timestamp without time zone,
    comment text NOT NULL,
    proposed_action smallint NOT NULL,
    proposed_related_abstract_id integer,
    proposed_contribution_type_id integer,
    CONSTRAINT ck_abstract_reviews_prop_abstract_id_only_duplicate_merge CHECK (((proposed_action = ANY (ARRAY[4, 5])) = (proposed_related_abstract_id IS NOT NULL))),
    CONSTRAINT ck_abstract_reviews_prop_contrib_id_only_accepted CHECK (((proposed_action = 1) OR (proposed_contribution_type_id IS NULL))),
    CONSTRAINT ck_abstract_reviews_valid_enum_proposed_action CHECK ((proposed_action = ANY (ARRAY[1, 2, 3, 4, 5])))
);


ALTER TABLE event_abstracts.abstract_reviews OWNER TO indico;

--
-- Name: abstract_reviews_id_seq; Type: SEQUENCE; Schema: event_abstracts; Owner: indico
--

CREATE SEQUENCE event_abstracts.abstract_reviews_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_abstracts.abstract_reviews_id_seq OWNER TO indico;

--
-- Name: abstract_reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: event_abstracts; Owner: indico
--

ALTER SEQUENCE event_abstracts.abstract_reviews_id_seq OWNED BY event_abstracts.abstract_reviews.id;


--
-- Name: abstracts; Type: TABLE; Schema: event_abstracts; Owner: indico
--

CREATE TABLE event_abstracts.abstracts (
    id integer NOT NULL,
    uuid uuid,
    friendly_id integer NOT NULL,
    event_id integer NOT NULL,
    title character varying NOT NULL,
    submitter_id integer NOT NULL,
    submitted_contrib_type_id integer,
    submitted_dt timestamp without time zone NOT NULL,
    modified_by_id integer,
    modified_dt timestamp without time zone,
    state smallint NOT NULL,
    submission_comment text NOT NULL,
    judge_id integer,
    judgment_comment text NOT NULL,
    judgment_dt timestamp without time zone,
    accepted_track_id integer,
    accepted_contrib_type_id integer,
    merged_into_id integer,
    duplicate_of_id integer,
    is_deleted boolean NOT NULL,
    description text NOT NULL,
    CONSTRAINT ck_abstracts_accepted_contrib_type_id_only_accepted CHECK (((state = 3) OR (accepted_contrib_type_id IS NULL))),
    CONSTRAINT ck_abstracts_accepted_track_id_only_accepted CHECK (((state = 3) OR (accepted_track_id IS NULL))),
    CONSTRAINT ck_abstracts_duplicate_of_id_only_duplicate CHECK (((state = 6) = (duplicate_of_id IS NOT NULL))),
    CONSTRAINT ck_abstracts_judge_if_judged CHECK (((state = ANY (ARRAY[3, 4, 5, 6])) = (judge_id IS NOT NULL))),
    CONSTRAINT ck_abstracts_judgment_dt_if_judged CHECK (((state = ANY (ARRAY[3, 4, 5, 6])) = (judgment_dt IS NOT NULL))),
    CONSTRAINT ck_abstracts_merged_into_id_only_merged CHECK (((state = 5) = (merged_into_id IS NOT NULL))),
    CONSTRAINT ck_abstracts_uuid_if_invited CHECK (((state <> 7) OR (uuid IS NOT NULL))),
    CONSTRAINT ck_abstracts_valid_enum_state CHECK ((state = ANY (ARRAY[1, 2, 3, 4, 5, 6, 7])))
);


ALTER TABLE event_abstracts.abstracts OWNER TO indico;

--
-- Name: abstracts_id_seq; Type: SEQUENCE; Schema: event_abstracts; Owner: indico
--

CREATE SEQUENCE event_abstracts.abstracts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_abstracts.abstracts_id_seq OWNER TO indico;

--
-- Name: abstracts_id_seq; Type: SEQUENCE OWNED BY; Schema: event_abstracts; Owner: indico
--

ALTER SEQUENCE event_abstracts.abstracts_id_seq OWNED BY event_abstracts.abstracts.id;


--
-- Name: email_logs; Type: TABLE; Schema: event_abstracts; Owner: indico
--

CREATE TABLE event_abstracts.email_logs (
    id integer NOT NULL,
    abstract_id integer NOT NULL,
    email_template_id integer,
    user_id integer,
    sent_dt timestamp without time zone NOT NULL,
    recipients character varying[] NOT NULL,
    subject character varying NOT NULL,
    body text NOT NULL,
    data jsonb NOT NULL
);


ALTER TABLE event_abstracts.email_logs OWNER TO indico;

--
-- Name: email_logs_id_seq; Type: SEQUENCE; Schema: event_abstracts; Owner: indico
--

CREATE SEQUENCE event_abstracts.email_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_abstracts.email_logs_id_seq OWNER TO indico;

--
-- Name: email_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: event_abstracts; Owner: indico
--

ALTER SEQUENCE event_abstracts.email_logs_id_seq OWNED BY event_abstracts.email_logs.id;


--
-- Name: email_templates; Type: TABLE; Schema: event_abstracts; Owner: indico
--

CREATE TABLE event_abstracts.email_templates (
    id integer NOT NULL,
    title character varying NOT NULL,
    event_id integer NOT NULL,
    "position" integer NOT NULL,
    reply_to_address character varying NOT NULL,
    subject character varying NOT NULL,
    body text NOT NULL,
    extra_cc_emails character varying[] NOT NULL,
    include_submitter boolean NOT NULL,
    include_authors boolean NOT NULL,
    include_coauthors boolean NOT NULL,
    stop_on_match boolean NOT NULL,
    rules jsonb NOT NULL
);


ALTER TABLE event_abstracts.email_templates OWNER TO indico;

--
-- Name: email_templates_id_seq; Type: SEQUENCE; Schema: event_abstracts; Owner: indico
--

CREATE SEQUENCE event_abstracts.email_templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_abstracts.email_templates_id_seq OWNER TO indico;

--
-- Name: email_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: event_abstracts; Owner: indico
--

ALTER SEQUENCE event_abstracts.email_templates_id_seq OWNED BY event_abstracts.email_templates.id;


--
-- Name: files; Type: TABLE; Schema: event_abstracts; Owner: indico
--

CREATE TABLE event_abstracts.files (
    id integer NOT NULL,
    abstract_id integer NOT NULL,
    filename character varying NOT NULL,
    content_type character varying NOT NULL,
    size bigint NOT NULL,
    md5 character varying NOT NULL,
    storage_backend character varying NOT NULL,
    storage_file_id character varying NOT NULL
);


ALTER TABLE event_abstracts.files OWNER TO indico;

--
-- Name: files_id_seq; Type: SEQUENCE; Schema: event_abstracts; Owner: indico
--

CREATE SEQUENCE event_abstracts.files_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_abstracts.files_id_seq OWNER TO indico;

--
-- Name: files_id_seq; Type: SEQUENCE OWNED BY; Schema: event_abstracts; Owner: indico
--

ALTER SEQUENCE event_abstracts.files_id_seq OWNED BY event_abstracts.files.id;


--
-- Name: proposed_for_tracks; Type: TABLE; Schema: event_abstracts; Owner: indico
--

CREATE TABLE event_abstracts.proposed_for_tracks (
    review_id integer NOT NULL,
    track_id integer NOT NULL
);


ALTER TABLE event_abstracts.proposed_for_tracks OWNER TO indico;

--
-- Name: reviewed_for_tracks; Type: TABLE; Schema: event_abstracts; Owner: indico
--

CREATE TABLE event_abstracts.reviewed_for_tracks (
    abstract_id integer NOT NULL,
    track_id integer NOT NULL
);


ALTER TABLE event_abstracts.reviewed_for_tracks OWNER TO indico;

--
-- Name: submitted_for_tracks; Type: TABLE; Schema: event_abstracts; Owner: indico
--

CREATE TABLE event_abstracts.submitted_for_tracks (
    abstract_id integer NOT NULL,
    track_id integer NOT NULL
);


ALTER TABLE event_abstracts.submitted_for_tracks OWNER TO indico;

--
-- Name: comments; Type: TABLE; Schema: event_editing; Owner: indico
--

CREATE TABLE event_editing.comments (
    id integer NOT NULL,
    revision_id integer NOT NULL,
    user_id integer,
    created_dt timestamp without time zone NOT NULL,
    modified_dt timestamp without time zone,
    is_deleted boolean NOT NULL,
    internal boolean NOT NULL,
    system boolean NOT NULL,
    text text NOT NULL,
    CONSTRAINT ck_comments_system_comment_no_user CHECK (((user_id IS NULL) = system))
);


ALTER TABLE event_editing.comments OWNER TO indico;

--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: event_editing; Owner: indico
--

CREATE SEQUENCE event_editing.comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_editing.comments_id_seq OWNER TO indico;

--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: event_editing; Owner: indico
--

ALTER SEQUENCE event_editing.comments_id_seq OWNED BY event_editing.comments.id;


--
-- Name: editables; Type: TABLE; Schema: event_editing; Owner: indico
--

CREATE TABLE event_editing.editables (
    id integer NOT NULL,
    contribution_id integer NOT NULL,
    type smallint NOT NULL,
    editor_id integer,
    published_revision_id integer,
    is_deleted boolean NOT NULL,
    CONSTRAINT ck_editables_valid_enum_type CHECK ((type = ANY (ARRAY[1, 2, 3])))
);


ALTER TABLE event_editing.editables OWNER TO indico;

--
-- Name: editables_id_seq; Type: SEQUENCE; Schema: event_editing; Owner: indico
--

CREATE SEQUENCE event_editing.editables_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_editing.editables_id_seq OWNER TO indico;

--
-- Name: editables_id_seq; Type: SEQUENCE OWNED BY; Schema: event_editing; Owner: indico
--

ALTER SEQUENCE event_editing.editables_id_seq OWNED BY event_editing.editables.id;


--
-- Name: file_types; Type: TABLE; Schema: event_editing; Owner: indico
--

CREATE TABLE event_editing.file_types (
    id integer NOT NULL,
    event_id integer NOT NULL,
    type smallint NOT NULL,
    name character varying NOT NULL,
    extensions character varying[] NOT NULL,
    allow_multiple_files boolean NOT NULL,
    required boolean NOT NULL,
    publishable boolean NOT NULL,
    filename_template character varying,
    CONSTRAINT ck_file_types_valid_enum_type CHECK ((type = ANY (ARRAY[1, 2, 3])))
);


ALTER TABLE event_editing.file_types OWNER TO indico;

--
-- Name: file_types_id_seq; Type: SEQUENCE; Schema: event_editing; Owner: indico
--

CREATE SEQUENCE event_editing.file_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_editing.file_types_id_seq OWNER TO indico;

--
-- Name: file_types_id_seq; Type: SEQUENCE OWNED BY; Schema: event_editing; Owner: indico
--

ALTER SEQUENCE event_editing.file_types_id_seq OWNED BY event_editing.file_types.id;


--
-- Name: review_condition_file_types; Type: TABLE; Schema: event_editing; Owner: indico
--

CREATE TABLE event_editing.review_condition_file_types (
    review_condition_id integer NOT NULL,
    file_type_id integer NOT NULL
);


ALTER TABLE event_editing.review_condition_file_types OWNER TO indico;

--
-- Name: review_conditions; Type: TABLE; Schema: event_editing; Owner: indico
--

CREATE TABLE event_editing.review_conditions (
    id integer NOT NULL,
    type smallint NOT NULL,
    event_id integer NOT NULL,
    CONSTRAINT ck_review_conditions_valid_enum_type CHECK ((type = ANY (ARRAY[1, 2, 3])))
);


ALTER TABLE event_editing.review_conditions OWNER TO indico;

--
-- Name: review_conditions_id_seq; Type: SEQUENCE; Schema: event_editing; Owner: indico
--

CREATE SEQUENCE event_editing.review_conditions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_editing.review_conditions_id_seq OWNER TO indico;

--
-- Name: review_conditions_id_seq; Type: SEQUENCE OWNED BY; Schema: event_editing; Owner: indico
--

ALTER SEQUENCE event_editing.review_conditions_id_seq OWNED BY event_editing.review_conditions.id;


--
-- Name: revision_files; Type: TABLE; Schema: event_editing; Owner: indico
--

CREATE TABLE event_editing.revision_files (
    revision_id integer NOT NULL,
    file_id integer NOT NULL,
    file_type_id integer
);


ALTER TABLE event_editing.revision_files OWNER TO indico;

--
-- Name: revision_tags; Type: TABLE; Schema: event_editing; Owner: indico
--

CREATE TABLE event_editing.revision_tags (
    revision_id integer NOT NULL,
    tag_id integer NOT NULL
);


ALTER TABLE event_editing.revision_tags OWNER TO indico;

--
-- Name: revisions; Type: TABLE; Schema: event_editing; Owner: indico
--

CREATE TABLE event_editing.revisions (
    id integer NOT NULL,
    editable_id integer NOT NULL,
    user_id integer NOT NULL,
    created_dt timestamp without time zone NOT NULL,
    modified_dt timestamp without time zone,
    type smallint NOT NULL,
    is_undone boolean NOT NULL,
    comment text NOT NULL,
    CONSTRAINT ck_revisions_new_revision_not_undone CHECK (((type <> 1) OR (NOT is_undone))),
    CONSTRAINT ck_revisions_valid_enum_type CHECK ((type = ANY (ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10])))
);


ALTER TABLE event_editing.revisions OWNER TO indico;

--
-- Name: revisions_id_seq; Type: SEQUENCE; Schema: event_editing; Owner: indico
--

CREATE SEQUENCE event_editing.revisions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_editing.revisions_id_seq OWNER TO indico;

--
-- Name: revisions_id_seq; Type: SEQUENCE OWNED BY; Schema: event_editing; Owner: indico
--

ALTER SEQUENCE event_editing.revisions_id_seq OWNED BY event_editing.revisions.id;


--
-- Name: tags; Type: TABLE; Schema: event_editing; Owner: indico
--

CREATE TABLE event_editing.tags (
    id integer NOT NULL,
    event_id integer NOT NULL,
    title character varying NOT NULL,
    code character varying NOT NULL,
    color character varying NOT NULL,
    system boolean NOT NULL
);


ALTER TABLE event_editing.tags OWNER TO indico;

--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: event_editing; Owner: indico
--

CREATE SEQUENCE event_editing.tags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_editing.tags_id_seq OWNER TO indico;

--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: event_editing; Owner: indico
--

ALTER SEQUENCE event_editing.tags_id_seq OWNED BY event_editing.tags.id;


--
-- Name: competences; Type: TABLE; Schema: event_paper_reviewing; Owner: indico
--

CREATE TABLE event_paper_reviewing.competences (
    id integer NOT NULL,
    user_id integer NOT NULL,
    event_id integer NOT NULL,
    competences character varying[] NOT NULL
);


ALTER TABLE event_paper_reviewing.competences OWNER TO indico;

--
-- Name: competences_id_seq; Type: SEQUENCE; Schema: event_paper_reviewing; Owner: indico
--

CREATE SEQUENCE event_paper_reviewing.competences_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_paper_reviewing.competences_id_seq OWNER TO indico;

--
-- Name: competences_id_seq; Type: SEQUENCE OWNED BY; Schema: event_paper_reviewing; Owner: indico
--

ALTER SEQUENCE event_paper_reviewing.competences_id_seq OWNED BY event_paper_reviewing.competences.id;


--
-- Name: content_reviewers; Type: TABLE; Schema: event_paper_reviewing; Owner: indico
--

CREATE TABLE event_paper_reviewing.content_reviewers (
    contribution_id integer NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE event_paper_reviewing.content_reviewers OWNER TO indico;

--
-- Name: files; Type: TABLE; Schema: event_paper_reviewing; Owner: indico
--

CREATE TABLE event_paper_reviewing.files (
    id integer NOT NULL,
    contribution_id integer NOT NULL,
    revision_id integer,
    filename character varying NOT NULL,
    content_type character varying NOT NULL,
    size bigint NOT NULL,
    md5 character varying NOT NULL,
    storage_backend character varying NOT NULL,
    storage_file_id character varying NOT NULL
);


ALTER TABLE event_paper_reviewing.files OWNER TO indico;

--
-- Name: files_id_seq; Type: SEQUENCE; Schema: event_paper_reviewing; Owner: indico
--

CREATE SEQUENCE event_paper_reviewing.files_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_paper_reviewing.files_id_seq OWNER TO indico;

--
-- Name: files_id_seq; Type: SEQUENCE OWNED BY; Schema: event_paper_reviewing; Owner: indico
--

ALTER SEQUENCE event_paper_reviewing.files_id_seq OWNED BY event_paper_reviewing.files.id;


--
-- Name: judges; Type: TABLE; Schema: event_paper_reviewing; Owner: indico
--

CREATE TABLE event_paper_reviewing.judges (
    contribution_id integer NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE event_paper_reviewing.judges OWNER TO indico;

--
-- Name: layout_reviewers; Type: TABLE; Schema: event_paper_reviewing; Owner: indico
--

CREATE TABLE event_paper_reviewing.layout_reviewers (
    contribution_id integer NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE event_paper_reviewing.layout_reviewers OWNER TO indico;

--
-- Name: review_comments; Type: TABLE; Schema: event_paper_reviewing; Owner: indico
--

CREATE TABLE event_paper_reviewing.review_comments (
    id integer NOT NULL,
    user_id integer NOT NULL,
    text text NOT NULL,
    modified_by_id integer,
    created_dt timestamp without time zone NOT NULL,
    modified_dt timestamp without time zone,
    is_deleted boolean NOT NULL,
    revision_id integer NOT NULL,
    visibility smallint NOT NULL,
    CONSTRAINT ck_review_comments_valid_enum_visibility CHECK ((visibility = ANY (ARRAY[1, 2, 3, 4])))
);


ALTER TABLE event_paper_reviewing.review_comments OWNER TO indico;

--
-- Name: review_comments_id_seq; Type: SEQUENCE; Schema: event_paper_reviewing; Owner: indico
--

CREATE SEQUENCE event_paper_reviewing.review_comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_paper_reviewing.review_comments_id_seq OWNER TO indico;

--
-- Name: review_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: event_paper_reviewing; Owner: indico
--

ALTER SEQUENCE event_paper_reviewing.review_comments_id_seq OWNED BY event_paper_reviewing.review_comments.id;


--
-- Name: review_questions; Type: TABLE; Schema: event_paper_reviewing; Owner: indico
--

CREATE TABLE event_paper_reviewing.review_questions (
    type smallint NOT NULL,
    id integer NOT NULL,
    event_id integer NOT NULL,
    field_type character varying NOT NULL,
    title text NOT NULL,
    no_score boolean NOT NULL,
    "position" integer NOT NULL,
    is_deleted boolean NOT NULL,
    is_required boolean NOT NULL,
    field_data jsonb NOT NULL,
    description text NOT NULL,
    CONSTRAINT ck_review_questions_valid_enum_type CHECK ((type = ANY (ARRAY[1, 2])))
);


ALTER TABLE event_paper_reviewing.review_questions OWNER TO indico;

--
-- Name: review_questions_id_seq; Type: SEQUENCE; Schema: event_paper_reviewing; Owner: indico
--

CREATE SEQUENCE event_paper_reviewing.review_questions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_paper_reviewing.review_questions_id_seq OWNER TO indico;

--
-- Name: review_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: event_paper_reviewing; Owner: indico
--

ALTER SEQUENCE event_paper_reviewing.review_questions_id_seq OWNED BY event_paper_reviewing.review_questions.id;


--
-- Name: review_ratings; Type: TABLE; Schema: event_paper_reviewing; Owner: indico
--

CREATE TABLE event_paper_reviewing.review_ratings (
    id integer NOT NULL,
    question_id integer NOT NULL,
    review_id integer NOT NULL,
    value jsonb NOT NULL
);


ALTER TABLE event_paper_reviewing.review_ratings OWNER TO indico;

--
-- Name: review_ratings_id_seq; Type: SEQUENCE; Schema: event_paper_reviewing; Owner: indico
--

CREATE SEQUENCE event_paper_reviewing.review_ratings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_paper_reviewing.review_ratings_id_seq OWNER TO indico;

--
-- Name: review_ratings_id_seq; Type: SEQUENCE OWNED BY; Schema: event_paper_reviewing; Owner: indico
--

ALTER SEQUENCE event_paper_reviewing.review_ratings_id_seq OWNED BY event_paper_reviewing.review_ratings.id;


--
-- Name: reviews; Type: TABLE; Schema: event_paper_reviewing; Owner: indico
--

CREATE TABLE event_paper_reviewing.reviews (
    id integer NOT NULL,
    revision_id integer NOT NULL,
    user_id integer NOT NULL,
    created_dt timestamp without time zone NOT NULL,
    modified_dt timestamp without time zone,
    comment text NOT NULL,
    type smallint NOT NULL,
    proposed_action smallint NOT NULL,
    CONSTRAINT ck_reviews_valid_enum_proposed_action CHECK ((proposed_action = ANY (ARRAY[1, 2, 3]))),
    CONSTRAINT ck_reviews_valid_enum_type CHECK ((type = ANY (ARRAY[1, 2])))
);


ALTER TABLE event_paper_reviewing.reviews OWNER TO indico;

--
-- Name: reviews_id_seq; Type: SEQUENCE; Schema: event_paper_reviewing; Owner: indico
--

CREATE SEQUENCE event_paper_reviewing.reviews_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_paper_reviewing.reviews_id_seq OWNER TO indico;

--
-- Name: reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: event_paper_reviewing; Owner: indico
--

ALTER SEQUENCE event_paper_reviewing.reviews_id_seq OWNED BY event_paper_reviewing.reviews.id;


--
-- Name: revisions; Type: TABLE; Schema: event_paper_reviewing; Owner: indico
--

CREATE TABLE event_paper_reviewing.revisions (
    id integer NOT NULL,
    state smallint NOT NULL,
    contribution_id integer NOT NULL,
    submitter_id integer NOT NULL,
    submitted_dt timestamp without time zone NOT NULL,
    judge_id integer,
    judgment_dt timestamp without time zone,
    judgment_comment text NOT NULL,
    CONSTRAINT ck_revisions_judge_if_judged CHECK (((state = ANY (ARRAY[2, 3, 4])) = (judge_id IS NOT NULL))),
    CONSTRAINT ck_revisions_judgment_dt_if_judged CHECK (((state = ANY (ARRAY[2, 3, 4])) = (judgment_dt IS NOT NULL))),
    CONSTRAINT ck_revisions_valid_enum_state CHECK ((state = ANY (ARRAY[1, 2, 3, 4])))
);


ALTER TABLE event_paper_reviewing.revisions OWNER TO indico;

--
-- Name: revisions_id_seq; Type: SEQUENCE; Schema: event_paper_reviewing; Owner: indico
--

CREATE SEQUENCE event_paper_reviewing.revisions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_paper_reviewing.revisions_id_seq OWNER TO indico;

--
-- Name: revisions_id_seq; Type: SEQUENCE OWNED BY; Schema: event_paper_reviewing; Owner: indico
--

ALTER SEQUENCE event_paper_reviewing.revisions_id_seq OWNED BY event_paper_reviewing.revisions.id;


--
-- Name: templates; Type: TABLE; Schema: event_paper_reviewing; Owner: indico
--

CREATE TABLE event_paper_reviewing.templates (
    id integer NOT NULL,
    event_id integer NOT NULL,
    name character varying NOT NULL,
    description text NOT NULL,
    filename character varying NOT NULL,
    content_type character varying NOT NULL,
    size bigint NOT NULL,
    md5 character varying NOT NULL,
    storage_backend character varying NOT NULL,
    storage_file_id character varying NOT NULL
);


ALTER TABLE event_paper_reviewing.templates OWNER TO indico;

--
-- Name: templates_id_seq; Type: SEQUENCE; Schema: event_paper_reviewing; Owner: indico
--

CREATE SEQUENCE event_paper_reviewing.templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_paper_reviewing.templates_id_seq OWNER TO indico;

--
-- Name: templates_id_seq; Type: SEQUENCE OWNED BY; Schema: event_paper_reviewing; Owner: indico
--

ALTER SEQUENCE event_paper_reviewing.templates_id_seq OWNED BY event_paper_reviewing.templates.id;


--
-- Name: form_field_data; Type: TABLE; Schema: event_registration; Owner: indico
--

CREATE TABLE event_registration.form_field_data (
    id integer NOT NULL,
    field_id integer NOT NULL,
    versioned_data jsonb NOT NULL
);


ALTER TABLE event_registration.form_field_data OWNER TO indico;

--
-- Name: form_field_data_id_seq; Type: SEQUENCE; Schema: event_registration; Owner: indico
--

CREATE SEQUENCE event_registration.form_field_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_registration.form_field_data_id_seq OWNER TO indico;

--
-- Name: form_field_data_id_seq; Type: SEQUENCE OWNED BY; Schema: event_registration; Owner: indico
--

ALTER SEQUENCE event_registration.form_field_data_id_seq OWNED BY event_registration.form_field_data.id;


--
-- Name: form_items; Type: TABLE; Schema: event_registration; Owner: indico
--

CREATE TABLE event_registration.form_items (
    id integer NOT NULL,
    registration_form_id integer NOT NULL,
    type smallint NOT NULL,
    personal_data_type smallint,
    parent_id integer,
    "position" integer NOT NULL,
    title character varying NOT NULL,
    description character varying NOT NULL,
    is_enabled boolean NOT NULL,
    is_deleted boolean NOT NULL,
    is_required boolean NOT NULL,
    is_manager_only boolean NOT NULL,
    input_type character varying,
    data jsonb NOT NULL,
    retention_period interval,
    is_purged boolean NOT NULL,
    current_data_id integer,
    CONSTRAINT ck_form_items_current_data_id_only_field CHECK (((current_data_id IS NULL) OR (type = ANY (ARRAY[2, 5])))),
    CONSTRAINT ck_form_items_pd_field_enabled CHECK ((is_enabled OR (type <> 5) OR (personal_data_type <> ALL (ARRAY[1, 2, 3])))),
    CONSTRAINT ck_form_items_pd_field_required CHECK ((is_required OR (type <> 5) OR (personal_data_type <> ALL (ARRAY[1, 2, 3])))),
    CONSTRAINT ck_form_items_pd_field_type CHECK (((type <> 5) = (personal_data_type IS NULL))),
    CONSTRAINT ck_form_items_pd_not_deleted CHECK (((NOT is_deleted) OR (type <> ALL (ARRAY[4, 5])))),
    CONSTRAINT ck_form_items_pd_section_enabled CHECK ((is_enabled OR (type <> 4))),
    CONSTRAINT ck_form_items_retention_period_allowed_fields CHECK (((retention_period IS NULL) OR (type = 2) OR ((type = 5) AND (personal_data_type <> ALL (ARRAY[1, 2, 3]))))),
    CONSTRAINT ck_form_items_top_level_sections CHECK (((type = ANY (ARRAY[1, 4])) = (parent_id IS NULL))),
    CONSTRAINT ck_form_items_valid_enum_personal_data_type CHECK ((personal_data_type = ANY (ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]))),
    CONSTRAINT ck_form_items_valid_enum_type CHECK ((type = ANY (ARRAY[1, 2, 3, 4, 5]))),
    CONSTRAINT ck_form_items_valid_input CHECK (((input_type IS NULL) = (type <> ALL (ARRAY[2, 5])))),
    CONSTRAINT ck_form_items_valid_manager_only CHECK (((NOT is_manager_only) OR (type = 1)))
);


ALTER TABLE event_registration.form_items OWNER TO indico;

--
-- Name: form_items_id_seq; Type: SEQUENCE; Schema: event_registration; Owner: indico
--

CREATE SEQUENCE event_registration.form_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_registration.form_items_id_seq OWNER TO indico;

--
-- Name: form_items_id_seq; Type: SEQUENCE OWNED BY; Schema: event_registration; Owner: indico
--

ALTER SEQUENCE event_registration.form_items_id_seq OWNED BY event_registration.form_items.id;


--
-- Name: forms; Type: TABLE; Schema: event_registration; Owner: indico
--

CREATE TABLE event_registration.forms (
    id integer NOT NULL,
    event_id integer NOT NULL,
    title character varying NOT NULL,
    is_participation boolean NOT NULL,
    introduction text NOT NULL,
    contact_info character varying NOT NULL,
    start_dt timestamp without time zone,
    end_dt timestamp without time zone,
    modification_mode smallint NOT NULL,
    modification_end_dt timestamp without time zone,
    is_deleted boolean NOT NULL,
    require_login boolean NOT NULL,
    require_user boolean NOT NULL,
    require_captcha boolean NOT NULL,
    registration_limit integer,
    publish_registrations_public smallint NOT NULL,
    publish_registrations_participants smallint NOT NULL,
    publish_registrations_duration interval,
    publish_registration_count boolean NOT NULL,
    publish_checkin_enabled boolean NOT NULL,
    moderation_enabled boolean NOT NULL,
    private boolean NOT NULL,
    uuid uuid NOT NULL,
    base_price numeric(11,2) NOT NULL,
    currency character varying NOT NULL,
    notification_sender_address character varying,
    message_pending text NOT NULL,
    message_unpaid text NOT NULL,
    message_complete text NOT NULL,
    attach_ical boolean NOT NULL,
    manager_notifications_enabled boolean NOT NULL,
    manager_notification_recipients character varying[] NOT NULL,
    tickets_enabled boolean NOT NULL,
    ticket_google_wallet boolean NOT NULL,
    ticket_apple_wallet boolean NOT NULL,
    ticket_on_email boolean NOT NULL,
    ticket_on_event_page boolean NOT NULL,
    ticket_on_summary_page boolean NOT NULL,
    tickets_for_accompanying_persons boolean NOT NULL,
    ticket_template_id integer,
    retention_period interval,
    is_purged boolean NOT NULL,
    require_privacy_policy_agreement boolean NOT NULL,
    CONSTRAINT ck_forms_publish_registrations_more_restrictive_to_public CHECK ((publish_registrations_public <= publish_registrations_participants)),
    CONSTRAINT ck_forms_valid_enum_modification_mode CHECK ((modification_mode = ANY (ARRAY[1, 2, 3, 4]))),
    CONSTRAINT ck_forms_valid_enum_publish_registrations_participants CHECK ((publish_registrations_participants = ANY (ARRAY[0, 1, 2]))),
    CONSTRAINT ck_forms_valid_enum_publish_registrations_public CHECK ((publish_registrations_public = ANY (ARRAY[0, 1, 2])))
);


ALTER TABLE event_registration.forms OWNER TO indico;

--
-- Name: forms_id_seq; Type: SEQUENCE; Schema: event_registration; Owner: indico
--

CREATE SEQUENCE event_registration.forms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_registration.forms_id_seq OWNER TO indico;

--
-- Name: forms_id_seq; Type: SEQUENCE OWNED BY; Schema: event_registration; Owner: indico
--

ALTER SEQUENCE event_registration.forms_id_seq OWNED BY event_registration.forms.id;


--
-- Name: invitations; Type: TABLE; Schema: event_registration; Owner: indico
--

CREATE TABLE event_registration.invitations (
    id integer NOT NULL,
    uuid uuid NOT NULL,
    registration_form_id integer NOT NULL,
    registration_id integer,
    state smallint NOT NULL,
    skip_moderation boolean NOT NULL,
    skip_access_check boolean NOT NULL,
    email character varying NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    affiliation character varying NOT NULL,
    CONSTRAINT ck_invitations_registration_state CHECK (((state = 1) OR (registration_id IS NULL))),
    CONSTRAINT ck_invitations_valid_enum_state CHECK ((state = ANY (ARRAY[0, 1, 2])))
);


ALTER TABLE event_registration.invitations OWNER TO indico;

--
-- Name: invitations_id_seq; Type: SEQUENCE; Schema: event_registration; Owner: indico
--

CREATE SEQUENCE event_registration.invitations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_registration.invitations_id_seq OWNER TO indico;

--
-- Name: invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: event_registration; Owner: indico
--

ALTER SEQUENCE event_registration.invitations_id_seq OWNED BY event_registration.invitations.id;


--
-- Name: legacy_registration_map; Type: TABLE; Schema: event_registration; Owner: indico
--

CREATE TABLE event_registration.legacy_registration_map (
    event_id integer NOT NULL,
    legacy_registrant_id integer NOT NULL,
    legacy_registrant_key character varying NOT NULL,
    registration_id integer NOT NULL
);


ALTER TABLE event_registration.legacy_registration_map OWNER TO indico;

--
-- Name: receipt_files; Type: TABLE; Schema: event_registration; Owner: indico
--

CREATE TABLE event_registration.receipt_files (
    file_id integer NOT NULL,
    registration_id integer NOT NULL,
    template_id integer NOT NULL,
    template_params jsonb NOT NULL,
    is_published boolean NOT NULL,
    is_deleted boolean NOT NULL
);


ALTER TABLE event_registration.receipt_files OWNER TO indico;

--
-- Name: registration_data; Type: TABLE; Schema: event_registration; Owner: indico
--

CREATE TABLE event_registration.registration_data (
    registration_id integer NOT NULL,
    field_data_id integer NOT NULL,
    data jsonb NOT NULL,
    filename character varying,
    content_type character varying,
    size bigint,
    md5 character varying,
    storage_backend character varying,
    storage_file_id character varying
);


ALTER TABLE event_registration.registration_data OWNER TO indico;

--
-- Name: registration_tags; Type: TABLE; Schema: event_registration; Owner: indico
--

CREATE TABLE event_registration.registration_tags (
    registration_id integer NOT NULL,
    registration_tag_id integer NOT NULL
);


ALTER TABLE event_registration.registration_tags OWNER TO indico;

--
-- Name: registrations; Type: TABLE; Schema: event_registration; Owner: indico
--

CREATE TABLE event_registration.registrations (
    id integer NOT NULL,
    uuid uuid NOT NULL,
    friendly_id integer NOT NULL,
    event_id integer NOT NULL,
    registration_form_id integer NOT NULL,
    user_id integer,
    transaction_id integer,
    state smallint NOT NULL,
    base_price numeric(11,2) NOT NULL,
    price_adjustment numeric(11,2) NOT NULL,
    currency character varying NOT NULL,
    submitted_dt timestamp without time zone NOT NULL,
    email character varying NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    is_deleted boolean NOT NULL,
    ticket_uuid uuid NOT NULL,
    checked_in boolean NOT NULL,
    checked_in_dt timestamp without time zone,
    rejection_reason character varying NOT NULL,
    consent_to_publish smallint NOT NULL,
    participant_hidden boolean NOT NULL,
    created_by_manager boolean NOT NULL,
    modification_end_dt timestamp without time zone,
    apple_wallet_serial character varying NOT NULL,
    CONSTRAINT ck_registrations_lowercase_email CHECK (((email)::text = lower((email)::text))),
    CONSTRAINT ck_registrations_valid_enum_consent_to_publish CHECK ((consent_to_publish = ANY (ARRAY[0, 1, 2]))),
    CONSTRAINT ck_registrations_valid_enum_state CHECK ((state = ANY (ARRAY[1, 2, 3, 4, 5])))
);


ALTER TABLE event_registration.registrations OWNER TO indico;

--
-- Name: registrations_id_seq; Type: SEQUENCE; Schema: event_registration; Owner: indico
--

CREATE SEQUENCE event_registration.registrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_registration.registrations_id_seq OWNER TO indico;

--
-- Name: registrations_id_seq; Type: SEQUENCE OWNED BY; Schema: event_registration; Owner: indico
--

ALTER SEQUENCE event_registration.registrations_id_seq OWNED BY event_registration.registrations.id;


--
-- Name: tags; Type: TABLE; Schema: event_registration; Owner: indico
--

CREATE TABLE event_registration.tags (
    id integer NOT NULL,
    event_id integer NOT NULL,
    title character varying NOT NULL,
    color character varying NOT NULL
);


ALTER TABLE event_registration.tags OWNER TO indico;

--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: event_registration; Owner: indico
--

CREATE SEQUENCE event_registration.tags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_registration.tags_id_seq OWNER TO indico;

--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: event_registration; Owner: indico
--

ALTER SEQUENCE event_registration.tags_id_seq OWNED BY event_registration.tags.id;


--
-- Name: anonymous_submissions; Type: TABLE; Schema: event_surveys; Owner: indico
--

CREATE TABLE event_surveys.anonymous_submissions (
    survey_id integer NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE event_surveys.anonymous_submissions OWNER TO indico;

--
-- Name: answers; Type: TABLE; Schema: event_surveys; Owner: indico
--

CREATE TABLE event_surveys.answers (
    submission_id integer NOT NULL,
    question_id integer NOT NULL,
    data jsonb NOT NULL
);


ALTER TABLE event_surveys.answers OWNER TO indico;

--
-- Name: items; Type: TABLE; Schema: event_surveys; Owner: indico
--

CREATE TABLE event_surveys.items (
    id integer NOT NULL,
    survey_id integer NOT NULL,
    parent_id integer,
    "position" integer NOT NULL,
    type smallint NOT NULL,
    title character varying,
    display_as_section boolean,
    is_required boolean,
    field_type character varying,
    field_data jsonb NOT NULL,
    description text NOT NULL,
    CONSTRAINT ck_items_valid_enum_type CHECK ((type = ANY (ARRAY[1, 2, 3]))),
    CONSTRAINT ck_items_valid_question CHECK (((type <> 1) OR ((title IS NOT NULL) AND (is_required IS NOT NULL) AND (field_type IS NOT NULL) AND (parent_id IS NOT NULL) AND (display_as_section IS NULL)))),
    CONSTRAINT ck_items_valid_section CHECK (((type <> 2) OR ((title IS NOT NULL) AND (is_required IS NULL) AND (field_type IS NULL) AND ((field_data)::text = '{}'::text) AND (parent_id IS NULL) AND (display_as_section IS NOT NULL)))),
    CONSTRAINT ck_items_valid_text CHECK (((type <> 3) OR ((title IS NULL) AND (is_required IS NULL) AND (field_type IS NULL) AND ((field_data)::text = '{}'::text) AND (parent_id IS NOT NULL) AND (display_as_section IS NULL))))
);


ALTER TABLE event_surveys.items OWNER TO indico;

--
-- Name: items_id_seq; Type: SEQUENCE; Schema: event_surveys; Owner: indico
--

CREATE SEQUENCE event_surveys.items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_surveys.items_id_seq OWNER TO indico;

--
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: event_surveys; Owner: indico
--

ALTER SEQUENCE event_surveys.items_id_seq OWNED BY event_surveys.items.id;


--
-- Name: submissions; Type: TABLE; Schema: event_surveys; Owner: indico
--

CREATE TABLE event_surveys.submissions (
    id integer NOT NULL,
    friendly_id integer NOT NULL,
    survey_id integer NOT NULL,
    user_id integer,
    submitted_dt timestamp without time zone,
    is_anonymous boolean NOT NULL,
    is_submitted boolean NOT NULL,
    pending_answers jsonb,
    CONSTRAINT ck_submissions_anonymous_or_user CHECK ((is_anonymous OR (user_id IS NOT NULL))),
    CONSTRAINT ck_submissions_dt_set_when_submitted CHECK ((is_submitted = (submitted_dt IS NOT NULL))),
    CONSTRAINT ck_submissions_submitted_and_anonymous_no_user CHECK (((is_submitted AND is_anonymous) = (user_id IS NULL)))
);


ALTER TABLE event_surveys.submissions OWNER TO indico;

--
-- Name: submissions_id_seq; Type: SEQUENCE; Schema: event_surveys; Owner: indico
--

CREATE SEQUENCE event_surveys.submissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_surveys.submissions_id_seq OWNER TO indico;

--
-- Name: submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: event_surveys; Owner: indico
--

ALTER SEQUENCE event_surveys.submissions_id_seq OWNED BY event_surveys.submissions.id;


--
-- Name: surveys; Type: TABLE; Schema: event_surveys; Owner: indico
--

CREATE TABLE event_surveys.surveys (
    id integer NOT NULL,
    event_id integer NOT NULL,
    title character varying NOT NULL,
    uuid uuid NOT NULL,
    introduction text NOT NULL,
    anonymous boolean NOT NULL,
    require_user boolean NOT NULL,
    private boolean NOT NULL,
    submission_limit integer,
    start_dt timestamp without time zone,
    end_dt timestamp without time zone,
    is_deleted boolean NOT NULL,
    start_notification_sent boolean NOT NULL,
    notifications_enabled boolean NOT NULL,
    notify_participants boolean NOT NULL,
    start_notification_emails character varying[] NOT NULL,
    new_submission_emails character varying[] NOT NULL,
    partial_completion boolean NOT NULL,
    last_friendly_submission_id integer NOT NULL,
    CONSTRAINT ck_surveys_valid_anonymous_user CHECK ((anonymous OR require_user))
);


ALTER TABLE event_surveys.surveys OWNER TO indico;

--
-- Name: surveys_id_seq; Type: SEQUENCE; Schema: event_surveys; Owner: indico
--

CREATE SEQUENCE event_surveys.surveys_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_surveys.surveys_id_seq OWNER TO indico;

--
-- Name: surveys_id_seq; Type: SEQUENCE OWNED BY; Schema: event_surveys; Owner: indico
--

ALTER SEQUENCE event_surveys.surveys_id_seq OWNED BY event_surveys.surveys.id;


--
-- Name: agreements; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.agreements (
    id integer NOT NULL,
    uuid character varying NOT NULL,
    event_id integer NOT NULL,
    type character varying NOT NULL,
    identifier character varying NOT NULL,
    person_email character varying,
    person_name character varying NOT NULL,
    state smallint NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    user_id integer,
    signed_dt timestamp without time zone,
    signed_from_ip character varying,
    reason character varying,
    attachment bytea,
    attachment_filename character varying,
    data jsonb,
    CONSTRAINT ck_agreements_valid_enum_state CHECK ((state = ANY (ARRAY[0, 1, 2, 3, 4])))
);


ALTER TABLE events.agreements OWNER TO indico;

--
-- Name: agreements_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.agreements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.agreements_id_seq OWNER TO indico;

--
-- Name: agreements_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.agreements_id_seq OWNED BY events.agreements.id;


--
-- Name: breaks; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.breaks (
    id integer NOT NULL,
    title character varying NOT NULL,
    duration interval NOT NULL,
    description text NOT NULL,
    text_color character varying NOT NULL,
    background_color character varying NOT NULL,
    inherit_location boolean NOT NULL,
    room_id integer,
    venue_id integer,
    venue_name character varying NOT NULL,
    room_name character varying NOT NULL,
    address text NOT NULL,
    CONSTRAINT ck_breaks_both_or_no_colors CHECK ((((text_color)::text = ''::text) = ((background_color)::text = ''::text))),
    CONSTRAINT ck_breaks_colors_not_empty CHECK ((((text_color)::text <> ''::text) AND ((background_color)::text <> ''::text))),
    CONSTRAINT ck_breaks_duration_no_seconds CHECK ((date_trunc('minute'::text, duration) = duration)),
    CONSTRAINT ck_breaks_inherited_location CHECK (((NOT inherit_location) OR ((venue_id IS NULL) AND (room_id IS NULL) AND ((venue_name)::text = ''::text) AND ((room_name)::text = ''::text) AND (address = ''::text)))),
    CONSTRAINT ck_breaks_no_custom_location_if_room CHECK (((room_id IS NULL) OR (((venue_name)::text = ''::text) AND ((room_name)::text = ''::text)))),
    CONSTRAINT ck_breaks_no_venue_name_if_venue_id CHECK (((venue_id IS NULL) OR ((venue_name)::text = ''::text))),
    CONSTRAINT ck_breaks_nonnegative_duration CHECK ((duration >= '00:00:00'::interval)),
    CONSTRAINT ck_breaks_venue_id_if_room_id CHECK (((room_id IS NULL) OR (venue_id IS NOT NULL)))
);


ALTER TABLE events.breaks OWNER TO indico;

--
-- Name: breaks_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.breaks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.breaks_id_seq OWNER TO indico;

--
-- Name: breaks_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.breaks_id_seq OWNED BY events.breaks.id;


--
-- Name: contribution_field_values; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.contribution_field_values (
    data jsonb NOT NULL,
    contribution_id integer NOT NULL,
    contribution_field_id integer NOT NULL
);


ALTER TABLE events.contribution_field_values OWNER TO indico;

--
-- Name: contribution_fields; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.contribution_fields (
    id integer NOT NULL,
    event_id integer NOT NULL,
    legacy_id character varying,
    "position" integer NOT NULL,
    title character varying NOT NULL,
    description text NOT NULL,
    is_required boolean NOT NULL,
    is_active boolean NOT NULL,
    is_user_editable boolean NOT NULL,
    visibility smallint NOT NULL,
    field_type character varying,
    field_data jsonb NOT NULL,
    CONSTRAINT ck_contribution_fields_valid_enum_visibility CHECK ((visibility = ANY (ARRAY[1, 2, 3])))
);


ALTER TABLE events.contribution_fields OWNER TO indico;

--
-- Name: contribution_fields_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.contribution_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.contribution_fields_id_seq OWNER TO indico;

--
-- Name: contribution_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.contribution_fields_id_seq OWNED BY events.contribution_fields.id;


--
-- Name: contribution_person_links; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.contribution_person_links (
    contribution_id integer NOT NULL,
    is_speaker boolean NOT NULL,
    author_type smallint NOT NULL,
    id integer NOT NULL,
    person_id integer NOT NULL,
    first_name character varying,
    last_name character varying,
    title smallint,
    affiliation_id integer,
    affiliation character varying,
    address text,
    phone character varying,
    display_order integer NOT NULL,
    CONSTRAINT ck_contribution_person_links_valid_enum_author_type CHECK ((author_type = ANY (ARRAY[0, 1, 2]))),
    CONSTRAINT ck_contribution_person_links_valid_enum_title CHECK ((title = ANY (ARRAY[0, 1, 2, 3, 4, 5, 6])))
);


ALTER TABLE events.contribution_person_links OWNER TO indico;

--
-- Name: contribution_person_links_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.contribution_person_links_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.contribution_person_links_id_seq OWNER TO indico;

--
-- Name: contribution_person_links_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.contribution_person_links_id_seq OWNED BY events.contribution_person_links.id;


--
-- Name: contribution_principals; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.contribution_principals (
    read_access boolean NOT NULL,
    full_access boolean NOT NULL,
    permissions character varying[] NOT NULL,
    id integer NOT NULL,
    contribution_id integer NOT NULL,
    type smallint NOT NULL,
    user_id integer,
    local_group_id integer,
    mp_group_provider character varying,
    mp_group_name character varying,
    email character varying,
    event_role_id integer,
    category_role_id integer,
    registration_form_id integer,
    CONSTRAINT ck_contribution_principals_has_privs CHECK ((read_access OR full_access OR (array_length(permissions, 1) IS NOT NULL))),
    CONSTRAINT ck_contribution_principals_lowercase_email CHECK (((email IS NULL) OR ((email)::text = lower((email)::text)))),
    CONSTRAINT ck_contribution_principals_registration_form_read_only CHECK (((type <> 8) OR ((NOT full_access) AND (array_length(permissions, 1) IS NULL)))),
    CONSTRAINT ck_contribution_principals_valid_category_role CHECK (((type <> 7) OR ((email IS NULL) AND (event_role_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NULL) AND (category_role_id IS NOT NULL)))),
    CONSTRAINT ck_contribution_principals_valid_email CHECK (((type <> 4) OR ((category_role_id IS NULL) AND (event_role_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NULL) AND (email IS NOT NULL)))),
    CONSTRAINT ck_contribution_principals_valid_enum_type CHECK ((type = ANY (ARRAY[1, 2, 3, 4, 6, 7, 8]))),
    CONSTRAINT ck_contribution_principals_valid_event_role CHECK (((type <> 6) OR ((category_role_id IS NULL) AND (email IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NULL) AND (event_role_id IS NOT NULL)))),
    CONSTRAINT ck_contribution_principals_valid_local_group CHECK (((type <> 2) OR ((category_role_id IS NULL) AND (email IS NULL) AND (event_role_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NULL) AND (local_group_id IS NOT NULL)))),
    CONSTRAINT ck_contribution_principals_valid_multipass_group CHECK (((type <> 3) OR ((category_role_id IS NULL) AND (email IS NULL) AND (event_role_id IS NULL) AND (local_group_id IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NULL) AND (mp_group_name IS NOT NULL) AND (mp_group_provider IS NOT NULL)))),
    CONSTRAINT ck_contribution_principals_valid_registration_form CHECK (((type <> 8) OR ((category_role_id IS NULL) AND (email IS NULL) AND (event_role_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (user_id IS NULL) AND (registration_form_id IS NOT NULL)))),
    CONSTRAINT ck_contribution_principals_valid_user CHECK (((type <> 1) OR ((category_role_id IS NULL) AND (email IS NULL) AND (event_role_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NOT NULL))))
);


ALTER TABLE events.contribution_principals OWNER TO indico;

--
-- Name: contribution_principals_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.contribution_principals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.contribution_principals_id_seq OWNER TO indico;

--
-- Name: contribution_principals_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.contribution_principals_id_seq OWNED BY events.contribution_principals.id;


--
-- Name: contribution_references; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.contribution_references (
    id integer NOT NULL,
    value character varying NOT NULL,
    contribution_id integer NOT NULL,
    reference_type_id integer NOT NULL
);


ALTER TABLE events.contribution_references OWNER TO indico;

--
-- Name: contribution_references_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.contribution_references_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.contribution_references_id_seq OWNER TO indico;

--
-- Name: contribution_references_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.contribution_references_id_seq OWNED BY events.contribution_references.id;


--
-- Name: contribution_types; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.contribution_types (
    id integer NOT NULL,
    event_id integer NOT NULL,
    name character varying NOT NULL,
    description text NOT NULL,
    is_private boolean NOT NULL
);


ALTER TABLE events.contribution_types OWNER TO indico;

--
-- Name: contribution_types_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.contribution_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.contribution_types_id_seq OWNER TO indico;

--
-- Name: contribution_types_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.contribution_types_id_seq OWNED BY events.contribution_types.id;


--
-- Name: contributions; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.contributions (
    id integer NOT NULL,
    friendly_id integer NOT NULL,
    event_id integer NOT NULL,
    session_id integer,
    session_block_id integer,
    track_id integer,
    abstract_id integer,
    type_id integer,
    code character varying NOT NULL,
    duration interval NOT NULL,
    board_number character varying NOT NULL,
    keywords character varying[] NOT NULL,
    is_deleted boolean NOT NULL,
    last_friendly_subcontribution_id integer NOT NULL,
    description text NOT NULL,
    title character varying NOT NULL,
    render_mode smallint NOT NULL,
    protection_mode smallint NOT NULL,
    inherit_location boolean NOT NULL,
    room_id integer,
    venue_id integer,
    venue_name character varying NOT NULL,
    room_name character varying NOT NULL,
    address text NOT NULL,
    CONSTRAINT ck_contributions_duration_no_seconds CHECK ((date_trunc('minute'::text, duration) = duration)),
    CONSTRAINT ck_contributions_inherited_location CHECK (((NOT inherit_location) OR ((venue_id IS NULL) AND (room_id IS NULL) AND ((venue_name)::text = ''::text) AND ((room_name)::text = ''::text) AND (address = ''::text)))),
    CONSTRAINT ck_contributions_no_custom_location_if_room CHECK (((room_id IS NULL) OR (((venue_name)::text = ''::text) AND ((room_name)::text = ''::text)))),
    CONSTRAINT ck_contributions_no_venue_name_if_venue_id CHECK (((venue_id IS NULL) OR ((venue_name)::text = ''::text))),
    CONSTRAINT ck_contributions_positive_duration CHECK ((duration > '00:00:00'::interval)),
    CONSTRAINT ck_contributions_session_block_if_session CHECK (((session_block_id IS NULL) OR (session_id IS NOT NULL))),
    CONSTRAINT ck_contributions_valid_enum_protection_mode CHECK ((protection_mode = ANY (ARRAY[0, 1, 2]))),
    CONSTRAINT ck_contributions_valid_enum_render_mode CHECK ((render_mode = ANY (ARRAY[1, 2, 3]))),
    CONSTRAINT ck_contributions_valid_title CHECK (((title)::text <> ''::text)),
    CONSTRAINT ck_contributions_venue_id_if_room_id CHECK (((room_id IS NULL) OR (venue_id IS NOT NULL)))
);


ALTER TABLE events.contributions OWNER TO indico;

--
-- Name: contributions_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.contributions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.contributions_id_seq OWNER TO indico;

--
-- Name: contributions_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.contributions_id_seq OWNED BY events.contributions.id;


--
-- Name: event_person_links; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.event_person_links (
    event_id integer NOT NULL,
    id integer NOT NULL,
    person_id integer NOT NULL,
    first_name character varying,
    last_name character varying,
    title smallint,
    affiliation_id integer,
    affiliation character varying,
    address text,
    phone character varying,
    display_order integer NOT NULL,
    CONSTRAINT ck_event_person_links_valid_enum_title CHECK ((title = ANY (ARRAY[0, 1, 2, 3, 4, 5, 6])))
);


ALTER TABLE events.event_person_links OWNER TO indico;

--
-- Name: event_person_links_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.event_person_links_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.event_person_links_id_seq OWNER TO indico;

--
-- Name: event_person_links_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.event_person_links_id_seq OWNED BY events.event_person_links.id;


--
-- Name: event_references; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.event_references (
    id integer NOT NULL,
    value character varying NOT NULL,
    event_id integer NOT NULL,
    reference_type_id integer NOT NULL
);


ALTER TABLE events.event_references OWNER TO indico;

--
-- Name: event_references_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.event_references_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.event_references_id_seq OWNER TO indico;

--
-- Name: event_references_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.event_references_id_seq OWNED BY events.event_references.id;


--
-- Name: events; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.events (
    id integer NOT NULL,
    is_deleted boolean NOT NULL,
    is_locked boolean NOT NULL,
    creator_id integer NOT NULL,
    category_id integer,
    series_id integer,
    cloned_from_id integer,
    label_id integer,
    label_message text NOT NULL,
    created_dt timestamp without time zone NOT NULL,
    start_dt timestamp without time zone NOT NULL,
    end_dt timestamp without time zone NOT NULL,
    timezone character varying NOT NULL,
    type smallint NOT NULL,
    visibility integer,
    keywords character varying[] NOT NULL,
    url_shortcut character varying,
    logo_metadata jsonb NOT NULL,
    logo bytea,
    stylesheet_metadata jsonb NOT NULL,
    stylesheet text,
    default_page_id integer,
    map_url character varying NOT NULL,
    custom_boa_id integer,
    subcontrib_speakers_can_submit boolean NOT NULL,
    last_friendly_registration_id integer NOT NULL,
    last_friendly_contribution_id integer NOT NULL,
    last_friendly_session_id integer NOT NULL,
    title character varying NOT NULL,
    description text NOT NULL,
    room_id integer,
    venue_id integer,
    venue_name character varying NOT NULL,
    room_name character varying NOT NULL,
    address text NOT NULL,
    protection_mode smallint NOT NULL,
    access_key character varying NOT NULL,
    no_access_contact character varying NOT NULL,
    CONSTRAINT ck_events_no_custom_location_if_room CHECK (((room_id IS NULL) OR (((venue_name)::text = ''::text) AND ((room_name)::text = ''::text)))),
    CONSTRAINT ck_events_no_venue_name_if_venue_id CHECK (((venue_id IS NULL) OR ((venue_name)::text = ''::text))),
    CONSTRAINT ck_events_not_cloned_from_self CHECK ((cloned_from_id <> id)),
    CONSTRAINT ck_events_unlisted_events_always_inherit CHECK ((is_deleted OR (category_id IS NOT NULL) OR (protection_mode = 1))),
    CONSTRAINT ck_events_url_shortcut_not_empty CHECK (((url_shortcut)::text <> ''::text)),
    CONSTRAINT ck_events_valid_dates CHECK ((end_dt >= start_dt)),
    CONSTRAINT ck_events_valid_enum_protection_mode CHECK ((protection_mode = ANY (ARRAY[0, 1, 2]))),
    CONSTRAINT ck_events_valid_enum_type CHECK ((type = ANY (ARRAY[1, 2, 3]))),
    CONSTRAINT ck_events_valid_logo CHECK (((logo IS NULL) = ((logo_metadata)::text = 'null'::text))),
    CONSTRAINT ck_events_valid_stylesheet CHECK (((stylesheet IS NULL) = ((stylesheet_metadata)::text = 'null'::text))),
    CONSTRAINT ck_events_valid_title CHECK (((title)::text <> ''::text)),
    CONSTRAINT ck_events_valid_visibility CHECK (((visibility IS NULL) OR (visibility >= 0))),
    CONSTRAINT ck_events_venue_id_if_room_id CHECK (((room_id IS NULL) OR (venue_id IS NOT NULL)))
);


ALTER TABLE events.events OWNER TO indico;

--
-- Name: events_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.events_id_seq OWNER TO indico;

--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.events_id_seq OWNED BY events.events.id;


--
-- Name: image_files; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.image_files (
    id integer NOT NULL,
    event_id integer NOT NULL,
    filename character varying NOT NULL,
    content_type character varying NOT NULL,
    size bigint NOT NULL,
    md5 character varying NOT NULL,
    storage_backend character varying NOT NULL,
    storage_file_id character varying NOT NULL,
    created_dt timestamp without time zone NOT NULL
);


ALTER TABLE events.image_files OWNER TO indico;

--
-- Name: image_files_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.image_files_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.image_files_id_seq OWNER TO indico;

--
-- Name: image_files_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.image_files_id_seq OWNED BY events.image_files.id;


--
-- Name: labels; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.labels (
    id integer NOT NULL,
    title character varying NOT NULL,
    color character varying NOT NULL,
    is_event_not_happening boolean NOT NULL
);


ALTER TABLE events.labels OWNER TO indico;

--
-- Name: labels_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.labels_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.labels_id_seq OWNER TO indico;

--
-- Name: labels_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.labels_id_seq OWNED BY events.labels.id;


--
-- Name: legacy_contribution_id_map; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.legacy_contribution_id_map (
    event_id integer NOT NULL,
    legacy_contribution_id character varying NOT NULL,
    contribution_id integer NOT NULL
);


ALTER TABLE events.legacy_contribution_id_map OWNER TO indico;

--
-- Name: legacy_id_map; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.legacy_id_map (
    legacy_event_id character varying NOT NULL,
    event_id integer NOT NULL
);


ALTER TABLE events.legacy_id_map OWNER TO indico;

--
-- Name: legacy_image_id_map; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.legacy_image_id_map (
    event_id integer NOT NULL,
    legacy_image_id integer NOT NULL,
    image_id integer NOT NULL
);


ALTER TABLE events.legacy_image_id_map OWNER TO indico;

--
-- Name: legacy_page_id_map; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.legacy_page_id_map (
    event_id integer NOT NULL,
    legacy_page_id integer NOT NULL,
    page_id integer NOT NULL
);


ALTER TABLE events.legacy_page_id_map OWNER TO indico;

--
-- Name: legacy_session_block_id_map; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.legacy_session_block_id_map (
    event_id integer NOT NULL,
    legacy_session_id character varying NOT NULL,
    legacy_session_block_id character varying NOT NULL,
    session_block_id integer NOT NULL
);


ALTER TABLE events.legacy_session_block_id_map OWNER TO indico;

--
-- Name: legacy_session_id_map; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.legacy_session_id_map (
    event_id integer NOT NULL,
    legacy_session_id character varying NOT NULL,
    session_id integer NOT NULL
);


ALTER TABLE events.legacy_session_id_map OWNER TO indico;

--
-- Name: legacy_subcontribution_id_map; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.legacy_subcontribution_id_map (
    event_id integer NOT NULL,
    legacy_contribution_id character varying NOT NULL,
    legacy_subcontribution_id character varying NOT NULL,
    subcontribution_id integer NOT NULL
);


ALTER TABLE events.legacy_subcontribution_id_map OWNER TO indico;

--
-- Name: logs; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.logs (
    id integer NOT NULL,
    logged_dt timestamp without time zone NOT NULL,
    kind smallint NOT NULL,
    module character varying NOT NULL,
    type character varying NOT NULL,
    summary character varying NOT NULL,
    data json NOT NULL,
    meta jsonb NOT NULL,
    event_id integer NOT NULL,
    realm smallint NOT NULL,
    user_id integer,
    CONSTRAINT ck_logs_valid_enum_kind CHECK ((kind = ANY (ARRAY[1, 2, 3, 4]))),
    CONSTRAINT ck_logs_valid_enum_realm CHECK ((realm = ANY (ARRAY[1, 2, 3, 4, 5])))
);


ALTER TABLE events.logs OWNER TO indico;

--
-- Name: logs_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.logs_id_seq OWNER TO indico;

--
-- Name: logs_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.logs_id_seq OWNED BY events.logs.id;


--
-- Name: menu_entries; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.menu_entries (
    id integer NOT NULL,
    parent_id integer,
    event_id integer NOT NULL,
    is_enabled boolean NOT NULL,
    title character varying,
    name character varying,
    "position" integer NOT NULL,
    new_tab boolean NOT NULL,
    link_url character varying,
    plugin character varying,
    page_id integer,
    type smallint NOT NULL,
    protection_mode smallint NOT NULL,
    speakers_can_access boolean NOT NULL,
    CONSTRAINT ck_menu_entries_title_not_empty CHECK (((title)::text <> ''::text)),
    CONSTRAINT ck_menu_entries_valid_enum_protection_mode CHECK ((protection_mode = ANY (ARRAY[1, 2]))),
    CONSTRAINT ck_menu_entries_valid_enum_type CHECK ((type = ANY (ARRAY[1, 2, 3, 4, 5]))),
    CONSTRAINT ck_menu_entries_valid_link_url CHECK (((type = 3) = (link_url IS NOT NULL))),
    CONSTRAINT ck_menu_entries_valid_name CHECK ((((type = ANY (ARRAY[2, 4])) AND (name IS NOT NULL)) OR ((type <> ALL (ARRAY[2, 4])) AND (name IS NULL)))),
    CONSTRAINT ck_menu_entries_valid_page_id CHECK ((((type = 5) AND (page_id IS NOT NULL)) OR ((type <> 5) AND (page_id IS NULL)))),
    CONSTRAINT ck_menu_entries_valid_plugin CHECK ((((type = 4) AND (plugin IS NOT NULL)) OR ((type <> 4) AND (plugin IS NULL)))),
    CONSTRAINT ck_menu_entries_valid_title CHECK ((((type = 1) AND (title IS NULL)) OR ((type = ANY (ARRAY[3, 5])) AND (title IS NOT NULL)) OR (type <> ALL (ARRAY[1, 3, 5]))))
);


ALTER TABLE events.menu_entries OWNER TO indico;

--
-- Name: menu_entries_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.menu_entries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.menu_entries_id_seq OWNER TO indico;

--
-- Name: menu_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.menu_entries_id_seq OWNED BY events.menu_entries.id;


--
-- Name: menu_entry_principals; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.menu_entry_principals (
    id integer NOT NULL,
    menu_entry_id integer NOT NULL,
    type smallint NOT NULL,
    user_id integer,
    local_group_id integer,
    mp_group_provider character varying,
    mp_group_name character varying,
    event_role_id integer,
    category_role_id integer,
    registration_form_id integer,
    CONSTRAINT ck_menu_entry_principals_valid_category_role CHECK (((type <> 7) OR ((event_role_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NULL) AND (category_role_id IS NOT NULL)))),
    CONSTRAINT ck_menu_entry_principals_valid_enum_type CHECK ((type = ANY (ARRAY[1, 2, 3, 6, 7, 8]))),
    CONSTRAINT ck_menu_entry_principals_valid_event_role CHECK (((type <> 6) OR ((category_role_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NULL) AND (event_role_id IS NOT NULL)))),
    CONSTRAINT ck_menu_entry_principals_valid_local_group CHECK (((type <> 2) OR ((category_role_id IS NULL) AND (event_role_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NULL) AND (local_group_id IS NOT NULL)))),
    CONSTRAINT ck_menu_entry_principals_valid_multipass_group CHECK (((type <> 3) OR ((category_role_id IS NULL) AND (event_role_id IS NULL) AND (local_group_id IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NULL) AND (mp_group_name IS NOT NULL) AND (mp_group_provider IS NOT NULL)))),
    CONSTRAINT ck_menu_entry_principals_valid_registration_form CHECK (((type <> 8) OR ((category_role_id IS NULL) AND (event_role_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (user_id IS NULL) AND (registration_form_id IS NOT NULL)))),
    CONSTRAINT ck_menu_entry_principals_valid_user CHECK (((type <> 1) OR ((category_role_id IS NULL) AND (event_role_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NOT NULL))))
);


ALTER TABLE events.menu_entry_principals OWNER TO indico;

--
-- Name: menu_entry_principals_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.menu_entry_principals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.menu_entry_principals_id_seq OWNER TO indico;

--
-- Name: menu_entry_principals_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.menu_entry_principals_id_seq OWNED BY events.menu_entry_principals.id;


--
-- Name: note_revisions; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.note_revisions (
    id integer NOT NULL,
    note_id integer NOT NULL,
    user_id integer NOT NULL,
    created_dt timestamp without time zone NOT NULL,
    render_mode smallint NOT NULL,
    source text NOT NULL,
    html text NOT NULL,
    CONSTRAINT ck_note_revisions_valid_enum_render_mode CHECK ((render_mode = ANY (ARRAY[1, 2, 3])))
);


ALTER TABLE events.note_revisions OWNER TO indico;

--
-- Name: note_revisions_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.note_revisions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.note_revisions_id_seq OWNER TO indico;

--
-- Name: note_revisions_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.note_revisions_id_seq OWNED BY events.note_revisions.id;


--
-- Name: notes; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.notes (
    id integer NOT NULL,
    is_deleted boolean NOT NULL,
    html text NOT NULL,
    current_revision_id integer,
    link_type smallint NOT NULL,
    event_id integer,
    linked_event_id integer,
    session_id integer,
    contribution_id integer,
    subcontribution_id integer,
    CONSTRAINT ck_notes_valid_contribution_link CHECK (((link_type <> 3) OR ((linked_event_id IS NULL) AND (session_id IS NULL) AND (subcontribution_id IS NULL) AND (contribution_id IS NOT NULL)))),
    CONSTRAINT ck_notes_valid_enum_link_type CHECK ((link_type = ANY (ARRAY[2, 3, 4, 5]))),
    CONSTRAINT ck_notes_valid_event_id CHECK (((event_id IS NULL) = (link_type = 1))),
    CONSTRAINT ck_notes_valid_event_link CHECK (((link_type <> 2) OR ((contribution_id IS NULL) AND (session_id IS NULL) AND (subcontribution_id IS NULL) AND (linked_event_id IS NOT NULL)))),
    CONSTRAINT ck_notes_valid_session_link CHECK (((link_type <> 5) OR ((contribution_id IS NULL) AND (linked_event_id IS NULL) AND (subcontribution_id IS NULL) AND (session_id IS NOT NULL)))),
    CONSTRAINT ck_notes_valid_subcontribution_link CHECK (((link_type <> 4) OR ((contribution_id IS NULL) AND (linked_event_id IS NULL) AND (session_id IS NULL) AND (subcontribution_id IS NOT NULL))))
);


ALTER TABLE events.notes OWNER TO indico;

--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.notes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.notes_id_seq OWNER TO indico;

--
-- Name: notes_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.notes_id_seq OWNED BY events.notes.id;


--
-- Name: pages; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.pages (
    id integer NOT NULL,
    event_id integer NOT NULL,
    html text NOT NULL
);


ALTER TABLE events.pages OWNER TO indico;

--
-- Name: pages_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.pages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.pages_id_seq OWNER TO indico;

--
-- Name: pages_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.pages_id_seq OWNED BY events.pages.id;


--
-- Name: payment_transactions; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.payment_transactions (
    id integer NOT NULL,
    registration_id integer NOT NULL,
    status smallint NOT NULL,
    amount numeric(11,2) NOT NULL,
    currency character varying NOT NULL,
    provider character varying NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    data jsonb NOT NULL,
    CONSTRAINT ck_payment_transactions_positive_amount CHECK ((amount > (0)::numeric)),
    CONSTRAINT ck_payment_transactions_valid_enum_status CHECK ((status = ANY (ARRAY[1, 2, 3, 4, 5])))
);


ALTER TABLE events.payment_transactions OWNER TO indico;

--
-- Name: payment_transactions_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.payment_transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.payment_transactions_id_seq OWNER TO indico;

--
-- Name: payment_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.payment_transactions_id_seq OWNED BY events.payment_transactions.id;


--
-- Name: persons; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.persons (
    id integer NOT NULL,
    event_id integer NOT NULL,
    user_id integer,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    email character varying NOT NULL,
    title smallint NOT NULL,
    affiliation_id integer,
    affiliation character varying NOT NULL,
    address text NOT NULL,
    phone character varying NOT NULL,
    invited_dt timestamp without time zone,
    is_untrusted boolean NOT NULL,
    CONSTRAINT ck_persons_lowercase_email CHECK (((email)::text = lower((email)::text))),
    CONSTRAINT ck_persons_valid_enum_title CHECK ((title = ANY (ARRAY[0, 1, 2, 3, 4, 5, 6])))
);


ALTER TABLE events.persons OWNER TO indico;

--
-- Name: persons_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.persons_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.persons_id_seq OWNER TO indico;

--
-- Name: persons_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.persons_id_seq OWNED BY events.persons.id;


--
-- Name: principals; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.principals (
    read_access boolean NOT NULL,
    full_access boolean NOT NULL,
    permissions character varying[] NOT NULL,
    id integer NOT NULL,
    event_id integer NOT NULL,
    type smallint NOT NULL,
    user_id integer,
    local_group_id integer,
    mp_group_provider character varying,
    mp_group_name character varying,
    email character varying,
    ip_network_group_id integer,
    event_role_id integer,
    category_role_id integer,
    registration_form_id integer,
    CONSTRAINT ck_principals_disallow_group_editor_permissions CHECK (((type <> ALL (ARRAY[2, 3])) OR (NOT ((permissions)::text[] && ARRAY['paper_editing'::text, 'slides_editing'::text, 'poster_editing'::text])))),
    CONSTRAINT ck_principals_has_privs CHECK ((read_access OR full_access OR (array_length(permissions, 1) IS NOT NULL))),
    CONSTRAINT ck_principals_lowercase_email CHECK (((email IS NULL) OR ((email)::text = lower((email)::text)))),
    CONSTRAINT ck_principals_networks_read_only CHECK (((type <> 5) OR ((NOT full_access) AND (array_length(permissions, 1) IS NULL)))),
    CONSTRAINT ck_principals_registration_form_read_only CHECK (((type <> 8) OR ((NOT full_access) AND (array_length(permissions, 1) IS NULL)))),
    CONSTRAINT ck_principals_valid_category_role CHECK (((type <> 7) OR ((email IS NULL) AND (event_role_id IS NULL) AND (ip_network_group_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NULL) AND (category_role_id IS NOT NULL)))),
    CONSTRAINT ck_principals_valid_email CHECK (((type <> 4) OR ((category_role_id IS NULL) AND (event_role_id IS NULL) AND (ip_network_group_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NULL) AND (email IS NOT NULL)))),
    CONSTRAINT ck_principals_valid_enum_type CHECK ((type = ANY (ARRAY[1, 2, 3, 4, 5, 6, 7, 8]))),
    CONSTRAINT ck_principals_valid_event_role CHECK (((type <> 6) OR ((category_role_id IS NULL) AND (email IS NULL) AND (ip_network_group_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NULL) AND (event_role_id IS NOT NULL)))),
    CONSTRAINT ck_principals_valid_local_group CHECK (((type <> 2) OR ((category_role_id IS NULL) AND (email IS NULL) AND (event_role_id IS NULL) AND (ip_network_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NULL) AND (local_group_id IS NOT NULL)))),
    CONSTRAINT ck_principals_valid_multipass_group CHECK (((type <> 3) OR ((category_role_id IS NULL) AND (email IS NULL) AND (event_role_id IS NULL) AND (ip_network_group_id IS NULL) AND (local_group_id IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NULL) AND (mp_group_name IS NOT NULL) AND (mp_group_provider IS NOT NULL)))),
    CONSTRAINT ck_principals_valid_network CHECK (((type <> 5) OR ((category_role_id IS NULL) AND (email IS NULL) AND (event_role_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NULL) AND (ip_network_group_id IS NOT NULL)))),
    CONSTRAINT ck_principals_valid_registration_form CHECK (((type <> 8) OR ((category_role_id IS NULL) AND (email IS NULL) AND (event_role_id IS NULL) AND (ip_network_group_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (user_id IS NULL) AND (registration_form_id IS NOT NULL)))),
    CONSTRAINT ck_principals_valid_user CHECK (((type <> 1) OR ((category_role_id IS NULL) AND (email IS NULL) AND (event_role_id IS NULL) AND (ip_network_group_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NOT NULL))))
);


ALTER TABLE events.principals OWNER TO indico;

--
-- Name: principals_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.principals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.principals_id_seq OWNER TO indico;

--
-- Name: principals_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.principals_id_seq OWNED BY events.principals.id;


--
-- Name: reminders; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.reminders (
    id integer NOT NULL,
    event_id integer NOT NULL,
    creator_id integer NOT NULL,
    created_dt timestamp without time zone NOT NULL,
    scheduled_dt timestamp without time zone NOT NULL,
    is_sent boolean NOT NULL,
    event_start_delta interval,
    recipients character varying[] NOT NULL,
    send_to_participants boolean NOT NULL,
    send_to_speakers boolean NOT NULL,
    include_summary boolean NOT NULL,
    include_description boolean NOT NULL,
    attach_ical boolean NOT NULL,
    reply_to_address character varying NOT NULL,
    message character varying NOT NULL
);


ALTER TABLE events.reminders OWNER TO indico;

--
-- Name: reminders_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.reminders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.reminders_id_seq OWNER TO indico;

--
-- Name: reminders_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.reminders_id_seq OWNED BY events.reminders.id;


--
-- Name: requests; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.requests (
    id integer NOT NULL,
    event_id integer NOT NULL,
    type character varying NOT NULL,
    state smallint NOT NULL,
    data jsonb NOT NULL,
    created_by_id integer NOT NULL,
    created_dt timestamp without time zone NOT NULL,
    processed_by_id integer,
    processed_dt timestamp without time zone,
    comment text,
    CONSTRAINT ck_requests_valid_enum_state CHECK ((state = ANY (ARRAY[0, 1, 2, 3])))
);


ALTER TABLE events.requests OWNER TO indico;

--
-- Name: requests_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.requests_id_seq OWNER TO indico;

--
-- Name: requests_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.requests_id_seq OWNED BY events.requests.id;


--
-- Name: role_members; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.role_members (
    role_id integer NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE events.role_members OWNER TO indico;

--
-- Name: roles; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.roles (
    id integer NOT NULL,
    event_id integer NOT NULL,
    name character varying NOT NULL,
    code character varying NOT NULL,
    color character varying NOT NULL,
    CONSTRAINT ck_roles_uppercase_code CHECK (((code)::text = upper((code)::text)))
);


ALTER TABLE events.roles OWNER TO indico;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.roles_id_seq OWNER TO indico;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.roles_id_seq OWNED BY events.roles.id;


--
-- Name: series; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.series (
    id integer NOT NULL,
    show_sequence_in_title boolean NOT NULL,
    show_links boolean NOT NULL,
    event_title_pattern character varying NOT NULL
);


ALTER TABLE events.series OWNER TO indico;

--
-- Name: series_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.series_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.series_id_seq OWNER TO indico;

--
-- Name: series_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.series_id_seq OWNED BY events.series.id;


--
-- Name: session_block_person_links; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.session_block_person_links (
    session_block_id integer NOT NULL,
    id integer NOT NULL,
    person_id integer NOT NULL,
    first_name character varying,
    last_name character varying,
    title smallint,
    affiliation_id integer,
    affiliation character varying,
    address text,
    phone character varying,
    display_order integer NOT NULL,
    CONSTRAINT ck_session_block_person_links_valid_enum_title CHECK ((title = ANY (ARRAY[0, 1, 2, 3, 4, 5, 6])))
);


ALTER TABLE events.session_block_person_links OWNER TO indico;

--
-- Name: session_block_person_links_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.session_block_person_links_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.session_block_person_links_id_seq OWNER TO indico;

--
-- Name: session_block_person_links_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.session_block_person_links_id_seq OWNED BY events.session_block_person_links.id;


--
-- Name: session_blocks; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.session_blocks (
    id integer NOT NULL,
    session_id integer NOT NULL,
    title character varying NOT NULL,
    code character varying NOT NULL,
    duration interval NOT NULL,
    inherit_location boolean NOT NULL,
    room_id integer,
    venue_id integer,
    venue_name character varying NOT NULL,
    room_name character varying NOT NULL,
    address text NOT NULL,
    CONSTRAINT ck_session_blocks_duration_no_seconds CHECK ((date_trunc('minute'::text, duration) = duration)),
    CONSTRAINT ck_session_blocks_inherited_location CHECK (((NOT inherit_location) OR ((venue_id IS NULL) AND (room_id IS NULL) AND ((venue_name)::text = ''::text) AND ((room_name)::text = ''::text) AND (address = ''::text)))),
    CONSTRAINT ck_session_blocks_no_custom_location_if_room CHECK (((room_id IS NULL) OR (((venue_name)::text = ''::text) AND ((room_name)::text = ''::text)))),
    CONSTRAINT ck_session_blocks_no_venue_name_if_venue_id CHECK (((venue_id IS NULL) OR ((venue_name)::text = ''::text))),
    CONSTRAINT ck_session_blocks_positive_duration CHECK ((duration > '00:00:00'::interval)),
    CONSTRAINT ck_session_blocks_venue_id_if_room_id CHECK (((room_id IS NULL) OR (venue_id IS NOT NULL)))
);


ALTER TABLE events.session_blocks OWNER TO indico;

--
-- Name: session_blocks_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.session_blocks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.session_blocks_id_seq OWNER TO indico;

--
-- Name: session_blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.session_blocks_id_seq OWNED BY events.session_blocks.id;


--
-- Name: session_principals; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.session_principals (
    read_access boolean NOT NULL,
    full_access boolean NOT NULL,
    permissions character varying[] NOT NULL,
    id integer NOT NULL,
    session_id integer NOT NULL,
    type smallint NOT NULL,
    user_id integer,
    local_group_id integer,
    mp_group_provider character varying,
    mp_group_name character varying,
    email character varying,
    event_role_id integer,
    category_role_id integer,
    registration_form_id integer,
    CONSTRAINT ck_session_principals_has_privs CHECK ((read_access OR full_access OR (array_length(permissions, 1) IS NOT NULL))),
    CONSTRAINT ck_session_principals_lowercase_email CHECK (((email IS NULL) OR ((email)::text = lower((email)::text)))),
    CONSTRAINT ck_session_principals_registration_form_read_only CHECK (((type <> 8) OR ((NOT full_access) AND (array_length(permissions, 1) IS NULL)))),
    CONSTRAINT ck_session_principals_valid_category_role CHECK (((type <> 7) OR ((email IS NULL) AND (event_role_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NULL) AND (category_role_id IS NOT NULL)))),
    CONSTRAINT ck_session_principals_valid_email CHECK (((type <> 4) OR ((category_role_id IS NULL) AND (event_role_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NULL) AND (email IS NOT NULL)))),
    CONSTRAINT ck_session_principals_valid_enum_type CHECK ((type = ANY (ARRAY[1, 2, 3, 4, 6, 7, 8]))),
    CONSTRAINT ck_session_principals_valid_event_role CHECK (((type <> 6) OR ((category_role_id IS NULL) AND (email IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NULL) AND (event_role_id IS NOT NULL)))),
    CONSTRAINT ck_session_principals_valid_local_group CHECK (((type <> 2) OR ((category_role_id IS NULL) AND (email IS NULL) AND (event_role_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NULL) AND (local_group_id IS NOT NULL)))),
    CONSTRAINT ck_session_principals_valid_multipass_group CHECK (((type <> 3) OR ((category_role_id IS NULL) AND (email IS NULL) AND (event_role_id IS NULL) AND (local_group_id IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NULL) AND (mp_group_name IS NOT NULL) AND (mp_group_provider IS NOT NULL)))),
    CONSTRAINT ck_session_principals_valid_registration_form CHECK (((type <> 8) OR ((category_role_id IS NULL) AND (email IS NULL) AND (event_role_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (user_id IS NULL) AND (registration_form_id IS NOT NULL)))),
    CONSTRAINT ck_session_principals_valid_user CHECK (((type <> 1) OR ((category_role_id IS NULL) AND (email IS NULL) AND (event_role_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (registration_form_id IS NULL) AND (user_id IS NOT NULL))))
);


ALTER TABLE events.session_principals OWNER TO indico;

--
-- Name: session_principals_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.session_principals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.session_principals_id_seq OWNER TO indico;

--
-- Name: session_principals_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.session_principals_id_seq OWNED BY events.session_principals.id;


--
-- Name: session_types; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.session_types (
    id integer NOT NULL,
    event_id integer NOT NULL,
    name character varying NOT NULL,
    code character varying NOT NULL,
    is_poster boolean NOT NULL
);


ALTER TABLE events.session_types OWNER TO indico;

--
-- Name: session_types_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.session_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.session_types_id_seq OWNER TO indico;

--
-- Name: session_types_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.session_types_id_seq OWNED BY events.session_types.id;


--
-- Name: sessions; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.sessions (
    id integer NOT NULL,
    friendly_id integer NOT NULL,
    event_id integer NOT NULL,
    type_id integer,
    title character varying NOT NULL,
    code character varying NOT NULL,
    default_contribution_duration interval NOT NULL,
    is_deleted boolean NOT NULL,
    description text NOT NULL,
    text_color character varying NOT NULL,
    background_color character varying NOT NULL,
    protection_mode smallint NOT NULL,
    inherit_location boolean NOT NULL,
    room_id integer,
    venue_id integer,
    venue_name character varying NOT NULL,
    room_name character varying NOT NULL,
    address text NOT NULL,
    CONSTRAINT ck_sessions_both_or_no_colors CHECK ((((text_color)::text = ''::text) = ((background_color)::text = ''::text))),
    CONSTRAINT ck_sessions_colors_not_empty CHECK ((((text_color)::text <> ''::text) AND ((background_color)::text <> ''::text))),
    CONSTRAINT ck_sessions_default_contribution_duration_no_seconds CHECK ((date_trunc('minute'::text, default_contribution_duration) = default_contribution_duration)),
    CONSTRAINT ck_sessions_inherited_location CHECK (((NOT inherit_location) OR ((venue_id IS NULL) AND (room_id IS NULL) AND ((venue_name)::text = ''::text) AND ((room_name)::text = ''::text) AND (address = ''::text)))),
    CONSTRAINT ck_sessions_no_custom_location_if_room CHECK (((room_id IS NULL) OR (((venue_name)::text = ''::text) AND ((room_name)::text = ''::text)))),
    CONSTRAINT ck_sessions_no_venue_name_if_venue_id CHECK (((venue_id IS NULL) OR ((venue_name)::text = ''::text))),
    CONSTRAINT ck_sessions_positive_default_contribution_duration CHECK ((default_contribution_duration > '00:00:00'::interval)),
    CONSTRAINT ck_sessions_valid_enum_protection_mode CHECK ((protection_mode = ANY (ARRAY[0, 1, 2]))),
    CONSTRAINT ck_sessions_venue_id_if_room_id CHECK (((room_id IS NULL) OR (venue_id IS NOT NULL)))
);


ALTER TABLE events.sessions OWNER TO indico;

--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.sessions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.sessions_id_seq OWNER TO indico;

--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.sessions_id_seq OWNED BY events.sessions.id;


--
-- Name: settings; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.settings (
    id integer NOT NULL,
    module character varying NOT NULL,
    name character varying NOT NULL,
    value jsonb NOT NULL,
    event_id integer NOT NULL,
    CONSTRAINT ck_settings_lowercase_module CHECK (((module)::text = lower((module)::text))),
    CONSTRAINT ck_settings_lowercase_name CHECK (((name)::text = lower((name)::text)))
);


ALTER TABLE events.settings OWNER TO indico;

--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.settings_id_seq OWNER TO indico;

--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.settings_id_seq OWNED BY events.settings.id;


--
-- Name: settings_principals; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.settings_principals (
    id integer NOT NULL,
    module character varying NOT NULL,
    name character varying NOT NULL,
    type smallint NOT NULL,
    user_id integer,
    local_group_id integer,
    mp_group_provider character varying,
    mp_group_name character varying,
    event_role_id integer,
    category_role_id integer,
    event_id integer NOT NULL,
    CONSTRAINT ck_settings_principals_lowercase_module CHECK (((module)::text = lower((module)::text))),
    CONSTRAINT ck_settings_principals_lowercase_name CHECK (((name)::text = lower((name)::text))),
    CONSTRAINT ck_settings_principals_valid_category_role CHECK (((type <> 7) OR ((event_role_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (user_id IS NULL) AND (category_role_id IS NOT NULL)))),
    CONSTRAINT ck_settings_principals_valid_enum_type CHECK ((type = ANY (ARRAY[1, 2, 3, 6, 7]))),
    CONSTRAINT ck_settings_principals_valid_event_role CHECK (((type <> 6) OR ((category_role_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (user_id IS NULL) AND (event_role_id IS NOT NULL)))),
    CONSTRAINT ck_settings_principals_valid_local_group CHECK (((type <> 2) OR ((category_role_id IS NULL) AND (event_role_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (user_id IS NULL) AND (local_group_id IS NOT NULL)))),
    CONSTRAINT ck_settings_principals_valid_multipass_group CHECK (((type <> 3) OR ((category_role_id IS NULL) AND (event_role_id IS NULL) AND (local_group_id IS NULL) AND (user_id IS NULL) AND (mp_group_name IS NOT NULL) AND (mp_group_provider IS NOT NULL)))),
    CONSTRAINT ck_settings_principals_valid_user CHECK (((type <> 1) OR ((category_role_id IS NULL) AND (event_role_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (user_id IS NOT NULL))))
);


ALTER TABLE events.settings_principals OWNER TO indico;

--
-- Name: settings_principals_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.settings_principals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.settings_principals_id_seq OWNER TO indico;

--
-- Name: settings_principals_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.settings_principals_id_seq OWNED BY events.settings_principals.id;


--
-- Name: static_list_links; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.static_list_links (
    id integer NOT NULL,
    event_id integer NOT NULL,
    type character varying NOT NULL,
    uuid uuid NOT NULL,
    created_dt timestamp without time zone NOT NULL,
    last_used_dt timestamp without time zone,
    data jsonb NOT NULL
);


ALTER TABLE events.static_list_links OWNER TO indico;

--
-- Name: static_list_links_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.static_list_links_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.static_list_links_id_seq OWNER TO indico;

--
-- Name: static_list_links_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.static_list_links_id_seq OWNED BY events.static_list_links.id;


--
-- Name: static_sites; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.static_sites (
    id integer NOT NULL,
    event_id integer NOT NULL,
    state smallint NOT NULL,
    requested_dt timestamp without time zone NOT NULL,
    creator_id integer NOT NULL,
    filename character varying,
    content_type character varying,
    size bigint,
    md5 character varying,
    storage_backend character varying,
    storage_file_id character varying,
    CONSTRAINT ck_static_sites_valid_enum_state CHECK ((state = ANY (ARRAY[0, 1, 2, 3, 4])))
);


ALTER TABLE events.static_sites OWNER TO indico;

--
-- Name: static_sites_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.static_sites_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.static_sites_id_seq OWNER TO indico;

--
-- Name: static_sites_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.static_sites_id_seq OWNED BY events.static_sites.id;


--
-- Name: subcontribution_person_links; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.subcontribution_person_links (
    subcontribution_id integer NOT NULL,
    id integer NOT NULL,
    person_id integer NOT NULL,
    first_name character varying,
    last_name character varying,
    title smallint,
    affiliation_id integer,
    affiliation character varying,
    address text,
    phone character varying,
    display_order integer NOT NULL,
    CONSTRAINT ck_subcontribution_person_links_valid_enum_title CHECK ((title = ANY (ARRAY[0, 1, 2, 3, 4, 5, 6])))
);


ALTER TABLE events.subcontribution_person_links OWNER TO indico;

--
-- Name: subcontribution_person_links_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.subcontribution_person_links_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.subcontribution_person_links_id_seq OWNER TO indico;

--
-- Name: subcontribution_person_links_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.subcontribution_person_links_id_seq OWNED BY events.subcontribution_person_links.id;


--
-- Name: subcontribution_references; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.subcontribution_references (
    id integer NOT NULL,
    value character varying NOT NULL,
    subcontribution_id integer NOT NULL,
    reference_type_id integer NOT NULL
);


ALTER TABLE events.subcontribution_references OWNER TO indico;

--
-- Name: subcontribution_references_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.subcontribution_references_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.subcontribution_references_id_seq OWNER TO indico;

--
-- Name: subcontribution_references_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.subcontribution_references_id_seq OWNED BY events.subcontribution_references.id;


--
-- Name: subcontributions; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.subcontributions (
    id integer NOT NULL,
    friendly_id integer NOT NULL,
    contribution_id integer NOT NULL,
    "position" integer NOT NULL,
    code character varying NOT NULL,
    duration interval NOT NULL,
    is_deleted boolean NOT NULL,
    description text NOT NULL,
    title character varying NOT NULL,
    render_mode smallint NOT NULL,
    CONSTRAINT ck_subcontributions_duration_no_seconds CHECK ((date_trunc('minute'::text, duration) = duration)),
    CONSTRAINT ck_subcontributions_nonnegative_duration CHECK ((duration >= '00:00:00'::interval)),
    CONSTRAINT ck_subcontributions_valid_enum_render_mode CHECK ((render_mode = ANY (ARRAY[1, 2, 3]))),
    CONSTRAINT ck_subcontributions_valid_title CHECK (((title)::text <> ''::text))
);


ALTER TABLE events.subcontributions OWNER TO indico;

--
-- Name: subcontributions_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.subcontributions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.subcontributions_id_seq OWNER TO indico;

--
-- Name: subcontributions_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.subcontributions_id_seq OWNED BY events.subcontributions.id;


--
-- Name: timetable_entries; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.timetable_entries (
    id integer NOT NULL,
    event_id integer NOT NULL,
    parent_id integer,
    session_block_id integer,
    contribution_id integer,
    break_id integer,
    type smallint NOT NULL,
    start_dt timestamp without time zone NOT NULL,
    CONSTRAINT ck_timetable_entries_valid_break CHECK (((type <> 3) OR ((contribution_id IS NULL) AND (session_block_id IS NULL) AND (break_id IS NOT NULL)))),
    CONSTRAINT ck_timetable_entries_valid_contribution CHECK (((type <> 2) OR ((break_id IS NULL) AND (session_block_id IS NULL) AND (contribution_id IS NOT NULL)))),
    CONSTRAINT ck_timetable_entries_valid_enum_type CHECK ((type = ANY (ARRAY[1, 2, 3]))),
    CONSTRAINT ck_timetable_entries_valid_parent CHECK (((type <> 1) OR (parent_id IS NULL))),
    CONSTRAINT ck_timetable_entries_valid_session_block CHECK (((type <> 1) OR ((break_id IS NULL) AND (contribution_id IS NULL) AND (session_block_id IS NOT NULL))))
);


ALTER TABLE events.timetable_entries OWNER TO indico;

--
-- Name: timetable_entries_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.timetable_entries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.timetable_entries_id_seq OWNER TO indico;

--
-- Name: timetable_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.timetable_entries_id_seq OWNED BY events.timetable_entries.id;


--
-- Name: track_groups; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.track_groups (
    id integer NOT NULL,
    title character varying NOT NULL,
    "position" integer NOT NULL,
    event_id integer NOT NULL,
    description text NOT NULL
);


ALTER TABLE events.track_groups OWNER TO indico;

--
-- Name: track_groups_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.track_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.track_groups_id_seq OWNER TO indico;

--
-- Name: track_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.track_groups_id_seq OWNED BY events.track_groups.id;


--
-- Name: track_principals; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.track_principals (
    read_access boolean NOT NULL,
    full_access boolean NOT NULL,
    permissions character varying[] NOT NULL,
    id integer NOT NULL,
    track_id integer NOT NULL,
    type smallint NOT NULL,
    user_id integer,
    local_group_id integer,
    mp_group_provider character varying,
    mp_group_name character varying,
    event_role_id integer,
    category_role_id integer,
    CONSTRAINT ck_track_principals_has_privs CHECK ((read_access OR full_access OR (array_length(permissions, 1) IS NOT NULL))),
    CONSTRAINT ck_track_principals_no_full_access CHECK ((NOT full_access)),
    CONSTRAINT ck_track_principals_no_read_access CHECK ((NOT read_access)),
    CONSTRAINT ck_track_principals_valid_category_role CHECK (((type <> 7) OR ((event_role_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (user_id IS NULL) AND (category_role_id IS NOT NULL)))),
    CONSTRAINT ck_track_principals_valid_enum_type CHECK ((type = ANY (ARRAY[1, 2, 3, 6, 7]))),
    CONSTRAINT ck_track_principals_valid_event_role CHECK (((type <> 6) OR ((category_role_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (user_id IS NULL) AND (event_role_id IS NOT NULL)))),
    CONSTRAINT ck_track_principals_valid_local_group CHECK (((type <> 2) OR ((category_role_id IS NULL) AND (event_role_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (user_id IS NULL) AND (local_group_id IS NOT NULL)))),
    CONSTRAINT ck_track_principals_valid_multipass_group CHECK (((type <> 3) OR ((category_role_id IS NULL) AND (event_role_id IS NULL) AND (local_group_id IS NULL) AND (user_id IS NULL) AND (mp_group_name IS NOT NULL) AND (mp_group_provider IS NOT NULL)))),
    CONSTRAINT ck_track_principals_valid_user CHECK (((type <> 1) OR ((category_role_id IS NULL) AND (event_role_id IS NULL) AND (local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (user_id IS NOT NULL))))
);


ALTER TABLE events.track_principals OWNER TO indico;

--
-- Name: track_principals_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.track_principals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.track_principals_id_seq OWNER TO indico;

--
-- Name: track_principals_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.track_principals_id_seq OWNED BY events.track_principals.id;


--
-- Name: tracks; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.tracks (
    id integer NOT NULL,
    title character varying NOT NULL,
    code character varying NOT NULL,
    event_id integer NOT NULL,
    "position" integer NOT NULL,
    default_session_id integer,
    track_group_id integer,
    description text NOT NULL
);


ALTER TABLE events.tracks OWNER TO indico;

--
-- Name: tracks_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.tracks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.tracks_id_seq OWNER TO indico;

--
-- Name: tracks_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.tracks_id_seq OWNED BY events.tracks.id;


--
-- Name: vc_room_events; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.vc_room_events (
    id integer NOT NULL,
    event_id integer NOT NULL,
    vc_room_id integer NOT NULL,
    link_type smallint NOT NULL,
    linked_event_id integer,
    session_block_id integer,
    contribution_id integer,
    show boolean NOT NULL,
    data jsonb NOT NULL,
    CONSTRAINT ck_vc_room_events_valid_block_link CHECK (((link_type <> 3) OR ((contribution_id IS NULL) AND (linked_event_id IS NULL) AND (session_block_id IS NOT NULL)))),
    CONSTRAINT ck_vc_room_events_valid_contribution_link CHECK (((link_type <> 2) OR ((linked_event_id IS NULL) AND (session_block_id IS NULL) AND (contribution_id IS NOT NULL)))),
    CONSTRAINT ck_vc_room_events_valid_enum_link_type CHECK ((link_type = ANY (ARRAY[1, 2, 3]))),
    CONSTRAINT ck_vc_room_events_valid_event_link CHECK (((link_type <> 1) OR ((contribution_id IS NULL) AND (session_block_id IS NULL) AND (linked_event_id IS NOT NULL))))
);


ALTER TABLE events.vc_room_events OWNER TO indico;

--
-- Name: vc_room_events_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.vc_room_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.vc_room_events_id_seq OWNER TO indico;

--
-- Name: vc_room_events_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.vc_room_events_id_seq OWNED BY events.vc_room_events.id;


--
-- Name: vc_rooms; Type: TABLE; Schema: events; Owner: indico
--

CREATE TABLE events.vc_rooms (
    id integer NOT NULL,
    type character varying NOT NULL,
    name character varying NOT NULL,
    status smallint NOT NULL,
    created_by_id integer NOT NULL,
    created_dt timestamp without time zone NOT NULL,
    modified_dt timestamp without time zone,
    data jsonb NOT NULL,
    CONSTRAINT ck_vc_rooms_valid_enum_status CHECK ((status = ANY (ARRAY[1, 2])))
);


ALTER TABLE events.vc_rooms OWNER TO indico;

--
-- Name: vc_rooms_id_seq; Type: SEQUENCE; Schema: events; Owner: indico
--

CREATE SEQUENCE events.vc_rooms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE events.vc_rooms_id_seq OWNER TO indico;

--
-- Name: vc_rooms_id_seq; Type: SEQUENCE OWNED BY; Schema: events; Owner: indico
--

ALTER SEQUENCE events.vc_rooms_id_seq OWNED BY events.vc_rooms.id;


--
-- Name: affiliations; Type: TABLE; Schema: indico; Owner: indico
--

CREATE TABLE indico.affiliations (
    id integer NOT NULL,
    name character varying NOT NULL,
    alt_names character varying[] NOT NULL,
    is_deleted boolean NOT NULL,
    street character varying NOT NULL,
    postcode character varying NOT NULL,
    city character varying NOT NULL,
    country_code character varying NOT NULL,
    meta jsonb NOT NULL
);


ALTER TABLE indico.affiliations OWNER TO indico;

--
-- Name: affiliations_id_seq; Type: SEQUENCE; Schema: indico; Owner: indico
--

CREATE SEQUENCE indico.affiliations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE indico.affiliations_id_seq OWNER TO indico;

--
-- Name: affiliations_id_seq; Type: SEQUENCE OWNED BY; Schema: indico; Owner: indico
--

ALTER SEQUENCE indico.affiliations_id_seq OWNED BY indico.affiliations.id;


--
-- Name: designer_image_files; Type: TABLE; Schema: indico; Owner: indico
--

CREATE TABLE indico.designer_image_files (
    id integer NOT NULL,
    template_id integer NOT NULL,
    filename character varying NOT NULL,
    content_type character varying NOT NULL,
    size bigint NOT NULL,
    md5 character varying NOT NULL,
    storage_backend character varying NOT NULL,
    storage_file_id character varying NOT NULL,
    created_dt timestamp without time zone NOT NULL
);


ALTER TABLE indico.designer_image_files OWNER TO indico;

--
-- Name: designer_image_files_id_seq; Type: SEQUENCE; Schema: indico; Owner: indico
--

CREATE SEQUENCE indico.designer_image_files_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE indico.designer_image_files_id_seq OWNER TO indico;

--
-- Name: designer_image_files_id_seq; Type: SEQUENCE OWNED BY; Schema: indico; Owner: indico
--

ALTER SEQUENCE indico.designer_image_files_id_seq OWNED BY indico.designer_image_files.id;


--
-- Name: designer_templates; Type: TABLE; Schema: indico; Owner: indico
--

CREATE TABLE indico.designer_templates (
    id integer NOT NULL,
    type smallint NOT NULL,
    title character varying NOT NULL,
    registration_form_id integer,
    event_id integer,
    category_id integer,
    data jsonb NOT NULL,
    background_image_id integer,
    backside_template_id integer,
    is_clonable boolean NOT NULL,
    is_system_template boolean NOT NULL,
    CONSTRAINT ck_designer_templates_event_xor_category_id_null CHECK (((event_id IS NULL) <> (category_id IS NULL))),
    CONSTRAINT ck_designer_templates_no_regform_if_category CHECK (((category_id IS NULL) OR (registration_form_id IS NULL))),
    CONSTRAINT ck_designer_templates_valid_enum_type CHECK ((type = ANY (ARRAY[1, 2])))
);


ALTER TABLE indico.designer_templates OWNER TO indico;

--
-- Name: designer_templates_id_seq; Type: SEQUENCE; Schema: indico; Owner: indico
--

CREATE SEQUENCE indico.designer_templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE indico.designer_templates_id_seq OWNER TO indico;

--
-- Name: designer_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: indico; Owner: indico
--

ALTER SEQUENCE indico.designer_templates_id_seq OWNED BY indico.designer_templates.id;


--
-- Name: files; Type: TABLE; Schema: indico; Owner: indico
--

CREATE TABLE indico.files (
    id integer NOT NULL,
    uuid uuid NOT NULL,
    claimed boolean NOT NULL,
    meta jsonb NOT NULL,
    filename character varying NOT NULL,
    content_type character varying NOT NULL,
    size bigint NOT NULL,
    md5 character varying NOT NULL,
    storage_backend character varying NOT NULL,
    storage_file_id character varying NOT NULL,
    created_dt timestamp without time zone NOT NULL
);


ALTER TABLE indico.files OWNER TO indico;

--
-- Name: files_id_seq; Type: SEQUENCE; Schema: indico; Owner: indico
--

CREATE SEQUENCE indico.files_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE indico.files_id_seq OWNER TO indico;

--
-- Name: files_id_seq; Type: SEQUENCE OWNED BY; Schema: indico; Owner: indico
--

ALTER SEQUENCE indico.files_id_seq OWNED BY indico.files.id;


--
-- Name: ip_network_groups; Type: TABLE; Schema: indico; Owner: indico
--

CREATE TABLE indico.ip_network_groups (
    id integer NOT NULL,
    name character varying NOT NULL,
    description text NOT NULL,
    hidden boolean NOT NULL,
    attachment_access_override boolean NOT NULL
);


ALTER TABLE indico.ip_network_groups OWNER TO indico;

--
-- Name: ip_network_groups_id_seq; Type: SEQUENCE; Schema: indico; Owner: indico
--

CREATE SEQUENCE indico.ip_network_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE indico.ip_network_groups_id_seq OWNER TO indico;

--
-- Name: ip_network_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: indico; Owner: indico
--

ALTER SEQUENCE indico.ip_network_groups_id_seq OWNED BY indico.ip_network_groups.id;


--
-- Name: ip_networks; Type: TABLE; Schema: indico; Owner: indico
--

CREATE TABLE indico.ip_networks (
    group_id integer NOT NULL,
    network cidr NOT NULL
);


ALTER TABLE indico.ip_networks OWNER TO indico;

--
-- Name: news; Type: TABLE; Schema: indico; Owner: indico
--

CREATE TABLE indico.news (
    id integer NOT NULL,
    created_dt timestamp without time zone NOT NULL,
    title character varying NOT NULL,
    content text NOT NULL
);


ALTER TABLE indico.news OWNER TO indico;

--
-- Name: news_id_seq; Type: SEQUENCE; Schema: indico; Owner: indico
--

CREATE SEQUENCE indico.news_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE indico.news_id_seq OWNER TO indico;

--
-- Name: news_id_seq; Type: SEQUENCE OWNED BY; Schema: indico; Owner: indico
--

ALTER SEQUENCE indico.news_id_seq OWNED BY indico.news.id;


--
-- Name: receipt_templates; Type: TABLE; Schema: indico; Owner: indico
--

CREATE TABLE indico.receipt_templates (
    id integer NOT NULL,
    title character varying NOT NULL,
    event_id integer,
    category_id integer,
    html character varying NOT NULL,
    css character varying NOT NULL,
    yaml character varying NOT NULL,
    default_filename character varying NOT NULL,
    is_deleted boolean NOT NULL,
    CONSTRAINT ck_receipt_templates_event_xor_category_id_null CHECK (((event_id IS NULL) <> (category_id IS NULL)))
);


ALTER TABLE indico.receipt_templates OWNER TO indico;

--
-- Name: receipt_templates_id_seq; Type: SEQUENCE; Schema: indico; Owner: indico
--

CREATE SEQUENCE indico.receipt_templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE indico.receipt_templates_id_seq OWNER TO indico;

--
-- Name: receipt_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: indico; Owner: indico
--

ALTER SEQUENCE indico.receipt_templates_id_seq OWNED BY indico.receipt_templates.id;


--
-- Name: reference_types; Type: TABLE; Schema: indico; Owner: indico
--

CREATE TABLE indico.reference_types (
    id integer NOT NULL,
    name character varying NOT NULL,
    scheme character varying NOT NULL,
    url_template character varying NOT NULL
);


ALTER TABLE indico.reference_types OWNER TO indico;

--
-- Name: reference_types_id_seq; Type: SEQUENCE; Schema: indico; Owner: indico
--

CREATE SEQUENCE indico.reference_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE indico.reference_types_id_seq OWNER TO indico;

--
-- Name: reference_types_id_seq; Type: SEQUENCE OWNED BY; Schema: indico; Owner: indico
--

ALTER SEQUENCE indico.reference_types_id_seq OWNED BY indico.reference_types.id;


--
-- Name: settings; Type: TABLE; Schema: indico; Owner: indico
--

CREATE TABLE indico.settings (
    id integer NOT NULL,
    module character varying NOT NULL,
    name character varying NOT NULL,
    value jsonb NOT NULL,
    CONSTRAINT ck_settings_lowercase_module CHECK (((module)::text = lower((module)::text))),
    CONSTRAINT ck_settings_lowercase_name CHECK (((name)::text = lower((name)::text)))
);


ALTER TABLE indico.settings OWNER TO indico;

--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: indico; Owner: indico
--

CREATE SEQUENCE indico.settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE indico.settings_id_seq OWNER TO indico;

--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: indico; Owner: indico
--

ALTER SEQUENCE indico.settings_id_seq OWNED BY indico.settings.id;


--
-- Name: settings_principals; Type: TABLE; Schema: indico; Owner: indico
--

CREATE TABLE indico.settings_principals (
    id integer NOT NULL,
    module character varying NOT NULL,
    name character varying NOT NULL,
    type smallint NOT NULL,
    user_id integer,
    local_group_id integer,
    mp_group_provider character varying,
    mp_group_name character varying,
    CONSTRAINT ck_settings_principals_lowercase_module CHECK (((module)::text = lower((module)::text))),
    CONSTRAINT ck_settings_principals_lowercase_name CHECK (((name)::text = lower((name)::text))),
    CONSTRAINT ck_settings_principals_valid_enum_type CHECK ((type = ANY (ARRAY[1, 2, 3]))),
    CONSTRAINT ck_settings_principals_valid_local_group CHECK (((type <> 2) OR ((mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (user_id IS NULL) AND (local_group_id IS NOT NULL)))),
    CONSTRAINT ck_settings_principals_valid_multipass_group CHECK (((type <> 3) OR ((local_group_id IS NULL) AND (user_id IS NULL) AND (mp_group_name IS NOT NULL) AND (mp_group_provider IS NOT NULL)))),
    CONSTRAINT ck_settings_principals_valid_user CHECK (((type <> 1) OR ((local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (user_id IS NOT NULL))))
);


ALTER TABLE indico.settings_principals OWNER TO indico;

--
-- Name: settings_principals_id_seq; Type: SEQUENCE; Schema: indico; Owner: indico
--

CREATE SEQUENCE indico.settings_principals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE indico.settings_principals_id_seq OWNER TO indico;

--
-- Name: settings_principals_id_seq; Type: SEQUENCE OWNED BY; Schema: indico; Owner: indico
--

ALTER SEQUENCE indico.settings_principals_id_seq OWNED BY indico.settings_principals.id;


--
-- Name: application_user_links; Type: TABLE; Schema: oauth; Owner: indico
--

CREATE TABLE oauth.application_user_links (
    id integer NOT NULL,
    application_id integer NOT NULL,
    user_id integer NOT NULL,
    scopes character varying[] NOT NULL
);


ALTER TABLE oauth.application_user_links OWNER TO indico;

--
-- Name: application_user_links_id_seq; Type: SEQUENCE; Schema: oauth; Owner: indico
--

CREATE SEQUENCE oauth.application_user_links_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE oauth.application_user_links_id_seq OWNER TO indico;

--
-- Name: application_user_links_id_seq; Type: SEQUENCE OWNED BY; Schema: oauth; Owner: indico
--

ALTER SEQUENCE oauth.application_user_links_id_seq OWNED BY oauth.application_user_links.id;


--
-- Name: applications; Type: TABLE; Schema: oauth; Owner: indico
--

CREATE TABLE oauth.applications (
    id integer NOT NULL,
    name character varying NOT NULL,
    description text NOT NULL,
    client_id uuid NOT NULL,
    client_secret uuid NOT NULL,
    allowed_scopes character varying[] NOT NULL,
    redirect_uris character varying[] NOT NULL,
    is_enabled boolean NOT NULL,
    is_trusted boolean NOT NULL,
    allow_pkce_flow boolean NOT NULL,
    system_app_type smallint NOT NULL,
    CONSTRAINT ck_applications_valid_enum_system_app_type CHECK ((system_app_type = ANY (ARRAY[0, 1])))
);


ALTER TABLE oauth.applications OWNER TO indico;

--
-- Name: applications_id_seq; Type: SEQUENCE; Schema: oauth; Owner: indico
--

CREATE SEQUENCE oauth.applications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE oauth.applications_id_seq OWNER TO indico;

--
-- Name: applications_id_seq; Type: SEQUENCE OWNED BY; Schema: oauth; Owner: indico
--

ALTER SEQUENCE oauth.applications_id_seq OWNED BY oauth.applications.id;


--
-- Name: tokens; Type: TABLE; Schema: oauth; Owner: indico
--

CREATE TABLE oauth.tokens (
    id integer NOT NULL,
    access_token_hash character varying NOT NULL,
    scopes character varying[] NOT NULL,
    created_dt timestamp without time zone NOT NULL,
    last_used_dt timestamp without time zone,
    last_used_ip inet,
    use_count integer NOT NULL,
    app_user_link_id integer NOT NULL
);


ALTER TABLE oauth.tokens OWNER TO indico;

--
-- Name: tokens_id_seq; Type: SEQUENCE; Schema: oauth; Owner: indico
--

CREATE SEQUENCE oauth.tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE oauth.tokens_id_seq OWNER TO indico;

--
-- Name: tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: oauth; Owner: indico
--

ALTER SEQUENCE oauth.tokens_id_seq OWNED BY oauth.tokens.id;


--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: indico
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO indico;

--
-- Name: blocked_rooms; Type: TABLE; Schema: roombooking; Owner: indico
--

CREATE TABLE roombooking.blocked_rooms (
    id integer NOT NULL,
    state smallint NOT NULL,
    rejected_by character varying,
    rejection_reason character varying,
    blocking_id integer NOT NULL,
    room_id integer NOT NULL,
    CONSTRAINT ck_blocked_rooms_valid_enum_state CHECK ((state = ANY (ARRAY[0, 1, 2])))
);


ALTER TABLE roombooking.blocked_rooms OWNER TO indico;

--
-- Name: blocked_rooms_id_seq; Type: SEQUENCE; Schema: roombooking; Owner: indico
--

CREATE SEQUENCE roombooking.blocked_rooms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE roombooking.blocked_rooms_id_seq OWNER TO indico;

--
-- Name: blocked_rooms_id_seq; Type: SEQUENCE OWNED BY; Schema: roombooking; Owner: indico
--

ALTER SEQUENCE roombooking.blocked_rooms_id_seq OWNED BY roombooking.blocked_rooms.id;


--
-- Name: blocking_principals; Type: TABLE; Schema: roombooking; Owner: indico
--

CREATE TABLE roombooking.blocking_principals (
    id integer NOT NULL,
    blocking_id integer NOT NULL,
    type smallint NOT NULL,
    user_id integer,
    local_group_id integer,
    mp_group_provider character varying,
    mp_group_name character varying,
    CONSTRAINT ck_blocking_principals_valid_enum_type CHECK ((type = ANY (ARRAY[1, 2, 3]))),
    CONSTRAINT ck_blocking_principals_valid_local_group CHECK (((type <> 2) OR ((mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (user_id IS NULL) AND (local_group_id IS NOT NULL)))),
    CONSTRAINT ck_blocking_principals_valid_multipass_group CHECK (((type <> 3) OR ((local_group_id IS NULL) AND (user_id IS NULL) AND (mp_group_name IS NOT NULL) AND (mp_group_provider IS NOT NULL)))),
    CONSTRAINT ck_blocking_principals_valid_user CHECK (((type <> 1) OR ((local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (user_id IS NOT NULL))))
);


ALTER TABLE roombooking.blocking_principals OWNER TO indico;

--
-- Name: blocking_principals_id_seq; Type: SEQUENCE; Schema: roombooking; Owner: indico
--

CREATE SEQUENCE roombooking.blocking_principals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE roombooking.blocking_principals_id_seq OWNER TO indico;

--
-- Name: blocking_principals_id_seq; Type: SEQUENCE OWNED BY; Schema: roombooking; Owner: indico
--

ALTER SEQUENCE roombooking.blocking_principals_id_seq OWNED BY roombooking.blocking_principals.id;


--
-- Name: blockings; Type: TABLE; Schema: roombooking; Owner: indico
--

CREATE TABLE roombooking.blockings (
    id integer NOT NULL,
    created_by_id integer NOT NULL,
    created_dt timestamp without time zone NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    reason text NOT NULL
);


ALTER TABLE roombooking.blockings OWNER TO indico;

--
-- Name: blockings_id_seq; Type: SEQUENCE; Schema: roombooking; Owner: indico
--

CREATE SEQUENCE roombooking.blockings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE roombooking.blockings_id_seq OWNER TO indico;

--
-- Name: blockings_id_seq; Type: SEQUENCE OWNED BY; Schema: roombooking; Owner: indico
--

ALTER SEQUENCE roombooking.blockings_id_seq OWNED BY roombooking.blockings.id;


--
-- Name: equipment_features; Type: TABLE; Schema: roombooking; Owner: indico
--

CREATE TABLE roombooking.equipment_features (
    equipment_id integer NOT NULL,
    feature_id integer NOT NULL
);


ALTER TABLE roombooking.equipment_features OWNER TO indico;

--
-- Name: equipment_types; Type: TABLE; Schema: roombooking; Owner: indico
--

CREATE TABLE roombooking.equipment_types (
    id integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE roombooking.equipment_types OWNER TO indico;

--
-- Name: equipment_types_id_seq; Type: SEQUENCE; Schema: roombooking; Owner: indico
--

CREATE SEQUENCE roombooking.equipment_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE roombooking.equipment_types_id_seq OWNER TO indico;

--
-- Name: equipment_types_id_seq; Type: SEQUENCE OWNED BY; Schema: roombooking; Owner: indico
--

ALTER SEQUENCE roombooking.equipment_types_id_seq OWNED BY roombooking.equipment_types.id;


--
-- Name: favorite_rooms; Type: TABLE; Schema: roombooking; Owner: indico
--

CREATE TABLE roombooking.favorite_rooms (
    user_id integer NOT NULL,
    room_id integer NOT NULL
);


ALTER TABLE roombooking.favorite_rooms OWNER TO indico;

--
-- Name: features; Type: TABLE; Schema: roombooking; Owner: indico
--

CREATE TABLE roombooking.features (
    id integer NOT NULL,
    name character varying NOT NULL,
    title character varying NOT NULL,
    icon character varying NOT NULL
);


ALTER TABLE roombooking.features OWNER TO indico;

--
-- Name: features_id_seq; Type: SEQUENCE; Schema: roombooking; Owner: indico
--

CREATE SEQUENCE roombooking.features_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE roombooking.features_id_seq OWNER TO indico;

--
-- Name: features_id_seq; Type: SEQUENCE OWNED BY; Schema: roombooking; Owner: indico
--

ALTER SEQUENCE roombooking.features_id_seq OWNED BY roombooking.features.id;


--
-- Name: location_principals; Type: TABLE; Schema: roombooking; Owner: indico
--

CREATE TABLE roombooking.location_principals (
    read_access boolean NOT NULL,
    full_access boolean NOT NULL,
    permissions character varying[] NOT NULL,
    id integer NOT NULL,
    location_id integer NOT NULL,
    type smallint NOT NULL,
    user_id integer,
    local_group_id integer,
    mp_group_provider character varying,
    mp_group_name character varying,
    CONSTRAINT ck_location_principals_has_privs CHECK ((read_access OR full_access OR (array_length(permissions, 1) IS NOT NULL))),
    CONSTRAINT ck_location_principals_no_read_access CHECK ((NOT read_access)),
    CONSTRAINT ck_location_principals_valid_enum_type CHECK ((type = ANY (ARRAY[1, 2, 3]))),
    CONSTRAINT ck_location_principals_valid_local_group CHECK (((type <> 2) OR ((mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (user_id IS NULL) AND (local_group_id IS NOT NULL)))),
    CONSTRAINT ck_location_principals_valid_multipass_group CHECK (((type <> 3) OR ((local_group_id IS NULL) AND (user_id IS NULL) AND (mp_group_name IS NOT NULL) AND (mp_group_provider IS NOT NULL)))),
    CONSTRAINT ck_location_principals_valid_user CHECK (((type <> 1) OR ((local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (user_id IS NOT NULL))))
);


ALTER TABLE roombooking.location_principals OWNER TO indico;

--
-- Name: location_principals_id_seq; Type: SEQUENCE; Schema: roombooking; Owner: indico
--

CREATE SEQUENCE roombooking.location_principals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE roombooking.location_principals_id_seq OWNER TO indico;

--
-- Name: location_principals_id_seq; Type: SEQUENCE OWNED BY; Schema: roombooking; Owner: indico
--

ALTER SEQUENCE roombooking.location_principals_id_seq OWNED BY roombooking.location_principals.id;


--
-- Name: locations; Type: TABLE; Schema: roombooking; Owner: indico
--

CREATE TABLE roombooking.locations (
    id integer NOT NULL,
    name character varying NOT NULL,
    map_url_template character varying NOT NULL,
    room_name_format character varying NOT NULL,
    is_deleted boolean NOT NULL
);


ALTER TABLE roombooking.locations OWNER TO indico;

--
-- Name: locations_id_seq; Type: SEQUENCE; Schema: roombooking; Owner: indico
--

CREATE SEQUENCE roombooking.locations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE roombooking.locations_id_seq OWNER TO indico;

--
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: roombooking; Owner: indico
--

ALTER SEQUENCE roombooking.locations_id_seq OWNED BY roombooking.locations.id;


--
-- Name: map_areas; Type: TABLE; Schema: roombooking; Owner: indico
--

CREATE TABLE roombooking.map_areas (
    id integer NOT NULL,
    name character varying NOT NULL,
    is_default boolean NOT NULL,
    top_left_latitude double precision NOT NULL,
    top_left_longitude double precision NOT NULL,
    bottom_right_latitude double precision NOT NULL,
    bottom_right_longitude double precision NOT NULL
);


ALTER TABLE roombooking.map_areas OWNER TO indico;

--
-- Name: map_areas_id_seq; Type: SEQUENCE; Schema: roombooking; Owner: indico
--

CREATE SEQUENCE roombooking.map_areas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE roombooking.map_areas_id_seq OWNER TO indico;

--
-- Name: map_areas_id_seq; Type: SEQUENCE OWNED BY; Schema: roombooking; Owner: indico
--

ALTER SEQUENCE roombooking.map_areas_id_seq OWNED BY roombooking.map_areas.id;


--
-- Name: photos; Type: TABLE; Schema: roombooking; Owner: indico
--

CREATE TABLE roombooking.photos (
    id integer NOT NULL,
    data bytea
);


ALTER TABLE roombooking.photos OWNER TO indico;

--
-- Name: photos_id_seq; Type: SEQUENCE; Schema: roombooking; Owner: indico
--

CREATE SEQUENCE roombooking.photos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE roombooking.photos_id_seq OWNER TO indico;

--
-- Name: photos_id_seq; Type: SEQUENCE OWNED BY; Schema: roombooking; Owner: indico
--

ALTER SEQUENCE roombooking.photos_id_seq OWNED BY roombooking.photos.id;


--
-- Name: reservation_edit_logs; Type: TABLE; Schema: roombooking; Owner: indico
--

CREATE TABLE roombooking.reservation_edit_logs (
    id integer NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    info character varying[] NOT NULL,
    user_name character varying NOT NULL,
    reservation_id integer NOT NULL
);


ALTER TABLE roombooking.reservation_edit_logs OWNER TO indico;

--
-- Name: reservation_edit_logs_id_seq; Type: SEQUENCE; Schema: roombooking; Owner: indico
--

CREATE SEQUENCE roombooking.reservation_edit_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE roombooking.reservation_edit_logs_id_seq OWNER TO indico;

--
-- Name: reservation_edit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: roombooking; Owner: indico
--

ALTER SEQUENCE roombooking.reservation_edit_logs_id_seq OWNED BY roombooking.reservation_edit_logs.id;


--
-- Name: reservation_occurrence_links; Type: TABLE; Schema: roombooking; Owner: indico
--

CREATE TABLE roombooking.reservation_occurrence_links (
    id integer NOT NULL,
    link_type smallint NOT NULL,
    event_id integer,
    linked_event_id integer,
    session_block_id integer,
    contribution_id integer,
    CONSTRAINT ck_reservation_occurrence_links_valid_contribution_link CHECK (((link_type <> 3) OR ((linked_event_id IS NULL) AND (session_block_id IS NULL) AND (contribution_id IS NOT NULL)))),
    CONSTRAINT ck_reservation_occurrence_links_valid_enum_link_type CHECK ((link_type = ANY (ARRAY[2, 3, 6]))),
    CONSTRAINT ck_reservation_occurrence_links_valid_event_id CHECK (((event_id IS NULL) = (link_type = 1))),
    CONSTRAINT ck_reservation_occurrence_links_valid_event_link CHECK (((link_type <> 2) OR ((contribution_id IS NULL) AND (session_block_id IS NULL) AND (linked_event_id IS NOT NULL)))),
    CONSTRAINT ck_reservation_occurrence_links_valid_session_block_link CHECK (((link_type <> 6) OR ((contribution_id IS NULL) AND (linked_event_id IS NULL) AND (session_block_id IS NOT NULL))))
);


ALTER TABLE roombooking.reservation_occurrence_links OWNER TO indico;

--
-- Name: reservation_occurrence_links_id_seq; Type: SEQUENCE; Schema: roombooking; Owner: indico
--

CREATE SEQUENCE roombooking.reservation_occurrence_links_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE roombooking.reservation_occurrence_links_id_seq OWNER TO indico;

--
-- Name: reservation_occurrence_links_id_seq; Type: SEQUENCE OWNED BY; Schema: roombooking; Owner: indico
--

ALTER SEQUENCE roombooking.reservation_occurrence_links_id_seq OWNED BY roombooking.reservation_occurrence_links.id;


--
-- Name: reservation_occurrences; Type: TABLE; Schema: roombooking; Owner: indico
--

CREATE TABLE roombooking.reservation_occurrences (
    reservation_id integer NOT NULL,
    link_id integer,
    start_dt timestamp without time zone NOT NULL,
    end_dt timestamp without time zone NOT NULL,
    notification_sent boolean NOT NULL,
    state smallint NOT NULL,
    rejection_reason character varying,
    CONSTRAINT ck_reservation_occurrences_rejection_reason_not_empty CHECK (((rejection_reason)::text <> ''::text)),
    CONSTRAINT ck_reservation_occurrences_valid_enum_state CHECK ((state = ANY (ARRAY[2, 3, 4])))
);


ALTER TABLE roombooking.reservation_occurrences OWNER TO indico;

--
-- Name: reservations; Type: TABLE; Schema: roombooking; Owner: indico
--

CREATE TABLE roombooking.reservations (
    id integer NOT NULL,
    created_dt timestamp without time zone NOT NULL,
    start_dt timestamp without time zone NOT NULL,
    end_dt timestamp without time zone NOT NULL,
    repeat_frequency smallint NOT NULL,
    repeat_interval smallint NOT NULL,
    recurrence_weekdays character varying[],
    booked_for_id integer,
    booked_for_name character varying NOT NULL,
    created_by_id integer,
    room_id integer NOT NULL,
    state smallint NOT NULL,
    booking_reason text NOT NULL,
    rejection_reason character varying,
    end_notification_sent boolean NOT NULL,
    internal_note text NOT NULL,
    CONSTRAINT ck_reservations_recurrence_weekdays_only_weekly CHECK (((recurrence_weekdays IS NULL) OR (repeat_frequency = 2))),
    CONSTRAINT ck_reservations_rejection_reason_not_empty CHECK (((rejection_reason)::text <> ''::text)),
    CONSTRAINT ck_reservations_valid_enum_repeat_frequency CHECK ((repeat_frequency = ANY (ARRAY[0, 1, 2, 3]))),
    CONSTRAINT ck_reservations_valid_enum_state CHECK ((state = ANY (ARRAY[1, 2, 3, 4]))),
    CONSTRAINT ck_reservations_valid_recurrence_weekdays CHECK ((indico.array_is_unique((recurrence_weekdays)::text[]) AND ((recurrence_weekdays)::text[] <@ ARRAY['mon'::text, 'tue'::text, 'wed'::text, 'thu'::text, 'fri'::text, 'sat'::text, 'sun'::text])))
);


ALTER TABLE roombooking.reservations OWNER TO indico;

--
-- Name: reservations_id_seq; Type: SEQUENCE; Schema: roombooking; Owner: indico
--

CREATE SEQUENCE roombooking.reservations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE roombooking.reservations_id_seq OWNER TO indico;

--
-- Name: reservations_id_seq; Type: SEQUENCE OWNED BY; Schema: roombooking; Owner: indico
--

ALTER SEQUENCE roombooking.reservations_id_seq OWNED BY roombooking.reservations.id;


--
-- Name: room_attribute_values; Type: TABLE; Schema: roombooking; Owner: indico
--

CREATE TABLE roombooking.room_attribute_values (
    attribute_id integer NOT NULL,
    room_id integer NOT NULL,
    value jsonb
);


ALTER TABLE roombooking.room_attribute_values OWNER TO indico;

--
-- Name: room_attributes; Type: TABLE; Schema: roombooking; Owner: indico
--

CREATE TABLE roombooking.room_attributes (
    id integer NOT NULL,
    name character varying NOT NULL,
    title character varying NOT NULL,
    is_hidden boolean NOT NULL
);


ALTER TABLE roombooking.room_attributes OWNER TO indico;

--
-- Name: room_attributes_id_seq; Type: SEQUENCE; Schema: roombooking; Owner: indico
--

CREATE SEQUENCE roombooking.room_attributes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE roombooking.room_attributes_id_seq OWNER TO indico;

--
-- Name: room_attributes_id_seq; Type: SEQUENCE OWNED BY; Schema: roombooking; Owner: indico
--

ALTER SEQUENCE roombooking.room_attributes_id_seq OWNED BY roombooking.room_attributes.id;


--
-- Name: room_bookable_hours; Type: TABLE; Schema: roombooking; Owner: indico
--

CREATE TABLE roombooking.room_bookable_hours (
    id integer NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    weekday character varying,
    room_id integer NOT NULL,
    CONSTRAINT ck_room_bookable_hours_valid_weekdays CHECK (((weekday)::text = ANY (ARRAY['mon'::text, 'tue'::text, 'wed'::text, 'thu'::text, 'fri'::text, 'sat'::text, 'sun'::text])))
);


ALTER TABLE roombooking.room_bookable_hours OWNER TO indico;

--
-- Name: room_bookable_hours_id_seq; Type: SEQUENCE; Schema: roombooking; Owner: indico
--

CREATE SEQUENCE roombooking.room_bookable_hours_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE roombooking.room_bookable_hours_id_seq OWNER TO indico;

--
-- Name: room_bookable_hours_id_seq; Type: SEQUENCE OWNED BY; Schema: roombooking; Owner: indico
--

ALTER SEQUENCE roombooking.room_bookable_hours_id_seq OWNED BY roombooking.room_bookable_hours.id;


--
-- Name: room_equipment; Type: TABLE; Schema: roombooking; Owner: indico
--

CREATE TABLE roombooking.room_equipment (
    equipment_id integer NOT NULL,
    room_id integer NOT NULL
);


ALTER TABLE roombooking.room_equipment OWNER TO indico;

--
-- Name: room_nonbookable_periods; Type: TABLE; Schema: roombooking; Owner: indico
--

CREATE TABLE roombooking.room_nonbookable_periods (
    start_dt timestamp without time zone NOT NULL,
    end_dt timestamp without time zone NOT NULL,
    room_id integer NOT NULL
);


ALTER TABLE roombooking.room_nonbookable_periods OWNER TO indico;

--
-- Name: room_principals; Type: TABLE; Schema: roombooking; Owner: indico
--

CREATE TABLE roombooking.room_principals (
    read_access boolean NOT NULL,
    full_access boolean NOT NULL,
    permissions character varying[] NOT NULL,
    id integer NOT NULL,
    room_id integer NOT NULL,
    type smallint NOT NULL,
    user_id integer,
    local_group_id integer,
    mp_group_provider character varying,
    mp_group_name character varying,
    CONSTRAINT ck_room_principals_has_privs CHECK ((read_access OR full_access OR (array_length(permissions, 1) IS NOT NULL))),
    CONSTRAINT ck_room_principals_no_read_access CHECK ((NOT read_access)),
    CONSTRAINT ck_room_principals_valid_enum_type CHECK ((type = ANY (ARRAY[1, 2, 3]))),
    CONSTRAINT ck_room_principals_valid_local_group CHECK (((type <> 2) OR ((mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (user_id IS NULL) AND (local_group_id IS NOT NULL)))),
    CONSTRAINT ck_room_principals_valid_multipass_group CHECK (((type <> 3) OR ((local_group_id IS NULL) AND (user_id IS NULL) AND (mp_group_name IS NOT NULL) AND (mp_group_provider IS NOT NULL)))),
    CONSTRAINT ck_room_principals_valid_user CHECK (((type <> 1) OR ((local_group_id IS NULL) AND (mp_group_name IS NULL) AND (mp_group_provider IS NULL) AND (user_id IS NOT NULL))))
);


ALTER TABLE roombooking.room_principals OWNER TO indico;

--
-- Name: room_principals_id_seq; Type: SEQUENCE; Schema: roombooking; Owner: indico
--

CREATE SEQUENCE roombooking.room_principals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE roombooking.room_principals_id_seq OWNER TO indico;

--
-- Name: room_principals_id_seq; Type: SEQUENCE OWNED BY; Schema: roombooking; Owner: indico
--

ALTER SEQUENCE roombooking.room_principals_id_seq OWNED BY roombooking.room_principals.id;


--
-- Name: rooms; Type: TABLE; Schema: roombooking; Owner: indico
--

CREATE TABLE roombooking.rooms (
    id integer NOT NULL,
    location_id integer NOT NULL,
    photo_id integer,
    verbose_name character varying,
    site character varying,
    division character varying NOT NULL,
    building character varying NOT NULL,
    floor character varying NOT NULL,
    number character varying NOT NULL,
    notification_emails character varying[] NOT NULL,
    notification_before_days integer,
    notification_before_days_weekly integer,
    notification_before_days_monthly integer,
    end_notification_daily integer,
    end_notification_weekly integer,
    end_notification_monthly integer,
    reservations_need_confirmation boolean NOT NULL,
    notifications_enabled boolean NOT NULL,
    end_notifications_enabled boolean NOT NULL,
    telephone character varying NOT NULL,
    key_location character varying NOT NULL,
    capacity integer,
    surface_area integer,
    longitude double precision,
    latitude double precision,
    comments character varying NOT NULL,
    owner_id integer NOT NULL,
    is_deleted boolean NOT NULL,
    is_reservable boolean NOT NULL,
    max_advance_days integer,
    booking_limit_days integer,
    protection_mode smallint NOT NULL,
    CONSTRAINT ck_rooms_valid_enum_protection_mode CHECK ((protection_mode = ANY (ARRAY[0, 2]))),
    CONSTRAINT ck_rooms_verbose_name_not_empty CHECK (((verbose_name)::text <> ''::text))
);


ALTER TABLE roombooking.rooms OWNER TO indico;

--
-- Name: rooms_id_seq; Type: SEQUENCE; Schema: roombooking; Owner: indico
--

CREATE SEQUENCE roombooking.rooms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE roombooking.rooms_id_seq OWNER TO indico;

--
-- Name: rooms_id_seq; Type: SEQUENCE OWNED BY; Schema: roombooking; Owner: indico
--

ALTER SEQUENCE roombooking.rooms_id_seq OWNED BY roombooking.rooms.id;


--
-- Name: api_keys; Type: TABLE; Schema: users; Owner: indico
--

CREATE TABLE users.api_keys (
    id integer NOT NULL,
    token uuid NOT NULL,
    secret uuid NOT NULL,
    user_id integer NOT NULL,
    is_active boolean NOT NULL,
    is_blocked boolean NOT NULL,
    is_persistent_allowed boolean NOT NULL,
    created_dt timestamp without time zone NOT NULL,
    last_used_dt timestamp without time zone,
    last_used_ip inet,
    last_used_uri character varying,
    last_used_auth boolean,
    use_count integer NOT NULL
);


ALTER TABLE users.api_keys OWNER TO indico;

--
-- Name: api_keys_id_seq; Type: SEQUENCE; Schema: users; Owner: indico
--

CREATE SEQUENCE users.api_keys_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE users.api_keys_id_seq OWNER TO indico;

--
-- Name: api_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: users; Owner: indico
--

ALTER SEQUENCE users.api_keys_id_seq OWNED BY users.api_keys.id;


--
-- Name: data_export_requests; Type: TABLE; Schema: users; Owner: indico
--

CREATE TABLE users.data_export_requests (
    id integer NOT NULL,
    user_id integer NOT NULL,
    file_id integer,
    requested_dt timestamp without time zone NOT NULL,
    selected_options character varying(18)[] NOT NULL,
    include_files boolean NOT NULL,
    state smallint NOT NULL,
    max_size_exceeded boolean NOT NULL,
    CONSTRAINT ck_data_export_requests_success_has_file CHECK (((state <> 2) OR (file_id IS NOT NULL))),
    CONSTRAINT ck_data_export_requests_valid_enum_state CHECK ((state = ANY (ARRAY[0, 1, 2, 3, 4])))
);


ALTER TABLE users.data_export_requests OWNER TO indico;

--
-- Name: data_export_requests_id_seq; Type: SEQUENCE; Schema: users; Owner: indico
--

CREATE SEQUENCE users.data_export_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE users.data_export_requests_id_seq OWNER TO indico;

--
-- Name: data_export_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: users; Owner: indico
--

ALTER SEQUENCE users.data_export_requests_id_seq OWNED BY users.data_export_requests.id;


--
-- Name: emails; Type: TABLE; Schema: users; Owner: indico
--

CREATE TABLE users.emails (
    id integer NOT NULL,
    user_id integer NOT NULL,
    email character varying NOT NULL,
    is_primary boolean NOT NULL,
    is_user_deleted boolean NOT NULL,
    CONSTRAINT ck_emails_lowercase_email CHECK (((email)::text = lower((email)::text)))
);


ALTER TABLE users.emails OWNER TO indico;

--
-- Name: emails_id_seq; Type: SEQUENCE; Schema: users; Owner: indico
--

CREATE SEQUENCE users.emails_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE users.emails_id_seq OWNER TO indico;

--
-- Name: emails_id_seq; Type: SEQUENCE OWNED BY; Schema: users; Owner: indico
--

ALTER SEQUENCE users.emails_id_seq OWNED BY users.emails.id;


--
-- Name: favorite_categories; Type: TABLE; Schema: users; Owner: indico
--

CREATE TABLE users.favorite_categories (
    user_id integer NOT NULL,
    target_id integer NOT NULL
);


ALTER TABLE users.favorite_categories OWNER TO indico;

--
-- Name: favorite_events; Type: TABLE; Schema: users; Owner: indico
--

CREATE TABLE users.favorite_events (
    user_id integer NOT NULL,
    target_id integer NOT NULL
);


ALTER TABLE users.favorite_events OWNER TO indico;

--
-- Name: favorite_users; Type: TABLE; Schema: users; Owner: indico
--

CREATE TABLE users.favorite_users (
    user_id integer NOT NULL,
    target_id integer NOT NULL
);


ALTER TABLE users.favorite_users OWNER TO indico;

--
-- Name: group_members; Type: TABLE; Schema: users; Owner: indico
--

CREATE TABLE users.group_members (
    group_id integer NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE users.group_members OWNER TO indico;

--
-- Name: groups; Type: TABLE; Schema: users; Owner: indico
--

CREATE TABLE users.groups (
    id integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE users.groups OWNER TO indico;

--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: users; Owner: indico
--

CREATE SEQUENCE users.groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE users.groups_id_seq OWNER TO indico;

--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: users; Owner: indico
--

ALTER SEQUENCE users.groups_id_seq OWNED BY users.groups.id;


--
-- Name: identities; Type: TABLE; Schema: users; Owner: indico
--

CREATE TABLE users.identities (
    id integer NOT NULL,
    user_id integer NOT NULL,
    provider character varying NOT NULL,
    identifier character varying NOT NULL,
    multipass_data jsonb NOT NULL,
    data jsonb NOT NULL,
    password_hash character varying,
    last_login_dt timestamp without time zone,
    last_login_ip inet
);


ALTER TABLE users.identities OWNER TO indico;

--
-- Name: identities_id_seq; Type: SEQUENCE; Schema: users; Owner: indico
--

CREATE SEQUENCE users.identities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE users.identities_id_seq OWNER TO indico;

--
-- Name: identities_id_seq; Type: SEQUENCE OWNED BY; Schema: users; Owner: indico
--

ALTER SEQUENCE users.identities_id_seq OWNED BY users.identities.id;


--
-- Name: logs; Type: TABLE; Schema: users; Owner: indico
--

CREATE TABLE users.logs (
    id integer NOT NULL,
    logged_dt timestamp without time zone NOT NULL,
    kind smallint NOT NULL,
    module character varying NOT NULL,
    type character varying NOT NULL,
    summary character varying NOT NULL,
    data json NOT NULL,
    meta jsonb NOT NULL,
    target_user_id integer NOT NULL,
    realm smallint NOT NULL,
    user_id integer,
    CONSTRAINT ck_logs_valid_enum_kind CHECK ((kind = ANY (ARRAY[1, 2, 3, 4]))),
    CONSTRAINT ck_logs_valid_enum_realm CHECK ((realm = ANY (ARRAY[1, 2])))
);


ALTER TABLE users.logs OWNER TO indico;

--
-- Name: logs_id_seq; Type: SEQUENCE; Schema: users; Owner: indico
--

CREATE SEQUENCE users.logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE users.logs_id_seq OWNER TO indico;

--
-- Name: logs_id_seq; Type: SEQUENCE OWNED BY; Schema: users; Owner: indico
--

ALTER SEQUENCE users.logs_id_seq OWNED BY users.logs.id;


--
-- Name: registration_requests; Type: TABLE; Schema: users; Owner: indico
--

CREATE TABLE users.registration_requests (
    id integer NOT NULL,
    comment text NOT NULL,
    email character varying NOT NULL,
    extra_emails character varying[] NOT NULL,
    user_data jsonb NOT NULL,
    identity_data jsonb NOT NULL,
    settings jsonb NOT NULL,
    CONSTRAINT ck_registration_requests_lowercase_email CHECK (((email)::text = lower((email)::text)))
);


ALTER TABLE users.registration_requests OWNER TO indico;

--
-- Name: registration_requests_id_seq; Type: SEQUENCE; Schema: users; Owner: indico
--

CREATE SEQUENCE users.registration_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE users.registration_requests_id_seq OWNER TO indico;

--
-- Name: registration_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: users; Owner: indico
--

ALTER SEQUENCE users.registration_requests_id_seq OWNED BY users.registration_requests.id;


--
-- Name: settings; Type: TABLE; Schema: users; Owner: indico
--

CREATE TABLE users.settings (
    id integer NOT NULL,
    module character varying NOT NULL,
    name character varying NOT NULL,
    value jsonb NOT NULL,
    user_id integer NOT NULL,
    CONSTRAINT ck_settings_lowercase_module CHECK (((module)::text = lower((module)::text))),
    CONSTRAINT ck_settings_lowercase_name CHECK (((name)::text = lower((name)::text)))
);


ALTER TABLE users.settings OWNER TO indico;

--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: users; Owner: indico
--

CREATE SEQUENCE users.settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE users.settings_id_seq OWNER TO indico;

--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: users; Owner: indico
--

ALTER SEQUENCE users.settings_id_seq OWNED BY users.settings.id;


--
-- Name: suggested_categories; Type: TABLE; Schema: users; Owner: indico
--

CREATE TABLE users.suggested_categories (
    user_id integer NOT NULL,
    category_id integer NOT NULL,
    is_ignored boolean NOT NULL,
    score double precision NOT NULL
);


ALTER TABLE users.suggested_categories OWNER TO indico;

--
-- Name: tokens; Type: TABLE; Schema: users; Owner: indico
--

CREATE TABLE users.tokens (
    id integer NOT NULL,
    access_token_hash character varying NOT NULL,
    scopes character varying[] NOT NULL,
    created_dt timestamp without time zone NOT NULL,
    last_used_dt timestamp without time zone,
    last_used_ip inet,
    use_count integer NOT NULL,
    user_id integer NOT NULL,
    name character varying NOT NULL,
    revoked_dt timestamp without time zone
);


ALTER TABLE users.tokens OWNER TO indico;

--
-- Name: tokens_id_seq; Type: SEQUENCE; Schema: users; Owner: indico
--

CREATE SEQUENCE users.tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE users.tokens_id_seq OWNER TO indico;

--
-- Name: tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: users; Owner: indico
--

ALTER SEQUENCE users.tokens_id_seq OWNED BY users.tokens.id;


--
-- Name: users; Type: TABLE; Schema: users; Owner: indico
--

CREATE TABLE users.users (
    id integer NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    title smallint NOT NULL,
    affiliation character varying NOT NULL,
    affiliation_id integer,
    phone character varying NOT NULL,
    address text NOT NULL,
    merged_into_id integer,
    is_system boolean NOT NULL,
    is_admin boolean NOT NULL,
    is_blocked boolean NOT NULL,
    is_pending boolean NOT NULL,
    is_deleted boolean NOT NULL,
    accepted_terms_dt timestamp without time zone,
    signing_secret uuid NOT NULL,
    picture bytea,
    picture_metadata jsonb NOT NULL,
    picture_source smallint NOT NULL,
    created_dt timestamp without time zone,
    CONSTRAINT ck_users_not_merged_self CHECK ((id <> merged_into_id)),
    CONSTRAINT ck_users_not_pending_proper_names CHECK ((is_pending OR (((first_name)::text <> ''::text) AND ((last_name)::text <> ''::text)))),
    CONSTRAINT ck_users_valid_enum_picture_source CHECK ((picture_source = ANY (ARRAY[0, 1, 2, 3]))),
    CONSTRAINT ck_users_valid_enum_title CHECK ((title = ANY (ARRAY[0, 1, 2, 3, 4, 5, 6]))),
    CONSTRAINT ck_users_valid_picture CHECK (((picture IS NULL) = ((picture_metadata)::text = 'null'::text))),
    CONSTRAINT ck_users_valid_system_user CHECK (((NOT is_system) OR ((NOT is_blocked) AND (NOT is_pending) AND (NOT is_deleted))))
);


ALTER TABLE users.users OWNER TO indico;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: users; Owner: indico
--

CREATE SEQUENCE users.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE users.users_id_seq OWNER TO indico;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: users; Owner: indico
--

ALTER SEQUENCE users.users_id_seq OWNED BY users.users.id;


--
-- Name: attachment_principals id; Type: DEFAULT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.attachment_principals ALTER COLUMN id SET DEFAULT nextval('attachments.attachment_principals_id_seq'::regclass);


--
-- Name: attachments id; Type: DEFAULT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.attachments ALTER COLUMN id SET DEFAULT nextval('attachments.attachments_id_seq'::regclass);


--
-- Name: files id; Type: DEFAULT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.files ALTER COLUMN id SET DEFAULT nextval('attachments.files_id_seq'::regclass);


--
-- Name: folder_principals id; Type: DEFAULT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.folder_principals ALTER COLUMN id SET DEFAULT nextval('attachments.folder_principals_id_seq'::regclass);


--
-- Name: folders id; Type: DEFAULT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.folders ALTER COLUMN id SET DEFAULT nextval('attachments.folders_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.categories ALTER COLUMN id SET DEFAULT nextval('categories.categories_id_seq'::regclass);


--
-- Name: event_move_requests id; Type: DEFAULT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.event_move_requests ALTER COLUMN id SET DEFAULT nextval('categories.event_move_requests_id_seq'::regclass);


--
-- Name: logs id; Type: DEFAULT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.logs ALTER COLUMN id SET DEFAULT nextval('categories.logs_id_seq'::regclass);


--
-- Name: principals id; Type: DEFAULT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.principals ALTER COLUMN id SET DEFAULT nextval('categories.principals_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.roles ALTER COLUMN id SET DEFAULT nextval('categories.roles_id_seq'::regclass);


--
-- Name: settings id; Type: DEFAULT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.settings ALTER COLUMN id SET DEFAULT nextval('categories.settings_id_seq'::regclass);


--
-- Name: abstract_comments id; Type: DEFAULT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_comments ALTER COLUMN id SET DEFAULT nextval('event_abstracts.abstract_comments_id_seq'::regclass);


--
-- Name: abstract_person_links id; Type: DEFAULT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_person_links ALTER COLUMN id SET DEFAULT nextval('event_abstracts.abstract_person_links_id_seq'::regclass);


--
-- Name: abstract_review_questions id; Type: DEFAULT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_review_questions ALTER COLUMN id SET DEFAULT nextval('event_abstracts.abstract_review_questions_id_seq'::regclass);


--
-- Name: abstract_review_ratings id; Type: DEFAULT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_review_ratings ALTER COLUMN id SET DEFAULT nextval('event_abstracts.abstract_review_ratings_id_seq'::regclass);


--
-- Name: abstract_reviews id; Type: DEFAULT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_reviews ALTER COLUMN id SET DEFAULT nextval('event_abstracts.abstract_reviews_id_seq'::regclass);


--
-- Name: abstracts id; Type: DEFAULT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstracts ALTER COLUMN id SET DEFAULT nextval('event_abstracts.abstracts_id_seq'::regclass);


--
-- Name: email_logs id; Type: DEFAULT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.email_logs ALTER COLUMN id SET DEFAULT nextval('event_abstracts.email_logs_id_seq'::regclass);


--
-- Name: email_templates id; Type: DEFAULT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.email_templates ALTER COLUMN id SET DEFAULT nextval('event_abstracts.email_templates_id_seq'::regclass);


--
-- Name: files id; Type: DEFAULT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.files ALTER COLUMN id SET DEFAULT nextval('event_abstracts.files_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.comments ALTER COLUMN id SET DEFAULT nextval('event_editing.comments_id_seq'::regclass);


--
-- Name: editables id; Type: DEFAULT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.editables ALTER COLUMN id SET DEFAULT nextval('event_editing.editables_id_seq'::regclass);


--
-- Name: file_types id; Type: DEFAULT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.file_types ALTER COLUMN id SET DEFAULT nextval('event_editing.file_types_id_seq'::regclass);


--
-- Name: review_conditions id; Type: DEFAULT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.review_conditions ALTER COLUMN id SET DEFAULT nextval('event_editing.review_conditions_id_seq'::regclass);


--
-- Name: revisions id; Type: DEFAULT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.revisions ALTER COLUMN id SET DEFAULT nextval('event_editing.revisions_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.tags ALTER COLUMN id SET DEFAULT nextval('event_editing.tags_id_seq'::regclass);


--
-- Name: competences id; Type: DEFAULT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.competences ALTER COLUMN id SET DEFAULT nextval('event_paper_reviewing.competences_id_seq'::regclass);


--
-- Name: files id; Type: DEFAULT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.files ALTER COLUMN id SET DEFAULT nextval('event_paper_reviewing.files_id_seq'::regclass);


--
-- Name: review_comments id; Type: DEFAULT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.review_comments ALTER COLUMN id SET DEFAULT nextval('event_paper_reviewing.review_comments_id_seq'::regclass);


--
-- Name: review_questions id; Type: DEFAULT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.review_questions ALTER COLUMN id SET DEFAULT nextval('event_paper_reviewing.review_questions_id_seq'::regclass);


--
-- Name: review_ratings id; Type: DEFAULT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.review_ratings ALTER COLUMN id SET DEFAULT nextval('event_paper_reviewing.review_ratings_id_seq'::regclass);


--
-- Name: reviews id; Type: DEFAULT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.reviews ALTER COLUMN id SET DEFAULT nextval('event_paper_reviewing.reviews_id_seq'::regclass);


--
-- Name: revisions id; Type: DEFAULT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.revisions ALTER COLUMN id SET DEFAULT nextval('event_paper_reviewing.revisions_id_seq'::regclass);


--
-- Name: templates id; Type: DEFAULT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.templates ALTER COLUMN id SET DEFAULT nextval('event_paper_reviewing.templates_id_seq'::regclass);


--
-- Name: form_field_data id; Type: DEFAULT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.form_field_data ALTER COLUMN id SET DEFAULT nextval('event_registration.form_field_data_id_seq'::regclass);


--
-- Name: form_items id; Type: DEFAULT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.form_items ALTER COLUMN id SET DEFAULT nextval('event_registration.form_items_id_seq'::regclass);


--
-- Name: forms id; Type: DEFAULT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.forms ALTER COLUMN id SET DEFAULT nextval('event_registration.forms_id_seq'::regclass);


--
-- Name: invitations id; Type: DEFAULT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.invitations ALTER COLUMN id SET DEFAULT nextval('event_registration.invitations_id_seq'::regclass);


--
-- Name: registrations id; Type: DEFAULT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.registrations ALTER COLUMN id SET DEFAULT nextval('event_registration.registrations_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.tags ALTER COLUMN id SET DEFAULT nextval('event_registration.tags_id_seq'::regclass);


--
-- Name: items id; Type: DEFAULT; Schema: event_surveys; Owner: indico
--

ALTER TABLE ONLY event_surveys.items ALTER COLUMN id SET DEFAULT nextval('event_surveys.items_id_seq'::regclass);


--
-- Name: submissions id; Type: DEFAULT; Schema: event_surveys; Owner: indico
--

ALTER TABLE ONLY event_surveys.submissions ALTER COLUMN id SET DEFAULT nextval('event_surveys.submissions_id_seq'::regclass);


--
-- Name: surveys id; Type: DEFAULT; Schema: event_surveys; Owner: indico
--

ALTER TABLE ONLY event_surveys.surveys ALTER COLUMN id SET DEFAULT nextval('event_surveys.surveys_id_seq'::regclass);


--
-- Name: agreements id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.agreements ALTER COLUMN id SET DEFAULT nextval('events.agreements_id_seq'::regclass);


--
-- Name: breaks id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.breaks ALTER COLUMN id SET DEFAULT nextval('events.breaks_id_seq'::regclass);


--
-- Name: contribution_fields id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contribution_fields ALTER COLUMN id SET DEFAULT nextval('events.contribution_fields_id_seq'::regclass);


--
-- Name: contribution_person_links id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contribution_person_links ALTER COLUMN id SET DEFAULT nextval('events.contribution_person_links_id_seq'::regclass);


--
-- Name: contribution_principals id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contribution_principals ALTER COLUMN id SET DEFAULT nextval('events.contribution_principals_id_seq'::regclass);


--
-- Name: contribution_references id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contribution_references ALTER COLUMN id SET DEFAULT nextval('events.contribution_references_id_seq'::regclass);


--
-- Name: contribution_types id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contribution_types ALTER COLUMN id SET DEFAULT nextval('events.contribution_types_id_seq'::regclass);


--
-- Name: contributions id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contributions ALTER COLUMN id SET DEFAULT nextval('events.contributions_id_seq'::regclass);


--
-- Name: event_person_links id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.event_person_links ALTER COLUMN id SET DEFAULT nextval('events.event_person_links_id_seq'::regclass);


--
-- Name: event_references id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.event_references ALTER COLUMN id SET DEFAULT nextval('events.event_references_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.events ALTER COLUMN id SET DEFAULT nextval('events.events_id_seq'::regclass);


--
-- Name: image_files id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.image_files ALTER COLUMN id SET DEFAULT nextval('events.image_files_id_seq'::regclass);


--
-- Name: labels id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.labels ALTER COLUMN id SET DEFAULT nextval('events.labels_id_seq'::regclass);


--
-- Name: logs id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.logs ALTER COLUMN id SET DEFAULT nextval('events.logs_id_seq'::regclass);


--
-- Name: menu_entries id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.menu_entries ALTER COLUMN id SET DEFAULT nextval('events.menu_entries_id_seq'::regclass);


--
-- Name: menu_entry_principals id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.menu_entry_principals ALTER COLUMN id SET DEFAULT nextval('events.menu_entry_principals_id_seq'::regclass);


--
-- Name: note_revisions id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.note_revisions ALTER COLUMN id SET DEFAULT nextval('events.note_revisions_id_seq'::regclass);


--
-- Name: notes id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.notes ALTER COLUMN id SET DEFAULT nextval('events.notes_id_seq'::regclass);


--
-- Name: pages id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.pages ALTER COLUMN id SET DEFAULT nextval('events.pages_id_seq'::regclass);


--
-- Name: payment_transactions id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.payment_transactions ALTER COLUMN id SET DEFAULT nextval('events.payment_transactions_id_seq'::regclass);


--
-- Name: persons id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.persons ALTER COLUMN id SET DEFAULT nextval('events.persons_id_seq'::regclass);


--
-- Name: principals id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.principals ALTER COLUMN id SET DEFAULT nextval('events.principals_id_seq'::regclass);


--
-- Name: reminders id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.reminders ALTER COLUMN id SET DEFAULT nextval('events.reminders_id_seq'::regclass);


--
-- Name: requests id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.requests ALTER COLUMN id SET DEFAULT nextval('events.requests_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.roles ALTER COLUMN id SET DEFAULT nextval('events.roles_id_seq'::regclass);


--
-- Name: series id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.series ALTER COLUMN id SET DEFAULT nextval('events.series_id_seq'::regclass);


--
-- Name: session_block_person_links id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.session_block_person_links ALTER COLUMN id SET DEFAULT nextval('events.session_block_person_links_id_seq'::regclass);


--
-- Name: session_blocks id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.session_blocks ALTER COLUMN id SET DEFAULT nextval('events.session_blocks_id_seq'::regclass);


--
-- Name: session_principals id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.session_principals ALTER COLUMN id SET DEFAULT nextval('events.session_principals_id_seq'::regclass);


--
-- Name: session_types id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.session_types ALTER COLUMN id SET DEFAULT nextval('events.session_types_id_seq'::regclass);


--
-- Name: sessions id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.sessions ALTER COLUMN id SET DEFAULT nextval('events.sessions_id_seq'::regclass);


--
-- Name: settings id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.settings ALTER COLUMN id SET DEFAULT nextval('events.settings_id_seq'::regclass);


--
-- Name: settings_principals id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.settings_principals ALTER COLUMN id SET DEFAULT nextval('events.settings_principals_id_seq'::regclass);


--
-- Name: static_list_links id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.static_list_links ALTER COLUMN id SET DEFAULT nextval('events.static_list_links_id_seq'::regclass);


--
-- Name: static_sites id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.static_sites ALTER COLUMN id SET DEFAULT nextval('events.static_sites_id_seq'::regclass);


--
-- Name: subcontribution_person_links id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.subcontribution_person_links ALTER COLUMN id SET DEFAULT nextval('events.subcontribution_person_links_id_seq'::regclass);


--
-- Name: subcontribution_references id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.subcontribution_references ALTER COLUMN id SET DEFAULT nextval('events.subcontribution_references_id_seq'::regclass);


--
-- Name: subcontributions id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.subcontributions ALTER COLUMN id SET DEFAULT nextval('events.subcontributions_id_seq'::regclass);


--
-- Name: timetable_entries id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.timetable_entries ALTER COLUMN id SET DEFAULT nextval('events.timetable_entries_id_seq'::regclass);


--
-- Name: track_groups id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.track_groups ALTER COLUMN id SET DEFAULT nextval('events.track_groups_id_seq'::regclass);


--
-- Name: track_principals id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.track_principals ALTER COLUMN id SET DEFAULT nextval('events.track_principals_id_seq'::regclass);


--
-- Name: tracks id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.tracks ALTER COLUMN id SET DEFAULT nextval('events.tracks_id_seq'::regclass);


--
-- Name: vc_room_events id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.vc_room_events ALTER COLUMN id SET DEFAULT nextval('events.vc_room_events_id_seq'::regclass);


--
-- Name: vc_rooms id; Type: DEFAULT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.vc_rooms ALTER COLUMN id SET DEFAULT nextval('events.vc_rooms_id_seq'::regclass);


--
-- Name: affiliations id; Type: DEFAULT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.affiliations ALTER COLUMN id SET DEFAULT nextval('indico.affiliations_id_seq'::regclass);


--
-- Name: designer_image_files id; Type: DEFAULT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.designer_image_files ALTER COLUMN id SET DEFAULT nextval('indico.designer_image_files_id_seq'::regclass);


--
-- Name: designer_templates id; Type: DEFAULT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.designer_templates ALTER COLUMN id SET DEFAULT nextval('indico.designer_templates_id_seq'::regclass);


--
-- Name: files id; Type: DEFAULT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.files ALTER COLUMN id SET DEFAULT nextval('indico.files_id_seq'::regclass);


--
-- Name: ip_network_groups id; Type: DEFAULT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.ip_network_groups ALTER COLUMN id SET DEFAULT nextval('indico.ip_network_groups_id_seq'::regclass);


--
-- Name: news id; Type: DEFAULT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.news ALTER COLUMN id SET DEFAULT nextval('indico.news_id_seq'::regclass);


--
-- Name: receipt_templates id; Type: DEFAULT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.receipt_templates ALTER COLUMN id SET DEFAULT nextval('indico.receipt_templates_id_seq'::regclass);


--
-- Name: reference_types id; Type: DEFAULT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.reference_types ALTER COLUMN id SET DEFAULT nextval('indico.reference_types_id_seq'::regclass);


--
-- Name: settings id; Type: DEFAULT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.settings ALTER COLUMN id SET DEFAULT nextval('indico.settings_id_seq'::regclass);


--
-- Name: settings_principals id; Type: DEFAULT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.settings_principals ALTER COLUMN id SET DEFAULT nextval('indico.settings_principals_id_seq'::regclass);


--
-- Name: application_user_links id; Type: DEFAULT; Schema: oauth; Owner: indico
--

ALTER TABLE ONLY oauth.application_user_links ALTER COLUMN id SET DEFAULT nextval('oauth.application_user_links_id_seq'::regclass);


--
-- Name: applications id; Type: DEFAULT; Schema: oauth; Owner: indico
--

ALTER TABLE ONLY oauth.applications ALTER COLUMN id SET DEFAULT nextval('oauth.applications_id_seq'::regclass);


--
-- Name: tokens id; Type: DEFAULT; Schema: oauth; Owner: indico
--

ALTER TABLE ONLY oauth.tokens ALTER COLUMN id SET DEFAULT nextval('oauth.tokens_id_seq'::regclass);


--
-- Name: blocked_rooms id; Type: DEFAULT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.blocked_rooms ALTER COLUMN id SET DEFAULT nextval('roombooking.blocked_rooms_id_seq'::regclass);


--
-- Name: blocking_principals id; Type: DEFAULT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.blocking_principals ALTER COLUMN id SET DEFAULT nextval('roombooking.blocking_principals_id_seq'::regclass);


--
-- Name: blockings id; Type: DEFAULT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.blockings ALTER COLUMN id SET DEFAULT nextval('roombooking.blockings_id_seq'::regclass);


--
-- Name: equipment_types id; Type: DEFAULT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.equipment_types ALTER COLUMN id SET DEFAULT nextval('roombooking.equipment_types_id_seq'::regclass);


--
-- Name: features id; Type: DEFAULT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.features ALTER COLUMN id SET DEFAULT nextval('roombooking.features_id_seq'::regclass);


--
-- Name: location_principals id; Type: DEFAULT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.location_principals ALTER COLUMN id SET DEFAULT nextval('roombooking.location_principals_id_seq'::regclass);


--
-- Name: locations id; Type: DEFAULT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.locations ALTER COLUMN id SET DEFAULT nextval('roombooking.locations_id_seq'::regclass);


--
-- Name: map_areas id; Type: DEFAULT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.map_areas ALTER COLUMN id SET DEFAULT nextval('roombooking.map_areas_id_seq'::regclass);


--
-- Name: photos id; Type: DEFAULT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.photos ALTER COLUMN id SET DEFAULT nextval('roombooking.photos_id_seq'::regclass);


--
-- Name: reservation_edit_logs id; Type: DEFAULT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.reservation_edit_logs ALTER COLUMN id SET DEFAULT nextval('roombooking.reservation_edit_logs_id_seq'::regclass);


--
-- Name: reservation_occurrence_links id; Type: DEFAULT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.reservation_occurrence_links ALTER COLUMN id SET DEFAULT nextval('roombooking.reservation_occurrence_links_id_seq'::regclass);


--
-- Name: reservations id; Type: DEFAULT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.reservations ALTER COLUMN id SET DEFAULT nextval('roombooking.reservations_id_seq'::regclass);


--
-- Name: room_attributes id; Type: DEFAULT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.room_attributes ALTER COLUMN id SET DEFAULT nextval('roombooking.room_attributes_id_seq'::regclass);


--
-- Name: room_bookable_hours id; Type: DEFAULT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.room_bookable_hours ALTER COLUMN id SET DEFAULT nextval('roombooking.room_bookable_hours_id_seq'::regclass);


--
-- Name: room_principals id; Type: DEFAULT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.room_principals ALTER COLUMN id SET DEFAULT nextval('roombooking.room_principals_id_seq'::regclass);


--
-- Name: rooms id; Type: DEFAULT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.rooms ALTER COLUMN id SET DEFAULT nextval('roombooking.rooms_id_seq'::regclass);


--
-- Name: api_keys id; Type: DEFAULT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.api_keys ALTER COLUMN id SET DEFAULT nextval('users.api_keys_id_seq'::regclass);


--
-- Name: data_export_requests id; Type: DEFAULT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.data_export_requests ALTER COLUMN id SET DEFAULT nextval('users.data_export_requests_id_seq'::regclass);


--
-- Name: emails id; Type: DEFAULT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.emails ALTER COLUMN id SET DEFAULT nextval('users.emails_id_seq'::regclass);


--
-- Name: groups id; Type: DEFAULT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.groups ALTER COLUMN id SET DEFAULT nextval('users.groups_id_seq'::regclass);


--
-- Name: identities id; Type: DEFAULT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.identities ALTER COLUMN id SET DEFAULT nextval('users.identities_id_seq'::regclass);


--
-- Name: logs id; Type: DEFAULT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.logs ALTER COLUMN id SET DEFAULT nextval('users.logs_id_seq'::regclass);


--
-- Name: registration_requests id; Type: DEFAULT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.registration_requests ALTER COLUMN id SET DEFAULT nextval('users.registration_requests_id_seq'::regclass);


--
-- Name: settings id; Type: DEFAULT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.settings ALTER COLUMN id SET DEFAULT nextval('users.settings_id_seq'::regclass);


--
-- Name: tokens id; Type: DEFAULT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.tokens ALTER COLUMN id SET DEFAULT nextval('users.tokens_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.users ALTER COLUMN id SET DEFAULT nextval('users.users_id_seq'::regclass);


--
-- Data for Name: attachment_principals; Type: TABLE DATA; Schema: attachments; Owner: indico
--

COPY attachments.attachment_principals (id, attachment_id, type, user_id, local_group_id, mp_group_provider, mp_group_name, event_role_id, category_role_id, registration_form_id) FROM stdin;
\.


--
-- Data for Name: attachments; Type: TABLE DATA; Schema: attachments; Owner: indico
--

COPY attachments.attachments (id, folder_id, user_id, is_deleted, description, modified_dt, type, link_url, title, protection_mode, file_id) FROM stdin;
\.


--
-- Data for Name: files; Type: TABLE DATA; Schema: attachments; Owner: indico
--

COPY attachments.files (id, attachment_id, user_id, filename, content_type, size, md5, storage_backend, storage_file_id, created_dt) FROM stdin;
\.


--
-- Data for Name: folder_principals; Type: TABLE DATA; Schema: attachments; Owner: indico
--

COPY attachments.folder_principals (id, folder_id, type, user_id, local_group_id, mp_group_provider, mp_group_name, event_role_id, category_role_id, registration_form_id) FROM stdin;
\.


--
-- Data for Name: folders; Type: TABLE DATA; Schema: attachments; Owner: indico
--

COPY attachments.folders (id, title, description, is_deleted, is_default, is_always_visible, is_hidden, link_type, category_id, event_id, linked_event_id, session_id, contribution_id, subcontribution_id, protection_mode) FROM stdin;
\.


--
-- Data for Name: legacy_attachment_id_map; Type: TABLE DATA; Schema: attachments; Owner: indico
--

COPY attachments.legacy_attachment_id_map (material_id, resource_id, attachment_id, event_id, session_id, contribution_id, subcontribution_id) FROM stdin;
\.


--
-- Data for Name: legacy_folder_id_map; Type: TABLE DATA; Schema: attachments; Owner: indico
--

COPY attachments.legacy_folder_id_map (material_id, folder_id, event_id, session_id, contribution_id, subcontribution_id) FROM stdin;
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: categories; Owner: indico
--

COPY categories.categories (id, parent_id, is_deleted, "position", visibility, icon_metadata, icon, logo_metadata, logo, timezone, default_event_themes, event_creation_mode, event_creation_notification_emails, event_message_mode, event_message, suggestions_disabled, notify_managers, show_future_months, google_wallet_mode, google_wallet_settings, apple_wallet_mode, apple_wallet_settings, is_flat_view_enabled, default_ticket_template_id, default_badge_template_id, title, description, protection_mode, no_access_contact) FROM stdin;
0	\N	f	1	\N	null	\N	null	\N	Europe/Zurich	{"lecture": "lecture", "meeting": "standard"}	1	{}	0		f	f	0	0	{}	0	{}	f	1	2	Home		0	
\.


--
-- Data for Name: event_move_requests; Type: TABLE DATA; Schema: categories; Owner: indico
--

COPY categories.event_move_requests (id, event_id, category_id, requestor_id, state, requestor_comment, moderator_comment, moderator_id, requested_dt) FROM stdin;
\.


--
-- Data for Name: legacy_id_map; Type: TABLE DATA; Schema: categories; Owner: indico
--

COPY categories.legacy_id_map (legacy_category_id, category_id) FROM stdin;
\.


--
-- Data for Name: logs; Type: TABLE DATA; Schema: categories; Owner: indico
--

COPY categories.logs (id, logged_dt, kind, module, type, summary, data, meta, category_id, realm, user_id) FROM stdin;
\.


--
-- Data for Name: principals; Type: TABLE DATA; Schema: categories; Owner: indico
--

COPY categories.principals (read_access, full_access, permissions, id, category_id, type, user_id, local_group_id, mp_group_provider, mp_group_name, ip_network_group_id, category_role_id) FROM stdin;
\.


--
-- Data for Name: role_members; Type: TABLE DATA; Schema: categories; Owner: indico
--

COPY categories.role_members (role_id, user_id) FROM stdin;
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: categories; Owner: indico
--

COPY categories.roles (id, category_id, name, code, color) FROM stdin;
\.


--
-- Data for Name: settings; Type: TABLE DATA; Schema: categories; Owner: indico
--

COPY categories.settings (id, module, name, value, category_id) FROM stdin;
\.


--
-- Data for Name: abstract_comments; Type: TABLE DATA; Schema: event_abstracts; Owner: indico
--

COPY event_abstracts.abstract_comments (id, user_id, text, modified_by_id, created_dt, modified_dt, is_deleted, abstract_id, visibility) FROM stdin;
\.


--
-- Data for Name: abstract_field_values; Type: TABLE DATA; Schema: event_abstracts; Owner: indico
--

COPY event_abstracts.abstract_field_values (data, abstract_id, contribution_field_id) FROM stdin;
\.


--
-- Data for Name: abstract_person_links; Type: TABLE DATA; Schema: event_abstracts; Owner: indico
--

COPY event_abstracts.abstract_person_links (abstract_id, is_speaker, author_type, id, person_id, first_name, last_name, title, affiliation_id, affiliation, address, phone, display_order) FROM stdin;
\.


--
-- Data for Name: abstract_review_questions; Type: TABLE DATA; Schema: event_abstracts; Owner: indico
--

COPY event_abstracts.abstract_review_questions (id, event_id, field_type, title, no_score, "position", is_deleted, is_required, field_data, description) FROM stdin;
\.


--
-- Data for Name: abstract_review_ratings; Type: TABLE DATA; Schema: event_abstracts; Owner: indico
--

COPY event_abstracts.abstract_review_ratings (id, question_id, review_id, value) FROM stdin;
\.


--
-- Data for Name: abstract_reviews; Type: TABLE DATA; Schema: event_abstracts; Owner: indico
--

COPY event_abstracts.abstract_reviews (id, abstract_id, user_id, track_id, created_dt, modified_dt, comment, proposed_action, proposed_related_abstract_id, proposed_contribution_type_id) FROM stdin;
\.


--
-- Data for Name: abstracts; Type: TABLE DATA; Schema: event_abstracts; Owner: indico
--

COPY event_abstracts.abstracts (id, uuid, friendly_id, event_id, title, submitter_id, submitted_contrib_type_id, submitted_dt, modified_by_id, modified_dt, state, submission_comment, judge_id, judgment_comment, judgment_dt, accepted_track_id, accepted_contrib_type_id, merged_into_id, duplicate_of_id, is_deleted, description) FROM stdin;
\.


--
-- Data for Name: email_logs; Type: TABLE DATA; Schema: event_abstracts; Owner: indico
--

COPY event_abstracts.email_logs (id, abstract_id, email_template_id, user_id, sent_dt, recipients, subject, body, data) FROM stdin;
\.


--
-- Data for Name: email_templates; Type: TABLE DATA; Schema: event_abstracts; Owner: indico
--

COPY event_abstracts.email_templates (id, title, event_id, "position", reply_to_address, subject, body, extra_cc_emails, include_submitter, include_authors, include_coauthors, stop_on_match, rules) FROM stdin;
\.


--
-- Data for Name: files; Type: TABLE DATA; Schema: event_abstracts; Owner: indico
--

COPY event_abstracts.files (id, abstract_id, filename, content_type, size, md5, storage_backend, storage_file_id) FROM stdin;
\.


--
-- Data for Name: proposed_for_tracks; Type: TABLE DATA; Schema: event_abstracts; Owner: indico
--

COPY event_abstracts.proposed_for_tracks (review_id, track_id) FROM stdin;
\.


--
-- Data for Name: reviewed_for_tracks; Type: TABLE DATA; Schema: event_abstracts; Owner: indico
--

COPY event_abstracts.reviewed_for_tracks (abstract_id, track_id) FROM stdin;
\.


--
-- Data for Name: submitted_for_tracks; Type: TABLE DATA; Schema: event_abstracts; Owner: indico
--

COPY event_abstracts.submitted_for_tracks (abstract_id, track_id) FROM stdin;
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: event_editing; Owner: indico
--

COPY event_editing.comments (id, revision_id, user_id, created_dt, modified_dt, is_deleted, internal, system, text) FROM stdin;
\.


--
-- Data for Name: editables; Type: TABLE DATA; Schema: event_editing; Owner: indico
--

COPY event_editing.editables (id, contribution_id, type, editor_id, published_revision_id, is_deleted) FROM stdin;
\.


--
-- Data for Name: file_types; Type: TABLE DATA; Schema: event_editing; Owner: indico
--

COPY event_editing.file_types (id, event_id, type, name, extensions, allow_multiple_files, required, publishable, filename_template) FROM stdin;
\.


--
-- Data for Name: review_condition_file_types; Type: TABLE DATA; Schema: event_editing; Owner: indico
--

COPY event_editing.review_condition_file_types (review_condition_id, file_type_id) FROM stdin;
\.


--
-- Data for Name: review_conditions; Type: TABLE DATA; Schema: event_editing; Owner: indico
--

COPY event_editing.review_conditions (id, type, event_id) FROM stdin;
\.


--
-- Data for Name: revision_files; Type: TABLE DATA; Schema: event_editing; Owner: indico
--

COPY event_editing.revision_files (revision_id, file_id, file_type_id) FROM stdin;
\.


--
-- Data for Name: revision_tags; Type: TABLE DATA; Schema: event_editing; Owner: indico
--

COPY event_editing.revision_tags (revision_id, tag_id) FROM stdin;
\.


--
-- Data for Name: revisions; Type: TABLE DATA; Schema: event_editing; Owner: indico
--

COPY event_editing.revisions (id, editable_id, user_id, created_dt, modified_dt, type, is_undone, comment) FROM stdin;
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: event_editing; Owner: indico
--

COPY event_editing.tags (id, event_id, title, code, color, system) FROM stdin;
\.


--
-- Data for Name: competences; Type: TABLE DATA; Schema: event_paper_reviewing; Owner: indico
--

COPY event_paper_reviewing.competences (id, user_id, event_id, competences) FROM stdin;
\.


--
-- Data for Name: content_reviewers; Type: TABLE DATA; Schema: event_paper_reviewing; Owner: indico
--

COPY event_paper_reviewing.content_reviewers (contribution_id, user_id) FROM stdin;
\.


--
-- Data for Name: files; Type: TABLE DATA; Schema: event_paper_reviewing; Owner: indico
--

COPY event_paper_reviewing.files (id, contribution_id, revision_id, filename, content_type, size, md5, storage_backend, storage_file_id) FROM stdin;
\.


--
-- Data for Name: judges; Type: TABLE DATA; Schema: event_paper_reviewing; Owner: indico
--

COPY event_paper_reviewing.judges (contribution_id, user_id) FROM stdin;
\.


--
-- Data for Name: layout_reviewers; Type: TABLE DATA; Schema: event_paper_reviewing; Owner: indico
--

COPY event_paper_reviewing.layout_reviewers (contribution_id, user_id) FROM stdin;
\.


--
-- Data for Name: review_comments; Type: TABLE DATA; Schema: event_paper_reviewing; Owner: indico
--

COPY event_paper_reviewing.review_comments (id, user_id, text, modified_by_id, created_dt, modified_dt, is_deleted, revision_id, visibility) FROM stdin;
\.


--
-- Data for Name: review_questions; Type: TABLE DATA; Schema: event_paper_reviewing; Owner: indico
--

COPY event_paper_reviewing.review_questions (type, id, event_id, field_type, title, no_score, "position", is_deleted, is_required, field_data, description) FROM stdin;
\.


--
-- Data for Name: review_ratings; Type: TABLE DATA; Schema: event_paper_reviewing; Owner: indico
--

COPY event_paper_reviewing.review_ratings (id, question_id, review_id, value) FROM stdin;
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: event_paper_reviewing; Owner: indico
--

COPY event_paper_reviewing.reviews (id, revision_id, user_id, created_dt, modified_dt, comment, type, proposed_action) FROM stdin;
\.


--
-- Data for Name: revisions; Type: TABLE DATA; Schema: event_paper_reviewing; Owner: indico
--

COPY event_paper_reviewing.revisions (id, state, contribution_id, submitter_id, submitted_dt, judge_id, judgment_dt, judgment_comment) FROM stdin;
\.


--
-- Data for Name: templates; Type: TABLE DATA; Schema: event_paper_reviewing; Owner: indico
--

COPY event_paper_reviewing.templates (id, event_id, name, description, filename, content_type, size, md5, storage_backend, storage_file_id) FROM stdin;
\.


--
-- Data for Name: form_field_data; Type: TABLE DATA; Schema: event_registration; Owner: indico
--

COPY event_registration.form_field_data (id, field_id, versioned_data) FROM stdin;
\.


--
-- Data for Name: form_items; Type: TABLE DATA; Schema: event_registration; Owner: indico
--

COPY event_registration.form_items (id, registration_form_id, type, personal_data_type, parent_id, "position", title, description, is_enabled, is_deleted, is_required, is_manager_only, input_type, data, retention_period, is_purged, current_data_id) FROM stdin;
\.


--
-- Data for Name: forms; Type: TABLE DATA; Schema: event_registration; Owner: indico
--

COPY event_registration.forms (id, event_id, title, is_participation, introduction, contact_info, start_dt, end_dt, modification_mode, modification_end_dt, is_deleted, require_login, require_user, require_captcha, registration_limit, publish_registrations_public, publish_registrations_participants, publish_registrations_duration, publish_registration_count, publish_checkin_enabled, moderation_enabled, private, uuid, base_price, currency, notification_sender_address, message_pending, message_unpaid, message_complete, attach_ical, manager_notifications_enabled, manager_notification_recipients, tickets_enabled, ticket_google_wallet, ticket_apple_wallet, ticket_on_email, ticket_on_event_page, ticket_on_summary_page, tickets_for_accompanying_persons, ticket_template_id, retention_period, is_purged, require_privacy_policy_agreement) FROM stdin;
\.


--
-- Data for Name: invitations; Type: TABLE DATA; Schema: event_registration; Owner: indico
--

COPY event_registration.invitations (id, uuid, registration_form_id, registration_id, state, skip_moderation, skip_access_check, email, first_name, last_name, affiliation) FROM stdin;
\.


--
-- Data for Name: legacy_registration_map; Type: TABLE DATA; Schema: event_registration; Owner: indico
--

COPY event_registration.legacy_registration_map (event_id, legacy_registrant_id, legacy_registrant_key, registration_id) FROM stdin;
\.


--
-- Data for Name: receipt_files; Type: TABLE DATA; Schema: event_registration; Owner: indico
--

COPY event_registration.receipt_files (file_id, registration_id, template_id, template_params, is_published, is_deleted) FROM stdin;
\.


--
-- Data for Name: registration_data; Type: TABLE DATA; Schema: event_registration; Owner: indico
--

COPY event_registration.registration_data (registration_id, field_data_id, data, filename, content_type, size, md5, storage_backend, storage_file_id) FROM stdin;
\.


--
-- Data for Name: registration_tags; Type: TABLE DATA; Schema: event_registration; Owner: indico
--

COPY event_registration.registration_tags (registration_id, registration_tag_id) FROM stdin;
\.


--
-- Data for Name: registrations; Type: TABLE DATA; Schema: event_registration; Owner: indico
--

COPY event_registration.registrations (id, uuid, friendly_id, event_id, registration_form_id, user_id, transaction_id, state, base_price, price_adjustment, currency, submitted_dt, email, first_name, last_name, is_deleted, ticket_uuid, checked_in, checked_in_dt, rejection_reason, consent_to_publish, participant_hidden, created_by_manager, modification_end_dt, apple_wallet_serial) FROM stdin;
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: event_registration; Owner: indico
--

COPY event_registration.tags (id, event_id, title, color) FROM stdin;
\.


--
-- Data for Name: anonymous_submissions; Type: TABLE DATA; Schema: event_surveys; Owner: indico
--

COPY event_surveys.anonymous_submissions (survey_id, user_id) FROM stdin;
\.


--
-- Data for Name: answers; Type: TABLE DATA; Schema: event_surveys; Owner: indico
--

COPY event_surveys.answers (submission_id, question_id, data) FROM stdin;
\.


--
-- Data for Name: items; Type: TABLE DATA; Schema: event_surveys; Owner: indico
--

COPY event_surveys.items (id, survey_id, parent_id, "position", type, title, display_as_section, is_required, field_type, field_data, description) FROM stdin;
\.


--
-- Data for Name: submissions; Type: TABLE DATA; Schema: event_surveys; Owner: indico
--

COPY event_surveys.submissions (id, friendly_id, survey_id, user_id, submitted_dt, is_anonymous, is_submitted, pending_answers) FROM stdin;
\.


--
-- Data for Name: surveys; Type: TABLE DATA; Schema: event_surveys; Owner: indico
--

COPY event_surveys.surveys (id, event_id, title, uuid, introduction, anonymous, require_user, private, submission_limit, start_dt, end_dt, is_deleted, start_notification_sent, notifications_enabled, notify_participants, start_notification_emails, new_submission_emails, partial_completion, last_friendly_submission_id) FROM stdin;
\.


--
-- Data for Name: agreements; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.agreements (id, uuid, event_id, type, identifier, person_email, person_name, state, "timestamp", user_id, signed_dt, signed_from_ip, reason, attachment, attachment_filename, data) FROM stdin;
\.


--
-- Data for Name: breaks; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.breaks (id, title, duration, description, text_color, background_color, inherit_location, room_id, venue_id, venue_name, room_name, address) FROM stdin;
\.


--
-- Data for Name: contribution_field_values; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.contribution_field_values (data, contribution_id, contribution_field_id) FROM stdin;
\.


--
-- Data for Name: contribution_fields; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.contribution_fields (id, event_id, legacy_id, "position", title, description, is_required, is_active, is_user_editable, visibility, field_type, field_data) FROM stdin;
\.


--
-- Data for Name: contribution_person_links; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.contribution_person_links (contribution_id, is_speaker, author_type, id, person_id, first_name, last_name, title, affiliation_id, affiliation, address, phone, display_order) FROM stdin;
\.


--
-- Data for Name: contribution_principals; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.contribution_principals (read_access, full_access, permissions, id, contribution_id, type, user_id, local_group_id, mp_group_provider, mp_group_name, email, event_role_id, category_role_id, registration_form_id) FROM stdin;
\.


--
-- Data for Name: contribution_references; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.contribution_references (id, value, contribution_id, reference_type_id) FROM stdin;
\.


--
-- Data for Name: contribution_types; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.contribution_types (id, event_id, name, description, is_private) FROM stdin;
\.


--
-- Data for Name: contributions; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.contributions (id, friendly_id, event_id, session_id, session_block_id, track_id, abstract_id, type_id, code, duration, board_number, keywords, is_deleted, last_friendly_subcontribution_id, description, title, render_mode, protection_mode, inherit_location, room_id, venue_id, venue_name, room_name, address) FROM stdin;
\.


--
-- Data for Name: event_person_links; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.event_person_links (event_id, id, person_id, first_name, last_name, title, affiliation_id, affiliation, address, phone, display_order) FROM stdin;
\.


--
-- Data for Name: event_references; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.event_references (id, value, event_id, reference_type_id) FROM stdin;
\.


--
-- Data for Name: events; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.events (id, is_deleted, is_locked, creator_id, category_id, series_id, cloned_from_id, label_id, label_message, created_dt, start_dt, end_dt, timezone, type, visibility, keywords, url_shortcut, logo_metadata, logo, stylesheet_metadata, stylesheet, default_page_id, map_url, custom_boa_id, subcontrib_speakers_can_submit, last_friendly_registration_id, last_friendly_contribution_id, last_friendly_session_id, title, description, room_id, venue_id, venue_name, room_name, address, protection_mode, access_key, no_access_contact) FROM stdin;
\.


--
-- Data for Name: image_files; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.image_files (id, event_id, filename, content_type, size, md5, storage_backend, storage_file_id, created_dt) FROM stdin;
\.


--
-- Data for Name: labels; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.labels (id, title, color, is_event_not_happening) FROM stdin;
\.


--
-- Data for Name: legacy_contribution_id_map; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.legacy_contribution_id_map (event_id, legacy_contribution_id, contribution_id) FROM stdin;
\.


--
-- Data for Name: legacy_id_map; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.legacy_id_map (legacy_event_id, event_id) FROM stdin;
\.


--
-- Data for Name: legacy_image_id_map; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.legacy_image_id_map (event_id, legacy_image_id, image_id) FROM stdin;
\.


--
-- Data for Name: legacy_page_id_map; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.legacy_page_id_map (event_id, legacy_page_id, page_id) FROM stdin;
\.


--
-- Data for Name: legacy_session_block_id_map; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.legacy_session_block_id_map (event_id, legacy_session_id, legacy_session_block_id, session_block_id) FROM stdin;
\.


--
-- Data for Name: legacy_session_id_map; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.legacy_session_id_map (event_id, legacy_session_id, session_id) FROM stdin;
\.


--
-- Data for Name: legacy_subcontribution_id_map; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.legacy_subcontribution_id_map (event_id, legacy_contribution_id, legacy_subcontribution_id, subcontribution_id) FROM stdin;
\.


--
-- Data for Name: logs; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.logs (id, logged_dt, kind, module, type, summary, data, meta, event_id, realm, user_id) FROM stdin;
\.


--
-- Data for Name: menu_entries; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.menu_entries (id, parent_id, event_id, is_enabled, title, name, "position", new_tab, link_url, plugin, page_id, type, protection_mode, speakers_can_access) FROM stdin;
\.


--
-- Data for Name: menu_entry_principals; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.menu_entry_principals (id, menu_entry_id, type, user_id, local_group_id, mp_group_provider, mp_group_name, event_role_id, category_role_id, registration_form_id) FROM stdin;
\.


--
-- Data for Name: note_revisions; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.note_revisions (id, note_id, user_id, created_dt, render_mode, source, html) FROM stdin;
\.


--
-- Data for Name: notes; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.notes (id, is_deleted, html, current_revision_id, link_type, event_id, linked_event_id, session_id, contribution_id, subcontribution_id) FROM stdin;
\.


--
-- Data for Name: pages; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.pages (id, event_id, html) FROM stdin;
\.


--
-- Data for Name: payment_transactions; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.payment_transactions (id, registration_id, status, amount, currency, provider, "timestamp", data) FROM stdin;
\.


--
-- Data for Name: persons; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.persons (id, event_id, user_id, first_name, last_name, email, title, affiliation_id, affiliation, address, phone, invited_dt, is_untrusted) FROM stdin;
\.


--
-- Data for Name: principals; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.principals (read_access, full_access, permissions, id, event_id, type, user_id, local_group_id, mp_group_provider, mp_group_name, email, ip_network_group_id, event_role_id, category_role_id, registration_form_id) FROM stdin;
\.


--
-- Data for Name: reminders; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.reminders (id, event_id, creator_id, created_dt, scheduled_dt, is_sent, event_start_delta, recipients, send_to_participants, send_to_speakers, include_summary, include_description, attach_ical, reply_to_address, message) FROM stdin;
\.


--
-- Data for Name: requests; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.requests (id, event_id, type, state, data, created_by_id, created_dt, processed_by_id, processed_dt, comment) FROM stdin;
\.


--
-- Data for Name: role_members; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.role_members (role_id, user_id) FROM stdin;
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.roles (id, event_id, name, code, color) FROM stdin;
\.


--
-- Data for Name: series; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.series (id, show_sequence_in_title, show_links, event_title_pattern) FROM stdin;
\.


--
-- Data for Name: session_block_person_links; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.session_block_person_links (session_block_id, id, person_id, first_name, last_name, title, affiliation_id, affiliation, address, phone, display_order) FROM stdin;
\.


--
-- Data for Name: session_blocks; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.session_blocks (id, session_id, title, code, duration, inherit_location, room_id, venue_id, venue_name, room_name, address) FROM stdin;
\.


--
-- Data for Name: session_principals; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.session_principals (read_access, full_access, permissions, id, session_id, type, user_id, local_group_id, mp_group_provider, mp_group_name, email, event_role_id, category_role_id, registration_form_id) FROM stdin;
\.


--
-- Data for Name: session_types; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.session_types (id, event_id, name, code, is_poster) FROM stdin;
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.sessions (id, friendly_id, event_id, type_id, title, code, default_contribution_duration, is_deleted, description, text_color, background_color, protection_mode, inherit_location, room_id, venue_id, venue_name, room_name, address) FROM stdin;
\.


--
-- Data for Name: settings; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.settings (id, module, name, value, event_id) FROM stdin;
\.


--
-- Data for Name: settings_principals; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.settings_principals (id, module, name, type, user_id, local_group_id, mp_group_provider, mp_group_name, event_role_id, category_role_id, event_id) FROM stdin;
\.


--
-- Data for Name: static_list_links; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.static_list_links (id, event_id, type, uuid, created_dt, last_used_dt, data) FROM stdin;
\.


--
-- Data for Name: static_sites; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.static_sites (id, event_id, state, requested_dt, creator_id, filename, content_type, size, md5, storage_backend, storage_file_id) FROM stdin;
\.


--
-- Data for Name: subcontribution_person_links; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.subcontribution_person_links (subcontribution_id, id, person_id, first_name, last_name, title, affiliation_id, affiliation, address, phone, display_order) FROM stdin;
\.


--
-- Data for Name: subcontribution_references; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.subcontribution_references (id, value, subcontribution_id, reference_type_id) FROM stdin;
\.


--
-- Data for Name: subcontributions; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.subcontributions (id, friendly_id, contribution_id, "position", code, duration, is_deleted, description, title, render_mode) FROM stdin;
\.


--
-- Data for Name: timetable_entries; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.timetable_entries (id, event_id, parent_id, session_block_id, contribution_id, break_id, type, start_dt) FROM stdin;
\.


--
-- Data for Name: track_groups; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.track_groups (id, title, "position", event_id, description) FROM stdin;
\.


--
-- Data for Name: track_principals; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.track_principals (read_access, full_access, permissions, id, track_id, type, user_id, local_group_id, mp_group_provider, mp_group_name, event_role_id, category_role_id) FROM stdin;
\.


--
-- Data for Name: tracks; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.tracks (id, title, code, event_id, "position", default_session_id, track_group_id, description) FROM stdin;
\.


--
-- Data for Name: vc_room_events; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.vc_room_events (id, event_id, vc_room_id, link_type, linked_event_id, session_block_id, contribution_id, show, data) FROM stdin;
\.


--
-- Data for Name: vc_rooms; Type: TABLE DATA; Schema: events; Owner: indico
--

COPY events.vc_rooms (id, type, name, status, created_by_id, created_dt, modified_dt, data) FROM stdin;
\.


--
-- Data for Name: affiliations; Type: TABLE DATA; Schema: indico; Owner: indico
--

COPY indico.affiliations (id, name, alt_names, is_deleted, street, postcode, city, country_code, meta) FROM stdin;
\.


--
-- Data for Name: designer_image_files; Type: TABLE DATA; Schema: indico; Owner: indico
--

COPY indico.designer_image_files (id, template_id, filename, content_type, size, md5, storage_backend, storage_file_id, created_dt) FROM stdin;
\.


--
-- Data for Name: designer_templates; Type: TABLE DATA; Schema: indico; Owner: indico
--

COPY indico.designer_templates (id, type, title, registration_form_id, event_id, category_id, data, background_image_id, backside_template_id, is_clonable, is_system_template) FROM stdin;
1	1	Default ticket	\N	\N	0	{"items": [{"x": 330, "y": 190, "id": 0, "bold": false, "text": "Fixed text", "type": "event_title", "color": "black", "width": 400, "height": null, "italic": false, "selected": false, "font_size": "24pt", "text_align": "center", "font_family": "sans-serif"}, {"x": 50, "y": 50, "id": 1, "bold": false, "text": "Fixed text", "type": "event_dates", "color": "black", "width": 400, "height": null, "italic": false, "selected": false, "font_size": "15pt", "text_align": "left", "font_family": "sans-serif"}, {"x": 230, "y": 350, "id": 2, "bold": false, "text": "Fixed text", "type": "affiliation", "color": "black", "width": 400, "height": null, "italic": false, "selected": false, "font_size": "15pt", "text_align": "left", "font_family": "sans-serif"}, {"x": 230, "y": 310, "id": 3, "bold": false, "text": "Fixed text", "type": "full_name_b", "color": "black", "width": 400, "height": null, "italic": false, "selected": false, "font_size": "15pt", "text_align": "left", "font_family": "sans-serif"}, {"x": 50, "y": 130, "id": 4, "bold": false, "text": "Fixed text", "type": "event_venue", "color": "black", "width": 400, "height": null, "italic": false, "selected": true, "font_size": "13.5pt", "text_align": "left", "font_family": "sans-serif"}, {"x": 50, "y": 270, "id": 5, "bold": false, "text": "Fixed text", "type": "ticket_qr_code", "color": "black", "width": 150, "height": 150, "italic": false, "selected": false, "font_size": "15pt", "text_align": "center", "font_family": "sans-serif"}, {"x": 50, "y": 90, "id": 6, "bold": false, "text": "Fixed text", "type": "event_room", "color": "black", "width": 400, "height": null, "italic": false, "selected": false, "font_size": "13.5pt", "text_align": "left", "font_family": "sans-serif"}], "width": 850, "height": 1350, "background_position": "stretch"}	\N	\N	t	t
2	1	Default badge	\N	\N	0	{"items": [{"x": 129, "y": 42, "id": 0, "bold": false, "text": "Fixed text", "type": "event_title", "color": "black", "width": 275, "height": null, "italic": false, "selected": false, "font_size": "10pt", "text_align": "right", "font_family": "sans-serif"}, {"x": 128, "y": 85, "id": 1, "bold": false, "text": "Fixed text", "type": "event_dates", "color": "black", "width": 275, "height": null, "italic": false, "selected": false, "font_size": "7pt", "text_align": "right", "font_family": "sans-serif"}, {"x": 20, "y": 168, "id": 2, "bold": false, "text": "Fixed text", "type": "affiliation", "color": "black", "width": 385, "height": null, "italic": false, "selected": false, "font_size": "10pt", "text_align": "left", "font_family": "sans-serif"}, {"x": 20, "y": 123, "id": 3, "bold": true, "text": "Fixed text", "type": "full_name_b", "color": "black", "width": 385, "height": null, "italic": false, "selected": false, "font_size": "12pt", "text_align": "left", "font_family": "sans-serif"}, {"x": 20, "y": 194, "id": 4, "bold": false, "text": "Fixed text", "type": "position", "color": "black", "width": 385, "height": null, "italic": false, "selected": false, "font_size": "7.5pt", "text_align": "left", "font_family": "sans-serif"}, {"x": 20, "y": 218, "id": 5, "bold": false, "text": "Fixed text", "type": "country", "color": "black", "width": 385, "height": null, "italic": false, "selected": false, "font_size": "7pt", "text_align": "left", "font_family": "sans-serif"}], "width": 425, "height": 270, "background_position": "stretch"}	\N	\N	t	t
\.


--
-- Data for Name: files; Type: TABLE DATA; Schema: indico; Owner: indico
--

COPY indico.files (id, uuid, claimed, meta, filename, content_type, size, md5, storage_backend, storage_file_id, created_dt) FROM stdin;
\.


--
-- Data for Name: ip_network_groups; Type: TABLE DATA; Schema: indico; Owner: indico
--

COPY indico.ip_network_groups (id, name, description, hidden, attachment_access_override) FROM stdin;
\.


--
-- Data for Name: ip_networks; Type: TABLE DATA; Schema: indico; Owner: indico
--

COPY indico.ip_networks (group_id, network) FROM stdin;
\.


--
-- Data for Name: news; Type: TABLE DATA; Schema: indico; Owner: indico
--

COPY indico.news (id, created_dt, title, content) FROM stdin;
\.


--
-- Data for Name: receipt_templates; Type: TABLE DATA; Schema: indico; Owner: indico
--

COPY indico.receipt_templates (id, title, event_id, category_id, html, css, yaml, default_filename, is_deleted) FROM stdin;
\.


--
-- Data for Name: reference_types; Type: TABLE DATA; Schema: indico; Owner: indico
--

COPY indico.reference_types (id, name, scheme, url_template) FROM stdin;
\.


--
-- Data for Name: settings; Type: TABLE DATA; Schema: indico; Owner: indico
--

COPY indico.settings (id, module, name, value) FROM stdin;
\.


--
-- Data for Name: settings_principals; Type: TABLE DATA; Schema: indico; Owner: indico
--

COPY indico.settings_principals (id, module, name, type, user_id, local_group_id, mp_group_provider, mp_group_name) FROM stdin;
\.


--
-- Data for Name: application_user_links; Type: TABLE DATA; Schema: oauth; Owner: indico
--

COPY oauth.application_user_links (id, application_id, user_id, scopes) FROM stdin;
\.


--
-- Data for Name: applications; Type: TABLE DATA; Schema: oauth; Owner: indico
--

COPY oauth.applications (id, name, description, client_id, client_secret, allowed_scopes, redirect_uris, is_enabled, is_trusted, allow_pkce_flow, system_app_type) FROM stdin;
1	Checkin App	The checkin app for mobile devices allows scanning ticket QR codes and checking-in event participants.	11382bbb-974b-43f0-888e-11e555b3cbc4	f276536f-63e3-4a9b-a608-5a56e2e5a91e	{registrants}	{https://checkin.getindico.io/,http://localhost}	t	t	t	1
\.


--
-- Data for Name: tokens; Type: TABLE DATA; Schema: oauth; Owner: indico
--

COPY oauth.tokens (id, access_token_hash, scopes, created_dt, last_used_dt, last_used_ip, use_count, app_user_link_id) FROM stdin;
\.


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: indico
--

COPY public.alembic_version (version_num) FROM stdin;
4615aff776e0
\.


--
-- Data for Name: blocked_rooms; Type: TABLE DATA; Schema: roombooking; Owner: indico
--

COPY roombooking.blocked_rooms (id, state, rejected_by, rejection_reason, blocking_id, room_id) FROM stdin;
\.


--
-- Data for Name: blocking_principals; Type: TABLE DATA; Schema: roombooking; Owner: indico
--

COPY roombooking.blocking_principals (id, blocking_id, type, user_id, local_group_id, mp_group_provider, mp_group_name) FROM stdin;
\.


--
-- Data for Name: blockings; Type: TABLE DATA; Schema: roombooking; Owner: indico
--

COPY roombooking.blockings (id, created_by_id, created_dt, start_date, end_date, reason) FROM stdin;
\.


--
-- Data for Name: equipment_features; Type: TABLE DATA; Schema: roombooking; Owner: indico
--

COPY roombooking.equipment_features (equipment_id, feature_id) FROM stdin;
\.


--
-- Data for Name: equipment_types; Type: TABLE DATA; Schema: roombooking; Owner: indico
--

COPY roombooking.equipment_types (id, name) FROM stdin;
\.


--
-- Data for Name: favorite_rooms; Type: TABLE DATA; Schema: roombooking; Owner: indico
--

COPY roombooking.favorite_rooms (user_id, room_id) FROM stdin;
\.


--
-- Data for Name: features; Type: TABLE DATA; Schema: roombooking; Owner: indico
--

COPY roombooking.features (id, name, title, icon) FROM stdin;
\.


--
-- Data for Name: location_principals; Type: TABLE DATA; Schema: roombooking; Owner: indico
--

COPY roombooking.location_principals (read_access, full_access, permissions, id, location_id, type, user_id, local_group_id, mp_group_provider, mp_group_name) FROM stdin;
\.


--
-- Data for Name: locations; Type: TABLE DATA; Schema: roombooking; Owner: indico
--

COPY roombooking.locations (id, name, map_url_template, room_name_format, is_deleted) FROM stdin;
\.


--
-- Data for Name: map_areas; Type: TABLE DATA; Schema: roombooking; Owner: indico
--

COPY roombooking.map_areas (id, name, is_default, top_left_latitude, top_left_longitude, bottom_right_latitude, bottom_right_longitude) FROM stdin;
\.


--
-- Data for Name: photos; Type: TABLE DATA; Schema: roombooking; Owner: indico
--

COPY roombooking.photos (id, data) FROM stdin;
\.


--
-- Data for Name: reservation_edit_logs; Type: TABLE DATA; Schema: roombooking; Owner: indico
--

COPY roombooking.reservation_edit_logs (id, "timestamp", info, user_name, reservation_id) FROM stdin;
\.


--
-- Data for Name: reservation_occurrence_links; Type: TABLE DATA; Schema: roombooking; Owner: indico
--

COPY roombooking.reservation_occurrence_links (id, link_type, event_id, linked_event_id, session_block_id, contribution_id) FROM stdin;
\.


--
-- Data for Name: reservation_occurrences; Type: TABLE DATA; Schema: roombooking; Owner: indico
--

COPY roombooking.reservation_occurrences (reservation_id, link_id, start_dt, end_dt, notification_sent, state, rejection_reason) FROM stdin;
\.


--
-- Data for Name: reservations; Type: TABLE DATA; Schema: roombooking; Owner: indico
--

COPY roombooking.reservations (id, created_dt, start_dt, end_dt, repeat_frequency, repeat_interval, recurrence_weekdays, booked_for_id, booked_for_name, created_by_id, room_id, state, booking_reason, rejection_reason, end_notification_sent, internal_note) FROM stdin;
\.


--
-- Data for Name: room_attribute_values; Type: TABLE DATA; Schema: roombooking; Owner: indico
--

COPY roombooking.room_attribute_values (attribute_id, room_id, value) FROM stdin;
\.


--
-- Data for Name: room_attributes; Type: TABLE DATA; Schema: roombooking; Owner: indico
--

COPY roombooking.room_attributes (id, name, title, is_hidden) FROM stdin;
\.


--
-- Data for Name: room_bookable_hours; Type: TABLE DATA; Schema: roombooking; Owner: indico
--

COPY roombooking.room_bookable_hours (id, start_time, end_time, weekday, room_id) FROM stdin;
\.


--
-- Data for Name: room_equipment; Type: TABLE DATA; Schema: roombooking; Owner: indico
--

COPY roombooking.room_equipment (equipment_id, room_id) FROM stdin;
\.


--
-- Data for Name: room_nonbookable_periods; Type: TABLE DATA; Schema: roombooking; Owner: indico
--

COPY roombooking.room_nonbookable_periods (start_dt, end_dt, room_id) FROM stdin;
\.


--
-- Data for Name: room_principals; Type: TABLE DATA; Schema: roombooking; Owner: indico
--

COPY roombooking.room_principals (read_access, full_access, permissions, id, room_id, type, user_id, local_group_id, mp_group_provider, mp_group_name) FROM stdin;
\.


--
-- Data for Name: rooms; Type: TABLE DATA; Schema: roombooking; Owner: indico
--

COPY roombooking.rooms (id, location_id, photo_id, verbose_name, site, division, building, floor, number, notification_emails, notification_before_days, notification_before_days_weekly, notification_before_days_monthly, end_notification_daily, end_notification_weekly, end_notification_monthly, reservations_need_confirmation, notifications_enabled, end_notifications_enabled, telephone, key_location, capacity, surface_area, longitude, latitude, comments, owner_id, is_deleted, is_reservable, max_advance_days, booking_limit_days, protection_mode) FROM stdin;
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: users; Owner: indico
--

COPY users.api_keys (id, token, secret, user_id, is_active, is_blocked, is_persistent_allowed, created_dt, last_used_dt, last_used_ip, last_used_uri, last_used_auth, use_count) FROM stdin;
\.


--
-- Data for Name: data_export_requests; Type: TABLE DATA; Schema: users; Owner: indico
--

COPY users.data_export_requests (id, user_id, file_id, requested_dt, selected_options, include_files, state, max_size_exceeded) FROM stdin;
\.


--
-- Data for Name: emails; Type: TABLE DATA; Schema: users; Owner: indico
--

COPY users.emails (id, user_id, email, is_primary, is_user_deleted) FROM stdin;
1	1	admin@admin.com	t	f
\.


--
-- Data for Name: favorite_categories; Type: TABLE DATA; Schema: users; Owner: indico
--

COPY users.favorite_categories (user_id, target_id) FROM stdin;
\.


--
-- Data for Name: favorite_events; Type: TABLE DATA; Schema: users; Owner: indico
--

COPY users.favorite_events (user_id, target_id) FROM stdin;
\.


--
-- Data for Name: favorite_users; Type: TABLE DATA; Schema: users; Owner: indico
--

COPY users.favorite_users (user_id, target_id) FROM stdin;
1	1
\.


--
-- Data for Name: group_members; Type: TABLE DATA; Schema: users; Owner: indico
--

COPY users.group_members (group_id, user_id) FROM stdin;
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: users; Owner: indico
--

COPY users.groups (id, name) FROM stdin;
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: users; Owner: indico
--

COPY users.identities (id, user_id, provider, identifier, multipass_data, data, password_hash, last_login_dt, last_login_ip) FROM stdin;
1	1	indico	admin	null	{}	$2b$12$5zhsQ/lVJTSCC702oNIEQeXF3lgMk32JXvysu6uGjXi4u7URq3CUS	\N	\N
\.


--
-- Data for Name: logs; Type: TABLE DATA; Schema: users; Owner: indico
--

COPY users.logs (id, logged_dt, kind, module, type, summary, data, meta, target_user_id, realm, user_id) FROM stdin;
1	2026-09-16 07:57:57.671732	2	User	simple	User created	{"Moderated": true, "Provider": "indico", "Identifier": "admin"}	{}	1	1	\N
\.


--
-- Data for Name: registration_requests; Type: TABLE DATA; Schema: users; Owner: indico
--

COPY users.registration_requests (id, comment, email, extra_emails, user_data, identity_data, settings) FROM stdin;
\.


--
-- Data for Name: settings; Type: TABLE DATA; Schema: users; Owner: indico
--

COPY users.settings (id, module, name, value, user_id) FROM stdin;
1	users	lang	"en_GB"	1
2	users	timezone	"Europe/Zurich"	1
3	users	suggest_categories	false	1
\.


--
-- Data for Name: suggested_categories; Type: TABLE DATA; Schema: users; Owner: indico
--

COPY users.suggested_categories (user_id, category_id, is_ignored, score) FROM stdin;
\.


--
-- Data for Name: tokens; Type: TABLE DATA; Schema: users; Owner: indico
--

COPY users.tokens (id, access_token_hash, scopes, created_dt, last_used_dt, last_used_ip, use_count, user_id, name, revoked_dt) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: users; Owner: indico
--

COPY users.users (id, first_name, last_name, title, affiliation, affiliation_id, phone, address, merged_into_id, is_system, is_admin, is_blocked, is_pending, is_deleted, accepted_terms_dt, signing_secret, picture, picture_metadata, picture_source, created_dt) FROM stdin;
0	Indico	System	0		\N			\N	t	f	f	f	f	\N	9e7c3bf4-2cb7-41cb-901d-b230e88a7db9	\N	null	0	2026-09-16 07:57:50.764351
1	Admin	User	0	WebTestPilot	\N			\N	f	t	f	f	f	\N	1d47457a-23a8-4557-803a-7c2243976d2b	\N	null	0	2026-09-16 07:57:57.392776
\.


--
-- Name: attachment_principals_id_seq; Type: SEQUENCE SET; Schema: attachments; Owner: indico
--

SELECT pg_catalog.setval('attachments.attachment_principals_id_seq', 1, false);


--
-- Name: attachments_id_seq; Type: SEQUENCE SET; Schema: attachments; Owner: indico
--

SELECT pg_catalog.setval('attachments.attachments_id_seq', 1, false);


--
-- Name: files_id_seq; Type: SEQUENCE SET; Schema: attachments; Owner: indico
--

SELECT pg_catalog.setval('attachments.files_id_seq', 1, false);


--
-- Name: folder_principals_id_seq; Type: SEQUENCE SET; Schema: attachments; Owner: indico
--

SELECT pg_catalog.setval('attachments.folder_principals_id_seq', 1, false);


--
-- Name: folders_id_seq; Type: SEQUENCE SET; Schema: attachments; Owner: indico
--

SELECT pg_catalog.setval('attachments.folders_id_seq', 1, false);


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: categories; Owner: indico
--

SELECT pg_catalog.setval('categories.categories_id_seq', 1, false);


--
-- Name: event_move_requests_id_seq; Type: SEQUENCE SET; Schema: categories; Owner: indico
--

SELECT pg_catalog.setval('categories.event_move_requests_id_seq', 1, false);


--
-- Name: logs_id_seq; Type: SEQUENCE SET; Schema: categories; Owner: indico
--

SELECT pg_catalog.setval('categories.logs_id_seq', 1, false);


--
-- Name: principals_id_seq; Type: SEQUENCE SET; Schema: categories; Owner: indico
--

SELECT pg_catalog.setval('categories.principals_id_seq', 1, false);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: categories; Owner: indico
--

SELECT pg_catalog.setval('categories.roles_id_seq', 1, false);


--
-- Name: settings_id_seq; Type: SEQUENCE SET; Schema: categories; Owner: indico
--

SELECT pg_catalog.setval('categories.settings_id_seq', 1, false);


--
-- Name: abstract_comments_id_seq; Type: SEQUENCE SET; Schema: event_abstracts; Owner: indico
--

SELECT pg_catalog.setval('event_abstracts.abstract_comments_id_seq', 1, false);


--
-- Name: abstract_person_links_id_seq; Type: SEQUENCE SET; Schema: event_abstracts; Owner: indico
--

SELECT pg_catalog.setval('event_abstracts.abstract_person_links_id_seq', 1, false);


--
-- Name: abstract_review_questions_id_seq; Type: SEQUENCE SET; Schema: event_abstracts; Owner: indico
--

SELECT pg_catalog.setval('event_abstracts.abstract_review_questions_id_seq', 1, false);


--
-- Name: abstract_review_ratings_id_seq; Type: SEQUENCE SET; Schema: event_abstracts; Owner: indico
--

SELECT pg_catalog.setval('event_abstracts.abstract_review_ratings_id_seq', 1, false);


--
-- Name: abstract_reviews_id_seq; Type: SEQUENCE SET; Schema: event_abstracts; Owner: indico
--

SELECT pg_catalog.setval('event_abstracts.abstract_reviews_id_seq', 1, false);


--
-- Name: abstracts_id_seq; Type: SEQUENCE SET; Schema: event_abstracts; Owner: indico
--

SELECT pg_catalog.setval('event_abstracts.abstracts_id_seq', 1, false);


--
-- Name: email_logs_id_seq; Type: SEQUENCE SET; Schema: event_abstracts; Owner: indico
--

SELECT pg_catalog.setval('event_abstracts.email_logs_id_seq', 1, false);


--
-- Name: email_templates_id_seq; Type: SEQUENCE SET; Schema: event_abstracts; Owner: indico
--

SELECT pg_catalog.setval('event_abstracts.email_templates_id_seq', 1, false);


--
-- Name: files_id_seq; Type: SEQUENCE SET; Schema: event_abstracts; Owner: indico
--

SELECT pg_catalog.setval('event_abstracts.files_id_seq', 1, false);


--
-- Name: comments_id_seq; Type: SEQUENCE SET; Schema: event_editing; Owner: indico
--

SELECT pg_catalog.setval('event_editing.comments_id_seq', 1, false);


--
-- Name: editables_id_seq; Type: SEQUENCE SET; Schema: event_editing; Owner: indico
--

SELECT pg_catalog.setval('event_editing.editables_id_seq', 1, false);


--
-- Name: file_types_id_seq; Type: SEQUENCE SET; Schema: event_editing; Owner: indico
--

SELECT pg_catalog.setval('event_editing.file_types_id_seq', 1, false);


--
-- Name: review_conditions_id_seq; Type: SEQUENCE SET; Schema: event_editing; Owner: indico
--

SELECT pg_catalog.setval('event_editing.review_conditions_id_seq', 1, false);


--
-- Name: revisions_id_seq; Type: SEQUENCE SET; Schema: event_editing; Owner: indico
--

SELECT pg_catalog.setval('event_editing.revisions_id_seq', 1, false);


--
-- Name: tags_id_seq; Type: SEQUENCE SET; Schema: event_editing; Owner: indico
--

SELECT pg_catalog.setval('event_editing.tags_id_seq', 1, false);


--
-- Name: competences_id_seq; Type: SEQUENCE SET; Schema: event_paper_reviewing; Owner: indico
--

SELECT pg_catalog.setval('event_paper_reviewing.competences_id_seq', 1, false);


--
-- Name: files_id_seq; Type: SEQUENCE SET; Schema: event_paper_reviewing; Owner: indico
--

SELECT pg_catalog.setval('event_paper_reviewing.files_id_seq', 1, false);


--
-- Name: review_comments_id_seq; Type: SEQUENCE SET; Schema: event_paper_reviewing; Owner: indico
--

SELECT pg_catalog.setval('event_paper_reviewing.review_comments_id_seq', 1, false);


--
-- Name: review_questions_id_seq; Type: SEQUENCE SET; Schema: event_paper_reviewing; Owner: indico
--

SELECT pg_catalog.setval('event_paper_reviewing.review_questions_id_seq', 1, false);


--
-- Name: review_ratings_id_seq; Type: SEQUENCE SET; Schema: event_paper_reviewing; Owner: indico
--

SELECT pg_catalog.setval('event_paper_reviewing.review_ratings_id_seq', 1, false);


--
-- Name: reviews_id_seq; Type: SEQUENCE SET; Schema: event_paper_reviewing; Owner: indico
--

SELECT pg_catalog.setval('event_paper_reviewing.reviews_id_seq', 1, false);


--
-- Name: revisions_id_seq; Type: SEQUENCE SET; Schema: event_paper_reviewing; Owner: indico
--

SELECT pg_catalog.setval('event_paper_reviewing.revisions_id_seq', 1, false);


--
-- Name: templates_id_seq; Type: SEQUENCE SET; Schema: event_paper_reviewing; Owner: indico
--

SELECT pg_catalog.setval('event_paper_reviewing.templates_id_seq', 1, false);


--
-- Name: form_field_data_id_seq; Type: SEQUENCE SET; Schema: event_registration; Owner: indico
--

SELECT pg_catalog.setval('event_registration.form_field_data_id_seq', 1, false);


--
-- Name: form_items_id_seq; Type: SEQUENCE SET; Schema: event_registration; Owner: indico
--

SELECT pg_catalog.setval('event_registration.form_items_id_seq', 1, false);


--
-- Name: forms_id_seq; Type: SEQUENCE SET; Schema: event_registration; Owner: indico
--

SELECT pg_catalog.setval('event_registration.forms_id_seq', 1, false);


--
-- Name: invitations_id_seq; Type: SEQUENCE SET; Schema: event_registration; Owner: indico
--

SELECT pg_catalog.setval('event_registration.invitations_id_seq', 1, false);


--
-- Name: registrations_id_seq; Type: SEQUENCE SET; Schema: event_registration; Owner: indico
--

SELECT pg_catalog.setval('event_registration.registrations_id_seq', 1, false);


--
-- Name: tags_id_seq; Type: SEQUENCE SET; Schema: event_registration; Owner: indico
--

SELECT pg_catalog.setval('event_registration.tags_id_seq', 1, false);


--
-- Name: items_id_seq; Type: SEQUENCE SET; Schema: event_surveys; Owner: indico
--

SELECT pg_catalog.setval('event_surveys.items_id_seq', 1, false);


--
-- Name: submissions_id_seq; Type: SEQUENCE SET; Schema: event_surveys; Owner: indico
--

SELECT pg_catalog.setval('event_surveys.submissions_id_seq', 1, false);


--
-- Name: surveys_id_seq; Type: SEQUENCE SET; Schema: event_surveys; Owner: indico
--

SELECT pg_catalog.setval('event_surveys.surveys_id_seq', 1, false);


--
-- Name: agreements_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.agreements_id_seq', 1, false);


--
-- Name: breaks_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.breaks_id_seq', 1, false);


--
-- Name: contribution_fields_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.contribution_fields_id_seq', 1, false);


--
-- Name: contribution_person_links_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.contribution_person_links_id_seq', 1, false);


--
-- Name: contribution_principals_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.contribution_principals_id_seq', 1, false);


--
-- Name: contribution_references_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.contribution_references_id_seq', 1, false);


--
-- Name: contribution_types_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.contribution_types_id_seq', 1, false);


--
-- Name: contributions_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.contributions_id_seq', 1, false);


--
-- Name: event_person_links_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.event_person_links_id_seq', 1, false);


--
-- Name: event_references_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.event_references_id_seq', 1, false);


--
-- Name: events_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.events_id_seq', 1, false);


--
-- Name: image_files_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.image_files_id_seq', 1, false);


--
-- Name: labels_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.labels_id_seq', 1, false);


--
-- Name: logs_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.logs_id_seq', 1, false);


--
-- Name: menu_entries_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.menu_entries_id_seq', 1, false);


--
-- Name: menu_entry_principals_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.menu_entry_principals_id_seq', 1, false);


--
-- Name: note_revisions_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.note_revisions_id_seq', 1, false);


--
-- Name: notes_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.notes_id_seq', 1, false);


--
-- Name: pages_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.pages_id_seq', 1, false);


--
-- Name: payment_transactions_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.payment_transactions_id_seq', 1, false);


--
-- Name: persons_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.persons_id_seq', 1, false);


--
-- Name: principals_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.principals_id_seq', 1, false);


--
-- Name: reminders_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.reminders_id_seq', 1, false);


--
-- Name: requests_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.requests_id_seq', 1, false);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.roles_id_seq', 1, false);


--
-- Name: series_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.series_id_seq', 1, false);


--
-- Name: session_block_person_links_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.session_block_person_links_id_seq', 1, false);


--
-- Name: session_blocks_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.session_blocks_id_seq', 1, false);


--
-- Name: session_principals_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.session_principals_id_seq', 1, false);


--
-- Name: session_types_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.session_types_id_seq', 1, false);


--
-- Name: sessions_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.sessions_id_seq', 1, false);


--
-- Name: settings_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.settings_id_seq', 1, false);


--
-- Name: settings_principals_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.settings_principals_id_seq', 1, false);


--
-- Name: static_list_links_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.static_list_links_id_seq', 1, false);


--
-- Name: static_sites_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.static_sites_id_seq', 1, false);


--
-- Name: subcontribution_person_links_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.subcontribution_person_links_id_seq', 1, false);


--
-- Name: subcontribution_references_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.subcontribution_references_id_seq', 1, false);


--
-- Name: subcontributions_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.subcontributions_id_seq', 1, false);


--
-- Name: timetable_entries_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.timetable_entries_id_seq', 1, false);


--
-- Name: track_groups_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.track_groups_id_seq', 1, false);


--
-- Name: track_principals_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.track_principals_id_seq', 1, false);


--
-- Name: tracks_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.tracks_id_seq', 1, false);


--
-- Name: vc_room_events_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.vc_room_events_id_seq', 1, false);


--
-- Name: vc_rooms_id_seq; Type: SEQUENCE SET; Schema: events; Owner: indico
--

SELECT pg_catalog.setval('events.vc_rooms_id_seq', 1, false);


--
-- Name: affiliations_id_seq; Type: SEQUENCE SET; Schema: indico; Owner: indico
--

SELECT pg_catalog.setval('indico.affiliations_id_seq', 1, false);


--
-- Name: designer_image_files_id_seq; Type: SEQUENCE SET; Schema: indico; Owner: indico
--

SELECT pg_catalog.setval('indico.designer_image_files_id_seq', 1, false);


--
-- Name: designer_templates_id_seq; Type: SEQUENCE SET; Schema: indico; Owner: indico
--

SELECT pg_catalog.setval('indico.designer_templates_id_seq', 2, true);


--
-- Name: files_id_seq; Type: SEQUENCE SET; Schema: indico; Owner: indico
--

SELECT pg_catalog.setval('indico.files_id_seq', 1, false);


--
-- Name: ip_network_groups_id_seq; Type: SEQUENCE SET; Schema: indico; Owner: indico
--

SELECT pg_catalog.setval('indico.ip_network_groups_id_seq', 1, false);


--
-- Name: news_id_seq; Type: SEQUENCE SET; Schema: indico; Owner: indico
--

SELECT pg_catalog.setval('indico.news_id_seq', 1, false);


--
-- Name: receipt_templates_id_seq; Type: SEQUENCE SET; Schema: indico; Owner: indico
--

SELECT pg_catalog.setval('indico.receipt_templates_id_seq', 1, false);


--
-- Name: reference_types_id_seq; Type: SEQUENCE SET; Schema: indico; Owner: indico
--

SELECT pg_catalog.setval('indico.reference_types_id_seq', 1, false);


--
-- Name: settings_id_seq; Type: SEQUENCE SET; Schema: indico; Owner: indico
--

SELECT pg_catalog.setval('indico.settings_id_seq', 1, false);


--
-- Name: settings_principals_id_seq; Type: SEQUENCE SET; Schema: indico; Owner: indico
--

SELECT pg_catalog.setval('indico.settings_principals_id_seq', 1, false);


--
-- Name: application_user_links_id_seq; Type: SEQUENCE SET; Schema: oauth; Owner: indico
--

SELECT pg_catalog.setval('oauth.application_user_links_id_seq', 1, false);


--
-- Name: applications_id_seq; Type: SEQUENCE SET; Schema: oauth; Owner: indico
--

SELECT pg_catalog.setval('oauth.applications_id_seq', 1, true);


--
-- Name: tokens_id_seq; Type: SEQUENCE SET; Schema: oauth; Owner: indico
--

SELECT pg_catalog.setval('oauth.tokens_id_seq', 1, false);


--
-- Name: blocked_rooms_id_seq; Type: SEQUENCE SET; Schema: roombooking; Owner: indico
--

SELECT pg_catalog.setval('roombooking.blocked_rooms_id_seq', 1, false);


--
-- Name: blocking_principals_id_seq; Type: SEQUENCE SET; Schema: roombooking; Owner: indico
--

SELECT pg_catalog.setval('roombooking.blocking_principals_id_seq', 1, false);


--
-- Name: blockings_id_seq; Type: SEQUENCE SET; Schema: roombooking; Owner: indico
--

SELECT pg_catalog.setval('roombooking.blockings_id_seq', 1, false);


--
-- Name: equipment_types_id_seq; Type: SEQUENCE SET; Schema: roombooking; Owner: indico
--

SELECT pg_catalog.setval('roombooking.equipment_types_id_seq', 1, false);


--
-- Name: features_id_seq; Type: SEQUENCE SET; Schema: roombooking; Owner: indico
--

SELECT pg_catalog.setval('roombooking.features_id_seq', 1, false);


--
-- Name: location_principals_id_seq; Type: SEQUENCE SET; Schema: roombooking; Owner: indico
--

SELECT pg_catalog.setval('roombooking.location_principals_id_seq', 1, false);


--
-- Name: locations_id_seq; Type: SEQUENCE SET; Schema: roombooking; Owner: indico
--

SELECT pg_catalog.setval('roombooking.locations_id_seq', 1, false);


--
-- Name: map_areas_id_seq; Type: SEQUENCE SET; Schema: roombooking; Owner: indico
--

SELECT pg_catalog.setval('roombooking.map_areas_id_seq', 1, false);


--
-- Name: photos_id_seq; Type: SEQUENCE SET; Schema: roombooking; Owner: indico
--

SELECT pg_catalog.setval('roombooking.photos_id_seq', 1, false);


--
-- Name: reservation_edit_logs_id_seq; Type: SEQUENCE SET; Schema: roombooking; Owner: indico
--

SELECT pg_catalog.setval('roombooking.reservation_edit_logs_id_seq', 1, false);


--
-- Name: reservation_occurrence_links_id_seq; Type: SEQUENCE SET; Schema: roombooking; Owner: indico
--

SELECT pg_catalog.setval('roombooking.reservation_occurrence_links_id_seq', 1, false);


--
-- Name: reservations_id_seq; Type: SEQUENCE SET; Schema: roombooking; Owner: indico
--

SELECT pg_catalog.setval('roombooking.reservations_id_seq', 1, false);


--
-- Name: room_attributes_id_seq; Type: SEQUENCE SET; Schema: roombooking; Owner: indico
--

SELECT pg_catalog.setval('roombooking.room_attributes_id_seq', 1, false);


--
-- Name: room_bookable_hours_id_seq; Type: SEQUENCE SET; Schema: roombooking; Owner: indico
--

SELECT pg_catalog.setval('roombooking.room_bookable_hours_id_seq', 1, false);


--
-- Name: room_principals_id_seq; Type: SEQUENCE SET; Schema: roombooking; Owner: indico
--

SELECT pg_catalog.setval('roombooking.room_principals_id_seq', 1, false);


--
-- Name: rooms_id_seq; Type: SEQUENCE SET; Schema: roombooking; Owner: indico
--

SELECT pg_catalog.setval('roombooking.rooms_id_seq', 1, false);


--
-- Name: api_keys_id_seq; Type: SEQUENCE SET; Schema: users; Owner: indico
--

SELECT pg_catalog.setval('users.api_keys_id_seq', 1, false);


--
-- Name: data_export_requests_id_seq; Type: SEQUENCE SET; Schema: users; Owner: indico
--

SELECT pg_catalog.setval('users.data_export_requests_id_seq', 1, false);


--
-- Name: emails_id_seq; Type: SEQUENCE SET; Schema: users; Owner: indico
--

SELECT pg_catalog.setval('users.emails_id_seq', 1, true);


--
-- Name: groups_id_seq; Type: SEQUENCE SET; Schema: users; Owner: indico
--

SELECT pg_catalog.setval('users.groups_id_seq', 1, false);


--
-- Name: identities_id_seq; Type: SEQUENCE SET; Schema: users; Owner: indico
--

SELECT pg_catalog.setval('users.identities_id_seq', 1, true);


--
-- Name: logs_id_seq; Type: SEQUENCE SET; Schema: users; Owner: indico
--

SELECT pg_catalog.setval('users.logs_id_seq', 1, true);


--
-- Name: registration_requests_id_seq; Type: SEQUENCE SET; Schema: users; Owner: indico
--

SELECT pg_catalog.setval('users.registration_requests_id_seq', 1, false);


--
-- Name: settings_id_seq; Type: SEQUENCE SET; Schema: users; Owner: indico
--

SELECT pg_catalog.setval('users.settings_id_seq', 3, true);


--
-- Name: tokens_id_seq; Type: SEQUENCE SET; Schema: users; Owner: indico
--

SELECT pg_catalog.setval('users.tokens_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: users; Owner: indico
--

SELECT pg_catalog.setval('users.users_id_seq', 1, true);


--
-- Name: attachment_principals pk_attachment_principals; Type: CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.attachment_principals
    ADD CONSTRAINT pk_attachment_principals PRIMARY KEY (id);


--
-- Name: attachments pk_attachments; Type: CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.attachments
    ADD CONSTRAINT pk_attachments PRIMARY KEY (id);


--
-- Name: files pk_files; Type: CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.files
    ADD CONSTRAINT pk_files PRIMARY KEY (id);


--
-- Name: folder_principals pk_folder_principals; Type: CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.folder_principals
    ADD CONSTRAINT pk_folder_principals PRIMARY KEY (id);


--
-- Name: folders pk_folders; Type: CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.folders
    ADD CONSTRAINT pk_folders PRIMARY KEY (id);


--
-- Name: legacy_attachment_id_map pk_legacy_attachment_id_map; Type: CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.legacy_attachment_id_map
    ADD CONSTRAINT pk_legacy_attachment_id_map PRIMARY KEY (attachment_id);


--
-- Name: legacy_folder_id_map pk_legacy_folder_id_map; Type: CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.legacy_folder_id_map
    ADD CONSTRAINT pk_legacy_folder_id_map PRIMARY KEY (folder_id);


--
-- Name: categories pk_categories; Type: CONSTRAINT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.categories
    ADD CONSTRAINT pk_categories PRIMARY KEY (id);


--
-- Name: event_move_requests pk_event_move_requests; Type: CONSTRAINT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.event_move_requests
    ADD CONSTRAINT pk_event_move_requests PRIMARY KEY (id);


--
-- Name: legacy_id_map pk_legacy_id_map; Type: CONSTRAINT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.legacy_id_map
    ADD CONSTRAINT pk_legacy_id_map PRIMARY KEY (legacy_category_id, category_id);


--
-- Name: logs pk_logs; Type: CONSTRAINT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.logs
    ADD CONSTRAINT pk_logs PRIMARY KEY (id);


--
-- Name: principals pk_principals; Type: CONSTRAINT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.principals
    ADD CONSTRAINT pk_principals PRIMARY KEY (id);


--
-- Name: role_members pk_role_members; Type: CONSTRAINT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.role_members
    ADD CONSTRAINT pk_role_members PRIMARY KEY (role_id, user_id);


--
-- Name: roles pk_roles; Type: CONSTRAINT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.roles
    ADD CONSTRAINT pk_roles PRIMARY KEY (id);


--
-- Name: settings pk_settings; Type: CONSTRAINT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.settings
    ADD CONSTRAINT pk_settings PRIMARY KEY (id);


--
-- Name: settings uq_settings_category_id_module_name; Type: CONSTRAINT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.settings
    ADD CONSTRAINT uq_settings_category_id_module_name UNIQUE (category_id, module, name);


--
-- Name: abstract_comments pk_abstract_comments; Type: CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_comments
    ADD CONSTRAINT pk_abstract_comments PRIMARY KEY (id);


--
-- Name: abstract_field_values pk_abstract_field_values; Type: CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_field_values
    ADD CONSTRAINT pk_abstract_field_values PRIMARY KEY (abstract_id, contribution_field_id);


--
-- Name: abstract_person_links pk_abstract_person_links; Type: CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_person_links
    ADD CONSTRAINT pk_abstract_person_links PRIMARY KEY (id);


--
-- Name: abstract_review_questions pk_abstract_review_questions; Type: CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_review_questions
    ADD CONSTRAINT pk_abstract_review_questions PRIMARY KEY (id);


--
-- Name: abstract_review_ratings pk_abstract_review_ratings; Type: CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_review_ratings
    ADD CONSTRAINT pk_abstract_review_ratings PRIMARY KEY (id);


--
-- Name: abstract_reviews pk_abstract_reviews; Type: CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_reviews
    ADD CONSTRAINT pk_abstract_reviews PRIMARY KEY (id);


--
-- Name: abstracts pk_abstracts; Type: CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstracts
    ADD CONSTRAINT pk_abstracts PRIMARY KEY (id);


--
-- Name: email_logs pk_email_logs; Type: CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.email_logs
    ADD CONSTRAINT pk_email_logs PRIMARY KEY (id);


--
-- Name: email_templates pk_email_templates; Type: CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.email_templates
    ADD CONSTRAINT pk_email_templates PRIMARY KEY (id);


--
-- Name: files pk_files; Type: CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.files
    ADD CONSTRAINT pk_files PRIMARY KEY (id);


--
-- Name: proposed_for_tracks pk_proposed_for_tracks; Type: CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.proposed_for_tracks
    ADD CONSTRAINT pk_proposed_for_tracks PRIMARY KEY (review_id, track_id);


--
-- Name: reviewed_for_tracks pk_reviewed_for_tracks; Type: CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.reviewed_for_tracks
    ADD CONSTRAINT pk_reviewed_for_tracks PRIMARY KEY (abstract_id, track_id);


--
-- Name: submitted_for_tracks pk_submitted_for_tracks; Type: CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.submitted_for_tracks
    ADD CONSTRAINT pk_submitted_for_tracks PRIMARY KEY (abstract_id, track_id);


--
-- Name: abstract_person_links uq_abstract_person_links_person_id_abstract_id; Type: CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_person_links
    ADD CONSTRAINT uq_abstract_person_links_person_id_abstract_id UNIQUE (person_id, abstract_id);


--
-- Name: abstract_review_ratings uq_abstract_review_ratings_review_id_question_id; Type: CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_review_ratings
    ADD CONSTRAINT uq_abstract_review_ratings_review_id_question_id UNIQUE (review_id, question_id);


--
-- Name: abstract_reviews uq_abstract_reviews_abstract_id_user_id_track_id; Type: CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_reviews
    ADD CONSTRAINT uq_abstract_reviews_abstract_id_user_id_track_id UNIQUE (abstract_id, user_id, track_id);


--
-- Name: comments pk_comments; Type: CONSTRAINT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.comments
    ADD CONSTRAINT pk_comments PRIMARY KEY (id);


--
-- Name: editables pk_editables; Type: CONSTRAINT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.editables
    ADD CONSTRAINT pk_editables PRIMARY KEY (id);


--
-- Name: file_types pk_file_types; Type: CONSTRAINT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.file_types
    ADD CONSTRAINT pk_file_types PRIMARY KEY (id);


--
-- Name: review_condition_file_types pk_review_condition_file_types; Type: CONSTRAINT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.review_condition_file_types
    ADD CONSTRAINT pk_review_condition_file_types PRIMARY KEY (review_condition_id, file_type_id);


--
-- Name: review_conditions pk_review_conditions; Type: CONSTRAINT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.review_conditions
    ADD CONSTRAINT pk_review_conditions PRIMARY KEY (id);


--
-- Name: revision_files pk_revision_files; Type: CONSTRAINT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.revision_files
    ADD CONSTRAINT pk_revision_files PRIMARY KEY (revision_id, file_id);


--
-- Name: revision_tags pk_revision_tags; Type: CONSTRAINT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.revision_tags
    ADD CONSTRAINT pk_revision_tags PRIMARY KEY (revision_id, tag_id);


--
-- Name: revisions pk_revisions; Type: CONSTRAINT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.revisions
    ADD CONSTRAINT pk_revisions PRIMARY KEY (id);


--
-- Name: tags pk_tags; Type: CONSTRAINT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.tags
    ADD CONSTRAINT pk_tags PRIMARY KEY (id);


--
-- Name: competences pk_competences; Type: CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.competences
    ADD CONSTRAINT pk_competences PRIMARY KEY (id);


--
-- Name: content_reviewers pk_content_reviewers; Type: CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.content_reviewers
    ADD CONSTRAINT pk_content_reviewers PRIMARY KEY (contribution_id, user_id);


--
-- Name: files pk_files; Type: CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.files
    ADD CONSTRAINT pk_files PRIMARY KEY (id);


--
-- Name: judges pk_judges; Type: CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.judges
    ADD CONSTRAINT pk_judges PRIMARY KEY (contribution_id, user_id);


--
-- Name: layout_reviewers pk_layout_reviewers; Type: CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.layout_reviewers
    ADD CONSTRAINT pk_layout_reviewers PRIMARY KEY (contribution_id, user_id);


--
-- Name: review_comments pk_review_comments; Type: CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.review_comments
    ADD CONSTRAINT pk_review_comments PRIMARY KEY (id);


--
-- Name: review_questions pk_review_questions; Type: CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.review_questions
    ADD CONSTRAINT pk_review_questions PRIMARY KEY (id);


--
-- Name: review_ratings pk_review_ratings; Type: CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.review_ratings
    ADD CONSTRAINT pk_review_ratings PRIMARY KEY (id);


--
-- Name: reviews pk_reviews; Type: CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.reviews
    ADD CONSTRAINT pk_reviews PRIMARY KEY (id);


--
-- Name: revisions pk_revisions; Type: CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.revisions
    ADD CONSTRAINT pk_revisions PRIMARY KEY (id);


--
-- Name: templates pk_templates; Type: CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.templates
    ADD CONSTRAINT pk_templates PRIMARY KEY (id);


--
-- Name: competences uq_competences_user_id_event_id; Type: CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.competences
    ADD CONSTRAINT uq_competences_user_id_event_id UNIQUE (user_id, event_id);


--
-- Name: review_ratings uq_review_ratings_review_id_question_id; Type: CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.review_ratings
    ADD CONSTRAINT uq_review_ratings_review_id_question_id UNIQUE (review_id, question_id);


--
-- Name: reviews uq_reviews_revision_id_user_id_type; Type: CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.reviews
    ADD CONSTRAINT uq_reviews_revision_id_user_id_type UNIQUE (revision_id, user_id, type);


--
-- Name: revisions uq_revisions_contribution_id_submitted_dt; Type: CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.revisions
    ADD CONSTRAINT uq_revisions_contribution_id_submitted_dt UNIQUE (contribution_id, submitted_dt);


--
-- Name: form_field_data pk_form_field_data; Type: CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.form_field_data
    ADD CONSTRAINT pk_form_field_data PRIMARY KEY (id);


--
-- Name: form_items pk_form_items; Type: CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.form_items
    ADD CONSTRAINT pk_form_items PRIMARY KEY (id);


--
-- Name: forms pk_forms; Type: CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.forms
    ADD CONSTRAINT pk_forms PRIMARY KEY (id);


--
-- Name: invitations pk_invitations; Type: CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.invitations
    ADD CONSTRAINT pk_invitations PRIMARY KEY (id);


--
-- Name: legacy_registration_map pk_legacy_registration_map; Type: CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.legacy_registration_map
    ADD CONSTRAINT pk_legacy_registration_map PRIMARY KEY (event_id, legacy_registrant_id);


--
-- Name: receipt_files pk_receipt_files; Type: CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.receipt_files
    ADD CONSTRAINT pk_receipt_files PRIMARY KEY (file_id);


--
-- Name: registration_data pk_registration_data; Type: CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.registration_data
    ADD CONSTRAINT pk_registration_data PRIMARY KEY (registration_id, field_data_id);


--
-- Name: registration_tags pk_registration_tags; Type: CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.registration_tags
    ADD CONSTRAINT pk_registration_tags PRIMARY KEY (registration_id, registration_tag_id);


--
-- Name: registrations pk_registrations; Type: CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.registrations
    ADD CONSTRAINT pk_registrations PRIMARY KEY (id);


--
-- Name: tags pk_tags; Type: CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.tags
    ADD CONSTRAINT pk_tags PRIMARY KEY (id);


--
-- Name: forms uq_forms_id_event_id; Type: CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.forms
    ADD CONSTRAINT uq_forms_id_event_id UNIQUE (id, event_id);


--
-- Name: forms uq_forms_uuid; Type: CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.forms
    ADD CONSTRAINT uq_forms_uuid UNIQUE (uuid);


--
-- Name: invitations uq_invitations_registration_form_id_email; Type: CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.invitations
    ADD CONSTRAINT uq_invitations_registration_form_id_email UNIQUE (registration_form_id, email);


--
-- Name: anonymous_submissions pk_anonymous_submissions; Type: CONSTRAINT; Schema: event_surveys; Owner: indico
--

ALTER TABLE ONLY event_surveys.anonymous_submissions
    ADD CONSTRAINT pk_anonymous_submissions PRIMARY KEY (survey_id, user_id);


--
-- Name: answers pk_answers; Type: CONSTRAINT; Schema: event_surveys; Owner: indico
--

ALTER TABLE ONLY event_surveys.answers
    ADD CONSTRAINT pk_answers PRIMARY KEY (submission_id, question_id);


--
-- Name: items pk_items; Type: CONSTRAINT; Schema: event_surveys; Owner: indico
--

ALTER TABLE ONLY event_surveys.items
    ADD CONSTRAINT pk_items PRIMARY KEY (id);


--
-- Name: submissions pk_submissions; Type: CONSTRAINT; Schema: event_surveys; Owner: indico
--

ALTER TABLE ONLY event_surveys.submissions
    ADD CONSTRAINT pk_submissions PRIMARY KEY (id);


--
-- Name: surveys pk_surveys; Type: CONSTRAINT; Schema: event_surveys; Owner: indico
--

ALTER TABLE ONLY event_surveys.surveys
    ADD CONSTRAINT pk_surveys PRIMARY KEY (id);


--
-- Name: surveys uq_surveys_uuid; Type: CONSTRAINT; Schema: event_surveys; Owner: indico
--

ALTER TABLE ONLY event_surveys.surveys
    ADD CONSTRAINT uq_surveys_uuid UNIQUE (uuid);


--
-- Name: agreements pk_agreements; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.agreements
    ADD CONSTRAINT pk_agreements PRIMARY KEY (id);


--
-- Name: breaks pk_breaks; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.breaks
    ADD CONSTRAINT pk_breaks PRIMARY KEY (id);


--
-- Name: contribution_field_values pk_contribution_field_values; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contribution_field_values
    ADD CONSTRAINT pk_contribution_field_values PRIMARY KEY (contribution_id, contribution_field_id);


--
-- Name: contribution_fields pk_contribution_fields; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contribution_fields
    ADD CONSTRAINT pk_contribution_fields PRIMARY KEY (id);


--
-- Name: contribution_person_links pk_contribution_person_links; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contribution_person_links
    ADD CONSTRAINT pk_contribution_person_links PRIMARY KEY (id);


--
-- Name: contribution_principals pk_contribution_principals; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contribution_principals
    ADD CONSTRAINT pk_contribution_principals PRIMARY KEY (id);


--
-- Name: contribution_references pk_contribution_references; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contribution_references
    ADD CONSTRAINT pk_contribution_references PRIMARY KEY (id);


--
-- Name: contribution_types pk_contribution_types; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contribution_types
    ADD CONSTRAINT pk_contribution_types PRIMARY KEY (id);


--
-- Name: contributions pk_contributions; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contributions
    ADD CONSTRAINT pk_contributions PRIMARY KEY (id);


--
-- Name: event_person_links pk_event_person_links; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.event_person_links
    ADD CONSTRAINT pk_event_person_links PRIMARY KEY (id);


--
-- Name: event_references pk_event_references; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.event_references
    ADD CONSTRAINT pk_event_references PRIMARY KEY (id);


--
-- Name: events pk_events; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.events
    ADD CONSTRAINT pk_events PRIMARY KEY (id);


--
-- Name: image_files pk_image_files; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.image_files
    ADD CONSTRAINT pk_image_files PRIMARY KEY (id);


--
-- Name: labels pk_labels; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.labels
    ADD CONSTRAINT pk_labels PRIMARY KEY (id);


--
-- Name: legacy_contribution_id_map pk_legacy_contribution_id_map; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.legacy_contribution_id_map
    ADD CONSTRAINT pk_legacy_contribution_id_map PRIMARY KEY (event_id, legacy_contribution_id);


--
-- Name: legacy_id_map pk_legacy_id_map; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.legacy_id_map
    ADD CONSTRAINT pk_legacy_id_map PRIMARY KEY (legacy_event_id, event_id);


--
-- Name: legacy_image_id_map pk_legacy_image_id_map; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.legacy_image_id_map
    ADD CONSTRAINT pk_legacy_image_id_map PRIMARY KEY (event_id, legacy_image_id);


--
-- Name: legacy_page_id_map pk_legacy_page_id_map; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.legacy_page_id_map
    ADD CONSTRAINT pk_legacy_page_id_map PRIMARY KEY (event_id, legacy_page_id);


--
-- Name: legacy_session_block_id_map pk_legacy_session_block_id_map; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.legacy_session_block_id_map
    ADD CONSTRAINT pk_legacy_session_block_id_map PRIMARY KEY (event_id, legacy_session_id, legacy_session_block_id);


--
-- Name: legacy_session_id_map pk_legacy_session_id_map; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.legacy_session_id_map
    ADD CONSTRAINT pk_legacy_session_id_map PRIMARY KEY (event_id, legacy_session_id);


--
-- Name: legacy_subcontribution_id_map pk_legacy_subcontribution_id_map; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.legacy_subcontribution_id_map
    ADD CONSTRAINT pk_legacy_subcontribution_id_map PRIMARY KEY (event_id, legacy_contribution_id, legacy_subcontribution_id);


--
-- Name: logs pk_logs; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.logs
    ADD CONSTRAINT pk_logs PRIMARY KEY (id);


--
-- Name: menu_entries pk_menu_entries; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.menu_entries
    ADD CONSTRAINT pk_menu_entries PRIMARY KEY (id);


--
-- Name: menu_entry_principals pk_menu_entry_principals; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.menu_entry_principals
    ADD CONSTRAINT pk_menu_entry_principals PRIMARY KEY (id);


--
-- Name: note_revisions pk_note_revisions; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.note_revisions
    ADD CONSTRAINT pk_note_revisions PRIMARY KEY (id);


--
-- Name: notes pk_notes; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.notes
    ADD CONSTRAINT pk_notes PRIMARY KEY (id);


--
-- Name: pages pk_pages; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.pages
    ADD CONSTRAINT pk_pages PRIMARY KEY (id);


--
-- Name: payment_transactions pk_payment_transactions; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.payment_transactions
    ADD CONSTRAINT pk_payment_transactions PRIMARY KEY (id);


--
-- Name: persons pk_persons; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.persons
    ADD CONSTRAINT pk_persons PRIMARY KEY (id);


--
-- Name: principals pk_principals; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.principals
    ADD CONSTRAINT pk_principals PRIMARY KEY (id);


--
-- Name: reminders pk_reminders; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.reminders
    ADD CONSTRAINT pk_reminders PRIMARY KEY (id);


--
-- Name: requests pk_requests; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.requests
    ADD CONSTRAINT pk_requests PRIMARY KEY (id);


--
-- Name: role_members pk_role_members; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.role_members
    ADD CONSTRAINT pk_role_members PRIMARY KEY (role_id, user_id);


--
-- Name: roles pk_roles; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.roles
    ADD CONSTRAINT pk_roles PRIMARY KEY (id);


--
-- Name: series pk_series; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.series
    ADD CONSTRAINT pk_series PRIMARY KEY (id);


--
-- Name: session_block_person_links pk_session_block_person_links; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.session_block_person_links
    ADD CONSTRAINT pk_session_block_person_links PRIMARY KEY (id);


--
-- Name: session_blocks pk_session_blocks; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.session_blocks
    ADD CONSTRAINT pk_session_blocks PRIMARY KEY (id);


--
-- Name: session_principals pk_session_principals; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.session_principals
    ADD CONSTRAINT pk_session_principals PRIMARY KEY (id);


--
-- Name: session_types pk_session_types; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.session_types
    ADD CONSTRAINT pk_session_types PRIMARY KEY (id);


--
-- Name: sessions pk_sessions; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.sessions
    ADD CONSTRAINT pk_sessions PRIMARY KEY (id);


--
-- Name: settings pk_settings; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.settings
    ADD CONSTRAINT pk_settings PRIMARY KEY (id);


--
-- Name: settings_principals pk_settings_principals; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.settings_principals
    ADD CONSTRAINT pk_settings_principals PRIMARY KEY (id);


--
-- Name: static_list_links pk_static_list_links; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.static_list_links
    ADD CONSTRAINT pk_static_list_links PRIMARY KEY (id);


--
-- Name: static_sites pk_static_sites; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.static_sites
    ADD CONSTRAINT pk_static_sites PRIMARY KEY (id);


--
-- Name: subcontribution_person_links pk_subcontribution_person_links; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.subcontribution_person_links
    ADD CONSTRAINT pk_subcontribution_person_links PRIMARY KEY (id);


--
-- Name: subcontribution_references pk_subcontribution_references; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.subcontribution_references
    ADD CONSTRAINT pk_subcontribution_references PRIMARY KEY (id);


--
-- Name: subcontributions pk_subcontributions; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.subcontributions
    ADD CONSTRAINT pk_subcontributions PRIMARY KEY (id);


--
-- Name: timetable_entries pk_timetable_entries; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.timetable_entries
    ADD CONSTRAINT pk_timetable_entries PRIMARY KEY (id);


--
-- Name: track_groups pk_track_groups; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.track_groups
    ADD CONSTRAINT pk_track_groups PRIMARY KEY (id);


--
-- Name: track_principals pk_track_principals; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.track_principals
    ADD CONSTRAINT pk_track_principals PRIMARY KEY (id);


--
-- Name: tracks pk_tracks; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.tracks
    ADD CONSTRAINT pk_tracks PRIMARY KEY (id);


--
-- Name: vc_room_events pk_vc_room_events; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.vc_room_events
    ADD CONSTRAINT pk_vc_room_events PRIMARY KEY (id);


--
-- Name: vc_rooms pk_vc_rooms; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.vc_rooms
    ADD CONSTRAINT pk_vc_rooms PRIMARY KEY (id);


--
-- Name: agreements uq_agreements_event_id_type_identifier; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.agreements
    ADD CONSTRAINT uq_agreements_event_id_type_identifier UNIQUE (event_id, type, identifier);


--
-- Name: contribution_fields uq_contribution_fields_event_id_legacy_id; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contribution_fields
    ADD CONSTRAINT uq_contribution_fields_event_id_legacy_id UNIQUE (event_id, legacy_id);


--
-- Name: contribution_person_links uq_contribution_person_links_person_id_contribution_id; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contribution_person_links
    ADD CONSTRAINT uq_contribution_person_links_person_id_contribution_id UNIQUE (person_id, contribution_id);


--
-- Name: event_person_links uq_event_person_links_person_id_event_id; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.event_person_links
    ADD CONSTRAINT uq_event_person_links_person_id_event_id UNIQUE (person_id, event_id);


--
-- Name: persons uq_persons_event_id_user_id; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.persons
    ADD CONSTRAINT uq_persons_event_id_user_id UNIQUE (event_id, user_id);


--
-- Name: session_block_person_links uq_session_block_person_links_person_id_session_block_id; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.session_block_person_links
    ADD CONSTRAINT uq_session_block_person_links_person_id_session_block_id UNIQUE (person_id, session_block_id);


--
-- Name: session_blocks uq_session_blocks_id_session_id; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.session_blocks
    ADD CONSTRAINT uq_session_blocks_id_session_id UNIQUE (id, session_id);


--
-- Name: settings uq_settings_event_id_module_name; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.settings
    ADD CONSTRAINT uq_settings_event_id_module_name UNIQUE (event_id, module, name);


--
-- Name: subcontribution_person_links uq_subcontribution_person_links_person_id_subcontribution_id; Type: CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.subcontribution_person_links
    ADD CONSTRAINT uq_subcontribution_person_links_person_id_subcontribution_id UNIQUE (person_id, subcontribution_id);


--
-- Name: affiliations pk_affiliations; Type: CONSTRAINT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.affiliations
    ADD CONSTRAINT pk_affiliations PRIMARY KEY (id);


--
-- Name: designer_image_files pk_designer_image_files; Type: CONSTRAINT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.designer_image_files
    ADD CONSTRAINT pk_designer_image_files PRIMARY KEY (id);


--
-- Name: designer_templates pk_designer_templates; Type: CONSTRAINT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.designer_templates
    ADD CONSTRAINT pk_designer_templates PRIMARY KEY (id);


--
-- Name: files pk_files; Type: CONSTRAINT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.files
    ADD CONSTRAINT pk_files PRIMARY KEY (id);


--
-- Name: ip_network_groups pk_ip_network_groups; Type: CONSTRAINT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.ip_network_groups
    ADD CONSTRAINT pk_ip_network_groups PRIMARY KEY (id);


--
-- Name: ip_networks pk_ip_networks; Type: CONSTRAINT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.ip_networks
    ADD CONSTRAINT pk_ip_networks PRIMARY KEY (group_id, network);


--
-- Name: news pk_news; Type: CONSTRAINT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.news
    ADD CONSTRAINT pk_news PRIMARY KEY (id);


--
-- Name: receipt_templates pk_receipt_templates; Type: CONSTRAINT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.receipt_templates
    ADD CONSTRAINT pk_receipt_templates PRIMARY KEY (id);


--
-- Name: reference_types pk_reference_types; Type: CONSTRAINT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.reference_types
    ADD CONSTRAINT pk_reference_types PRIMARY KEY (id);


--
-- Name: settings pk_settings; Type: CONSTRAINT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.settings
    ADD CONSTRAINT pk_settings PRIMARY KEY (id);


--
-- Name: settings_principals pk_settings_principals; Type: CONSTRAINT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.settings_principals
    ADD CONSTRAINT pk_settings_principals PRIMARY KEY (id);


--
-- Name: settings uq_settings_module_name; Type: CONSTRAINT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.settings
    ADD CONSTRAINT uq_settings_module_name UNIQUE (module, name);


--
-- Name: application_user_links pk_application_user_links; Type: CONSTRAINT; Schema: oauth; Owner: indico
--

ALTER TABLE ONLY oauth.application_user_links
    ADD CONSTRAINT pk_application_user_links PRIMARY KEY (id);


--
-- Name: applications pk_applications; Type: CONSTRAINT; Schema: oauth; Owner: indico
--

ALTER TABLE ONLY oauth.applications
    ADD CONSTRAINT pk_applications PRIMARY KEY (id);


--
-- Name: tokens pk_tokens; Type: CONSTRAINT; Schema: oauth; Owner: indico
--

ALTER TABLE ONLY oauth.tokens
    ADD CONSTRAINT pk_tokens PRIMARY KEY (id);


--
-- Name: application_user_links uq_application_user_links_application_id_user_id; Type: CONSTRAINT; Schema: oauth; Owner: indico
--

ALTER TABLE ONLY oauth.application_user_links
    ADD CONSTRAINT uq_application_user_links_application_id_user_id UNIQUE (application_id, user_id);


--
-- Name: applications uq_applications_client_id; Type: CONSTRAINT; Schema: oauth; Owner: indico
--

ALTER TABLE ONLY oauth.applications
    ADD CONSTRAINT uq_applications_client_id UNIQUE (client_id);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: indico
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: blocked_rooms pk_blocked_rooms; Type: CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.blocked_rooms
    ADD CONSTRAINT pk_blocked_rooms PRIMARY KEY (id);


--
-- Name: blocking_principals pk_blocking_principals; Type: CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.blocking_principals
    ADD CONSTRAINT pk_blocking_principals PRIMARY KEY (id);


--
-- Name: blockings pk_blockings; Type: CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.blockings
    ADD CONSTRAINT pk_blockings PRIMARY KEY (id);


--
-- Name: equipment_features pk_equipment_features; Type: CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.equipment_features
    ADD CONSTRAINT pk_equipment_features PRIMARY KEY (equipment_id, feature_id);


--
-- Name: equipment_types pk_equipment_types; Type: CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.equipment_types
    ADD CONSTRAINT pk_equipment_types PRIMARY KEY (id);


--
-- Name: favorite_rooms pk_favorite_rooms; Type: CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.favorite_rooms
    ADD CONSTRAINT pk_favorite_rooms PRIMARY KEY (user_id, room_id);


--
-- Name: features pk_features; Type: CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.features
    ADD CONSTRAINT pk_features PRIMARY KEY (id);


--
-- Name: location_principals pk_location_principals; Type: CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.location_principals
    ADD CONSTRAINT pk_location_principals PRIMARY KEY (id);


--
-- Name: locations pk_locations; Type: CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.locations
    ADD CONSTRAINT pk_locations PRIMARY KEY (id);


--
-- Name: map_areas pk_map_areas; Type: CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.map_areas
    ADD CONSTRAINT pk_map_areas PRIMARY KEY (id);


--
-- Name: photos pk_photos; Type: CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.photos
    ADD CONSTRAINT pk_photos PRIMARY KEY (id);


--
-- Name: reservation_edit_logs pk_reservation_edit_logs; Type: CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.reservation_edit_logs
    ADD CONSTRAINT pk_reservation_edit_logs PRIMARY KEY (id);


--
-- Name: reservation_occurrence_links pk_reservation_occurrence_links; Type: CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.reservation_occurrence_links
    ADD CONSTRAINT pk_reservation_occurrence_links PRIMARY KEY (id);


--
-- Name: reservation_occurrences pk_reservation_occurrences; Type: CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.reservation_occurrences
    ADD CONSTRAINT pk_reservation_occurrences PRIMARY KEY (reservation_id, start_dt);


--
-- Name: reservations pk_reservations; Type: CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.reservations
    ADD CONSTRAINT pk_reservations PRIMARY KEY (id);


--
-- Name: room_attribute_values pk_room_attribute_values; Type: CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.room_attribute_values
    ADD CONSTRAINT pk_room_attribute_values PRIMARY KEY (attribute_id, room_id);


--
-- Name: room_attributes pk_room_attributes; Type: CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.room_attributes
    ADD CONSTRAINT pk_room_attributes PRIMARY KEY (id);


--
-- Name: room_bookable_hours pk_room_bookable_hours; Type: CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.room_bookable_hours
    ADD CONSTRAINT pk_room_bookable_hours PRIMARY KEY (id);


--
-- Name: room_equipment pk_room_equipment; Type: CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.room_equipment
    ADD CONSTRAINT pk_room_equipment PRIMARY KEY (equipment_id, room_id);


--
-- Name: room_nonbookable_periods pk_room_nonbookable_periods; Type: CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.room_nonbookable_periods
    ADD CONSTRAINT pk_room_nonbookable_periods PRIMARY KEY (start_dt, end_dt, room_id);


--
-- Name: room_principals pk_room_principals; Type: CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.room_principals
    ADD CONSTRAINT pk_room_principals PRIMARY KEY (id);


--
-- Name: rooms pk_rooms; Type: CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.rooms
    ADD CONSTRAINT pk_rooms PRIMARY KEY (id);


--
-- Name: rooms uq_rooms_id_location_id; Type: CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.rooms
    ADD CONSTRAINT uq_rooms_id_location_id UNIQUE (id, location_id);


--
-- Name: api_keys pk_api_keys; Type: CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.api_keys
    ADD CONSTRAINT pk_api_keys PRIMARY KEY (id);


--
-- Name: data_export_requests pk_data_export_requests; Type: CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.data_export_requests
    ADD CONSTRAINT pk_data_export_requests PRIMARY KEY (id);


--
-- Name: emails pk_emails; Type: CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.emails
    ADD CONSTRAINT pk_emails PRIMARY KEY (id);


--
-- Name: favorite_categories pk_favorite_categories; Type: CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.favorite_categories
    ADD CONSTRAINT pk_favorite_categories PRIMARY KEY (user_id, target_id);


--
-- Name: favorite_events pk_favorite_events; Type: CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.favorite_events
    ADD CONSTRAINT pk_favorite_events PRIMARY KEY (user_id, target_id);


--
-- Name: favorite_users pk_favorite_users; Type: CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.favorite_users
    ADD CONSTRAINT pk_favorite_users PRIMARY KEY (user_id, target_id);


--
-- Name: group_members pk_group_members; Type: CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.group_members
    ADD CONSTRAINT pk_group_members PRIMARY KEY (group_id, user_id);


--
-- Name: groups pk_groups; Type: CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.groups
    ADD CONSTRAINT pk_groups PRIMARY KEY (id);


--
-- Name: identities pk_identities; Type: CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.identities
    ADD CONSTRAINT pk_identities PRIMARY KEY (id);


--
-- Name: logs pk_logs; Type: CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.logs
    ADD CONSTRAINT pk_logs PRIMARY KEY (id);


--
-- Name: registration_requests pk_registration_requests; Type: CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.registration_requests
    ADD CONSTRAINT pk_registration_requests PRIMARY KEY (id);


--
-- Name: settings pk_settings; Type: CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.settings
    ADD CONSTRAINT pk_settings PRIMARY KEY (id);


--
-- Name: suggested_categories pk_suggested_categories; Type: CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.suggested_categories
    ADD CONSTRAINT pk_suggested_categories PRIMARY KEY (user_id, category_id);


--
-- Name: tokens pk_tokens; Type: CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.tokens
    ADD CONSTRAINT pk_tokens PRIMARY KEY (id);


--
-- Name: users pk_users; Type: CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.users
    ADD CONSTRAINT pk_users PRIMARY KEY (id);


--
-- Name: api_keys uq_api_keys_token; Type: CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.api_keys
    ADD CONSTRAINT uq_api_keys_token UNIQUE (token);


--
-- Name: data_export_requests uq_data_export_requests_user_id; Type: CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.data_export_requests
    ADD CONSTRAINT uq_data_export_requests_user_id UNIQUE (user_id);


--
-- Name: identities uq_identities_provider_identifier; Type: CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.identities
    ADD CONSTRAINT uq_identities_provider_identifier UNIQUE (provider, identifier);


--
-- Name: settings uq_settings_user_id_module_name; Type: CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.settings
    ADD CONSTRAINT uq_settings_user_id_module_name UNIQUE (user_id, module, name);


--
-- Name: ix_attachment_principals_category_role_id; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE INDEX ix_attachment_principals_category_role_id ON attachments.attachment_principals USING btree (category_role_id);


--
-- Name: ix_attachment_principals_event_role_id; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE INDEX ix_attachment_principals_event_role_id ON attachments.attachment_principals USING btree (event_role_id);


--
-- Name: ix_attachment_principals_local_group_id; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE INDEX ix_attachment_principals_local_group_id ON attachments.attachment_principals USING btree (local_group_id);


--
-- Name: ix_attachment_principals_mp_group_provider_mp_group_name; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE INDEX ix_attachment_principals_mp_group_provider_mp_group_name ON attachments.attachment_principals USING btree (mp_group_provider, mp_group_name);


--
-- Name: ix_attachment_principals_registration_form_id; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE INDEX ix_attachment_principals_registration_form_id ON attachments.attachment_principals USING btree (registration_form_id);


--
-- Name: ix_attachment_principals_user_id; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE INDEX ix_attachment_principals_user_id ON attachments.attachment_principals USING btree (user_id);


--
-- Name: ix_attachments_folder_id; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE INDEX ix_attachments_folder_id ON attachments.attachments USING btree (folder_id);


--
-- Name: ix_attachments_title_fts; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE INDEX ix_attachments_title_fts ON attachments.attachments USING gin (to_tsvector('simple'::regconfig, (title)::text));


--
-- Name: ix_attachments_user_id; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE INDEX ix_attachments_user_id ON attachments.attachments USING btree (user_id);


--
-- Name: ix_files_attachment_id; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE INDEX ix_files_attachment_id ON attachments.files USING btree (attachment_id);


--
-- Name: ix_files_user_id; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE INDEX ix_files_user_id ON attachments.files USING btree (user_id);


--
-- Name: ix_folder_principals_category_role_id; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE INDEX ix_folder_principals_category_role_id ON attachments.folder_principals USING btree (category_role_id);


--
-- Name: ix_folder_principals_event_role_id; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE INDEX ix_folder_principals_event_role_id ON attachments.folder_principals USING btree (event_role_id);


--
-- Name: ix_folder_principals_local_group_id; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE INDEX ix_folder_principals_local_group_id ON attachments.folder_principals USING btree (local_group_id);


--
-- Name: ix_folder_principals_mp_group_provider_mp_group_name; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE INDEX ix_folder_principals_mp_group_provider_mp_group_name ON attachments.folder_principals USING btree (mp_group_provider, mp_group_name);


--
-- Name: ix_folder_principals_registration_form_id; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE INDEX ix_folder_principals_registration_form_id ON attachments.folder_principals USING btree (registration_form_id);


--
-- Name: ix_folder_principals_user_id; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE INDEX ix_folder_principals_user_id ON attachments.folder_principals USING btree (user_id);


--
-- Name: ix_folders_category_id; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE INDEX ix_folders_category_id ON attachments.folders USING btree (category_id);


--
-- Name: ix_folders_contribution_id; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE INDEX ix_folders_contribution_id ON attachments.folders USING btree (contribution_id);


--
-- Name: ix_folders_event_id; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE INDEX ix_folders_event_id ON attachments.folders USING btree (event_id);


--
-- Name: ix_folders_linked_event_id; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE INDEX ix_folders_linked_event_id ON attachments.folders USING btree (linked_event_id);


--
-- Name: ix_folders_session_id; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE INDEX ix_folders_session_id ON attachments.folders USING btree (session_id);


--
-- Name: ix_folders_subcontribution_id; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE INDEX ix_folders_subcontribution_id ON attachments.folders USING btree (subcontribution_id);


--
-- Name: ix_legacy_attachment_id_map_event_id; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE INDEX ix_legacy_attachment_id_map_event_id ON attachments.legacy_attachment_id_map USING btree (event_id);


--
-- Name: ix_legacy_folder_id_map_event_id; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE INDEX ix_legacy_folder_id_map_event_id ON attachments.legacy_folder_id_map USING btree (event_id);


--
-- Name: ix_uq_attachment_principals_local_group; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_attachment_principals_local_group ON attachments.attachment_principals USING btree (local_group_id, attachment_id) WHERE (type = 2);


--
-- Name: ix_uq_attachment_principals_mp_group; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_attachment_principals_mp_group ON attachments.attachment_principals USING btree (mp_group_provider, mp_group_name, attachment_id) WHERE (type = 3);


--
-- Name: ix_uq_attachment_principals_user; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_attachment_principals_user ON attachments.attachment_principals USING btree (user_id, attachment_id) WHERE (type = 1);


--
-- Name: ix_uq_folder_principals_local_group; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_folder_principals_local_group ON attachments.folder_principals USING btree (local_group_id, folder_id) WHERE (type = 2);


--
-- Name: ix_uq_folder_principals_mp_group; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_folder_principals_mp_group ON attachments.folder_principals USING btree (mp_group_provider, mp_group_name, folder_id) WHERE (type = 3);


--
-- Name: ix_uq_folder_principals_user; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_folder_principals_user ON attachments.folder_principals USING btree (user_id, folder_id) WHERE (type = 1);


--
-- Name: ix_uq_folders_category_id; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_folders_category_id ON attachments.folders USING btree (category_id) WHERE ((link_type = 1) AND is_default);


--
-- Name: ix_uq_folders_contribution_id; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_folders_contribution_id ON attachments.folders USING btree (contribution_id) WHERE ((link_type = 3) AND is_default);


--
-- Name: ix_uq_folders_linked_event_id; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_folders_linked_event_id ON attachments.folders USING btree (linked_event_id) WHERE ((link_type = 2) AND is_default);


--
-- Name: ix_uq_folders_session_id; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_folders_session_id ON attachments.folders USING btree (session_id) WHERE ((link_type = 5) AND is_default);


--
-- Name: ix_uq_folders_subcontribution_id; Type: INDEX; Schema: attachments; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_folders_subcontribution_id ON attachments.folders USING btree (subcontribution_id) WHERE ((link_type = 4) AND is_default);


--
-- Name: ix_categories_default_badge_template_id; Type: INDEX; Schema: categories; Owner: indico
--

CREATE INDEX ix_categories_default_badge_template_id ON categories.categories USING btree (default_badge_template_id);


--
-- Name: ix_categories_default_ticket_template_id; Type: INDEX; Schema: categories; Owner: indico
--

CREATE INDEX ix_categories_default_ticket_template_id ON categories.categories USING btree (default_ticket_template_id);


--
-- Name: ix_categories_parent_id; Type: INDEX; Schema: categories; Owner: indico
--

CREATE INDEX ix_categories_parent_id ON categories.categories USING btree (parent_id);


--
-- Name: ix_categories_title_fts; Type: INDEX; Schema: categories; Owner: indico
--

CREATE INDEX ix_categories_title_fts ON categories.categories USING gin (to_tsvector('simple'::regconfig, (title)::text));


--
-- Name: ix_event_move_requests_category_id; Type: INDEX; Schema: categories; Owner: indico
--

CREATE INDEX ix_event_move_requests_category_id ON categories.event_move_requests USING btree (category_id);


--
-- Name: ix_event_move_requests_event_id; Type: INDEX; Schema: categories; Owner: indico
--

CREATE INDEX ix_event_move_requests_event_id ON categories.event_move_requests USING btree (event_id);


--
-- Name: ix_event_move_requests_requestor_id; Type: INDEX; Schema: categories; Owner: indico
--

CREATE INDEX ix_event_move_requests_requestor_id ON categories.event_move_requests USING btree (requestor_id);


--
-- Name: ix_legacy_id_map_category_id; Type: INDEX; Schema: categories; Owner: indico
--

CREATE INDEX ix_legacy_id_map_category_id ON categories.legacy_id_map USING btree (category_id);


--
-- Name: ix_legacy_id_map_legacy_category_id; Type: INDEX; Schema: categories; Owner: indico
--

CREATE INDEX ix_legacy_id_map_legacy_category_id ON categories.legacy_id_map USING btree (legacy_category_id);


--
-- Name: ix_logs_category_id; Type: INDEX; Schema: categories; Owner: indico
--

CREATE INDEX ix_logs_category_id ON categories.logs USING btree (category_id);


--
-- Name: ix_logs_meta; Type: INDEX; Schema: categories; Owner: indico
--

CREATE INDEX ix_logs_meta ON categories.logs USING gin (meta);


--
-- Name: ix_logs_user_id; Type: INDEX; Schema: categories; Owner: indico
--

CREATE INDEX ix_logs_user_id ON categories.logs USING btree (user_id);


--
-- Name: ix_principals_category_id; Type: INDEX; Schema: categories; Owner: indico
--

CREATE INDEX ix_principals_category_id ON categories.principals USING btree (category_id);


--
-- Name: ix_principals_category_role_id; Type: INDEX; Schema: categories; Owner: indico
--

CREATE INDEX ix_principals_category_role_id ON categories.principals USING btree (category_role_id);


--
-- Name: ix_principals_ip_network_group_id; Type: INDEX; Schema: categories; Owner: indico
--

CREATE INDEX ix_principals_ip_network_group_id ON categories.principals USING btree (ip_network_group_id);


--
-- Name: ix_principals_local_group_id; Type: INDEX; Schema: categories; Owner: indico
--

CREATE INDEX ix_principals_local_group_id ON categories.principals USING btree (local_group_id);


--
-- Name: ix_principals_mp_group_provider_mp_group_name; Type: INDEX; Schema: categories; Owner: indico
--

CREATE INDEX ix_principals_mp_group_provider_mp_group_name ON categories.principals USING btree (mp_group_provider, mp_group_name);


--
-- Name: ix_principals_user_id; Type: INDEX; Schema: categories; Owner: indico
--

CREATE INDEX ix_principals_user_id ON categories.principals USING btree (user_id);


--
-- Name: ix_role_members_role_id; Type: INDEX; Schema: categories; Owner: indico
--

CREATE INDEX ix_role_members_role_id ON categories.role_members USING btree (role_id);


--
-- Name: ix_role_members_user_id; Type: INDEX; Schema: categories; Owner: indico
--

CREATE INDEX ix_role_members_user_id ON categories.role_members USING btree (user_id);


--
-- Name: ix_roles_category_id; Type: INDEX; Schema: categories; Owner: indico
--

CREATE INDEX ix_roles_category_id ON categories.roles USING btree (category_id);


--
-- Name: ix_settings_category_id; Type: INDEX; Schema: categories; Owner: indico
--

CREATE INDEX ix_settings_category_id ON categories.settings USING btree (category_id);


--
-- Name: ix_settings_category_id_module; Type: INDEX; Schema: categories; Owner: indico
--

CREATE INDEX ix_settings_category_id_module ON categories.settings USING btree (category_id, module);


--
-- Name: ix_settings_category_id_module_name; Type: INDEX; Schema: categories; Owner: indico
--

CREATE INDEX ix_settings_category_id_module_name ON categories.settings USING btree (category_id, module, name);


--
-- Name: ix_settings_module; Type: INDEX; Schema: categories; Owner: indico
--

CREATE INDEX ix_settings_module ON categories.settings USING btree (module);


--
-- Name: ix_settings_name; Type: INDEX; Schema: categories; Owner: indico
--

CREATE INDEX ix_settings_name ON categories.settings USING btree (name);


--
-- Name: ix_uq_event_move_requests_event_id; Type: INDEX; Schema: categories; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_event_move_requests_event_id ON categories.event_move_requests USING btree (event_id) WHERE (state = 0);


--
-- Name: ix_uq_principals_local_group; Type: INDEX; Schema: categories; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_principals_local_group ON categories.principals USING btree (local_group_id, category_id) WHERE (type = 2);


--
-- Name: ix_uq_principals_mp_group; Type: INDEX; Schema: categories; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_principals_mp_group ON categories.principals USING btree (mp_group_provider, mp_group_name, category_id) WHERE (type = 3);


--
-- Name: ix_uq_principals_user; Type: INDEX; Schema: categories; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_principals_user ON categories.principals USING btree (user_id, category_id) WHERE (type = 1);


--
-- Name: ix_uq_roles_category_id_code; Type: INDEX; Schema: categories; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_roles_category_id_code ON categories.roles USING btree (category_id, code);


--
-- Name: ix_abstract_comments_abstract_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_abstract_comments_abstract_id ON event_abstracts.abstract_comments USING btree (abstract_id);


--
-- Name: ix_abstract_comments_modified_by_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_abstract_comments_modified_by_id ON event_abstracts.abstract_comments USING btree (modified_by_id);


--
-- Name: ix_abstract_comments_user_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_abstract_comments_user_id ON event_abstracts.abstract_comments USING btree (user_id);


--
-- Name: ix_abstract_field_values_abstract_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_abstract_field_values_abstract_id ON event_abstracts.abstract_field_values USING btree (abstract_id);


--
-- Name: ix_abstract_field_values_contribution_field_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_abstract_field_values_contribution_field_id ON event_abstracts.abstract_field_values USING btree (contribution_field_id);


--
-- Name: ix_abstract_person_links_abstract_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_abstract_person_links_abstract_id ON event_abstracts.abstract_person_links USING btree (abstract_id);


--
-- Name: ix_abstract_person_links_affiliation_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_abstract_person_links_affiliation_id ON event_abstracts.abstract_person_links USING btree (affiliation_id);


--
-- Name: ix_abstract_person_links_person_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_abstract_person_links_person_id ON event_abstracts.abstract_person_links USING btree (person_id);


--
-- Name: ix_abstract_review_questions_event_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_abstract_review_questions_event_id ON event_abstracts.abstract_review_questions USING btree (event_id);


--
-- Name: ix_abstract_review_ratings_question_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_abstract_review_ratings_question_id ON event_abstracts.abstract_review_ratings USING btree (question_id);


--
-- Name: ix_abstract_review_ratings_review_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_abstract_review_ratings_review_id ON event_abstracts.abstract_review_ratings USING btree (review_id);


--
-- Name: ix_abstract_reviews_abstract_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_abstract_reviews_abstract_id ON event_abstracts.abstract_reviews USING btree (abstract_id);


--
-- Name: ix_abstract_reviews_proposed_contribution_type_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_abstract_reviews_proposed_contribution_type_id ON event_abstracts.abstract_reviews USING btree (proposed_contribution_type_id);


--
-- Name: ix_abstract_reviews_proposed_related_abstract_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_abstract_reviews_proposed_related_abstract_id ON event_abstracts.abstract_reviews USING btree (proposed_related_abstract_id);


--
-- Name: ix_abstract_reviews_track_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_abstract_reviews_track_id ON event_abstracts.abstract_reviews USING btree (track_id);


--
-- Name: ix_abstract_reviews_user_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_abstract_reviews_user_id ON event_abstracts.abstract_reviews USING btree (user_id);


--
-- Name: ix_abstracts_accepted_contrib_type_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_abstracts_accepted_contrib_type_id ON event_abstracts.abstracts USING btree (accepted_contrib_type_id);


--
-- Name: ix_abstracts_accepted_track_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_abstracts_accepted_track_id ON event_abstracts.abstracts USING btree (accepted_track_id);


--
-- Name: ix_abstracts_duplicate_of_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_abstracts_duplicate_of_id ON event_abstracts.abstracts USING btree (duplicate_of_id);


--
-- Name: ix_abstracts_event_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_abstracts_event_id ON event_abstracts.abstracts USING btree (event_id);


--
-- Name: ix_abstracts_judge_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_abstracts_judge_id ON event_abstracts.abstracts USING btree (judge_id);


--
-- Name: ix_abstracts_merged_into_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_abstracts_merged_into_id ON event_abstracts.abstracts USING btree (merged_into_id);


--
-- Name: ix_abstracts_modified_by_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_abstracts_modified_by_id ON event_abstracts.abstracts USING btree (modified_by_id);


--
-- Name: ix_abstracts_submitted_contrib_type_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_abstracts_submitted_contrib_type_id ON event_abstracts.abstracts USING btree (submitted_contrib_type_id);


--
-- Name: ix_abstracts_submitter_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_abstracts_submitter_id ON event_abstracts.abstracts USING btree (submitter_id);


--
-- Name: ix_email_logs_abstract_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_email_logs_abstract_id ON event_abstracts.email_logs USING btree (abstract_id);


--
-- Name: ix_email_logs_email_template_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_email_logs_email_template_id ON event_abstracts.email_logs USING btree (email_template_id);


--
-- Name: ix_email_logs_user_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_email_logs_user_id ON event_abstracts.email_logs USING btree (user_id);


--
-- Name: ix_email_templates_event_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_email_templates_event_id ON event_abstracts.email_templates USING btree (event_id);


--
-- Name: ix_files_abstract_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_files_abstract_id ON event_abstracts.files USING btree (abstract_id);


--
-- Name: ix_proposed_for_tracks_review_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_proposed_for_tracks_review_id ON event_abstracts.proposed_for_tracks USING btree (review_id);


--
-- Name: ix_proposed_for_tracks_track_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_proposed_for_tracks_track_id ON event_abstracts.proposed_for_tracks USING btree (track_id);


--
-- Name: ix_reviewed_for_tracks_abstract_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_reviewed_for_tracks_abstract_id ON event_abstracts.reviewed_for_tracks USING btree (abstract_id);


--
-- Name: ix_reviewed_for_tracks_track_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_reviewed_for_tracks_track_id ON event_abstracts.reviewed_for_tracks USING btree (track_id);


--
-- Name: ix_submitted_for_tracks_abstract_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_submitted_for_tracks_abstract_id ON event_abstracts.submitted_for_tracks USING btree (abstract_id);


--
-- Name: ix_submitted_for_tracks_track_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE INDEX ix_submitted_for_tracks_track_id ON event_abstracts.submitted_for_tracks USING btree (track_id);


--
-- Name: ix_uq_abstracts_friendly_id_event_id; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_abstracts_friendly_id_event_id ON event_abstracts.abstracts USING btree (friendly_id, event_id) WHERE (NOT is_deleted);


--
-- Name: ix_uq_abstracts_uuid; Type: INDEX; Schema: event_abstracts; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_abstracts_uuid ON event_abstracts.abstracts USING btree (uuid);


--
-- Name: ix_comments_revision_id; Type: INDEX; Schema: event_editing; Owner: indico
--

CREATE INDEX ix_comments_revision_id ON event_editing.comments USING btree (revision_id);


--
-- Name: ix_comments_user_id; Type: INDEX; Schema: event_editing; Owner: indico
--

CREATE INDEX ix_comments_user_id ON event_editing.comments USING btree (user_id);


--
-- Name: ix_editables_contribution_id; Type: INDEX; Schema: event_editing; Owner: indico
--

CREATE INDEX ix_editables_contribution_id ON event_editing.editables USING btree (contribution_id);


--
-- Name: ix_editables_editor_id; Type: INDEX; Schema: event_editing; Owner: indico
--

CREATE INDEX ix_editables_editor_id ON event_editing.editables USING btree (editor_id);


--
-- Name: ix_editables_published_revision_id; Type: INDEX; Schema: event_editing; Owner: indico
--

CREATE INDEX ix_editables_published_revision_id ON event_editing.editables USING btree (published_revision_id);


--
-- Name: ix_file_types_event_id; Type: INDEX; Schema: event_editing; Owner: indico
--

CREATE INDEX ix_file_types_event_id ON event_editing.file_types USING btree (event_id);


--
-- Name: ix_review_condition_file_types_file_type_id; Type: INDEX; Schema: event_editing; Owner: indico
--

CREATE INDEX ix_review_condition_file_types_file_type_id ON event_editing.review_condition_file_types USING btree (file_type_id);


--
-- Name: ix_review_condition_file_types_review_condition_id; Type: INDEX; Schema: event_editing; Owner: indico
--

CREATE INDEX ix_review_condition_file_types_review_condition_id ON event_editing.review_condition_file_types USING btree (review_condition_id);


--
-- Name: ix_review_conditions_event_id; Type: INDEX; Schema: event_editing; Owner: indico
--

CREATE INDEX ix_review_conditions_event_id ON event_editing.review_conditions USING btree (event_id);


--
-- Name: ix_revision_files_file_id; Type: INDEX; Schema: event_editing; Owner: indico
--

CREATE INDEX ix_revision_files_file_id ON event_editing.revision_files USING btree (file_id);


--
-- Name: ix_revision_files_file_type_id; Type: INDEX; Schema: event_editing; Owner: indico
--

CREATE INDEX ix_revision_files_file_type_id ON event_editing.revision_files USING btree (file_type_id);


--
-- Name: ix_revision_files_revision_id; Type: INDEX; Schema: event_editing; Owner: indico
--

CREATE INDEX ix_revision_files_revision_id ON event_editing.revision_files USING btree (revision_id);


--
-- Name: ix_revision_tags_revision_id; Type: INDEX; Schema: event_editing; Owner: indico
--

CREATE INDEX ix_revision_tags_revision_id ON event_editing.revision_tags USING btree (revision_id);


--
-- Name: ix_revision_tags_tag_id; Type: INDEX; Schema: event_editing; Owner: indico
--

CREATE INDEX ix_revision_tags_tag_id ON event_editing.revision_tags USING btree (tag_id);


--
-- Name: ix_revisions_editable_id; Type: INDEX; Schema: event_editing; Owner: indico
--

CREATE INDEX ix_revisions_editable_id ON event_editing.revisions USING btree (editable_id);


--
-- Name: ix_revisions_user_id; Type: INDEX; Schema: event_editing; Owner: indico
--

CREATE INDEX ix_revisions_user_id ON event_editing.revisions USING btree (user_id);


--
-- Name: ix_tags_event_id; Type: INDEX; Schema: event_editing; Owner: indico
--

CREATE INDEX ix_tags_event_id ON event_editing.tags USING btree (event_id);


--
-- Name: ix_uq_editables_contribution_id_type; Type: INDEX; Schema: event_editing; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_editables_contribution_id_type ON event_editing.editables USING btree (contribution_id, type) WHERE (NOT is_deleted);


--
-- Name: ix_uq_file_types_event_id_type_name_lower; Type: INDEX; Schema: event_editing; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_file_types_event_id_type_name_lower ON event_editing.file_types USING btree (event_id, type, lower((name)::text));


--
-- Name: ix_uq_tags_event_id_code_lower; Type: INDEX; Schema: event_editing; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_tags_event_id_code_lower ON event_editing.tags USING btree (event_id, lower((code)::text));


--
-- Name: ix_competences_event_id; Type: INDEX; Schema: event_paper_reviewing; Owner: indico
--

CREATE INDEX ix_competences_event_id ON event_paper_reviewing.competences USING btree (event_id);


--
-- Name: ix_competences_user_id; Type: INDEX; Schema: event_paper_reviewing; Owner: indico
--

CREATE INDEX ix_competences_user_id ON event_paper_reviewing.competences USING btree (user_id);


--
-- Name: ix_content_reviewers_contribution_id; Type: INDEX; Schema: event_paper_reviewing; Owner: indico
--

CREATE INDEX ix_content_reviewers_contribution_id ON event_paper_reviewing.content_reviewers USING btree (contribution_id);


--
-- Name: ix_content_reviewers_user_id; Type: INDEX; Schema: event_paper_reviewing; Owner: indico
--

CREATE INDEX ix_content_reviewers_user_id ON event_paper_reviewing.content_reviewers USING btree (user_id);


--
-- Name: ix_files_contribution_id; Type: INDEX; Schema: event_paper_reviewing; Owner: indico
--

CREATE INDEX ix_files_contribution_id ON event_paper_reviewing.files USING btree (contribution_id);


--
-- Name: ix_files_revision_id; Type: INDEX; Schema: event_paper_reviewing; Owner: indico
--

CREATE INDEX ix_files_revision_id ON event_paper_reviewing.files USING btree (revision_id);


--
-- Name: ix_judges_contribution_id; Type: INDEX; Schema: event_paper_reviewing; Owner: indico
--

CREATE INDEX ix_judges_contribution_id ON event_paper_reviewing.judges USING btree (contribution_id);


--
-- Name: ix_judges_user_id; Type: INDEX; Schema: event_paper_reviewing; Owner: indico
--

CREATE INDEX ix_judges_user_id ON event_paper_reviewing.judges USING btree (user_id);


--
-- Name: ix_layout_reviewers_contribution_id; Type: INDEX; Schema: event_paper_reviewing; Owner: indico
--

CREATE INDEX ix_layout_reviewers_contribution_id ON event_paper_reviewing.layout_reviewers USING btree (contribution_id);


--
-- Name: ix_layout_reviewers_user_id; Type: INDEX; Schema: event_paper_reviewing; Owner: indico
--

CREATE INDEX ix_layout_reviewers_user_id ON event_paper_reviewing.layout_reviewers USING btree (user_id);


--
-- Name: ix_review_comments_modified_by_id; Type: INDEX; Schema: event_paper_reviewing; Owner: indico
--

CREATE INDEX ix_review_comments_modified_by_id ON event_paper_reviewing.review_comments USING btree (modified_by_id);


--
-- Name: ix_review_comments_revision_id; Type: INDEX; Schema: event_paper_reviewing; Owner: indico
--

CREATE INDEX ix_review_comments_revision_id ON event_paper_reviewing.review_comments USING btree (revision_id);


--
-- Name: ix_review_comments_user_id; Type: INDEX; Schema: event_paper_reviewing; Owner: indico
--

CREATE INDEX ix_review_comments_user_id ON event_paper_reviewing.review_comments USING btree (user_id);


--
-- Name: ix_review_questions_event_id; Type: INDEX; Schema: event_paper_reviewing; Owner: indico
--

CREATE INDEX ix_review_questions_event_id ON event_paper_reviewing.review_questions USING btree (event_id);


--
-- Name: ix_review_ratings_question_id; Type: INDEX; Schema: event_paper_reviewing; Owner: indico
--

CREATE INDEX ix_review_ratings_question_id ON event_paper_reviewing.review_ratings USING btree (question_id);


--
-- Name: ix_review_ratings_review_id; Type: INDEX; Schema: event_paper_reviewing; Owner: indico
--

CREATE INDEX ix_review_ratings_review_id ON event_paper_reviewing.review_ratings USING btree (review_id);


--
-- Name: ix_reviews_revision_id; Type: INDEX; Schema: event_paper_reviewing; Owner: indico
--

CREATE INDEX ix_reviews_revision_id ON event_paper_reviewing.reviews USING btree (revision_id);


--
-- Name: ix_reviews_user_id; Type: INDEX; Schema: event_paper_reviewing; Owner: indico
--

CREATE INDEX ix_reviews_user_id ON event_paper_reviewing.reviews USING btree (user_id);


--
-- Name: ix_revisions_contribution_id; Type: INDEX; Schema: event_paper_reviewing; Owner: indico
--

CREATE INDEX ix_revisions_contribution_id ON event_paper_reviewing.revisions USING btree (contribution_id);


--
-- Name: ix_revisions_judge_id; Type: INDEX; Schema: event_paper_reviewing; Owner: indico
--

CREATE INDEX ix_revisions_judge_id ON event_paper_reviewing.revisions USING btree (judge_id);


--
-- Name: ix_revisions_submitter_id; Type: INDEX; Schema: event_paper_reviewing; Owner: indico
--

CREATE INDEX ix_revisions_submitter_id ON event_paper_reviewing.revisions USING btree (submitter_id);


--
-- Name: ix_templates_event_id; Type: INDEX; Schema: event_paper_reviewing; Owner: indico
--

CREATE INDEX ix_templates_event_id ON event_paper_reviewing.templates USING btree (event_id);


--
-- Name: ix_uq_revisions_contribution_id; Type: INDEX; Schema: event_paper_reviewing; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_revisions_contribution_id ON event_paper_reviewing.revisions USING btree (contribution_id) WHERE (state = 2);


--
-- Name: ix_form_field_data_field_id; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE INDEX ix_form_field_data_field_id ON event_registration.form_field_data USING btree (field_id);


--
-- Name: ix_form_items_current_data_id; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE INDEX ix_form_items_current_data_id ON event_registration.form_items USING btree (current_data_id);


--
-- Name: ix_form_items_parent_id; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE INDEX ix_form_items_parent_id ON event_registration.form_items USING btree (parent_id);


--
-- Name: ix_form_items_registration_form_id; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE INDEX ix_form_items_registration_form_id ON event_registration.form_items USING btree (registration_form_id);


--
-- Name: ix_forms_event_id; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE INDEX ix_forms_event_id ON event_registration.forms USING btree (event_id);


--
-- Name: ix_forms_ticket_template_id; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE INDEX ix_forms_ticket_template_id ON event_registration.forms USING btree (ticket_template_id);


--
-- Name: ix_invitations_registration_form_id; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE INDEX ix_invitations_registration_form_id ON event_registration.invitations USING btree (registration_form_id);


--
-- Name: ix_legacy_registration_map_registration_id; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE INDEX ix_legacy_registration_map_registration_id ON event_registration.legacy_registration_map USING btree (registration_id);


--
-- Name: ix_receipt_files_file_id; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE INDEX ix_receipt_files_file_id ON event_registration.receipt_files USING btree (file_id);


--
-- Name: ix_receipt_files_registration_id; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE INDEX ix_receipt_files_registration_id ON event_registration.receipt_files USING btree (registration_id);


--
-- Name: ix_receipt_files_template_id; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE INDEX ix_receipt_files_template_id ON event_registration.receipt_files USING btree (template_id);


--
-- Name: ix_registration_tags_registration_id; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE INDEX ix_registration_tags_registration_id ON event_registration.registration_tags USING btree (registration_id);


--
-- Name: ix_registration_tags_registration_tag_id; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE INDEX ix_registration_tags_registration_tag_id ON event_registration.registration_tags USING btree (registration_tag_id);


--
-- Name: ix_registrations_event_id; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE INDEX ix_registrations_event_id ON event_registration.registrations USING btree (event_id);


--
-- Name: ix_registrations_registration_form_id; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE INDEX ix_registrations_registration_form_id ON event_registration.registrations USING btree (registration_form_id);


--
-- Name: ix_registrations_user_id; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE INDEX ix_registrations_user_id ON event_registration.registrations USING btree (user_id);


--
-- Name: ix_tags_event_id; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE INDEX ix_tags_event_id ON event_registration.tags USING btree (event_id);


--
-- Name: ix_uq_form_items_pd_field; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_form_items_pd_field ON event_registration.form_items USING btree (registration_form_id, personal_data_type) WHERE (type = 5);


--
-- Name: ix_uq_form_items_pd_section; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_form_items_pd_section ON event_registration.form_items USING btree (registration_form_id) WHERE (type = 4);


--
-- Name: ix_uq_forms_participation; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_forms_participation ON event_registration.forms USING btree (event_id) WHERE (is_participation AND (NOT is_deleted));


--
-- Name: ix_uq_invitations_registration_id; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_invitations_registration_id ON event_registration.invitations USING btree (registration_id);


--
-- Name: ix_uq_invitations_uuid; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_invitations_uuid ON event_registration.invitations USING btree (uuid);


--
-- Name: ix_uq_registrations_friendly_id_event_id; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_registrations_friendly_id_event_id ON event_registration.registrations USING btree (friendly_id, event_id) WHERE (NOT is_deleted);


--
-- Name: ix_uq_registrations_registration_form_id_email; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_registrations_registration_form_id_email ON event_registration.registrations USING btree (registration_form_id, email) WHERE ((NOT is_deleted) AND (state <> ALL (ARRAY[3, 4])));


--
-- Name: ix_uq_registrations_registration_form_id_user_id; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_registrations_registration_form_id_user_id ON event_registration.registrations USING btree (registration_form_id, user_id) WHERE ((NOT is_deleted) AND (state <> ALL (ARRAY[3, 4])));


--
-- Name: ix_uq_registrations_ticket_uuid; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_registrations_ticket_uuid ON event_registration.registrations USING btree (ticket_uuid);


--
-- Name: ix_uq_registrations_transaction_id; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_registrations_transaction_id ON event_registration.registrations USING btree (transaction_id);


--
-- Name: ix_uq_registrations_uuid; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_registrations_uuid ON event_registration.registrations USING btree (uuid);


--
-- Name: ix_uq_tags_title_lower; Type: INDEX; Schema: event_registration; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_tags_title_lower ON event_registration.tags USING btree (event_id, lower((title)::text));


--
-- Name: ix_anonymous_submissions_survey_id; Type: INDEX; Schema: event_surveys; Owner: indico
--

CREATE INDEX ix_anonymous_submissions_survey_id ON event_surveys.anonymous_submissions USING btree (survey_id);


--
-- Name: ix_anonymous_submissions_user_id; Type: INDEX; Schema: event_surveys; Owner: indico
--

CREATE INDEX ix_anonymous_submissions_user_id ON event_surveys.anonymous_submissions USING btree (user_id);


--
-- Name: ix_items_parent_id; Type: INDEX; Schema: event_surveys; Owner: indico
--

CREATE INDEX ix_items_parent_id ON event_surveys.items USING btree (parent_id);


--
-- Name: ix_items_survey_id; Type: INDEX; Schema: event_surveys; Owner: indico
--

CREATE INDEX ix_items_survey_id ON event_surveys.items USING btree (survey_id);


--
-- Name: ix_submissions_survey_id; Type: INDEX; Schema: event_surveys; Owner: indico
--

CREATE INDEX ix_submissions_survey_id ON event_surveys.submissions USING btree (survey_id);


--
-- Name: ix_submissions_user_id; Type: INDEX; Schema: event_surveys; Owner: indico
--

CREATE INDEX ix_submissions_user_id ON event_surveys.submissions USING btree (user_id);


--
-- Name: ix_surveys_event_id; Type: INDEX; Schema: event_surveys; Owner: indico
--

CREATE INDEX ix_surveys_event_id ON event_surveys.surveys USING btree (event_id);


--
-- Name: ix_agreements_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_agreements_event_id ON events.agreements USING btree (event_id);


--
-- Name: ix_agreements_user_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_agreements_user_id ON events.agreements USING btree (user_id);


--
-- Name: ix_breaks_room_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_breaks_room_id ON events.breaks USING btree (room_id);


--
-- Name: ix_breaks_venue_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_breaks_venue_id ON events.breaks USING btree (venue_id);


--
-- Name: ix_contribution_field_values_contribution_field_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contribution_field_values_contribution_field_id ON events.contribution_field_values USING btree (contribution_field_id);


--
-- Name: ix_contribution_field_values_contribution_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contribution_field_values_contribution_id ON events.contribution_field_values USING btree (contribution_id);


--
-- Name: ix_contribution_fields_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contribution_fields_event_id ON events.contribution_fields USING btree (event_id);


--
-- Name: ix_contribution_person_links_affiliation_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contribution_person_links_affiliation_id ON events.contribution_person_links USING btree (affiliation_id);


--
-- Name: ix_contribution_person_links_contribution_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contribution_person_links_contribution_id ON events.contribution_person_links USING btree (contribution_id);


--
-- Name: ix_contribution_person_links_person_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contribution_person_links_person_id ON events.contribution_person_links USING btree (person_id);


--
-- Name: ix_contribution_principals_category_role_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contribution_principals_category_role_id ON events.contribution_principals USING btree (category_role_id);


--
-- Name: ix_contribution_principals_contribution_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contribution_principals_contribution_id ON events.contribution_principals USING btree (contribution_id);


--
-- Name: ix_contribution_principals_email; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contribution_principals_email ON events.contribution_principals USING btree (email);


--
-- Name: ix_contribution_principals_event_role_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contribution_principals_event_role_id ON events.contribution_principals USING btree (event_role_id);


--
-- Name: ix_contribution_principals_local_group_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contribution_principals_local_group_id ON events.contribution_principals USING btree (local_group_id);


--
-- Name: ix_contribution_principals_mp_group_provider_mp_group_name; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contribution_principals_mp_group_provider_mp_group_name ON events.contribution_principals USING btree (mp_group_provider, mp_group_name);


--
-- Name: ix_contribution_principals_registration_form_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contribution_principals_registration_form_id ON events.contribution_principals USING btree (registration_form_id);


--
-- Name: ix_contribution_principals_user_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contribution_principals_user_id ON events.contribution_principals USING btree (user_id);


--
-- Name: ix_contribution_references_contribution_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contribution_references_contribution_id ON events.contribution_references USING btree (contribution_id);


--
-- Name: ix_contribution_references_reference_type_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contribution_references_reference_type_id ON events.contribution_references USING btree (reference_type_id);


--
-- Name: ix_contribution_types_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contribution_types_event_id ON events.contribution_types USING btree (event_id);


--
-- Name: ix_contributions_abstract_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contributions_abstract_id ON events.contributions USING btree (abstract_id);


--
-- Name: ix_contributions_description_fts; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contributions_description_fts ON events.contributions USING gin (to_tsvector('simple'::regconfig, description));


--
-- Name: ix_contributions_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contributions_event_id ON events.contributions USING btree (event_id);


--
-- Name: ix_contributions_event_id_abstract_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contributions_event_id_abstract_id ON events.contributions USING btree (event_id, abstract_id);


--
-- Name: ix_contributions_event_id_track_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contributions_event_id_track_id ON events.contributions USING btree (event_id, track_id);


--
-- Name: ix_contributions_room_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contributions_room_id ON events.contributions USING btree (room_id);


--
-- Name: ix_contributions_session_block_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contributions_session_block_id ON events.contributions USING btree (session_block_id);


--
-- Name: ix_contributions_session_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contributions_session_id ON events.contributions USING btree (session_id);


--
-- Name: ix_contributions_title_fts; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contributions_title_fts ON events.contributions USING gin (to_tsvector('simple'::regconfig, (title)::text));


--
-- Name: ix_contributions_track_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contributions_track_id ON events.contributions USING btree (track_id);


--
-- Name: ix_contributions_type_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contributions_type_id ON events.contributions USING btree (type_id);


--
-- Name: ix_contributions_venue_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_contributions_venue_id ON events.contributions USING btree (venue_id);


--
-- Name: ix_event_person_links_affiliation_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_event_person_links_affiliation_id ON events.event_person_links USING btree (affiliation_id);


--
-- Name: ix_event_person_links_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_event_person_links_event_id ON events.event_person_links USING btree (event_id);


--
-- Name: ix_event_person_links_person_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_event_person_links_person_id ON events.event_person_links USING btree (person_id);


--
-- Name: ix_event_references_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_event_references_event_id ON events.event_references USING btree (event_id);


--
-- Name: ix_event_references_reference_type_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_event_references_reference_type_id ON events.event_references USING btree (reference_type_id);


--
-- Name: ix_events_category_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_events_category_id ON events.events USING btree (category_id);


--
-- Name: ix_events_cloned_from_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_events_cloned_from_id ON events.events USING btree (cloned_from_id);


--
-- Name: ix_events_created_dt; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_events_created_dt ON events.events USING btree (created_dt);


--
-- Name: ix_events_creator_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_events_creator_id ON events.events USING btree (creator_id);


--
-- Name: ix_events_default_page_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_events_default_page_id ON events.events USING btree (default_page_id);


--
-- Name: ix_events_end_dt; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_events_end_dt ON events.events USING btree (end_dt);


--
-- Name: ix_events_end_dt_desc; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_events_end_dt_desc ON events.events USING btree (end_dt DESC);


--
-- Name: ix_events_label_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_events_label_id ON events.events USING btree (label_id);


--
-- Name: ix_events_not_deleted_category; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_events_not_deleted_category ON events.events USING btree (is_deleted, category_id);


--
-- Name: ix_events_not_deleted_category_dates; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_events_not_deleted_category_dates ON events.events USING btree (is_deleted, category_id, start_dt, end_dt);


--
-- Name: ix_events_room_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_events_room_id ON events.events USING btree (room_id);


--
-- Name: ix_events_series_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_events_series_id ON events.events USING btree (series_id);


--
-- Name: ix_events_start_dt; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_events_start_dt ON events.events USING btree (start_dt);


--
-- Name: ix_events_start_dt_desc; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_events_start_dt_desc ON events.events USING btree (start_dt DESC);


--
-- Name: ix_events_title_fts; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_events_title_fts ON events.events USING gin (to_tsvector('simple'::regconfig, (title)::text));


--
-- Name: ix_events_venue_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_events_venue_id ON events.events USING btree (venue_id);


--
-- Name: ix_image_files_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_image_files_event_id ON events.image_files USING btree (event_id);


--
-- Name: ix_legacy_contribution_id_map_contribution_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_legacy_contribution_id_map_contribution_id ON events.legacy_contribution_id_map USING btree (contribution_id);


--
-- Name: ix_legacy_id_map_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_legacy_id_map_event_id ON events.legacy_id_map USING btree (event_id);


--
-- Name: ix_legacy_id_map_legacy_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_legacy_id_map_legacy_event_id ON events.legacy_id_map USING btree (legacy_event_id);


--
-- Name: ix_legacy_image_id_map_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_legacy_image_id_map_event_id ON events.legacy_image_id_map USING btree (event_id);


--
-- Name: ix_legacy_image_id_map_image_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_legacy_image_id_map_image_id ON events.legacy_image_id_map USING btree (image_id);


--
-- Name: ix_legacy_image_id_map_legacy_image_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_legacy_image_id_map_legacy_image_id ON events.legacy_image_id_map USING btree (legacy_image_id);


--
-- Name: ix_legacy_page_id_map_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_legacy_page_id_map_event_id ON events.legacy_page_id_map USING btree (event_id);


--
-- Name: ix_legacy_page_id_map_legacy_page_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_legacy_page_id_map_legacy_page_id ON events.legacy_page_id_map USING btree (legacy_page_id);


--
-- Name: ix_legacy_page_id_map_page_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_legacy_page_id_map_page_id ON events.legacy_page_id_map USING btree (page_id);


--
-- Name: ix_legacy_session_block_id_map_session_block_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_legacy_session_block_id_map_session_block_id ON events.legacy_session_block_id_map USING btree (session_block_id);


--
-- Name: ix_legacy_session_id_map_session_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_legacy_session_id_map_session_id ON events.legacy_session_id_map USING btree (session_id);


--
-- Name: ix_legacy_subcontribution_id_map_subcontribution_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_legacy_subcontribution_id_map_subcontribution_id ON events.legacy_subcontribution_id_map USING btree (subcontribution_id);


--
-- Name: ix_logs_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_logs_event_id ON events.logs USING btree (event_id);


--
-- Name: ix_logs_meta; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_logs_meta ON events.logs USING gin (meta);


--
-- Name: ix_logs_user_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_logs_user_id ON events.logs USING btree (user_id);


--
-- Name: ix_menu_entries_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_menu_entries_event_id ON events.menu_entries USING btree (event_id);


--
-- Name: ix_menu_entries_page_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_menu_entries_page_id ON events.menu_entries USING btree (page_id);


--
-- Name: ix_menu_entries_parent_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_menu_entries_parent_id ON events.menu_entries USING btree (parent_id);


--
-- Name: ix_menu_entry_principals_category_role_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_menu_entry_principals_category_role_id ON events.menu_entry_principals USING btree (category_role_id);


--
-- Name: ix_menu_entry_principals_event_role_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_menu_entry_principals_event_role_id ON events.menu_entry_principals USING btree (event_role_id);


--
-- Name: ix_menu_entry_principals_local_group_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_menu_entry_principals_local_group_id ON events.menu_entry_principals USING btree (local_group_id);


--
-- Name: ix_menu_entry_principals_mp_group_provider_mp_group_name; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_menu_entry_principals_mp_group_provider_mp_group_name ON events.menu_entry_principals USING btree (mp_group_provider, mp_group_name);


--
-- Name: ix_menu_entry_principals_registration_form_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_menu_entry_principals_registration_form_id ON events.menu_entry_principals USING btree (registration_form_id);


--
-- Name: ix_menu_entry_principals_user_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_menu_entry_principals_user_id ON events.menu_entry_principals USING btree (user_id);


--
-- Name: ix_note_revisions_note_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_note_revisions_note_id ON events.note_revisions USING btree (note_id);


--
-- Name: ix_note_revisions_user_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_note_revisions_user_id ON events.note_revisions USING btree (user_id);


--
-- Name: ix_notes_contribution_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_notes_contribution_id ON events.notes USING btree (contribution_id);


--
-- Name: ix_notes_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_notes_event_id ON events.notes USING btree (event_id);


--
-- Name: ix_notes_html_fts; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_notes_html_fts ON events.notes USING gin (to_tsvector('simple'::regconfig, html));


--
-- Name: ix_notes_linked_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_notes_linked_event_id ON events.notes USING btree (linked_event_id);


--
-- Name: ix_notes_session_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_notes_session_id ON events.notes USING btree (session_id);


--
-- Name: ix_notes_subcontribution_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_notes_subcontribution_id ON events.notes USING btree (subcontribution_id);


--
-- Name: ix_pages_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_pages_event_id ON events.pages USING btree (event_id);


--
-- Name: ix_payment_transactions_registration_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_payment_transactions_registration_id ON events.payment_transactions USING btree (registration_id);


--
-- Name: ix_persons_affiliation_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_persons_affiliation_id ON events.persons USING btree (affiliation_id);


--
-- Name: ix_persons_email; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_persons_email ON events.persons USING btree (email);


--
-- Name: ix_persons_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_persons_event_id ON events.persons USING btree (event_id);


--
-- Name: ix_persons_user_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_persons_user_id ON events.persons USING btree (user_id);


--
-- Name: ix_principals_category_role_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_principals_category_role_id ON events.principals USING btree (category_role_id);


--
-- Name: ix_principals_email; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_principals_email ON events.principals USING btree (email);


--
-- Name: ix_principals_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_principals_event_id ON events.principals USING btree (event_id);


--
-- Name: ix_principals_event_role_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_principals_event_role_id ON events.principals USING btree (event_role_id);


--
-- Name: ix_principals_ip_network_group_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_principals_ip_network_group_id ON events.principals USING btree (ip_network_group_id);


--
-- Name: ix_principals_local_group_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_principals_local_group_id ON events.principals USING btree (local_group_id);


--
-- Name: ix_principals_mp_group_provider_mp_group_name; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_principals_mp_group_provider_mp_group_name ON events.principals USING btree (mp_group_provider, mp_group_name);


--
-- Name: ix_principals_registration_form_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_principals_registration_form_id ON events.principals USING btree (registration_form_id);


--
-- Name: ix_principals_user_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_principals_user_id ON events.principals USING btree (user_id);


--
-- Name: ix_reminders_creator_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_reminders_creator_id ON events.reminders USING btree (creator_id);


--
-- Name: ix_reminders_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_reminders_event_id ON events.reminders USING btree (event_id);


--
-- Name: ix_reminders_scheduled_dt; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_reminders_scheduled_dt ON events.reminders USING btree (scheduled_dt) WHERE (NOT is_sent);


--
-- Name: ix_requests_created_by_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_requests_created_by_id ON events.requests USING btree (created_by_id);


--
-- Name: ix_requests_created_dt; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_requests_created_dt ON events.requests USING btree (created_dt);


--
-- Name: ix_requests_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_requests_event_id ON events.requests USING btree (event_id);


--
-- Name: ix_requests_processed_by_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_requests_processed_by_id ON events.requests USING btree (processed_by_id);


--
-- Name: ix_role_members_role_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_role_members_role_id ON events.role_members USING btree (role_id);


--
-- Name: ix_role_members_user_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_role_members_user_id ON events.role_members USING btree (user_id);


--
-- Name: ix_roles_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_roles_event_id ON events.roles USING btree (event_id);


--
-- Name: ix_session_block_person_links_affiliation_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_session_block_person_links_affiliation_id ON events.session_block_person_links USING btree (affiliation_id);


--
-- Name: ix_session_block_person_links_person_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_session_block_person_links_person_id ON events.session_block_person_links USING btree (person_id);


--
-- Name: ix_session_block_person_links_session_block_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_session_block_person_links_session_block_id ON events.session_block_person_links USING btree (session_block_id);


--
-- Name: ix_session_blocks_room_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_session_blocks_room_id ON events.session_blocks USING btree (room_id);


--
-- Name: ix_session_blocks_session_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_session_blocks_session_id ON events.session_blocks USING btree (session_id);


--
-- Name: ix_session_blocks_venue_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_session_blocks_venue_id ON events.session_blocks USING btree (venue_id);


--
-- Name: ix_session_principals_category_role_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_session_principals_category_role_id ON events.session_principals USING btree (category_role_id);


--
-- Name: ix_session_principals_email; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_session_principals_email ON events.session_principals USING btree (email);


--
-- Name: ix_session_principals_event_role_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_session_principals_event_role_id ON events.session_principals USING btree (event_role_id);


--
-- Name: ix_session_principals_local_group_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_session_principals_local_group_id ON events.session_principals USING btree (local_group_id);


--
-- Name: ix_session_principals_mp_group_provider_mp_group_name; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_session_principals_mp_group_provider_mp_group_name ON events.session_principals USING btree (mp_group_provider, mp_group_name);


--
-- Name: ix_session_principals_registration_form_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_session_principals_registration_form_id ON events.session_principals USING btree (registration_form_id);


--
-- Name: ix_session_principals_session_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_session_principals_session_id ON events.session_principals USING btree (session_id);


--
-- Name: ix_session_principals_user_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_session_principals_user_id ON events.session_principals USING btree (user_id);


--
-- Name: ix_session_types_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_session_types_event_id ON events.session_types USING btree (event_id);


--
-- Name: ix_sessions_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_sessions_event_id ON events.sessions USING btree (event_id);


--
-- Name: ix_sessions_room_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_sessions_room_id ON events.sessions USING btree (room_id);


--
-- Name: ix_sessions_type_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_sessions_type_id ON events.sessions USING btree (type_id);


--
-- Name: ix_sessions_venue_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_sessions_venue_id ON events.sessions USING btree (venue_id);


--
-- Name: ix_settings_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_settings_event_id ON events.settings USING btree (event_id);


--
-- Name: ix_settings_event_id_module; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_settings_event_id_module ON events.settings USING btree (event_id, module);


--
-- Name: ix_settings_event_id_module_name; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_settings_event_id_module_name ON events.settings USING btree (event_id, module, name);


--
-- Name: ix_settings_module; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_settings_module ON events.settings USING btree (module);


--
-- Name: ix_settings_name; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_settings_name ON events.settings USING btree (name);


--
-- Name: ix_settings_principals_category_role_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_settings_principals_category_role_id ON events.settings_principals USING btree (category_role_id);


--
-- Name: ix_settings_principals_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_settings_principals_event_id ON events.settings_principals USING btree (event_id);


--
-- Name: ix_settings_principals_event_id_module; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_settings_principals_event_id_module ON events.settings_principals USING btree (event_id, module);


--
-- Name: ix_settings_principals_event_id_module_name; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_settings_principals_event_id_module_name ON events.settings_principals USING btree (event_id, module, name);


--
-- Name: ix_settings_principals_event_role_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_settings_principals_event_role_id ON events.settings_principals USING btree (event_role_id);


--
-- Name: ix_settings_principals_local_group_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_settings_principals_local_group_id ON events.settings_principals USING btree (local_group_id);


--
-- Name: ix_settings_principals_module; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_settings_principals_module ON events.settings_principals USING btree (module);


--
-- Name: ix_settings_principals_mp_group_provider_mp_group_name; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_settings_principals_mp_group_provider_mp_group_name ON events.settings_principals USING btree (mp_group_provider, mp_group_name);


--
-- Name: ix_settings_principals_name; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_settings_principals_name ON events.settings_principals USING btree (name);


--
-- Name: ix_settings_principals_user_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_settings_principals_user_id ON events.settings_principals USING btree (user_id);


--
-- Name: ix_static_list_links_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_static_list_links_event_id ON events.static_list_links USING btree (event_id);


--
-- Name: ix_static_sites_creator_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_static_sites_creator_id ON events.static_sites USING btree (creator_id);


--
-- Name: ix_static_sites_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_static_sites_event_id ON events.static_sites USING btree (event_id);


--
-- Name: ix_subcontribution_person_links_affiliation_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_subcontribution_person_links_affiliation_id ON events.subcontribution_person_links USING btree (affiliation_id);


--
-- Name: ix_subcontribution_person_links_person_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_subcontribution_person_links_person_id ON events.subcontribution_person_links USING btree (person_id);


--
-- Name: ix_subcontribution_person_links_subcontribution_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_subcontribution_person_links_subcontribution_id ON events.subcontribution_person_links USING btree (subcontribution_id);


--
-- Name: ix_subcontribution_references_reference_type_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_subcontribution_references_reference_type_id ON events.subcontribution_references USING btree (reference_type_id);


--
-- Name: ix_subcontribution_references_subcontribution_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_subcontribution_references_subcontribution_id ON events.subcontribution_references USING btree (subcontribution_id);


--
-- Name: ix_subcontributions_contribution_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_subcontributions_contribution_id ON events.subcontributions USING btree (contribution_id);


--
-- Name: ix_subcontributions_description_fts; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_subcontributions_description_fts ON events.subcontributions USING gin (to_tsvector('simple'::regconfig, description));


--
-- Name: ix_subcontributions_title_fts; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_subcontributions_title_fts ON events.subcontributions USING gin (to_tsvector('simple'::regconfig, (title)::text));


--
-- Name: ix_timetable_entries_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_timetable_entries_event_id ON events.timetable_entries USING btree (event_id);


--
-- Name: ix_timetable_entries_parent_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_timetable_entries_parent_id ON events.timetable_entries USING btree (parent_id);


--
-- Name: ix_timetable_entries_start_dt_desc; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_timetable_entries_start_dt_desc ON events.timetable_entries USING btree (start_dt DESC);


--
-- Name: ix_track_groups_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_track_groups_event_id ON events.track_groups USING btree (event_id);


--
-- Name: ix_track_principals_category_role_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_track_principals_category_role_id ON events.track_principals USING btree (category_role_id);


--
-- Name: ix_track_principals_event_role_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_track_principals_event_role_id ON events.track_principals USING btree (event_role_id);


--
-- Name: ix_track_principals_local_group_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_track_principals_local_group_id ON events.track_principals USING btree (local_group_id);


--
-- Name: ix_track_principals_mp_group_provider_mp_group_name; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_track_principals_mp_group_provider_mp_group_name ON events.track_principals USING btree (mp_group_provider, mp_group_name);


--
-- Name: ix_track_principals_track_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_track_principals_track_id ON events.track_principals USING btree (track_id);


--
-- Name: ix_track_principals_user_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_track_principals_user_id ON events.track_principals USING btree (user_id);


--
-- Name: ix_tracks_default_session_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_tracks_default_session_id ON events.tracks USING btree (default_session_id);


--
-- Name: ix_tracks_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_tracks_event_id ON events.tracks USING btree (event_id);


--
-- Name: ix_tracks_track_group_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_tracks_track_group_id ON events.tracks USING btree (track_group_id);


--
-- Name: ix_uq_contribution_principals_email; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_contribution_principals_email ON events.contribution_principals USING btree (email, contribution_id) WHERE (type = 4);


--
-- Name: ix_uq_contribution_principals_local_group; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_contribution_principals_local_group ON events.contribution_principals USING btree (local_group_id, contribution_id) WHERE (type = 2);


--
-- Name: ix_uq_contribution_principals_mp_group; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_contribution_principals_mp_group ON events.contribution_principals USING btree (mp_group_provider, mp_group_name, contribution_id) WHERE (type = 3);


--
-- Name: ix_uq_contribution_principals_user; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_contribution_principals_user ON events.contribution_principals USING btree (user_id, contribution_id) WHERE (type = 1);


--
-- Name: ix_uq_contribution_types_event_id_name_lower; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_contribution_types_event_id_name_lower ON events.contribution_types USING btree (event_id, lower((name)::text));


--
-- Name: ix_uq_contributions_abstract_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_contributions_abstract_id ON events.contributions USING btree (abstract_id) WHERE (NOT is_deleted);


--
-- Name: ix_uq_contributions_friendly_id_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_contributions_friendly_id_event_id ON events.contributions USING btree (friendly_id, event_id) WHERE (NOT is_deleted);


--
-- Name: ix_uq_events_url_shortcut; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_events_url_shortcut ON events.events USING btree (lower((url_shortcut)::text)) WHERE (NOT is_deleted);


--
-- Name: ix_uq_labels_title_lower; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_labels_title_lower ON events.labels USING btree (lower((title)::text));


--
-- Name: ix_uq_menu_entries_event_id_name; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_menu_entries_event_id_name ON events.menu_entries USING btree (event_id, name) WHERE ((type = 2) OR (type = 4));


--
-- Name: ix_uq_menu_entry_principals_local_group; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_menu_entry_principals_local_group ON events.menu_entry_principals USING btree (local_group_id, menu_entry_id) WHERE (type = 2);


--
-- Name: ix_uq_menu_entry_principals_mp_group; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_menu_entry_principals_mp_group ON events.menu_entry_principals USING btree (mp_group_provider, mp_group_name, menu_entry_id) WHERE (type = 3);


--
-- Name: ix_uq_menu_entry_principals_user; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_menu_entry_principals_user ON events.menu_entry_principals USING btree (user_id, menu_entry_id) WHERE (type = 1);


--
-- Name: ix_uq_notes_contribution_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_notes_contribution_id ON events.notes USING btree (contribution_id) WHERE (link_type = 3);


--
-- Name: ix_uq_notes_linked_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_notes_linked_event_id ON events.notes USING btree (linked_event_id) WHERE (link_type = 2);


--
-- Name: ix_uq_notes_session_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_notes_session_id ON events.notes USING btree (session_id) WHERE (link_type = 5);


--
-- Name: ix_uq_notes_subcontribution_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_notes_subcontribution_id ON events.notes USING btree (subcontribution_id) WHERE (link_type = 4);


--
-- Name: ix_uq_persons_event_id_email; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_persons_event_id_email ON events.persons USING btree (event_id, email) WHERE ((email)::text <> ''::text);


--
-- Name: ix_uq_principals_email; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_principals_email ON events.principals USING btree (email, event_id) WHERE (type = 4);


--
-- Name: ix_uq_principals_local_group; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_principals_local_group ON events.principals USING btree (local_group_id, event_id) WHERE (type = 2);


--
-- Name: ix_uq_principals_mp_group; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_principals_mp_group ON events.principals USING btree (mp_group_provider, mp_group_name, event_id) WHERE (type = 3);


--
-- Name: ix_uq_principals_user; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_principals_user ON events.principals USING btree (user_id, event_id) WHERE (type = 1);


--
-- Name: ix_uq_roles_event_id_code; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_roles_event_id_code ON events.roles USING btree (event_id, code);


--
-- Name: ix_uq_session_principals_email; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_session_principals_email ON events.session_principals USING btree (email, session_id) WHERE (type = 4);


--
-- Name: ix_uq_session_principals_local_group; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_session_principals_local_group ON events.session_principals USING btree (local_group_id, session_id) WHERE (type = 2);


--
-- Name: ix_uq_session_principals_mp_group; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_session_principals_mp_group ON events.session_principals USING btree (mp_group_provider, mp_group_name, session_id) WHERE (type = 3);


--
-- Name: ix_uq_session_principals_user; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_session_principals_user ON events.session_principals USING btree (user_id, session_id) WHERE (type = 1);


--
-- Name: ix_uq_session_types_event_id_name_lower; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_session_types_event_id_name_lower ON events.session_types USING btree (event_id, lower((name)::text));


--
-- Name: ix_uq_sessions_friendly_id_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_sessions_friendly_id_event_id ON events.sessions USING btree (friendly_id, event_id) WHERE (NOT is_deleted);


--
-- Name: ix_uq_settings_principals_local_group; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_settings_principals_local_group ON events.settings_principals USING btree (local_group_id, module, name, event_id) WHERE (type = 2);


--
-- Name: ix_uq_settings_principals_mp_group; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_settings_principals_mp_group ON events.settings_principals USING btree (mp_group_provider, mp_group_name, module, name, event_id) WHERE (type = 3);


--
-- Name: ix_uq_settings_principals_user; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_settings_principals_user ON events.settings_principals USING btree (user_id, module, name, event_id) WHERE (type = 1);


--
-- Name: ix_uq_static_list_links_uuid; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_static_list_links_uuid ON events.static_list_links USING btree (uuid);


--
-- Name: ix_uq_subcontributions_friendly_id_contribution_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_subcontributions_friendly_id_contribution_id ON events.subcontributions USING btree (friendly_id, contribution_id);


--
-- Name: ix_uq_timetable_entries_break_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_timetable_entries_break_id ON events.timetable_entries USING btree (break_id);


--
-- Name: ix_uq_timetable_entries_contribution_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_timetable_entries_contribution_id ON events.timetable_entries USING btree (contribution_id);


--
-- Name: ix_uq_timetable_entries_session_block_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_timetable_entries_session_block_id ON events.timetable_entries USING btree (session_block_id);


--
-- Name: ix_uq_track_principals_local_group; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_track_principals_local_group ON events.track_principals USING btree (local_group_id, track_id) WHERE (type = 2);


--
-- Name: ix_uq_track_principals_mp_group; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_track_principals_mp_group ON events.track_principals USING btree (mp_group_provider, mp_group_name, track_id) WHERE (type = 3);


--
-- Name: ix_uq_track_principals_user; Type: INDEX; Schema: events; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_track_principals_user ON events.track_principals USING btree (user_id, track_id) WHERE (type = 1);


--
-- Name: ix_vc_room_events_contribution_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_vc_room_events_contribution_id ON events.vc_room_events USING btree (contribution_id);


--
-- Name: ix_vc_room_events_data; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_vc_room_events_data ON events.vc_room_events USING gin (data);


--
-- Name: ix_vc_room_events_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_vc_room_events_event_id ON events.vc_room_events USING btree (event_id);


--
-- Name: ix_vc_room_events_linked_event_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_vc_room_events_linked_event_id ON events.vc_room_events USING btree (linked_event_id);


--
-- Name: ix_vc_room_events_session_block_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_vc_room_events_session_block_id ON events.vc_room_events USING btree (session_block_id);


--
-- Name: ix_vc_room_events_vc_room_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_vc_room_events_vc_room_id ON events.vc_room_events USING btree (vc_room_id);


--
-- Name: ix_vc_rooms_created_by_id; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_vc_rooms_created_by_id ON events.vc_rooms USING btree (created_by_id);


--
-- Name: ix_vc_rooms_data; Type: INDEX; Schema: events; Owner: indico
--

CREATE INDEX ix_vc_rooms_data ON events.vc_rooms USING gin (data);


--
-- Name: ix_affiliations_meta; Type: INDEX; Schema: indico; Owner: indico
--

CREATE INDEX ix_affiliations_meta ON indico.affiliations USING gin (meta);


--
-- Name: ix_affiliations_name; Type: INDEX; Schema: indico; Owner: indico
--

CREATE INDEX ix_affiliations_name ON indico.affiliations USING btree (name);


--
-- Name: ix_affiliations_searchable_names_fts; Type: INDEX; Schema: indico; Owner: indico
--

CREATE INDEX ix_affiliations_searchable_names_fts ON indico.affiliations USING gin (to_tsvector('simple'::regconfig, indico.text_array_to_string(((ARRAY[''::text] || indico.text_array_append((alt_names)::text[], (name)::text)) || ARRAY[''::text]), '|||'::text)));


--
-- Name: ix_affiliations_searchable_names_unaccent; Type: INDEX; Schema: indico; Owner: indico
--

CREATE INDEX ix_affiliations_searchable_names_unaccent ON indico.affiliations USING gin (indico.indico_unaccent(lower(indico.text_array_to_string(((ARRAY[''::text] || indico.text_array_append((alt_names)::text[], (name)::text)) || ARRAY[''::text]), '|||'::text))) public.gin_trgm_ops);


--
-- Name: ix_designer_image_files_template_id; Type: INDEX; Schema: indico; Owner: indico
--

CREATE INDEX ix_designer_image_files_template_id ON indico.designer_image_files USING btree (template_id);


--
-- Name: ix_designer_templates_backside_template_id; Type: INDEX; Schema: indico; Owner: indico
--

CREATE INDEX ix_designer_templates_backside_template_id ON indico.designer_templates USING btree (backside_template_id);


--
-- Name: ix_designer_templates_category_id; Type: INDEX; Schema: indico; Owner: indico
--

CREATE INDEX ix_designer_templates_category_id ON indico.designer_templates USING btree (category_id);


--
-- Name: ix_designer_templates_event_id; Type: INDEX; Schema: indico; Owner: indico
--

CREATE INDEX ix_designer_templates_event_id ON indico.designer_templates USING btree (event_id);


--
-- Name: ix_designer_templates_registration_form_id; Type: INDEX; Schema: indico; Owner: indico
--

CREATE INDEX ix_designer_templates_registration_form_id ON indico.designer_templates USING btree (registration_form_id);


--
-- Name: ix_receipt_templates_category_id; Type: INDEX; Schema: indico; Owner: indico
--

CREATE INDEX ix_receipt_templates_category_id ON indico.receipt_templates USING btree (category_id);


--
-- Name: ix_receipt_templates_event_id; Type: INDEX; Schema: indico; Owner: indico
--

CREATE INDEX ix_receipt_templates_event_id ON indico.receipt_templates USING btree (event_id);


--
-- Name: ix_settings_module; Type: INDEX; Schema: indico; Owner: indico
--

CREATE INDEX ix_settings_module ON indico.settings USING btree (module);


--
-- Name: ix_settings_module_name; Type: INDEX; Schema: indico; Owner: indico
--

CREATE INDEX ix_settings_module_name ON indico.settings USING btree (module, name);


--
-- Name: ix_settings_name; Type: INDEX; Schema: indico; Owner: indico
--

CREATE INDEX ix_settings_name ON indico.settings USING btree (name);


--
-- Name: ix_settings_principals_local_group_id; Type: INDEX; Schema: indico; Owner: indico
--

CREATE INDEX ix_settings_principals_local_group_id ON indico.settings_principals USING btree (local_group_id);


--
-- Name: ix_settings_principals_module; Type: INDEX; Schema: indico; Owner: indico
--

CREATE INDEX ix_settings_principals_module ON indico.settings_principals USING btree (module);


--
-- Name: ix_settings_principals_module_name; Type: INDEX; Schema: indico; Owner: indico
--

CREATE INDEX ix_settings_principals_module_name ON indico.settings_principals USING btree (module, name);


--
-- Name: ix_settings_principals_mp_group_provider_mp_group_name; Type: INDEX; Schema: indico; Owner: indico
--

CREATE INDEX ix_settings_principals_mp_group_provider_mp_group_name ON indico.settings_principals USING btree (mp_group_provider, mp_group_name);


--
-- Name: ix_settings_principals_name; Type: INDEX; Schema: indico; Owner: indico
--

CREATE INDEX ix_settings_principals_name ON indico.settings_principals USING btree (name);


--
-- Name: ix_settings_principals_user_id; Type: INDEX; Schema: indico; Owner: indico
--

CREATE INDEX ix_settings_principals_user_id ON indico.settings_principals USING btree (user_id);


--
-- Name: ix_uq_files_uuid; Type: INDEX; Schema: indico; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_files_uuid ON indico.files USING btree (uuid);


--
-- Name: ix_uq_ip_network_groups_name_lower; Type: INDEX; Schema: indico; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_ip_network_groups_name_lower ON indico.ip_network_groups USING btree (lower((name)::text));


--
-- Name: ix_uq_reference_types_name_lower; Type: INDEX; Schema: indico; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_reference_types_name_lower ON indico.reference_types USING btree (lower((name)::text));


--
-- Name: ix_uq_settings_principals_local_group; Type: INDEX; Schema: indico; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_settings_principals_local_group ON indico.settings_principals USING btree (local_group_id, module, name) WHERE (type = 2);


--
-- Name: ix_uq_settings_principals_mp_group; Type: INDEX; Schema: indico; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_settings_principals_mp_group ON indico.settings_principals USING btree (mp_group_provider, mp_group_name, module, name) WHERE (type = 3);


--
-- Name: ix_uq_settings_principals_user; Type: INDEX; Schema: indico; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_settings_principals_user ON indico.settings_principals USING btree (user_id, module, name) WHERE (type = 1);


--
-- Name: ix_application_user_links_application_id; Type: INDEX; Schema: oauth; Owner: indico
--

CREATE INDEX ix_application_user_links_application_id ON oauth.application_user_links USING btree (application_id);


--
-- Name: ix_application_user_links_user_id; Type: INDEX; Schema: oauth; Owner: indico
--

CREATE INDEX ix_application_user_links_user_id ON oauth.application_user_links USING btree (user_id);


--
-- Name: ix_tokens_app_user_link_id; Type: INDEX; Schema: oauth; Owner: indico
--

CREATE INDEX ix_tokens_app_user_link_id ON oauth.tokens USING btree (app_user_link_id);


--
-- Name: ix_uq_applications_name_lower; Type: INDEX; Schema: oauth; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_applications_name_lower ON oauth.applications USING btree (lower((name)::text));


--
-- Name: ix_uq_applications_system_app_type; Type: INDEX; Schema: oauth; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_applications_system_app_type ON oauth.applications USING btree (system_app_type) WHERE (system_app_type <> 0);


--
-- Name: ix_uq_tokens_access_token_hash; Type: INDEX; Schema: oauth; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_tokens_access_token_hash ON oauth.tokens USING btree (access_token_hash);


--
-- Name: ix_blocked_rooms_room_id; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_blocked_rooms_room_id ON roombooking.blocked_rooms USING btree (room_id);


--
-- Name: ix_blocking_principals_local_group_id; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_blocking_principals_local_group_id ON roombooking.blocking_principals USING btree (local_group_id);


--
-- Name: ix_blocking_principals_mp_group_provider_mp_group_name; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_blocking_principals_mp_group_provider_mp_group_name ON roombooking.blocking_principals USING btree (mp_group_provider, mp_group_name);


--
-- Name: ix_blocking_principals_user_id; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_blocking_principals_user_id ON roombooking.blocking_principals USING btree (user_id);


--
-- Name: ix_blockings_created_by_id; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_blockings_created_by_id ON roombooking.blockings USING btree (created_by_id);


--
-- Name: ix_blockings_end_date; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_blockings_end_date ON roombooking.blockings USING btree (end_date);


--
-- Name: ix_blockings_start_date; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_blockings_start_date ON roombooking.blockings USING btree (start_date);


--
-- Name: ix_favorite_rooms_room_id; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_favorite_rooms_room_id ON roombooking.favorite_rooms USING btree (room_id);


--
-- Name: ix_favorite_rooms_user_id; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_favorite_rooms_user_id ON roombooking.favorite_rooms USING btree (user_id);


--
-- Name: ix_location_principals_local_group_id; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_location_principals_local_group_id ON roombooking.location_principals USING btree (local_group_id);


--
-- Name: ix_location_principals_location_id; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_location_principals_location_id ON roombooking.location_principals USING btree (location_id);


--
-- Name: ix_location_principals_mp_group_provider_mp_group_name; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_location_principals_mp_group_provider_mp_group_name ON roombooking.location_principals USING btree (mp_group_provider, mp_group_name);


--
-- Name: ix_location_principals_user_id; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_location_principals_user_id ON roombooking.location_principals USING btree (user_id);


--
-- Name: ix_reservation_edit_logs_reservation_id; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_reservation_edit_logs_reservation_id ON roombooking.reservation_edit_logs USING btree (reservation_id);


--
-- Name: ix_reservation_occurrence_links_contribution_id; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_reservation_occurrence_links_contribution_id ON roombooking.reservation_occurrence_links USING btree (contribution_id);


--
-- Name: ix_reservation_occurrence_links_event_id; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_reservation_occurrence_links_event_id ON roombooking.reservation_occurrence_links USING btree (event_id);


--
-- Name: ix_reservation_occurrence_links_linked_event_id; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_reservation_occurrence_links_linked_event_id ON roombooking.reservation_occurrence_links USING btree (linked_event_id);


--
-- Name: ix_reservation_occurrence_links_session_block_id; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_reservation_occurrence_links_session_block_id ON roombooking.reservation_occurrence_links USING btree (session_block_id);


--
-- Name: ix_reservation_occurrences_end_dt; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_reservation_occurrences_end_dt ON roombooking.reservation_occurrences USING btree (end_dt);


--
-- Name: ix_reservation_occurrences_link_id; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_reservation_occurrences_link_id ON roombooking.reservation_occurrences USING btree (link_id);


--
-- Name: ix_reservation_occurrences_start_dt; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_reservation_occurrences_start_dt ON roombooking.reservation_occurrences USING btree (start_dt);


--
-- Name: ix_reservations_booked_for_id; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_reservations_booked_for_id ON roombooking.reservations USING btree (booked_for_id);


--
-- Name: ix_reservations_created_by_id; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_reservations_created_by_id ON roombooking.reservations USING btree (created_by_id);


--
-- Name: ix_reservations_end_dt; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_reservations_end_dt ON roombooking.reservations USING btree (end_dt);


--
-- Name: ix_reservations_end_dt_date; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_reservations_end_dt_date ON roombooking.reservations USING btree (((end_dt)::date));


--
-- Name: ix_reservations_end_dt_time; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_reservations_end_dt_time ON roombooking.reservations USING btree (((end_dt)::time without time zone));


--
-- Name: ix_reservations_room_id; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_reservations_room_id ON roombooking.reservations USING btree (room_id);


--
-- Name: ix_reservations_start_dt; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_reservations_start_dt ON roombooking.reservations USING btree (start_dt);


--
-- Name: ix_reservations_start_dt_date; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_reservations_start_dt_date ON roombooking.reservations USING btree (((start_dt)::date));


--
-- Name: ix_reservations_start_dt_time; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_reservations_start_dt_time ON roombooking.reservations USING btree (((start_dt)::time without time zone));


--
-- Name: ix_room_principals_local_group_id; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_room_principals_local_group_id ON roombooking.room_principals USING btree (local_group_id);


--
-- Name: ix_room_principals_mp_group_provider_mp_group_name; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_room_principals_mp_group_provider_mp_group_name ON roombooking.room_principals USING btree (mp_group_provider, mp_group_name);


--
-- Name: ix_room_principals_room_id; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_room_principals_room_id ON roombooking.room_principals USING btree (room_id);


--
-- Name: ix_room_principals_user_id; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_room_principals_user_id ON roombooking.room_principals USING btree (user_id);


--
-- Name: ix_rooms_owner_id; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE INDEX ix_rooms_owner_id ON roombooking.rooms USING btree (owner_id);


--
-- Name: ix_uq_blocking_principals_local_group; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_blocking_principals_local_group ON roombooking.blocking_principals USING btree (local_group_id, blocking_id) WHERE (type = 2);


--
-- Name: ix_uq_blocking_principals_mp_group; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_blocking_principals_mp_group ON roombooking.blocking_principals USING btree (mp_group_provider, mp_group_name, blocking_id) WHERE (type = 3);


--
-- Name: ix_uq_blocking_principals_user; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_blocking_principals_user ON roombooking.blocking_principals USING btree (user_id, blocking_id) WHERE (type = 1);


--
-- Name: ix_uq_equipment_types_name; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_equipment_types_name ON roombooking.equipment_types USING btree (name);


--
-- Name: ix_uq_features_name; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_features_name ON roombooking.features USING btree (name);


--
-- Name: ix_uq_location_principals_local_group; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_location_principals_local_group ON roombooking.location_principals USING btree (local_group_id, location_id) WHERE (type = 2);


--
-- Name: ix_uq_location_principals_mp_group; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_location_principals_mp_group ON roombooking.location_principals USING btree (mp_group_provider, mp_group_name, location_id) WHERE (type = 3);


--
-- Name: ix_uq_location_principals_user; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_location_principals_user ON roombooking.location_principals USING btree (user_id, location_id) WHERE (type = 1);


--
-- Name: ix_uq_locations_name; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_locations_name ON roombooking.locations USING btree (name) WHERE (NOT is_deleted);


--
-- Name: ix_uq_map_areas_is_default; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_map_areas_is_default ON roombooking.map_areas USING btree (is_default) WHERE is_default;


--
-- Name: ix_uq_room_attributes_name; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_room_attributes_name ON roombooking.room_attributes USING btree (name);


--
-- Name: ix_uq_room_bookable_hours_room_id_start_time_end_time_weekday; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_room_bookable_hours_room_id_start_time_end_time_weekday ON roombooking.room_bookable_hours USING btree (room_id, start_time, end_time, weekday);


--
-- Name: ix_uq_room_principals_local_group; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_room_principals_local_group ON roombooking.room_principals USING btree (local_group_id, room_id) WHERE (type = 2);


--
-- Name: ix_uq_room_principals_mp_group; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_room_principals_mp_group ON roombooking.room_principals USING btree (mp_group_provider, mp_group_name, room_id) WHERE (type = 3);


--
-- Name: ix_uq_room_principals_user; Type: INDEX; Schema: roombooking; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_room_principals_user ON roombooking.room_principals USING btree (user_id, room_id) WHERE (type = 1);


--
-- Name: ix_api_keys_user_id; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_api_keys_user_id ON users.api_keys USING btree (user_id);


--
-- Name: ix_data_export_requests_file_id; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_data_export_requests_file_id ON users.data_export_requests USING btree (file_id);


--
-- Name: ix_data_export_requests_user_id; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_data_export_requests_user_id ON users.data_export_requests USING btree (user_id);


--
-- Name: ix_emails_email; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_emails_email ON users.emails USING btree (email);


--
-- Name: ix_emails_email_unaccent; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_emails_email_unaccent ON users.emails USING gin (indico.indico_unaccent(lower((email)::text)) public.gin_trgm_ops);


--
-- Name: ix_emails_user_id; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_emails_user_id ON users.emails USING btree (user_id);


--
-- Name: ix_favorite_categories_target_id; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_favorite_categories_target_id ON users.favorite_categories USING btree (target_id);


--
-- Name: ix_favorite_categories_user_id; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_favorite_categories_user_id ON users.favorite_categories USING btree (user_id);


--
-- Name: ix_favorite_events_target_id; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_favorite_events_target_id ON users.favorite_events USING btree (target_id);


--
-- Name: ix_favorite_events_user_id; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_favorite_events_user_id ON users.favorite_events USING btree (user_id);


--
-- Name: ix_favorite_users_target_id; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_favorite_users_target_id ON users.favorite_users USING btree (target_id);


--
-- Name: ix_favorite_users_user_id; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_favorite_users_user_id ON users.favorite_users USING btree (user_id);


--
-- Name: ix_group_members_group_id; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_group_members_group_id ON users.group_members USING btree (group_id);


--
-- Name: ix_group_members_user_id; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_group_members_user_id ON users.group_members USING btree (user_id);


--
-- Name: ix_groups_name; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_groups_name ON users.groups USING btree (name);


--
-- Name: ix_logs_meta; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_logs_meta ON users.logs USING gin (meta);


--
-- Name: ix_logs_target_user_id; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_logs_target_user_id ON users.logs USING btree (target_user_id);


--
-- Name: ix_logs_user_id; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_logs_user_id ON users.logs USING btree (user_id);


--
-- Name: ix_settings_module; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_settings_module ON users.settings USING btree (module);


--
-- Name: ix_settings_name; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_settings_name ON users.settings USING btree (name);


--
-- Name: ix_settings_user_id; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_settings_user_id ON users.settings USING btree (user_id);


--
-- Name: ix_settings_user_id_module; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_settings_user_id_module ON users.settings USING btree (user_id, module);


--
-- Name: ix_settings_user_id_module_name; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_settings_user_id_module_name ON users.settings USING btree (user_id, module, name);


--
-- Name: ix_suggested_categories_category_id; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_suggested_categories_category_id ON users.suggested_categories USING btree (category_id);


--
-- Name: ix_suggested_categories_user_id; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_suggested_categories_user_id ON users.suggested_categories USING btree (user_id);


--
-- Name: ix_tokens_user_id; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_tokens_user_id ON users.tokens USING btree (user_id);


--
-- Name: ix_uq_api_keys_user_id; Type: INDEX; Schema: users; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_api_keys_user_id ON users.api_keys USING btree (user_id) WHERE is_active;


--
-- Name: ix_uq_emails_email; Type: INDEX; Schema: users; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_emails_email ON users.emails USING btree (email) WHERE (NOT is_user_deleted);


--
-- Name: ix_uq_emails_user_id; Type: INDEX; Schema: users; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_emails_user_id ON users.emails USING btree (user_id) WHERE (is_primary AND (NOT is_user_deleted));


--
-- Name: ix_uq_groups_name_lower; Type: INDEX; Schema: users; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_groups_name_lower ON users.groups USING btree (lower((name)::text));


--
-- Name: ix_uq_registration_requests_email; Type: INDEX; Schema: users; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_registration_requests_email ON users.registration_requests USING btree (email);


--
-- Name: ix_uq_tokens_access_token_hash; Type: INDEX; Schema: users; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_tokens_access_token_hash ON users.tokens USING btree (access_token_hash);


--
-- Name: ix_uq_user_id_name_lower; Type: INDEX; Schema: users; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_user_id_name_lower ON users.tokens USING btree (user_id, lower((name)::text)) WHERE (revoked_dt IS NULL);


--
-- Name: ix_uq_users_is_system; Type: INDEX; Schema: users; Owner: indico
--

CREATE UNIQUE INDEX ix_uq_users_is_system ON users.users USING btree (is_system) WHERE is_system;


--
-- Name: ix_users_address_unaccent; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_users_address_unaccent ON users.users USING gin (indico.indico_unaccent(lower(address)) public.gin_trgm_ops);


--
-- Name: ix_users_affiliation; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_users_affiliation ON users.users USING btree (affiliation);


--
-- Name: ix_users_affiliation_id; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_users_affiliation_id ON users.users USING btree (affiliation_id);


--
-- Name: ix_users_affiliation_unaccent; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_users_affiliation_unaccent ON users.users USING gin (indico.indico_unaccent(lower((affiliation)::text)) public.gin_trgm_ops);


--
-- Name: ix_users_first_name; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_users_first_name ON users.users USING btree (first_name);


--
-- Name: ix_users_first_name_unaccent; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_users_first_name_unaccent ON users.users USING gin (indico.indico_unaccent(lower((first_name)::text)) public.gin_trgm_ops);


--
-- Name: ix_users_is_admin; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_users_is_admin ON users.users USING btree (is_admin);


--
-- Name: ix_users_last_name; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_users_last_name ON users.users USING btree (last_name);


--
-- Name: ix_users_last_name_unaccent; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_users_last_name_unaccent ON users.users USING gin (indico.indico_unaccent(lower((last_name)::text)) public.gin_trgm_ops);


--
-- Name: ix_users_merged_into_id; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_users_merged_into_id ON users.users USING btree (merged_into_id);


--
-- Name: ix_users_phone_unaccent; Type: INDEX; Schema: users; Owner: indico
--

CREATE INDEX ix_users_phone_unaccent ON users.users USING gin (indico.indico_unaccent(lower((phone)::text)) public.gin_trgm_ops);


--
-- Name: categories consistent_deleted; Type: TRIGGER; Schema: categories; Owner: indico
--

CREATE CONSTRAINT TRIGGER consistent_deleted AFTER INSERT OR UPDATE OF parent_id, is_deleted ON categories.categories DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION categories.check_consistency_deleted();


--
-- Name: categories no_cycles; Type: TRIGGER; Schema: categories; Owner: indico
--

CREATE CONSTRAINT TRIGGER no_cycles AFTER INSERT OR UPDATE OF parent_id ON categories.categories NOT DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE FUNCTION categories.check_cycles();


--
-- Name: events consistent_deleted; Type: TRIGGER; Schema: events; Owner: indico
--

CREATE CONSTRAINT TRIGGER consistent_deleted AFTER INSERT OR UPDATE OF category_id, is_deleted ON events.events DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION categories.check_consistency_deleted();


--
-- Name: breaks consistent_timetable; Type: TRIGGER; Schema: events; Owner: indico
--

CREATE CONSTRAINT TRIGGER consistent_timetable AFTER INSERT OR UPDATE OF duration ON events.breaks DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION events.check_timetable_consistency('break');


--
-- Name: contributions consistent_timetable; Type: TRIGGER; Schema: events; Owner: indico
--

CREATE CONSTRAINT TRIGGER consistent_timetable AFTER INSERT OR UPDATE OF event_id, session_id, session_block_id, duration ON events.contributions DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION events.check_timetable_consistency('contribution');


--
-- Name: events consistent_timetable; Type: TRIGGER; Schema: events; Owner: indico
--

CREATE CONSTRAINT TRIGGER consistent_timetable AFTER UPDATE OF start_dt, end_dt ON events.events DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION events.check_timetable_consistency('event');


--
-- Name: session_blocks consistent_timetable; Type: TRIGGER; Schema: events; Owner: indico
--

CREATE CONSTRAINT TRIGGER consistent_timetable AFTER INSERT OR UPDATE OF session_id, duration ON events.session_blocks DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION events.check_timetable_consistency('session_block');


--
-- Name: timetable_entries consistent_timetable; Type: TRIGGER; Schema: events; Owner: indico
--

CREATE CONSTRAINT TRIGGER consistent_timetable AFTER INSERT OR UPDATE ON events.timetable_entries DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION events.check_timetable_consistency('timetable_entry');


--
-- Name: attachment_principals fk_attachment_principals_attachment_id_attachments; Type: FK CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.attachment_principals
    ADD CONSTRAINT fk_attachment_principals_attachment_id_attachments FOREIGN KEY (attachment_id) REFERENCES attachments.attachments(id);


--
-- Name: attachment_principals fk_attachment_principals_category_role_id_roles; Type: FK CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.attachment_principals
    ADD CONSTRAINT fk_attachment_principals_category_role_id_roles FOREIGN KEY (category_role_id) REFERENCES categories.roles(id);


--
-- Name: attachment_principals fk_attachment_principals_event_role_id_roles; Type: FK CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.attachment_principals
    ADD CONSTRAINT fk_attachment_principals_event_role_id_roles FOREIGN KEY (event_role_id) REFERENCES events.roles(id);


--
-- Name: attachment_principals fk_attachment_principals_local_group_id_groups; Type: FK CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.attachment_principals
    ADD CONSTRAINT fk_attachment_principals_local_group_id_groups FOREIGN KEY (local_group_id) REFERENCES users.groups(id);


--
-- Name: attachment_principals fk_attachment_principals_registration_form_id_forms; Type: FK CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.attachment_principals
    ADD CONSTRAINT fk_attachment_principals_registration_form_id_forms FOREIGN KEY (registration_form_id) REFERENCES event_registration.forms(id);


--
-- Name: attachment_principals fk_attachment_principals_user_id_users; Type: FK CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.attachment_principals
    ADD CONSTRAINT fk_attachment_principals_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: attachments fk_attachments_file_id_files; Type: FK CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.attachments
    ADD CONSTRAINT fk_attachments_file_id_files FOREIGN KEY (file_id) REFERENCES attachments.files(id);


--
-- Name: attachments fk_attachments_folder_id_folders; Type: FK CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.attachments
    ADD CONSTRAINT fk_attachments_folder_id_folders FOREIGN KEY (folder_id) REFERENCES attachments.folders(id);


--
-- Name: attachments fk_attachments_user_id_users; Type: FK CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.attachments
    ADD CONSTRAINT fk_attachments_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: files fk_files_attachment_id_attachments; Type: FK CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.files
    ADD CONSTRAINT fk_files_attachment_id_attachments FOREIGN KEY (attachment_id) REFERENCES attachments.attachments(id);


--
-- Name: files fk_files_user_id_users; Type: FK CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.files
    ADD CONSTRAINT fk_files_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: folder_principals fk_folder_principals_category_role_id_roles; Type: FK CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.folder_principals
    ADD CONSTRAINT fk_folder_principals_category_role_id_roles FOREIGN KEY (category_role_id) REFERENCES categories.roles(id);


--
-- Name: folder_principals fk_folder_principals_event_role_id_roles; Type: FK CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.folder_principals
    ADD CONSTRAINT fk_folder_principals_event_role_id_roles FOREIGN KEY (event_role_id) REFERENCES events.roles(id);


--
-- Name: folder_principals fk_folder_principals_folder_id_folders; Type: FK CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.folder_principals
    ADD CONSTRAINT fk_folder_principals_folder_id_folders FOREIGN KEY (folder_id) REFERENCES attachments.folders(id);


--
-- Name: folder_principals fk_folder_principals_local_group_id_groups; Type: FK CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.folder_principals
    ADD CONSTRAINT fk_folder_principals_local_group_id_groups FOREIGN KEY (local_group_id) REFERENCES users.groups(id);


--
-- Name: folder_principals fk_folder_principals_registration_form_id_forms; Type: FK CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.folder_principals
    ADD CONSTRAINT fk_folder_principals_registration_form_id_forms FOREIGN KEY (registration_form_id) REFERENCES event_registration.forms(id);


--
-- Name: folder_principals fk_folder_principals_user_id_users; Type: FK CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.folder_principals
    ADD CONSTRAINT fk_folder_principals_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: folders fk_folders_category_id_categories; Type: FK CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.folders
    ADD CONSTRAINT fk_folders_category_id_categories FOREIGN KEY (category_id) REFERENCES categories.categories(id);


--
-- Name: folders fk_folders_contribution_id_contributions; Type: FK CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.folders
    ADD CONSTRAINT fk_folders_contribution_id_contributions FOREIGN KEY (contribution_id) REFERENCES events.contributions(id);


--
-- Name: folders fk_folders_event_id_events; Type: FK CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.folders
    ADD CONSTRAINT fk_folders_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: folders fk_folders_linked_event_id_events; Type: FK CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.folders
    ADD CONSTRAINT fk_folders_linked_event_id_events FOREIGN KEY (linked_event_id) REFERENCES events.events(id);


--
-- Name: folders fk_folders_session_id_sessions; Type: FK CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.folders
    ADD CONSTRAINT fk_folders_session_id_sessions FOREIGN KEY (session_id) REFERENCES events.sessions(id);


--
-- Name: folders fk_folders_subcontribution_id_subcontributions; Type: FK CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.folders
    ADD CONSTRAINT fk_folders_subcontribution_id_subcontributions FOREIGN KEY (subcontribution_id) REFERENCES events.subcontributions(id);


--
-- Name: legacy_attachment_id_map fk_legacy_attachment_id_map_attachment_id_attachments; Type: FK CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.legacy_attachment_id_map
    ADD CONSTRAINT fk_legacy_attachment_id_map_attachment_id_attachments FOREIGN KEY (attachment_id) REFERENCES attachments.attachments(id);


--
-- Name: legacy_attachment_id_map fk_legacy_attachment_id_map_event_id_events; Type: FK CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.legacy_attachment_id_map
    ADD CONSTRAINT fk_legacy_attachment_id_map_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: legacy_folder_id_map fk_legacy_folder_id_map_event_id_events; Type: FK CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.legacy_folder_id_map
    ADD CONSTRAINT fk_legacy_folder_id_map_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: legacy_folder_id_map fk_legacy_folder_id_map_folder_id_folders; Type: FK CONSTRAINT; Schema: attachments; Owner: indico
--

ALTER TABLE ONLY attachments.legacy_folder_id_map
    ADD CONSTRAINT fk_legacy_folder_id_map_folder_id_folders FOREIGN KEY (folder_id) REFERENCES attachments.folders(id);


--
-- Name: categories fk_categories_default_badge_template_id_designer_templates; Type: FK CONSTRAINT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.categories
    ADD CONSTRAINT fk_categories_default_badge_template_id_designer_templates FOREIGN KEY (default_badge_template_id) REFERENCES indico.designer_templates(id);


--
-- Name: categories fk_categories_default_ticket_template_id_designer_templates; Type: FK CONSTRAINT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.categories
    ADD CONSTRAINT fk_categories_default_ticket_template_id_designer_templates FOREIGN KEY (default_ticket_template_id) REFERENCES indico.designer_templates(id);


--
-- Name: categories fk_categories_parent_id_categories; Type: FK CONSTRAINT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.categories
    ADD CONSTRAINT fk_categories_parent_id_categories FOREIGN KEY (parent_id) REFERENCES categories.categories(id);


--
-- Name: event_move_requests fk_event_move_requests_category_id_categories; Type: FK CONSTRAINT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.event_move_requests
    ADD CONSTRAINT fk_event_move_requests_category_id_categories FOREIGN KEY (category_id) REFERENCES categories.categories(id);


--
-- Name: event_move_requests fk_event_move_requests_event_id_events; Type: FK CONSTRAINT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.event_move_requests
    ADD CONSTRAINT fk_event_move_requests_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: event_move_requests fk_event_move_requests_moderator_id_users; Type: FK CONSTRAINT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.event_move_requests
    ADD CONSTRAINT fk_event_move_requests_moderator_id_users FOREIGN KEY (moderator_id) REFERENCES users.users(id);


--
-- Name: event_move_requests fk_event_move_requests_requestor_id_users; Type: FK CONSTRAINT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.event_move_requests
    ADD CONSTRAINT fk_event_move_requests_requestor_id_users FOREIGN KEY (requestor_id) REFERENCES users.users(id);


--
-- Name: legacy_id_map fk_legacy_id_map_category_id_categories; Type: FK CONSTRAINT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.legacy_id_map
    ADD CONSTRAINT fk_legacy_id_map_category_id_categories FOREIGN KEY (category_id) REFERENCES categories.categories(id);


--
-- Name: logs fk_logs_category_id_categories; Type: FK CONSTRAINT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.logs
    ADD CONSTRAINT fk_logs_category_id_categories FOREIGN KEY (category_id) REFERENCES categories.categories(id);


--
-- Name: logs fk_logs_user_id_users; Type: FK CONSTRAINT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.logs
    ADD CONSTRAINT fk_logs_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: principals fk_principals_category_id_categories; Type: FK CONSTRAINT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.principals
    ADD CONSTRAINT fk_principals_category_id_categories FOREIGN KEY (category_id) REFERENCES categories.categories(id);


--
-- Name: principals fk_principals_category_role_id_roles; Type: FK CONSTRAINT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.principals
    ADD CONSTRAINT fk_principals_category_role_id_roles FOREIGN KEY (category_role_id) REFERENCES categories.roles(id);


--
-- Name: principals fk_principals_ip_network_group_id_ip_network_groups; Type: FK CONSTRAINT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.principals
    ADD CONSTRAINT fk_principals_ip_network_group_id_ip_network_groups FOREIGN KEY (ip_network_group_id) REFERENCES indico.ip_network_groups(id);


--
-- Name: principals fk_principals_local_group_id_groups; Type: FK CONSTRAINT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.principals
    ADD CONSTRAINT fk_principals_local_group_id_groups FOREIGN KEY (local_group_id) REFERENCES users.groups(id);


--
-- Name: principals fk_principals_user_id_users; Type: FK CONSTRAINT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.principals
    ADD CONSTRAINT fk_principals_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: role_members fk_role_members_role_id_roles; Type: FK CONSTRAINT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.role_members
    ADD CONSTRAINT fk_role_members_role_id_roles FOREIGN KEY (role_id) REFERENCES categories.roles(id);


--
-- Name: role_members fk_role_members_user_id_users; Type: FK CONSTRAINT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.role_members
    ADD CONSTRAINT fk_role_members_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: roles fk_roles_category_id_categories; Type: FK CONSTRAINT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.roles
    ADD CONSTRAINT fk_roles_category_id_categories FOREIGN KEY (category_id) REFERENCES categories.categories(id);


--
-- Name: settings fk_settings_category_id_categories; Type: FK CONSTRAINT; Schema: categories; Owner: indico
--

ALTER TABLE ONLY categories.settings
    ADD CONSTRAINT fk_settings_category_id_categories FOREIGN KEY (category_id) REFERENCES categories.categories(id);


--
-- Name: abstract_comments fk_abstract_comments_abstract_id_abstracts; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_comments
    ADD CONSTRAINT fk_abstract_comments_abstract_id_abstracts FOREIGN KEY (abstract_id) REFERENCES event_abstracts.abstracts(id);


--
-- Name: abstract_comments fk_abstract_comments_modified_by_id_users; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_comments
    ADD CONSTRAINT fk_abstract_comments_modified_by_id_users FOREIGN KEY (modified_by_id) REFERENCES users.users(id);


--
-- Name: abstract_comments fk_abstract_comments_user_id_users; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_comments
    ADD CONSTRAINT fk_abstract_comments_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: abstract_field_values fk_abstract_field_values_abstract_id_abstracts; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_field_values
    ADD CONSTRAINT fk_abstract_field_values_abstract_id_abstracts FOREIGN KEY (abstract_id) REFERENCES event_abstracts.abstracts(id);


--
-- Name: abstract_field_values fk_abstract_field_values_contribution_field; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_field_values
    ADD CONSTRAINT fk_abstract_field_values_contribution_field FOREIGN KEY (contribution_field_id) REFERENCES events.contribution_fields(id);


--
-- Name: abstract_person_links fk_abstract_person_links_abstract_id_abstracts; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_person_links
    ADD CONSTRAINT fk_abstract_person_links_abstract_id_abstracts FOREIGN KEY (abstract_id) REFERENCES event_abstracts.abstracts(id);


--
-- Name: abstract_person_links fk_abstract_person_links_affiliation_id_affiliations; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_person_links
    ADD CONSTRAINT fk_abstract_person_links_affiliation_id_affiliations FOREIGN KEY (affiliation_id) REFERENCES indico.affiliations(id);


--
-- Name: abstract_person_links fk_abstract_person_links_person_id_persons; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_person_links
    ADD CONSTRAINT fk_abstract_person_links_person_id_persons FOREIGN KEY (person_id) REFERENCES events.persons(id);


--
-- Name: abstract_review_questions fk_abstract_review_questions_event_id_events; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_review_questions
    ADD CONSTRAINT fk_abstract_review_questions_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: abstract_review_ratings fk_abstract_review_ratings_question_id_abstract_review__aa27; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_review_ratings
    ADD CONSTRAINT fk_abstract_review_ratings_question_id_abstract_review__aa27 FOREIGN KEY (question_id) REFERENCES event_abstracts.abstract_review_questions(id);


--
-- Name: abstract_review_ratings fk_abstract_review_ratings_review_id_abstract_reviews; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_review_ratings
    ADD CONSTRAINT fk_abstract_review_ratings_review_id_abstract_reviews FOREIGN KEY (review_id) REFERENCES event_abstracts.abstract_reviews(id);


--
-- Name: abstract_reviews fk_abstract_reviews_abstract_id_abstracts; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_reviews
    ADD CONSTRAINT fk_abstract_reviews_abstract_id_abstracts FOREIGN KEY (abstract_id) REFERENCES event_abstracts.abstracts(id);


--
-- Name: abstract_reviews fk_abstract_reviews_proposed_contribution_type_id_contr_6290; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_reviews
    ADD CONSTRAINT fk_abstract_reviews_proposed_contribution_type_id_contr_6290 FOREIGN KEY (proposed_contribution_type_id) REFERENCES events.contribution_types(id);


--
-- Name: abstract_reviews fk_abstract_reviews_proposed_related_abstract_id_abstracts; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_reviews
    ADD CONSTRAINT fk_abstract_reviews_proposed_related_abstract_id_abstracts FOREIGN KEY (proposed_related_abstract_id) REFERENCES event_abstracts.abstracts(id);


--
-- Name: abstract_reviews fk_abstract_reviews_track_id_tracks; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_reviews
    ADD CONSTRAINT fk_abstract_reviews_track_id_tracks FOREIGN KEY (track_id) REFERENCES events.tracks(id);


--
-- Name: abstract_reviews fk_abstract_reviews_user_id_users; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstract_reviews
    ADD CONSTRAINT fk_abstract_reviews_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: abstracts fk_abstracts_accepted_contrib_type_id_contribution_types; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstracts
    ADD CONSTRAINT fk_abstracts_accepted_contrib_type_id_contribution_types FOREIGN KEY (accepted_contrib_type_id) REFERENCES events.contribution_types(id) ON DELETE SET NULL;


--
-- Name: abstracts fk_abstracts_accepted_track_id_tracks; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstracts
    ADD CONSTRAINT fk_abstracts_accepted_track_id_tracks FOREIGN KEY (accepted_track_id) REFERENCES events.tracks(id) ON DELETE SET NULL;


--
-- Name: abstracts fk_abstracts_duplicate_of_id_abstracts; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstracts
    ADD CONSTRAINT fk_abstracts_duplicate_of_id_abstracts FOREIGN KEY (duplicate_of_id) REFERENCES event_abstracts.abstracts(id);


--
-- Name: abstracts fk_abstracts_event_id_events; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstracts
    ADD CONSTRAINT fk_abstracts_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: abstracts fk_abstracts_judge_id_users; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstracts
    ADD CONSTRAINT fk_abstracts_judge_id_users FOREIGN KEY (judge_id) REFERENCES users.users(id);


--
-- Name: abstracts fk_abstracts_merged_into_id_abstracts; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstracts
    ADD CONSTRAINT fk_abstracts_merged_into_id_abstracts FOREIGN KEY (merged_into_id) REFERENCES event_abstracts.abstracts(id);


--
-- Name: abstracts fk_abstracts_modified_by_id_users; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstracts
    ADD CONSTRAINT fk_abstracts_modified_by_id_users FOREIGN KEY (modified_by_id) REFERENCES users.users(id);


--
-- Name: abstracts fk_abstracts_submitted_contrib_type_id_contribution_types; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstracts
    ADD CONSTRAINT fk_abstracts_submitted_contrib_type_id_contribution_types FOREIGN KEY (submitted_contrib_type_id) REFERENCES events.contribution_types(id) ON DELETE SET NULL;


--
-- Name: abstracts fk_abstracts_submitter_id_users; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.abstracts
    ADD CONSTRAINT fk_abstracts_submitter_id_users FOREIGN KEY (submitter_id) REFERENCES users.users(id);


--
-- Name: email_logs fk_email_logs_abstract_id_abstracts; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.email_logs
    ADD CONSTRAINT fk_email_logs_abstract_id_abstracts FOREIGN KEY (abstract_id) REFERENCES event_abstracts.abstracts(id);


--
-- Name: email_logs fk_email_logs_email_template_id_email_templates; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.email_logs
    ADD CONSTRAINT fk_email_logs_email_template_id_email_templates FOREIGN KEY (email_template_id) REFERENCES event_abstracts.email_templates(id);


--
-- Name: email_logs fk_email_logs_user_id_users; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.email_logs
    ADD CONSTRAINT fk_email_logs_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: email_templates fk_email_templates_event_id_events; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.email_templates
    ADD CONSTRAINT fk_email_templates_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: files fk_files_abstract_id_abstracts; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.files
    ADD CONSTRAINT fk_files_abstract_id_abstracts FOREIGN KEY (abstract_id) REFERENCES event_abstracts.abstracts(id);


--
-- Name: proposed_for_tracks fk_proposed_for_tracks_review_id_abstract_reviews; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.proposed_for_tracks
    ADD CONSTRAINT fk_proposed_for_tracks_review_id_abstract_reviews FOREIGN KEY (review_id) REFERENCES event_abstracts.abstract_reviews(id);


--
-- Name: proposed_for_tracks fk_proposed_for_tracks_track_id_tracks; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.proposed_for_tracks
    ADD CONSTRAINT fk_proposed_for_tracks_track_id_tracks FOREIGN KEY (track_id) REFERENCES events.tracks(id) ON DELETE CASCADE;


--
-- Name: reviewed_for_tracks fk_reviewed_for_tracks_abstract_id_abstracts; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.reviewed_for_tracks
    ADD CONSTRAINT fk_reviewed_for_tracks_abstract_id_abstracts FOREIGN KEY (abstract_id) REFERENCES event_abstracts.abstracts(id);


--
-- Name: reviewed_for_tracks fk_reviewed_for_tracks_track_id_tracks; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.reviewed_for_tracks
    ADD CONSTRAINT fk_reviewed_for_tracks_track_id_tracks FOREIGN KEY (track_id) REFERENCES events.tracks(id) ON DELETE CASCADE;


--
-- Name: submitted_for_tracks fk_submitted_for_tracks_abstract_id_abstracts; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.submitted_for_tracks
    ADD CONSTRAINT fk_submitted_for_tracks_abstract_id_abstracts FOREIGN KEY (abstract_id) REFERENCES event_abstracts.abstracts(id);


--
-- Name: submitted_for_tracks fk_submitted_for_tracks_track_id_tracks; Type: FK CONSTRAINT; Schema: event_abstracts; Owner: indico
--

ALTER TABLE ONLY event_abstracts.submitted_for_tracks
    ADD CONSTRAINT fk_submitted_for_tracks_track_id_tracks FOREIGN KEY (track_id) REFERENCES events.tracks(id) ON DELETE CASCADE;


--
-- Name: comments fk_comments_revision_id_revisions; Type: FK CONSTRAINT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.comments
    ADD CONSTRAINT fk_comments_revision_id_revisions FOREIGN KEY (revision_id) REFERENCES event_editing.revisions(id) ON DELETE CASCADE;


--
-- Name: comments fk_comments_user_id_users; Type: FK CONSTRAINT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.comments
    ADD CONSTRAINT fk_comments_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: editables fk_editables_contribution_id_contributions; Type: FK CONSTRAINT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.editables
    ADD CONSTRAINT fk_editables_contribution_id_contributions FOREIGN KEY (contribution_id) REFERENCES events.contributions(id);


--
-- Name: editables fk_editables_editor_id_users; Type: FK CONSTRAINT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.editables
    ADD CONSTRAINT fk_editables_editor_id_users FOREIGN KEY (editor_id) REFERENCES users.users(id);


--
-- Name: editables fk_editables_published_revision_id_revisions; Type: FK CONSTRAINT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.editables
    ADD CONSTRAINT fk_editables_published_revision_id_revisions FOREIGN KEY (published_revision_id) REFERENCES event_editing.revisions(id);


--
-- Name: file_types fk_file_types_event_id_events; Type: FK CONSTRAINT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.file_types
    ADD CONSTRAINT fk_file_types_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: review_condition_file_types fk_review_condition_file_types_file_type_id_file_types; Type: FK CONSTRAINT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.review_condition_file_types
    ADD CONSTRAINT fk_review_condition_file_types_file_type_id_file_types FOREIGN KEY (file_type_id) REFERENCES event_editing.file_types(id);


--
-- Name: review_condition_file_types fk_review_condition_file_types_review_condition_id_revi_175a; Type: FK CONSTRAINT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.review_condition_file_types
    ADD CONSTRAINT fk_review_condition_file_types_review_condition_id_revi_175a FOREIGN KEY (review_condition_id) REFERENCES event_editing.review_conditions(id);


--
-- Name: review_conditions fk_review_conditions_event_id_events; Type: FK CONSTRAINT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.review_conditions
    ADD CONSTRAINT fk_review_conditions_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: revision_files fk_revision_files_file_id_files; Type: FK CONSTRAINT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.revision_files
    ADD CONSTRAINT fk_revision_files_file_id_files FOREIGN KEY (file_id) REFERENCES indico.files(id);


--
-- Name: revision_files fk_revision_files_file_type_id_file_types; Type: FK CONSTRAINT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.revision_files
    ADD CONSTRAINT fk_revision_files_file_type_id_file_types FOREIGN KEY (file_type_id) REFERENCES event_editing.file_types(id);


--
-- Name: revision_files fk_revision_files_revision_id_revisions; Type: FK CONSTRAINT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.revision_files
    ADD CONSTRAINT fk_revision_files_revision_id_revisions FOREIGN KEY (revision_id) REFERENCES event_editing.revisions(id);


--
-- Name: revision_tags fk_revision_tags_revision_id_revisions; Type: FK CONSTRAINT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.revision_tags
    ADD CONSTRAINT fk_revision_tags_revision_id_revisions FOREIGN KEY (revision_id) REFERENCES event_editing.revisions(id);


--
-- Name: revision_tags fk_revision_tags_tag_id_tags; Type: FK CONSTRAINT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.revision_tags
    ADD CONSTRAINT fk_revision_tags_tag_id_tags FOREIGN KEY (tag_id) REFERENCES event_editing.tags(id);


--
-- Name: revisions fk_revisions_editable_id_editables; Type: FK CONSTRAINT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.revisions
    ADD CONSTRAINT fk_revisions_editable_id_editables FOREIGN KEY (editable_id) REFERENCES event_editing.editables(id);


--
-- Name: revisions fk_revisions_user_id_users; Type: FK CONSTRAINT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.revisions
    ADD CONSTRAINT fk_revisions_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: tags fk_tags_event_id_events; Type: FK CONSTRAINT; Schema: event_editing; Owner: indico
--

ALTER TABLE ONLY event_editing.tags
    ADD CONSTRAINT fk_tags_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: competences fk_competences_event_id_events; Type: FK CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.competences
    ADD CONSTRAINT fk_competences_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: competences fk_competences_user_id_users; Type: FK CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.competences
    ADD CONSTRAINT fk_competences_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: content_reviewers fk_content_reviewers_contribution_id_contributions; Type: FK CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.content_reviewers
    ADD CONSTRAINT fk_content_reviewers_contribution_id_contributions FOREIGN KEY (contribution_id) REFERENCES events.contributions(id);


--
-- Name: content_reviewers fk_content_reviewers_user_id_users; Type: FK CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.content_reviewers
    ADD CONSTRAINT fk_content_reviewers_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: files fk_files_contribution_id_contributions; Type: FK CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.files
    ADD CONSTRAINT fk_files_contribution_id_contributions FOREIGN KEY (contribution_id) REFERENCES events.contributions(id);


--
-- Name: files fk_files_revision_id_revisions; Type: FK CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.files
    ADD CONSTRAINT fk_files_revision_id_revisions FOREIGN KEY (revision_id) REFERENCES event_paper_reviewing.revisions(id);


--
-- Name: judges fk_judges_contribution_id_contributions; Type: FK CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.judges
    ADD CONSTRAINT fk_judges_contribution_id_contributions FOREIGN KEY (contribution_id) REFERENCES events.contributions(id);


--
-- Name: judges fk_judges_user_id_users; Type: FK CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.judges
    ADD CONSTRAINT fk_judges_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: layout_reviewers fk_layout_reviewers_contribution_id_contributions; Type: FK CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.layout_reviewers
    ADD CONSTRAINT fk_layout_reviewers_contribution_id_contributions FOREIGN KEY (contribution_id) REFERENCES events.contributions(id);


--
-- Name: layout_reviewers fk_layout_reviewers_user_id_users; Type: FK CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.layout_reviewers
    ADD CONSTRAINT fk_layout_reviewers_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: review_comments fk_review_comments_modified_by_id_users; Type: FK CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.review_comments
    ADD CONSTRAINT fk_review_comments_modified_by_id_users FOREIGN KEY (modified_by_id) REFERENCES users.users(id);


--
-- Name: review_comments fk_review_comments_revision_id_revisions; Type: FK CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.review_comments
    ADD CONSTRAINT fk_review_comments_revision_id_revisions FOREIGN KEY (revision_id) REFERENCES event_paper_reviewing.revisions(id);


--
-- Name: review_comments fk_review_comments_user_id_users; Type: FK CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.review_comments
    ADD CONSTRAINT fk_review_comments_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: review_questions fk_review_questions_event_id_events; Type: FK CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.review_questions
    ADD CONSTRAINT fk_review_questions_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: review_ratings fk_review_ratings_question_id_review_questions; Type: FK CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.review_ratings
    ADD CONSTRAINT fk_review_ratings_question_id_review_questions FOREIGN KEY (question_id) REFERENCES event_paper_reviewing.review_questions(id);


--
-- Name: review_ratings fk_review_ratings_review_id_reviews; Type: FK CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.review_ratings
    ADD CONSTRAINT fk_review_ratings_review_id_reviews FOREIGN KEY (review_id) REFERENCES event_paper_reviewing.reviews(id);


--
-- Name: reviews fk_reviews_revision_id_revisions; Type: FK CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.reviews
    ADD CONSTRAINT fk_reviews_revision_id_revisions FOREIGN KEY (revision_id) REFERENCES event_paper_reviewing.revisions(id);


--
-- Name: reviews fk_reviews_user_id_users; Type: FK CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.reviews
    ADD CONSTRAINT fk_reviews_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: revisions fk_revisions_contribution_id_contributions; Type: FK CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.revisions
    ADD CONSTRAINT fk_revisions_contribution_id_contributions FOREIGN KEY (contribution_id) REFERENCES events.contributions(id);


--
-- Name: revisions fk_revisions_judge_id_users; Type: FK CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.revisions
    ADD CONSTRAINT fk_revisions_judge_id_users FOREIGN KEY (judge_id) REFERENCES users.users(id);


--
-- Name: revisions fk_revisions_submitter_id_users; Type: FK CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.revisions
    ADD CONSTRAINT fk_revisions_submitter_id_users FOREIGN KEY (submitter_id) REFERENCES users.users(id);


--
-- Name: templates fk_templates_event_id_events; Type: FK CONSTRAINT; Schema: event_paper_reviewing; Owner: indico
--

ALTER TABLE ONLY event_paper_reviewing.templates
    ADD CONSTRAINT fk_templates_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: form_field_data fk_form_field_data_field_id_form_items; Type: FK CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.form_field_data
    ADD CONSTRAINT fk_form_field_data_field_id_form_items FOREIGN KEY (field_id) REFERENCES event_registration.form_items(id);


--
-- Name: form_items fk_form_items_current_data_id_form_field_data; Type: FK CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.form_items
    ADD CONSTRAINT fk_form_items_current_data_id_form_field_data FOREIGN KEY (current_data_id) REFERENCES event_registration.form_field_data(id);


--
-- Name: form_items fk_form_items_parent_id_form_items; Type: FK CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.form_items
    ADD CONSTRAINT fk_form_items_parent_id_form_items FOREIGN KEY (parent_id) REFERENCES event_registration.form_items(id);


--
-- Name: form_items fk_form_items_registration_form_id_forms; Type: FK CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.form_items
    ADD CONSTRAINT fk_form_items_registration_form_id_forms FOREIGN KEY (registration_form_id) REFERENCES event_registration.forms(id);


--
-- Name: forms fk_forms_event_id_events; Type: FK CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.forms
    ADD CONSTRAINT fk_forms_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: forms fk_forms_ticket_template_id_designer_templates; Type: FK CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.forms
    ADD CONSTRAINT fk_forms_ticket_template_id_designer_templates FOREIGN KEY (ticket_template_id) REFERENCES indico.designer_templates(id);


--
-- Name: invitations fk_invitations_registration_form_id_forms; Type: FK CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.invitations
    ADD CONSTRAINT fk_invitations_registration_form_id_forms FOREIGN KEY (registration_form_id) REFERENCES event_registration.forms(id);


--
-- Name: invitations fk_invitations_registration_id_registrations; Type: FK CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.invitations
    ADD CONSTRAINT fk_invitations_registration_id_registrations FOREIGN KEY (registration_id) REFERENCES event_registration.registrations(id);


--
-- Name: legacy_registration_map fk_legacy_registration_map_event_id_events; Type: FK CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.legacy_registration_map
    ADD CONSTRAINT fk_legacy_registration_map_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: legacy_registration_map fk_legacy_registration_map_registration_id_registrations; Type: FK CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.legacy_registration_map
    ADD CONSTRAINT fk_legacy_registration_map_registration_id_registrations FOREIGN KEY (registration_id) REFERENCES event_registration.registrations(id);


--
-- Name: receipt_files fk_receipt_files_file_id_files; Type: FK CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.receipt_files
    ADD CONSTRAINT fk_receipt_files_file_id_files FOREIGN KEY (file_id) REFERENCES indico.files(id);


--
-- Name: receipt_files fk_receipt_files_registration_id_registrations; Type: FK CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.receipt_files
    ADD CONSTRAINT fk_receipt_files_registration_id_registrations FOREIGN KEY (registration_id) REFERENCES event_registration.registrations(id) ON DELETE CASCADE;


--
-- Name: receipt_files fk_receipt_files_template_id_receipt_templates; Type: FK CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.receipt_files
    ADD CONSTRAINT fk_receipt_files_template_id_receipt_templates FOREIGN KEY (template_id) REFERENCES indico.receipt_templates(id);


--
-- Name: registration_data fk_registration_data_field_data_id_form_field_data; Type: FK CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.registration_data
    ADD CONSTRAINT fk_registration_data_field_data_id_form_field_data FOREIGN KEY (field_data_id) REFERENCES event_registration.form_field_data(id);


--
-- Name: registration_data fk_registration_data_registration_id_registrations; Type: FK CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.registration_data
    ADD CONSTRAINT fk_registration_data_registration_id_registrations FOREIGN KEY (registration_id) REFERENCES event_registration.registrations(id);


--
-- Name: registration_tags fk_registration_tags_registration_id_registrations; Type: FK CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.registration_tags
    ADD CONSTRAINT fk_registration_tags_registration_id_registrations FOREIGN KEY (registration_id) REFERENCES event_registration.registrations(id) ON DELETE CASCADE;


--
-- Name: registration_tags fk_registration_tags_registration_tag_id_tags; Type: FK CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.registration_tags
    ADD CONSTRAINT fk_registration_tags_registration_tag_id_tags FOREIGN KEY (registration_tag_id) REFERENCES event_registration.tags(id) ON DELETE CASCADE;


--
-- Name: registrations fk_registrations_event_id_events; Type: FK CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.registrations
    ADD CONSTRAINT fk_registrations_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: registrations fk_registrations_event_id_registration_form_id_forms; Type: FK CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.registrations
    ADD CONSTRAINT fk_registrations_event_id_registration_form_id_forms FOREIGN KEY (event_id, registration_form_id) REFERENCES event_registration.forms(event_id, id);


--
-- Name: registrations fk_registrations_registration_form_id_forms; Type: FK CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.registrations
    ADD CONSTRAINT fk_registrations_registration_form_id_forms FOREIGN KEY (registration_form_id) REFERENCES event_registration.forms(id);


--
-- Name: registrations fk_registrations_transaction_id_payment_transactions; Type: FK CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.registrations
    ADD CONSTRAINT fk_registrations_transaction_id_payment_transactions FOREIGN KEY (transaction_id) REFERENCES events.payment_transactions(id);


--
-- Name: registrations fk_registrations_user_id_users; Type: FK CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.registrations
    ADD CONSTRAINT fk_registrations_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: tags fk_tags_event_id_events; Type: FK CONSTRAINT; Schema: event_registration; Owner: indico
--

ALTER TABLE ONLY event_registration.tags
    ADD CONSTRAINT fk_tags_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: anonymous_submissions fk_anonymous_submissions_survey_id_surveys; Type: FK CONSTRAINT; Schema: event_surveys; Owner: indico
--

ALTER TABLE ONLY event_surveys.anonymous_submissions
    ADD CONSTRAINT fk_anonymous_submissions_survey_id_surveys FOREIGN KEY (survey_id) REFERENCES event_surveys.surveys(id) ON DELETE CASCADE;


--
-- Name: anonymous_submissions fk_anonymous_submissions_user_id_users; Type: FK CONSTRAINT; Schema: event_surveys; Owner: indico
--

ALTER TABLE ONLY event_surveys.anonymous_submissions
    ADD CONSTRAINT fk_anonymous_submissions_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id) ON DELETE CASCADE;


--
-- Name: answers fk_answers_question_id_items; Type: FK CONSTRAINT; Schema: event_surveys; Owner: indico
--

ALTER TABLE ONLY event_surveys.answers
    ADD CONSTRAINT fk_answers_question_id_items FOREIGN KEY (question_id) REFERENCES event_surveys.items(id);


--
-- Name: answers fk_answers_submission_id_submissions; Type: FK CONSTRAINT; Schema: event_surveys; Owner: indico
--

ALTER TABLE ONLY event_surveys.answers
    ADD CONSTRAINT fk_answers_submission_id_submissions FOREIGN KEY (submission_id) REFERENCES event_surveys.submissions(id);


--
-- Name: items fk_items_parent_id_items; Type: FK CONSTRAINT; Schema: event_surveys; Owner: indico
--

ALTER TABLE ONLY event_surveys.items
    ADD CONSTRAINT fk_items_parent_id_items FOREIGN KEY (parent_id) REFERENCES event_surveys.items(id);


--
-- Name: items fk_items_survey_id_surveys; Type: FK CONSTRAINT; Schema: event_surveys; Owner: indico
--

ALTER TABLE ONLY event_surveys.items
    ADD CONSTRAINT fk_items_survey_id_surveys FOREIGN KEY (survey_id) REFERENCES event_surveys.surveys(id);


--
-- Name: submissions fk_submissions_survey_id_surveys; Type: FK CONSTRAINT; Schema: event_surveys; Owner: indico
--

ALTER TABLE ONLY event_surveys.submissions
    ADD CONSTRAINT fk_submissions_survey_id_surveys FOREIGN KEY (survey_id) REFERENCES event_surveys.surveys(id);


--
-- Name: submissions fk_submissions_user_id_users; Type: FK CONSTRAINT; Schema: event_surveys; Owner: indico
--

ALTER TABLE ONLY event_surveys.submissions
    ADD CONSTRAINT fk_submissions_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: surveys fk_surveys_event_id_events; Type: FK CONSTRAINT; Schema: event_surveys; Owner: indico
--

ALTER TABLE ONLY event_surveys.surveys
    ADD CONSTRAINT fk_surveys_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: agreements fk_agreements_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.agreements
    ADD CONSTRAINT fk_agreements_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: agreements fk_agreements_user_id_users; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.agreements
    ADD CONSTRAINT fk_agreements_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: breaks fk_breaks_room_id_rooms; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.breaks
    ADD CONSTRAINT fk_breaks_room_id_rooms FOREIGN KEY (room_id) REFERENCES roombooking.rooms(id);


--
-- Name: breaks fk_breaks_venue_id_locations; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.breaks
    ADD CONSTRAINT fk_breaks_venue_id_locations FOREIGN KEY (venue_id) REFERENCES roombooking.locations(id);


--
-- Name: breaks fk_breaks_venue_id_room_id_rooms; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.breaks
    ADD CONSTRAINT fk_breaks_venue_id_room_id_rooms FOREIGN KEY (venue_id, room_id) REFERENCES roombooking.rooms(location_id, id);


--
-- Name: contribution_field_values fk_contribution_field_values_contribution_field; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contribution_field_values
    ADD CONSTRAINT fk_contribution_field_values_contribution_field FOREIGN KEY (contribution_field_id) REFERENCES events.contribution_fields(id);


--
-- Name: contribution_field_values fk_contribution_field_values_contribution_id_contributions; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contribution_field_values
    ADD CONSTRAINT fk_contribution_field_values_contribution_id_contributions FOREIGN KEY (contribution_id) REFERENCES events.contributions(id);


--
-- Name: contribution_fields fk_contribution_fields_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contribution_fields
    ADD CONSTRAINT fk_contribution_fields_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: contribution_person_links fk_contribution_person_links_affiliation_id_affiliations; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contribution_person_links
    ADD CONSTRAINT fk_contribution_person_links_affiliation_id_affiliations FOREIGN KEY (affiliation_id) REFERENCES indico.affiliations(id);


--
-- Name: contribution_person_links fk_contribution_person_links_contribution_id_contributions; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contribution_person_links
    ADD CONSTRAINT fk_contribution_person_links_contribution_id_contributions FOREIGN KEY (contribution_id) REFERENCES events.contributions(id);


--
-- Name: contribution_person_links fk_contribution_person_links_person_id_persons; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contribution_person_links
    ADD CONSTRAINT fk_contribution_person_links_person_id_persons FOREIGN KEY (person_id) REFERENCES events.persons(id);


--
-- Name: contribution_principals fk_contribution_principals_category_role_id_roles; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contribution_principals
    ADD CONSTRAINT fk_contribution_principals_category_role_id_roles FOREIGN KEY (category_role_id) REFERENCES categories.roles(id);


--
-- Name: contribution_principals fk_contribution_principals_contribution_id_contributions; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contribution_principals
    ADD CONSTRAINT fk_contribution_principals_contribution_id_contributions FOREIGN KEY (contribution_id) REFERENCES events.contributions(id);


--
-- Name: contribution_principals fk_contribution_principals_event_role_id_roles; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contribution_principals
    ADD CONSTRAINT fk_contribution_principals_event_role_id_roles FOREIGN KEY (event_role_id) REFERENCES events.roles(id);


--
-- Name: contribution_principals fk_contribution_principals_local_group_id_groups; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contribution_principals
    ADD CONSTRAINT fk_contribution_principals_local_group_id_groups FOREIGN KEY (local_group_id) REFERENCES users.groups(id);


--
-- Name: contribution_principals fk_contribution_principals_registration_form_id_forms; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contribution_principals
    ADD CONSTRAINT fk_contribution_principals_registration_form_id_forms FOREIGN KEY (registration_form_id) REFERENCES event_registration.forms(id);


--
-- Name: contribution_principals fk_contribution_principals_user_id_users; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contribution_principals
    ADD CONSTRAINT fk_contribution_principals_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: contribution_references fk_contribution_references_contribution_id_contributions; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contribution_references
    ADD CONSTRAINT fk_contribution_references_contribution_id_contributions FOREIGN KEY (contribution_id) REFERENCES events.contributions(id);


--
-- Name: contribution_references fk_contribution_references_reference_type_id_reference_types; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contribution_references
    ADD CONSTRAINT fk_contribution_references_reference_type_id_reference_types FOREIGN KEY (reference_type_id) REFERENCES indico.reference_types(id);


--
-- Name: contribution_types fk_contribution_types_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contribution_types
    ADD CONSTRAINT fk_contribution_types_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: contributions fk_contributions_abstract_id_abstracts; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contributions
    ADD CONSTRAINT fk_contributions_abstract_id_abstracts FOREIGN KEY (abstract_id) REFERENCES event_abstracts.abstracts(id);


--
-- Name: contributions fk_contributions_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contributions
    ADD CONSTRAINT fk_contributions_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: contributions fk_contributions_room_id_rooms; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contributions
    ADD CONSTRAINT fk_contributions_room_id_rooms FOREIGN KEY (room_id) REFERENCES roombooking.rooms(id);


--
-- Name: contributions fk_contributions_session_block_id_session_blocks; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contributions
    ADD CONSTRAINT fk_contributions_session_block_id_session_blocks FOREIGN KEY (session_block_id) REFERENCES events.session_blocks(id);


--
-- Name: contributions fk_contributions_session_block_id_session_id_session_blocks; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contributions
    ADD CONSTRAINT fk_contributions_session_block_id_session_id_session_blocks FOREIGN KEY (session_block_id, session_id) REFERENCES events.session_blocks(id, session_id);


--
-- Name: contributions fk_contributions_session_id_sessions; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contributions
    ADD CONSTRAINT fk_contributions_session_id_sessions FOREIGN KEY (session_id) REFERENCES events.sessions(id);


--
-- Name: contributions fk_contributions_track_id_tracks; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contributions
    ADD CONSTRAINT fk_contributions_track_id_tracks FOREIGN KEY (track_id) REFERENCES events.tracks(id) ON DELETE SET NULL;


--
-- Name: contributions fk_contributions_type_id_contribution_types; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contributions
    ADD CONSTRAINT fk_contributions_type_id_contribution_types FOREIGN KEY (type_id) REFERENCES events.contribution_types(id);


--
-- Name: contributions fk_contributions_venue_id_locations; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contributions
    ADD CONSTRAINT fk_contributions_venue_id_locations FOREIGN KEY (venue_id) REFERENCES roombooking.locations(id);


--
-- Name: contributions fk_contributions_venue_id_room_id_rooms; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.contributions
    ADD CONSTRAINT fk_contributions_venue_id_room_id_rooms FOREIGN KEY (venue_id, room_id) REFERENCES roombooking.rooms(location_id, id);


--
-- Name: event_person_links fk_event_person_links_affiliation_id_affiliations; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.event_person_links
    ADD CONSTRAINT fk_event_person_links_affiliation_id_affiliations FOREIGN KEY (affiliation_id) REFERENCES indico.affiliations(id);


--
-- Name: event_person_links fk_event_person_links_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.event_person_links
    ADD CONSTRAINT fk_event_person_links_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: event_person_links fk_event_person_links_person_id_persons; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.event_person_links
    ADD CONSTRAINT fk_event_person_links_person_id_persons FOREIGN KEY (person_id) REFERENCES events.persons(id);


--
-- Name: event_references fk_event_references_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.event_references
    ADD CONSTRAINT fk_event_references_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: event_references fk_event_references_reference_type_id_reference_types; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.event_references
    ADD CONSTRAINT fk_event_references_reference_type_id_reference_types FOREIGN KEY (reference_type_id) REFERENCES indico.reference_types(id);


--
-- Name: events fk_events_category_id_categories; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.events
    ADD CONSTRAINT fk_events_category_id_categories FOREIGN KEY (category_id) REFERENCES categories.categories(id);


--
-- Name: events fk_events_cloned_from_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.events
    ADD CONSTRAINT fk_events_cloned_from_id_events FOREIGN KEY (cloned_from_id) REFERENCES events.events(id);


--
-- Name: events fk_events_creator_id_users; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.events
    ADD CONSTRAINT fk_events_creator_id_users FOREIGN KEY (creator_id) REFERENCES users.users(id);


--
-- Name: events fk_events_custom_boa_id_files; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.events
    ADD CONSTRAINT fk_events_custom_boa_id_files FOREIGN KEY (custom_boa_id) REFERENCES indico.files(id);


--
-- Name: events fk_events_default_page_id_pages; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.events
    ADD CONSTRAINT fk_events_default_page_id_pages FOREIGN KEY (default_page_id) REFERENCES events.pages(id);


--
-- Name: events fk_events_label_id_labels; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.events
    ADD CONSTRAINT fk_events_label_id_labels FOREIGN KEY (label_id) REFERENCES events.labels(id);


--
-- Name: events fk_events_room_id_rooms; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.events
    ADD CONSTRAINT fk_events_room_id_rooms FOREIGN KEY (room_id) REFERENCES roombooking.rooms(id);


--
-- Name: events fk_events_series_id_series; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.events
    ADD CONSTRAINT fk_events_series_id_series FOREIGN KEY (series_id) REFERENCES events.series(id);


--
-- Name: events fk_events_venue_id_locations; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.events
    ADD CONSTRAINT fk_events_venue_id_locations FOREIGN KEY (venue_id) REFERENCES roombooking.locations(id);


--
-- Name: events fk_events_venue_id_room_id_rooms; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.events
    ADD CONSTRAINT fk_events_venue_id_room_id_rooms FOREIGN KEY (venue_id, room_id) REFERENCES roombooking.rooms(location_id, id);


--
-- Name: image_files fk_image_files_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.image_files
    ADD CONSTRAINT fk_image_files_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: legacy_contribution_id_map fk_legacy_contribution_id_map_contribution_id_contributions; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.legacy_contribution_id_map
    ADD CONSTRAINT fk_legacy_contribution_id_map_contribution_id_contributions FOREIGN KEY (contribution_id) REFERENCES events.contributions(id);


--
-- Name: legacy_contribution_id_map fk_legacy_contribution_id_map_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.legacy_contribution_id_map
    ADD CONSTRAINT fk_legacy_contribution_id_map_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: legacy_id_map fk_legacy_id_map_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.legacy_id_map
    ADD CONSTRAINT fk_legacy_id_map_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: legacy_image_id_map fk_legacy_image_id_map_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.legacy_image_id_map
    ADD CONSTRAINT fk_legacy_image_id_map_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: legacy_image_id_map fk_legacy_image_id_map_image_id_image_files; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.legacy_image_id_map
    ADD CONSTRAINT fk_legacy_image_id_map_image_id_image_files FOREIGN KEY (image_id) REFERENCES events.image_files(id);


--
-- Name: legacy_page_id_map fk_legacy_page_id_map_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.legacy_page_id_map
    ADD CONSTRAINT fk_legacy_page_id_map_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: legacy_page_id_map fk_legacy_page_id_map_page_id_pages; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.legacy_page_id_map
    ADD CONSTRAINT fk_legacy_page_id_map_page_id_pages FOREIGN KEY (page_id) REFERENCES events.pages(id);


--
-- Name: legacy_session_block_id_map fk_legacy_session_block_id_map_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.legacy_session_block_id_map
    ADD CONSTRAINT fk_legacy_session_block_id_map_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: legacy_session_block_id_map fk_legacy_session_block_id_map_session_block_id_session_blocks; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.legacy_session_block_id_map
    ADD CONSTRAINT fk_legacy_session_block_id_map_session_block_id_session_blocks FOREIGN KEY (session_block_id) REFERENCES events.session_blocks(id);


--
-- Name: legacy_session_id_map fk_legacy_session_id_map_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.legacy_session_id_map
    ADD CONSTRAINT fk_legacy_session_id_map_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: legacy_session_id_map fk_legacy_session_id_map_session_id_sessions; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.legacy_session_id_map
    ADD CONSTRAINT fk_legacy_session_id_map_session_id_sessions FOREIGN KEY (session_id) REFERENCES events.sessions(id);


--
-- Name: legacy_subcontribution_id_map fk_legacy_subcontribution_id_map_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.legacy_subcontribution_id_map
    ADD CONSTRAINT fk_legacy_subcontribution_id_map_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: legacy_subcontribution_id_map fk_legacy_subcontribution_id_map_subcontribution; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.legacy_subcontribution_id_map
    ADD CONSTRAINT fk_legacy_subcontribution_id_map_subcontribution FOREIGN KEY (subcontribution_id) REFERENCES events.subcontributions(id);


--
-- Name: logs fk_logs_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.logs
    ADD CONSTRAINT fk_logs_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: logs fk_logs_user_id_users; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.logs
    ADD CONSTRAINT fk_logs_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: menu_entries fk_menu_entries_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.menu_entries
    ADD CONSTRAINT fk_menu_entries_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: menu_entries fk_menu_entries_page_id_pages; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.menu_entries
    ADD CONSTRAINT fk_menu_entries_page_id_pages FOREIGN KEY (page_id) REFERENCES events.pages(id);


--
-- Name: menu_entries fk_menu_entries_parent_id_menu_entries; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.menu_entries
    ADD CONSTRAINT fk_menu_entries_parent_id_menu_entries FOREIGN KEY (parent_id) REFERENCES events.menu_entries(id);


--
-- Name: menu_entry_principals fk_menu_entry_principals_category_role_id_roles; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.menu_entry_principals
    ADD CONSTRAINT fk_menu_entry_principals_category_role_id_roles FOREIGN KEY (category_role_id) REFERENCES categories.roles(id);


--
-- Name: menu_entry_principals fk_menu_entry_principals_event_role_id_roles; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.menu_entry_principals
    ADD CONSTRAINT fk_menu_entry_principals_event_role_id_roles FOREIGN KEY (event_role_id) REFERENCES events.roles(id);


--
-- Name: menu_entry_principals fk_menu_entry_principals_local_group_id_groups; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.menu_entry_principals
    ADD CONSTRAINT fk_menu_entry_principals_local_group_id_groups FOREIGN KEY (local_group_id) REFERENCES users.groups(id);


--
-- Name: menu_entry_principals fk_menu_entry_principals_menu_entry_id_menu_entries; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.menu_entry_principals
    ADD CONSTRAINT fk_menu_entry_principals_menu_entry_id_menu_entries FOREIGN KEY (menu_entry_id) REFERENCES events.menu_entries(id);


--
-- Name: menu_entry_principals fk_menu_entry_principals_registration_form_id_forms; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.menu_entry_principals
    ADD CONSTRAINT fk_menu_entry_principals_registration_form_id_forms FOREIGN KEY (registration_form_id) REFERENCES event_registration.forms(id);


--
-- Name: menu_entry_principals fk_menu_entry_principals_user_id_users; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.menu_entry_principals
    ADD CONSTRAINT fk_menu_entry_principals_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: note_revisions fk_note_revisions_note_id_notes; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.note_revisions
    ADD CONSTRAINT fk_note_revisions_note_id_notes FOREIGN KEY (note_id) REFERENCES events.notes(id);


--
-- Name: note_revisions fk_note_revisions_user_id_users; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.note_revisions
    ADD CONSTRAINT fk_note_revisions_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: notes fk_notes_contribution_id_contributions; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.notes
    ADD CONSTRAINT fk_notes_contribution_id_contributions FOREIGN KEY (contribution_id) REFERENCES events.contributions(id);


--
-- Name: notes fk_notes_current_revision_id_note_revisions; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.notes
    ADD CONSTRAINT fk_notes_current_revision_id_note_revisions FOREIGN KEY (current_revision_id) REFERENCES events.note_revisions(id);


--
-- Name: notes fk_notes_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.notes
    ADD CONSTRAINT fk_notes_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: notes fk_notes_linked_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.notes
    ADD CONSTRAINT fk_notes_linked_event_id_events FOREIGN KEY (linked_event_id) REFERENCES events.events(id);


--
-- Name: notes fk_notes_session_id_sessions; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.notes
    ADD CONSTRAINT fk_notes_session_id_sessions FOREIGN KEY (session_id) REFERENCES events.sessions(id);


--
-- Name: notes fk_notes_subcontribution_id_subcontributions; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.notes
    ADD CONSTRAINT fk_notes_subcontribution_id_subcontributions FOREIGN KEY (subcontribution_id) REFERENCES events.subcontributions(id);


--
-- Name: pages fk_pages_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.pages
    ADD CONSTRAINT fk_pages_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: payment_transactions fk_payment_transactions_registration_id_registrations; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.payment_transactions
    ADD CONSTRAINT fk_payment_transactions_registration_id_registrations FOREIGN KEY (registration_id) REFERENCES event_registration.registrations(id);


--
-- Name: persons fk_persons_affiliation_id_affiliations; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.persons
    ADD CONSTRAINT fk_persons_affiliation_id_affiliations FOREIGN KEY (affiliation_id) REFERENCES indico.affiliations(id);


--
-- Name: persons fk_persons_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.persons
    ADD CONSTRAINT fk_persons_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: persons fk_persons_user_id_users; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.persons
    ADD CONSTRAINT fk_persons_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: principals fk_principals_category_role_id_roles; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.principals
    ADD CONSTRAINT fk_principals_category_role_id_roles FOREIGN KEY (category_role_id) REFERENCES categories.roles(id);


--
-- Name: principals fk_principals_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.principals
    ADD CONSTRAINT fk_principals_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: principals fk_principals_event_role_id_roles; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.principals
    ADD CONSTRAINT fk_principals_event_role_id_roles FOREIGN KEY (event_role_id) REFERENCES events.roles(id);


--
-- Name: principals fk_principals_ip_network_group_id_ip_network_groups; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.principals
    ADD CONSTRAINT fk_principals_ip_network_group_id_ip_network_groups FOREIGN KEY (ip_network_group_id) REFERENCES indico.ip_network_groups(id);


--
-- Name: principals fk_principals_local_group_id_groups; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.principals
    ADD CONSTRAINT fk_principals_local_group_id_groups FOREIGN KEY (local_group_id) REFERENCES users.groups(id);


--
-- Name: principals fk_principals_registration_form_id_forms; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.principals
    ADD CONSTRAINT fk_principals_registration_form_id_forms FOREIGN KEY (registration_form_id) REFERENCES event_registration.forms(id);


--
-- Name: principals fk_principals_user_id_users; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.principals
    ADD CONSTRAINT fk_principals_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: reminders fk_reminders_creator_id_users; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.reminders
    ADD CONSTRAINT fk_reminders_creator_id_users FOREIGN KEY (creator_id) REFERENCES users.users(id);


--
-- Name: reminders fk_reminders_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.reminders
    ADD CONSTRAINT fk_reminders_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: requests fk_requests_created_by_id_users; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.requests
    ADD CONSTRAINT fk_requests_created_by_id_users FOREIGN KEY (created_by_id) REFERENCES users.users(id);


--
-- Name: requests fk_requests_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.requests
    ADD CONSTRAINT fk_requests_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: requests fk_requests_processed_by_id_users; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.requests
    ADD CONSTRAINT fk_requests_processed_by_id_users FOREIGN KEY (processed_by_id) REFERENCES users.users(id);


--
-- Name: role_members fk_role_members_role_id_roles; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.role_members
    ADD CONSTRAINT fk_role_members_role_id_roles FOREIGN KEY (role_id) REFERENCES events.roles(id);


--
-- Name: role_members fk_role_members_user_id_users; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.role_members
    ADD CONSTRAINT fk_role_members_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: roles fk_roles_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.roles
    ADD CONSTRAINT fk_roles_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: session_block_person_links fk_session_block_person_links_affiliation_id_affiliations; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.session_block_person_links
    ADD CONSTRAINT fk_session_block_person_links_affiliation_id_affiliations FOREIGN KEY (affiliation_id) REFERENCES indico.affiliations(id);


--
-- Name: session_block_person_links fk_session_block_person_links_person_id_persons; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.session_block_person_links
    ADD CONSTRAINT fk_session_block_person_links_person_id_persons FOREIGN KEY (person_id) REFERENCES events.persons(id);


--
-- Name: session_block_person_links fk_session_block_person_links_session_block_id_session_blocks; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.session_block_person_links
    ADD CONSTRAINT fk_session_block_person_links_session_block_id_session_blocks FOREIGN KEY (session_block_id) REFERENCES events.session_blocks(id);


--
-- Name: session_blocks fk_session_blocks_room_id_rooms; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.session_blocks
    ADD CONSTRAINT fk_session_blocks_room_id_rooms FOREIGN KEY (room_id) REFERENCES roombooking.rooms(id);


--
-- Name: session_blocks fk_session_blocks_session_id_sessions; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.session_blocks
    ADD CONSTRAINT fk_session_blocks_session_id_sessions FOREIGN KEY (session_id) REFERENCES events.sessions(id);


--
-- Name: session_blocks fk_session_blocks_venue_id_locations; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.session_blocks
    ADD CONSTRAINT fk_session_blocks_venue_id_locations FOREIGN KEY (venue_id) REFERENCES roombooking.locations(id);


--
-- Name: session_blocks fk_session_blocks_venue_id_room_id_rooms; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.session_blocks
    ADD CONSTRAINT fk_session_blocks_venue_id_room_id_rooms FOREIGN KEY (venue_id, room_id) REFERENCES roombooking.rooms(location_id, id);


--
-- Name: session_principals fk_session_principals_category_role_id_roles; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.session_principals
    ADD CONSTRAINT fk_session_principals_category_role_id_roles FOREIGN KEY (category_role_id) REFERENCES categories.roles(id);


--
-- Name: session_principals fk_session_principals_event_role_id_roles; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.session_principals
    ADD CONSTRAINT fk_session_principals_event_role_id_roles FOREIGN KEY (event_role_id) REFERENCES events.roles(id);


--
-- Name: session_principals fk_session_principals_local_group_id_groups; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.session_principals
    ADD CONSTRAINT fk_session_principals_local_group_id_groups FOREIGN KEY (local_group_id) REFERENCES users.groups(id);


--
-- Name: session_principals fk_session_principals_registration_form_id_forms; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.session_principals
    ADD CONSTRAINT fk_session_principals_registration_form_id_forms FOREIGN KEY (registration_form_id) REFERENCES event_registration.forms(id);


--
-- Name: session_principals fk_session_principals_session_id_sessions; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.session_principals
    ADD CONSTRAINT fk_session_principals_session_id_sessions FOREIGN KEY (session_id) REFERENCES events.sessions(id);


--
-- Name: session_principals fk_session_principals_user_id_users; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.session_principals
    ADD CONSTRAINT fk_session_principals_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: session_types fk_session_types_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.session_types
    ADD CONSTRAINT fk_session_types_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: sessions fk_sessions_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.sessions
    ADD CONSTRAINT fk_sessions_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: sessions fk_sessions_room_id_rooms; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.sessions
    ADD CONSTRAINT fk_sessions_room_id_rooms FOREIGN KEY (room_id) REFERENCES roombooking.rooms(id);


--
-- Name: sessions fk_sessions_type_id_session_types; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.sessions
    ADD CONSTRAINT fk_sessions_type_id_session_types FOREIGN KEY (type_id) REFERENCES events.session_types(id);


--
-- Name: sessions fk_sessions_venue_id_locations; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.sessions
    ADD CONSTRAINT fk_sessions_venue_id_locations FOREIGN KEY (venue_id) REFERENCES roombooking.locations(id);


--
-- Name: sessions fk_sessions_venue_id_room_id_rooms; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.sessions
    ADD CONSTRAINT fk_sessions_venue_id_room_id_rooms FOREIGN KEY (venue_id, room_id) REFERENCES roombooking.rooms(location_id, id);


--
-- Name: settings fk_settings_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.settings
    ADD CONSTRAINT fk_settings_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: settings_principals fk_settings_principals_category_role_id_roles; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.settings_principals
    ADD CONSTRAINT fk_settings_principals_category_role_id_roles FOREIGN KEY (category_role_id) REFERENCES categories.roles(id);


--
-- Name: settings_principals fk_settings_principals_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.settings_principals
    ADD CONSTRAINT fk_settings_principals_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: settings_principals fk_settings_principals_event_role_id_roles; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.settings_principals
    ADD CONSTRAINT fk_settings_principals_event_role_id_roles FOREIGN KEY (event_role_id) REFERENCES events.roles(id);


--
-- Name: settings_principals fk_settings_principals_local_group_id_groups; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.settings_principals
    ADD CONSTRAINT fk_settings_principals_local_group_id_groups FOREIGN KEY (local_group_id) REFERENCES users.groups(id);


--
-- Name: settings_principals fk_settings_principals_user_id_users; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.settings_principals
    ADD CONSTRAINT fk_settings_principals_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: static_list_links fk_static_list_links_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.static_list_links
    ADD CONSTRAINT fk_static_list_links_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: static_sites fk_static_sites_creator_id_users; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.static_sites
    ADD CONSTRAINT fk_static_sites_creator_id_users FOREIGN KEY (creator_id) REFERENCES users.users(id);


--
-- Name: static_sites fk_static_sites_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.static_sites
    ADD CONSTRAINT fk_static_sites_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: subcontribution_person_links fk_subcontribution_person_links_affiliation_id_affiliations; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.subcontribution_person_links
    ADD CONSTRAINT fk_subcontribution_person_links_affiliation_id_affiliations FOREIGN KEY (affiliation_id) REFERENCES indico.affiliations(id);


--
-- Name: subcontribution_person_links fk_subcontribution_person_links_person_id_persons; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.subcontribution_person_links
    ADD CONSTRAINT fk_subcontribution_person_links_person_id_persons FOREIGN KEY (person_id) REFERENCES events.persons(id);


--
-- Name: subcontribution_person_links fk_subcontribution_person_links_subcontribution_id_subc_0455; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.subcontribution_person_links
    ADD CONSTRAINT fk_subcontribution_person_links_subcontribution_id_subc_0455 FOREIGN KEY (subcontribution_id) REFERENCES events.subcontributions(id);


--
-- Name: subcontribution_references fk_subcontribution_references_reference_type_id_reference_types; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.subcontribution_references
    ADD CONSTRAINT fk_subcontribution_references_reference_type_id_reference_types FOREIGN KEY (reference_type_id) REFERENCES indico.reference_types(id);


--
-- Name: subcontribution_references fk_subcontribution_references_subcontribution_id_subcon_bb79; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.subcontribution_references
    ADD CONSTRAINT fk_subcontribution_references_subcontribution_id_subcon_bb79 FOREIGN KEY (subcontribution_id) REFERENCES events.subcontributions(id);


--
-- Name: subcontributions fk_subcontributions_contribution_id_contributions; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.subcontributions
    ADD CONSTRAINT fk_subcontributions_contribution_id_contributions FOREIGN KEY (contribution_id) REFERENCES events.contributions(id);


--
-- Name: timetable_entries fk_timetable_entries_break_id_breaks; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.timetable_entries
    ADD CONSTRAINT fk_timetable_entries_break_id_breaks FOREIGN KEY (break_id) REFERENCES events.breaks(id);


--
-- Name: timetable_entries fk_timetable_entries_contribution_id_contributions; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.timetable_entries
    ADD CONSTRAINT fk_timetable_entries_contribution_id_contributions FOREIGN KEY (contribution_id) REFERENCES events.contributions(id);


--
-- Name: timetable_entries fk_timetable_entries_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.timetable_entries
    ADD CONSTRAINT fk_timetable_entries_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: timetable_entries fk_timetable_entries_parent_id_timetable_entries; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.timetable_entries
    ADD CONSTRAINT fk_timetable_entries_parent_id_timetable_entries FOREIGN KEY (parent_id) REFERENCES events.timetable_entries(id);


--
-- Name: timetable_entries fk_timetable_entries_session_block_id_session_blocks; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.timetable_entries
    ADD CONSTRAINT fk_timetable_entries_session_block_id_session_blocks FOREIGN KEY (session_block_id) REFERENCES events.session_blocks(id);


--
-- Name: track_groups fk_track_groups_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.track_groups
    ADD CONSTRAINT fk_track_groups_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: track_principals fk_track_principals_category_role_id_roles; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.track_principals
    ADD CONSTRAINT fk_track_principals_category_role_id_roles FOREIGN KEY (category_role_id) REFERENCES categories.roles(id);


--
-- Name: track_principals fk_track_principals_event_role_id_roles; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.track_principals
    ADD CONSTRAINT fk_track_principals_event_role_id_roles FOREIGN KEY (event_role_id) REFERENCES events.roles(id);


--
-- Name: track_principals fk_track_principals_local_group_id_groups; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.track_principals
    ADD CONSTRAINT fk_track_principals_local_group_id_groups FOREIGN KEY (local_group_id) REFERENCES users.groups(id);


--
-- Name: track_principals fk_track_principals_track_id_tracks; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.track_principals
    ADD CONSTRAINT fk_track_principals_track_id_tracks FOREIGN KEY (track_id) REFERENCES events.tracks(id);


--
-- Name: track_principals fk_track_principals_user_id_users; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.track_principals
    ADD CONSTRAINT fk_track_principals_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: tracks fk_tracks_default_session_id_sessions; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.tracks
    ADD CONSTRAINT fk_tracks_default_session_id_sessions FOREIGN KEY (default_session_id) REFERENCES events.sessions(id);


--
-- Name: tracks fk_tracks_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.tracks
    ADD CONSTRAINT fk_tracks_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: tracks fk_tracks_track_group_id_track_groups; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.tracks
    ADD CONSTRAINT fk_tracks_track_group_id_track_groups FOREIGN KEY (track_group_id) REFERENCES events.track_groups(id) ON DELETE SET NULL;


--
-- Name: vc_room_events fk_vc_room_events_contribution_id_contributions; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.vc_room_events
    ADD CONSTRAINT fk_vc_room_events_contribution_id_contributions FOREIGN KEY (contribution_id) REFERENCES events.contributions(id);


--
-- Name: vc_room_events fk_vc_room_events_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.vc_room_events
    ADD CONSTRAINT fk_vc_room_events_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: vc_room_events fk_vc_room_events_linked_event_id_events; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.vc_room_events
    ADD CONSTRAINT fk_vc_room_events_linked_event_id_events FOREIGN KEY (linked_event_id) REFERENCES events.events(id);


--
-- Name: vc_room_events fk_vc_room_events_session_block_id_session_blocks; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.vc_room_events
    ADD CONSTRAINT fk_vc_room_events_session_block_id_session_blocks FOREIGN KEY (session_block_id) REFERENCES events.session_blocks(id);


--
-- Name: vc_room_events fk_vc_room_events_vc_room_id_vc_rooms; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.vc_room_events
    ADD CONSTRAINT fk_vc_room_events_vc_room_id_vc_rooms FOREIGN KEY (vc_room_id) REFERENCES events.vc_rooms(id);


--
-- Name: vc_rooms fk_vc_rooms_created_by_id_users; Type: FK CONSTRAINT; Schema: events; Owner: indico
--

ALTER TABLE ONLY events.vc_rooms
    ADD CONSTRAINT fk_vc_rooms_created_by_id_users FOREIGN KEY (created_by_id) REFERENCES users.users(id);


--
-- Name: designer_image_files fk_designer_image_files_template_id_designer_templates; Type: FK CONSTRAINT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.designer_image_files
    ADD CONSTRAINT fk_designer_image_files_template_id_designer_templates FOREIGN KEY (template_id) REFERENCES indico.designer_templates(id);


--
-- Name: designer_templates fk_designer_templates_background_image_id_designer_image_files; Type: FK CONSTRAINT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.designer_templates
    ADD CONSTRAINT fk_designer_templates_background_image_id_designer_image_files FOREIGN KEY (background_image_id) REFERENCES indico.designer_image_files(id);


--
-- Name: designer_templates fk_designer_templates_backside_template_id_designer_templates; Type: FK CONSTRAINT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.designer_templates
    ADD CONSTRAINT fk_designer_templates_backside_template_id_designer_templates FOREIGN KEY (backside_template_id) REFERENCES indico.designer_templates(id);


--
-- Name: designer_templates fk_designer_templates_category_id_categories; Type: FK CONSTRAINT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.designer_templates
    ADD CONSTRAINT fk_designer_templates_category_id_categories FOREIGN KEY (category_id) REFERENCES categories.categories(id);


--
-- Name: designer_templates fk_designer_templates_event_id_events; Type: FK CONSTRAINT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.designer_templates
    ADD CONSTRAINT fk_designer_templates_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: designer_templates fk_designer_templates_registration_form_id_forms; Type: FK CONSTRAINT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.designer_templates
    ADD CONSTRAINT fk_designer_templates_registration_form_id_forms FOREIGN KEY (registration_form_id) REFERENCES event_registration.forms(id);


--
-- Name: ip_networks fk_ip_networks_group_id_ip_network_groups; Type: FK CONSTRAINT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.ip_networks
    ADD CONSTRAINT fk_ip_networks_group_id_ip_network_groups FOREIGN KEY (group_id) REFERENCES indico.ip_network_groups(id);


--
-- Name: receipt_templates fk_receipt_templates_category_id_categories; Type: FK CONSTRAINT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.receipt_templates
    ADD CONSTRAINT fk_receipt_templates_category_id_categories FOREIGN KEY (category_id) REFERENCES categories.categories(id);


--
-- Name: receipt_templates fk_receipt_templates_event_id_events; Type: FK CONSTRAINT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.receipt_templates
    ADD CONSTRAINT fk_receipt_templates_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: settings_principals fk_settings_principals_local_group_id_groups; Type: FK CONSTRAINT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.settings_principals
    ADD CONSTRAINT fk_settings_principals_local_group_id_groups FOREIGN KEY (local_group_id) REFERENCES users.groups(id);


--
-- Name: settings_principals fk_settings_principals_user_id_users; Type: FK CONSTRAINT; Schema: indico; Owner: indico
--

ALTER TABLE ONLY indico.settings_principals
    ADD CONSTRAINT fk_settings_principals_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: application_user_links fk_application_user_links_application_id_applications; Type: FK CONSTRAINT; Schema: oauth; Owner: indico
--

ALTER TABLE ONLY oauth.application_user_links
    ADD CONSTRAINT fk_application_user_links_application_id_applications FOREIGN KEY (application_id) REFERENCES oauth.applications(id) ON DELETE CASCADE;


--
-- Name: application_user_links fk_application_user_links_user_id_users; Type: FK CONSTRAINT; Schema: oauth; Owner: indico
--

ALTER TABLE ONLY oauth.application_user_links
    ADD CONSTRAINT fk_application_user_links_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id) ON DELETE CASCADE;


--
-- Name: tokens fk_tokens_app_user_link_id_application_user_links; Type: FK CONSTRAINT; Schema: oauth; Owner: indico
--

ALTER TABLE ONLY oauth.tokens
    ADD CONSTRAINT fk_tokens_app_user_link_id_application_user_links FOREIGN KEY (app_user_link_id) REFERENCES oauth.application_user_links(id) ON DELETE CASCADE;


--
-- Name: blocked_rooms fk_blocked_rooms_blocking_id_blockings; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.blocked_rooms
    ADD CONSTRAINT fk_blocked_rooms_blocking_id_blockings FOREIGN KEY (blocking_id) REFERENCES roombooking.blockings(id);


--
-- Name: blocked_rooms fk_blocked_rooms_room_id_rooms; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.blocked_rooms
    ADD CONSTRAINT fk_blocked_rooms_room_id_rooms FOREIGN KEY (room_id) REFERENCES roombooking.rooms(id);


--
-- Name: blocking_principals fk_blocking_principals_blocking_id_blockings; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.blocking_principals
    ADD CONSTRAINT fk_blocking_principals_blocking_id_blockings FOREIGN KEY (blocking_id) REFERENCES roombooking.blockings(id);


--
-- Name: blocking_principals fk_blocking_principals_local_group_id_groups; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.blocking_principals
    ADD CONSTRAINT fk_blocking_principals_local_group_id_groups FOREIGN KEY (local_group_id) REFERENCES users.groups(id);


--
-- Name: blocking_principals fk_blocking_principals_user_id_users; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.blocking_principals
    ADD CONSTRAINT fk_blocking_principals_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: blockings fk_blockings_created_by_id_users; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.blockings
    ADD CONSTRAINT fk_blockings_created_by_id_users FOREIGN KEY (created_by_id) REFERENCES users.users(id);


--
-- Name: equipment_features fk_equipment_features_equipment_id_equipment_types; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.equipment_features
    ADD CONSTRAINT fk_equipment_features_equipment_id_equipment_types FOREIGN KEY (equipment_id) REFERENCES roombooking.equipment_types(id);


--
-- Name: equipment_features fk_equipment_features_feature_id_features; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.equipment_features
    ADD CONSTRAINT fk_equipment_features_feature_id_features FOREIGN KEY (feature_id) REFERENCES roombooking.features(id);


--
-- Name: favorite_rooms fk_favorite_rooms_room_id_rooms; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.favorite_rooms
    ADD CONSTRAINT fk_favorite_rooms_room_id_rooms FOREIGN KEY (room_id) REFERENCES roombooking.rooms(id);


--
-- Name: favorite_rooms fk_favorite_rooms_user_id_users; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.favorite_rooms
    ADD CONSTRAINT fk_favorite_rooms_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: location_principals fk_location_principals_local_group_id_groups; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.location_principals
    ADD CONSTRAINT fk_location_principals_local_group_id_groups FOREIGN KEY (local_group_id) REFERENCES users.groups(id);


--
-- Name: location_principals fk_location_principals_location_id_locations; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.location_principals
    ADD CONSTRAINT fk_location_principals_location_id_locations FOREIGN KEY (location_id) REFERENCES roombooking.locations(id);


--
-- Name: location_principals fk_location_principals_user_id_users; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.location_principals
    ADD CONSTRAINT fk_location_principals_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: reservation_edit_logs fk_reservation_edit_logs_reservation_id_reservations; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.reservation_edit_logs
    ADD CONSTRAINT fk_reservation_edit_logs_reservation_id_reservations FOREIGN KEY (reservation_id) REFERENCES roombooking.reservations(id);


--
-- Name: reservation_occurrence_links fk_reservation_occurrence_links_contribution_id_contributions; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.reservation_occurrence_links
    ADD CONSTRAINT fk_reservation_occurrence_links_contribution_id_contributions FOREIGN KEY (contribution_id) REFERENCES events.contributions(id);


--
-- Name: reservation_occurrence_links fk_reservation_occurrence_links_event_id_events; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.reservation_occurrence_links
    ADD CONSTRAINT fk_reservation_occurrence_links_event_id_events FOREIGN KEY (event_id) REFERENCES events.events(id);


--
-- Name: reservation_occurrence_links fk_reservation_occurrence_links_linked_event_id_events; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.reservation_occurrence_links
    ADD CONSTRAINT fk_reservation_occurrence_links_linked_event_id_events FOREIGN KEY (linked_event_id) REFERENCES events.events(id);


--
-- Name: reservation_occurrence_links fk_reservation_occurrence_links_session_block_id_session_blocks; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.reservation_occurrence_links
    ADD CONSTRAINT fk_reservation_occurrence_links_session_block_id_session_blocks FOREIGN KEY (session_block_id) REFERENCES events.session_blocks(id);


--
-- Name: reservation_occurrences fk_reservation_occurrences_link_id_reservation_occurrence_links; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.reservation_occurrences
    ADD CONSTRAINT fk_reservation_occurrences_link_id_reservation_occurrence_links FOREIGN KEY (link_id) REFERENCES roombooking.reservation_occurrence_links(id);


--
-- Name: reservation_occurrences fk_reservation_occurrences_reservation_id_reservations; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.reservation_occurrences
    ADD CONSTRAINT fk_reservation_occurrences_reservation_id_reservations FOREIGN KEY (reservation_id) REFERENCES roombooking.reservations(id);


--
-- Name: reservations fk_reservations_booked_for_id_users; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.reservations
    ADD CONSTRAINT fk_reservations_booked_for_id_users FOREIGN KEY (booked_for_id) REFERENCES users.users(id);


--
-- Name: reservations fk_reservations_created_by_id_users; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.reservations
    ADD CONSTRAINT fk_reservations_created_by_id_users FOREIGN KEY (created_by_id) REFERENCES users.users(id);


--
-- Name: reservations fk_reservations_room_id_rooms; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.reservations
    ADD CONSTRAINT fk_reservations_room_id_rooms FOREIGN KEY (room_id) REFERENCES roombooking.rooms(id);


--
-- Name: room_attribute_values fk_room_attribute_values_attribute_id_room_attributes; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.room_attribute_values
    ADD CONSTRAINT fk_room_attribute_values_attribute_id_room_attributes FOREIGN KEY (attribute_id) REFERENCES roombooking.room_attributes(id);


--
-- Name: room_attribute_values fk_room_attribute_values_room_id_rooms; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.room_attribute_values
    ADD CONSTRAINT fk_room_attribute_values_room_id_rooms FOREIGN KEY (room_id) REFERENCES roombooking.rooms(id);


--
-- Name: room_bookable_hours fk_room_bookable_hours_room_id_rooms; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.room_bookable_hours
    ADD CONSTRAINT fk_room_bookable_hours_room_id_rooms FOREIGN KEY (room_id) REFERENCES roombooking.rooms(id);


--
-- Name: room_equipment fk_room_equipment_equipment_id_equipment_types; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.room_equipment
    ADD CONSTRAINT fk_room_equipment_equipment_id_equipment_types FOREIGN KEY (equipment_id) REFERENCES roombooking.equipment_types(id);


--
-- Name: room_equipment fk_room_equipment_room_id_rooms; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.room_equipment
    ADD CONSTRAINT fk_room_equipment_room_id_rooms FOREIGN KEY (room_id) REFERENCES roombooking.rooms(id);


--
-- Name: room_nonbookable_periods fk_room_nonbookable_periods_room_id_rooms; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.room_nonbookable_periods
    ADD CONSTRAINT fk_room_nonbookable_periods_room_id_rooms FOREIGN KEY (room_id) REFERENCES roombooking.rooms(id);


--
-- Name: room_principals fk_room_principals_local_group_id_groups; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.room_principals
    ADD CONSTRAINT fk_room_principals_local_group_id_groups FOREIGN KEY (local_group_id) REFERENCES users.groups(id);


--
-- Name: room_principals fk_room_principals_room_id_rooms; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.room_principals
    ADD CONSTRAINT fk_room_principals_room_id_rooms FOREIGN KEY (room_id) REFERENCES roombooking.rooms(id);


--
-- Name: room_principals fk_room_principals_user_id_users; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.room_principals
    ADD CONSTRAINT fk_room_principals_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: rooms fk_rooms_location_id_locations; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.rooms
    ADD CONSTRAINT fk_rooms_location_id_locations FOREIGN KEY (location_id) REFERENCES roombooking.locations(id);


--
-- Name: rooms fk_rooms_owner_id_users; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.rooms
    ADD CONSTRAINT fk_rooms_owner_id_users FOREIGN KEY (owner_id) REFERENCES users.users(id);


--
-- Name: rooms fk_rooms_photo_id_photos; Type: FK CONSTRAINT; Schema: roombooking; Owner: indico
--

ALTER TABLE ONLY roombooking.rooms
    ADD CONSTRAINT fk_rooms_photo_id_photos FOREIGN KEY (photo_id) REFERENCES roombooking.photos(id);


--
-- Name: api_keys fk_api_keys_user_id_users; Type: FK CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.api_keys
    ADD CONSTRAINT fk_api_keys_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: data_export_requests fk_data_export_requests_file_id_files; Type: FK CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.data_export_requests
    ADD CONSTRAINT fk_data_export_requests_file_id_files FOREIGN KEY (file_id) REFERENCES indico.files(id);


--
-- Name: data_export_requests fk_data_export_requests_user_id_users; Type: FK CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.data_export_requests
    ADD CONSTRAINT fk_data_export_requests_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id) ON DELETE CASCADE;


--
-- Name: emails fk_emails_user_id_users; Type: FK CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.emails
    ADD CONSTRAINT fk_emails_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: favorite_categories fk_favorite_categories_target_id_categories; Type: FK CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.favorite_categories
    ADD CONSTRAINT fk_favorite_categories_target_id_categories FOREIGN KEY (target_id) REFERENCES categories.categories(id);


--
-- Name: favorite_categories fk_favorite_categories_user_id_users; Type: FK CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.favorite_categories
    ADD CONSTRAINT fk_favorite_categories_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: favorite_events fk_favorite_events_target_id_events; Type: FK CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.favorite_events
    ADD CONSTRAINT fk_favorite_events_target_id_events FOREIGN KEY (target_id) REFERENCES events.events(id);


--
-- Name: favorite_events fk_favorite_events_user_id_users; Type: FK CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.favorite_events
    ADD CONSTRAINT fk_favorite_events_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: favorite_users fk_favorite_users_target_id_users; Type: FK CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.favorite_users
    ADD CONSTRAINT fk_favorite_users_target_id_users FOREIGN KEY (target_id) REFERENCES users.users(id);


--
-- Name: favorite_users fk_favorite_users_user_id_users; Type: FK CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.favorite_users
    ADD CONSTRAINT fk_favorite_users_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: group_members fk_group_members_group_id_groups; Type: FK CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.group_members
    ADD CONSTRAINT fk_group_members_group_id_groups FOREIGN KEY (group_id) REFERENCES users.groups(id);


--
-- Name: group_members fk_group_members_user_id_users; Type: FK CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.group_members
    ADD CONSTRAINT fk_group_members_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: identities fk_identities_user_id_users; Type: FK CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.identities
    ADD CONSTRAINT fk_identities_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: logs fk_logs_target_user_id_users; Type: FK CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.logs
    ADD CONSTRAINT fk_logs_target_user_id_users FOREIGN KEY (target_user_id) REFERENCES users.users(id);


--
-- Name: logs fk_logs_user_id_users; Type: FK CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.logs
    ADD CONSTRAINT fk_logs_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: settings fk_settings_user_id_users; Type: FK CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.settings
    ADD CONSTRAINT fk_settings_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: suggested_categories fk_suggested_categories_category_id_categories; Type: FK CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.suggested_categories
    ADD CONSTRAINT fk_suggested_categories_category_id_categories FOREIGN KEY (category_id) REFERENCES categories.categories(id);


--
-- Name: suggested_categories fk_suggested_categories_user_id_users; Type: FK CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.suggested_categories
    ADD CONSTRAINT fk_suggested_categories_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id);


--
-- Name: tokens fk_tokens_user_id_users; Type: FK CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.tokens
    ADD CONSTRAINT fk_tokens_user_id_users FOREIGN KEY (user_id) REFERENCES users.users(id) ON DELETE CASCADE;


--
-- Name: users fk_users_affiliation_id_affiliations; Type: FK CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.users
    ADD CONSTRAINT fk_users_affiliation_id_affiliations FOREIGN KEY (affiliation_id) REFERENCES indico.affiliations(id);


--
-- Name: users fk_users_merged_into_id_users; Type: FK CONSTRAINT; Schema: users; Owner: indico
--

ALTER TABLE ONLY users.users
    ADD CONSTRAINT fk_users_merged_into_id_users FOREIGN KEY (merged_into_id) REFERENCES users.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict gHxUjfVDfVpsMB1igawKIiDhcv5d0d2C0GtntIGHbqSP1etdz352f7dC2HTW828

