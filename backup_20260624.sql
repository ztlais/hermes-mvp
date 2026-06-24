--
-- PostgreSQL database dump
--

\restrict pwIob0Yb6kL0qdfGXZXcAE1rFQcdAShtAtVjbvhiYudxhgYpC72ncrdlFRmQBai

-- Dumped from database version 16.14 (Ubuntu 16.14-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.14 (Ubuntu 16.14-0ubuntu0.24.04.1)

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
-- Name: investorstatus; Type: TYPE; Schema: public; Owner: hermes
--

CREATE TYPE public.investorstatus AS ENUM (
    'to_contact',
    'contacted',
    'in_discussion',
    'active',
    'inactive'
);


ALTER TYPE public.investorstatus OWNER TO hermes;

--
-- Name: investortype; Type: TYPE; Schema: public; Owner: hermes
--

CREATE TYPE public.investortype AS ENUM (
    'fund',
    'family_office',
    'ipp',
    'corporate',
    'other'
);


ALTER TYPE public.investortype OWNER TO hermes;

--
-- Name: learningcategory; Type: TYPE; Schema: public; Owner: hermes
--

CREATE TYPE public.learningcategory AS ENUM (
    'vocabulary',
    'concept',
    'regulation',
    'market',
    'finance',
    'technical',
    'other'
);


ALTER TYPE public.learningcategory OWNER TO hermes;

--
-- Name: opportunitystatus; Type: TYPE; Schema: public; Owner: hermes
--

CREATE TYPE public.opportunitystatus AS ENUM (
    'en_discussion',
    'offre_envoyee',
    'term_sheet',
    'signe',
    'perdu'
);


ALTER TYPE public.opportunitystatus OWNER TO hermes;

--
-- Name: opportunitytype; Type: TYPE; Schema: public; Owner: hermes
--

CREATE TYPE public.opportunitytype AS ENUM (
    'financement',
    'levee',
    'co_dev',
    'cession',
    'ppa',
    'autre'
);


ALTER TYPE public.opportunitytype OWNER TO hermes;

--
-- Name: projectstage; Type: TYPE; Schema: public; Owner: hermes
--

CREATE TYPE public.projectstage AS ENUM (
    'development',
    'permitting',
    'ready_to_build',
    'construction',
    'operational',
    'origination',
    'early',
    'submit',
    'mid',
    'advanced',
    'nearly_secured',
    'secured_and_clean',
    'refused'
);


ALTER TYPE public.projectstage OWNER TO hermes;

--
-- Name: projecttechnology; Type: TYPE; Schema: public; Owner: hermes
--

CREATE TYPE public.projecttechnology AS ENUM (
    'solar',
    'wind',
    'bess',
    'hydro',
    'biomass',
    'other'
);


ALTER TYPE public.projecttechnology OWNER TO hermes;

--
-- Name: prospectstatus; Type: TYPE; Schema: public; Owner: hermes
--

CREATE TYPE public.prospectstatus AS ENUM (
    'to_contact',
    'contacted',
    'in_discussion',
    'meeting_scheduled',
    'nda_signed',
    'deal_in_progress',
    'closed',
    'rejected'
);


ALTER TYPE public.prospectstatus OWNER TO hermes;

--
-- Name: prospecttype; Type: TYPE; Schema: public; Owner: hermes
--

CREATE TYPE public.prospecttype AS ENUM (
    'developer',
    'investor',
    'ipp',
    'family_office',
    'other'
);


ALTER TYPE public.prospecttype OWNER TO hermes;

--
-- Name: scoutingstatus; Type: TYPE; Schema: public; Owner: hermes
--

CREATE TYPE public.scoutingstatus AS ENUM (
    'to_contact',
    'email_sent',
    'linkedin_sent',
    'responded',
    'meeting_done',
    'converted',
    'no_response',
    'not_interested',
    'premiere_connexion',
    'deuxieme_connexion'
);


ALTER TYPE public.scoutingstatus OWNER TO hermes;

--
-- Name: scoutingtype; Type: TYPE; Schema: public; Owner: hermes
--

CREATE TYPE public.scoutingtype AS ENUM (
    'developer',
    'investor',
    'ipp',
    'family_office'
);


ALTER TYPE public.scoutingtype OWNER TO hermes;

--
-- Name: templatetarget; Type: TYPE; Schema: public; Owner: hermes
--

CREATE TYPE public.templatetarget AS ENUM (
    'developer',
    'investor',
    'ipp',
    'family_office'
);


ALTER TYPE public.templatetarget OWNER TO hermes;

--
-- Name: templatetype; Type: TYPE; Schema: public; Owner: hermes
--

CREATE TYPE public.templatetype AS ENUM (
    'email',
    'linkedin'
);


ALTER TYPE public.templatetype OWNER TO hermes;

--
-- Name: userrole; Type: TYPE; Schema: public; Owner: hermes
--

CREATE TYPE public.userrole AS ENUM (
    'admin',
    'viewer',
    'member',
    'utilisateur'
);


ALTER TYPE public.userrole OWNER TO hermes;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: documents; Type: TABLE; Schema: public; Owner: hermes
--

CREATE TABLE public.documents (
    id integer NOT NULL,
    prospect_id integer,
    name character varying(255) NOT NULL,
    url character varying(1000) NOT NULL,
    doc_type character varying(50),
    created_at timestamp without time zone DEFAULT now(),
    investor_id integer
);


ALTER TABLE public.documents OWNER TO hermes;

--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: hermes
--

CREATE SEQUENCE public.documents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.documents_id_seq OWNER TO hermes;

--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hermes
--

ALTER SEQUENCE public.documents_id_seq OWNED BY public.documents.id;


--
-- Name: exhibition_companies; Type: TABLE; Schema: public; Owner: hermes
--

CREATE TABLE public.exhibition_companies (
    id integer NOT NULL,
    exhibition_id integer NOT NULL,
    name character varying(255) NOT NULL,
    type character varying(100),
    country character varying(100),
    stand character varying(100),
    contact_name character varying(255),
    contact_email character varying(255),
    status character varying(50),
    notes_fr text,
    created_at timestamp with time zone DEFAULT now(),
    notes_en text DEFAULT ''::text
);


ALTER TABLE public.exhibition_companies OWNER TO hermes;

--
-- Name: exhibition_companies_id_seq; Type: SEQUENCE; Schema: public; Owner: hermes
--

CREATE SEQUENCE public.exhibition_companies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.exhibition_companies_id_seq OWNER TO hermes;

--
-- Name: exhibition_companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hermes
--

ALTER SEQUENCE public.exhibition_companies_id_seq OWNED BY public.exhibition_companies.id;


--
-- Name: exhibitions; Type: TABLE; Schema: public; Owner: hermes
--

CREATE TABLE public.exhibitions (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    date character varying(100),
    location character varying(255),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone
);


ALTER TABLE public.exhibitions OWNER TO hermes;

--
-- Name: exhibitions_id_seq; Type: SEQUENCE; Schema: public; Owner: hermes
--

CREATE SEQUENCE public.exhibitions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.exhibitions_id_seq OWNER TO hermes;

--
-- Name: exhibitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hermes
--

ALTER SEQUENCE public.exhibitions_id_seq OWNED BY public.exhibitions.id;


--
-- Name: investors; Type: TABLE; Schema: public; Owner: hermes
--

CREATE TABLE public.investors (
    id integer NOT NULL,
    company character varying(255) NOT NULL,
    contact_name character varying(255),
    email character varying(255),
    phone character varying(50),
    linkedin character varying(500),
    type public.investortype,
    status public.investorstatus,
    country character varying(100),
    target_countries character varying(500),
    technologies character varying(500),
    min_mw double precision,
    max_mw double precision,
    min_ticket double precision,
    max_ticket double precision,
    criteria text,
    notes text,
    last_contact timestamp without time zone,
    next_action text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    deal_stages character varying(500),
    deal_types character varying(500)
);


ALTER TABLE public.investors OWNER TO hermes;

--
-- Name: investors_id_seq; Type: SEQUENCE; Schema: public; Owner: hermes
--

CREATE SEQUENCE public.investors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.investors_id_seq OWNER TO hermes;

--
-- Name: investors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hermes
--

ALTER SEQUENCE public.investors_id_seq OWNED BY public.investors.id;


--
-- Name: learning; Type: TABLE; Schema: public; Owner: hermes
--

CREATE TABLE public.learning (
    id integer NOT NULL,
    term character varying(255) NOT NULL,
    definition text NOT NULL,
    category public.learningcategory,
    example text,
    source character varying(500),
    language character varying(10),
    active boolean,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.learning OWNER TO hermes;

--
-- Name: learning_id_seq; Type: SEQUENCE; Schema: public; Owner: hermes
--

CREATE SEQUENCE public.learning_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.learning_id_seq OWNER TO hermes;

--
-- Name: learning_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hermes
--

ALTER SEQUENCE public.learning_id_seq OWNED BY public.learning.id;


--
-- Name: meeting_preps; Type: TABLE; Schema: public; Owner: hermes
--

CREATE TABLE public.meeting_preps (
    id integer NOT NULL,
    company character varying(255) NOT NULL,
    event_title character varying(500),
    event_date timestamp without time zone,
    context text,
    talking_points json,
    questions json,
    next_steps json,
    personal_notes text,
    status character varying(20),
    source_event_id character varying(100),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.meeting_preps OWNER TO hermes;

--
-- Name: meeting_preps_id_seq; Type: SEQUENCE; Schema: public; Owner: hermes
--

CREATE SEQUENCE public.meeting_preps_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.meeting_preps_id_seq OWNER TO hermes;

--
-- Name: meeting_preps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hermes
--

ALTER SEQUENCE public.meeting_preps_id_seq OWNED BY public.meeting_preps.id;


--
-- Name: opportunities; Type: TABLE; Schema: public; Owner: hermes
--

CREATE TABLE public.opportunities (
    id integer NOT NULL,
    prospect_id integer,
    title character varying(255) NOT NULL,
    type public.opportunitytype,
    country character varying(100),
    size_eur double precision,
    size_mw double precision,
    deadline timestamp without time zone,
    status public.opportunitystatus,
    notes text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    notes_en text,
    title_en text
);


ALTER TABLE public.opportunities OWNER TO hermes;

--
-- Name: opportunities_id_seq; Type: SEQUENCE; Schema: public; Owner: hermes
--

CREATE SEQUENCE public.opportunities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.opportunities_id_seq OWNER TO hermes;

--
-- Name: opportunities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hermes
--

ALTER SEQUENCE public.opportunities_id_seq OWNED BY public.opportunities.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: hermes
--

CREATE TABLE public.projects (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    developer_id integer,
    technology public.projecttechnology,
    stage public.projectstage,
    capacity_mw double precision,
    country character varying(100),
    region text,
    asking_price double precision,
    irr double precision,
    lcoe double precision,
    description text,
    teaser_path character varying(500),
    nda_signed character varying(10),
    notes text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    developer_name text,
    code integer,
    technology_detail text,
    status_detail text,
    p50_mwh double precision,
    commune text,
    department text,
    department_code character varying(10),
    rtb_date text,
    cod_date text,
    permit_status character varying(50),
    permit_type character varying(20),
    land_secured boolean DEFAULT false,
    grid_operator character varying(50),
    grid_connection_cost double precision,
    offtake_type text,
    raw_data text,
    custom_stage character varying(50),
    status_fr character varying(200),
    status_en character varying(200),
    permis_status text
);


ALTER TABLE public.projects OWNER TO hermes;

--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: hermes
--

CREATE SEQUENCE public.projects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.projects_id_seq OWNER TO hermes;

--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hermes
--

ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;


--
-- Name: prospects; Type: TABLE; Schema: public; Owner: hermes
--

CREATE TABLE public.prospects (
    id integer NOT NULL,
    company character varying(255) NOT NULL,
    contact_name character varying(255),
    email character varying(255),
    phone character varying(50),
    linkedin character varying(500),
    type public.prospecttype,
    status public.prospectstatus,
    country character varying(100),
    notes text,
    teaser text,
    nda_signed character varying(10),
    last_contact timestamp without time zone,
    next_action text,
    source character varying(100),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    raw_transcript text,
    email_draft text,
    transcript_processed boolean DEFAULT false
);


ALTER TABLE public.prospects OWNER TO hermes;

--
-- Name: prospects_id_seq; Type: SEQUENCE; Schema: public; Owner: hermes
--

CREATE SEQUENCE public.prospects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.prospects_id_seq OWNER TO hermes;

--
-- Name: prospects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hermes
--

ALTER SEQUENCE public.prospects_id_seq OWNED BY public.prospects.id;


--
-- Name: scouting; Type: TABLE; Schema: public; Owner: hermes
--

CREATE TABLE public.scouting (
    id integer NOT NULL,
    company character varying(255) NOT NULL,
    contact_name character varying(255),
    email character varying(255),
    linkedin character varying(500),
    type public.scoutingtype,
    status public.scoutingstatus,
    country character varying(100),
    template_used character varying(255),
    contact_date timestamp without time zone,
    response_date timestamp without time zone,
    notes text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    data text DEFAULT '{}'::text
);


ALTER TABLE public.scouting OWNER TO hermes;

--
-- Name: scouting_id_seq; Type: SEQUENCE; Schema: public; Owner: hermes
--

CREATE SEQUENCE public.scouting_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.scouting_id_seq OWNER TO hermes;

--
-- Name: scouting_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hermes
--

ALTER SEQUENCE public.scouting_id_seq OWNED BY public.scouting.id;


--
-- Name: task_suggestions; Type: TABLE; Schema: public; Owner: hermes
--

CREATE TABLE public.task_suggestions (
    id integer NOT NULL,
    week_start date NOT NULL,
    source character varying(20) NOT NULL,
    entity_id integer NOT NULL,
    ref character varying(50) NOT NULL,
    company character varying(255),
    contact_name character varying(255),
    status character varying(50),
    nda_signed character varying(10),
    criteria text,
    next_action text,
    notes text,
    notes_preview character varying(200),
    score double precision,
    reason text,
    task text,
    ai_generated boolean,
    last_update timestamp without time zone,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.task_suggestions OWNER TO hermes;

--
-- Name: task_suggestions_id_seq; Type: SEQUENCE; Schema: public; Owner: hermes
--

CREATE SEQUENCE public.task_suggestions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.task_suggestions_id_seq OWNER TO hermes;

--
-- Name: task_suggestions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hermes
--

ALTER SEQUENCE public.task_suggestions_id_seq OWNED BY public.task_suggestions.id;


--
-- Name: templates; Type: TABLE; Schema: public; Owner: hermes
--

CREATE TABLE public.templates (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    type public.templatetype,
    target public.templatetarget,
    subject character varying(500),
    body text NOT NULL,
    language character varying(10),
    notes text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    step integer DEFAULT 1
);


ALTER TABLE public.templates OWNER TO hermes;

--
-- Name: templates_id_seq; Type: SEQUENCE; Schema: public; Owner: hermes
--

CREATE SEQUENCE public.templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.templates_id_seq OWNER TO hermes;

--
-- Name: templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hermes
--

ALTER SEQUENCE public.templates_id_seq OWNED BY public.templates.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: hermes
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(100) NOT NULL,
    full_name character varying(255),
    password_hash character varying(255) NOT NULL,
    role public.userrole,
    is_active boolean,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.users OWNER TO hermes;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: hermes
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO hermes;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hermes
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: weekly_notes; Type: TABLE; Schema: public; Owner: hermes
--

CREATE TABLE public.weekly_notes (
    id integer NOT NULL,
    note text NOT NULL,
    category character varying(50),
    related_company character varying(255),
    status character varying(20),
    week_start date,
    done boolean,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.weekly_notes OWNER TO hermes;

--
-- Name: weekly_notes_id_seq; Type: SEQUENCE; Schema: public; Owner: hermes
--

CREATE SEQUENCE public.weekly_notes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.weekly_notes_id_seq OWNER TO hermes;

--
-- Name: weekly_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hermes
--

ALTER SEQUENCE public.weekly_notes_id_seq OWNED BY public.weekly_notes.id;


--
-- Name: weekly_tasks; Type: TABLE; Schema: public; Owner: hermes
--

CREATE TABLE public.weekly_tasks (
    id integer NOT NULL,
    title character varying(500) NOT NULL,
    description text,
    category character varying(50),
    related_company character varying(255),
    outcome text,
    priority character varying(20),
    assignee character varying(50),
    status character varying(20),
    week_start date,
    done boolean,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    prospect_id integer
);


ALTER TABLE public.weekly_tasks OWNER TO hermes;

--
-- Name: weekly_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: hermes
--

CREATE SEQUENCE public.weekly_tasks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.weekly_tasks_id_seq OWNER TO hermes;

--
-- Name: weekly_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hermes
--

ALTER SEQUENCE public.weekly_tasks_id_seq OWNED BY public.weekly_tasks.id;


--
-- Name: documents id; Type: DEFAULT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.documents ALTER COLUMN id SET DEFAULT nextval('public.documents_id_seq'::regclass);


--
-- Name: exhibition_companies id; Type: DEFAULT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.exhibition_companies ALTER COLUMN id SET DEFAULT nextval('public.exhibition_companies_id_seq'::regclass);


--
-- Name: exhibitions id; Type: DEFAULT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.exhibitions ALTER COLUMN id SET DEFAULT nextval('public.exhibitions_id_seq'::regclass);


--
-- Name: investors id; Type: DEFAULT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.investors ALTER COLUMN id SET DEFAULT nextval('public.investors_id_seq'::regclass);


--
-- Name: learning id; Type: DEFAULT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.learning ALTER COLUMN id SET DEFAULT nextval('public.learning_id_seq'::regclass);


--
-- Name: meeting_preps id; Type: DEFAULT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.meeting_preps ALTER COLUMN id SET DEFAULT nextval('public.meeting_preps_id_seq'::regclass);


--
-- Name: opportunities id; Type: DEFAULT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.opportunities ALTER COLUMN id SET DEFAULT nextval('public.opportunities_id_seq'::regclass);


--
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);


--
-- Name: prospects id; Type: DEFAULT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.prospects ALTER COLUMN id SET DEFAULT nextval('public.prospects_id_seq'::regclass);


--
-- Name: scouting id; Type: DEFAULT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.scouting ALTER COLUMN id SET DEFAULT nextval('public.scouting_id_seq'::regclass);


--
-- Name: task_suggestions id; Type: DEFAULT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.task_suggestions ALTER COLUMN id SET DEFAULT nextval('public.task_suggestions_id_seq'::regclass);


--
-- Name: templates id; Type: DEFAULT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.templates ALTER COLUMN id SET DEFAULT nextval('public.templates_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: weekly_notes id; Type: DEFAULT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.weekly_notes ALTER COLUMN id SET DEFAULT nextval('public.weekly_notes_id_seq'::regclass);


--
-- Name: weekly_tasks id; Type: DEFAULT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.weekly_tasks ALTER COLUMN id SET DEFAULT nextval('public.weekly_tasks_id_seq'::regclass);


--
-- Data for Name: documents; Type: TABLE DATA; Schema: public; Owner: hermes
--

COPY public.documents (id, prospect_id, name, url, doc_type, created_at, investor_id) FROM stdin;
1	90	NDA 8p2 Advisory signe	https://drive.google.com/file/d/1BmdcQg_4eAOtDAU7NDbj6J4SVnxzvcYr/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	\N
2	90	8p2 Advisory 	https://drive.google.com/file/d/14sZTq1OKfBZG7-CEiEmhQz-mCETXWQ8b/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	\N
3	105	BADR EDDINE EL BACHAR_EIR_NDA	https://drive.google.com/file/d/1jQeRyT-n7iHauXcWgu3PC-ynfDGpgzqK/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	\N
4	23	Sunmind	https://drive.google.com/file/d/1gv_Cn76jqmj091yeUyBXMNeL5dzk3dBI/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	\N
7	31	ENR_COURTAGE 	https://drive.google.com/file/d/1A-HfE7yNDZUFxnQe1Rz_scBKv0AJ6GMW/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	\N
8	1	Valeco	https://drive.google.com/file/d/1klJg-n0zyGMzC_6SOZoYjoygcdJUFXQG/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	\N
9	50	ADEN	https://drive.google.com/file/d/1Rf-rtSZx3XlBNu3J2M5MbojcmTtVBeNO/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	\N
10	98	Margaret	https://drive.google.com/drive/folders/1FaYmcbDC3w6twpw0Hu3d6vrLxRvCSE_w	nda	2026-06-15 20:25:04.001392	\N
12	104	Terravastus Infrastructures	https://drive.google.com/file/d/1wP5cAEPa5WpUG5YvQ-AM0BJ2m413NCS6/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	\N
13	80	Becquerelinstitute	https://drive.google.com/file/d/1e4FoLlO_oNRUnXjARWY5WHwNtyYBT6v-/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	\N
14	63	Kiwi_Energies	https://drive.google.com/file/d/1w2FVGBD12WaEtpT6dWFGQLdAqRM6lk5K/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	\N
15	21	Calycé	https://drive.google.com/file/d/17fk_ooQtjHTZfWHcJv-xEsOUw5ZQorIV/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	\N
16	17	ENERTRAG SE	https://drive.google.com/file/d/1uiAdMSihDwVY4RDRGuD6UUyeznf5XP9g/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	\N
17	33	Everwatt	https://drive.google.com/file/d/1RLw_8mFCY1M-EOOwcIYM8-9kQzIW2jBP/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	\N
18	26	H2Watt	https://drive.google.com/file/d/1RiuB2EjgX_LScW4sF1rnRoRcPqAi_nU7/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	\N
19	103	Inersys	https://drive.google.com/file/d/1VMC7Pp5qbSQbKxCrARzsnd0EoiwNkaAx/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	\N
20	2	JC_Mont_Fort	https://drive.google.com/file/d/1FinYVu6WwVYXOpbVeeanoq-rpzZD-mDH/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	\N
21	39	Menapy	https://drive.google.com/file/d/1yEJbYNj9yQkgfzAQR5iLbBIixooW3276/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	\N
22	63	ENECHANGE_NDA	https://drive.google.com/file/d/1U3AGYkV4sC8Z5dCuHV9tMyTaQsvqPxWt/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	\N
23	17	ENERTRAG SE	https://drive.google.com/file/d/1Co_XXdakRrV3miwosktEuVQXaH0i4vLM/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	\N
24	63	Renergies	https://drive.google.com/file/d/1cPe6Y6NP9cGafVsBrNrFaesnI26FCG1_/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	\N
26	11	TCO	https://drive.google.com/file/d/105LPvALEw6p1NitnXq18CqJkg02jcQXU/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	\N
27	24	AgrisolarPV	https://drive.google.com/file/d/1iF8QWD1FVCqzTg1uOIh96L6PaSmgwjS8/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	\N
28	31	ENR_COURTAGE	https://drive.google.com/file/d/1YvA2p5-S6pdSm_izUYwq20gdtADUzO2B/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	\N
30	63	Agritech	https://drive.google.com/file/d/1LHHMiaG35geBMZkobhtc0qyI3njFpi3H/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	\N
31	38	ASDEV	https://drive.google.com/file/d/1Z19qSRV2c0-QmHWddV9IS4KUnYvb06Bs/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	\N
32	113	Ecolinks	https://drive.google.com/file/d/1gISXmQq0V3r-GnTwSh9ffwlcffQdKip7/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	\N
33	85	EIR-LaurentCligny-fee-agreement-draft	https://drive.google.com/file/d/10Ea0JzTU6VyX3mI1H37dK4OTnA8TOCAi/view?usp=drivesdk	fee_agreement	2026-06-15 20:25:04.001392	\N
34	113	Ecolinks_ENECHANGE_NDA	https://drive.google.com/file/d/1coDUC9h9y5W-vHgTWY3SDgFoi_HUHAYS/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	\N
35	7	VIRIDI_EIR_NDA	https://drive.google.com/file/d/166jPLHexsphfqYYaRJvCFrGTL7VH7VjS/view?usp=drivesdk	nda	2026-06-15 20:25:37.968121	\N
36	23	Vinci_NDA	https://drive.google.com/file/d/1Csgh7z3hQaUMFwACARgPOTuRGrOrmKEt/view?usp=drivesdk	nda	2026-06-15 20:25:37.968121	\N
37	23	EIR-Vinci-fee-agreement-draft	https://drive.google.com/file/d/1QMZKh9Xyz_OSdGUf8D-ulD8U9iNGBYqv/view?usp=drivesdk	fee_agreement	2026-06-15 20:25:37.968121	\N
38	\N	Electron_Green	https://drive.google.com/file/d/1G5PcswT2uR79paBbNajMFt5HG5GNJ4RF/view?usp=drivesdk	nda	2026-06-15 20:30:22.728469	8
39	\N	Electron Green_agreement	https://drive.google.com/file/d/1r4eipvVsRb4vfp2jFX9AC9wRlfJgpHFB/view?usp=drivesdk	fee_agreement	2026-06-15 20:30:22.728469	8
40	\N	EIR-ElectronGreen-fee-agreement-draft (1)	https://drive.google.com/file/d/18UOwmK82ZD1meQbz7BhU93rngPMY5kMS/view?usp=drivesdk	fee_agreement	2026-06-15 20:30:22.728469	8
41	\N	REGENERASUN	https://drive.google.com/file/d/1cxCyss32B0shk0WiLSgHH_Nd6KjzIN9h/view?usp=drivesdk	nda	2026-06-15 20:30:22.728469	18
42	\N	Regenerasun	https://drive.google.com/file/d/1VhQUnunsbXCLZBmGgC0MAauy4l0Lw8ZL/view?usp=drivesdk	nda	2026-06-15 20:30:22.728469	18
11	6	SDESM_Energies	https://drive.google.com/file/d/1k73jmitZVXD8VY4jz3v6qtEhWuBceJJQ/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	14
29	22	FARADAE	https://drive.google.com/file/d/1eld5J9MeALGnd2i9OjKESZ3bg3r6lua8/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	4
25	67	Photosol	https://drive.google.com/file/d/1KNIgn8Q0tMPTjUL9z_hd4TW83qdKQzA4/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	7
6	99	EIR-Enervivo-France-fee-agreement-draft	https://drive.google.com/file/d/10t-6-4aXKZ-PUYnWwtHQNhG-NbptGhBx/view?usp=drivesdk	fee_agreement	2026-06-15 20:25:04.001392	16
5	99	Enervivo	https://drive.google.com/file/d/1nGTV26ZjZXjCuhDqA5Xb_4r75kuyjpQn/view?usp=drivesdk	nda	2026-06-15 20:25:04.001392	16
43	99	Enervivo_Shamsiyah_Pitch_Deck_Investisseurs V2	https://drive.google.com/file/d/17GgetM9VoxwtHk6m9-Eq72Vrcs0iWCW3/view?usp=drivesdk	presentation	2026-06-15 20:48:27.418907	16
44	99	Enervivo - Teaser	https://drive.google.com/file/d/1nGTV26ZjZXjCuhDqA5Xb_4r75kuyjpQn/view?usp=drivesdk	teaser	2026-06-15 20:48:27.839153	16
45	99	Enervivo - FR Development Insights Final	https://drive.google.com/file/d/1Jl2xo0o0Oiw9aIdestWORFu31Lbslnpl/view?usp=drivesdk	presentation	2026-06-15 20:48:27.888289	16
46	85	EIR-LaurentCligny-fee-agreement-signed	https://drive.google.com/file/d/1aWtzmJTKJFnO-m9IBZeJnmF5_P9ATVJX/view	fee_agreement	2026-06-15 20:57:58.880315	\N
47	85	Compte rendu - Laurent Cligny 11/06/2026	https://docs.google.com/document/d/18os2ST2VYZ_9LcCBP1T_VBlFidvKquZp88NjytE3238/edit	compte_rendu	2026-06-15 20:57:58.987822	\N
48	85	Compte rendu - Laurent Cligny 30/01/2026	https://docs.google.com/document/d/1EmVubj8-ZhYcDfPdvNgJg046EGxuuFK5BqwX_TisU9c/edit	compte_rendu	2026-06-15 20:57:59.085516	\N
49	22	EIR-Faradae-fee-agreement-draft	https://drive.google.com/file/d/1YNHFdqR9_oVZl5C8Zx8TKgAYYAT2cGiI/view	fee_agreement	2026-06-15 20:57:59.157664	\N
50	22	Minutes 2 Faradae 21-11-2024	https://drive.google.com/file/d/1cQR18gbvqngJ1q0BU7USP7SrMpdAHpq8/view	compte_rendu	2026-06-15 20:57:59.297601	\N
51	67	EIR-Photosol-fee-agreement-draft	https://drive.google.com/file/d/15FvdEPIutqWGKQqr-PuzOEsMwMhs6O2C/view	fee_agreement	2026-06-15 20:57:59.366224	\N
54	7	IM Projets VIF - Viridi 18/02/2026	https://drive.google.com/file/d/1TV8gk_0r19UA8GJC99nHtPN5kq1nDETz/view	presentation	2026-06-15 20:57:59.667483	\N
52	15	Recurrent-Energy-France NDA (signé 02/02/2026)	https://drive.google.com/file/d/1WeeFFJGCd4BaxH5O55jE6E9dVqLTm6xs/view	nda	2026-06-15 20:57:59.443196	\N
55	1	Teaser Argillières - Valeco	https://drive.google.com/file/d/1ArkXa6hjK7Nm0IcE7A6-xAkLsO_-YOwY/view	teaser	2026-06-15 20:58:00.25003	\N
58	10	Presentation Groupe Solges ENECHANGE 2026.01.15	https://drive.google.com/file/d/1zt8CYz25x2Jxf9-op3GGvJbFpW_fGOOH/view	presentation	2026-06-15 20:58:01.163851	\N
53	15	Project Horizon Info Memorandum - Recurrent Energy France	https://drive.google.com/file/d/10s3EBAmBOhx_pUL4XNymL4_1eA5Z8poz/view	other	2026-06-15 20:57:59.559639	\N
56	89	PITCH-DECK ACQUISITION ASSETS - Ademola	https://drive.google.com/file/d/1nMvpdKuWqtxka6fCxZUXE0GxKS0IIo4W/view	presentation	2026-06-15 20:58:00.980653	\N
59	50	Portfolio ADEN - Présentation 02/2026	https://drive.google.com/file/d/12D2BU93QxTQqIQbw0dwgblg3smy9-wjk/view	presentation	2026-06-15 20:58:01.282292	\N
57	96	TEASER portefeuille solaire Plenitude	https://drive.google.com/file/d/1VRbpTDyKUMxIVvping2G7uT_CGtxJsyB/view	teaser	2026-06-15 20:58:01.077814	\N
61	3	CR EIR x Qenergy - 13/05/2026 (FR)	https://docs.google.com/document/d/1z__OoHL6LPDQ2ODPG3Owvtv6ubELSdiNRko0JmprZkY/edit	compte_rendu	2026-06-15 21:01:21.730588	\N
62	31	CR EIR x ENR Courtage - 08/05/2026	https://docs.google.com/document/d/1ajlo4JG7ZJGA8Oj5fThl87L7MY-O9AhuD3uOac1dUAc/edit	compte_rendu	2026-06-15 21:01:22.097012	\N
63	97	CR Follow-up Renergies - 23/03/2026	https://docs.google.com/document/d/13MNh7-hMpr6giwyuBvCySc95OdhRevojQi5HcD_JHG8/edit	compte_rendu	2026-06-15 21:01:23.320359	\N
64	8	CR Follow-up Stephane Gilli - 23/03/2026	https://docs.google.com/document/d/1zqgoiB6dQPfqm0y9AZFUMwImbRy04nvT6DzttNHWo9g/edit	compte_rendu	2026-06-15 21:01:23.548578	\N
65	8	CR Follow-up Stephane Gilli - 20/03/2026	https://docs.google.com/document/d/1vjzBrL4M_78MdMQYCtC1BunZk8WyTzr9dSzkE_AoJc8/edit	compte_rendu	2026-06-15 21:01:23.75049	\N
66	70	CR EIR x Voltalia - 13/03/2026 (FR)	https://docs.google.com/document/d/10htef95LCM45k5s599BFhvlzI5Bbd7ip70mXNs_SmP8/edit	compte_rendu	2026-06-15 21:01:23.873751	\N
67	2	CR Follow-up ECodd - 29/01/2026	https://docs.google.com/document/d/16nJZdrmoW6W2QyU1hqIgpHjKXSeeRgH8mRGWXF22QoA/edit	compte_rendu	2026-06-15 21:01:23.944305	\N
68	2	CR Ecodd / Enrocks - Introduction 04/02/2026	https://docs.google.com/document/d/1X6cbwFmClU2witdz-Gm0dcwoaLoFhxSqYZuMXA3AG30/edit	compte_rendu	2026-06-15 21:01:24.183506	\N
69	7	CR Follow-up Viridi RE - 14/01/2026	https://docs.google.com/document/d/1_Ehvg4pVx0-N_ZBcaNDIoXw-qaUdFuoTuWLxbFCZpo4/edit	compte_rendu	2026-06-15 21:01:25.21732	\N
70	17	CR Follow-up Enertrag x EIR - 21/01/2026	https://docs.google.com/document/d/1V5cnE7JEKo-DqCWJgULq9viylwO7fscdKGcWDC50EdM/edit	compte_rendu	2026-06-15 21:01:25.641701	\N
71	15	CR Follow-up Recurrent Energy - 03/02/2026	https://docs.google.com/document/d/1sWF-kti9mULSa05sShiAxEe8H24ViZuQbd9le8w36z0/edit	compte_rendu	2026-06-15 21:01:25.805829	\N
72	90	CR 8p2 x EIR Introductory Meeting - 13/01/2026	https://docs.google.com/document/d/1zX739Uper_WjS6Br7eCzJcU9q-p-GUhL3duQJL6qwrg/edit	compte_rendu	2026-06-15 21:01:26.309422	\N
73	32	CR Gaëtan Gohin - 13/01/2026	https://docs.google.com/document/d/1s5zakMq826AQtYo_d9ngsy5E_dpcgzsX2fcO6eet6n0/edit	compte_rendu	2026-06-15 21:01:26.602264	\N
74	11	CR TCO Solar ENR - 05/12/2025	https://docs.google.com/document/d/1XS0TU0Ncm8_xvkDizKhcrPA5k01U0a55wvShG1sUex8/edit	compte_rendu	2026-06-15 21:01:26.842707	\N
75	14	CR EIR x Valorem Energy - 11/05/2026 (FR)	https://docs.google.com/document/d/1GOc7tQbVobVWNo0n1b4LeNS3lTLfIl6o0DVNq30E-oQ/edit	compte_rendu	2026-06-15 21:01:27.73969	\N
76	102	CR Nicolas GENTE (Avergies) - 22/04/2026 (FR)	https://docs.google.com/document/d/1uv7vaFCcy3tjpqO6Wx-jLQ23s8Bvr5mCTVN04wq1ayM/edit	compte_rendu	2026-06-15 21:01:28.505087	\N
77	101	CR Sophie Demartini - 01/04/2026 (FR)	https://docs.google.com/document/d/1qUaJBc0VeiEkUO79oSofaYpof5M7tguJa4lklf2txfM/edit	compte_rendu	2026-06-15 21:01:28.667139	\N
78	50	CR Aden x ENECHANGE - 23/02/2026	https://docs.google.com/document/d/1mGspCRGtWsRRcDXuXW8ZpIvHbdeOf0uupNeLniXEZdM/edit	compte_rendu	2026-06-15 21:01:29.940194	\N
79	10	CR Enrocks x Solgés Energy - Introduction 03/02/2026	https://docs.google.com/document/d/1g337CQgQ3sF1rxHLXmJ3dggmNEJKPalz7mIN84JvFQg/edit	compte_rendu	2026-06-15 21:01:30.44317	\N
80	92	CR RES Groupe - 30/01/2026	https://docs.google.com/document/d/1fzrX2PCG-RBZ2Jd2dJeC5fXkax2-nMkazl7ZJTHPYps/edit	compte_rendu	2026-06-15 21:01:30.777636	\N
81	\N	CR David LEBRET (Regenerasun) - 21/05/2026 (FR)	https://docs.google.com/document/d/1iCFAkp_HvOiQGWAtvhjBpwzdj0WY72ijhVHgP8qpMVo/edit	compte_rendu	2026-06-15 21:06:08.202875	18
82	\N	CR Electron Green x EIR - 23/02/2026	https://docs.google.com/document/d/1DOEYCpbvcRvsJxafVDjJk1mYN5KboxHvv1-gEZnYo8I/edit	compte_rendu	2026-06-15 21:06:08.322657	8
83	67	CR Serge Barge (Photosol) - 13/11/2025	https://docs.google.com/document/d/1P0CAdNXOb0rTyBeAQO1hpvviY-DefB57axjx4NLGTHk/edit	compte_rendu	2026-06-15 21:06:08.530416	7
84	90	NDA signé	https://drive.google.com/file/d/1BmdcQg_4eAOtDAU7NDbj6J4SVnxzvcYr/view	nda	2026-06-15 22:10:22.759128	\N
85	90	8p2 Advisory	https://drive.google.com/file/d/14sZTq1OKfBZG7-CEiEmhQz-mCETXWQ8b/view	other	2026-06-15 22:10:22.776591	\N
86	50	ADEN.pdf	https://drive.google.com/file/d/1Rf-rtSZx3XlBNu3J2M5MbojcmTtVBeNO/view	other	2026-06-15 22:10:22.794207	\N
87	50	Présentation portfolio	https://drive.google.com/file/d/12D2BU93QxTQqIQbw0dwgblg3smy9-wjk/view	other	2026-06-15 22:10:22.796231	\N
88	50	Database FR (mensuel x6)	https://drive.google.com/file/d/1YJBpLlM2kR2xdxcGqJJ53oyxanNLRCOP_w8b7BCV7sI/view	other	2026-06-15 22:10:22.802402	\N
89	111	AgrisolarPV.pdf	https://drive.google.com/file/d/1iF8QWD1FVCqzTg1uOIh96L6PaSmgwjS8/view	other	2026-06-15 22:10:22.811615	\N
90	18	EIR Projects Portfolio France	https://drive.google.com/file/d/1hLiZCL2K0q0ssqREpitmM_znX43PTdNRg68wqbrZrI4/view	other	2026-06-15 22:10:22.814533	\N
91	18	EIR-Altarea Tester	https://drive.google.com/file/d/1IpfjjAwNDhokltKOpSCxlX8zoPXhnGiG/view	other	2026-06-15 22:10:22.819923	\N
92	105	NDA signé	https://drive.google.com/file/d/1jQeRyT-n7iHauXcWgu3PC-ynfDGpgzqK/view	nda	2026-06-15 22:10:22.823063	\N
94	2	Notes follow-up (Gemini)	https://drive.google.com/file/d/16nJZdrmoW6W2QyU1hqIgpHjKXSeeRgH8mRGWXF22QoA/view	other	2026-06-15 22:10:22.831525	\N
95	2	Database FR (mensuel)	https://drive.google.com/file/d/1LPc0EPZENkWyNKNG9e3YFoaT1-cBx8AyOjYC7HJLgoA/view	other	2026-06-15 22:10:22.846903	\N
96	113	NDA signé	https://drive.google.com/file/d/1aLaR2yC9Fqy3PZvakVOVDl7puIwOi6AW/view	nda	2026-06-15 22:10:22.855659	\N
97	113	Ecolinks.pdf	https://drive.google.com/file/d/1gISXmQq0V3r-GnTwSh9ffwlcffQdKip7/view	other	2026-06-15 22:10:22.857873	\N
98	99	Enervivo.pdf	https://drive.google.com/file/d/1nGTV26ZjZXjCuhDqA5Xb_4r75kuyjpQn/view	other	2026-06-15 22:10:22.864137	\N
99	99	Enervivo - Database FR	https://drive.google.com/file/d/1QRNgg_amdfZOIx4IJsrhTez6HdOlMhwQfJ4QVCEjFKA/view	other	2026-06-15 22:10:22.866001	\N
100	99	FR Development Insights	https://drive.google.com/file/d/1QYvMOcVREWwuo2lqyWwImQUwXcW-Tuxe1BCGqS2ljhU/view	other	2026-06-15 22:10:22.871845	\N
101	99	Pitch Deck Investisseurs	https://drive.google.com/file/d/17GgetM9VoxwtHk6m9-Eq72Vrcs0iWCW3/view	presentation	2026-06-15 22:10:22.873758	\N
102	99	Info Memo MoreGreen	https://drive.google.com/file/d/1RFpTxePf4WrTeSBu8Xu23g9QxIBTouLn/view	other	2026-06-15 22:10:22.880837	\N
103	99	Fee agreement draft	https://drive.google.com/file/d/10t-6-4aXKZ-PUYnWwtHQNhG-NbptGhBx/view	fee_agreement	2026-06-15 22:10:22.882808	\N
104	17	NDA @Soumu	https://drive.google.com/file/d/1Ype2HlJtnNGQuEHa2e_vbX93j9KmtlTN/view	nda	2026-06-15 22:10:22.88498	\N
105	17	ENERTRAG SE.pdf	https://drive.google.com/file/d/1uiAdMSihDwVY4RDRGuD6UUyeznf5XP9g/view	other	2026-06-15 22:10:22.886282	\N
106	\N	FR Development Insights	https://drive.google.com/file/d/1vbS3UPFQG2GoP0BGmy0Eg4WIPZ8bb-d8afJU97V6c-k/view	other	2026-06-15 22:10:22.91087	5
107	\N	FR Development Insights - final	https://drive.google.com/file/d/1c0_1nINfYnnQbWnesKvMOiNdEVlJ_rHZsz73yNWDPIU/view	other	2026-06-15 22:10:22.920394	5
108	31	NDA signé	https://drive.google.com/file/d/1tAwqasVxNt1MEKW2ZC_jL3bx-f3Ik5K6/view	nda	2026-06-15 22:10:22.928759	\N
109	33	Everwatt.pdf	https://drive.google.com/file/d/1RLw_8mFCY1M-EOOwcIYM8-9kQzIW2jBP/view	other	2026-06-15 22:10:22.938176	\N
110	33	NDA signé	https://drive.google.com/file/d/1wfDfqTzTwQmj7mqd_KHqJc7ye8mfLAhN/view	nda	2026-06-15 22:10:22.940096	\N
111	22	FARADAE.pdf	https://drive.google.com/file/d/1eld5J9MeALGnd2i9OjKESZ3bg3r6lua8/view	other	2026-06-15 22:10:22.947804	\N
112	22	EIR-Faradae Tester	https://drive.google.com/file/d/1iYiBQJ17mJVDhAsypp7AhOhr5jqGM-zJaNUH7AxxwrU/view	other	2026-06-15 22:10:22.950444	\N
113	22	Fee agreement draft	https://drive.google.com/file/d/1YNHFdqR9_oVZl5C8Zx8TKgAYYAT2cGiI/view	fee_agreement	2026-06-15 22:10:22.956816	\N
114	26	H2Watt.pdf	https://drive.google.com/file/d/1RiuB2EjgX_LScW4sF1rnRoRcPqAi_nU7/view	other	2026-06-15 22:10:22.962334	\N
115	26	NDA signé	https://drive.google.com/file/d/1p6sX4F0igW4IIhIPVJ_Usp3hVHaa8Efy/view	nda	2026-06-15 22:10:22.965342	\N
116	86	Proposition Holosolis × EIR	https://drive.google.com/file/d/1qoIeatAsg5nhvmwVNQtg8btfK_diN_ERDQ-QHqGv9-U/view	other	2026-06-15 22:10:22.973767	\N
117	85	NDA signé ✅	https://drive.google.com/file/d/1G5PcswT2uR79paBbNajMFt5HG5GNJ4RF/view	nda	2026-06-15 22:10:23.018833	\N
118	85	Fee agreement draft	https://drive.google.com/file/d/10Ea0JzTU6VyX3mI1H37dK4OTnA8TOCAi/view	fee_agreement	2026-06-15 22:10:23.025015	\N
119	85	Fee agreement signé ✅	https://drive.google.com/file/d/1aWtzmJTKJFnO-m9IBZeJnmF5_P9ATVJX/view	fee_agreement	2026-06-15 22:10:23.026788	\N
120	39	Menapy.pdf	https://drive.google.com/file/d/1yEJbYNj9yQkgfzAQR5iLbBIixooW3276/view	other	2026-06-15 22:10:23.037783	\N
121	9	Projets permités	https://drive.google.com/file/d/1lvr9DT6N-N0JZf9ZzQQnpn5jpGUt2vg8/view	other	2026-06-15 22:10:23.048503	\N
122	9	Database FR (mensuel)	https://drive.google.com/file/d/1LPc0EPZENkWyNKNG9e3YFoaT1-cBx8AyOjYC7HJLgoA/view	other	2026-06-15 22:10:23.051326	\N
123	45	NDA signé	https://drive.google.com/file/d/1torZf_4_wjKCdA9Xy-40XsGhG9bvNH8q/view	nda	2026-06-15 22:10:23.053595	\N
124	67	Photosol.pdf	https://drive.google.com/file/d/1KNIgn8Q0tMPTjUL9z_hd4TW83qdKQzA4/view	other	2026-06-15 22:10:23.060337	\N
125	67	NDA signé ✅	https://drive.google.com/file/d/1CMDCZUf8q9JgrB7yVzTgL6yJOaYhDacA/view	nda	2026-06-15 22:10:23.063034	\N
126	67	Fee agreement draft	https://drive.google.com/file/d/15FvdEPIutqWGKQqr-PuzOEsMwMhs6O2C/view	fee_agreement	2026-06-15 22:10:23.065767	\N
127	67	Tester Italy	https://drive.google.com/file/d/1Emu5eB-VblH4I3ZJZN0ie0c9_t9WHsMZ/view	other	2026-06-15 22:10:23.068793	\N
128	67	Tester Italy - Final	https://drive.google.com/file/d/1KBNXuCfg-Vx8wrIOP1MJfH7UpJKZUUNj/view	other	2026-06-15 22:10:23.071646	\N
129	67	Scrap Italy Poland	https://drive.google.com/file/d/1zIuhS1zuJ6MbvxWTFONY746fVq4XwI4fj1g7c7hoPto/view	other	2026-06-15 22:10:23.07416	\N
130	67	Scrap Italy	https://drive.google.com/file/d/1jZTuRN4IQ_qiU6f6H6sshIQbm5UX3iemxK20Kh05oks/view	other	2026-06-15 22:10:23.077246	\N
131	96	Database FR	https://drive.google.com/file/d/1YBkJyWFIE_8bV2Y79UbRyHDNMYOuCqlNX8jyCGlUGK0/view	other	2026-06-15 22:10:23.081698	\N
132	96	Teaser portefeuille	https://drive.google.com/file/d/1VRbpTDyKUMxIVvping2G7uT_CGtxJsyB/view	teaser	2026-06-15 22:10:23.085034	\N
133	\N	Prosolia - Filtered out	https://drive.google.com/file/d/1Ms_DILlsrHCxgUAr7-3Uknp-ehRZXAKEuW04JADgRyQ/view	other	2026-06-15 22:10:23.091218	10
134	\N	Prosolia France - Filtered out	https://drive.google.com/file/d/1_vCnoNYRwPZgfIjjRIb4rNE4suOiK5lj9-Q5q4FQ4c4/view	other	2026-06-15 22:10:23.094756	10
135	\N	Prosolia France incomplete	https://drive.google.com/file/d/1Xwwrr7LiLN1eA9P1D_QLcq0fV1fn58SwqVYb8oJg368/view	other	2026-06-15 22:10:23.097802	10
136	15	NDA signé ✅	https://drive.google.com/file/d/1WYtTlHHiLwAiI95gQiadAxumjg9zFr3X/view	nda	2026-06-15 22:10:23.106302	\N
137	15	Info Memorandum	https://drive.google.com/file/d/10s3EBAmBOhx_pUL4XNymL4_1eA5Z8poz/view	other	2026-06-15 22:10:23.110254	\N
138	15	Database FR (mensuel)	https://drive.google.com/file/d/1YJBpLlM2kR2xdxcGqJJ53oyxanNLRCOP_w8b7BCV7sI/view	other	2026-06-15 22:10:23.113697	\N
139	97	Renergies.pdf	https://drive.google.com/file/d/1cPe6Y6NP9cGafVsBrNrFaesnI26FCG1_/view	other	2026-06-15 22:10:23.118222	\N
140	97	Projets FRANCE	https://drive.google.com/file/d/12j_7B6Urez2w585setv21eg0TN8fG1j0/view	other	2026-06-15 22:10:23.121058	\N
141	98	Database FR	https://drive.google.com/file/d/11EIyU70_PwD1vOpcIusvV0cc8hgG-NmHv_rjq0yFRXw/view	other	2026-06-15 22:10:23.125156	\N
142	98	Database FR (ENG)	https://drive.google.com/file/d/1MXfo7sZ7eIb8mDiDS-iZS_QU5HV7NYYlWzOeVWSxd-Q/view	other	2026-06-15 22:10:23.130896	\N
143	8	Notes follow-up (x2)	https://drive.google.com/file/d/1vjzBrL4M_78MdMQYCtC1BunZk8WyTzr9dSzkE_AoJc8/view	other	2026-06-15 22:10:23.136817	\N
144	8	MODELE AC NEA	https://drive.google.com/file/d/12z4qNeblysIQwkWmWdVaDbwFC316mZyy/view	other	2026-06-15 22:10:23.138101	\N
145	8	NDA Cevennes signé	https://drive.google.com/file/d/1rtbhtfzoGhJxtSUs3ZoGhAWrpaZIZyXi/view	nda	2026-06-15 22:10:23.139219	\N
146	8	Database FR	https://drive.google.com/file/d/1LPc0EPZENkWyNKNG9e3YFoaT1-cBx8AyOjYC7HJLgoA/view	other	2026-06-15 22:10:23.140261	\N
147	23	Sunmind.pdf	https://drive.google.com/file/d/1gv_Cn76jqmj091yeUyBXMNeL5dzk3dBI/view	other	2026-06-15 22:10:23.143411	\N
148	23	NDA ✅	https://drive.google.com/file/d/1i5Ux7P9vPaiHfiaQ8puh8x8__zyvMm9a/view	nda	2026-06-15 22:10:23.144582	\N
149	23	Tester	https://drive.google.com/file/d/1lTKrizNztT0csmT18llJ_RUtX6NSbNcC/view	other	2026-06-15 22:10:23.145804	\N
150	104	Terravastus Infrastructures.pdf	https://drive.google.com/file/d/1wP5cAEPa5WpUG5YvQ-AM0BJ2m413NCS6/view	other	2026-06-15 22:10:23.147493	\N
151	104	NDA signé	https://drive.google.com/file/d/1t3-B4U0AX8IwS9EmOqsFGTaz5p9ulU7p/view	nda	2026-06-15 22:10:23.148669	\N
152	104	CAPEX & OPEX 100MW	https://drive.google.com/file/d/1oyDqkb1tQuZweLytmhNDyRzfMg9jbbsl/view	other	2026-06-15 22:10:23.149878	\N
153	104	Nyakwere Solar PV	https://drive.google.com/file/d/1c5RzRp4EndpVrDZHwohXGfV11TzaxoiU/view	other	2026-06-15 22:10:23.150838	\N
154	1	Valeco.pdf	https://drive.google.com/file/d/1klJg-n0zyGMzC_6SOZoYjoygcdJUFXQG/view	other	2026-06-15 22:10:23.15226	\N
155	1	NDA Soumu	https://drive.google.com/file/d/1QlQzwZJYP9H8DUTBkOb2-AF432Wm_7Go/view	nda	2026-06-15 22:10:23.153198	\N
156	1	Teaser Argillières	https://drive.google.com/file/d/1ArkXa6hjK7Nm0IcE7A6-xAkLsO_-YOwY/view	teaser	2026-06-15 22:10:23.154309	\N
157	1	Database FR (mensuel)	https://drive.google.com/file/d/1LPc0EPZENkWyNKNG9e3YFoaT1-cBx8AyOjYC7HJLgoA/view	other	2026-06-15 22:10:23.155253	\N
158	14	Draft tester	https://drive.google.com/file/d/1hmhAVL-e4k-rXtbmYCoCEQX445ewlLZsNtGLv2Ux6pE/view	other	2026-06-15 22:10:23.156637	\N
159	7	NDA signé ✅	https://drive.google.com/file/d/166jPLHexsphfqYYaRJvCFrGTL7VH7VjS/view	nda	2026-06-15 22:10:23.157965	\N
160	7	Info Mémo Projets	https://drive.google.com/file/d/1TV8gk_0r19UA8GJC99nHtPN5kq1nDETz/view	other	2026-06-15 22:10:23.159166	\N
161	7	Database FR (mensuel)	https://drive.google.com/file/d/1YJBpLlM2kR2xdxcGqJJ53oyxanNLRCOP_w8b7BCV7sI/view	other	2026-06-15 22:10:23.160084	\N
162	\N	FINAL WSKW	https://drive.google.com/file/d/1tpVw_5B5E4sAEqUIyajm_DLvl0rCBqzrKy0nWeaIK9I/view	other	2026-06-15 22:10:23.162537	13
163	\N	WSKW filtered out	https://drive.google.com/file/d/1q78cmXhMt6cxBBQUAHcVwG2771FgCj96xweyCIfSUG0/view	other	2026-06-15 22:10:23.163583	13
164	\N	Italian Projects	https://drive.google.com/file/d/1i4spIMUbEQAkWkfffwHSFAP2smyO7E1k/view	other	2026-06-15 22:10:23.16448	13
165	\N	WSKW fr incomplete	https://drive.google.com/file/d/1lPIUgjrgez4uJ64dSPO0lCLLaUFzo5Fn-TdXOGyeMRw/view	other	2026-06-15 22:10:23.165482	13
166	21	NDA	https://drive.google.com/file/d/17fk_ooQtjHTZfWHcJv-xEsOUw5ZQorIV/view	nda	2026-06-15 22:10:23.166883	\N
167	103	NDA	https://drive.google.com/file/d/1VMC7Pp5qbSQbKxCrARzsnd0EoiwNkaAx/view	nda	2026-06-15 22:10:23.168512	\N
168	11	NDA TCO Solar	https://drive.google.com/file/d/105LPvALEw6p1NitnXq18CqJkg02jcQXU/view	nda	2026-06-15 22:10:23.170051	\N
169	6	NDA SDESM	https://drive.google.com/file/d/1k73jmitZVXD8VY4jz3v6qtEhWuBceJJQ/view	nda	2026-06-15 22:10:23.171454	\N
170	\N	NDA Standard EIR	https://drive.google.com/drive/folders/1Ul59d8EENfg8Dl8PVdYrXzRP1wKJpYxM	nda	2026-06-17 13:16:39.744245	\N
171	\N	Presentation EIR (Plateforme)	https://docs.google.com/presentation/d/1snx8vpIHipoZuw-fLLUiNQ2mRQyHehHgdj4Jjxvgyys/edit	presentation	2026-06-17 13:16:39.744245	\N
172	\N	Modele Fee-Sharing EIR	https://docs.google.com/spreadsheets/d/1ZsFcbzY8xIqqmp9OeARIkIqy-2oobQzxXbxn4tHYPQE/edit	fee_agreement	2026-06-17 13:16:39.744245	\N
173	\N	Presentations EIR	https://1drv.ms/f/c/9343c73c7771b285/IgCFsnF3PMdDIICT_30BAAAAAQUoKwdENaUAsNHkGqi5kvU?e=3pbynw	presentation	2026-06-17 16:53:39.88568	\N
174	\N	NDA Standard EIR	https://1drv.ms/f/c/9343c73c7771b285/IgDtbKmmaNc_QYqd1IDmZg6YAdFXp7qs1KbCbXptfwYBEeU?e=ZQChjC	nda	2026-06-17 16:54:44.592057	\N
175	\N	Projets Toiture (10 projets)	https://docs.google.com/spreadsheets/d/1f1CYFkgIaXUcpVaybXTTxeNnDX9abnhs/edit?usp=drivesdk&ouid=104293679809544745310&rtpof=true&sd=true	other	2026-06-17 19:52:30.019183	\N
176	\N	Méthodologie des stages de développement solaire	/docs/stages-methodology.md	methodology	2026-06-18 02:31:31.101351	\N
177	8	Mairie de Montfrin - 200 kWc	https://docs.google.com/presentation/d/18cQ_KILSI26t8R4OUzNCAW9U5XV42lyK/edit	teaser	2026-06-22 10:18:42.548423	\N
178	8	Mairie de Fitou - 1.07 MWc	https://docs.google.com/presentation/d/1nSuwW3knhyUPQQdyqd2WKVsNSHkTeg8y/edit	teaser	2026-06-22 10:18:42.548423	\N
179	8	Cave de Nébian - 500 kWc	https://docs.google.com/presentation/d/1sSyw7ldd9UKxYLMqJ73rLJbXGfPo7pjd/edit	teaser	2026-06-22 10:18:42.548423	\N
180	113	Projet Eau Rwanda	https://drive.google.com/file/d/1J4MR99D0LQRsZCiHC0C11OfHb3pvVPzH/view	presentation	2026-06-22 17:01:10.37847	\N
\.


--
-- Data for Name: exhibition_companies; Type: TABLE DATA; Schema: public; Owner: hermes
--

COPY public.exhibition_companies (id, exhibition_id, name, type, country, stand, contact_name, contact_email, status, notes_fr, created_at, notes_en) FROM stdin;
11	1	CYCAP	Investor	Germany	\N	Midhun Tom Jose / Henrik Harms	tomjose@cycap.com / henrik.harms@cycap.com	to_contact	Midhun Tom Jose - Investment Manager - Tel: +49 40 688788-148 - Mobile: +49 171 5455379\nHenrik Harms - Investment Analyst - Tel: +49 40 688788-60 - Mobile: +49 151 67532848\nAdresse: Speersort 10, 20095 Hamburg, Germany - Web: cycap.com\nCartes reçues via un contact chinois rencontré sur le salon. Intersolar Munich, 23/06/2026.	2026-06-23 23:49:28.488647+02	Midhun Tom Jose - Investment Manager - Tel: +49 40 688788-148 - Mobile: +49 171 5455379\nHenrik Harms - Investment Analyst - Tel: +49 40 688788-60 - Mobile: +49 151 67532848\nAddress: Speersort 10, 20095 Hamburg, Germany - Web: cycap.com\nCards received via a Chinese contact met at the exhibition. Intersolar Munich, 23/06/2026.
12	1	3SUN Srl (Enel Group)	Manufacturer	Italy	\N	Giovanni Damiano D'Urso	giovanni.durso@enel.com	to_contact	Giovanni Damiano D'Urso - Business Development Manager\nAdresse: Cda. Blocco Torrazze, 95121, CT, Italie\nMobile: +39 329 969 4046 - Web: 3sun.com\nPossibilité d'investissement dans leurs modules pour passer de Tier 2 à Tier 1.\nIntersolar Munich, 23/06/2026.	2026-06-23 23:51:37.182693+02	Giovanni Damiano D'Urso - Business Development Manager\nAddress: Cda. Blocco Torrazze, 95121, CT, Italy\nMobile: +39 329 969 4046 - Web: 3sun.com\nPossibility to invest in their modules to move from Tier 2 to Tier 1.\nIntersolar Munich, 23/06/2026.
13	1	BEC-Energie Consult GmbH	Developer	Germany	\N	Dr. Andreas Brockmoller	brockmoeller@bec-berlin.de	to_contact	Dr. Andreas Brockmoller - Geschäftsführer (CEO)\nAdresse: Astemplatz 3, 12203 Berlin\nTél: +49 (030) 61 65 76 - 0 - Fax: +49 (030) 61 65 76 - 33 - Mobile: +49 (0173) 61 63 35 7\nIntersolar Munich, 23/06/2026. Il veut m'envoyer son projet à vendre en Allemagne (~20 MW). A aussi des projets abandonnés en France à Biarritz. Très gentil.	2026-06-24 00:07:05.048586+02	Dr. Andreas Brockmoller - Geschäftsführer (CEO)\nAddress: Astemplatz 3, 12203 Berlin\nPhone: +49 (030) 61 65 76 - 0 - Fax: +49 (030) 61 65 76 - 33 - Mobile: +49 (0173) 61 63 35 7\nIntersolar Munich, 23/06/2026. He wants to send me his project to sell in Germany (~20 MW). Also has abandoned projects in France in Biarritz. Very friendly.
14	1	ELMYA	Developer	Spain	\N	Enrique Gahete Cárdeno	egahete@elmya.com	to_contact	👤 Contact — Enrique Gahete Cárdeno\nPoste — Business Development Director\nTél — +34 659 70 94 90\nAdresse — Edificio Morera & Vallejo II, C. Aviación, 14, planta baja, 41007 Sevilla\nWeb — www.elmya.com\n\n🌍 Géographie — Espagne, Italie, Grèce, UK, USA\n\n🎯 Positionnement — Développeur, taille de projet minimum 20 MW, cherche des investisseurs pour co-développer leurs projets\n\n💬 Échange clé — Leur directeur général n'était pas disponible au salon (agenda très chargé)\n📅 Prochaine étape — Envoyer un email à Enrique pour fixer un rendez-vous	2026-06-24 00:23:55.937178+02	👤 Contact — Enrique Gahete Cárdeno\nTitle — Business Development Director\nPhone — +34 659 70 94 90\nAddress — Edificio Morera & Vallejo II, C. Aviación, 14, planta baja, 41007 Sevilla\nWeb — www.elmya.com\n\n🌍 Geography — Spain, Italy, Greece, UK, USA\n\n🎯 Positioning — Developer, minimum project size 20 MW, looking for investors to co-develop their projects\n\n💬 Key exchange — Their managing director was unavailable at the fair (very busy schedule)\n📅 Next step — Email to Enrique to set up a meeting
1	1	Avasco Solar NV	Manufacturer	Belgium	A5.171			meeting_done	Fabricant systèmes montage PV. Pas développeur/pas IPP. Réseau installateurs.	2026-06-23 22:23:24.06515+02	PV mounting systems manufacturer. Not a developer/not IPP. Installer network.
2	1	Wagner Solar GmbH	Manufacturer	Germany				meeting_done	Systemanbieter allemand depuis 1979. PV, thermique, stockage. Pas développeur/pas IPP.	2026-06-23 22:23:24.06515+02	German system provider since 1979. PV, thermal, storage. Not a developer/not IPP.
3	1	ELVAN S.A.	Manufacturer	Greece	Hall A5, Booth 134			meeting_done	Fabricant structures montage PV depuis 50+ ans. Partenariat Brite Solar agriPV.	2026-06-23 22:23:24.06515+02	PV mounting structures manufacturer for 50+ years. Partnership with Brite Solar agriPV.
4	1	Akiş Enerji (Akis Energy)	IPP	Turkey		Nilay Unutulmaz	nilay.unutulmaz@akisgroup.com	meeting_scheduled	🏢 Company Profile — IPP turc, 70 MW opérationnel, modèle hold\n🎯 Target — Italie & UK, RTB 1-1.5 MW\n🇮🇹 Italia status — 2 projets en DD\n🤝 Network — Investisseurs partenaires turcs aussi\n📅 Next step — Meeting dans 2 semaines\n\n👤 Contact — Nilay UNUTULMAZ\nPoste — Deputy General Manager, Investment & Business Development\nAdresse — Levent Mah. Begonya Sk. No:1 Beşiktaş / İSTANBUL\nTél — +90 212 290 24 64\nFax — +90 212 290 24 62\nMobile — +90 539 518 70 69\nWeb — www.akisgroup.com	2026-06-23 22:23:24.06515+02	🏢 Company Profile — Turkish IPP, 70 MW operational, hold model\n🎯 Target — Italy & UK, RTB 1-1.5 MW\n🇮🇹 Italy status — 2 projects in DD\n🤝 Network — Turkish partner investors too\n📅 Next step — Meeting in 2 weeks\n\n👤 Contact — Nilay UNUTULMAZ\nTitle — Deputy General Manager, Investment & Business Development\nAddress — Levent Mah. Begonya Sk. No:1 Beşiktaş / İSTANBUL\nTel — +90 212 290 24 64\nFax — +90 212 290 24 62\nMobile — +90 539 518 70 69\nWeb — www.akisgroup.com
5	1	Novar Energy	Developer	Czech Republic		Merijn Havinga	merijn.havinga@novar.energy	contacted	🔧 Profil — Développeur (Czech Republic)\n\nCe qu'ils ont dit :\n- Développent des projets jusqu'à RTB puis les vendent\n- Ont parfois besoin d'un partenaire d'investissement (paiement par jalons)\n- Parfois font le développement en interne\n- Joint-ventures avec Langa International (France) et IB Focal GmbH\n- Ont déjà des partenaires de développement\n- Vendent des projets (n'achètent pas)\n- Optionnellement peuvent acheter des projets early-stage\n\n👤 Contact — Merijn Havinga\nPoste — Head of International Operations\nMobile — +31 (6) 15 38 72 68	2026-06-23 22:23:24.06515+02	🔧 Profile — Developer (Czech Republic)\n\nWhat they said:\n- Develop projects up to RTB then sell them\n- Sometimes need an investment partner (milestone payments)\n- Sometimes do development in-house\n- Joint ventures with Langa International (France) and IB Focal GmbH\n- Already have development partners\n- Sell projects (don't buy)\n- Can optionally buy early-stage projects\n\n👤 Contact — Merijn Havinga\nTitle — Head of International Operations\nMobile — +31 (6) 15 38 72 68
16	1	The Milk Sun	Broker	Germany	\N	\N	\N	to_contact	🌍 Géographie — Allemagne uniquement\n🏢 Rôle — Broker / marketplace entre vendeurs et acheteurs de projets solaires\n💰 Modèle — Vendent des parts de projets à partir de 50k€ — n'achètent PAS eux-mêmes\n\n💬 Échange — Trouvent des acheteurs pour des projets. Intéressés par les projets de Z en France/Allemagne. Ont demandé l'email. Ont proposé de scanner QR/carte.\n📌 Prochaine étape — Pas de carte récupérée → repasser à leur stand demain pour en récupérer une / visiter le stand	2026-06-24 00:32:20.928673+02	🌍 Geography — Germany only\n🏢 Role — Broker / marketplace between solar project sellers and buyers\n💰 Model — Sell shares of projects from €50k — they do NOT buy themselves\n\n💬 Convo — They find buyers for projects. Interested in Z's projects in France/Germany. Asked for email. Offered to scan QR/card.\n📌 Next — No card collected → pass by their booth tomorrow to get one or visit the stand
17	1	UmweltBank AG	Investor	Germany	\N	Thomas Günter	thomas.guenter.2026@umweltbank.de	to_contact	👤 Contact — Thomas Günter\nPoste — Kreditspezialist — Financement Énergies Renouvelables\nQualification — Bankkaufmann — Bachelor en gestion d'entreprise\nTél — 0911 5308-2552\nAdresse — Laufertorgraben 6 · 90489 Nürnberg\n\n🏦 Activité — Financement de projets d'énergies renouvelables\n- Uniquement SPV / financement de projet (très peu d'equity)\n- Uniquement en Allemagne\n- Secteurs — PV, stockage batterie, éolien\n- Stade requis — Ready-to-build (permis sécurisé)\n- Éolien — permis requis sécurisé (BImSchG)\n- Besoin de voir le projet d'abord → teaser préféré\n\n📌 Prochaine étape — Email pour fixer un rendez-vous	2026-06-24 00:39:40.04565+02	👤 Contact — Thomas Günter\nTitle — Kreditspezialist — Credit Specialist, Renewable Energy Financing\nQualification — Bankkaufmann — Bachelor Betriebswirtschaftslehre\nPhone — 0911 5308-2552\nAddress — Laufertorgraben 6 · 90489 Nürnberg\n\n🏦 What they do — Financing renewable energy projects\n- Only SPV / project financing (very little equity)\n- Only in Germany\n- Sectors — PV, battery storage, wind\n- Stage needed — Ready-to-build (permitting secured)\n- Wind needs permit secured (BImSchG)\n- Need to see the project first → teaser preferred\n\n📌 Next — Email to fix a meeting
\.


--
-- Data for Name: exhibitions; Type: TABLE DATA; Schema: public; Owner: hermes
--

COPY public.exhibitions (id, name, date, location, created_at, updated_at) FROM stdin;
1	Intersolar 2026	23-25 Juin 2026	Munich, Allemagne	2026-06-23 22:23:24.06515+02	\N
\.


--
-- Data for Name: investors; Type: TABLE DATA; Schema: public; Owner: hermes
--

COPY public.investors (id, company, contact_name, email, phone, linkedin, type, status, country, target_countries, technologies, min_mw, max_mw, min_ticket, max_ticket, criteria, notes, last_contact, next_action, created_at, updated_at, deal_stages, deal_types) FROM stdin;
4	Faradae	Philippe DURAND	philippe@faradae.com	. +33 7 67 40 02 81	\N	fund	active	\N	Europe	PV, tout stade	\N	\N	\N	\N	Capacité <2 MW, co-développement ou near-RTB\nPour profiter du dispositif d’EDF Obligation d’Achat (EDF OA)	Zone: Europe\nTechnologies: PV, tout stade\nCritères: Capacité <2 MW, co-développement ou near-RTB\nPour profiter du dispositif d’EDF Obligation d’Achat (EDF OA)\nRemarques: Basé en France	\N	\N	2026-06-15 11:28:22.542893	2026-06-15 11:28:22.542893	\N	\N
8	Electron Green	Electron Green	\N	\N	\N	ipp	active	\N	France	Toitures et ombrières C&I	0	0	0	0	Dès early-stage jusqu'a operationnel	Zone: France\nTechnologies: Toitures et ombrières C&I\nCritères: Dès early-stage jusqu'a operationnel	\N	\N	2026-06-15 11:28:22.542893	2026-06-18 14:32:13.058966		
11	CATL	CATL	\N	\N	\N	other	in_discussion	\N		bess	0	0	0	0	\N	\N	\N	\N	2026-06-15 11:28:22.542893	2026-06-18 14:35:29.018206		
1	Altarea ENR	Jean Percier / R. Charuau	tgracia@altarea.com / rcharuau@altarea.com	07 87 66 74 52	\N	fund	active	\N	France	Toitures, ombrières, sol, (pas de agrivoltaïque), flottant	\N	\N	\N	\N	Acquisition de sociétés de développement, partenariats de co-développement	Zone: France\nTechnologies: Toitures, ombrières, sol, (pas de agrivoltaïque), flottant\nCritères: Acquisition de sociétés de développement, partenariats de co-développement\nRemarques: Near RTB (permis obtenu)	\N	\N	2026-06-15 11:28:22.542893	2026-06-15 11:28:22.542893	\N	\N
2	Vensolair (11/04/2025)	Vensolair	\N	\N	\N	fund	active	\N	France	PV, Wind, BESS, Hydrogène	\N	\N	\N	\N	PV ≥5 MW, Wind (1 turbine ou plus), near-RTB/RTB	Zone: France\nTechnologies: PV, Wind, BESS, Hydrogène\nCritères: PV ≥5 MW, Wind (1 turbine ou plus), near-RTB/RTB\nRemarques: Confirmera intérêt pour Corse bientôt	\N	\N	2026-06-15 11:28:22.542893	2026-06-15 11:28:22.542893	\N	\N
3	Phoenix Energy	Phoenix Energy	\N	\N	\N	fund	active	\N	Actif en Italie	PV Hybrides	\N	150	\N	\N	Préférence Proche RTB (moins mature pourquoi pas) >5 MW, TIR ≥8%, plus proche RTB	Zone: Actif en Italie\nTechnologies: PV Hybrides\nCritères: Préférence Proche RTB (moins mature pourquoi pas) >5 MW, TIR ≥8%, plus proche RTB\nRemarques: Il faut l'EPC lui-meme\nIl prefère des projets RTB pour les Construire\nFiliale du groupe Indevco	\N	\N	2026-06-15 11:28:22.542893	2026-06-15 11:28:22.542893	\N	\N
5	Enrocks	Enrocks	\N	\N	\N	fund	active	\N	Europe	PV	150	\N	\N	\N	Total 100 MW en 2026, co-développement préféré	Zone: Europe\nTechnologies: PV\nCritères: Total 100 MW en 2026, co-développement préféré\nRemarques: RTB possible mais pas après RTB	\N	\N	2026-06-15 11:28:22.542893	2026-06-15 11:28:22.542893	\N	\N
6	Philadelphia Solar	Philadelphia Solar	\N	\N	\N	fund	active	\N	Europe	PV	\N	\N	\N	\N	Préfère near-RTB, projets ≥10 MWp	Zone: Europe\nTechnologies: PV\nCritères: Préfère near-RTB, projets ≥10 MWp\nRemarques: Investit a travers ses modules + equity si nécessaire	\N	\N	2026-06-15 11:28:22.542893	2026-06-15 11:28:22.542893	\N	\N
7	Photosol (29/10/2025)	Ugo DE HALDAT DU LYS	ugo.dehaldatdulys@photosol.fr	003 6 84 46 41 52	\N	fund	active	\N	Italie, Pologne, UK, France	PV, stockage	\N	\N	\N	\N	Préférence RTB\nItalie : 20–30 MW, Pologne : 50 MW+	Zone: Italie, Pologne, UK, France\nTechnologies: PV, stockage\nCritères: Préférence RTB\nItalie : 20–30 MW, Pologne : 50 MW+\nRemarques: Préfère garder et exploiter les projets eux-mêmes; UK : intérêt non déterminé	\N	\N	2026-06-15 11:28:22.542893	2026-06-15 11:28:22.542893	\N	\N
9	RWE	RWE	\N	\N	\N	fund	active	\N	France	PV, Agri-PV au sol	\N	\N	\N	\N	Dès early-stage jusqu'a operationnel	Zone: France\nTechnologies: PV, Agri-PV au sol\nCritères: Dès early-stage jusqu'a operationnel\nRemarques: 15+ MW	\N	\N	2026-06-15 11:28:22.542893	2026-06-15 11:28:22.542893	\N	\N
10	Prosolia	Prosolia	\N	\N	\N	fund	active	\N	France	Eolien onshore (flexible in terms of capacity), prefer RTB, \nstockage standalone (<10MW), et PV+stockage (C&I)	\N	\N	\N	\N	Dès early-stage jusqu'a operationnel	Zone: France\nTechnologies: Eolien onshore (flexible in terms of capacity), prefer RTB, \nstockage standalone (<10MW), et PV+stockage (C&I)\nCritères: Dès early-stage jusqu'a operationnel	\N	\N	2026-06-15 11:28:22.542893	2026-06-15 11:28:22.542893	\N	\N
12	Tozzi Green (?)	Tozzi Green	\N	\N	\N	fund	active	\N	\N	50 +- MW onshore wind, RTB, EPC selection on Tozzi	\N	\N	\N	\N	\N	\nTechnologies: 50 +- MW onshore wind, RTB, EPC selection on Tozzi	\N	\N	2026-06-15 11:28:22.542893	2026-06-15 11:28:22.542893	\N	\N
13	WSKW (intermediary)	WSKW	\N	\N	\N	fund	active	\N	\N	Intermediary: their investor wants to acquire BESS projects, the first acquisition per developer has to be RTB, the rest can be at an earlier stage	\N	\N	\N	\N	\N	\nTechnologies: Intermediary: their investor wants to acquire BESS projects, the first acquisition per developer has to be RTB, the rest can be at an earlier stage	\N	\N	2026-06-15 11:28:22.542893	2026-06-15 11:28:22.542893	\N	\N
18	Regenerasun (David Lebret)	David Lebret	\N	\N	\N	fund	active	\N	France	PV Toitures industrielles RTB	\N	\N	\N	\N	Projets PV toiture proches RTB	Zone: France\nTechnologies: PV Toitures industrielles RTB\nCritères: Projets PV toiture proches RTB\nRemarques: Présenté par Yann Barberis (ENR Courtage). Réunion faite avec Mariella. Intérêt pour portefeuille toitures industrielles PV RTB.	\N	\N	2026-06-15 11:28:22.542893	2026-06-15 11:28:22.542893	\N	\N
17	Avergies	Nicolas Gente	nicolas.gente@avergies.fr	\N	\N	fund	active	\N	France\nPV pref. sud-est\nEolien et BESS: partout en FR	PV, BESS, wind	10	\N	\N	\N	fully RTB only (PTF finalisee)	Zone: France\nPV pref. sud-est\nEolien et BESS: partout en FR\nTechnologies: PV, BESS, wind\nCritères: fully RTB only (PTF finalisee)	\N	\N	2026-06-15 11:28:22.542893	2026-06-15 11:28:22.542893	\N	\N
15	Chint Solar	Fathia Taghozi	fathia.taghozi@chintglobal.com	07.64.85.31.82	\N	fund	active	\N	France	PV, PV+BESS	\N	\N	\N	\N	~15 MW per project or larger, near-RTB / RTB	Zone: France\nTechnologies: PV, PV+BESS\nCritères: ~15 MW per project or larger, near-RTB / RTB	\N	\N	2026-06-15 11:28:22.542893	2026-06-15 11:28:22.542893	\N	\N
16	Enervivo	Sylvain FREDERIC	sylvain.frederic@enervivo.fr	06 76 49 59 01	\N	fund	active	\N	France	Agri PV (sol ou toitures)	\N	\N	\N	\N	250 kW+, near-RTB / RTB, mais peut considerer d'autres opportunites	Zone: France\nTechnologies: Agri PV (sol ou toitures)\nCritères: 250 kW+, near-RTB / RTB, mais peut considerer d'autres opportunites	\N	\N	2026-06-15 11:28:22.542893	2026-06-15 11:28:22.542893	\N	\N
14	SDESM	Philippe HUMBRECHT	philippe.humbrecht@sdesm-energies.fr	33.6.02.09.15.4400	\N	fund	active	\N	France, seulement ces departements (Ile de France + voisins directs)\n \nVale d'Oise (95)\nYvelines (78)\nEssonne (91)\nSeine-et-Marne (77)\nSeine-Saint-Denis (93)\nHauts-de-Seine (92)\nVal-de-Marne (94)\nEssone (91)\nParis (75)\nYonne (89)\nLoiret (45)\nAube (10)\nMarne (51)\nAisne (02)\nOise (60)	PV, pas d'agriPV	\N	\N	\N	\N	500 kW + any stage (greenfield or brownfield)	Zone: France, seulement ces departements (Ile de France + voisins directs)\n \nVale d'Oise (95)\nYvelines (78)\nEssonne (91)\nSeine-et-Marne (77)\nSeine-Saint-Denis (93)\nHauts-de-Seine (92)\nVal-de-Marne (94)\nEssone (91)\nParis (75)\nYonne (89)\nLoiret (45)\nAube (10)\nMarne (51)\nAisne (02)\nOise (60)\nTechnologies: PV, pas d'agriPV\nCritères: 500 kW + any stage (greenfield or brownfield)	\N	\N	2026-06-15 11:28:22.542893	2026-06-15 11:28:22.542893	\N	\N
19	CATL / BESS Broadway	Antonio Sanchez	\N	\N	\N	fund	in_discussion	Spain	ES,DE,IT,PL,FR,RO,CH,CL,MX,AU,JP	bess	\N	\N	0	200000000	\N	## Compte-rendu réunion - CATL / BESS Broadway\nDate: 1 avril 2026 | Participants: Mariella Mansour (Enechange), Antonio Sanchez (CATL / BESS Broadway)\nContact: Antonio Sanchez — Head of Business Development & Investment Strategy (Europe)\n\n### Structure CATL / BESS Broadway\n- CATL = fabricant chinois de batteries (n°1 mondial) (BESS)\n- BESS Broadway = SPV dédié de CATL, en Joint Venture avec Lockpipe (investment group)\n- Lockpipe a engagé 200M$ dans la JV\n- Modèle : acquérir/développer projets → packager avec batteries CATL (prix compétitif fabricant) → vendre le package clé en main à Lockpipe\n\n### Cibles recherchées\n- Standalone BESS (priorité)\n- Projets PV+BESS collocated (envisageable, surtout pour charger batteries à coût zéro)\n- Pas de pur solaire seul\n- Stade min : grid connection sécurisée (open à early stage et co-développement)\n- RTB aussi possible si prix raisonnable\n\n### Marchés\n- Europe prioritaire : Espagne, Allemagne, Italie, Pologne, France, Roumanie, Suisse\n- International : Chili, Mexique, Australie, Japon (20 GW en vue au Japon)\n- Budget 2026 : 200M$ à déployer\n\n### Fee agreement\n- Antonio ouvert à reconnaître le rôle d'intermédiaire\n- Prêt à dire en meeting direct : structure fee avec Mariella/EIR\n- Pour lui, pas de problème à déclarer le mandat\n\n### Prochains steps\n- Mariella envoie briefs sur projet BESS Pologne (460 MW / 1 200 MWh, grid offer reçue, RTB Q2 2027)\n- Mariella envoie brief projet Finlande (à vérifier statut grid)\n- Vérifier structure revenus capacity markets / AS pour marchés nordiques\n- Envoyer NDA EIR\n- Continuer à envoyer portfolios	2026-04-01 12:00:00	📩 Mariella envoie briefs Pologne + Finlande\n📄 Envoyer NDA EIR\n📎 Vérifier structure revenus capacity markets	2026-06-18 14:38:38.082131	2026-06-18 14:38:38.082131	grid_connection_secured,rtb,co_development,early_stage	acquisition,co_development
\.


--
-- Data for Name: learning; Type: TABLE DATA; Schema: public; Owner: hermes
--

COPY public.learning (id, term, definition, category, example, source, language, active, created_at) FROM stdin;
1	Grid parity	Parité réseau	technical	When solar costs same as grid electricity	\N	fr	t	2026-06-16 00:45:49.181942
2	Curtailment	Écrêtement	technical	Reducing renewable output when grid is oversupplied	\N	fr	t	2026-06-16 00:45:49.348455
3	Power Purchase Agreement (PPA)	Contrat d'achat d'électricité	finance	Long-term contract to buy power at fixed price	\N	fr	t	2026-06-16 00:45:49.373082
4	distortion	distorsion	technical		\N	fr	t	2026-06-16 00:45:49.40586
5	Pact	Pacte	technical		\N	fr	t	2026-06-16 00:45:49.431956
6	granted	octroyée	technical	les aides seront octroyées sur la base d’une procédure d’appel d’offres transparente	\N	fr	t	2026-06-16 00:45:49.503224
7	Discriminatory	Discriminatoire	technical	les aides seront octroyées sur la base d’une procédure d’appel d’offres transparente	\N	fr	t	2026-06-16 00:45:49.552901
8	coming from	en provenance	technical	les aides seront octroyées sur la base d’une procédure d’appel d’offres transparente	\N	fr	t	2026-06-16 00:45:49.584177
9	Fleet Manager	Gestionnaire de flotte	technical	Tesla Fleet Manager — pilotage à distance des batteries Megapack (maintenance, optimisation)	\N	fr	t	2026-06-16 00:45:49.623361
10	Megapack	Mégapack	technical	Conteneur batterie Tesla (~4 MWh). Utilisé par HarmonyEnergy pour leurs projets BESS	\N	fr	t	2026-06-16 00:45:49.649433
11	BESS	Batterie stationnaire (stockage)	technical	Battery Energy Storage System — gros conteneurs de batteries pour stabiliser le réseau	\N	fr	t	2026-06-16 00:45:49.671431
12	HEIT	Fonds d'investissement coté	finance	Harmony Energy Income Trust PLC — fonds coté sur AIM (Londres) qui finance les projets BESS	\N	fr	t	2026-06-16 00:45:49.709287
13	After-sales service (SAV)	Service Après-Vente (SAV)	market	Tesla fournit le SAV des Megapacks via Fleet Manager — maintenance à distance incluse dans le contrat	\N	fr	t	2026-06-16 00:45:50.184706
14	Arbitrage (trading)	Arbitrage	finance	Acheter l'électricité pas chère (nuit, surplus ENR) → charger la batterie → revendre plus cher aux heures de pointe. HarmonyEnergy le fait via son équipe trading interne sur EPEX.	\N	fr	t	2026-06-16 00:45:50.488249
15	Frequency regulation	Réglage de fréquence	technical	Service RTE : les batteries maintiennent le réseau à 50 Hz en injectant/prélevant de l'électricité en millisecondes.	\N	fr	t	2026-06-16 00:45:50.50195
16	Capacity mechanism	Mécanisme de capacité	technical	RTE paie Harmony pour garantir une puissance disponible en période de pointe (grand froid). C'est une assurance-réseau.	\N	fr	t	2026-06-16 00:45:50.524089
17	Fast Reserve	Réserve Rapide	technical	Service RTE : si une centrale tombe, la batterie injecte de l'électricité en 0,1 seconde pour stabiliser le réseau	\N	fr	t	2026-06-16 00:45:50.586463
18	Availability payment	Paiement de disponibilité	finance	RTE paie Harmony pour garder la batterie disponible (abonnement), même si elle n'est pas activée	\N	fr	t	2026-06-16 00:45:50.60331
19	Activation payment	Paiement d'activation	finance	RTE paie Harmony en plus quand la batterie est réellement sollicitée (énergie fournie)	\N	fr	t	2026-06-16 00:45:50.61948
20	Flagship project	Projet phare	market	Le projet le plus avancé qui sert de vitrine. Ex: le projet 100 MW Nouvelle-Aquitaine est le projet phare d'HarmonyEnergy France.	\N	fr	t	2026-06-16 00:45:50.650344
21	ESTP Paris	École Spéciale des Travaux Publics, du Bâtiment et de l'Industrie	vocabulary	Grande école d'ingénieurs - BTP, génie civil, construction. Réputée dans l'énergie et les infrastructures.	\N	fr	t	2026-06-16 00:45:50.666677
22	HEC Executive MBA	MBA Exécutif HEC Paris	vocabulary	HEC Paris = top business school française. Executive MBA = programme pour cadres dirigeants.	\N	fr	t	2026-06-16 00:45:50.680359
23	Ingé	Ingénieur (abréviation familière)	vocabulary	Abbréviation courante en français parlé. Ex: "C'est un ingé ESTP"	\N	fr	t	2026-06-16 00:45:50.692319
24	Combo	Combinaison / Association gagnante	vocabulary	Abréviation de 'combination'. Ex: 'ESTP + HEC = le combo parfait'	\N	fr	t	2026-06-16 00:45:50.70506
25	Trading (énergie)	Achat/vente d'électricité sur les marchés	vocabulary	Pour le BESS: acheter pas cher, stocker, revendre cher = arbitrage. Ex: équipe trading interne Harmony UK	\N	fr	t	2026-06-16 00:45:50.737543
26	Numero de dossier de demande de raccordement obtenu aupres de RTE (Reseau de Transport d'Electricite, gestionnaire du reseau haute tension en France). Avoir un identifiant = projet avance. Pas d'identifiant = projet en phase amont.	Question qualification Phase 3: 'Vous avez deja des identifiants RTE ou vous partez de zero ?' — Verifier si le projet a entame les demarches.	vocabulary	Question qualification Phase 3: 'Vous avez deja des identifiants RTE ou vous partez de zero ?' — Verifier si le projet a entame les demarches.	\N	fr	t	2026-06-16 00:45:50.765889
27	MW (Megawatt)	MW (Megawatt)	technical	Puissance = la force de la batterie. 1 MW ~ 500-800 foyers en pointe	\N	fr	t	2026-06-16 00:45:50.789159
28	MWh (Megawatt-hour)	MWh (Megawattheure)	technical	Capacite = taille du reservoir. 200 MWh = 200 MW pendant 1h	\N	fr	t	2026-06-16 00:45:50.803351
29	BESS (Battery Energy Storage System)	Systeme de stockage par batteries	technical	Batteries stationnaires pour stocker/restituer de l electricite	\N	fr	t	2026-06-16 00:45:50.846897
30	Arbitrage	Arbitrage	finance	Acheter electricite pas cher (nuit), revendre cher (jour)	\N	fr	t	2026-06-16 00:45:50.891903
31	Grid services	Services systeme RTE	technical	Services payes par RTE pour stabiliser le reseau (reserve rapide)	\N	fr	t	2026-06-16 00:45:50.927333
32	Tesla Megapack	Tesla Megapack	technical	Batterie stationnaire Tesla. HarmonyEnergy utilise que des Megapacks	\N	fr	t	2026-06-16 00:45:51.237261
33	Capacity mechanism	Mecanisme de capacite	finance	Remuneration garantie pour etre dispo en hiver (RTE)	\N	fr	t	2026-06-16 00:45:51.26719
34	Pipeline	Pipeline (portefeuille de projets)	finance	Ensemble des projets en developpement (ex: 1 GW d ici 2026)	\N	fr	t	2026-06-16 00:45:51.301776
35	Greenfield	Greenfield (projet neuf)	technical	Projet developpe from scratch (vs acquisition / brownfield)	\N	fr	t	2026-06-16 00:45:51.343426
36	LCOE	Coût de production de l'électricité	vocabulary	Le LCOE du solaire en France est autour de 35-50 €/MWh	\N	fr	t	2026-06-16 00:45:51.766993
37	PPA	Contrat d'achat d'électricité	vocabulary	Le PPA garantit un prix de vente fixe sur 10-20 ans	\N	fr	t	2026-06-16 00:45:51.853811
38	CfD	Contrat pour Différence	vocabulary	Si marché > prix AO → le développeur rembourse l'État	\N	fr	t	2026-06-16 00:45:51.931626
39	Grid parity	Parité réseau	vocabulary	Le solaire a atteint la parité réseau en France en 2020	\N	fr	t	2026-06-16 00:45:52.108448
40	Soumissionner	Proposer un prix dans un appel d'offres	vocabulary	Le développeur soumissionne à 45 €/MWh pour gagner l'AO	\N	fr	t	2026-06-16 00:45:52.249629
41	Soumissionnaire	Candidat à un appel d'offres	vocabulary	Les soumissionnaires sont classés du moins cher au plus cher	\N	fr	t	2026-06-16 00:45:52.263259
42	Appel d'offres (AO)	Tender / Concours organisé par la CRE	vocabulary	La CRE sélectionne les projets les plus compétitifs	\N	fr	t	2026-06-16 00:45:52.275763
43	Enedis / RTE	Gestionnaires du réseau électrique	vocabulary	Enedis contrôle l'injection via un compteur unique certifié	\N	fr	t	2026-06-16 00:45:52.295373
44	EDF OA	Obligation d'Achat - gère les CfD	vocabulary	EDF OA gère les contrats CfD pour le compte de l'État	\N	fr	t	2026-06-16 00:45:52.748758
47	Marge (PPA - LCOE)	Écart entre prix de vente et coût de revient	vocabulary	Les développeurs visent 5-15 €/MWh de marge	\N	fr	t	2026-06-16 00:45:53.454786
50	CSPE / TICFE	Contribution au Service Public de l'Électricité	finance	Taxe sur la facture d'électricité qui finance le rachat solaire par EDF OA (~22 €/MWh)	\N	fr	t	2026-06-16 00:45:53.559178
53	Retail electricity price	Prix foyer / Tarif réglementé	vocabulary	Prix que paie un particulier sur sa facture (~0,17 €/kWh en France, fournisseur EDF etc.)	\N	fr	t	2026-06-16 00:45:54.352936
56	AssetCo (Asset Company)	Société d'actifs	finance	La société qui détient et exploite l'actif (centrale) une fois construit	\N	fr	t	2026-06-16 00:45:54.411816
59	OpCo (Operating Company)	Société d'exploitation	finance	Société qui gère l'exploitation et la maintenance de la centrale	\N	fr	t	2026-06-16 00:45:54.863644
62	DevEx	Dépenses de développement	finance	Coûts de développement (études, foncier, permis) avant construction	\N	fr	t	2026-06-16 00:45:55.402168
65	Full value chain	Chaîne de valeur complète	finance	Maîtrise de toute la chaîne : développement → construction → exploitation → vente	\N	fr	t	2026-06-16 00:45:55.46293
68	Financement projet (Project Finance)	Financement de projet	finance	Structure où un projet spécifique (ex: centrale solaire) est financé sur ses propres cash-flows futurs, sans recours sur la société mère.	\N	fr	t	2026-06-16 00:45:55.522583
71	Sweetener / Carrot / Bait (deal sweetener)	Appât / Paniers de la mariée (deal sweetener)	finance	Projet déjà opérationnel ajouté à un package pour le rendre plus attractif. Ex: Coca-Cola est l'appât dans le package Enervivo.	\N	fr	t	2026-06-16 00:45:55.635725
74	Au 31 mars 2026, la puissance du parc photovoltaïque français atteint 33 GW	https://www.pv-magazine.fr/2026/05/29/au-31-mars-2026-la-puissance-du-parc-photovoltaique-francais-atteint-33-gw/	market	⬜ A lire | FR | Chiffres clés du solaire français - MTES	\N	fr	t	2026-06-16 00:45:55.791897
77	Renewable capacity additions to hit 700 GW in 2026, latest IEA market update shows	https://www.iea.org/news/renewable-capacity-additions-to-hit-700-gw-in-2026-latest-iea-market-update-shows	market	⬜ A lire | EN | IEA prevision 700 GW capacites renouvelables installees en 2026, portees par le solaire PV en Chine et Europe	\N	en	t	2026-06-16 00:45:55.859151
80	Le plus grand parc éolien-solaire au monde est chinois	https://www.connaissancedesenergies.org/le-plus-grand-parc-eolien-solaire-au-monde-est-chinois	market	⬜ A lire | FR | Parc hybride Envision Energy - le plus grand du monde	\N	fr	t	2026-06-16 00:45:55.999947
83	Tandem PV announces 30.4% efficient perovskite/silicon demonstration module	https://www.pv-magazine.com/2026/06/01/tandem-pv-announces-30-4-efficient-perovskite-silicon-demonstration-module/	market	⬜ A lire | EN | Tandem PV atteint 30.4% d efficacite sur module tandem perovskite/silicium - promet 28% pour modules taille reelle d ici fin 2026	\N	en	t	2026-06-16 00:45:56.081454
86	L appel d offres solaire 100-500 kWc desormais ouvert au PV au sol	https://www.pv-magazine.fr/2026/06/03/lappel-doffres-solaire-100-500-kwc-desormais-ouvert-au-pv-au-sol/	market	⬜ A lire | FR | CRE ouvre l AO PPE2 Petit PV au sol : 288 MWc, prix plafond 95 EUR/MWh, criteres resilience chaine appro. Candidatures 20-31 juillet 2026.	\N	fr	t	2026-06-16 00:45:56.169275
89	Photovoltaïque résidentiel : le point de bascule vers l'autoconsommation	https://www.pv-magazine.fr/2026/06/04/photovoltaique-residentiel-le-point-de-bascule-vers-lautoconsommation/	market	⬜ A lire | FR | Nouvel arrêté S21 - tarif surplus à 1.1 c€/kWh, fin prime autoconsommation, bascule vers stockage/pilotage EMS	\N	fr	t	2026-06-16 00:45:56.208501
92	Fiscalité : un appel à « réduire les incohérences » pour « ne pas entraver la transition énergétique »	https://www.connaissancedesenergies.org/fiscalite-cpo-reduire-incoherences-transition-energetique	market	⬜ A lire | FR | CPO (Cour des comptes) propose une réforme cohérente de la fiscalité énergétique pour accélérer la décarbonation	\N	fr	t	2026-06-16 00:45:56.294
95	Age of electrification exposing Australia's weakest link	https://www.pv-magazine.com/2026/06/06/age-of-electrification-exposing-australias-weakest-link/	market	⬜ A lire | EN | Lélectrification massive révèle les fragilités du réseau australien - coupures, congestion et besoin d investissements	\N	en	t	2026-06-16 00:45:56.459823
98	Eclipse accélère dans le stockage par batteries avec une levée de 20 millions d'euros	https://www.pv-magazine.fr/2026/06/09/eclipse-accelere-dans-le-stockage-par-batteries-avec-une-levee-de-20-millions-deuros/	market	⬜ A lire | FR | Eclipse (stockage batteries) lève 20M€ en Série A — BNP Paribas & Noria. Accélération déploiement projets + logiciel Flowstream + offtake Europe.	\N	fr	t	2026-06-16 00:45:56.503117
101	U.S. deploys 7.8 GW of solar in Q1	https://www.pv-magazine.com/2026/06/11/u-s-q1-solar-installations-decline-27-year-over-year/	market	⬜ A lire | EN | 7,8 GW solaire installé au T1 2026 aux USA — baisse de 27% vs T1 2025. Utility-scale en retrait, secteur résidentiel en hausse. 8,2 GW de stockage déployés, +163% YoY.	\N	en	t	2026-06-16 00:45:56.710982
104	Photovoltaïque vs. nouveau nucléaire : l'heure des comptes	https://www.pv-magazine.fr/2026/06/12/photovoltaique-vs-nouveau-nucleaire-lheure-des-comptes/	market	⬜ A lire | FR | Comparaison des coûts entre PV et nouveau nucléaire : prix négatifs, coûts de production, souveraineté des chaînes d'approvisionnement	\N	fr	t	2026-06-16 00:45:56.956395
107	Trinasolar launches 620 W TOPCon 'Shield' module for North American market	https://www.pv-magazine.com/2026/06/12/trinasolar-launches-620-w-topcon-shield-module-for-north-american-market/	market	⬜ A lire | EN | Trina Solar lance Vertex N Shield : module TOPCon 620 W, résistant à la grêle, pour le marché nord-américain	\N	en	t	2026-06-16 00:45:57.336285
45	CRE	Commission de Régulation de l'Énergie	vocabulary	La CRE supervise les appels d'offres et les contrôles	\N	fr	t	2026-06-16 00:45:52.929736
48	ICPE (Installation Classified for Environmental Protection)	ICPE — Installation Classée pour la Protection de l'Environnement	vocabulary	Cadre réglementaire français. Éolien = ICPE obligatoire. PV sol = selon puissance. ICPE obtenu = étape clé vers RTB.	\N	fr	t	2026-06-16 00:45:53.502777
51	CSPE / TICFE	Contribution au Service Public de l'Électricité	vocabulary	Taxe sur la facture d'électricité qui finance le rachat solaire par EDF OA (~22 €/MWh)	\N	fr	t	2026-06-16 00:45:53.593645
54	PPA / Market price	Prix marché / PPA (Power Purchase Agreement)	vocabulary	Prix négocié entre producteur et acheteur pour grands projets (35-50 €/MWh pour le solaire France)	\N	fr	t	2026-06-16 00:45:54.372096
57	SPV (Special Purpose Vehicle)	Véhicule dédié	finance	Société créée spécifiquement pour un seul projet — isole le risque	\N	fr	t	2026-06-16 00:45:54.802468
60	JV (Joint Venture)	Coentreprise / JV	finance	Société créée à deux (50-50 ou autre répartition) pour collaborer sur un projet	\N	fr	t	2026-06-16 00:45:54.884694
63	CapEx	Dépenses d'investissement	finance	Coûts de construction et d'équipement de la centrale	\N	fr	t	2026-06-16 00:45:55.427008
66	Equity / Equity Raise / Levée de fonds	Levée de fonds (apport en capital)	finance	Vendre une part de sa société/projet à des investisseurs en échange d'argent. Pas de remboursement — l'investisseur devient actionnaire.	\N	fr	t	2026-06-16 00:45:55.482759
69	Go bankrupt / Goes bankrupt	Faire faillite	finance	Quand une entreprise n'a plus d'argent et doit fermer. Ex: 'Si la SPV fait faillite, Enervivo continue.'	\N	fr	t	2026-06-16 00:45:55.539041
72	L'énergie solaire en France : chiffres clés 2026	https://www.france-renouvelables.fr/actualites	market	✅ Lu | FR | À lire - infos générales marché FR	\N	fr	t	2026-06-16 00:45:55.668139
75	India installs 2.7 GW of rooftop PV in Q1	https://www.pv-magazine.com/2026/05/29/residential-segment-accounts-for-82-of-indias-rooftop-solar-additions-in-q1-2026-mercom/	market	⬜ A lire | EN | PMA Surya Ghar program - marché émergent	\N	en	t	2026-06-16 00:45:55.813797
78	Record de production photovoltaïque en France au printemps 2026	https://www.connaissancedesenergies.org/afp/record-de-production-photovoltaique-en-france-au-printemps-2026-260531	market	⬜ A lire | FR | Nouveau record de production solaire au printemps 2026, météo + croissance du parc	\N	fr	t	2026-06-16 00:45:55.885455
81	ContourGlobal inaugurates Chilean hybrid plant with 231 MW of solar and 200 MW/1.3 GWh BESS	https://www.pv-magazine.com/2026/05/30/inauguran-en-chile-una-planta-hibrida-con-231-mwp-solares-y-un-bess-de-200-mw-13-gwh/	market	⬜ A lire | EN | Plus grande installation BESS operationnelle d Amerique latine	\N	en	t	2026-06-16 00:45:56.039656
84	Un prix spot negatif record de -498 EUR/MWh enregistre le 1er mai	https://www.pv-magazine.fr/2026/06/02/un-prix-spot-negatif-record-de-498-e-mwh-enregistre-le-1er-mai/	market	⬜ A lire | FR | Record de prix negatifs sur le marche francais - spread 141 EUR/MWh en mai 2026, +34% revenus BESS	\N	fr	t	2026-06-16 00:45:56.145303
87	France, Germany, Portugal, Spain set daily solar records	https://www.pv-magazine.com/2026/06/03/france-germany-portugal-spain-set-daily-solar-records/	market	⬜ A lire | EN | Records solaires : Allemagne 503 GWh, Espagne 265 GWh, France 179 GWh, Portugal 32 GWh. Analyse AleaSoft - prix electriques en hausse malgre les records.	\N	en	t	2026-06-16 00:45:56.181938
90	Dutch solar owners asked to switch off during peak periods to ease distribution crisis	https://www.pv-magazine.com/2026/06/05/grid-connection-delays-affect-thousands-of-dutch-customers-liander/	market	⬜ A lire | EN | Régulateur néerlandais introduit nouvelles règles prioritaires raccordement au 1er juillet - congestion réseau distribution	\N	en	t	2026-06-16 00:45:56.255869
93	Global grid capex to surpass $650 billion in 2026, says Rystad Energy	https://www.pv-magazine.com/2026/06/06/global-grid-capex-to-surpass-650-billion-in-2026-says-rystad-energy/	market	⬜ A lire | EN | Rystad prévoit 650 G$ d'investissements réseaux en 2026 - capacité fabricants transformateurs à 4700 GVA, 400 usines dans le monde	\N	en	t	2026-06-16 00:45:56.404661
96	La CRE valide cinq projets de stockage en Corse pour près de 50 MW de puissance	https://www.pv-magazine.fr/2026/06/08/la-cre-valide-cinq-projets-de-stockage-en-corse-pour-pres-de-50-mw-de-puissance/	market	⬜ A lire | FR | CRE valide 5 projets stockage Corse (2 STEP + 3 batteries) — 50 MW cumulés, entrée en service début 2030, évitera 535 M€ surcoûts	\N	fr	t	2026-06-16 00:45:56.479026
99	From 'crazy vision' to 698 GW: How a bold solar forecast became too conservative	https://www.pv-magazine.com/2026/06/09/from-crazy-vision-to-698-gw-how-a-bold-solar-forecast-became-too-conservative/	market	⬜ A lire | EN | Prévision 2012 de 300 GW/an PV en 2025 jugée "folle" — réalité 698 GW en 2025, plus du double. Analyse IEA PVPS.	\N	en	t	2026-06-16 00:45:56.540878
102	L'alimentation des datas centers, un nouveau débouché pour les renouvelables	https://www.pv-magazine.fr/2026/06/12/lalimentation-des-datas-centers-un-nouveau-debouche-pour-les-renouvelables/	market	⬜ A lire | FR | Nouveau marché pour les ENR : les datas centers, gros consommateurs d'électricité, se tournent vers les renouvelables pour leur alimentation	\N	fr	t	2026-06-16 00:45:56.737332
105	Renewables-powered data centers feasible with sevenfold solar and wind overbuild, study finds	https://www.pv-magazine.com/2026/06/12/renewables-powered-data-centers-feasible-with-sevenfold-solar-and-wind-overbuild-study-finds/	market	⬜ A lire | EN | Étude LUT University : datas centers alimentés 24/7 par ENR avec surdimensionnement x7 + flexibilité demande + backup — coûts compétitifs	\N	en	t	2026-06-16 00:45:57.100321
46	EPEX SPOT	Marché européen de l'électricité	vocabulary	Les prix de l'électricité sont transparents sur EPEX SPOT	\N	fr	t	2026-06-16 00:45:53.281751
49	IRR (Internal Rate of Return)	TRI — Taux de Rentabilité Interne	finance	TRI > taux d'emprunt bancaire = projet crée de la valeur ✅. Échelle : >15% excellent, 10-15% bon, 8-10% correct, <6% pas intéressant. Ex: banque à 4,5%, TRI 8% → gain 3,5% (effet de levier). Fonds ENR visent 8-15%.	\N	fr	t	2026-06-16 00:45:53.522817
52	Feed-in Tariff	Tarif d'Achat régulé	vocabulary	Prix garanti par l'État pour rachat de l'électricité solaire (0,0886 €/kWh en France, contrat 20 ans)	\N	fr	t	2026-06-16 00:45:54.336287
55	DevCo (Development Company)	Société de développement	finance	La société qui développe le projet (études, foncier, permis) jusqu'au stade RTB	\N	fr	t	2026-06-16 00:45:54.394228
58	PropCo (Property Company)	Société foncière	finance	Société qui détient le foncier / terrain du projet	\N	fr	t	2026-06-16 00:45:54.829475
61	RTB (Ready To Build)	Prêt à construire	technical	Stade où le projet a tous les permis et peut commencer la construction	\N	fr	t	2026-06-16 00:45:55.169937
64	PPA (Power Purchase Agreement)	Contrat d'achat d'électricité	finance	Contrat long-terme de vente d'électricité à prix fixe	\N	fr	t	2026-06-16 00:45:55.44613
67	Debt / Prêt bancaire / Loan	Dette / Prêt bancaire	finance	Emprunter de l'argent à une banque. Doit être remboursé avec intérêts. La banque ne devient pas actionnaire.	\N	fr	t	2026-06-16 00:45:55.502481
70	Arc Atlantique (Atlantic Arc)	Arc Atlantique	market	Façade ouest de la France (Bretagne → Pays de la Loire → Nouvelle-Aquitaine). Zone historique d'Enervivo.	\N	fr	t	2026-06-16 00:45:55.563466
73	Global Solar PV Market Outlook 2026	https://www.solarpowereurope.org/insights	market	⬜ A lire | EN | SolarPower Europe - tendances mondiales	\N	en	t	2026-06-16 00:45:55.695084
76	Eolien en mer: la Commission europeenne approuve le nouveau schema francais de planification	https://www.connaissancedesenergies.org/afp/eolien-mer-commission-europeenne-approuve-schema-francais-planification-260530	market	⬜ A lire | FR | Planification spatiale eolien offshore - zones 2035/2050, feu vert CE	\N	fr	t	2026-06-16 00:45:55.840642
79	Norway kicks off 3 GW offshore wind tender	https://renewablesnow.com/news/norway-kicks-off-3-gw-offshore-wind-tender-849910/	market	⬜ A lire | EN | Nouvel appel d'offres éolien offshore norvégien de 3 GW	\N	en	t	2026-06-16 00:45:55.966292
82	Enertrag annonce un programme d investissement de 1 1 milliard d euros en France d ici a 2030	https://www.pv-magazine.fr/2026/06/01/enertrag-annonce-un-programme-dinvestissement-de-11-milliard-deuros-en-france-dici-a-2030/	market	⬜ A lire | FR | Enertrag investit 1 1 MdE en France - 1 GW de hubs hybrides eolien/solaire/batterie d ici 2030	\N	fr	t	2026-06-16 00:45:56.070682
85	Rooftop PV helps South Africa pass one year without loadshedding	https://www.pv-magazine.com/2026/06/02/rooftop-pv-helps-south-africa-pass-one-year-without-loadshedding/	market	⬜ A lire | EN | Eskom atteint 365 jours sans deconnexion - 7.5 GW PV toiture installe, baisse de la demande + hausse tarifs	\N	en	t	2026-06-16 00:45:56.157941
88	Australia installs 435 MW of residential rooftop PV in April	https://www.pv-magazine.com/2026/06/05/small-scale-certificate-april-record-bumps-rooftop-solar-30-to-435-mw/	market	⬜ A lire | EN | Record PV toiture résidentielle Australie - 435 MW en avril, +30% MoM avant réduction subventions batteries	\N	en	t	2026-06-16 00:45:56.193783
91	La Commission européenne va mener une évaluation des risques des installations solaires et éoliennes dans l’UE	https://www.pv-magazine.fr/2026/06/05/la-commission-europeenne-va-mener-une-evaluation-des-risques-des-installations-solaires-et-eoliennes-dans-lue/	market	⬜ A lire | FR | Évaluation cybersécurité des actifs solaires/éoliens dans l’UE - nouvelle feuille de route numérique et IA pour l’énergie	\N	fr	t	2026-06-16 00:45:56.268836
94	RTE affirme que l'essor des prix négatifs protège les consommateurs	https://www.connaissancedesenergies.org/afp/les-prix-negatifs-effet-collateral-de-labondance-electrique-260607	market	⬜ A lire | FR | RTE justifie les prix négatifs comme protection des consommateurs face à labondance de production renouvelable	\N	fr	t	2026-06-16 00:45:56.421804
97	Grid collapse in Indonesia poses threat to renewables expansion	https://www.pv-magazine.com/2026/06/08/grid-collapse-in-indonesia-poses-threat-to-renewables-expansion/	market	⬜ A lire | EN | Série de coupures électriques en Indonésie du Nord-Ouest — infrastructure de transmission pas prête pour absorber les GW de solaire prévus	\N	en	t	2026-06-16 00:45:56.489744
100	Stockage d'énergie : Faradae déploie deux batteries stationnaires en Auvergne-Rhône-Alpes	https://www.pv-magazine.fr/2026/06/10/stockage-denergie-faradae-deploie-deux-batteries-stationnaires-en-auvergne-rhone-alpes/	market	⬜ A lire | FR | Faradae (groupe GALEC/Leclerc) installe 2 batteries (1,9 MW/3,8 MWh) sur parking à Roanne — partenariat avec NW pour pilotage via Jumeau Numérique	\N	fr	t	2026-06-16 00:45:56.661968
103	Hot weather and clear skies give Europe a bumper May	https://www.pv-magazine.com/2026/06/12/hot-weather-and-clear-skies-give-europe-a-bumper-may/	market	⬜ A lire | EN | Production solaire record en Europe en mai 2026 grâce à une météo favorable — analyse pays par pays	\N	en	t	2026-06-16 00:45:56.911405
106	JA Solar devient JA et se positionne comme fabricant d'un écosystème intégré	https://www.pv-magazine.fr/2026/06/12/ja-solar-devient-ja-et-se-positionne-comme-fabricant-dun-ecosysteme-integre/	market	⬜ A lire | FR | JA Solar se rebaptise JA, passe du statut de fabricant modules à fournisseur écosystème intégré : PV, stockage, énergie intelligente et financement	\N	fr	t	2026-06-16 00:45:57.280895
108	Parité réseau	EN: Grid parity | AR: تعادل الشبكة	technical	When solar costs same as grid electricity	sheet-vocab-import	fr	t	2026-06-17 09:34:20.107992
109	Écrêtement	EN: Curtailment | AR: تقليص الإنتاج	technical	Reducing renewable output when grid is oversupplied	sheet-vocab-import	fr	t	2026-06-17 09:34:20.281869
110	Contrat d'achat d'électricité	EN: Power Purchase Agreement (PPA) | AR: اتفاقية شراء الطاقة	finance	Long-term contract to buy power at fixed price	sheet-vocab-import	fr	t	2026-06-17 09:34:20.436983
111	distorsion	EN: distortion | AR: تشويه	technical	\N	sheet-vocab-import	fr	t	2026-06-17 09:34:20.602821
112	Pacte	EN: Pact | AR: ميثاق	technical	\N	sheet-vocab-import	fr	t	2026-06-17 09:34:20.759753
113	octroyée	EN: granted | AR: ممنوح	technical	les aides seront octroyées sur la base d’une procédure d’appel d’offres transparente	sheet-vocab-import	fr	t	2026-06-17 09:34:20.889185
114	Discriminatoire	EN: Discriminatory | AR: تمييزي	technical	les aides seront octroyées sur la base d’une procédure d’appel d’offres transparente	sheet-vocab-import	fr	t	2026-06-17 09:34:21.068572
115	en provenance	EN: coming from | AR: قادم من	technical	les aides seront octroyées sur la base d’une procédure d’appel d’offres transparente	sheet-vocab-import	fr	t	2026-06-17 09:34:21.220036
116	Gestionnaire de flotte	EN: Fleet Manager | AR: مدير الأسطول	technical	Tesla Fleet Manager — pilotage à distance des batteries Megapack (maintenance, optimisation)	sheet-vocab-import	fr	t	2026-06-17 09:34:21.353054
117	Mégapack	EN: Megapack | AR: ميجاباك	technical	Conteneur batterie Tesla (~4 MWh). Utilisé par HarmonyEnergy pour leurs projets BESS	sheet-vocab-import	fr	t	2026-06-17 09:34:21.496619
118	Batterie stationnaire (stockage)	EN: BESS | AR: بطارية تخزين ثابتة	technical	Battery Energy Storage System — gros conteneurs de batteries pour stabiliser le réseau	sheet-vocab-import	fr	t	2026-06-17 09:34:21.62957
119	Fonds d'investissement coté	EN: HEIT | AR: صندوق استثمار مدرج	finance	Harmony Energy Income Trust PLC — fonds coté sur AIM (Londres) qui finance les projets BESS	sheet-vocab-import	fr	t	2026-06-17 09:34:21.784236
120	Service Après-Vente (SAV)	EN: After-sales service (SAV) | AR: خدمة ما بعد البيع	market	Tesla fournit le SAV des Megapacks via Fleet Manager — maintenance à distance incluse dans le contrat	sheet-vocab-import	fr	t	2026-06-17 09:34:21.925496
121	Réglage de fréquence	EN: Frequency regulation | AR: تنظيم التردد	technical	Service RTE : les batteries maintiennent le réseau à 50 Hz en injectant/prélevant de l'électricité en millisecondes.	sheet-vocab-import	fr	t	2026-06-17 09:34:22.042
122	Mécanisme de capacité	EN: Capacity mechanism | AR: آلية السعة	technical	RTE paie Harmony pour garantir une puissance disponible en période de pointe (grand froid). C'est une assurance-réseau.	sheet-vocab-import	fr	t	2026-06-17 09:34:22.183758
123	Réserve Rapide	EN: Fast Reserve | AR: الاحتياطي السريع	technical	Service RTE : si une centrale tombe, la batterie injecte de l'électricité en 0,1 seconde pour stabiliser le réseau	sheet-vocab-import	fr	t	2026-06-17 09:34:22.316581
124	Paiement de disponibilité	EN: Availability payment | AR: دفع الجاهزية	finance	RTE paie Harmony pour garder la batterie disponible (abonnement), même si elle n'est pas activée	sheet-vocab-import	fr	t	2026-06-17 09:34:22.481601
125	Paiement d'activation	EN: Activation payment | AR: دفع التفعيل	finance	RTE paie Harmony en plus quand la batterie est réellement sollicitée (énergie fournie)	sheet-vocab-import	fr	t	2026-06-17 09:34:22.624562
126	Projet phare	EN: Flagship project | AR: مشروع رئيسي / مشروع رائد	market	Le projet le plus avancé qui sert de vitrine. Ex: le projet 100 MW Nouvelle-Aquitaine est le projet phare d'HarmonyEnergy France.	sheet-vocab-import	fr	t	2026-06-17 09:34:22.746571
127	École Spéciale des Travaux Publics, du Bâtiment et de l'Industrie	EN: ESTP Paris | AR: إي إس تي بي باريس (مدرسة الأشغال العامة)	vocabulary	Grande école d'ingénieurs - BTP, génie civil, construction. Réputée dans l'énergie et les infrastructures.	sheet-vocab-import	fr	t	2026-06-17 09:34:22.893637
128	MBA Exécutif HEC Paris	EN: HEC Executive MBA | AR: إم بي إيه تنفيذي من إتش إي سي (باريس)	vocabulary	HEC Paris = top business school française. Executive MBA = programme pour cadres dirigeants.	sheet-vocab-import	fr	t	2026-06-17 09:34:23.031567
129	Combinaison / Association gagnante	EN: Combo | AR: مزيج / توليفة	vocabulary	Abréviation de 'combination'. Ex: 'ESTP + HEC = le combo parfait'	sheet-vocab-import	fr	t	2026-06-17 09:34:23.33128
130	Achat/vente d'électricité sur les marchés	EN: Trading (énergie) | AR: تداول (الطاقة)	vocabulary	Pour le BESS: acheter pas cher, stocker, revendre cher = arbitrage. Ex: équipe trading interne Harmony UK	sheet-vocab-import	fr	t	2026-06-17 09:34:23.469831
131	Question qualification Phase 3: 'Vous avez deja des identifiants RTE ou vous partez de zero ?' — Verifier si le projet a entame les demarches.	EN: Numero de dossier de demande de raccordement obtenu aupres de RTE (Reseau de Transport d'Electricite, gestionnaire du reseau haute tension en France). Avoir un identifiant = projet avance. Pas d'identifiant = projet en phase amont. | AR: Raccordement / Grid	vocabulary	Question qualification Phase 3: 'Vous avez deja des identifiants RTE ou vous partez de zero ?' — Verifier si le projet a entame les demarches.	sheet-vocab-import	fr	t	2026-06-17 09:34:23.629291
132	MWh (Megawattheure)	EN: MWh (Megawatt-hour) | AR: ميغاواط/ساعة	technical	Capacite = taille du reservoir. 200 MWh = 200 MW pendant 1h	sheet-vocab-import	fr	t	2026-06-17 09:34:23.758307
133	Systeme de stockage par batteries	EN: BESS (Battery Energy Storage System) | AR: نظام تخزين طاقة البطاريات	technical	Batteries stationnaires pour stocker/restituer de l electricite	sheet-vocab-import	fr	t	2026-06-17 09:34:23.900572
134	Services systeme RTE	EN: Grid services | AR: خدمات الشبكة	technical	Services payes par RTE pour stabiliser le reseau (reserve rapide)	sheet-vocab-import	fr	t	2026-06-17 09:34:24.035574
135	Mecanisme de capacite	EN: Capacity mechanism | AR: آلية السعة	finance	Remuneration garantie pour etre dispo en hiver (RTE)	sheet-vocab-import	fr	t	2026-06-17 09:34:24.168198
136	Pipeline (portefeuille de projets)	EN: Pipeline | AR: خط الأنابيب	finance	Ensemble des projets en developpement (ex: 1 GW d ici 2026)	sheet-vocab-import	fr	t	2026-06-17 09:34:24.320581
137	Greenfield (projet neuf)	EN: Greenfield | AR: مشروع جديد من الصفر	technical	Projet developpe from scratch (vs acquisition / brownfield)	sheet-vocab-import	fr	t	2026-06-17 09:34:24.427565
138	Coût de production de l'électricité	EN: LCOE | AR: تكلفة إنتاج الكهرباء	vocabulary	Le LCOE du solaire en France est autour de 35-50 €/MWh	sheet-vocab-import	fr	t	2026-06-17 09:34:24.552565
139	Contrat pour Différence	EN: CfD | AR: عقد الفرق	vocabulary	Si marché > prix AO → le développeur rembourse l'État	sheet-vocab-import	fr	t	2026-06-17 09:34:24.691784
140	Proposer un prix dans un appel d'offres	EN: Soumissionner | AR: تقديم عرض في مناقصة	vocabulary	Le développeur soumissionne à 45 €/MWh pour gagner l'AO	sheet-vocab-import	fr	t	2026-06-17 09:34:24.843017
141	Candidat à un appel d'offres	EN: Soumissionnaire | AR: مقدم العرض في المناقصة	vocabulary	Les soumissionnaires sont classés du moins cher au plus cher	sheet-vocab-import	fr	t	2026-06-17 09:34:24.96192
142	Tender / Concours organisé par la CRE	EN: Appel d'offres (AO) | AR: مناقصة	vocabulary	La CRE sélectionne les projets les plus compétitifs	sheet-vocab-import	fr	t	2026-06-17 09:34:25.084281
143	Gestionnaires du réseau électrique	EN: Enedis / RTE | AR: مشغلي الشبكة الكهربائية	vocabulary	Enedis contrôle l'injection via un compteur unique certifié	sheet-vocab-import	fr	t	2026-06-17 09:34:25.229919
144	Obligation d'Achat - gère les CfD	EN: EDF OA | AR: التزام الشراء	vocabulary	EDF OA gère les contrats CfD pour le compte de l'État	sheet-vocab-import	fr	t	2026-06-17 09:34:25.391588
145	Commission de Régulation de l'Énergie	EN: CRE | AR: هيئة تنظيم الطاقة	vocabulary	La CRE supervise les appels d'offres et les contrôles	sheet-vocab-import	fr	t	2026-06-17 09:34:25.528005
146	Marché européen de l'électricité	EN: EPEX SPOT | AR: سوق الكهرباء الأوروبي	vocabulary	Les prix de l'électricité sont transparents sur EPEX SPOT	sheet-vocab-import	fr	t	2026-06-17 09:34:25.669577
147	Écart entre prix de vente et coût de revient	EN: Marge (PPA - LCOE) | AR: الهامش	vocabulary	Les développeurs visent 5-15 €/MWh de marge	sheet-vocab-import	fr	t	2026-06-17 09:34:25.815416
148	ICPE — Installation Classée pour la Protection de l'Environnement	EN: ICPE (Installation Classified for Environmental Protection) | AR: منشأة مصنفة لحماية البيئة	vocabulary	Cadre réglementaire français. Éolien = ICPE obligatoire. PV sol = selon puissance. ICPE obtenu = étape clé vers RTB.	sheet-vocab-import	fr	t	2026-06-17 09:34:25.942061
149	TRI — Taux de Rentabilité Interne	EN: IRR (Internal Rate of Return) | AR: معدل العائد الداخلي	finance	TRI > taux d'emprunt bancaire = projet crée de la valeur ✅. Échelle : >15% excellent, 10-15% bon, 8-10% correct, <6% pas intéressant. Ex: banque à 4,5%, TRI 8% → gain 3,5% (effet de levier). Fonds ENR visent 8-15%.	sheet-vocab-import	fr	t	2026-06-17 09:34:26.064878
150	Contribution au Service Public de l'Électricité	EN: CSPE / TICFE | AR: مساهمة في الخدمة العامة للكهرباء	finance	Taxe sur la facture d'électricité qui finance le rachat solaire par EDF OA (~22 €/MWh)	sheet-vocab-import	fr	t	2026-06-17 09:34:26.222005
151	Tarif d'Achat régulé	EN: Feed-in Tariff | AR: تعرفة التغذية	vocabulary	Prix garanti par l'État pour rachat de l'électricité solaire (0,0886 €/kWh en France, contrat 20 ans)	sheet-vocab-import	fr	t	2026-06-17 09:34:26.351562
152	Prix foyer / Tarif réglementé	EN: Retail electricity price | AR: سعر الكهرباء للأسر	vocabulary	Prix que paie un particulier sur sa facture (~0,17 €/kWh en France, fournisseur EDF etc.)	sheet-vocab-import	fr	t	2026-06-17 09:34:26.477717
153	Prix marché / PPA (Power Purchase Agreement)	EN: PPA / Market price | AR: سعر السوق / اتفاقية شراء الطاقة	vocabulary	Prix négocié entre producteur et acheteur pour grands projets (35-50 €/MWh pour le solaire France)	sheet-vocab-import	fr	t	2026-06-17 09:34:26.598802
154	Société de développement	EN: DevCo (Development Company) | AR: شركة التطوير	finance	La société qui développe le projet (études, foncier, permis) jusqu'au stade RTB	sheet-vocab-import	fr	t	2026-06-17 09:34:26.777171
155	Société d'actifs	EN: AssetCo (Asset Company) | AR: شركة الأصول	finance	La société qui détient et exploite l'actif (centrale) une fois construit	sheet-vocab-import	fr	t	2026-06-17 09:34:26.931596
156	Véhicule dédié	EN: SPV (Special Purpose Vehicle) | AR: كيان لأغراض خاصة	finance	Société créée spécifiquement pour un seul projet — isole le risque	sheet-vocab-import	fr	t	2026-06-17 09:34:27.05822
157	Société foncière	EN: PropCo (Property Company) | AR: شركة العقارات	finance	Société qui détient le foncier / terrain du projet	sheet-vocab-import	fr	t	2026-06-17 09:34:27.186599
158	Société d'exploitation	EN: OpCo (Operating Company) | AR: شركة التشغيل	finance	Société qui gère l'exploitation et la maintenance de la centrale	sheet-vocab-import	fr	t	2026-06-17 09:34:27.31467
159	Coentreprise / JV	EN: JV (Joint Venture) | AR: مشروع مشترك	finance	Société créée à deux (50-50 ou autre répartition) pour collaborer sur un projet	sheet-vocab-import	fr	t	2026-06-17 09:34:27.453695
160	Prêt à construire	EN: RTB (Ready To Build) | AR: جاهز للبناء	technical	Stade où le projet a tous les permis et peut commencer la construction	sheet-vocab-import	fr	t	2026-06-17 09:34:27.597563
161	Dépenses de développement	EN: DevEx | AR: نفقات التطوير	finance	Coûts de développement (études, foncier, permis) avant construction	sheet-vocab-import	fr	t	2026-06-17 09:34:27.742828
162	Dépenses d'investissement	EN: CapEx | AR: نفقات رأسمالية	finance	Coûts de construction et d'équipement de la centrale	sheet-vocab-import	fr	t	2026-06-17 09:34:27.875317
163	Chaîne de valeur complète	EN: Full value chain | AR: سلسلة القيمة الكاملة	finance	Maîtrise de toute la chaîne : développement → construction → exploitation → vente	sheet-vocab-import	fr	t	2026-06-17 09:34:28.003341
164	Levée de fonds (apport en capital)	EN: Equity / Equity Raise / Levée de fonds | AR: جمع رأس المال / زيادة رأس المال	finance	Vendre une part de sa société/projet à des investisseurs en échange d'argent. Pas de remboursement — l'investisseur devient actionnaire.	sheet-vocab-import	fr	t	2026-06-17 09:34:28.158736
165	Dette / Prêt bancaire	EN: Debt / Prêt bancaire / Loan | AR: قرض / دين	finance	Emprunter de l'argent à une banque. Doit être remboursé avec intérêts. La banque ne devient pas actionnaire.	sheet-vocab-import	fr	t	2026-06-17 09:34:28.311587
166	Financement de projet	EN: Financement projet (Project Finance) | AR: تمويل المشاريع	finance	Structure où un projet spécifique (ex: centrale solaire) est financé sur ses propres cash-flows futurs, sans recours sur la société mère.	sheet-vocab-import	fr	t	2026-06-17 09:34:28.495573
167	Faire faillite	EN: Go bankrupt / Goes bankrupt | AR: يفلس / إفلاس	finance	Quand une entreprise n'a plus d'argent et doit fermer. Ex: 'Si la SPV fait faillite, Enervivo continue.'	sheet-vocab-import	fr	t	2026-06-17 09:34:28.613711
168	Arc Atlantique	EN: Arc Atlantique (Atlantic Arc) | AR: القوس الأطلسي	market	Façade ouest de la France (Bretagne → Pays de la Loire → Nouvelle-Aquitaine). Zone historique d'Enervivo.	sheet-vocab-import	fr	t	2026-06-17 09:34:28.743325
169	Appât / Paniers de la mariée (deal sweetener)	EN: Sweetener / Carrot / Bait (deal sweetener) | AR: طعم / محفز إضافي	finance	Projet déjà opérationnel ajouté à un package pour le rendre plus attractif. Ex: Coca-Cola est l'appât dans le package Enervivo.	sheet-vocab-import	fr	t	2026-06-17 09:34:28.875935
170	Toiture logistique	Grandes toitures d'entrepôts logistiques (warehouses, centres de distribution) équipées de panneaux solaires. Segment porté par des IPP spécialisés comme Sunrock. Avantages : raccordement rapide (zones industrielles/commerciales, pas de file d'attente RTE), délai court bail→MES (~18 mois), pas de conflit d'usage agricole.	concept	Sunrock (IPP néerlandais) : 600 MWc exploitation, exclusivement toitures logistiques + ombrières. Toitures de 1 à 18 MW, moyenne 3-6 MW. 60 MW en France, objectif 200 MW/an.	Réunion Sunrock 17/06/2026	fr	t	2026-06-17 13:07:28.517596
171	Sunrock	IPP néerlandais spécialisé exclusivement en grandes toitures logistiques et ombrières solaires. Fondé en 2012. 600 MWc en exploitation. Adossé au family office Cofra. Filiale France depuis 3 ans (15 pers). Top 3 aux appels d'offres CRE.	market	60 MW France → objectif 100 MW → 200 MW/an à partir 2027. Toitures 1-18 MW. Délai bail→MES ~18 mois.	Réunion 17/06/2026 avec Franck Burguion (BDM France)	fr	t	2026-06-17 13:07:28.534116
172	Ombrière solaire	Structure équipée de panneaux solaires installée au-dessus de parkings. Techno complémentaire aux toitures logistiques pour les IPP comme Sunrock. Même avantages : raccordement rapide, ~18 mois délai.	concept	Sunrock combine toitures logistiques + ombrières. Pas de sol ni agriPV.	Réunion Sunrock 17/06/2026	fr	t	2026-06-17 13:07:28.547408
173	MES (Mise En Service)	Mise En Service : étape où une centrale solaire est raccordée au réseau électrique et commence à produire. Équivalent de COD (Commercial Operation Date). Jalon clé dans le développement de projet solaire.	vocabulary	Sunrock : délai signature bail → MES = ~18 mois pour toitures logistiques (vs 3-5 ans pour sol/agriPV à cause du file d'attente RTE).	CR Sunrock 17/06/2026	fr	t	2026-06-17 13:10:03.24215
174	Délai projet toiture logistique	Pour les projets solaires sur grandes toitures logistiques (entrepôts, warehouses), le délai total de la signature du bail avec le propriétaire jusqu'à la Mise En Service (MES) est d'environ 18 mois. C'est très rapide comparé aux centrales au sol ou à l'agriPV qui peuvent prendre 3-5 ans à cause du file d'attente RTE et des procédures administratives plus longues.	concept	Sunrock (IPP toiture) : signature bail → MES = ~18 mois. Pas de file d'attente RTE car zones industrielles/commerciales. Possibilité de phaser le raccordement sur les gros projets (12-18 MW).	CR Sunrock 17/06/2026 — Franck Burguion	fr	t	2026-06-17 13:11:11.181963
175	Raccordement phasable	Possibilité de raccorder un projet solaire au réseau en plusieurs phases plutôt qu'en une seule fois. Utile pour les grandes toitures (12-18 MW) où la capacité réseau disponible immédiatement est insuffisante. On raccorde une partie du projet maintenant, le reste plus tard quand la capacité se libère.	concept	Sunrock : pour un projet de 18 MW sur un seul toit, ils peuvent phaser le raccordement (ex: 6+6+6 MW) au lieu d'attendre un seul slot de 18 MW. Permet d'éviter le file d'attente RTE et d'accélérer la MES partielle.	CR Sunrock 17/06/2026 — Franck Burguion	fr	t	2026-06-17 13:12:43.971106
\.


--
-- Data for Name: meeting_preps; Type: TABLE DATA; Schema: public; Owner: hermes
--

COPY public.meeting_preps (id, company, event_title, event_date, context, talking_points, questions, next_steps, personal_notes, status, source_event_id, created_at, updated_at) FROM stdin;
1	Holosolis	Test Holosolis	\N		["Point 1 modifie", "Point 2 ajoute"]	["Question 1", "Question 2"]	["Step 1", "Step 2"]	Mes notes personnelles	draft	\N	2026-06-17 00:57:31.194613	2026-06-17 00:57:31.194613
\.


--
-- Data for Name: opportunities; Type: TABLE DATA; Schema: public; Owner: hermes
--

COPY public.opportunities (id, prospect_id, title, type, country, size_eur, size_mw, deadline, status, notes, created_at, updated_at, notes_en, title_en) FROM stdin;
2	99	Financement Tunisie — Projet sol 5 MW	financement	Tunisie	\N	5	2027-06-01 00:00:00	en_discussion	Partenariat ASTEG. Tarif réglementé + garantie change 80%.\nMise en service 2027. Rendement ~15%.	2026-06-16 14:57:31.807191	2026-06-16 23:35:43.36003	ASTEG partnership. Regulated rate + 80% exchange guarantee.\nCommissioning 2027. Yield ~15%.	Financing Tunisia — 5 MW ground project
5	86	Levée equity — Usine production cellules/modules 5 GWp	levee	France	7.5	\N	2026-06-30 00:00:00	en_discussion	Holosolis — construction usine Q2 2026, plus grande Europe (5 GWp/an). Tous permis sécurisés. Besoin 5-10M€ equity ASAP. NDA pas encore signé.\nAction : confirmer avec Imad quels investisseurs peuvent être intéressés.	2026-06-16 15:00:39.586082	2026-06-16 23:34:50.652858	Holosolis — Q2 2026 plant construction, largest in Europe (5 GWp/year). All permits secure. Need 5-10M€ equity ASAP. NDA not yet signed.\nAction: confirm with Imad which investors may be interested.	Equity raising — 5 GWp cell/module production plant
12	90	BESS France opérationnel ≤10 MW	cession	France	\N	10	2026-06-30 00:00:00	en_discussion	8p2 — veut uniquement BESS projets France, opérationnel, max 10 MW. Pas de projets actuellement.\nAction : email de reconnexion programmé fin juin 2026.	2026-06-16 15:00:39.586082	2026-06-16 23:35:39.706984	8p2 — only wants BESS projects France, operational, max 10 MW. No projects currently.\nAction: reconnection email scheduled for the end of June 2026.	BESS France operational ≤10 MW
1	99	Financement Maroc — 3 projets packagés	financement	Maroc	1.7	\N	2026-09-01 00:00:00	en_discussion	3 projets packagés : Coca-Cola (construit) + textile + Mexique. PPA signés. Urgence sept 2026.\nPitch deck reçu de Damien le 13/06. Réponse EIR envoyée le 14/06.\nEIR : sourcer investisseurs pour 1.6M€ equity.	2026-06-16 14:57:31.807191	2026-06-16 23:35:40.785037	3 packaged projects: Coca-Cola (built) + textile + Mexico. PPAs signed. Emergency September 2026.\nPitch deck received from Damien on 06/13. EIR response sent on 06/14.\nEIR: source investors for €1.6M equity.	Financing Morocco — 3 packaged projects
10	13	80 MW RTB à vendre — France 2026	cession	France	\N	80	2026-12-31 00:00:00	en_discussion	ABO Energy. PV 5-40 MW, pipeline 120 MW total. 80 MW RTB en vente 2026, 50 MW en 2027. Éolien min 10 MW.\nAction : relancé 19/05/2026 — en attente réponse.	2026-06-16 15:00:39.586082	2026-06-16 23:35:41.896349	ABO Energy. PV 5-40 MW, pipeline 120 MW total. 80 MW RTB on sale 2026, 50 MW in 2027. Wind power min 10 MW.\nAction: relaunched 05/19/2026 — awaiting response.	80 MW RTB for sale — France 2026
3	99	Levée de fonds — Véhicule DevCo/AssetCo international	levee	International	40	\N	2027-03-01 00:00:00	en_discussion	Levée 30-50M€ pour véhicule DevCo/AssetCo international. Répliquer modèle France (JV 50-50, partenaire finance 80%).\nInfo memo prêt. Marchés : France, Maroc, Tunisie, Sénégal, CI, Cameroun.\nEIR : sourcer investisseurs Moyen-Orient + BDD Afrique (projets 5-15 MW, 14-16%).	2026-06-16 14:57:31.807191	2026-06-16 23:35:42.745625	Raised €30-50M for international DevCo/AssetCo vehicle. Replicate France model (50-50 JV, 80% finance partner).\nInfo memo ready. Markets: France, Morocco, Tunisia, Senegal, CI, Cameroon.\nEIR: source investors from the Middle East + BDD Africa (5-15 MW projects, 14-16%).	Fundraising — International DevCo/AssetCo Vehicle
8	105	Oued Noun Wind Farm — Maroc	financement	Maroc	\N	\N	\N	en_discussion	Badr Eddine El Bachar. NDA signé. Présentation PPTX reçue (lien non accessible). Investisseur japonais potentiel identifié. Badr devait compléter dossier avec consultants — pas de retour depuis mai 2025.\nAction : relancé le 21/05/2026 — en attente réponse.	2026-06-16 15:00:39.586082	2026-06-16 23:35:44.222889	Badr Eddine El Bachar. NDA signed. PPTX presentation received (link not accessible). Potential Japanese investor identified. Badr had to complete the file with consultants - no return since May 2025.\nAction: relaunched on 05/21/2026 — awaiting response.	Oued Noun Wind Farm — Morocco
4	116	Acquisition portefeuille RTB/exploitation C&I	cession	France	\N	\N	\N	en_discussion	Sunrock IPP néerlandais. Cherche toitures + ombrières C&I, RTB ou exploitation. Min 1 MWc, pas de max. BESS BTM ok, standalone non. JV si apport immobilier.\nRéunion mercredi 11h30 Google Meet (Franck Burgui BDM France).\nActions : envoyer pipeline RTB + exploitation ≥1 MWc. NDA à lancer.	2026-06-16 15:00:39.586082	2026-06-16 23:35:45.238838	Sunrock Dutch IPP. Looking for roofs + shades C&I, RTB or exploitation. Min 1 MWp, no max. BESS BTM ok, standalone no. JV if real estate contribution.\nMeeting Wednesday 11:30 a.m. Google Meet (Franck Burgui BDM France).\nActions: send RTB pipeline + operation ≥1 MWp. NDA to be launched.	RTB portfolio acquisition/C&I operation
11	3	Achat RTB/COD éolien + stockage	cession	France	\N	\N	\N	en_discussion	Qenergy — PV & wind France/DE/ES/PT, ~3 GW dev, 1 GW construction. Réunion 13/05 : focus éolien onshore + storage.\nActions : 1. Monitorer éolien 2. Stockage 3. Contacter Martin Allemagne.	2026-06-16 15:00:39.586082	2026-06-16 23:35:45.903558	Qenergy — PV & wind France/DE/ES/PT, ~3 GW dev, 1 GW construction. Meeting 05/13: focus on onshore wind + storage.\nActions: 1. Monitor wind power 2. Storage 3. Contact Martin Germany.	Purchase RTB/COD wind power + storage
9	9	AgriPV 10 sites — 3 MWc, cherche investisseur	financement	France	\N	3	\N	en_discussion	Novabridge — Erwan Bibollet (CEO). 10 sites toitures agriPV, 2/10 éligibles AO toiture. Electron Green sorti (ticket trop grand). Nouvel investisseur intéressé, NDA en cours avec lui.\nAction : attendre finalisation NDA investisseur pour partager les détails.	2026-06-16 15:00:39.586082	2026-06-16 23:35:46.546398	Novabridge — Erwan Bibollet (CEO). 10 agriPV roof sites, 2/10 eligible for AO roofing. Electron Green released (ticket too big). New investor interested, NDA in progress with him.\nAction: Wait for investor NDA finalization to share details.	AgriPV 10 sites — 3 MWp, seeking investor
6	31	Portefeuille 6/7 MWc PV toiture + ~33 dossiers BESS	financement	France	\N	\N	\N	en_discussion	EnR Courtage (Yann). Fee-sharing 50/50 signé le 03/06 ✅. Projets PV toiture <500 kWc + stockage batteries (~33 dossiers, PDB signées, loyer 1250€/an/batterie, 12 ans). Autorisé contact Groupe Dolfines (stockage). Problème : ne peut pas avancer frais de dev → cherche investisseurs.\nAction : suivre retour Groupe Dolfines + portefeuille 6/7 MWc.	2026-06-16 15:00:39.586082	2026-06-16 23:35:47.477113	EnR Courtage (Yann). 50/50 fee-sharing signed on 03/06 ✅. Roof PV projects <500 kWp + battery storage (~33 files, PDB signed, rent 1250€/year/battery, 12 years). Authorized contact Dolfines Group (storage). Problem: cannot advance dev costs → looking for investors.\nAction: follow return Dolfines Group + 6/7 MWp portfolio.	6/7 MWp PV roofing portfolio + ~33 BESS files
7	104	Kenya — 100 MW Solar + 40 MWh BESS	financement	Kenya	55.4	100	\N	en_discussion	Terravastus Infrastructures — projet gouvernemental Kenya. SPV dédié. CAPEX 5.4M. PPA /bin/bash.08/kWh. NDA signé fév 2025. Docs analysés.\nDocs: https://drive.google.com/drive/folders/13HZSS0V7-WcCWZaewBnDTAegGB6TvFtH\nAction : à discuter en interne.	2026-06-16 15:00:39.586082	2026-06-16 23:35:48.206324	Terravastus Infrastructures — Kenya government project. Dedicated SPV. CAPEX 5.4M. PPA /bin/bash.08/kWh. NDA signed Feb 2025. Documents analyzed.\nDocs: https://drive.google.com/drive/folders/13HZSS0V7-WcCWZaewBnDTAegGB6TvFtH\nAction: to be discussed internally.	Kenya — 100 MW Solar + 40 MWh BESS
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: hermes
--

COPY public.projects (id, name, developer_id, technology, stage, capacity_mw, country, region, asking_price, irr, lcoe, description, teaser_path, nda_signed, notes, created_at, updated_at, developer_name, code, technology_detail, status_detail, p50_mwh, commune, department, department_code, rtb_date, cod_date, permit_status, permit_type, land_secured, grid_operator, grid_connection_cost, offtake_type, raw_data, custom_stage, status_fr, status_en, permis_status) FROM stdin;
148	La Berre	\N	solar	early	10.7	FR	Auvergne-Rhône-Alpes	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.385441	2026-06-18 02:18:18.385441	Viridi	14	Sol	Mid-(3) Environnement & (4) Autorisations administratives\\nLand secured, studies launched, permit application planned Q2 2026	18766	\N	Drôme (26)	26	Q4 2027	Q4 2028	\N	\N	t	Enedis	1.12	AO CRE	{"Code": "14", "Actionnariat SPV (%)": "Viridi", "Nom du projet": "La Berre", "État de développement": "Mid-(3) Environnement & (4) Autorisations administratives\\nLand secured, studies launched, permit application planned Q2 2026", "Technologie": "AgriPV", "Typologie": "Sol", "Date RTB estimée": "Q4 2027", "Date COD estimée": "Q4 2028", "Code postal": "26700", "Département": "Drôme (26)", "Région": "Auvergne-Rhône-Alpes", "Puissance installée (MWc)": "10.7", "Configuration": "1 axis tracker", "Rendement (kWh/kWc)": "1834", "Production annuelle / P50 (MWh)": "18766", "Type de terrain": "Agricultural land (organic cultivation)", "Activité": "Cultures bio", "Contrat foncier": "PdBS", "Contrat foncier signé ?": "Yes\\n05/03/2024\\nAmendement signé 25/10/2024", "Durée contrat (ans)": "6 + 2×3 ans", "Prix (EUR ou EUR/Ha/an)": "1500 land lease \\n+1500 agriculture agreement", "Aire du terrain (Ha)": "17", "Études techniques et d’optimisation agricole": "Ongoing", "Environnement & contraintes": "captage eau / PPR, zone industrielle", "EIE (EIA)\\nEnvironmental Impact Assessment": "Ongoing", "Urbanisme": "A - PLU", "Type permis": "PC", "Statut permis": "A déposer", "Date de Dépot": "Q2 2026", "Date obtention": "Q2 2027", "Gestionnaire réseau": "Enedis", "Prix raccordement (€)": "~1.12 M€ (Works + QP)", "Distance point connexion (km)": "6.4", "PRD (Planned Raccordement Date)": "2029", "Type d'offtake": "AO CRE", "Lien - Project teaser": "Viridi", "Date added / updated": "Feb 2026"}	Mid	✅ Foncier sécurisé / 📝 Env ongoing	Land secured	À déposer (Q2 2026)
149	Les Brissaudières	\N	solar	early	15.5	FR	Centre-Val de Loire	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.385441	2026-06-18 02:18:18.385441	Viridi	15	Sol	Early-(3) Environment & (5) Grid connection\\nLand fully secured; environmental studies ongoing; PRAC grid connection study in progress including hybrid BESS option; permit application targeted for 2027.	19185	Lignières-de-Touraine\nAzay-le-Rideau	Indre-et-Loire (37)	37	Q4 2028	Q4 2029	\N	\N	t	Enedis	69040	AO CRE	{"Code": "15", "Actionnariat SPV (%)": "Viridi", "Nom du projet": "Les Brissaudières", "État de développement": "Early-(3) Environment & (5) Grid connection\\nLand fully secured; environmental studies ongoing; PRAC grid connection study in progress including hybrid BESS option; permit application targeted for 2027.", "Technologie": "AgriPV", "Typologie": "Sol", "Date RTB estimée": "Q4 2028", "Date COD estimée": "Q4 2029", "Ville / Commune": "Lignières-de-Touraine\\nAzay-le-Rideau", "Code postal": "37130", "Département": "Indre-et-Loire (37)", "Région": "Centre-Val de Loire", "Puissance installée (MWc)": "15.5", "Configuration": "1 axis tracker", "Rendement (kWh/kWc)": "1238", "Production annuelle / P50 (MWh)": "19185", "Activité": "production fourragère pour élevage", "Contrat foncier": "PdBS", "Contrat foncier signé ?": "Yes\\nQ4 2024\\nQ1/Q2 2025", "Durée contrat (ans)": "6 + 2×3 ans", "Prix (EUR ou EUR/Ha/an)": "2500€/MW + 2500€/MW", "Aire du terrain (Ha)": "30", "Environnement & contraintes": "parc Loire-Anjou-Touraine, château 500 m", "EIE (EIA)\\nEnvironmental Impact Assessment": "Ongoing", "Urbanisme": "A - PLU", "Type permis": "PC", "Statut permis": "A déposer", "Date de Dépot": "Q2 2027", "Date obtention": "Q2 2028", "Gestionnaire réseau": "Enedis", "Prix raccordement (€)": "QP = 69 040 €/MW (pas le total)", "Distance point connexion (km)": "3", "Type d'offtake": "AO CRE", "Lien - Project teaser": "Viridi", "Date added / updated": "Feb 2026"}	Early	✅ Foncier sécurisé / 📝 Env ongoing	Land fully secured	À déposer (Q2 2027)
155	SPT	\N	solar	nearly_secured	3	FR	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.385441	2026-06-18 02:18:18.385441	Ecodd	21	\N	Secured & clean of appeal-(7) RTB – Ready To Build\\nPermis purgé + “Certificat Enedis OUI (11/17/2025)” + PRAC	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	601.77	AO CRE	{"Code": "21", "Actionnariat SPV (%)": "Ecodd", "Nom du projet": "SPT", "État de développement": "Secured & clean of appeal-(7) RTB – Ready To Build\\nPermis purgé + “Certificat Enedis OUI (11/17/2025)” + PRAC", "Puissance installée (MWc)": "3", "Rendement (kWh/kWc)": "1254", "Contrat foncier": "PDB", "Prix (EUR ou EUR/Ha/an)": "7980.00", "Aire du terrain (Ha)": "2.66", "Statut permis": "Purgé", "Date de Dépot": "2/23/2023", "Date obtention": "8/14/2024", "Date purge": "10/14/2024", "Prix raccordement (€)": "601,770 PRAC", "Type d'offtake": "AO CRE", "Lien - Project teaser": "Ecodd", "Date added / updated": "Jan 2026"}	Secured & clean	✅ PC purgé	Secured & clean of appeal-(7…	Purgé (10/14/2024)
181	Peyrusse-Vieille	\N	solar	early	13	FR	Occitanie	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.426949	2026-06-18 02:18:18.426949	Recurrent Energy	47	Sol	Early-(4) Autorisations administratives\\nPermis à déposer – études environnementales en cours	\N	Peyrusse-Vieille	Gers (32)	\N	Q2 2029	Q4 2031	\N	\N	t	\N	1065682	AO CRE	{"Code": "47", "Actionnariat SPV (%)": "Recurrent Energy", "Nom du projet": "Peyrusse-Vieille", "État de développement": "Early-(4) Autorisations administratives\\nPermis à déposer – études environnementales en cours", "Technologie": "AgriPV", "Typologie": "Sol", "Date RTB estimée": "Q2 2029", "Date COD estimée": "Q4 2031", "Ville / Commune": "Peyrusse-Vieille", "Département": "Gers (32)", "Région": "Occitanie", "Puissance installée (MWc)": "13", "Configuration": "Tracker 2P", "Rendement (kWh/kWc)": "1309", "Type de terrain": "Crops", "Activité": "Mixte", "Contrat foncier": "Bail", "Prix (EUR ou EUR/Ha/an)": "1850 (to be confirmed)", "Aire du terrain (Ha)": "73", "EIE (EIA)\\nEnvironmental Impact Assessment": "Q3 2026", "Type permis": "PC", "Date de Dépot": "Q4 2026", "Date obtention": "Q2 2028", "Prix raccordement (€)": "1065682", "Distance point connexion (km)": "3.8", "Type d'offtake": "AO CRE", "Signé ?": "Non", "Lien - Project teaser": "Recurrent Energy", "Date added / updated": "Feb 2026"}	Early	✅ Foncier sécurisé / 📝 Env ongoing	\N	À déposer (Q4 2026)
163	ST-DENIS-DE-JOUHET (36)	\N	solar	submit	10	FR	Centre-Val de Loire	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.385441	2026-06-18 02:18:18.385441	ADEN	29	Sol	Early-(3) Environnement / pré-permitting\\nPC à déposer 07/2026, raccordement “en instruction 11/2027”	7400	St-Denis-de-Jouhet	36	\N	06/2028	12/2028	\N	\N	t	\N	\N	AO CfD	{"Code": "29", "Actionnariat SPV (%)": "ADEN", "Nom du projet": "ST-DENIS-DE-JOUHET (36)", "État de développement": "Early-(3) Environnement / pré-permitting\\nPC à déposer 07/2026, raccordement “en instruction 11/2027”", "Technologie": "AgriPV", "Typologie": "Sol", "Date RTB estimée": "06/2028", "Date COD estimée": "12/2028", "Ville / Commune": "St-Denis-de-Jouhet", "Département": "36", "Région": "Centre-Val de Loire", "Puissance installée (MWc)": "10", "Puissance injectée réseau (MWac)": "TBD", "Type d’implantation": "AgriPV\\nCow", "Configuration": "Trackers", "Rendement (kWh/kWc)": "1360", "Production annuelle / P50 (MWh)": "7400", "Type de terrain": "Agricole", "Contrat foncier": "Bail", "Contrat foncier signé ?": "Yes\\n12/1/2023", "Aire du terrain (Ha)": "16", "Support administration locale": "Conforme local", "Statut permis": "A déposer", "Date de Dépot": "07/2026", "Date obtention": "7/1/2027", "Distance point connexion (km)": "8", "Type d'offtake": "AO CfD", "Signé ?": "02/2028", "Durée du contrat Offtake (ans)": "-", "Tariff (EUR/kWh)": "~0.07–0.08", "Lien - Project teaser": "Aden", "Date added / updated": "Feb 2026"}	Early	✅ Autorités locales / 📝 Dépôt PC imminent	\N	À déposer (07/2026)
162	Qui	\N	solar	mid	24	FR	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.385441	2026-06-18 02:18:18.385441	Ecodd (50%)\n(50% régie électrique)	28	\N	Advanced-(4) Autorisations administratives\\nPC déposé 11/10/2023, obtention prévue 07/2026, purge 08/2026	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	4900	AO CRE	{"Code": "28", "Actionnariat SPV (%)": "Ecodd (50%)\\n(50% régie électrique)", "Nom du projet": "Qui", "État de développement": "Advanced-(4) Autorisations administratives\\nPC déposé 11/10/2023, obtention prévue 07/2026, purge 08/2026", "Puissance installée (MWc)": "24", "Rendement (kWh/kWc)": "1456", "Contrat foncier": "PDB", "Prix (EUR ou EUR/Ha/an)": "319000.00", "Aire du terrain (Ha)": "30", "Statut permis": "Déposé", "Date de Dépot": "11/10/2023", "Date obtention": "prévue pour 07/2026", "Date purge": "8/30/2026", "Prix raccordement (€)": "4,900,000 PRAC", "Type d'offtake": "AO CRE", "Lien - Project teaser": "Ecodd", "Date added / updated": "Jan 2026"}	Advanced	✅ Foncier sécurisé / ✅ PC déposé / 📝 En instruction	\N	Submitted (11/10/2023)
166	ST JEANNET (04)	\N	solar	submit	20	FR	PACA	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.385441	2026-06-18 02:18:18.385441	ADEN	32	Sol	Early-(3) Environnement / pré-permitting\\nPC à déposer 04/2027, raccordement “en instruction 07/2028”	32000	St Jeannet	4	\N	06/2029	06/2030	\N	\N	t	\N	\N	AO CfD	{"Code": "32", "Actionnariat SPV (%)": "ADEN", "Nom du projet": "ST JEANNET (04)", "État de développement": "Early-(3) Environnement / pré-permitting\\nPC à déposer 04/2027, raccordement “en instruction 07/2028”", "Technologie": "AgriPV", "Typologie": "Sol", "Date RTB estimée": "06/2029", "Date COD estimée": "06/2030", "Ville / Commune": "St Jeannet", "Département": "4", "Région": "PACA", "Puissance installée (MWc)": "20", "Configuration": "Fix and trackers", "Rendement (kWh/kWc)": "1600", "Production annuelle / P50 (MWh)": "32000", "Type de terrain": "Agricole", "Contrat foncier": "Bail", "Contrat foncier signé ?": "Yes\\n11/2025", "Aire du terrain (Ha)": "50", "Support administration locale": "Conforme zone", "Statut permis": "A déposer", "Date de Dépot": "04/2027", "Date obtention": "04/2028", "Distance point connexion (km)": "20", "Type d'offtake": "AO CfD", "Signé ?": "02/2029", "Durée du contrat Offtake (ans)": "-", "Tariff (EUR/kWh)": "~0.07–0.08", "Lien - Project teaser": "Aden", "Date added / updated": "Feb 2026"}	Early	✅ Autorités locales / 📝 Dépôt PC imminent	\N	À déposer (04/2027)
171	Pr5	\N	solar	nearly_secured	0.35	FR	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.426949	2026-06-18 02:18:18.426949	Novabridge	37	Toiture	Secured & clean of appeal-(5) Raccordement au réseau\\nPC purgé	1000	Carignan	ARDENNES (08)	\N	\N	\N	\N	\N	t	\N	\N	\N	{"Code": "37", "Actionnariat SPV (%)": "Novabridge", "Nom du projet": "Pr5", "État de développement": "Secured & clean of appeal-(5) Raccordement au réseau\\nPC purgé", "Technologie": "AgriPV", "Typologie": "Toiture", "Ville / Commune": "Carignan", "Département": "ARDENNES (08)", "Puissance installée (MWc)": "0.35", "Production annuelle / P50 (MWh)": "1000", "Contrat foncier": "Bail", "Contrat foncier signé ?": "Yes", "Durée contrat (ans)": "30", "Type permis": "PC", "Statut permis": "Purgé", "Date purge": "TBD", "Distance point connexion (km)": "0.2", "Lien - Project teaser": "Novabridge", "Date added / updated": "Feb 2026"}	Secured & clean	✅ PC purgé	\N	Purgé
172	Pr6	\N	solar	nearly_secured	0.4	FR	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.426949	2026-06-18 02:18:18.426949	Novabridge	38	Toiture	Secured & clean of appeal-(5) Raccordement au réseau\\nPC purgé	1000	Fromy	ARDENNES (08)	\N	\N	\N	\N	\N	t	\N	\N	\N	{"Code": "38", "Actionnariat SPV (%)": "Novabridge", "Nom du projet": "Pr6", "État de développement": "Secured & clean of appeal-(5) Raccordement au réseau\\nPC purgé", "Technologie": "AgriPV", "Typologie": "Toiture", "Ville / Commune": "Fromy", "Département": "ARDENNES (08)", "Puissance installée (MWc)": "0.4", "Production annuelle / P50 (MWh)": "1000", "Contrat foncier": "Bail", "Contrat foncier signé ?": "Yes", "Durée contrat (ans)": "30", "Type permis": "PC", "Statut permis": "Purgé", "Date purge": "TBD", "Distance point connexion (km)": "0.25", "Lien - Project teaser": "Novabridge", "Date added / updated": "Feb 2026"}	Secured & clean	✅ PC purgé	\N	Purgé
174	Pr8	\N	solar	nearly_secured	0.2	FR	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.426949	2026-06-18 02:18:18.426949	Novabridge	40	Toiture	Secured & clean of appeal-(5) Raccordement au réseau\\nPC purgé	1200	Canet-de-Salars	AVEYRON (12)	\N	\N	\N	\N	\N	t	\N	\N	\N	{"Code": "40", "Actionnariat SPV (%)": "Novabridge", "Nom du projet": "Pr8", "État de développement": "Secured & clean of appeal-(5) Raccordement au réseau\\nPC purgé", "Technologie": "AgriPV", "Typologie": "Toiture", "Ville / Commune": "Canet-de-Salars", "Département": "AVEYRON (12)", "Puissance installée (MWc)": "0.2", "Production annuelle / P50 (MWh)": "1200", "Contrat foncier": "Bail", "Contrat foncier signé ?": "Yes", "Durée contrat (ans)": "30", "Type permis": "PC", "Statut permis": "Purgé", "Date purge": "TBD", "Distance point connexion (km)": "0.23", "Lien - Project teaser": "Novabridge", "Date added / updated": "Feb 2026"}	Secured & clean	✅ PC purgé	\N	Purgé
175	Pr9	\N	solar	nearly_secured	0.2	FR	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.426949	2026-06-18 02:18:18.426949	Novabridge	41	Toiture	Secured & clean of appeal-(5) Raccordement au réseau\\nPC purgé	1100	Saint-Julien-aux-Bois	CORREZE (19)	\N	\N	\N	\N	\N	t	\N	\N	\N	{"Code": "41", "Actionnariat SPV (%)": "Novabridge", "Nom du projet": "Pr9", "État de développement": "Secured & clean of appeal-(5) Raccordement au réseau\\nPC purgé", "Technologie": "AgriPV", "Typologie": "Toiture", "Ville / Commune": "Saint-Julien-aux-Bois", "Département": "CORREZE (19)", "Puissance installée (MWc)": "0.2", "Production annuelle / P50 (MWh)": "1100", "Contrat foncier": "Bail", "Contrat foncier signé ?": "Yes", "Durée contrat (ans)": "30", "Type permis": "PC", "Statut permis": "Purgé", "Date purge": "TBD", "Distance point connexion (km)": "0.25", "Lien - Project teaser": "Novabridge", "Date added / updated": "Feb 2026"}	Secured & clean	✅ PC purgé	\N	Purgé
185	PR_FR_0124	\N	solar	origination	12.15	FR	Occitanie	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.426949	2026-06-18 02:18:18.426949	Renergies	51	Sol	3. Etudes environnementales	\N	\N	Gard (30)	\N	31/03/2027	29/03/2029	\N	\N	t	\N	\N	\N	{"Code": "51", "Actionnariat SPV (%)": "Renergies", "Nom du projet": "PR_FR_0124", "État de développement": "3. Etudes environnementales", "Technologie": "AgriPV", "Typologie": "Sol", "Date RTB estimée": "31/03/2027", "Date COD estimée": "29/03/2029", "Département": "Gard (30)", "Région": "Occitanie", "Puissance installée (MWc)": "12.15", "Puissance injectée réseau (MWac)": "9.86", "Type d’implantation": "AgriPV\\n Livestock farming", "Activité": "Livestock farming", "Lien - Project teaser": "renergies-Active  SFS Projects FRANCE AM 13 04 2026.xlsx", "Date added / updated": "Apr 2026"}	Origination	🔍 Identification foncier en cours	\N	Pas d'info
186	PR_FR_0019	\N	solar	origination	7.18	FR	Pays de la Loire	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.426949	2026-06-18 02:18:18.426949	Renergies	52	Sol	3. Etudes environnementales	\N	\N	Maine-et-Loire (49)	\N	31/03/2027	31/03/2028	\N	\N	t	\N	\N	\N	{"Code": "52", "Actionnariat SPV (%)": "Renergies", "Nom du projet": "PR_FR_0019", "État de développement": "3. Etudes environnementales", "Technologie": "AgriPV", "Typologie": "Sol", "Date RTB estimée": "31/03/2027", "Date COD estimée": "31/03/2028", "Département": "Maine-et-Loire (49)", "Région": "Pays de la Loire", "Puissance installée (MWc)": "7.18", "Puissance injectée réseau (MWac)": "5.98", "Type d’implantation": "AgriPV\\n Livestock farming", "Activité": "Livestock farming", "Lien - Project teaser": "renergies-Active  SFS Projects FRANCE AM 13 04 2026.xlsx", "Date added / updated": "Apr 2026"}	Origination	🔍 Identification foncier en cours	\N	Pas d'info
187	PR_FR_0029	\N	solar	origination	16.6	FR	Auvergne-Rhône-Alpes	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.453033	2026-06-18 02:18:18.453033	Renergies	53	Sol	3. Etudes environnementales	\N	\N	Allier (03)	\N	31/03/2027	31/03/2029	\N	\N	t	\N	\N	\N	{"Code": "53", "Actionnariat SPV (%)": "Renergies", "Nom du projet": "PR_FR_0029", "État de développement": "3. Etudes environnementales", "Technologie": "AgriPV", "Typologie": "Sol", "Date RTB estimée": "31/03/2027", "Date COD estimée": "31/03/2029", "Département": "Allier (03)", "Région": "Auvergne-Rhône-Alpes", "Puissance installée (MWc)": "16.6", "Puissance injectée réseau (MWac)": "13.7", "Type d’implantation": "AgriPV\\n Livestock farming", "Activité": "Livestock farming", "Lien - Project teaser": "renergies-Active  SFS Projects FRANCE AM 13 04 2026.xlsx", "Date added / updated": "Apr 2026"}	Origination	🔍 Identification foncier en cours	\N	Pas d'info
188	PR_FR_0022	\N	solar	origination	5.5	FR	Auvergne-Rhône-Alpes	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.453033	2026-06-18 02:18:18.453033	Renergies	54	Sol	3. Etudes environnementales	\N	Luzinay	Isère (38)	\N	31/03/2027	31/03/2028	\N	\N	t	\N	\N	\N	{"Code": "54", "Actionnariat SPV (%)": "Renergies", "Nom du projet": "PR_FR_0022", "État de développement": "3. Etudes environnementales", "Technologie": "AgriPV", "Typologie": "Sol", "Date RTB estimée": "31/03/2027", "Date COD estimée": "31/03/2028", "Ville / Commune": "Luzinay", "Département": "Isère (38)", "Région": "Auvergne-Rhône-Alpes", "Puissance installée (MWc)": "5.5", "Puissance injectée réseau (MWac)": "4.93", "Type d’implantation": "AgriPV\\n Livestock farming", "Activité": "Livestock farming", "Lien - Project teaser": "renergies-Active  SFS Projects FRANCE AM 13 04 2026.xlsx", "Date added / updated": "Apr 2026"}	Origination	🔍 Identification foncier en cours	\N	Pas d'info
189	PR_FR_0020	\N	solar	origination	4.07	FR	Auvergne-Rhône-Alpes	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.453033	2026-06-18 02:18:18.453033	Renergies	55	Sol	3. Etudes environnementales	\N	\N	Allier (03)	\N	31/03/2027	31/03/2028	\N	\N	t	\N	\N	\N	{"Code": "55", "Actionnariat SPV (%)": "Renergies", "Nom du projet": "PR_FR_0020", "État de développement": "3. Etudes environnementales", "Technologie": "AgriPV", "Typologie": "Sol", "Date RTB estimée": "31/03/2027", "Date COD estimée": "31/03/2028", "Département": "Allier (03)", "Région": "Auvergne-Rhône-Alpes", "Puissance installée (MWc)": "4.07", "Puissance injectée réseau (MWac)": "3.17", "Type d’implantation": "AgriPV\\n Livestock farming", "Activité": "Livestock farming", "Lien - Project teaser": "renergies-Active  SFS Projects FRANCE AM 13 04 2026.xlsx", "Date added / updated": "Apr 2026"}	Origination	🔍 Identification foncier en cours	\N	Pas d'info
190	PR_FR_0021	\N	solar	origination	10.74	FR	Auvergne-Rhône-Alpes	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.453033	2026-06-18 02:18:18.453033	Renergies	56	Sol	3. Etudes environnementales	\N	\N	Rhône (69)	\N	31/03/2027	31/03/2028	\N	\N	t	\N	\N	\N	{"Code": "56", "Actionnariat SPV (%)": "Renergies", "Nom du projet": "PR_FR_0021", "État de développement": "3. Etudes environnementales", "Technologie": "AgriPV", "Typologie": "Sol", "Date RTB estimée": "31/03/2027", "Date COD estimée": "31/03/2028", "Département": "Rhône (69)", "Région": "Auvergne-Rhône-Alpes", "Puissance installée (MWc)": "10.74", "Puissance injectée réseau (MWac)": "9.86", "Type d’implantation": "AgriPV\\n Livestock farming", "Activité": "Livestock farming", "Lien - Project teaser": "renergies-Active  SFS Projects FRANCE AM 13 04 2026.xlsx", "Date added / updated": "Apr 2026"}	Origination	🔍 Identification foncier en cours	\N	Pas d'info
191	PR_FR_0025	\N	solar	origination	4.92	FR	Occitanie	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.453033	2026-06-18 02:18:18.453033	Renergies	57	Sol	3. Etudes environnementales	\N	\N	Gard (30)	\N	31/03/2027	31/03/2029	\N	\N	t	\N	\N	\N	{"Code": "57", "Actionnariat SPV (%)": "Renergies", "Nom du projet": "PR_FR_0025", "État de développement": "3. Etudes environnementales", "Technologie": "AgriPV", "Typologie": "Sol", "Date RTB estimée": "31/03/2027", "Date COD estimée": "31/03/2029", "Département": "Gard (30)", "Région": "Occitanie", "Puissance installée (MWc)": "4.92", "Puissance injectée réseau (MWac)": "4.22", "Type d’implantation": "AgriPV\\n Livestock farming", "Activité": "Livestock farming", "Lien - Project teaser": "renergies-Active  SFS Projects FRANCE AM 13 04 2026.xlsx", "Date added / updated": "Apr 2026"}	Origination	🔍 Identification foncier en cours	\N	Pas d'info
180	Peyrusse-Grande	\N	solar	early	15	FR	Occitanie	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.426949	2026-06-18 02:18:18.426949	Recurrent Energy	46	Sol	Early-(4) Autorisations administratives\\nPermis à déposer – études environnementales en cours	\N	Peyrusse-Grande	Gers (32)	\N	Q3 2030	Q1 2033	\N	\N	t	\N	1932685	AO CRE	{"Code": "46", "Actionnariat SPV (%)": "Recurrent Energy", "Nom du projet": "Peyrusse-Grande", "État de développement": "Early-(4) Autorisations administratives\\nPermis à déposer – études environnementales en cours", "Technologie": "AgriPV", "Typologie": "Sol", "Date RTB estimée": "Q3 2030", "Date COD estimée": "Q1 2033", "Ville / Commune": "Peyrusse-Grande", "Département": "Gers (32)", "Région": "Occitanie", "Puissance installée (MWc)": "15", "Configuration": "Tracker 2P", "Rendement (kWh/kWc)": "1311", "Type de terrain": "Meadow", "Activité": "Élevage bovin", "Contrat foncier": "Bail", "Prix (EUR ou EUR/Ha/an)": "1850 (to be confirmed)", "Aire du terrain (Ha)": "31", "EIE (EIA)\\nEnvironmental Impact Assessment": "Q3 2027", "Type permis": "PC", "Date de Dépot": "Q4 2027", "Date obtention": "Q2 2029", "Prix raccordement (€)": "1932685", "Distance point connexion (km)": "6.7", "Type d'offtake": "AO CRE", "Signé ?": "Non", "Lien - Project teaser": "Recurrent Energy", "Date added / updated": "Feb 2026"}	Early	✅ Foncier sécurisé / 📝 Env ongoing	\N	À déposer (Q4 2027)
157	VIV	\N	solar	mid	13	FR	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.385441	2026-06-18 02:18:18.385441	Ecodd	23	\N	Advanced-(4) Autorisations administratives\\nPC déposé, purge prévue (09/2026)	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2500	PPA	{"Code": "23", "Actionnariat SPV (%)": "Ecodd", "Nom du projet": "VIV", "État de développement": "Advanced-(4) Autorisations administratives\\nPC déposé, purge prévue (09/2026)", "Puissance installée (MWc)": "13", "Rendement (kWh/kWc)": "1449", "Contrat foncier": "PDB", "Prix (EUR ou EUR/Ha/an)": "94700.00", "Aire du terrain (Ha)": "10.76", "Statut permis": "Déposé", "Date de Dépot": "12/17/2024", "Date obtention": "7/30/2026", "Date purge": "9/30/2026", "Prix raccordement (€)": "2,500,000", "Type d'offtake": "PPA", "Lien - Project teaser": "Ecodd", "Date added / updated": "Jan 2026"}	Advanced	✅ Foncier sécurisé / ✅ PC déposé / 📝 En instruction	\N	Submitted (12/17/2024)
167	Pr1	\N	solar	nearly_secured	0.1	FR	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.426949	2026-06-18 02:18:18.426949	Novabridge	33	Toiture	Secured & clean of appeal-(5) Raccordement au réseau\\nPC purgé	1000	Genouillac	CREUSE (23)	\N	\N	\N	\N	\N	t	\N	\N	\N	{"Code": "33", "Actionnariat SPV (%)": "Novabridge", "Nom du projet": "Pr1", "État de développement": "Secured & clean of appeal-(5) Raccordement au réseau\\nPC purgé", "Technologie": "AgriPV", "Typologie": "Toiture", "Ville / Commune": "Genouillac", "Département": "CREUSE (23)", "Puissance installée (MWc)": "0.1", "Production annuelle / P50 (MWh)": "1000", "Contrat foncier": "Bail", "Contrat foncier signé ?": "Yes", "Durée contrat (ans)": "30", "Type permis": "PC", "Statut permis": "Purgé", "Date purge": "TBD", "Distance point connexion (km)": "0.02", "Lien - Project teaser": "Novabridge", "Date added / updated": "Feb 2026"}	Secured & clean	✅ PC purgé	\N	Purgé
173	Pr7	\N	solar	nearly_secured	0.25	FR	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.426949	2026-06-18 02:18:18.426949	Novabridge	39	Toiture	Secured & clean of appeal-(5) Raccordement au réseau\\nPC purgé	1200	Crest	DROME (26)	\N	\N	\N	\N	\N	t	\N	\N	\N	{"Code": "39", "Actionnariat SPV (%)": "Novabridge", "Nom du projet": "Pr7", "État de développement": "Secured & clean of appeal-(5) Raccordement au réseau\\nPC purgé", "Technologie": "AgriPV", "Typologie": "Toiture", "Ville / Commune": "Crest", "Département": "DROME (26)", "Puissance installée (MWc)": "0.25", "Production annuelle / P50 (MWh)": "1200", "Contrat foncier": "Bail", "Contrat foncier signé ?": "Yes", "Durée contrat (ans)": "30", "Type permis": "PC", "Statut permis": "Purgé", "Date purge": "TBD", "Distance point connexion (km)": "0.13", "Lien - Project teaser": "Novabridge", "Date added / updated": "Feb 2026"}	Secured & clean	✅ PC purgé	\N	Purgé
156	Saint-Denis-Catus	\N	solar	mid	4	FR	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.385441	2026-06-18 02:18:18.385441	Ecodd	22	Sol	Advanced-(4) Autorisations administrative\\nPC déposé (04/2025), obtention prévue 07/2026	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	970	AO CRE	{"Code": "22", "Actionnariat SPV (%)": "Ecodd", "Nom du projet": "Saint-Denis-Catus", "État de développement": "Advanced-(4) Autorisations administrative\\nPC déposé (04/2025), obtention prévue 07/2026", "Technologie": "AgriPV", "Typologie": "Sol", "Puissance installée (MWc)": "4", "Rendement (kWh/kWc)": "1414", "Contrat foncier": "PDB", "Prix (EUR ou EUR/Ha/an)": "8100.00", "Aire du terrain (Ha)": "6", "Statut permis": "Déposé", "Date de Dépot": "4/15/2025", "Date obtention": "prévue pour 07/2026", "Date purge": "NA", "Prix raccordement (€)": "970,000 PRAC", "Type d'offtake": "AO CRE", "Lien - Project teaser": "Ecodd", "Date added / updated": "Jan 2026"}	Advanced	✅ Foncier sécurisé / ✅ PC déposé / 📝 En instruction	\N	Submitted (4/15/2025)
154	Up	\N	solar	nearly_secured	1.508	FR	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.385441	2026-06-18 02:18:18.385441	Ecodd	20	\N	Nearly secured-(4) Autorisations administrative\\nStatut permis Recours	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	329.741	AO CRE	{"Code": "20", "Actionnariat SPV (%)": "Ecodd", "Nom du projet": "Up", "État de développement": "Nearly secured-(4) Autorisations administrative\\nStatut permis Recours", "Puissance installée (MWc)": "1.508", "Rendement (kWh/kWc)": "1479", "Contrat foncier": "PDB", "Prix (EUR ou EUR/Ha/an)": "11000.00", "Aire du terrain (Ha)": "2.2", "Statut permis": "Recours", "Date de Dépot": "12/19/2025", "Date obtention": "6/30/2025", "Date purge": "8/30/2026", "Prix raccordement (€)": "329,741 PRAC", "Type d'offtake": "AO CRE", "Lien - Project teaser": "Ecodd", "Date added / updated": "Jan 2026"}	Nearly secured	✅ PC obtenu / ⚖️ Recours	\N	Obtenu (recours) - purge prévue 8/30/2026
177	Reterre	\N	solar	early	20	FR	Nouvelle-Aquitaine	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.426949	2026-06-18 02:18:18.426949	Recurrent Energy	43	Sol	Early-(4) Autorisations administratives\\nPermis à déposer – études environnementales en cours	\N	Reterre	CREUSE (23)	\N	Q4 2029	Q2 2032	\N	\N	t	\N	2571001	AO CRE	{"Code": "43", "Actionnariat SPV (%)": "Recurrent Energy", "Nom du projet": "Reterre", "État de développement": "Early-(4) Autorisations administratives\\nPermis à déposer – études environnementales en cours", "Technologie": "AgriPV", "Typologie": "Sol", "Date RTB estimée": "Q4 2029", "Date COD estimée": "Q2 2032", "Ville / Commune": "Reterre", "Département": "CREUSE (23)", "Région": "Nouvelle-Aquitaine", "Puissance installée (MWc)": "20", "Configuration": "Tracker 2P", "Rendement (kWh/kWc)": "1259", "Type de terrain": "Meadow", "Activité": "Élevage bovin", "Contrat foncier": "Bail", "Prix (EUR ou EUR/Ha/an)": "1900 (to be confirmed)", "Aire du terrain (Ha)": "58", "EIE (EIA)\\nEnvironmental Impact Assessment": "Q1 2027", "Type permis": "PC", "Date de Dépot": "Q2 2027", "Date obtention": "Q4 2028", "Prix raccordement (€)": "2571001", "Distance point connexion (km)": "10", "Type d'offtake": "AO CRE", "Signé ?": "Non", "Lien - Project teaser": "Recurrent Energy", "Date added / updated": "Feb 2026"}	Early	✅ Foncier sécurisé / 📝 Env ongoing	\N	À déposer (Q2 2027)
184	Sury	\N	solar	mid	9.77	FR	Centre-Val de Loire	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.426949	2026-06-18 02:18:18.426949	Recurrent Energy	50	Sol	Advanced-(4) Autorisations administratives\\nPermis en instruction	\N	Sury-près-Léré	Cher (18)	\N	Q1 2028	Q1 2031	\N	\N	t	\N	1249232	AO CRE	{"Code": "50", "Actionnariat SPV (%)": "Recurrent Energy", "Nom du projet": "Sury", "État de développement": "Advanced-(4) Autorisations administratives\\nPermis en instruction", "Technologie": "AgriPV", "Typologie": "Sol", "Date RTB estimée": "Q1 2028", "Date COD estimée": "Q1 2031", "Ville / Commune": "Sury-près-Léré", "Département": "Cher (18)", "Région": "Centre-Val de Loire", "Puissance installée (MWc)": "9.77", "Configuration": "Tracker 2P", "Rendement (kWh/kWc)": "1186", "Type de terrain": "Meadow and wheat", "Activité": "Élevage bovin", "Contrat foncier": "Bail", "Prix (EUR ou EUR/Ha/an)": "1800 (to be confirmed)", "Aire du terrain (Ha)": "30.7", "EIE (EIA)\\nEnvironmental Impact Assessment": "Yes", "Type permis": "PC", "Date de Dépot": "Q4 2025", "Date obtention": "Q3 2027", "Prix raccordement (€)": "1249232", "Distance point connexion (km)": "6", "Type d'offtake": "AO CRE", "Signé ?": "Non", "Lien - Project teaser": "Recurrent Energy", "Date added / updated": "Feb 2026"}	Advanced	✅ Foncier sécurisé / ✅ PC déposé / 📝 En instruction	\N	Submitted (Q4 2025)
192	Mairie de Montfrin	8	solar	origination	0.2	FR	Occitanie	\N	\N	\N	Toiture 200 kWc avec desamiantage. CAPEX 265 400€, CA 27 200€/an. Production 255 712 kWh/an.	https://docs.google.com/presentation/d/18cQ_KILSI26t8R4OUzNCAW9U5XV42lyK/edit	Oui	Le maire de Montfrin est un ami de Stephane (il habite la commune). Etude concurrente transmise par le maire. Adresse : 47 avenue du docteur Felix Clement.	2026-06-22 10:24:34.686896	2026-06-22 10:24:34.686896	Stephane Gilli	\N	\N	\N	255.7	Montfrin	Gard	30	\N	\N	\N	\N	f	\N	\N	Autoconsommation collective	{"Code": "192", "Adresse": "47 avenue du docteur Félix Clément", "Ville / Commune": "Montfrin", "Département": "Gard (30)", "Région": "Occitanie", "Technologie": "Solaire", "Typologie": "Toiture", "Puissance installée (MWc)": "0.2", "Production annuelle / P50 (MWh)": "255.7", "Consommation commune (kWh/an)": "453 900", "Type d'offtake": "Autoconsommation collective", "CAPEX (€)": "265 400", "CA prévisionnel (€/an)": "27 200", "Type de terrain": "Toiture bâtiment communal", "Désamiantage": "Oui — bâtiment à désamianter", "Notes": "Batiment a desamianter. Le maire de Montfrin est un ami de Stephane (il habite la commune). Etude concurrente realisee il y a 2 ans transmise par le maire. Consommation commune : 453 900 kWh/an.", "Lien - Project teaser": "https://docs.google.com/presentation/d/18cQ_KILSI26t8R4OUzNCAW9U5XV42lyK/edit", "Date added / updated": "18/03/2026", "Surface totale (m²)": "—"}	\N	Origination - étude en cours, maire favorable	Origination - study in progress, mayor favorable	\N
153	CER	\N	solar	mid	3.01	FR	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.385441	2026-06-18 02:18:18.385441	Ecodd	19	Sol	Advanced-(4) Autorisations administrative\\nPC déposé 12/10/2025, obtention prévue 07/2026	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	400	AO CRE	{"Code": "19", "Actionnariat SPV (%)": "Ecodd", "Nom du projet": "CER", "État de développement": "Advanced-(4) Autorisations administrative\\nPC déposé 12/10/2025, obtention prévue 07/2026", "Technologie": "AgriPV", "Typologie": "Sol", "Puissance installée (MWc)": "3.01", "Type d’implantation": "AgriPV\\nsous cerisier", "Rendement (kWh/kWc)": "1515", "Contrat foncier": "PDB", "Prix (EUR ou EUR/Ha/an)": "15750.00", "Aire du terrain (Ha)": "5", "Statut permis": "Déposé", "Date de Dépot": "12/10/2025", "Date obtention": "7/30/2026", "Prix raccordement (€)": "400,000 Estm Enedis", "Type d'offtake": "AO CRE", "Lien - Project teaser": "Ecodd", "Date added / updated": "Jan 2026"}	Advanced	✅ Foncier sécurisé / ✅ PC déposé / 📝 En instruction	\N	Submitted (12/10/2025)
159	LBP	\N	solar	nearly_secured	5.1	FR	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.385441	2026-06-18 02:18:18.385441	Ecodd	25	\N	Secured & clean of appeal-(5) Raccordement au réseau\\nPermis purgé (12/2025) + PRAC (coût réseau)	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	1210.43	AO CRE	{"Code": "25", "Actionnariat SPV (%)": "Ecodd", "Nom du projet": "LBP", "État de développement": "Secured & clean of appeal-(5) Raccordement au réseau\\nPermis purgé (12/2025) + PRAC (coût réseau)", "Puissance installée (MWc)": "5.1", "Rendement (kWh/kWc)": "1406", "Contrat foncier": "PDB", "Prix (EUR ou EUR/Ha/an)": "36000.00", "Aire du terrain (Ha)": "4.6", "Statut permis": "Purgé", "Date de Dépot": "5/22/2025", "Date obtention": "10/9/2025", "Date purge": "12/9/2025", "Prix raccordement (€)": "1,210,430 PRAC", "Type d'offtake": "AO CRE", "Lien - Project teaser": "Ecodd", "Date added / updated": "Jan 2026"}	Secured & clean	✅ PC purgé	\N	Purgé (12/9/2025)
158	LGC	\N	solar	mid	13.5	FR	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.385441	2026-06-18 02:18:18.385441	Ecodd (50 %)\n(EDF 50%)	24	\N	Advanced-(4) Autorisations administratives\\nPC déposé (date incohérente “1905??”), obtention prévue 07/2026	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	1931.152	AO CRE	{"Code": "24", "Actionnariat SPV (%)": "Ecodd (50 %)\\n(EDF 50%)", "Nom du projet": "LGC", "État de développement": "Advanced-(4) Autorisations administratives\\nPC déposé (date incohérente “1905??”), obtention prévue 07/2026", "Puissance installée (MWc)": "13.5", "Rendement (kWh/kWc)": "1461", "Contrat foncier": "PDB", "Prix (EUR ou EUR/Ha/an)": "67500+ 10.9% of N-1 revenues", "Statut permis": "Déposé", "Date de Dépot": "7/15/1905??", "Date obtention": "prévue pour 07/2026", "Date purge": "8/30/2026", "Prix raccordement (€)": "1,931,152 PRAC", "Type d'offtake": "AO CRE", "Lien - Project teaser": "Ecodd", "Date added / updated": "Jan 2026"}	Advanced	✅ Foncier sécurisé / ✅ PC déposé / 📝 En instruction	\N	Submitted
183	Viersat	\N	solar	mid	10	FR	Nouvelle-Aquitaine	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.426949	2026-06-18 02:18:18.426949	Recurrent Energy	49	Sol	Advanced-(4) Autorisations administratives\\nPermis en instruction	\N	Viersat	CREUSE (23)	\N	Q3 2028	Q1 2031	\N	\N	t	\N	1421491	AO CRE	{"Code": "49", "Actionnariat SPV (%)": "Recurrent Energy", "Nom du projet": "Viersat", "État de développement": "Advanced-(4) Autorisations administratives\\nPermis en instruction", "Technologie": "AgriPV", "Typologie": "Sol", "Date RTB estimée": "Q3 2028", "Date COD estimée": "Q1 2031", "Ville / Commune": "Viersat", "Département": "CREUSE (23)", "Région": "Nouvelle-Aquitaine", "Puissance installée (MWc)": "10", "Configuration": "Tracker 2P", "Rendement (kWh/kWc)": "1259", "Type de terrain": "Meadow", "Activité": "Élevage bovin", "Contrat foncier": "Bail", "Prix (EUR ou EUR/Ha/an)": "300 (to be confirmed)", "Aire du terrain (Ha)": "43", "EIE (EIA)\\nEnvironmental Impact Assessment": "Q4 2025", "Type permis": "PC", "Date de Dépot": "Q1 2026", "Date obtention": "Q3 2027", "Prix raccordement (€)": "1421491", "Distance point connexion (km)": "12", "Type d'offtake": "AO CRE", "Signé ?": "Non", "Lien - Project teaser": "Recurrent Energy", "Date added / updated": "Feb 2026"}	Advanced	✅ Foncier sécurisé / ✅ PC déposé / 📝 En instruction	\N	Submitted (Q1 2026)
193	Mairie de Fitou (groupé 9 sites)	8	solar	origination	1.07	FR	Occitanie	\N	\N	\N	9 sites groupés pour 1.07 MWc à Fitou. Salle polyvalente (200+200 kWc), SPAR (210+200 kWc), service technique (60 kWc), boulodrome (100 kWc), parking (100 kWc).	https://docs.google.com/presentation/d/1nSuwW3knhyUPQQdyqd2WKVsNSHkTeg8y/edit	Oui	12 sites visités (1.9 MW) → 7 pré-confirmés → 9 chiffrés. NDA à signer pour factures à jour. Frais d'étude 9 000€ HT si pas de commande.	2026-06-22 10:24:34.686896	2026-06-22 10:24:34.686896	Stephane Gilli	\N	\N	\N	\N	Fitou	Aude	11	\N	\N	\N	\N	f	\N	\N	Autoconsommation collective + revente	{"Code": "193", "Ville / Commune": "Fitou", "Département": "Aude (11)", "Région": "Occitanie", "Technologie": "Solaire", "Typologie": "Toitures et ombrières multi-sites", "Puissance installée (MWc)": "1.07", "Type d'offtake": "Autoconsommation collective + revente réseau", "Total sites visités": "12 (1.9 MW)", "Sites pré-confirmés": "7 (1.1 MW)", "Projets chiffrés": "9 pour 1 070 kWc", "Détail projets": "", "Projet 1 — Salle polyvalente toiture": "200 kWc · 915 modules × 455W · Surface 1 989 m²", "Projet 2 — Salle polyvalente parking": "200 kWc · même configuration", "Projet 3 — SPAR toiture": "210 kWc · 568 modules × 455W · Surface 1 235 m²", "Projet 4 — SPAR parking": "200 kWc · même configuration", "Projet 5 — Service technique": "60 kWc · 132 modules × 465W · Surface 263 m²", "Projet 6 — Boulodrome": "100 kWc · données techniques non fournies", "Projet 7 — Parking des Boules": "100 kWc · 192 modules × 465W · Surface 383 m² · Ombrières 2 travées (5000×600 mm, 2300×600 mm)", "Notes": "12 sites visités initialement (1.9 MW potentiel) → 7 pré-confirmés (1.1 MW) → 9 chiffrés (1 070 kWc). À faire : signer NDA pour factures à jour (2024 dispo) + lettre de mission avec frais d'étude 9 000€ HT si pas de commande.", "Lien - Project teaser": "https://docs.google.com/presentation/d/1nSuwW3knhyUPQQdyqd2WKVsNSHkTeg8y/edit", "Date added / updated": "18/03/2026", "Surface totale (m²)": "3 870 (4 sites chiffrés)"}	\N	Origination - 9 sites chiffrés, attente NDA + lettre de mission	Origination - 9 sites pre-confirmed, awaiting NDA + engagement letter	\N
151	Les Forges	\N	solar	submit	1	FR	Centre-Val de Loire	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.385441	2026-06-18 02:18:18.385441	Viridi	17	Sol	Mid-(3) Environment & (4) Permitting\\nLand fully secured; EIA exemption obtained; wetland diagnostic ongoing; permit application under preparation.	1347	Saint-Benoît-la-Forêt	Indre-et-Loire (37)	37	Q1 2027	Q1 2028	\N	\N	t	Enedis	69040	AO CRE ou S25	{"Code": "17", "Actionnariat SPV (%)": "Viridi", "Nom du projet": "Les Forges", "État de développement": "Mid-(3) Environment & (4) Permitting\\nLand fully secured; EIA exemption obtained; wetland diagnostic ongoing; permit application under preparation.", "Technologie": "AgriPV", "Typologie": "Sol", "Date RTB estimée": "Q1 2027", "Date COD estimée": "Q1 2028", "Ville / Commune": "Saint-Benoît-la-Forêt", "Code postal": "37500", "Département": "Indre-et-Loire (37)", "Région": "Centre-Val de Loire", "Puissance installée (MWc)": "1", "Configuration": "1 Axis tracker", "Rendement (kWh/kWc)": "1351", "Production annuelle / P50 (MWh)": "1347", "Activité": "protection vignobles", "Contrat foncier": "PdBS", "Contrat foncier signé ?": "Yes\\n22/10/2024", "Durée contrat (ans)": "6 + 2×3 ans", "Prix (EUR ou EUR/Ha/an)": "2500€/MW + 1500€/ha", "Aire du terrain (Ha)": "1.8", "Environnement & contraintes": "zone humide à finaliser", "EIE (EIA)\\nEnvironmental Impact Assessment": "exemption obtained", "Urbanisme": "A - PLU\\nZone humide", "Type permis": "DP", "Statut permis": "A déposer", "Date de Dépot": "Q1 2026", "Date obtention": "Q3 2026", "Gestionnaire réseau": "Enedis", "Prix raccordement (€)": "QP = 69 040 €/MW", "Distance point connexion (km)": "Local Connection à étudier", "Type d'offtake": "AO CRE ou S25", "Lien - Project teaser": "Viridi", "Date added / updated": "Feb 2026"}	Mid	✅ Autorités locales / 📝 Dépôt PC imminent	Land fully secured	À déposer (Q1 2026)
147	PROJET ÉOLIEN D’ARGILLIÈRES	\N	wind	secured_and_clean	15.75	FR	Bourgogne-Franche-Comté	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.385441	2026-06-18 02:18:18.385441	Valeco - 100%	1	Éolien terrestre	(5) Raccordement au réseau\\nPermis purgé (CAA confirmé) + PTF signée (solution 2)	22290	Argillières	Haute-Saône (70)	70	Q4 2026	Q4 2027\r\n (Sol1)\n≥ 2029 (Sol2)	\N	\N	t	RTE	\N	E17 (actuel) → AO CRE PPE2 (CR/FIP)	{"Code": "1", "Actionnariat SPV (%)": "Valeco - 100%", "Nom du projet": "PROJET ÉOLIEN D’ARGILLIÈRES", "État de développement": "(5) Raccordement au réseau\\nPermis purgé (CAA confirmé) + PTF signée (solution 2)", "Technologie": "Éolien", "Typologie": "Éolien terrestre", "Date RTB estimée": "Q4 2026", "Date COD estimée": "Q4 2027\\r\\n (Sol1)\\n≥ 2029 (Sol2)", "Ville / Commune": "Argillières", "Code postal": "70600", "Département": "Haute-Saône (70)", "Région": "Bourgogne-Franche-Comté", "Puissance installée (MWc)": "15.75", "Type d’implantation": "Parc éolien terrestre", "Configuration": "6 éoliennes", "Rendement (kWh/kWc)": "1415.238095", "Production annuelle / P50 (MWh)": "22290", "Type de terrain": "Parcelles communales", "Contrat foncier": "Promesses de baux emphytéotiques + promesses de servitudes", "Contrat foncier signé ?": "Oui", "Durée contrat (ans)": "À confirmer", "Prix (EUR ou EUR/Ha/an)": "N/A", "Aire du terrain (Ha)": "N/A", "Sécurisation accès au foncier": "Majoritairement sécurisés", "Type permis": "ICPE", "Statut permis": "Purgé de recours (CAA confirmé, pas de pourvoi)", "Date obtention": "03/07/2025", "Date purge": "30/04/2025", "Gestionnaire réseau": "RTE", "Prix raccordement (€)": "-", "Distance point connexion (km)": "-", "Certificat Enedis délivré ?": "-", "PRD (Planned Raccordement Date)": "2029 (Solution 2)", "Contrat EPC signé ?": "-", "Type d'offtake": "E17 (actuel) → AO CRE PPE2 (CR/FIP)", "Lien - Project teaser": "Valeco", "Date added / updated": "Jan 2026"}	Secured & clean	✅ Raccordement sécurisé / ✅ Tarif sécurisé	\N	Purgé (30/04/2025)
169	Pr3	\N	solar	nearly_secured	0.2	FR	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.426949	2026-06-18 02:18:18.426949	Novabridge	35	Toiture	Secured & clean of appeal-(5) Raccordement au réseau\\nPC purgé	1000	Arbois-en-Bugey	AIN (01)	\N	\N	\N	\N	\N	t	\N	\N	\N	{"Code": "35", "Actionnariat SPV (%)": "Novabridge", "Nom du projet": "Pr3", "État de développement": "Secured & clean of appeal-(5) Raccordement au réseau\\nPC purgé", "Technologie": "AgriPV", "Typologie": "Toiture", "Ville / Commune": "Arbois-en-Bugey", "Département": "AIN (01)", "Puissance installée (MWc)": "0.2", "Production annuelle / P50 (MWh)": "1000", "Contrat foncier": "Bail", "Contrat foncier signé ?": "Yes", "Durée contrat (ans)": "30", "Type permis": "PC", "Statut permis": "Purgé", "Date purge": "TBD", "Distance point connexion (km)": "0.2", "Lien - Project teaser": "Novabridge", "Date added / updated": "Feb 2026"}	Secured & clean	✅ PC purgé	\N	Purgé
170	Pr4	\N	solar	nearly_secured	0.5	FR	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.426949	2026-06-18 02:18:18.426949	Novabridge	36	Toiture	Secured & clean of appeal-(5) Raccordement au réseau\\nPC purgé	1000	Meilhards	CORREZE (19)	\N	\N	\N	\N	\N	t	\N	\N	\N	{"Code": "36", "Actionnariat SPV (%)": "Novabridge", "Nom du projet": "Pr4", "État de développement": "Secured & clean of appeal-(5) Raccordement au réseau\\nPC purgé", "Technologie": "AgriPV", "Typologie": "Toiture", "Ville / Commune": "Meilhards", "Département": "CORREZE (19)", "Puissance installée (MWc)": "0.5", "Production annuelle / P50 (MWh)": "1000", "Contrat foncier": "Bail", "Contrat foncier signé ?": "Yes", "Durée contrat (ans)": "30", "Type permis": "PC", "Statut permis": "Purgé", "Date purge": "TBD", "Distance point connexion (km)": "0.22", "Lien - Project teaser": "Novabridge", "Date added / updated": "Feb 2026"}	Secured & clean	✅ PC purgé	\N	Purgé
194	Cave de Nevian	8	solar	origination	0.499	FR	Occitanie	\N	7.5	\N	Cave viticole 500 kWc (300 kWc autoconsommation + 200 kWc revente reseau). Directeur = conseiller regional, son epouse = maire du village. Consommateurs identifies : hopital, SDIS, commune.	https://docs.google.com/presentation/d/1sSyw7ldd9UKxYLMqJ73rLJbXGfPo7pjd/edit	Oui	CAPEX 679 500€ (refection complete toiture). CA auto 40 860€ + CA revente 21 900€ = Total 62 760€/an. 1 074 modules x 465W = 499 kWc. Surface 2 140 m². Etude autoconsommation deja realisee. TRI 7.5% pour investisseurs.	2026-06-22 10:24:34.686896	2026-06-22 10:24:34.686896	Stephane Gilli	\N	Toiture	\N	\N	Nevian	Aude	11	\N	\N	\N	\N	f	\N	\N	Autoconsommation collective 300 kWc + revente reseau 200 kWc	{"Code": "194", "Ville / Commune": "Névian", "Département": "Aude (11)", "Région": "Occitanie", "Technologie": "Solaire", "Typologie": "Toiture", "Puissance installée (MWc)": "0.499", "Nombre de modules": "1 074", "Puissance panneau (W)": "465", "Surface totale (m²)": "2 140", "Dimensions modules (mm)": "1757 x 1134 x 30", "Production annuelle / P50 (MWh)": "—", "Type d'offtake": "Autoconsommation collective 300 kWc + revente réseau 200 kWc", "CAPEX (€)": "679 500", "CA autoconsommation (€/an)": "40 860", "CA revente (€/an)": "21 900", "CA total (€/an)": "62 760", "TRI (%)": "7.5", "Type de terrain": "Toiture cave viticole", "Notes": "Directeur cave = conseiller régional, son épouse = maire du village. Consommateurs identifiés : hôpital, SDIS, commune. Étude autoconsommation déjà réalisée. Possibilité raccordement à l'hôpital et à la commune.", "Lien - Project teaser": "https://docs.google.com/presentation/d/1sSyw7ldd9UKxYLMqJ73rLJbXGfPo7pjd/edit", "Date added / updated": "18/03/2026"}	\N	Origination - étude autoconsommation faite, consommateurs identifiés	Origination - self-consumption study done, consumers identified	\N
176	Pr10	\N	solar	nearly_secured	0.5	FR	NOUVELLE ACQUITAINE	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.426949	2026-06-18 02:18:18.426949	Novabridge	42	Toiture	Secured & clean of appeal-(5) Raccordement au réseau\\nPC purgé	1000	Val d’Oire et Gartempe	Haute-Vienne (87)	\N	\N	\N	\N	\N	t	\N	\N	\N	{"Code": "42", "Actionnariat SPV (%)": "Novabridge", "Nom du projet": "Pr10", "État de développement": "Secured & clean of appeal-(5) Raccordement au réseau\\nPC purgé", "Technologie": "AgriPV", "Typologie": "Toiture", "Ville / Commune": "Val d’Oire et Gartempe", "Département": "Haute-Vienne (87)", "Région": "NOUVELLE ACQUITAINE", "Puissance installée (MWc)": "0.5", "Production annuelle / P50 (MWh)": "1000", "Contrat foncier": "Bail", "Contrat foncier signé ?": "Yes", "Durée contrat (ans)": "30", "Type permis": "PC", "Statut permis": "Purgé", "Date purge": "TBD", "Distance point connexion (km)": "0.02", "Lien - Project teaser": "Novabridge", "Date added / updated": "Feb 2026"}	Secured & clean	✅ PC purgé	\N	Purgé
164	CAPIAN (33)	\N	solar	submit	5	FR	Nouvelle-Aquitaine	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.385441	2026-06-18 02:18:18.385441	ADEN	30	Sol	Early-(3) Environnement / pré-permitting\\nPC à déposer 09/2026, raccordement “en instruction 11/2027”	7400	CAPIAN	Gironde (33)	33	06/2028	12/2028	\N	\N	t	\N	\N	AO CfD	{"Code": "30", "Actionnariat SPV (%)": "ADEN", "Nom du projet": "CAPIAN (33)", "État de développement": "Early-(3) Environnement / pré-permitting\\nPC à déposer 09/2026, raccordement “en instruction 11/2027”", "Technologie": "AgriPV", "Typologie": "Sol", "Date RTB estimée": "06/2028", "Date COD estimée": "12/2028", "Ville / Commune": "CAPIAN", "Code postal": "33550", "Département": "Gironde (33)", "Région": "Nouvelle-Aquitaine", "Puissance installée (MWc)": "5", "Type d’implantation": "AgriPV\\nSheep\\nOvins / viticole", "Configuration": "Trackers", "Rendement (kWh/kWc)": "1485", "Production annuelle / P50 (MWh)": "7400", "Type de terrain": "Agricole", "Contrat foncier": "Bail", "Contrat foncier signé ?": "Yes \\n11/2025", "Aire du terrain (Ha)": "10", "Support administration locale": "Support municipal", "Statut permis": "A déposer", "Date de Dépot": "09/2026", "Date obtention": "09/2027", "Distance point connexion (km)": "8", "Type d'offtake": "AO CfD", "Signé ?": "02/2028", "Durée du contrat Offtake (ans)": "-", "Tariff (EUR/kWh)": "~0.07–0.08", "Lien - Project teaser": "Aden", "Date added / updated": "Feb 2026"}	Early	✅ Autorités locales / 📝 Dépôt PC imminent	\N	À déposer (09/2026)
168	Pr2	\N	solar	nearly_secured	0.29	FR	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.426949	2026-06-18 02:18:18.426949	Novabridge	34	Toiture	Secured & clean of appeal-(5) Raccordement au réseau\\nPC purgé	1100	Albon d’Ardèche	ARDECHE (07)	\N	\N	\N	\N	\N	t	\N	\N	\N	{"Code": "34", "Actionnariat SPV (%)": "Novabridge", "Nom du projet": "Pr2", "État de développement": "Secured & clean of appeal-(5) Raccordement au réseau\\nPC purgé", "Technologie": "AgriPV", "Typologie": "Toiture", "Ville / Commune": "Albon d’Ardèche", "Département": "ARDECHE (07)", "Puissance installée (MWc)": "0.29", "Production annuelle / P50 (MWh)": "1100", "Contrat foncier": "Bail", "Contrat foncier signé ?": "Yes", "Durée contrat (ans)": "30", "Type permis": "PC", "Statut permis": "Purgé", "Date purge": "TBD", "Distance point connexion (km)": "0.22", "Lien - Project teaser": "Novabridge", "Date added / updated": "Feb 2026"}	Secured & clean	✅ PC purgé	\N	Purgé
195	Eau Rwanda - EcoLinks	\N	other	nearly_secured	\N	Rwanda	\N	\N	36	\N	\N	\N	Oui	GS13116 VPA-2 - Projet eau potable rural Rwanda. EcoLinks. Gold Standard. 150 systemes solaires, 210 000 personnes, 485 104 tCO2e/10 ans. IRR 36%.	2026-06-22 18:03:46.224953	2026-06-22 18:03:46.224953	EcoLinks (Johnson Penn)	100	Eau potable	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	{"Code": "GS13116", "Nom du projet": "Eau Rwanda - EcoLinks", "Porteur de projet": "EcoLinks Co., Ltd. (Coree) / EcoLinks Rwanda", "Pays": "Rwanda", "Localisation": "Provinces Nord, Est, Sud - Districts: Burera, Ruhango, Bugesera, Rwamagana, Kirehe", "Etat de developpement": "Gold Standard certifie - 5 sites pilotes identifies, etudes hydrogeologiques OK, 5 lettres intention recues", "Technologie": "Pompage solaire + traitement eau", "Typologie": "Eau potable / Carbone", "Standard carbone": "Gold Standard - GS13116 VPA-2", "Methodologie": "GS Methodology for emission reductions from safe drinking water supply", "Statut Article 6": "Letter of non-objection recue - LoA en attente", "Nombre de systemes": "150 (75 forages neufs + 75 rehabilitations)", "Beneficiaires": "210 000 personnes", "Capacite par pompe": "16 000 L/jour (pompes DAYLIFF)", "Traitement eau": "Filtration sable - Charbon actif - UV SITA - Reservoir 20 000L", "SmartTaps": "RFID - suivi consommation, facturation volume", "Phase pilote": "2 communautes, 2 000 personnes (Burera, Ruhango)", "Phase principale": "148 communautes, 207 200 personnes", "Phase expansion": "+100 communautes, +140 000 personnes", "CAPEX total": "2 574 215 USD", "OPEX 5 ans": "996 926 USD", "Investissement total": "2 993 379 USD", "Modele economique": "Pay-as-you-fetch - cartes RFID - 0.40 a 0.65 USD/m3", "Credits carbone annuels": "55 000 tCO2e", "Credits carbone totaux (10 ans)": "485 104 tCO2e", "Periode de credit": "25/03/2025 - 24/03/2030 (5 ans)", "IRR (4L/pers/j)": "36%", "Payback (4L/pers/j)": "5 ans", "IRR (5.5L/pers/j)": "45%", "Payback (5.5L/pers/j)": "4 ans", "Revenu projeté (10 ans, 150 sys)": "9.1 - 10.1 M USD", "Partenaires techniques": "GAIA Survey Rwanda, Davis & Shirtliff Rwanda", "Autorites": "REMA, RDB, WASAC, RWRB, RURA", "Emplois": "100 directs + 200 indirects", "ODD cibles": "1, 3, 5, 6, 7, 8, 13", "Lettres intention recues": "Kirehe, Rwamagana, Burera, Bugesera, Ruhango", "Lien - Presentation": "https://drive.google.com/file/d/1J4MR99D0LQRsZCiHC0C11OfHb3pvVPzH/view", "Date added / updated": "Juin 2026"}	Presque securise	Gold Standard certifie - 5 sites pilotes OK	\N	\N
161	Gag	\N	solar	nearly_secured	2.01	FR	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.385441	2026-06-18 02:18:18.385441	Ecodd	27	\N	Nearly secured-(4) Autorisations administratives\\nStatut permis Recours	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	458.319	AO CRE	{"Code": "27", "Actionnariat SPV (%)": "Ecodd", "Nom du projet": "Gag", "État de développement": "Nearly secured-(4) Autorisations administratives\\nStatut permis Recours", "Puissance installée (MWc)": "2.01", "Rendement (kWh/kWc)": "1478", "Contrat foncier": "PDB", "Prix (EUR ou EUR/Ha/an)": "24000.00", "Aire du terrain (Ha)": "2", "Statut permis": "Recours", "Date de Dépot": "12/19/2025", "Date obtention": "6/30/2025", "Date purge": "8/30/2026", "Prix raccordement (€)": "458,319 PRAC", "Type d'offtake": "AO CRE", "Lien - Project teaser": "Ecodd", "Date added / updated": "Jan 2026"}	Nearly secured	✅ PC obtenu / ⚖️ Recours	\N	Obtenu (recours) - purge prévue 8/30/2026
152	Saint-Sauveur	\N	solar	early	7	FR	Bretagne	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.385441	2026-06-18 02:18:18.385441	Viridi	18	Sol	Mid-(3) Environment\\nLand fully secured (13 ha); agricultural concept defined; EIA exemption request under preparation; permitting phase upcoming.	8553	Saint-Sauveur-des-Landes	Ille-et-Vilaine (35)	35	Q1 2028	Q1 2029	\N	\N	t	Enedis	\N	AO CRE	{"Code": "18", "Actionnariat SPV (%)": "Viridi", "Nom du projet": "Saint-Sauveur", "État de développement": "Mid-(3) Environment\\nLand fully secured (13 ha); agricultural concept defined; EIA exemption request under preparation; permitting phase upcoming.", "Typologie": "Sol", "Date RTB estimée": "Q1 2028", "Date COD estimée": "Q1 2029", "Ville / Commune": "Saint-Sauveur-des-Landes", "Code postal": "35133", "Département": "Ille-et-Vilaine (35)", "Région": "Bretagne", "Puissance installée (MWc)": "7", "Rendement (kWh/kWc)": "1222", "Production annuelle / P50 (MWh)": "8553", "Activité": "bien-être bovins", "Contrat foncier": "PdBS", "Contrat foncier signé ?": "Yes\\n12/11/2025", "Durée contrat (ans)": "6 + 2×3 ans", "Prix (EUR ou EUR/Ha/an)": "2500€/MW + 2500€/MW", "Aire du terrain (Ha)": "13", "Environnement & contraintes": "Ruisseau proche, aucun enjeu majeur", "EIE (EIA)\\nEnvironmental Impact Assessment": "exemption requested", "Urbanisme": "A / Nbp - PLU\\nRuisseau proche", "Type permis": "PC", "Statut permis": "A déposer", "Date de Dépot": "Q4 2026", "Date obtention": "Q1 2027", "Gestionnaire réseau": "Enedis", "Distance point connexion (km)": "Local Connection Envisaged", "Type d'offtake": "AO CRE", "Lien - Project teaser": "Viridi", "Date added / updated": "Feb 2026"}	Mid	✅ Foncier sécurisé / 📝 Env ongoing	Land fully secured	À déposer (Q4 2026)
165	CUSSET (03)	\N	solar	submit	12	FR	Auvergne-Rhône-Alpes	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.385441	2026-06-18 02:18:18.385441	ADEN	31	Sol	Early-(3) Environnement / pré-permitting\\nPC à déposer 10/2026, raccordement “en instruction 01/2028”	16400	CUSSET	3	\N	06/2028	03/2029	\N	\N	t	\N	\N	AO CfD	{"Code": "31", "Actionnariat SPV (%)": "ADEN", "Nom du projet": "CUSSET (03)", "État de développement": "Early-(3) Environnement / pré-permitting\\nPC à déposer 10/2026, raccordement “en instruction 01/2028”", "Technologie": "AgriPV", "Typologie": "Sol", "Date RTB estimée": "06/2028", "Date COD estimée": "03/2029", "Ville / Commune": "CUSSET", "Département": "3", "Région": "Auvergne-Rhône-Alpes", "Puissance installée (MWc)": "12", "Type d’implantation": "AgriPV\\nSheep", "Configuration": "Trackers", "Rendement (kWh/kWc)": "1369", "Production annuelle / P50 (MWh)": "16400", "Type de terrain": "Agricole", "Contrat foncier": "Bail", "Contrat foncier signé ?": "Yes\\n12/2023", "Aire du terrain (Ha)": "20", "Support administration locale": "Consultation locale", "Statut permis": "A déposer", "Date de Dépot": "10/2026", "Date obtention": "10/2027", "Distance point connexion (km)": "7", "Type d'offtake": "AO CfD", "Signé ?": "02/2028", "Durée du contrat Offtake (ans)": "-", "Tariff (EUR/kWh)": "~0.07–0.08", "Lien - Project teaser": "Aden", "Date added / updated": "Feb 2026"}	Early	✅ Autorités locales / 📝 Dépôt PC imminent	\N	À déposer (10/2026)
160	Bord	\N	solar	mid	8.583	FR	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.385441	2026-06-18 02:18:18.385441	Ecodd	26	\N	Advanced-(4) Autorisations administratives\\nPC déposé 10/30/2025, obtention 06/2026, purge 08/2026	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	888.425	AO CRE	{"Code": "26", "Actionnariat SPV (%)": "Ecodd", "Nom du projet": "Bord", "État de développement": "Advanced-(4) Autorisations administratives\\nPC déposé 10/30/2025, obtention 06/2026, purge 08/2026", "Puissance installée (MWc)": "8.583", "Rendement (kWh/kWc)": "1478", "Contrat foncier": "PDB", "Prix (EUR ou EUR/Ha/an)": "104280.00", "Aire du terrain (Ha)": "8.69", "Statut permis": "Déposé", "Date de Dépot": "10/30/2025", "Date obtention": "6/30/2026", "Date purge": "8/30/2026", "Prix raccordement (€)": "888,425 PRAC", "Type d'offtake": "AO CRE", "Lien - Project teaser": "Ecodd", "Date added / updated": "Jan 2026"}	Advanced	✅ Foncier sécurisé / ✅ PC déposé / 📝 En instruction	\N	Submitted (10/30/2025)
178	Condat	\N	solar	early	15	FR	Nouvelle-Aquitaine	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.426949	2026-06-18 02:18:18.426949	Recurrent Energy	44	Sol	Early-(4) Autorisations administratives\\nPermis à déposer – études environnementales en cours	\N	Condat-sur-Ganaveix	CORREZE (19)	\N	Q1 2030	Q3 2032	\N	\N	t	\N	1917700	AO CRE	{"Code": "44", "Actionnariat SPV (%)": "Recurrent Energy", "Nom du projet": "Condat", "État de développement": "Early-(4) Autorisations administratives\\nPermis à déposer – études environnementales en cours", "Technologie": "AgriPV", "Typologie": "Sol", "Date RTB estimée": "Q1 2030", "Date COD estimée": "Q3 2032", "Ville / Commune": "Condat-sur-Ganaveix", "Département": "CORREZE (19)", "Région": "Nouvelle-Aquitaine", "Puissance installée (MWc)": "15", "Configuration": "Tracker 2P", "Rendement (kWh/kWc)": "1283", "Type de terrain": "Meadow", "Activité": "Élevage bovin", "Contrat foncier": "Bail", "Prix (EUR ou EUR/Ha/an)": "3600 (to be confirmed)", "Aire du terrain (Ha)": "68", "EIE (EIA)\\nEnvironmental Impact Assessment": "Q1 2027", "Type permis": "PC", "Date de Dépot": "Q3 2027", "Date obtention": "Q3 2029", "Prix raccordement (€)": "1917700", "Distance point connexion (km)": "5.5", "Type d'offtake": "AO CRE", "Signé ?": "Non", "Lien - Project teaser": "Recurrent Energy", "Date added / updated": "Feb 2026"}	Early	✅ Foncier sécurisé / 📝 Env ongoing	\N	À déposer (Q3 2027)
182	Bouix	\N	solar	early	20	FR	Bourgogne-Franche-Comté	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.426949	2026-06-18 02:18:18.426949	Recurrent Energy	48	Sol	Early-(4) Autorisations administratives\\nPermis à déposer – études environnementales en cours	\N	Bouix	Côte-d’Or (21)	\N	Q3 2029	Q1 2032	\N	\N	t	\N	2338855	AO CRE	{"Code": "48", "Actionnariat SPV (%)": "Recurrent Energy", "Nom du projet": "Bouix", "État de développement": "Early-(4) Autorisations administratives\\nPermis à déposer – études environnementales en cours", "Technologie": "AgriPV", "Typologie": "Sol", "Date RTB estimée": "Q3 2029", "Date COD estimée": "Q1 2032", "Ville / Commune": "Bouix", "Département": "Côte-d’Or (21)", "Région": "Bourgogne-Franche-Comté", "Puissance installée (MWc)": "20", "Configuration": "Tracker 2P", "Rendement (kWh/kWc)": "1169", "Type de terrain": "Meadow abd Crops", "Activité": "Élevage bovin", "Contrat foncier": "Bail", "Prix (EUR ou EUR/Ha/an)": "1500 (to be confirmed)", "Aire du terrain (Ha)": "36.67", "EIE (EIA)\\nEnvironmental Impact Assessment": "Q4 2026", "Type permis": "PC", "Date de Dépot": "Q1 2027", "Date obtention": "Q3 2028", "Prix raccordement (€)": "2338855", "Distance point connexion (km)": "10", "Type d'offtake": "AO CRE", "Signé ?": "Non", "Lien - Project teaser": "Recurrent Energy", "Date added / updated": "Feb 2026"}	Early	✅ Foncier sécurisé / 📝 Env ongoing	\N	À déposer (Q1 2027)
150	Les Doranchères	\N	solar	early	22.4	FR	Centre-Val de Loire	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.385441	2026-06-18 02:18:18.385441	Viridi	16	Sol	Early-(3) Environment & (5) Grid connection\\nLand fully secured (single landowner); environmental studies ongoing; grid connection and hybrid storage studies in progress; permit application targeted for 2027.	26400	Vallères	Indre-et-Loire (37)	37	Q4 2028	Q4 2029	\N	\N	t	Enedis	\N	AO CRE	{"Code": "16", "Actionnariat SPV (%)": "Viridi", "Nom du projet": "Les Doranchères", "État de développement": "Early-(3) Environment & (5) Grid connection\\nLand fully secured (single landowner); environmental studies ongoing; grid connection and hybrid storage studies in progress; permit application targeted for 2027.", "Technologie": "AgriPV", "Typologie": "Sol", "Date RTB estimée": "Q4 2028", "Date COD estimée": "Q4 2029", "Ville / Commune": "Vallères", "Code postal": "37190", "Département": "Indre-et-Loire (37)", "Région": "Centre-Val de Loire", "Puissance installée (MWc)": "22.4", "Configuration": "1 axis tracker", "Rendement (kWh/kWc)": "1177", "Production annuelle / P50 (MWh)": "26400", "Activité": "rotation cultures", "Contrat foncier": "PdBS", "Contrat foncier signé ?": "Yes\\n20/05/2025", "Durée contrat (ans)": "6 + 2×3 ans", "Prix (EUR ou EUR/Ha/an)": "2500€/MW + 2500€/MW", "Aire du terrain (Ha)": "35", "Environnement & contraintes": "compatibilité AgriPV à confirmer", "EIE (EIA)\\nEnvironmental Impact Assessment": "Ongoing", "Urbanisme": "A - PLU (adaptation)", "Type permis": "PC", "Statut permis": "A déposer", "Date de Dépot": "Q2 2027", "Date obtention": "Q2 2028", "Gestionnaire réseau": "Enedis", "Distance point connexion (km)": "8", "Type d'offtake": "AO CRE", "Lien - Project teaser": "Viridi", "Date added / updated": "Feb 2026"}	Early	✅ Foncier sécurisé / 📝 Env ongoing	Land fully secured	À déposer (Q2 2027)
179	Saint-Romain	\N	solar	early	12.7	FR	Nouvelle-Aquitaine	\N	\N	\N	\N	\N	\N	\N	2026-06-18 02:18:18.426949	2026-06-18 02:18:18.426949	Recurrent Energy	45	Sol	Early-(4) Autorisations administratives\\nPermis à déposer – études environnementales en cours	\N	Saint-Romain	Charente (16)	\N	Q3 2030	Q1 2033	\N	\N	t	\N	1630609	AO CRE	{"Code": "45", "Actionnariat SPV (%)": "Recurrent Energy", "Nom du projet": "Saint-Romain", "État de développement": "Early-(4) Autorisations administratives\\nPermis à déposer – études environnementales en cours", "Technologie": "AgriPV", "Typologie": "Sol", "Date RTB estimée": "Q3 2030", "Date COD estimée": "Q1 2033", "Ville / Commune": "Saint-Romain", "Département": "Charente (16)", "Région": "Nouvelle-Aquitaine", "Puissance installée (MWc)": "12.7", "Configuration": "Tracker 2P", "Rendement (kWh/kWc)": "1289", "Type de terrain": "Crops", "Activité": "Élevage caprin", "Contrat foncier": "Bail", "Prix (EUR ou EUR/Ha/an)": "1750 (to be confirmed)", "Aire du terrain (Ha)": "34.2", "EIE (EIA)\\nEnvironmental Impact Assessment": "Q3 2027", "Type permis": "PC", "Date de Dépot": "Q4 2027", "Date obtention": "Q2 2029", "Prix raccordement (€)": "1630609", "Distance point connexion (km)": "5.9", "Type d'offtake": "AO CRE", "Signé ?": "Non", "Lien - Project teaser": "Recurrent Energy", "Date added / updated": "Feb 2026"}	Early	✅ Foncier sécurisé / 📝 Env ongoing	\N	À déposer (Q4 2027)
\.


--
-- Data for Name: prospects; Type: TABLE DATA; Schema: public; Owner: hermes
--

COPY public.prospects (id, company, contact_name, email, phone, linkedin, type, status, country, notes, teaser, nda_signed, last_contact, next_action, source, created_at, updated_at, raw_transcript, email_draft, transcript_processed) FROM stdin;
137	VENSOLAIR	Thomas MORAL	\N	\N	\N	developer	in_discussion	FR	Zone géographique: France\nStade projets: NDA Sent\nNotes: ZT: NDA Sent (2024-10-14 0)\n[Migration] Statut Sheet d'origine: 📋 ZT: NDA Sent	\N	Non	2026-06-19 00:15:39.298089	\N	Scouting FR (sheet) auto-conversion	2026-06-18 20:00:06.05045	2026-06-19 02:15:39.306281	\N	\N	f
139	Hydrolaire	Ademola LURO	\N	\N	\N	developer	nda_signed	FR	Zone géographique: France\nStade projets: NDA Executed\nNotes: ZT: NDA Executed\n[Migration] Statut Sheet d'origine: 📋 ZT: NDA Executed	\N	Oui	\N	\N	Scouting FR (sheet) auto-conversion	2026-06-18 20:00:06.05045	2026-06-18 20:00:06.05045	\N	\N	f
140	8.2 France	\N	\N	\N	\N	developer	nda_signed	FR	Zone géographique: France\nStade projets: NDA Executed\n[Migration] Statut Sheet d'origine: NDA Executed	\N	Oui	\N	\N	Scouting FR (sheet) auto-conversion	2026-06-18 20:00:06.05045	2026-06-18 20:00:06.05045	\N	\N	f
23	Sunmind / Vinci	Alexis Jagorel	alexis.jagorel@vinci-concessions.com	\N	\N	developer	nda_signed	FR	Mariella and (Alexis Jagorel) - Greek Projects - 2026/05/07 12:30 EEST - Notes by Gemini (French)	\N	Oui	\N	\N	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.139202	\N	\N	f
24	Agrisolar PV	François Lagoutte	f.lagoutte@agrisolarpv.com	06.07.87.46.20	\N	developer	to_contact	FR	POC: Mariella Mansour\n📎 Ref: Francois 06.07.87.46.20\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.139267	\N	\N	f
25	Nexun	Gottfried Vana	\N	\N	\N	developer	to_contact	FR	POC: Mariella Mansour\nZein Tlais\n\n⏭ Actions:\nfollow up linkedin to establish first contact Mariella Mansour\ntry reaching Gottfried (?) Zein Tlais Fev 4	\N	Non	\N	follow up linkedin to establish first contact Mariella Mansour\ntry reaching Gottfried (?) Zein Tlais Fev 4	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.139354	\N	\N	f
26	H2Watt	Haig Ghawzalian	\N	\N	\N	developer	contacted	FR	POC: Mariella Mansour | Priorité: Low\n\n⏭ Actions:\ntry emailing elise marcellan \nif not, try linkedin again - Fev 4	\N	Non	\N	try emailing elise marcellan \nif not, try linkedin again - Fev 4	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.13944	\N	\N	f
29	GreenGo Energy	Milko Binza Moussirou	mibm@greengoenergy.com	+45 31 13 02 67	\N	developer	contacted	FR	POC: Mariella Mansour | Priorité: Irrelevant\n\n⏭ Actions:\nMariella Mansour scout for contacts via linkedin	\N	Non	\N	Mariella Mansour scout for contacts via linkedin	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.139985	\N	\N	f
30	Wiapro Solar	Wiapro Solar	contact@wiapro-solar.com	\N	\N	developer	nda_signed	FR	POC: Mariella Mansour | NDA: Yes | Priorité: Low\n\n⏭ Actions:\nfollow up with Abdelilah about his partner for Enrocks	\N	Oui	\N	follow up with Abdelilah about his partner for Enrocks	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.14004	\N	\N	f
40	Valdeva Energies	Arnaud Vallée	valdevaenergies@free.fr	\N	\N	developer	to_contact	FR	POC: Zein Tlais\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.142733	\N	\N	f
43	Thom Bouttier	Thom Bouttier	thom.bouttier@outlook.com	\N	\N	developer	contacted	FR	POC: Mariella Mansour\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.143521	\N	\N	f
79	Rawi Abi Akl (Wartsila)	Rawi Abi Akl	\N	\N	\N	developer	to_contact	FR	POC: Mariella Mansour	\N	Non	\N	\N	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.159944	\N	\N	f
81	Christophe Parra	Christophe Parra	resolarpv@gmail.com	\N	\N	developer	contacted	FR	POC: Mariella Mansour\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.160109	\N	\N	f
84	Opale	Antoine CACIO	antoine@opale-en-eu / fanny@oyo-communities.fr	\N	\N	developer	in_discussion	FR	Dev Pv Wind et Biogas en France seulement\nautoconsommation collective et de raccordement indirect (avec des projets eoliens)\nFrance Est\nPortefeuille 45 MW PV + Wind\nEPC in-house et suivi avec l'O&M\nbiogas pour les agriculteurs, ils veulent etre des partenaires a long-terme 30-40%\nils veulent acheter des projets eoliens\nont une filiale qui a developpe une plateforme digitale pour OYO Communities pour gerer les projets d'autoconsommation collective\nils peuvent meme acheter une seule eolienne --> autoconsommation collective sur les eoliennes\npeuvent etre interesses par des projets RTB\n\nMariella and (Antoine Cacio) - 2026/01/27 09:58 EET - Notes by Gemini\n\nNotes: Mariella a envoyé le modèle NDA à Antoine Cacio le 28/01/2026. Aucun échange depuis février 2026 — relance nécessaire	\N	En attente	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.161316	\N	\N	f
85	Laurent	Laurent Cligny\nFR country manager	laurent.cligny@electrongreen.com	33(0)610632406	\N	developer	nda_signed	FR	POC: Mariella Mansour | NDA: Oui | Priorite: High\n\nContact: Laurent Cligny - FR country manager, Electron Green. Independant prospecteur ENR.\n\nReunion 11/06/2026 ✅\nParticipants: Zein, Mariella, Laurent\n\nContexte:\n- Laurent a parle a plusieurs investisseurs de la liste EIR - attend leurs retours\n- Frein principal: reseau francais paye moins bien -> autoconsommation individuelle/collective et PPA avec industriels privilegies\n- Projets en vente totale au reseau = difficulte mais pas bloquant\n- Pour ses propres projets: doit identifier des consommateurs voisins (industrie, supermarche, station epuration) pouvant prendre 80% production\n- Discussion avancee sur un projet ou on lui demande de nommer un premier consommateur potentiel\n\nProjets specifiques:\n- Projets #33-42 (toitures agricoles - 5e developpeur): pas de tarif securise, pas de contact avec communes. Zein a les communes (Genouak, Creuse, Ardeche...) -> envoyer a Laurent\n- Projet #20/15/13 (6e developpeur): besoin de plus d'infos\n- Incoherence tableau: permis obtenu mais bail non signe -> clarifie par Mariella\n\nFinances:\n- Virement facture envoye le 04/06 - verifier reception avec equipe Japon\n- Suggestion Mariella: regrouper paiements 2 mois pour reduire frais\n\nActions:\n1. Envoyer communes des projets #33-42 a Laurent\n2. Recontacter 5e developpeur pour tarif + communes\n3. Plus d infos sur 6e developpeur\n4. Envoyer DB EIR a jour\n5. Check reception virement Laurent avec equipe Japon\n6. Laurent attend retours investisseurs cette semaine\n\n18/06 ✅ Email envoye a Laurent: communes projets #33-42	\N	Oui	2026-06-18 00:00:00	Attendre retour Laurent sur communes + retours investisseurs	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-19 01:06:40.541398	\N	\N	f
141	enersol	\N	\N	\N	\N	developer	in_discussion	BE	He wants a meeting starting next week./I reminded him\n[Migration journal Zein] Stade: NDA Sent	\N	Non	\N	\N	Journal scouting Zein (logbook)	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	\N	\N	f
143	wattelse	\N	\N	\N	\N	developer	in_discussion	BE	12/05/2024\n[Migration journal Zein] Stade: NDA Sent	\N	Non	\N	\N	Journal scouting Zein (logbook)	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	\N	\N	f
144	Bwsc	\N	\N	\N	\N	developer	meeting_scheduled	BE	\n[Migration journal Zein] Stade: Preparing meeting	\N	Non	\N	\N	Journal scouting Zein (logbook)	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	\N	\N	f
6	Philippe Humbrecht / SDESM Energies	Philippe HUMBRECHT - Directeur Développement EnR	philippe.humbrecht@sdesm-energies.fr	33.6.02.09.15.4400	\N	developer	nda_signed	FR	Strategy change Feb 2026: acquire projects 500kWc+ dep 77+. AgriPV ~50MW, BESS, EV. Minority investment open.	\N	Oui	\N	send projects whenever in their departments	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.133195	\N	\N	f
33	Everwatt	Gaëtan Gohin	gaetan.gohin@groupe-everwatt.fr	06 37 31 96 22	\N	developer	to_contact	FR	POC: Zein Tlais\n\n📋 Résumé:\nwe had an NDA that expired in Jan 2026\n\n⏭ Actions:\nscouting for new contacts https://www.linkedin.com/company/everwatt/people/	\N	Non	\N	scouting for new contacts https://www.linkedin.com/company/everwatt/people/	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.141113	\N	\N	f
34	EEF (Energie Eolienne France)	Éric Sauvaget	eric.sauvaget@eno-energy.com	\N	\N	developer	to_contact	FR	POC: Zein Tlais\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.141228	\N	\N	f
35	Abei Energy	Jaime López	jaimelopez@abeienergy.com	\N	\N	developer	contacted	FR	POC: Mariella Mansour\n\n⏭ Actions:\nscheduled a reconnection email for april 2026	\N	Non	\N	scheduled a reconnection email for april 2026	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.141342	\N	\N	f
39	Menapy	Robbert Van Boxelaere	robbert@menapy.com	\N	\N	developer	nda_signed	FR	fully restructuring their firm with new investors and new strategy...\nactivities in France, Italy, Belgium, Spain\nAdriano to reconnect with the Italian guy	\N	Oui	\N	Q4 2026 reconnect Zein Tlais, email scheduled	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.175294	\N	\N	f
52	Corsica Energia	Ghjuvan'Battistu Albertini	gb.albertini@corsicaenergia.com	\N	\N	developer	to_contact	FR	POC: Zein Tlais\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.146609	\N	\N	f
69	Seawind	Sascha Lindemann	\N	\N	\N	developer	in_discussion	FR	Seawind - Sascha Lindemann. IPP eolien (Allemagne, Pologne, Philippines).\n95% eolien grande echelle (300 MW+ solaire possible).\nModele : co-developpement ou achat a COD (jamais construction).\nZones : Europe, Philippines (pas Japon/Coree/Australie/Vietnam).\nReunion intro EIR 29/10/2024. NDA envoye par Zein - Sascha a dit qu'il signerait.\nRelance oct 2025 avec opportunite Philippines (Acciona).\n\nNotes: NDA envoye 29/10/2024 - statut non confirme. Relance oct 2025 par Zein.	\N	En attente	\N	Verifier si NDA signe. Sascha devait reprendre echanges apres signature. Dernier contact oct 2025.	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.156098	\N	\N	f
80	Becquerel Institute	C. Trehin	c.trehin@becquerelinstitute.eu	\N	\N	developer	to_contact	FR	POC: Mariella Mansour	\N	Non	\N	\N	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.160073	\N	\N	f
86	Holosolis	Laurent Bodin (CCO)\nBertrand Lecacheux (CEO)	\N	\N	\N	developer	in_discussion	FR	in q2 2026: construction of their production plant starts\ncells + modules\n5 GWp yearly capacity - biggest in Europe\nall permits are secured. to finalize series A: need 5-10m euros in equity ASAP, by Q1 2026\n\nNotes: NDA pas signé	\N	Non	\N	confirm with Imad who could be interested Mariella Mansour. if we have investors --> move forward with NDA	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.161989	\N	\N	f
87	Luciole Energies	Quentin Mathon -- directeur	quentin.mathon@luciole-energies.fr	\N	\N	developer	contacted	FR	dev autoconsommation collective 900kWc - 1MWc max\nvendent en portefeuille, pas par projet, apres les avoir construits eux-memes\nmight consider developing larger projects in 2026 (most likely 2027)\ncurrent pipeline:15 *1MWc, out of which 2 are RTB\ncan sell at RTB or co-dev on the condition that they get the EPC	\N	Non	\N	follow up on NDA	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.162328	\N	\N	f
88	Boreas	Clémence Burgaleta	c.burgaleta@boreas.fr	03.72.51.06.10	\N	developer	in_discussion	FR	POC: Mariella Mansour | Priorité: High\n\n📋 Résumé:\nIPP (HQ in Germany)\ninterested in co-dev with Enrocks\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.162678	\N	\N	f
89	Ademola / Hydrolair	Luro Ademola	luro.ademola@gmail.com	\N	\N	developer	nda_signed	FR	POC: Zein Tlais | NDA: Yes | Priorité: Irrelevant\n\n📋 Résumé:\ncanceled	\N	Oui	\N	\N	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.163024	\N	\N	f
3	Qenergy	Amanda Baudry (resp comm) & Sebastien Rondel	sebastien.rondel@qenergy.eu / nicolas.robichaud@qenergy.eu / amanda.baudry@qenergy.eu	0033432760449 / 0033681836247	\N	developer	in_discussion	FR	POC: Zein Tlais | NDA: Non | Priorite: Medium\n\nContact: Sebastien Rondel (meeting) / Amanda Baudry (resp comm) / Nicolas Robichaud\nEmail: sebastien.rondel@qenergy.eu | nicolas.robichaud@qenergy.eu | amanda.baudry@qenergy.eu\n\nContexte:\n• Filiale d un groupe coreen Fortune 500\n• ~300 projets en developpement en France\n• Changement recent de business model -> peuvent maintenant acquerir des projets\n• N ONT PAS besoin de financement - tre's bien capitalise's\n• Participent aux auctions (2e meilleur enchere re'cemment) -> dans le marche' sur les prix\n\nReunion 13/05/2026 ✅\nParticipants: Zein, Mariella, Sebastien Rondel\n\nCe qu ils cherchent:\n• BESS/France -> connection economique (<50k/MW) = critere cle'\n• Eolien onshore/France -> ~2000+ heures equivalent, permit secured\n• Minimum 5 MW\n• Stages: de l early-stage a l operation (peuvent developper, construire, posseder)\n• Allemagne/Central Europe -> contacter Martin (Head of Central Europe)\n\nPas interesses par:\n• PV solaire -> trop d offre, pipelines irrealistes, recoivent 3 teasers/semaine\n• Espagne -> trop de projets\n• Gaz, biomasse, hydro\n\nNotes:\n• Projet eolien 16 MW presente -> 1 415h/an, trop bas, pas economique sans tarif >110-120 EUR/MWh\n• Projets BESS en France: tous sous exclusivite au moment du call\n• A contacte via Amanda Baudry (recommande par equipe Qenergy a EnerGaia)	\N	Non	2026-05-13 00:00:00	1. Surveiller nouveaux projets eoliens onshore >=5MW, >=2000h, France 2. Surveiller BESS France avec connection econo (<50k/MW) 3. Contacter Martin pour Allemagne/Central Europe	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-19 01:53:43.40382	\N	\N	f
4	Qair	Alexandra Agredo (assistante) / Guirec Dufour (LinkedIn)	a.agredo@qair.energy	33764433452	\N	developer	contacted	FR	POC: Zein Tlais | Priorité: High\n👤 Alexandra Agredo (assistante) / Guirec Dufour (LinkedIn)\n📎 Ref: Louis Blanchard\n\n📋 Résumé:\nPV & wind onshore & offshore projects\n\n⏭ Actions:\nfollow up with Guirec Dufour (LinkedIn)	\N	Non	\N	follow up with Guirec Dufour (LinkedIn)	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.132896	\N	\N	f
5	WPD	EWA Koziolek (project finance offshore/solar) / Louis Mathieu	e.koziolek@wpd.fr / l.mathieu@wpd.fr	0033786253837 / 0033182726100 / 0633397068	\N	developer	in_discussion	FR	POC: Zein Tlais | NDA: No | Priorité: High\n👤 EWA Koziolek (project finance offshore/solar) / Louis Mathieu\n📎 Ref: Joris Sauzet / EWA Koziolek / Louis Mathieu\n\n📋 Résumé:\nIPP. PV & wind, sell projects.\n\n⏭ Actions:\nfollow up\n\n💬 Notes:\n0 email depuis 90 jours — à relancer	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.133068	\N	\N	f
7	Viridi RE Group	Marion Bourdais-Massenet (Directrice Générale France)	m.bourdais-massenet@viridire.com	0033 6 80 24 38 65	\N	developer	nda_signed	FR	POC: Mariella Mansour | NDA: Yes | Priorité: High\n👤 Marion Bourdais-Massenet (Directrice Générale France)\n📎 Ref: Marion Bourdais-Massenet\n\n📋 Résumé:\nFR/DE/ES/IT. FR greenfield agriPV, 53MW permit 2026 + BESS. Open co-dev/holdco.\n\n⏭ Actions:\nfollow up with enrocks	\N	Oui	\N	follow up with enrocks	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.133384	\N	\N	f
8	Stephane Gilli (ex primosolar)	STEPHANE GILLI - Président	stephane.gilli@outlook.fr	06 62 29 86 91	\N	developer	nda_signed	FR	STEPHANE GILLI — Développeur indépendant\n📧 stephane.gilli@outlook.fr\n📞 06 62 29 86 91\nNDA signé\n\nRelations :\n- Ex-PrimoSolar (ancien employeur, capacité financement atteinte)\n- Ancienne adresse : stephane.gilli@cevennesone-energy.com (bounce, ne plus utiliser)\n- Aujourd'hui indépendant, utilise outlook.fr\n\nProjets dans la base EIR :\n1. Mairie de Montfrin (0.2 MW) — Stephane habite la commune, maire ami\n2. Mairie de Fitou (1.07 MW, 9 sites) — attend NDA + lettre mission 9k€\n3. Cave de Névian (0.5 MW, TRI 7.5%) — prêt, consommateurs identifiés\n\nSuivi : appel 23/03/2026, 3 teasers reçus ✅. Pas d'échange depuis.\n\nDoublons dans la BDD : CevennesOne-Energy (ID:112), CÉVENNESONE ENERGY (ID:138)	\N	Oui	\N	Relance Stephane — Fitou attend NDA + lettre mission 9k€ (pas d echange depuis mars 2026)	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-22 11:49:42.521269	\N	\N	f
68	Renner Energies	Jeroen Wuidart	\N	\N	\N	developer	to_contact	\N	POC EIR: Zein Tlais\n	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-15 23:06:03.201971	\N	\N	f
10	Solgés Energy	Armén Sedefian (Pres.) / Dimitri de Lanversin	ddelanversin@groupe-solges.com / asedefian@groupe-solges.com	#ERROR!	\N	developer	nda_signed	FR	POC: Mariella Mansour | NDA: Yes | Priorité: Low\n👤 Armén Sedefian (Pres.) / Dimitri de Lanversin\n\n📋 Résumé:\n800MW PV/agriPV + 400MW BESS. Co-dev/holdco. Prefer own EPC.\n\n⏭ Actions:\nreconnect Nov/Dec 2026	\N	Oui	\N	reconnect Nov/Dec 2026	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.134271	\N	\N	f
1	Valeco	Zakaria Cherrak	zakariyacherrak@groupevaleco.com	0033 6 28 47 27 03	\N	developer	nda_signed	FR	Mise à jour juin 2026 :\nContact initial avec Zakariya Cherrak le 15/01/2026. Teaser du projet éolien Argillières (15,75 MW) reçu le 20/01/2026.\nÉchanges avec Cyril Giffard de janvier à mars 2026 (questions techniques, attestation non-recours en attente).\nLe 16/04/2026, Cyril Giffard informe qu'un recours a été déposé sur le projet Argillières → mise en stand-by de la cession.\nCyril Giffard indique qu'il s'agissait de leur seul projet disponible et demande un track record EIR.\nAucun échange depuis le 16/04/2026.\nNDA signé (confirmé Drive).\nContacts : Zakariya Cherrak +33 6 28 47 27 03 / Cyril Giffard +33 7 88 29 53 00.\nÀ discuter avec Mariella : transmission track record, relance, ou mise en veille.	\N	Oui	2026-06-22 00:00:00	Waiting for feedback from Zakariya & Cyril	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.131787	\N	\N	f
2	JC Mont Fort / ecodd	Patrick Delbos (Energaia): p.delbos@ecodd.com / Andrea JOUVEN: a.jouven@ecodd.com / Richard Jouven jr@jcmontfort.com / Sophie DURANTON s.duranton@ecodd.com / Michel JOUVEN mj@jcmontfort.com	\N	\N	\N	developer	nda_signed	FR	Meeting Patrick – Energaïa. Portfolio France: 900 MW. PV constr: 130 MW. Wind 21 MW RTB. Sales 2026: 70 MW, 2027: 50 MW.\n\nNotes: RDV 20/03/2026. NDA pending — relancer	\N	Oui	\N	send projects to Chint FR	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.132236	\N	\N	f
11	TCO Solar EnR	Patrick F.A. Wurster & Thomas Casalta	management.france@tco-solar.com	#ERROR!	\N	developer	nda_signed	FR	POC: Mariella Mansour | NDA: Yes | Priorité: Low\n👤 Patrick F.A. Wurster & Thomas Casalta\n\n📋 Résumé:\nPatrick to send presentation on French projects. Priority Italy.\n\n⏭ Actions:\nfollow up	\N	Oui	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.134486	\N	\N	f
49	SolSyst Energy / Raft solar	Julien	\N	\N	\N	developer	to_contact	FR	POC: Mariella Mansour\n👤 Julien\n\n⏭ Actions:\nfind investors to buy and proceed with the commercialisation of their startup for floating solar\nno immediate action	\N	Non	\N	find investors to buy and proceed with the commercialisation of their startup for floating solar\nno immediate action	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.14573	\N	\N	f
94	KH Groupe	YILMAZ Baris directeur general	contact@kh-energy.fr	662679126	\N	developer	in_discussion	FR	POC: Mariella Mansour | NDA: No | Priorité: Medium\n👤 YILMAZ Baris directeur general\n\n📋 Résumé:\nknows a developer who needs investment in his project\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.164895	\N	\N	f
116	Sunrock	Franck Burguion	f.burguion@sunrock.com	0635566414	https://www.linkedin.com/in/franck-burguion-60559195/	ipp	in_discussion	France	## Compte-rendu réunion - Sunrock / Franck Burguion\nDate: 17 juin 2026 | Participants: Zein Tlais, Mariella Mansour (Enechange), Franck Burguion (Sunrock)\n\n### Présentation Sunrock\n- Développeur IPP 100% solaire depuis 2012, adossé au family office Cofra\n- 600 MW en exploitation (Allemagne n°1 toiture/ombrière, Pays-Bas top 3, Belgique, Danemark, France)\n- Filiale France ouverte il y a 3 ans - 60 MW actuellement, visent 100 MW\n- Objectif: déposer ~200 MW/an aux appels d'offre CRE à partir de 2027\n- Focus exclusif: grandes toitures logistiques (>1 MW) et ombrières - pas de sol au sol, pas d'agrivoltaïque\n- Taille projets: 3-6 MW en moyenne, jusqu'à 18 MW sur un seul site\n- 15 personnes en France (équipe légère -> contrainte sur petits projets éclatés)\n- Franck: 3 mois chez Sunrock, responsable développement France\n\n### Stades de développement acceptés\n- OK Tout stade: RTB, codéveloppement, acquisition portefeuille, voire exploitation\n- OK Co-SPV/JV avec propriétaires fonciers (ex: grosse foncière européenne)\n- NON Projets <1 MW éclatés sur multiples sites (trop de gestion M&A/OM pour l'équipe)\n- Délai typique: signature bail -> mise en service ~ 18 mois (pas de file d'attente RTE)\n\n### Offtake\n- Autoconsommation individuelle/collective + revente surplus (modèle principal)\n- PPA privés avec industriels\n- Appels d'offre CRE: top 3-10 sur prix, TRI les plus bas de France sur le segment toiture\n- TRI plus bas mais compensé par volume et soutien Cofra\n\n### Business model proposé\n- Période d'essai gratuite de 6 mois avec accès aux projets\n- Commission (% sur investissement) si Sunrock investit\n- Après 6 mois: possible abonnement mensuel modeste\n- Franck intéressé par ce modèle\n\n### Projet identifié chez Enechange\n- Lot de ~10 projets toiture de 0,3-3 MW (total ~3 MW) en RTB, régions: lozère, drôme, ardèche, corrèze, creuse\n- Intérêt conditionnel de Franck - à valider avec direction et pôle M&A\n- Même développeur travaille peut-être sur des toitures plus grandes -> Mariella va recontacter\n\n### Actions\n1. ✅ FAIT Zein: envoyer présentation Enechange/EIR + email récapitulatif (19 juin)\n2. ⏳ Zein: envoyer NDA standard à Jinan pour signature\n3. ⏳ EN ATTENTE Franck: envoyer présentation Sunrock PDF\n4. ⏳ EN ATTENTE Franck: valider en interne (direction + M&A) l'intérêt pour le lot de 3 MW\n5. ✅ Zein: contacté Novabridge (Erwan) — portefeuille 3 MW transmis à Sunrock (en cours d'étude)\n6. ⏳ Suivi dans 1-2 semaines	\N	Non	2026-06-18 12:07:40	📩 Attendre retour Franck\n📎 Recevoir présentation Sunrock\n📄 Suivre NDA	LinkedIn - Christian (DG Sunrock)	2026-06-16 13:29:16.494778	2026-06-17 16:43:43.835102		Bonjour Franck,\n\nMerci beaucoup pour notre échange d'hier, c'était très enrichissant.\n\nComme convenu, voici un resume et les prochaines etapes :\n\nCE QU'ON RETIENT :\n- Sunrock, exclusivement grandes toitures logistiques et ombrières (1-18 MW)\n- 60 MW en France, objectif 100 MW puis 200 MW/an\n- Modèles ouverts : acquisition, co-développement, JV, co-SPV\n\nPROCHAINES ETAPES :\n1. Je vous joins notre présentation EIR et notre modèle de NDA standard\n2. Votre présentation Sunrock nous intéresse beaucoup\n3. Nous avons identifié un lot de projets toiture (~3 MW, RTB, multi-régions)\n4. On continue à vous sourcer des opportunités grandes toitures\n\nNOTRE MODÈLE DE PARTENARIAT :\n- Période d'essai gratuite de 6 mois (accès à nos projets sans engagement)\n- Commission uniquement si vous investissez dans un projet qu'on vous présente\n- On évalue ensemble après 6 mois\n\nN'hésitez pas si vous avez des questions.\nCordialement\nZein Tlais\n\n\nBusiness Development Consultant\nMobile: 06 66 66 78 00\nFrance	t
12	Notus Energie	Robin Savoye	robin.savoye@notus.fr	0033670782647 / 0033187446317	\N	developer	in_discussion	FR	1 projet sol+agri. Min 10MW/SPV. Contacté 11/01/2026.\n\nNotes: 0 email depuis 90j — relancer	\N	Non	\N	Relancé 19/05/2026 — attente réponse	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.136377	\N	\N	f
15	Recurrent Energy	Theo Baudry-Sherry (Chargé projets) / Guillaume Auneau	theo.baudry@recurrentenergy.com	06 70 11 67 11 / +33 6 30 85 23 18	\N	developer	in_discussion	FR	POC: Mariella Mansour | NDA: Pending | Priorite: Medium\n\nContact: Theo Baudry-Sherry (Charge projets) / Guillaume Auneau\nEmail: theo.baudry@recurrentenergy.com\n\nContexte:\n• PV agri trackers cattle 80-90%\n• 8 projets ~100MW early-stage\n• Permis 2025-27\n\nEchanges:\n• 12/05/2026: Mariella a envoye email -> demande si prolongation NBO/BO/SPA, proposition presentation a investisseur, demande autres projets a vendre\n• 10/06/2026: Mariella a relance -> pas de reponse\n• Statut: Pas de reponse apres 2 relances	\N	En attente	2026-06-10 00:00:00	Relancer Theo ou essayer autre contact (Guillaume Auneau)	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-19 01:21:12.63204	\N	\N	f
13	ABO Energy	Paul Verger (Project Mgr Finance & Sales)	paul.verger@aboenergy.com	06 42 60 34 55	\N	developer	contacted	FR	POC: Zein Tlais | NDA: No | Priorité: High\n👤 Paul Verger (Project Mgr Finance & Sales)\n📎 Ref: Paul\n\n📋 Résumé:\nPV 5-40MW, 120MW pipeline, 80MW RTB sale 2026 France. Wind min 10MW.\n\n⏭ Actions:\nRelancé 19/05/2026 — attente	\N	Non	\N	Relancé 19/05/2026 — attente	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.136629	\N	\N	f
14	Valorem	Jérôme Espinet (Toiture & Ombrière Commercial)	jerome.espinet@valorem-energie.com	0033 6 23756169	\N	developer	to_contact	FR	POC: Zein Tlais | NDA: No\n👤 Jérôme Espinet (Toiture & Ombrière Commercial)\n\n📋 Résumé:\nCR réunion 11/05/2026\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.136837	\N	\N	f
16	Elmy	Thomas Rochoux (Directeur du solaire)	thomas.rochoux@elmy.fr	664159745	\N	developer	to_contact	FR	POC: Zein Tlais | NDA: No\n👤 Thomas Rochoux (Directeur du solaire)\n\n📋 Résumé:\nPV dev, 30MW soon RTB, co-dev pref, 15 projects eastern France.\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.137272	\N	\N	f
17	Enertrag	Antoine Pouille (Project Finance M&A)	Antoine.Pouille@enertrag.com	0049 152 26237630	\N	developer	nda_signed	FR	Allemand éolien. France ~100MW (3 RTB), Allemagne ~300MW. Storage 50/50. Meeting 21/01.	\N	Oui	\N	Relancé x2 19/05 — pas de réponse	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.137496	\N	\N	f
18	Altarea	Jean Percier (resp dev PV) / R. Charuau	tgracia@altarea.com / rcharuau@altarea.com	07 87 66 74 52	\N	developer	in_discussion	FR	Altarea ENR (groupe immobilier) - Cherche a acquerir projets PV near-RTB.\nToitures, ombrieres, sol, flottant (pas agriPV) | 100 kWc - 25 MWc | France + Italie.\nContacts : Jean Percier (resp dev PV), Thibaut Gracia, R. Charuau.\nInvestors List: Medium. Acquisition societes dev / co-developpement.\nRelance Mariella fev 2026. Zein a envoye selection projets mars 2026 (suite appel Thibaut).\n\nNotes: Dossier Mariella. Pas de NDA necessaire (Altarea = investisseur acheteur). Projets selectionnes envoyes mars 2026.	\N	Non	\N	En attente retour Thibaut sur projets envoyes mars 2026.	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.137729	\N	\N	f
19	Gascogne	Nicolas Lafarie - Directeur General	n.lafarie@gascogne-nouvelles-energies.fr	06 12 53 12 55	\N	developer	in_discussion	FR	Gascogne Nouvelles Energies - Nicolas Lafarie (DG).\nDeveloppeur projets ENR. Ne cherche PAS d'investisseurs actuellement.\nCherche a acquerir des projets (pas a vendre).\nReunion intro 24/05/2024. NDA envoye x2 (mai 2024, dec 2025) - pas signe.\nAppel dec 2025 : pas besoin d'investisseurs, peut-etre fin 2026.\n\nNotes: Contact initial via formulaire site web mai 2024. Plusieurs relances Zein (juil/nov/dec 2025).	\N	En attente	\N	Recontacter fin 2026. Relancer NDA si opportunite.	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.137957	\N	\N	f
20	Etherr.a / Terra	Olivier Aymard (CEO)	olivier.aymard@terr-a.fr	33660965809	\N	developer	to_contact	FR	Etherr.a: fusion Terr.a + Ether Energy. PV & BESS >=1MW. 4 projects 2026. France/Belgium/Lux. Prefer RTB.	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.138196	\N	\N	f
27	H2Air	Ziad Halwani	\N	\N	\N	developer	in_discussion	FR	POC: Mariella Mansour | Priorité: High\n\n⏭ Actions:\nfollow up with Joe and ...	\N	Non	\N	follow up with Joe and ...	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.139684	\N	\N	f
9	Novabridge	Erwan Bibollet - CEO	etude@novabridge.fr	06 35 44 89 47	\N	developer	nda_signed	FR	Novabridge — Erwan Bibollet (CEO). Toitures agriPV 10 sites (3 MWc).\nElectron Green out (ticket trop grand).\nNouvel investisseur interessé — NDA en cours avec l'investisseur.\nProjets éligibles AOS, 2/10 éligibles AO toiture. Pas de tarif d'achat fixe.\n\nNotes: Echange 22-25/05 - Electron Green out, nouvel investisseur (NDA cours), questions tarifs/eligibilite. Dernier echange Mariella 25/05.\n! Demander a Mariella : statut NDA Novabridge ? (NDA Enrocks sep 2024, pas de confirmation signature)\n\n### 19 juin 2026 — Relance Sunrock\n✅ Zein: contacté Erwan pour savoir s'il a des projets toiture >1 MW (investisseur Sunrock intéressé)\n⏳ En attente réponse Erwan\n\n### 19 juin 2026 — Précision envoyée à Erwan\n✅ Zein: précisé que Sunrock préfère toiture/ombrière >1 MW par projet\n✅ Zein: transmis portefeuille 3 MW Novabridge à Sunrock — en cours d'étude\n⏳ Attendre retour Erwan + retour Sunrock	\N	Oui	2026-06-18 14:50:43	📩 Attendre retour Erwan + étude Sunrock portefeuille 3 MW	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.134073	\N	Bonjour Erwan,\nPetite précision concernant mon précédent message : leur préférence porte sur des projets toiture ou ombrière d'environ 1 MW ou plus par projet.\nJe leur ai également transmis les informations concernant votre portefeuille actuel de 3 MW en toiture, qu'ils sont en train d'étudier en interne.\nBien cordialement,\nZein	f
21	Calycé	Paul-Antoine Grasset	paul-antoine@calyce-sun.fr	\N	\N	developer	nda_signed	FR	Dec 23 2025\n\nAgriPV developer, bureaux Reims & Toulouse, 30 employés.\nSell at RTB\n~100 MW under review (en instruction)\nTheir first permits early 2026\nTheir first RTB project in H2 2026.\n8-30 MW per project, mix élevage et grandes cultures.\nmay want to hybridize their projects (to be confirmed)\nno projects to sell at this stage (RTB)\nnot looking for milestone payments either	\N	Oui	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.138691	\N	\N	f
22	Faradae	Philippe DURAND\nDirecteur Général Délégué	philippe@faradae.com	. +33 7 67 40 02 81	\N	developer	to_contact	FR	POC: Zein Tlais\n👤 Philippe DURAND\nDirecteur Général Délégué\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.139151	\N	\N	f
28	Vensolair (CNR)	Vensolair CNR	\N	\N	\N	developer	to_contact	FR	POC: Zein Tlais\n📎 Ref: Gaëtan DARWICHE\nResponsable Repowering et Acquisitions\n\nHead of Repowering and M&A activities\n\ng.darwiche@vensolair.fr\n\n+33 (0)7 85 84 33 31 "\n\n⏭ Actions:\nfollow up with database	\N	Non	\N	follow up with database	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.139928	\N	\N	f
118	DH2 Energy		ztlais.ul@gmail.com	\N		developer	contacted	FR	PV solar +1Mw	\N	Non	\N	\N	\N	2026-06-18 13:57:16.321772	2026-06-18 13:57:16.321772	\N	\N	f
32	Gaëtan Gohin	Safra New Energie + Future société distribution électricité	g01.gaetan@gmail.com	France	\N	developer	to_contact	FR	1. Gaëtan Gohin a quitté Everwatt → maintenant Safra New Energie + future société de distribution d'électricité\n2. Il agit comme investisseur (pas développeur)\n3. Cherche projets ENR clé en main (solaire, éolien) en France\n4. Budget : 60M€ sur 2 ans / 10-20M€ fonds propres\n5. Objectif : >30 sites de production\n📝 Notes Gemini 13/01/2026 - https://docs.google.com/document/d/1s5zakMq826AQtYo_d9ngsy5E_dpcgzsX2fcO6eet6n0/edit	\N	Non	\N	Mariella → envoie résumé / Gaëtan → envoie détails recherche Safra / Gaëtan → revient dans 15 jours pour les besoins de sa nouvelle société. En attente depuis janv 2026.	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.141004	\N	\N	f
31	EnR Courtage	Yann Barberis	y.barberis@enr-courtage.fr	763877140	\N	developer	nda_signed	FR	Vous a présenté David Lebret (Regenerasun) — intro call fait le 21/05. Fee-sharing 50/50 signé le 03/06 ✅. A un portefeuille 6/7 MWc à proposer. Projets : PV toiture <500 kWc, stockage batteries (~33 dossiers, PDB signées, loyer 1250€/an/batterie, 12 ans). Yan a autorisé Mariella à contacter Groupe Dolfines (stockage). A d'autres projets en cours. Problème : ne peut pas avancer frais de dev → cherche investisseurs.\n\n📩 Dernier message Yann (juin 2026): demande retour sur David Lebret/Regenerasun et si Dolfines interesse par solutions EnR Courtage	\N	Oui	2026-06-19 16:34:12.564966	1. Retourner vers Yann: statut David Lebret (Regenerasun) + reponse Dolfines 2. Suivre portefeuille 6/7 MWc Yann	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-19 16:34:12.560246	\N	\N	f
36	Nordsolar	Tarvo	tarvo@nordsolar.ee	\N	\N	developer	to_contact	FR	POC: Mariella Mansour\n\n⏭ Actions:\nscout for new contacts	\N	Non	\N	scout for new contacts	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.141595	\N	\N	f
37	Corsica Sole	Raphaël ALPIN\n\nResponsable M&A	\N	France / Europe	\N	developer	to_contact	FR	Solaire + Stockage (150 MWh storage)\n\nNotes: Meeting 06/03/2024 (Maxime Prieur) — IPP solaire & stockage basé France, projets Europe, 150 MWh storage, intéressé par achat projets, devait connecter au responsable M&A. Zein follow up → intro Raphaël ALPIN (M&A) 08/04/2024. Meeting 23/04/2024. CR incomplet — demander à Mariella la suite des échanges.	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.142064	\N	\N	f
38	As Developpement	Sébastien ACKERMANN	\N	06 86 90 69 08	\N	developer	to_contact	FR	POC: Mariella Mansour\n👤 Sébastien ACKERMANN\n\n📋 Résumé:\nbrief phone discussion, could not meet at Energaia\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.142558	\N	\N	f
41	Argos Solar et 6e sens	Alexis PEREZ	aperez@argos.solar	\N	\N	developer	in_discussion	FR	POC: Mariella Mansour | Priorité: High\n👤 Alexis PEREZ\n\n⏭ Actions:\nemail him on his new email address	\N	Non	\N	email him on his new email address	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.143251	\N	\N	f
42	Azolis	Guillaume Jeangros	g.jeangros@azolis.com	+33 683 95 42 95	\N	developer	contacted	FR	POC: Mariella Mansour\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.143496	\N	\N	f
44	OK Transition	OK Transition	thomasjolenr@gmail.com	\N	\N	developer	contacted	FR	POC: Mariella Mansour\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.143822	\N	\N	f
45	Pegasus Developpement EnR		\N	\N	\N	developer	to_contact	FR	POC: Mariella Mansour\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.144073	\N	\N	f
46	Morgan Cronier	Mr. Morgan Cronier	\N	33 6 50 08 29 54.	\N	developer	to_contact	FR	POC: Zein Tlais\n👤 Mr. Morgan Cronier\n\n📋 Résumé:\na un reseau de developpeurs en France (3rd party)\n\n⏭ Actions:\nfollow up, send summary on inv requirements	\N	Non	\N	follow up, send summary on inv requirements	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.144608	\N	\N	f
47	Meriaura Energy	Morgan Cronier	morgan.cronier@meriaura.com	+358 50 564 15 80	\N	developer	to_contact	FR	POC: Zein Tlais\n👤 Morgan left Meriaura\n\n⏭ Actions:\nscout for contacts	\N	Non	\N	scout for contacts	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.145059	\N	\N	f
48	Watteos	Albin Garrigue	albin.garrigue@watteos.fr	+33 6 03 39 94 86	\N	developer	to_contact	FR	POC: Mariella Mansour\n\n⏭ Actions:\nreconnect	\N	Non	\N	reconnect	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.145299	\N	\N	f
50	Adenfi	Aurelia Fleche	aurelia.fleche@adenfi.com	\N	\N	developer	to_contact	FR	POC: Mariella Mansour\n\n⏭ Actions:\nreconnect	\N	Non	\N	reconnect	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.146205	\N	\N	f
119	Home H2watt - H2watt			\N		developer	contacted	FR	Zone géographique: France\nStade projets: Meeting Done\nNotes: ZT: Meeting Done\n[Migration] RDV déjà effectué avant migration du Scouting FR.	\N	Non	\N	\N	\N	2026-06-18 19:17:25.837916	2026-06-18 19:17:25.837916	\N	\N	f
120	KOURBE			\N		developer	contacted	FR	Zone géographique: France\nStade projets: Preparing meeting\nNotes: ZT: Preparing meeting\n[Migration] RDV déjà effectué avant migration du Scouting FR.	\N	Non	\N	\N	\N	2026-06-18 19:17:25.837916	2026-06-18 19:17:25.837916	\N	\N	f
121	Renner Energies France	Enrique Diaz Valdes		\N		developer	contacted	FR	Zone géographique: France\nStade projets: Meeting Done\nNotes: ZT: Meeting Done (2025-09-01 0)\n[Migration] RDV déjà effectué avant migration du Scouting FR.	\N	Non	\N	\N	\N	2026-06-18 19:17:25.837916	2026-06-18 19:17:25.837916	\N	\N	f
122	TYSILIO DEVELOPMENT			\N		developer	contacted	FR	Zone géographique: France\nStade projets: Meeting Done\nNotes: ZT: Meeting Done\n[Migration] RDV déjà effectué avant migration du Scouting FR.	\N	Non	\N	\N	\N	2026-06-18 19:17:25.837916	2026-06-18 19:17:25.837916	\N	\N	f
123	AEDES ENERGIES			\N		developer	contacted	FR	Zone géographique: France\nStade projets: Preparing meeting\nNotes: ZT: Preparing meeting\n[Migration] RDV déjà effectué avant migration du Scouting FR.	\N	Non	\N	\N	\N	2026-06-18 19:17:25.837916	2026-06-18 19:17:25.837916	\N	\N	f
124	La Spirale IM	06 95 45 17 46		\N		developer	contacted	FR	Zone géographique: France\nStade projets: Preparing meeting\nNotes: ZT: Preparing meeting\n[Migration] RDV déjà effectué avant migration du Scouting FR.	\N	Non	\N	\N	\N	2026-06-18 19:17:25.837916	2026-06-18 19:17:25.837916	\N	\N	f
125	ENERGIE EOLIENNE FRANCE			\N		developer	contacted	FR	Zone géographique: France\nStade projets: Meeting Done\n[Migration] RDV déjà effectué avant migration du Scouting FR.	\N	Non	\N	\N	\N	2026-06-18 19:17:25.837916	2026-06-18 19:17:25.837916	\N	\N	f
51	Chint Solar	Fathia Taghozi	fathia.taghozi@chintglobal.com	07.64.85.31.82	\N	developer	contacted	FR	POC: Mariella Mansour | Priorité: High\n\n⏭ Actions:\nsend projects ecodd	\N	Non	\N	send projects ecodd	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.146473	\N	\N	f
53	Sunzil	Lorraine Frignet des Préaux	l.frignet-des-preaux@sunzil.com	\N	\N	developer	to_contact	FR	POC: Zein Tlais\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.146859	\N	\N	f
54	Acama Groupe	Alexandru Mihailov, CEO.	a.mihailov@acama.fr	0033 7 68 08 69 79	\N	developer	contacted	FR	manages project sourcing and development, mainly agrivoltaic (≤1 MW) on PV and BESS\nProject structure: Often grouped in SPVs of several MW (latest: 15 MW)\nCollaboration flexibility: Very open to work with investors, either on development or EPC side\nMarket interest: Strong interest in the Romanian market\n\nRelancé par email le 19/05/2026 à Alexandru Mihailov avec Mariella Mansour en CC.\n\nNotes: Dernier email envoyé le 20/03/2026 (suite Energaïa) — pas de réponse depuis 2 mois	\N	Non	\N	Relancé le 19/05/2026 — en attente de réponse.	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.147366	\N	\N	f
55	Apex Energies	Mathieu Dziamski - achteur	m.dziamski@apexenergies.fr	07 76 00 15 92	\N	developer	to_contact	FR	Dev, contruction et d'exploitation\nPv toiture en FRANCE\nde 250 à 500 Kw\nvendre à Enedis\ncherche des opportunités à acheter	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.14847	\N	\N	f
56	Arkolia	Quentin BONNEAUD	qbonneaud@arkolia.com	\N	\N	developer	to_contact	FR	Photovoltaïque (activité majoritaire) + Un peu d’éolien et de biomasse\nHangars agricoles/ sol / Agrivoltaïsme\nSouhaite acquérir des projets (sol à partir de 1 MW)\nDéveloppeur actif avec volonté de croissance via acquisition de projets matures ou en développement	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.148988	\N	\N	f
57	Boralex	Mateo Celi-Cadieux	\N	\N	\N	developer	in_discussion	FR	POC: Mariella Mansour | Priorité: High\n\n📋 Résumé:\nZein Tlais to add info\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.149247	\N	\N	f
58	Dauphin Energies	Elodie Fabie	efabie@dauphinenergies.com	06.32.90.37.23	\N	developer	to_contact	FR	POC: Zein Tlais\n\n📋 Résumé:\nZein Tlais to add info\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.149538	\N	\N	f
59	Dev'EnR	Dev'EnR	\N	\N	\N	developer	to_contact	FR	Dev ENR développe, construit et exploite ses projets, mais ne vend pas beaucoup.\nune puissance minimale de 1 MW.\nsolaire au sol, toiture, ombrières, parkings…\nBureaux : Montpellier, Toulouse, Clermont-Ferrand et Bordeaux.\nOuvert à toutes opportunités et à la recherche de nouveaux projets.	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.149904	\N	\N	f
60	EDP	Liora Sebahoun	liora.sebahoun@edp.com	07.86.71.71.26	\N	developer	to_contact	FR	POC: Zein Tlais | NDA: No\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.150165	\N	\N	f
61	Elements	Souad Hajji (Directrice financiement et partenariats)	Souad.hajji@elements.green	06 98 21 89 78 (Sara)	\N	developer	to_contact	FR	Met Sara Tézenas du Montcel at EnerGaïa. She shared the contact details of Souad Hajji. LinkedIn message and email sent.	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.15373	\N	\N	f
62	Energiter	Eva Enjalran	enjalran@energiter.fr	04.27.04.50.46	\N	developer	to_contact	FR	POC: Zein Tlais\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.154032	\N	\N	f
63	ERG		\N	\N	\N	developer	to_contact	FR	POC: Zein Tlais\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.154319	\N	\N	f
64	Incidences	Incidences	\N	\N	\N	developer	to_contact	FR	POC: Zein Tlais\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.154703	\N	\N	f
65	Irisolaris	Karine Requena	karine.requena@irisolaris.com	04.84.49.23.79	\N	developer	to_contact	FR	POC: Zein Tlais | NDA: No\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.15498	\N	\N	f
66	Luxel	Luxel	\N	\N	\N	developer	to_contact	FR	POC: Zein Tlais\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.155256	\N	\N	f
67	Photosol	Ugo DE HALDAT DU LYS (Analyste M&A)	ugo.dehaldatdulys@photosol.fr	003 6 84 46 41 52	\N	developer	nda_signed	FR	Photosol - December 22 2025\nonly buying RTB projects, but can consider others that are very close to RTB (Poland and Italy)\n15+ MW\nPV or PV+BESS\nalready acquired 100+ MW in Italy, they have a local team\ninterested in Fer-X eligible projects\nWant to invest in 50 MWp per year (2-3 projects)\nNot active in agriPV yet, may consider it\nNot interested in standalone BESS, but may consider it with MACSE developments\nPrefer projects in the Center-North / North Italy. Not interested in Sicily and Sardinia\nNext: update testers in Italy and Poland\nthen he will discuss internally and confirm Photosol's interest\n\nNotes: Suivi actif par Mariella jusqu'au 12/05/2026 — vérifier avec Mariella avant intervention	\N	Oui	\N	follow up on italian pipeline	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.155804	\N	\N	f
70	Voltalia	Tayna ALMEIDA (Inv. Manager) — t.almeida@voltalia.com / Nicolas GOURVITCH — n.gourvitch-ext@voltalia.com	t.almeida@voltalia.com	33669185177	\N	developer	in_discussion	FR	EIR x Voltalia Introductory Meeting - 2026/03/13 10:28 CET - Notes by Gemini (English)\n\nNotes: 2 contacts: (1) Tayna Almeida (t.almeida) contact Energaïa 12/01 — pas de réponse; (2) Nicolas GOURVITCH meeting 13/03/2026 avec Zein, intéressé par le fee, brochure envoyée. Pas de suite.	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.156395	\N	\N	f
71	Virya Energy	Emilie Maran	e.maran@virya-energy.fr	06.99.16.36.77	\N	developer	to_contact	FR	POC: Zein Tlais\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.156727	\N	\N	f
72	Uniper Renewables France	Valeria Ceriani	valeria.ceriani@uniper.energy	06.75.00.24.43	\N	developer	in_discussion	FR	POC: NDA pas signé | Priorité: High\n\n⏭ Actions:\nfollow up\n\n💬 Notes:\nNDA pas signé	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.157244	\N	\N	f
73	Sunti	Thomas Delacroix	td@sunti.fr	0689578086\n0499522767	\N	developer	to_contact	FR	POC: NDA pas signé\n👤 Thomas Delacroix\n\n⏭ Actions:\nfollow up\n\n💬 Notes:\nNDA pas signé	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.157777	\N	\N	f
74	Sun'R	Eric Pene (Directeur commercial)	eric.pene@sunR.com	\N	\N	developer	to_contact	FR	PV + Agri\n3 Mw to 20 Mw\nil prefere garder les projets developpé\nouvert pour acheter des projets	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.158083	\N	\N	f
75	Genelios (Pascal Chauffez)	Pascal Choffez	p.choffez@genelios.com	06.69.59.37.39	\N	developer	to_contact	FR	POC: Mariella Mansour	\N	Non	\N	\N	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.158402	\N	\N	f
76	Aden FR	Eric DECOUX	eric.decoux@aden.fr	786093687	\N	developer	nda_signed	FR	Highly important notes on development risk: Aden et ENECHANGE - 2026/02/23 09:55 EET - Notes by Gemini\n\n\n\nMariella and (Eric DECOUX) - 2026/02/04 10:58 EET - Notes by Gemini	\N	Oui	\N	follow up with enrocks	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.158995	\N	\N	f
77	Greenflex	Fred Lherminier	flherminier@greenflex.com	. + 33 (0)6 82 29 42 95	\N	developer	to_contact	FR	POC: Zein Tlais\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.159314	\N	\N	f
78	Smart Energies	Edouard Dupuy\nLéa Raucroy	lea.raucroy@smart-energies.eu\nedouard.dupuy@smart-energies.eu	\N	\N	developer	to_contact	FR	Mariella Mansour 3:55 PM\nSmart Energies – June 27, 2024\nFrench IPP with projects in France, Italy, and Greece\nFocus on energy communities\nWant to buy and/or co-develop in Italy and Greece\nZein will follow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.159907	\N	\N	f
82	Syse Methanisation	Serge Barge	serge.barge@laposte.net	06 08 65 37 90	\N	developer	in_discussion	FR	POC: Mariella Mansour | Priorité: Low\n\n📋 Résumé:\nBase a Lyon	\N	Non	\N	\N	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.160424	\N	\N	f
83	VDN	Quentin Ferret (Ingénieur financement de projets)\n\nZhening Kang (chef de projets solaires)\n\nJean-Guilhaume Pigoullie (not sure, i think he's their manager)	q.ferret@vdn-energies.fr\nz.kang@vdn-energies.fr\njg.pigoullie@vdn-energies.fr	0033 7 64 13 01 38	\N	developer	to_contact	FR	PV and wind development + operation. they sell only, they don't buy (although they can buy early-stage wind of 15 MWc)\n95% of their PV pipeline is just before depot du permis de construire\nPV pipeline: 5 MW @ Corsica, 15 MWc agriPV @ Aude, et d'autres a Paris, Montpellier, Nantes...\nCurrent financing strategy: No equity investors; debt financing only, however, can sell a few active projects\n\n14/01/2025: PAs besoin d'investisseurs externes	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.16099	\N	\N	f
90	8p2	Richard Musi	richard.musi@8p2.fr	\N	\N	developer	nda_signed	FR	Update on requirements: want BESS projects in France only, operating, at most 10 MW\n\n8p2 x EIR Introductory meeting - 2026/01/13 13:59 CET - Notes by Gemini	\N	Oui	\N	no projects now. send when we find relevant opportunities\nreconnection email is scheduled in late June 2026	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.163363	\N	\N	f
96	Plenitude	Narottam Dalmia - Project Head	narottam.dalmia@eniplenitude.es	33 6 14 40 04 24	\N	developer	in_discussion	FR	PV more than 5 MW - France\n\nNotes: Dernier email de Narottam : 17/03/2026 (accord de son supérieur, demande teaser). Relance le 07/05/2026.	\N	Non	\N	Zein va l’appeler — mieux qu’une relance email.	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.16588	\N	\N	f
105	Badr Eddine El Bachar	Badr Eddine EL BACHAR	b.elbachar@gmail.com	\N	\N	developer	nda_signed	FR	Projet eolien Oued Noun Wind Farm — Maroc.\nReunion intro 26/03/2025 (Zein, Mariella, Imad, Jinan, Adnan + Badr).\nNDA signe et contre-signe le 28/03/2025 ✅\nPresentation PPTX recue (lien restore dans teaser).\nEIR a un contact investisseur japonais interesse par la region (30/04/2025) — pas encore pret a avancer sur ce projet, EIR explore d autres pistes.\nBadr devait completer dossier avec consultants — en attente depuis mai 2025.\nRelance email Zein le 21/05/2026 sans reponse a ce jour.\nDocuments sur Drive:\n- NDA: https://drive.google.com/file/d/1jQeRyT-n7iHauXcWgu3PC-ynfDGpgzqK/view\n- Presentation projet: https://docs.google.com/presentation/d/1-4GoQnS2TtHNCy46jg_fu4-5znZg35YU/edit	Presentation Oued Noun Wind Farm: https://docs.google.com/presentation/d/1-4GoQnS2TtHNCy46jg_fu4-5znZg35YU/edit	Oui	\N	Relancer Badr par telephone sur le dossier eolien Oued Noun — derniere relance email 21/05/2026 sans reponse	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-22 15:16:10.510979	\N	\N	f
106	Statkraft	Sébastien Darche (VP Development France)	sebastien.darche@statkraft.com	\N	\N	developer	in_discussion	FR	POC: Zein Tlais | NDA: No | Priorité: Low\n👤 Sébastien Darche (VP Development France)\n📎 Ref: Sébastien Darche	\N	Non	\N	\N	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.173844	\N	\N	f
109	Menapy France	Robbert Van Boxelaere	robbert@menapy.com	\N	\N	developer	nda_signed	\N	\N	\N	Oui	\N	À intégrer dans le suivi	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-15 11:28:20.210086	\N	\N	f
108	ECO DELTA	Elodie Pellitteri	elodie.pellitteri@finergreen.com	+1 224-505-3547	\N	developer	nda_signed	FR	NDA: Yes | Priorité: Medium\n\n⏭ Actions:\nÀ intégrer dans le suivi	\N	Oui	\N	À intégrer dans le suivi	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.175166	\N	\N	f
127	Agrisoléo	\N	\N	\N	\N	developer	meeting_scheduled	FR	Zone géographique: France\nTechnologies: AgriPV\nStade projets: Développeur agrivoltaïque\n[Migration] Statut Sheet d'origine: Call confirmé mer 17/06 11h ✅	\N	Non	\N	\N	Scouting FR (sheet) auto-conversion	2026-06-18 20:00:06.05045	2026-06-18 20:00:06.05045	\N	\N	f
128	Lightsource France Development	\N	contact.fr@lightsourcebp.com	\N	\N	developer	meeting_scheduled	FR	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur (BP)\nNotes: Filiale de Lightsource BP\n[Migration] Statut Sheet d'origine: A répondu ✅ — 3 centrales, 2 construites, OA — fixer call Sem.24	\N	Non	\N	\N	Scouting FR (sheet) auto-conversion	2026-06-18 20:00:06.05045	2026-06-18 20:00:06.05045	\N	\N	f
129	STATKRAFT RENOUVELABLES	\N	\N	\N	\N	developer	in_discussion	FR	Zone géographique: France\nStade projets: NDA Sent\nNotes: ZT: NDA Sent\n[Migration] Statut Sheet d'origine: 📋 ZT: NDA Sent	\N	Non	\N	\N	Scouting FR (sheet) auto-conversion	2026-06-18 20:00:06.05045	2026-06-18 20:00:06.05045	\N	\N	f
130	Inesys	\N	\N	\N	\N	developer	nda_signed	FR	Zone géographique: France\nStade projets: NDA Executed\nNotes: ZT: NDA Executed\n[Migration] Statut Sheet d'origine: 📋 ZT: NDA Executed	\N	Oui	\N	\N	Scouting FR (sheet) auto-conversion	2026-06-18 20:00:06.05045	2026-06-18 20:00:06.05045	\N	\N	f
131	AS DEV	\N	\N	\N	\N	developer	nda_signed	FR	Zone géographique: France\nStade projets: NDA Executed\nNotes: ZT: NDA Executed\n[Migration] Statut Sheet d'origine: 📋 ZT: NDA Executed	\N	Oui	\N	\N	Scouting FR (sheet) auto-conversion	2026-06-18 20:00:06.05045	2026-06-18 20:00:06.05045	\N	\N	f
132	Cevennes Energy	\N	\N	\N	\N	developer	in_discussion	FR	Zone géographique: France\nStade projets: NDA Sent\nNotes: ZT: NDA Sent\n[Migration] Statut Sheet d'origine: 📋 ZT: NDA Sent	\N	Non	\N	\N	Scouting FR (sheet) auto-conversion	2026-06-18 20:00:06.05045	2026-06-18 20:00:06.05045	\N	\N	f
133	Gascogne Nouvelles énergies SAS	Nicolas Lafarie	\N	\N	\N	developer	in_discussion	FR	Zone géographique: France\nStade projets: Meeting Done\nNotes: ZT: Meeting Done\n[Migration] Statut Sheet d'origine: 📋 ZT: Meeting Done	\N	Non	\N	\N	Scouting FR (sheet) auto-conversion	2026-06-18 20:00:06.05045	2026-06-18 20:00:06.05045	\N	\N	f
134	TCO Solar	\N	\N	\N	\N	developer	nda_signed	FR	Zone géographique: France\nStade projets: NDA Executed\nNotes: ZT: NDA Executed\n[Migration] Statut Sheet d'origine: 📋 ZT: NDA Executed	\N	Oui	\N	\N	Scouting FR (sheet) auto-conversion	2026-06-18 20:00:06.05045	2026-06-18 20:00:06.05045	\N	\N	f
135	Altarea Energies Renouvelables	\N	\N	\N	\N	developer	nda_signed	FR	Zone géographique: France\nStade projets: NDA Executed\nNotes: ZT: NDA Executed\n[Migration] Statut Sheet d'origine: 📋 ZT: NDA Executed	\N	Oui	\N	\N	Scouting FR (sheet) auto-conversion	2026-06-18 20:00:06.05045	2026-06-18 20:00:06.05045	\N	\N	f
136	élecocité	\N	\N	\N	\N	developer	in_discussion	FR	Zone géographique: France\nStade projets: NDA Sent\nNotes: ZT: NDA Sent\n[Migration] Statut Sheet d'origine: 📋 ZT: NDA Sent	\N	Non	\N	\N	Scouting FR (sheet) auto-conversion	2026-06-18 20:00:06.05045	2026-06-18 20:00:06.05045	\N	\N	f
110	SUNMIND SAS	Alexis Jagorel	alexis.jagorel@vinci-concessions.com	\N	\N	developer	nda_signed	FR	NDA: Yes | Priorité: Medium\n\n⏭ Actions:\nÀ intégrer dans le suivi	\N	Oui	\N	À intégrer dans le suivi	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.175883	\N	\N	f
91	bpi France	Clement Cabiron\nGentiane Gire	clement.cabiron@bpifrance.fr \ngentiane.gire@bpifrance.fr	\N	\N	developer	in_discussion	FR	POC: Mariella Mansour | NDA: No | Priorité: High\n👤 Clement Cabiron\nGentiane Gire\n\n📋 Résumé:\ninvestment and financing developers in France.\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.163723	\N	\N	f
92	RES Group	Nicolas Lanoue de Menthon	Nicolas.LanouedeMenthon@res-group.com	\N	\N	developer	in_discussion	FR	RES Group (UK) - Nicolas Lanoue de Menthon & Assane Fassa (RES France)\nRES France = conseil PPA, O&M, asset management. Pas de M&A (vendu a Q Energie il y a 5 ans).\nRES UK = M&A worldwide (cible pour EIR).\nReunion 30/01 : Mariella a presente EIR. Investisseur cherche 100 MW en France d'ici 2026.\nProposition : collab PPA via RES France + intro RES UK pour M&A.\nNotes Gemini 30/01/2026 - https://docs.google.com/document/d/1fzrX2PCG-RBZ2Jd2dJeC5fXkax2-nMkazl7ZJTHPYps/edit?usp=meet_tnfm_email\n\nNotes: Dossier Mariella. Reunion 30/01 faite, suivi envoye. Pas de mouvement depuis janv 2026.	\N	Non	\N	En attente opportunites concretes pour recontacter RES France (PPA) ou RES UK (M&A).	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.164089	\N	\N	f
93	Dekra	Didier Andreotti (resp. commercial regional)	didier.andreotti@dekra.com	33(0)623835653	\N	developer	in_discussion	FR	POC: Mariella Mansour | NDA: No | Priorité: Medium\n👤 Didier Andreotti (resp. commercial regional)\n\n📋 Résumé:\nEPC and O&M (mainly) but maybe also develop projects\nonshore wind and PV\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.164473	\N	\N	f
95	Solaris Nouvelles energies	P. Lalancette	p.lalancette@solaris-nouvelles-energies.fr	06.07.05.42.16	\N	developer	contacted	FR	POC: Zein Tlais | NDA: No\n\n📋 Résumé:\nFrench Dev \nS21 with OA\nLooking for Minority Investors\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.165306	\N	\N	f
97	Renergies	Alexandre Malot	direction@renergies.fr	645789381	\N	developer	nda_signed	FR	23 mar Follow-up meeting with Renergies - 2026/03/23 13:30 CET - Notes by Gemini\n\nRenergies – 6 mars 2026\nActivités :\nDéveloppement PV (France)\nM&A / transactions (Europe) – recherche de projets pour ~20 investisseurs.\nPortefeuille : ~100 MW en développement (12 projets)\n• 7 matures (~60 MW)\n• 5 précoces (~40 MW)\nLes projets sont actuellement financés par un fonds.\nProjets matures : études d’impact terminées, permis en cours (~10 MW/projet).\nCalendrier : premiers permis attendus fin 2026 / début 2027, autres en 2028.\nTypes de projets :\n•        Toitures ≥ 100 kW\n•        Toitures 500 kW – 1 MW (autoconsommation)\n•        Projets au sol 5 – 50 MW\nModèles : vente RTB ou partenariat de développement (financement du développement par jalons).\nInformations :\n•        Renergies analyse le réseau électrique avant de sécuriser un terrain afin de réduire le risque de refus de raccordement.\n•        Analyse : distance au poste source, capacité disponible, possibilité d’un poste source secondaire.\n•        Ratios utilisés : ~1 MW / hectare ; ~1 MW / km ; idéalement < 10 km du poste source.\n•        Possibilité d’échanges techniques en amont avec Enedis.\n•        Le marché solaire repose actuellement sur les appels d’offres, mais ce système pourrait évoluer dans 1–2 ans → développement probable du stockage batterie et de nouveaux modèles de marché.\nOptions de raccordement :\n•        Raccordement classique via Enedis\n•        Piquage sur ligne haute tension avec transformateur dédié\n•        Phasage du raccordement (ex : 10 MW puis 10 MW), avec risque financier.	\N	Oui	\N	follow up on our questions\nthen send projects to investors	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.166453	\N	\N	f
98	REUS (Margaret)	Margaret Nganga	mngangajd@gmail.com	\N	\N	developer	nda_signed	FR	POC: Zein Tlais | NDA: Yes\n👤 Margaret Nganga\n\n⏭ Actions:\nfollow up	\N	Oui	\N	follow up	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.167043	\N	\N	f
99	Enervivo	Sylvain FREDERIC	sylvain.frederic@enervivo.fr	06 76 49 59 01	\N	developer	nda_signed	FR	Full value chain (BE + constructeur + exploitant) | Focus PV sol, toiture, AgriPV, BESS — pas d'éolien | France : 2 MW exploit., 10 MW toiture, ~200 MW pipeline Arc Atlantique | Modèle DevCo/AssetCo en JV 50-50 avec partenaire finançant 80% | Levée 37 M€ France. Cherchent 30-50 M€ pour véhicule international (fin 2026/début 2027) | Co-fondateurs : Damien Léonard, Sylvain Frédéric, Vincent | Marchés : France, Maroc, Tunisie, Sénégal, CI, Cameroun\n\nCall 11/06 (Damien remplaçait Sylvain) :\n🔥 Axe 1 — Maroc (CT) : 3 projets packagés (Coca-Cola construit ✅ + textile + Mexique). 1,7 M€ equity. Urgence sept 2026. PPA signés.\n🏗 Axe 2 — Tunisie (MT) : 5 MW sol. Partenariat ASTEG. Tarif réglementé + garantie change 80%. Mise en service 2027. Rendement ~15%.\n💼 Axe 3 — Levée (LT) : 30-50 M€ pour véhicule DevCo/AssetCo international. Répliquer modèle France. Info memo prêt.\n\nEIR peut apporter : BDD Afrique (matching 5-15 MW, 14-16%), investisseurs Moyen-Orient, veille de projets early stage pour alimenter le pipe de la levée\n\nNotes: Fee agreement envoyé le 19/03. Relance le 11/05 et 17/05/2026. Email Afrique de l'Ouest envoyé le 17/05/2026.	\N	Oui	\N	13/06 : Damien a envoyé pitch deck Maroc + info memo levée | EIR : check BDD Afrique (projets matching sol/toiture ~5-15 MW, 14-16%) + sourcing investisseurs (Maroc 1,6 M€ et levée 30-90 M€) | Réponse envoyée à Damien le 14/06	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.167458	\N	\N	f
100	Feedgy	Harold (CEO/Direction) + Julien (Responsable Développement)	hdarras@feedgy.solar\njroulland@feedgy.solar	33 6 84 57 74 50	\N	developer	contacted	FR	Feedgy intéressé uniquement sur du brownfield PV en exploitation, >10 ans, France et/ou Allemagne.\n\nNotes: Intro via Nelly P. Adresse : 44 rue Lucien Sampaix, 75010 Paris	\N	Non	\N	Recontacter Harold + Julien dès qu'un projet opérationnel correspondant intègre la base Enechange	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.167835	\N	\N	f
101	Sophie Demartini	Sophie Demartini	sophie.eliedemartini@gmail.com	\N	\N	developer	in_discussion	FR	Mariella and (sophie Demartini) - 2026/04/01 10:59 EEST - Notes by Gemini (French)\nbiomethane 2e generation en France	\N	Non	\N	reconnect whenever we have 2nd gen biomethane investors or she knows developers that need investment	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.16825	\N	\N	f
102	Avergies	Nicolas Gente	nicolas.gente@avergies.fr	\N	\N	developer	contacted	FR	Mariella et Nicolas GENTE (Avergies) - 2026/04/22 11:55 EEST - Notes by Gemini (French) inv in PV, BESS, wind, RTB only, 10-30m EUR	\N	Non	\N	NDA then follow up on project teasers	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.168891	\N	\N	f
103	Inesys (Inersys)	Sylvain Corlay	s.corlay@syscom.fr	06 77 74 84 25	\N	developer	nda_signed	FR	Réunion introductive 02/05/2024 (visio). NDA signé 07/05/2024. Sylvain a mentionné période difficile juin 2024. Projets solaires.	\N	Oui	\N	Relancé par email le 21/05/2026 — en attente de réponse.	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.169056	\N	\N	f
104	Terravastus Infrastructures	Dave Kerecha	projects@terravastusinfrastructures.com	\N	\N	developer	nda_signed	FR	Projet gouvernemental Kenya. Terravastus = SPV. NDA signé fév 2025. 100MW Solar + 40MWh BESS. CAPEX $55.4M. PPA $0.08/kWh. Docs: https://drive.google.com/drive/folders/13HZSS0V7-WcCWZaewBnDTAegGB6TvFtH	\N	Oui	\N	Docs analysés — à discuter en interne.	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.169502	\N	\N	f
111	AgriSolarPV	Clotilde Bouvat-Martin	c.bouvatmartin@agrisolarpv.com	06.14.22.29.10	\N	developer	nda_signed	FR	NDA: Yes | Priorité: Medium\n\n⏭ Actions:\nÀ intégrer dans le suivi	\N	Oui	\N	À intégrer dans le suivi	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.176485	\N	\N	f
114	Altergie	Jean-Charles Lavigne Delville	jc.lavignedelville@altergie.eu	06 24 85 23 20	\N	developer	contacted	FR	Bonjour Zein \nMerci pour cette prise de contact. \nNous pouvons être intéressés par l'acquisition de projets solaires au sol en cours de développement.\nBien cordialement\n\nDéveloppeur PV/AgriPV — France. A répondu 12/06 ✅ Call mer 17/06 11h	\N	Non	\N	Call Teams mer 17/06 11h confirmé ✅ — Zein appelle + Mariella en visio	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.178313	\N	\N	f
115	LM Soleil	Henri Le Bouvier	\N	\N	\N	developer	in_discussion	FR	\n\nNotes: Développeur PV — France. A répondu le 12/06 ✅ 3 centrales, 2 construites, OA — fixer call\n\n18/06 ✅ Relance envoyée — Intersolar (23-25 juin) — demande si présent ou dispo début juin	\N	Non	2026-06-18 00:00:00	Attendre réponse Henri (Intersolar ou dispo juin)	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-18 21:56:31.179018		\N	f
142	renner-energies	\N	\N	\N	\N	developer	in_discussion	BE	POC: Zein Tlais\n\n⏭ Actions:\nfollow up	\N	Non	\N	follow up	Journal scouting Zein (logbook)	2026-06-18 20:23:06.010211	2026-06-18 21:56:31.155965	\N	\N	f
107	Harmonie Énergie France	Olivier Mesteuil - Responsable developpement stockage batterie	olivier.amestoy@harmonyenergy.fr	06 99 29 90 84	\N	developer	in_discussion	FR	POC: Mariella Mansour | NDA: Non encore | Priorite: Medium\n\nContact: Olivier Mesteuil - Responsable developpement stockage batterie, Harmony Energy (IPP pur)\n\nContexte:\n• IPP pur : developpe et garde les projets en propre, ne revend pas\n• Specialise stockage batteries grands parcs 50 MWh+\n• Modele: services systeme (reserves, regulation frequence) + trading intraday\n\nEchanges:\n• Call prospection 04/06 ✅\n• 05/06: Mariella a envoye follow-up email -> portefeuille hybride 150+ MW en exclusivite (Solges Energy), pas dispo\n• 05/06: Olivier a repondu Merci Mariella\n• Interesse par RTB stockage standalone, projets hybrides, NDA a envoyer si nouveau projet\n• Intersolar Munich mentionne\n\nNext:\n• En attente nouvelles opportunites BESS standalone/hybride utility-scale	\N	Non	2026-06-05 00:00:00	Attendre nouvelles opportunites BESS standalone/hybride - Intersolar Munich possible	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-19 01:18:16.543398	\N	\N	f
113	EcoLinks	Johnson	johnson@ecolinks.kr	\N	\N	developer	nda_signed	FR	EcoLinks (Johnson Penn) — Coree du Sud. Sebastien Hernandez Cardenas (Carbon Project & Compliance Manager).\nNDA signe mai 2025.\nProjet eau potable Rwanda (Gold Standard, pompage solaire, 210 000 personnes).\nPresentation projet: https://drive.google.com/file/d/1J4MR99D0LQRsZCiHC0C11OfHb3pvVPzH/view\nInvestisseur EIR decline juin 2025 — focus solaire pur, pas interessé pompage eau.\nJohnson a tente de relancer mais sans projet solaire a proposer.\nRelation en veille depuis juin 2025.	\N	Oui	\N	Pas de projet solaire a proposer. Relancer seulement si Johnson a des projets solaires.	FR Follow-ups (import)	2026-06-15 11:28:20.210086	2026-06-22 16:54:39.723639	\N	\N	f
\.


--
-- Data for Name: scouting; Type: TABLE DATA; Schema: public; Owner: hermes
--

COPY public.scouting (id, company, contact_name, email, linkedin, type, status, country, template_used, contact_date, response_date, notes, created_at, updated_at, data) FROM stdin;
1	AMUNDI Transition Énergetique		contact@amundi.com	https://linkedin.com/company/amundi	investor	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: ENR\nCritères: Gérant d'actifs\nNotes: Filiale Amundi dédiée à la transition énergétique	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{}
2	MIROVA		contact@mirova.com	https://linkedin.com/company/mirova	investor	to_contact	FR	\N	\N	\N	Zone géographique: France/Europe\nTechnologies: ENR, Infrastructures\nCritères: Asset manager\nNotes: Asset manager spécialisé ENR	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{}
3	KGAL		info@kgal.com	https://linkedin.com/company/kgal	investor	to_contact	FR	\N	\N	\N	Zone géographique: Europe\nTechnologies: ENR, Infrastructures\nCritères: Investisseur allemand\nNotes: Fonds d'investissement allemand ENR	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{}
633	alpiq				developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
4	RIVE PRIVATE INVESTMENT		contact@rive-pi.com	https://linkedin.com/company/rive-private-investment	investor	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Private equity ENR\nNotes: Private equity	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{}
5	CAISSE DES DEPOTS ET CONSIGNATIONS		contact@caissedesdepots.fr	https://linkedin.com/company/caisse-des-depots	investor	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Financement ENR\nCritères: Institution financière publique\nNotes: Investit dans des projets ENR via CDC	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{}
6	SOCIETE GENERALE		contact.socgen@socgen.com	https://linkedin.com/company/societe-generale	investor	to_contact	FR	\N	\N	\N	Zone géographique: France/Europe\nTechnologies: Financement projets ENR\nCritères: Banque\nNotes: Banque de financement et d'investissement	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{}
7	CREDIT AGRICOLE CIB		cib-contact@ca-cib.com	https://linkedin.com/company/credit-agricole-cib	investor	to_contact	FR	\N	\N	\N	Zone géographique: France/Europe\nTechnologies: Financement projets ENR\nCritères: Banque d'investissement\nNotes: Banque de financement grands projets	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{}
9	BPCE ENERGECO		contact.energeco@bpce.fr	https://linkedin.com/company/bpce-energeco	investor	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Financement ENR\nCritères: Banque spécialisée\nNotes: Filiale BPCE dédiée aux ENR	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{}
11	ENERGIE PARTAGEE		association@energie-partagee.org	https://linkedin.com/company/energie-partagee	investor	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Financement participatif ENR\nCritères: Investissement citoyen\nNotes: Financement participatif ENR	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{}
39	EDF Renouvelables		contact@edf-renouv.com	https://linkedin.com/company/edf-renouvelables	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, Éolien, AgriPV\nStade projets: Majeur français\nNotes: Filiale ENR d'EDF	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
40	Engie Green		contact@engie-green.com	https://linkedin.com/company/engie-green	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, Éolien, AgriPV\nStade projets: Majeur français\nNotes: Filiale ENR d'Engie	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
44	TotalEnergies Renouvelables		contact.rnr@totalenergies.com	https://linkedin.com/company/totalenergies	developer	to_contact	FR	\N	\N	\N	Zone géographique: France/Europe\nTechnologies: PV, Éolien, AgriPV\nStade projets: Majeur\nNotes: Filiale ENR de TotalEnergies	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
87	TSE		contact@tse.energy	https://linkedin.com/company/tse-energy	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, AgriPV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
448	EDF		contact@edf-renouv.com	https://linkedin.com/company/edf-renouvelables	developer	premiere_connexion	FR	\N	\N	\N	BESS Engineer chez EDF (IPP). Stand participant The smarter E Europe 2026 (ees Europe).	2026-06-15 11:28:26.379499	2026-06-19 22:00:43.705153	{"li_1ere_sent": true}
8	CREDIT INDUSTRIEL ET COMMERCIAL (CIC)	\N	\N	\N	investor	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Financement ENR\nCritères: Banque\nNotes: Banque régionale	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{}
10	Banque Neuflize OBC	\N	\N	\N	investor	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Banque privée\nCritères: Banque privée\nNotes: Banque privée, intérêt possible ENR	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{}
12	UNIFERGIE – CREDIT AGRICOLE	\N	\N	\N	investor	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Financement ENR\nNotes: Filiale Crédit Agricole dédiée ENR	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{}
13	GOTHAER	\N	\N	\N	investor	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Assurance ENR\nCritères: Groupe d'assurance\nNotes: Groupe BarmeniaGothaer - assurance, pas ENR	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{"pas_pertinent": true}
14	FILHET-ALLARD ET COMPAGNIE	Patricia Estenaga	\N	\N	investor	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Assurance\nCritères: Cabinet d'assurance\nNotes: Assurance ENR	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{"em_1ere_sent": true, "li_1ere_sent": true}
15	Alaïa Advisory	\N	\N	\N	investor	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Conseil en investissement\nCritères: Advisory\nNotes: Conseil en investissement ENR	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{}
16	Cohérence énergies	Nicolas Hernigou	\N	\N	investor	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Investissement ENR\nNotes: Investissement dans les ENR	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{"em_1ere_sent": true, "li_1ere_sent": true}
17	ENRSUR	\N	\N	\N	investor	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Assurance ENR\nCritères: Courtage\nNotes: Courtage assurance spécialisé ENR	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{}
18	BPI FRANCE FINANCEMENT	\N	\N	\N	investor	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Toutes ENR\nCritères: Investisseur institutionnel	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{}
19	OFI Invest Infra	Sebastien Chemouny - LinkedIn: linkedin.com/company/ofi-invest-real-estate	\N	\N	investor	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Infrastructures\nCritères: Asset Manager infrastructure\nNotes: Nouveau	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{}
20	Axa Investment Managers - Infra	\N	\N	\N	investor	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Infrastructures\nCritères: Assureur/AM infrastructure\nNotes: Nouveau	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
21	Groupama Asset Management	Xavier HOCHE	\N	\N	investor	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Infrastructures\nCritères: Assureur/AM\nNotes: Nouveau	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
22	La Banque Postale Asset Management	\N	\N	\N	investor	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Infrastructures\nCritères: AM infrastructure\nNotes: Nouveau	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
23	BNP Paribas Asset Management	Jean-Baptiste Lefief - linkedin.com/in/jean-baptiste-lefief-499b639	\N	\N	investor	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Infrastructures\nCritères: AM infrastructure\nNotes: Nouveau	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
24	RGreen Invest	Bastien Doutreleau, CFA	\N	\N	investor	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Transition énergétique\nCritères: Fonds infrastructure\nNotes: Nouveau	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
25	Infravia Capital	Nicolas Ritter - LinkedIn contacté	\N	\N	investor	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Infrastructures\nCritères: Fonds infrastructure\nNotes: Nouveau	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
26	Generali France	Enrique ROUSIOU - LinkedIn contacté	\N	\N	investor	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Infrastructures\nCritères: Assureur\nNotes: Nouveau	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
27	Natixis	Arnaud Fricotteau - LinkedIn contacté	\N	\N	investor	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Infrastructures\nCritères: Banque/AM\nNotes: Nouveau	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
28	Marguerite Fund	Christophe Bonnat - LinkedIn contacté	\N	\N	investor	premiere_connexion	FR	\N	\N	\N	Zone géographique: Europe/France\nTechnologies: Infrastructures ENR\nCritères: Fonds infra\nNotes: Nouveau	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
29	La Française AM - Infra	David Iviglia - LinkedIn contacté	\N	\N	investor	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Infrastructures\nCritères: AM infrastructure\nNotes: Nouveau	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
30	Meeschaert AM	Harry Wolhandler - LinkedIn contacté	\N	\N	investor	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Infrastructures\nCritères: AM\nNotes: Nouveau	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
31	Ecofi Investissements	Pierre Rispoli - LinkedIn contacté	\N	\N	investor	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Transition\nCritères: AM durable\nNotes: Nouveau	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
33	Acofi Gestion	\N	\N	\N	investor	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Infrastructures\nCritères: AM infrastructure\nNotes: Nouveau	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
34	Trocadéro Capital	\N	\N	\N	investor	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Investissement\nCritères: Asset manager\nNotes: Nouveau	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
35	Omnes Capital	Camille Zimmermann	\N	\N	investor	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Capital-investissement\nCritères: Asset manager\nNotes: Nouveau	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
36	Demea Sustainable Investment	Philippe Detours	\N	\N	investor	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Infrastructures durables\nCritères: Investisseur durable\nNotes: Nouveau	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
37	Meridiam	Guilhem Vecten	\N	\N	investor	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Infrastructures durables\nCritères: Investisseur infrastructure\nNotes: Nouveau	2026-06-15 11:28:24.855739	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
42	Mozaik Energies	Anthony Dequeant	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, AgriPV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
46	Groupe Watteco	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, AgriPV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
48	Terravene	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, AgriPV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
49	IEL (IEL Energie)	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, AgriPV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
50	Enoe Energie	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, AgriPV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
51	JPee (JP Energie Environnement)	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, AgriPV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
52	OX2	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: Europe/France\nTechnologies: Éolien, PV, AgriPV\nStade projets: Développeur suédois\nNotes: Actif en France	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
53	Ferme Solaire	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, AgriPV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
55	AgriPV Expert	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: AgriPV\nStade projets: Expert/conseil agriPV	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
56	ERG France	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, Éolien\nStade projets: Développeur italien\nNotes: Filiale française d'ERG	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
59	Terapolis	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, AgriPV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
60	Dynamiques Foncières	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, AgriPV\nStade projets: Développeur foncier	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
61	LCEET	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, AgriPV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
62	WKN France	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, Éolien\nStade projets: Développeur allemand\nNotes: Filiale de PNE Group	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
63	Concertation EHPY	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: AgriPV\nStade projets: Concertation agriPV\nNotes: Projet de concertation	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
64	Bergerie Edmond	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: AgriPV\nStade projets: Ferme agrivoltaïque	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
65	OPAT (OPATurages)	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: AgriPV\nStade projets: Projet agricole	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
66	Sud Barrois Agrivoltaïque	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: AgriPV\nStade projets: Projet agrivoltaïque	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
67	La Bergerie Ensoleillée	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: AgriPV\nStade projets: Ferme agrivoltaïque	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
70	Atlacé	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: AgriPV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
71	CDER	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: ENR, AgriPV\nStade projets: Centre de développement ENR	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
72	DAVELE	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur\nNotes: Jeune entreprise dynamique	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
73	EOLFI	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Éolien, PV, AgriPV\nStade projets: Développeur\nNotes: Fondée en 2004, spécialisée ENR	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
74	Eurocape New Energy	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, AgriPV\nStade projets: Développeur\nNotes: Filiale groupe belge Aspiravi?	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
76	GP Joule	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France/Europe\nTechnologies: PV, AgriPV\nStade projets: Développeur/investisseur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
77	Insolight	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: AgriPV (innovant)\nStade projets: Développeur technologique\nNotes: Spécialiste agrivoltaïsme innovant	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
78	La Plateforme Verte	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: AgriPV\nStade projets: Association/plateforme\nNotes: Association lancée pour l'agriPV	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
79	Next2Sun	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: Europe/France\nTechnologies: AgriPV (vertical)\nStade projets: Développeur allemand\nNotes: Spécialiste PV vertical	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
80	Nouvergies	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, AgriPV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
81	OKWIND	Christelle Briancourt	christelle.briancourt@okwind.com	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Eolien, PV\nStade projets: Developpeur\nNotes: Dev eolien	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true, "em_1ere_sent": true}
82	Olived Green (Oilve Green)	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, AgriPV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
83	Photeos	Jeoffrey CUVELLIEZ	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur familial\nNotes: Entreprise familiale experte en PV	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"em_1ere_sent": true, "li_1ere_sent": true}
84	SAFER IDF	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France (IDF)\nTechnologies: Foncier agricole\nStade projets: Acteur foncier\nNotes: Peut être source de projets	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
85	SOLEK	Andrés Bueno	france@solek.com	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: Europe/France\nTechnologies: PV, AgriPV\nStade projets: Développeur groupe\nNotes: Fondé en 2010, groupe spécialisé	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"em_1ere_sent": true, "li_1ere_sent": true}
86	Sun'Agri	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: AgriPV\nStade projets: Pionnier agrivoltaïsme\nNotes: Pionnier et leader agrivoltaïsme France	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
88	Triangle Solr	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, AgriPV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
89	Vent d'Est	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France (Est)\nTechnologies: Éolien, PV\nStade projets: Propriétaire exploitant\nNotes: Propriétaire exploitant ENR	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
91	Weenat	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: AgriTech\nStade projets: Capteurs agriculture\nNotes: Startup agritech, partenaire possible	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
92	Zamana	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: AgriPV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
94	Albiona	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, Éolien, Bioénergies\nStade projets: IPP\nNotes: Producteur d'électricité verte	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
95	Alterelec	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
96	Arverne Group	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Géothermie, ENR\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
99	Bohr Énergie	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
100	BW Ideol	Paul DE LA GUERIVIERE	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Éolien flottant\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"em_1ere_sent": true, "li_1ere_sent": true}
101	Capg Énergies Nouvelles	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, Éolien\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
102	Clean Horizon	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Stockage, BESS\nStade projets: Conseil stockage\nNotes: Expert stockage énergie	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
103	Cogra	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Biomasse, ENR\nStade projets: Producteur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
104	Compagnie Nationale du Rhône (CNR)	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Hydro, PV, Éolien\nStade projets: Producteur public	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
105	Copenhagen Offshore Partners	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: Europe\nTechnologies: Éolien en mer\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
106	CorexSolar	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
107	Cythelia Energy	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, Éolien\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
108	Dream Energy	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, AgriPV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"pas_pertinent": true}
109	EDF Hydro	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Hydroélectricité\nStade projets: Producteur majeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
110	EDF Solutions Solaires	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Filiale EDF	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
111	EDPR France Holding	\N	arthur.clouzeau@edpr.com	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, Éolien\nStade projets: Développeur (EDP)\nNotes: Filiale de l'portugais EDP	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"bounced": true}
112	EnBW France	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, Éolien en mer\nStade projets: Développeur allemand	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
113	Energieteam	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
114	Enerlis	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, Éolien\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
115	Enesi	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
116	Engie Solutions	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, Éolien, Services\nStade projets: Filiale Engie	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
117	Eolise	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Éolien\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
118	Eolink	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Éolien flottant\nStade projets: Développeur innovant	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
119	Erro	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
120	Euralis	Christophe Congues	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, AgriPV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"em_1ere_sent": true, "li_1ere_sent": true}
121	Eurocap Energie	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
122	Européenne de Biomasse	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Biomasse\nStade projets: Producteur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
123	Finergreen	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Conseil M&A ENR\nStade projets: Banque d'affaires ENR\nNotes: Peut avoir des contacts	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
124	France Hydro Électricité	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Hydroélectricité\nStade projets: Fédération	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
125	Galileo Green Energy	Anthony Dequeant	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur\nNotes: Anthony Dequeant (contact LinkedIn)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
126	Girasole Énergies	IVAN RENAUDIN	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"em_1ere_sent": true, "li_1ere_sent": true}
127	Glint Solar	Even J. Kvelland	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, AgriPV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"em_1ere_sent": true, "li_1ere_sent": true}
128	Green Lighthouse Développement	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, AgriPV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
131	IDEC Energy	\N	b.nobilliaux@groupeidec.com	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, AgriPV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"bounced": true}
133	Innergex	\N	lyon@innergex.com	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, Éolien, Hydro\nStade projets: IPP canadien	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"bounced": true}
134	Inthy Développement	Dominique Darne	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Hydro, PV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"em_1ere_sent": true, "li_1ere_sent": true}
135	Kallista Energy	\N	contact@kallistaenergy.com	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, Éolien\nStade projets: IPP	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"bounced": true}
136	KilowattSol	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur\nNotes: Ancien contact: Jérôme Sac — parti. Contacté LinkedIn juin 2026 → réponse: Technical Advisor ailleurs, pas pertinent EIR.	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
137	Klara Energy	Jérôme Connord	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, Éolien\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"em_1ere_sent": true, "li_1ere_sent": true}
142	Nara Solar	Yago Acón	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"em_1ere_sent": true, "li_1ere_sent": true}
143	Naturgy Renouvelables France	\N	renouvelables@naturgy.com	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, Éolien\nStade projets: Développeur espagnol	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"bounced": true}
145	Nordex France	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Éolien\nStade projets: Fabricant/développeur\nNotes: Fabricant d'eoliennes allemand	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"pas_interesse": true}
146	NovaFrance Energy	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
148	Obton France	Sebastian Schultheis	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur/investisseur\nNotes: Groupe danois	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"em_1ere_sent": true, "li_1ere_sent": true}
149	Oxan Energy	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
152	Seabased France	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Énergies marines\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
153	Siemens Gamesa Renewable Energy	\N	france.information@siemensgamesa.com	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Éolien\nStade projets: Fabricant/développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"bounced": true}
155	So Watt	BERTRAND MASSAT	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"em_1ere_sent": true, "li_1ere_sent": true}
156	Solédom	\N	Pas intéressant	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
157	Solora	Tomas Dewitte	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"em_1ere_sent": true, "li_1ere_sent": true}
159	Sunrock France Holding	Christian MOUCHEL	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur/investisseur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"em_1ere_sent": true, "li_1ere_sent": true}
160	Sunseo	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
161	Sunvest	Yann Thebault	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
162	Synerdev	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
183	projetsolaire.com	Louise S-A	louise@projetsolaire.com	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France (OM)\nTechnologies: PV\nStade projets: Developpeur OM\nNotes: Solaire Outre-mer	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"bounced": true}
184	opdenergy	Zouhair Rachid	zrachid@opdenergy.com	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France/Europe\nTechnologies: PV, Eolien\nStade projets: IPP espagnol\nNotes: IPP France	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"bounced": true}
189	CORIO	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
190	Devenr	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
191	Generale du solaire	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
192	Enercoop	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
194	Emeren Group	Enmanuel Boillos	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
195	BayWa r.e Solar Systems SAS	Laurent Barrau	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-07-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
197	NEWHEAT	Pierre Delmas	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2024-11-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
198	TRINA SOLAR FRANCE SYSTEM	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
200	ACTEAM ENR	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
201	Verso Energie	Guillaume Teulieres	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2026-03-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
202	CalyWattSol	Clément Lainé	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (March 25)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
199	ALTERGIE DEVELOPPEMENT	Antoine de Marliave	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-11-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
203	Cero France	06 19 27 51 68	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-06-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
205	E-SWEET ENERGIES	Nicolas Bodereau	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
207	ELMY Développement	Thomas Rochoux	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-09-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
208	ENERGIES DE LOIRE EDL	David LEROUEIL	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
209	ENERLANDES	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
210	ENERTRAG Etablissement France	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
211	EUROWATT DEVELOPPEMENT SASU (Virya)	06 44 28 17 51	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-07-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
212	GAIA Energy Systems	Thibault Rebourcet	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
216	IKAROS SOLAR	06 74 48 75 78	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2024-10-16 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
218	LANGA	Thibaud Pradal	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-09-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
220	SCEA DOMAINE DE BERNEUIL	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
221	OPALE ENERGIES NATURELLES	Antoine CACIO	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (April 25)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
222	OPTAREL	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
223	Ostwind international	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
224	Prosolia France	Alexis Ribeiro-Reis	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
225	QUENEA'CH	ludovic MERLIERE	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
227	GROUPE SOLGES	Guillaume ORGEAS	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (March 25)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
228	SOLIGEST	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
229	Sonnedix France Services	Carlos Guinand	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-09-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
232	TERRE ET LAC SOLAIRE	Sebastien Fenet	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
233	Iberdrola Renouvelables France	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
234	Iberdrola France	Elodie Calmels	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-09-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
236	UNITe	06 70 81 66 01	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-09-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
237	VALECO INGENIERIE	François Daumard	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-09-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
238	Calyce-developpement	Mathieu POQUET	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-06-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
239	Virya	Pieter Marinus	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-07-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
240	Terr.a	Olivier Aymard	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
241	Melvan	Laurent Albuisson	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-09-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
242	Enercoop Paca	Julien Noé	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-09-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
243	VOLTANIA	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
244	Sunopee	Eric Fenouil	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2024-11-14 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
245	SDESM ÉNERGIES	01 82 79 00 69	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (Fev 25)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
150	Perpetum Energy	Matías Baigorría Heise	francois.flament@perpetum.fr	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: Belgique\nPortefeuille (MW): PV/Eolien\nStade projets: Bounce France\nNotes: En attente réponse - 06/06	2026-06-15 11:28:26.379499	2026-06-18 20:23:06.010211	{"bounced": true, "li_1ere_sent": true}
246	Girasole Energies	Pierre-Marie BERLINGERI	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-03-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
247	LUCIA ENERGIE	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
248	ib vogt France	07 88 68 04 35	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-09-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
250	cvegroup	Fabien Martel	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2024-11-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
252	Corexsolar International	rivas manzo franck	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (Fev 25)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
253	LÉON GROSSE Energies Renouvelables	Xavier Rosa	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2024-09-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
255	VSB	04 66 21 78 43	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (Dec 2025)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
256	Enoé	Marc Watrin	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-07-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
257	ventelys	06 58 26 98 83	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-09-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
258	Nass et Wind	02 97 37 56 06	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (May 25)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
259	reservoir sun	Mathieu Cambet	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (Fev 25)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
260	Pierreval Energie	Morgan Owona	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
261	SOLSTYCE	01 83 62 13 29	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
262	serenysun	Donald Francois	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
263	Enovos France	06 19 36 56 96	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
264	CLEOSUN	Valentin Doguet	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-07-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
265	Ryall Energy	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
266	H. Family Office	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
267	axesscible	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
268	3D ENERGIES	Pierre MORA	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
269	ENERTRAG France	Antoine Pouille	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
270	Eolec	Ulrich Schmall	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
271	europeanenergy	Nicolas Koenig	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
272	skybornrenewables	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
273	ZEPHYR ENERGIES RENOUVELABLES	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
274	THYSEO	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
275	Greenbirdie	Gaetan COLLIN	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2024-11-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
276	Telamon	01 42 56 26 46	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-09-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
277	EnergieKontor France	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
278	X-ELIO	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
279	Jpee	Sylvain Vasseur	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (March 25)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
280	GREENVOLT POWER	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
281	WATT&CO INGENIERIE	05 67 29 04 61	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
282	EDPR in France	JONAS MENENDEZ	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2026-03-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
283	GREEN YeLLOW	Romain Butte	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
284	TERRASOLAIRE	Simon Bertorelle	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (ct 25)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
285	TECSOL	Malik Hamadi	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
287	AFRICA REN DEVELOPMENT	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
288	CIEL ET TERRE INTERNATIONAL	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
289	CORUSCANT DÉVELOPPEMENT	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
290	SOLARVIA	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
291	ABO WIND	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
292	Agriterra	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
293	WPD SOLAR France	Grégoire Simon	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
294	(2) Corsica Energia: Overview | LinkedIn	DepHy International	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
295	COPERGREEN	Elise Duclos-Beaubois	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
296	Crédit Agricole Transitions & Energies	Thomas Colpin	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
298	En Volt Toit	Antoine Couillet	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
299	Prejeance Industrial	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
300	Olifan groupe	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
301	Banque de la Transition Energétique par BPAURA	Pierre-Henri GRENIER	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
302	DI SOLAR	Ayoub DIOUANE	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
303	CREDIT AGRICOLE TOULOUSE	06 60 92 93 69	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2024-09-30 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
304	OSER ENR	Alexandre Cartillier	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
305	GREEN CONSULT B.V.	06 64 97 57 91	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2024-10-05 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
306	AENOW (Groupe ALSEI)	Anthony Perez	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
307	Green Cape Partners	06 17 26 36 29	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
308	LENDOPOLIS	09 72 32 49 42	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
309	IDEC ENERGY SOLAR	01 42 68 59 57	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
310	Crédit Industriel et Commercial CIC	01 53 48 51 83	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-11-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
311	ValEnergies	David Raguet	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
312	OSIA ENERGIES	Stéphane Bernardot	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
313	Enerev	Adrien P	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
314	BoucL Energie	07 67 53 01 54	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
315	Enercitif	06 86 42 67 25	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
316	Digitalsun Enr	06 40 12 67 97	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
317	Morbihan énergies	02 97 62 07 50	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
318	VOLTAÏCA	04 95 39 66 55	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
319	VISOLAR	04 68 21 09 09	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
320	Chint	Christophe Leyssieux	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (May 25)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
321	RADIANCE ENERGY	06 80 26 49 01	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (March 25)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
322	EXERGREEN Développement	06 07 01 03 12	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
323	Latitude Solaire	Johan Poujol	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (April 25)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
324	HORNET ENERGIES	Julien Chaumont	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (April 25)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
325	Néomix	Pierre Levi	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-03-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
326	LUMÉOL	Lucas Fougeras	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-03-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
327	Altémed	Cédric GRAIL	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
328	Nancy Sud Lorraine Energies	Jérémy SCHILD	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
329	CatEnR	Bertrand Rodriguez	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (pas urg)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
330	Éclaircie	Victor Mathevet	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2026-03-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
331	Tenea Energies	Benoit Giraud	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
332	Enrise	Armand d'Ambrières	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
333	ENERAGRI	Stefano Carteri	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
334	Helexia Agri	🌍 Christophe CONSTANT	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
335	SOLARIS NOUVELLES ÉNERGIES	Paul Lalancette	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
336	ENERGITER OUEST S.A.S.	Nicolas SICOT	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
337	Colibri Solar	Sébastien GIOIA	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
338	SASU NEOS	Natacha B	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
339	Maïa Energie	Philippe Lesoil	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
340	SEM Energies Hauts de France	LEFÈVRE Anne	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
341	Alliance Énergies	Eric Huber	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
342	Syan'EnR	Patrice Ravaud	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (2025-10-01 0)	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
343	ALBIOMA SOLAIRE FRANCE	Frédéric Lebret	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
344	SunVolt	Michel de Keréver	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
347	BILLAS AVENIR ENERGIE	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
348	artelia-group	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
349	ARHYZE	Jérémy Da Costa	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
350	BME	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
351	ORKANE	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
352	SOL'R	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
353	Albioma	Julien Gauthier	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2024-09-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
355	IEL energie	Ronan MOALIC	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-09-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
356	Energiequelle	Mathilde Jacquot	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-09-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
357	ENERGIES NOUVELLES COURTAGE	Christian MARTIN	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (Fev 25) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
358	Hanau Energies SAS	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
359	ORION ENERGIES	Hadrien CLEMENT	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
360	OSTARA ENERGIES	Alexandre Piquet	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
361	PAREF SAS	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
362	RENEW SUN	Jérôme FONTES	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2024-11-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
363	SEE YOU SUN	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
364	SEPALE	Cédric ANDRE	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
365	SEPE de Boyes SSE Renewables	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
366	Soleil du Midi	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
367	SUNSTO	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
368	IBITU	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
369	TECHNIQUE SOLAIRE	Julien Fleury	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-09-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
370	TELISOL SAS	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
372	ZE ENERGY	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
374	Groupe IEL	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
375	PCER	Ibrahim Diallo	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (april 25) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
376	GROUPE IDEC	Vincent KERSUZAN	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
377	GREENYELLOW	Julien (Julien ROULLAND) ROULLAND	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-03-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
378	INTERNAT SARL	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
379	LES TECHNICIENS DU SOLAIRE	Vincent marchand	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (Pas urg) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
380	DAVID PROJECT	Benoit Paris	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (April 25) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
381	LMG SOLAIR	Philippe Larmagnac	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (April 25) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
383	FRANSOLIS	06 16 39 26 78	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-09-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
384	amicus salus	Jean-Benoit Rio	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (Fev 25) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
385	Energ'Isère Seml	PASCAL CERVANTES	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (Fev 25) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
386	GLHD	Vincent Vignon	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
387	Inthy	07 78 47 06 17	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2024-11-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
388	SERFIM ENR	04 94 22 66 79	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-03-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
389	valence romans agglo	Candice MAGNARD	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (March 25) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
390	VDN SOLAIRE	Lola Jurrius	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-07-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
391	PROSOLIA	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
392	Aventron	Thomas Bitzi	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
393	omexom	Guillaume Berniolles	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"em_1ere_sent": true, "li_1ere_sent": true}
394	IDSUD Energie	Farid SAID	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (Fev 25) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
395	Bearn nouvelles energies	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
396	gascogne-nouvelles-energies	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
397	PERSONNEL	06 75 22 91 10	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
398	NEVO SOLAR	07 56 90 18 10	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (April 25) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
400	Green tower	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
401	bae energie	https://www.linkedin.com/in/yanis-denil-7ba5b816/overlay/about-this-profile/	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
402	ENESI SARL	Angela Pristauz-Telsnigg	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-06-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
403	HELIANTIS ENERGIES	Axelle Revel	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-06-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
404	SOLVEO ENERGIES	Frederik Nilsson	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
406	eneralys	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
407	GIPSI SAS	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
408	Groupe financier JC Parinaud	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
409	RIVAGE	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
410	Groupe Quasard	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
411	SkalePark	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
412	Techno’Start	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
413	Solylend	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
414	Argiduna Capital	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
416	alterric-france	Brice Mangin	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
417	DVP	Eduardo Criado Martínez	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
418	Encavis	Quirin Busse	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
419	EnBW	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
420	Future Energy France	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
421	Galileo energy	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
422	HDF	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
423	leonid	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
424	naturalpower	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
425	qualitasenergy	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
426	RP GLOBAL FRANCE	Luis Manuel del Vado Cerrillo	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-09-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
427	soledra	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
428	Soluxions	06 98 43 25 88	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2024-11-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
429	terega	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
430	vent-d-est.	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
431	VERBUND	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
432	SCATEC SOLAR	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
433	LUMO	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
434	VALEMO	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
435	TERRE & WATT	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
436	Babel Energy	Thibaut Levesque	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (March 25) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
437	AMDA ENERGIA	https://www.linkedin.com/in/sylvain-vasseur-10130235/overlay/about-this-profile/	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
438	RWE RENOUVELABLES FRANCE SAS	https://www.linkedin.com/in/carole-descroix-97291718/overlay/about-this-profile/	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
439	EHPI	Benjamin Courdier	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
440	PHOTOCIBLE	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
441	AKUO ENERGIE	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
442	CVE - CHANGEONS NOTRE VISION DE L’ÉNERGIE	Pierre de Froidefond	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-07-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
444	SYSTEKO	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
445	SAMSOLAR	Christophe DUMAS	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-09-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
446	Agri Valdi Vert	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
447	Agyl Capital	Aude Walter	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
449	WiSEED Transitions	Jean Marc CLERC	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
450	LA NEF	joel lebossé	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
451	Crédit Agricole d'Aquitaine	Antoine Malmezat	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2024-10-29 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
452	Terra Nea	Dimitri de Lanversin	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
453	SCIC-SAS CITOY'ENR	Arnaud CAYROL	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-06-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
454	CACL Energies Renouvelables	02 38 60 20 81	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
455	Crédit Agricole Pyrénées Gascogne	05 59 12 66 99	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2024-11-15 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
456	Andera Smart Infra	06 71 32 77 82	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
457	ETIC Partners	Pierre Pochet	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
458	Générale du Solaire	01 72 71 59 01	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
459	Soleriel	09 80 80 40 57	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
373	Storm	Jan Caerts (Fondateur)	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: Belgique\nPortefeuille (MW): Energie\nNotes: Contact LinkedIn par Zein	2026-06-15 11:28:26.379499	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
460	CitoyENergie	04 50 43 78 77	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
461	MW Energies	06 20 12 78 89	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
462	UEM	06 08 93 27 91	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
463	GE Grid Solutions	Julien Saint Girons	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
464	VoisiWATT	07 76 30 01 12	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
465	solapro	Olivier-Jean Rigaud	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
466	Lightsource bp	Raphaël Colas	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
467	Solaire XP	Emmanuel Vasseur	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
468	Sunid	Nicolas CRISTI	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
469	H.Saint-Paul	Thierry Brun	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
470	Eiffage	Benoît de Ruffray	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
471	SEML ENERLANDES	Eric Gorman	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
472	France Solar	Christophe Dillenseger	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
473	Soper	Laurent Espitalier-Noël	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
474	SOLAR DISTRIBUTION	Yann MONNIER	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
475	Energies du sud	christelle guery	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
476	Régie Municipale d'Electricité de Toulouse	Francois Bories	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (pas urg) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
477	Homea	Quentin Froment	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
479	Société du canal de provence	Jean-françois cloarec	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
480	Sostea	Jean-baptiste NAVARRO	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
481	ENR Courtage Pro	06 13 47 14 77	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
482	SAS DELHOMMEAU	Michaël Delhommeau	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
483	GROUPE GALOPIN	Lionel SENAN	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
484	PRIMOSOLAR GROUPE	STEPHANE GILLI	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
485	LA FRUITIERE A ENERGIES	Célia BESSOT	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
486	Crédit Mutuel Equity	Sylvain Maricourt	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
492	AMARENCO FRANCE	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nStade projets: Not Interrested	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"pas_interesse": true}
495	ENERGIES DE LOIRE	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
496	EUROWATT DEVELOPPEMENT SASU	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
500	SOLARHONA	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nStade projets: Not Interrested	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"pas_interesse": true}
501	SOLGES ENERGY	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
502	TSE ENERGY	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nStade projets: Not Interrested	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"pas_interesse": true}
504	W.E.B Energie du vent	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nStade projets: Not Interrested	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"pas_interesse": true}
506	CNR (Compagnie Nationale du Rhône)	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nStade projets: Not Interrested	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"pas_interesse": true}
508	CALYCE	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
512	Uniper	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
515	GREEN YALLOW	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
516	ENERCOOP HAUTS-DE-FRANCE	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
517	lease bpce	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
518	Amundi	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
519	Cohérence energie	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
520	Énergie Partagée	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
521	Credit Agricole Leasing & Factoring	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
524	BLUEFLOAT ENERGY	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
525	CGN Europe Energy	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
526	CUBE GREEN ENERGY SAS	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
527	ELICIO FRANCE	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
528	ENBW – Energie	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
530	ENGIE GREEN FRANCE	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
531	EOS Wind France	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
532	GEG ENR	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
533	GP JOULE France	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
534	Iqony Wind France	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
535	Noria	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
536	NTR WIND MANAGEMENT DAC	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
537	OCEAN WINDS	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
539	RENANTIS	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
540	NADARA	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
541	SAB Energies Renouvelables	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
542	SERGIES	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
544	WINDSTROM FRANCE	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
545	30 Degres sud	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
546	Abic	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
548	Capsun energie	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
552	Enercoop Normandie	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
553	Nexhos Energies	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
554	MONTS ÉNERGIES	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
555	ENERGIES des TERRITOIRES	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nStade projets: Not Interrested	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"pas_interesse": true}
559	ALTO Solution	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France\nStade projets: Not Interrested	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"pas_interesse": true}
560	Valénergies	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
562	KIWI ÉNERGIES	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
563	Acacia	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
565	Calyce 6	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
566	Grupo Cobra	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
567	COPENHAGEN OFFSHORE PARTNERS A/S	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
568	SOFIVA ENERGIE	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
569	Viridi Energies Renouvelables	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
570	SOLATERRA	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
571	DERASP	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
572	ECLIPSE	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
573	ENBW VALECO OFFSHORE SAS	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
574	ENERGIE EOLIENNE FRANCE Sas	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
564	APAL MW	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
575	INNOVENT	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
577	IWB	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
578	Dalkia	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
579	IDEX	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
580	Ilek	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
581	ZENITH SOLAIRE	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
582	KNR Renewable Energy	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
583	NUCLEOSUN	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
584	Afreenergy	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
585	énergreen	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
586	Avento	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
587	SEML AXE SEINE ENERGIES RENOUVELABLES	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
588	Totalenergies	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
589	Siemens Gamesa	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
590	VALREA (filiale valorem)	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
591	Apexenergies	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
592	WindVision Projects	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
593	Quadran	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
594	Velocita Energies	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
595	Envision Energy	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
596	Dhamma	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
598	Guadeloupe EnR	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
599	NOTUS	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
600	CHALBOS ENERGY	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
601	Soleil du Sud	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
624	montanSOLAR	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
625	Mana Energies	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
626	EREA INGENIERIE	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
627	ID Energy Group	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
628	Finsat Capital Luxembourg	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
630	Genelios	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
632	Capenergie	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
654	Energreen	\N	info@energreen.be	\N	developer	to_contact	BE	\N	\N	\N	Zone géographique: Belgique\nPortefeuille (MW): PV/Eolien\nTechnologies: A scout	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"bounced": true}
655	Biogaz du Haut Geer	\N	contact@biogazduhautgeer.be	\N	developer	to_contact	BE	\N	\N	\N	Zone géographique: Belgique\nPortefeuille (MW): Biogaz\nTechnologies: A scout	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"bounced": true}
656	Biowanze	\N	info@biowanze.com	\N	developer	to_contact	BE	\N	\N	\N	Zone géographique: Belgique\nPortefeuille (MW): Biogaz\nTechnologies: A scout	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"bounced": true}
657	Clef	\N	info@clef.be	\N	developer	premiere_connexion	BE	\N	\N	\N	Zone géographique: Belgique\nPortefeuille (MW): Cooperative ENR\nTechnologies: A scout	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"em_1ere_sent": true}
658	Energie Commune	\N	info@energiecommune.be	\N	developer	premiere_connexion	BE	\N	\N	\N	Zone géographique: Belgique\nPortefeuille (MW): Cooperative ENR\nTechnologies: A scout	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"em_1ere_sent": true}
659	Etherra	\N	contact@etherra.com	\N	developer	premiere_connexion	BE	\N	\N	\N	Zone géographique: Belgique\nPortefeuille (MW): PV\nTechnologies: A scout\nStade projets: Deja en CRM France	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"em_1ere_sent": true}
660	wpd Belgium	Ben Bisenius / Stéphane Diez Rabago	\N	\N	developer	deuxieme_connexion	BE	\N	\N	\N	Zone géographique: Belgique\nPortefeuille (MW): PV/Eolien	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
642	Engie (Belgium)	Emmanuel Gagniere	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	Zone géographique: Belgique\nPortefeuille (MW): IPP/PV/Eolien\nStade projets: Majeur	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
643	Eneco Belgium	Alain Ovyn	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	Zone géographique: Belgique\nPortefeuille (MW): IPP/Energie\nStade projets: Majeur	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
644	Luminus (EDF Group)	Thomas Ganne	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	Zone géographique: Belgique\nPortefeuille (MW): IPP/PV/Eolien\nStade projets: Filiale EDF	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
645	Eoly (Colruyt Group)	Jehan Decrop	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	Zone géographique: Belgique\nPortefeuille (MW): Eolien/Energie	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
646	Aspiravi	Edwin Kerboriou	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	Zone géographique: Belgique\nPortefeuille (MW): Eolien	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
647	Elawan Energy	Rodrigo Cano Rodríguez-Arias	\N	\N	developer	deuxieme_connexion	BE	\N	\N	\N	Zone géographique: Belgique\nPortefeuille (MW): PV/Eolien\nStade projets: IPP espagnol BE	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
649	Eno Energy	\N	info@eno-energy.com	\N	developer	premiere_connexion	BE	\N	\N	\N	Zone géographique: Belgique\nPortefeuille (MW): PV\nTechnologies: A scout	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"em_1ere_sent": true}
635	Soc Invest	\N	\N	\N	investor	premiere_connexion	BE	\N	\N	\N	Zone géographique: Fonds\nMandat (MW): À scout	2026-06-15 11:28:33.390881	2026-06-15 11:28:33.390881	{}
634	Société d'Investissement	\N	\N	\N	investor	to_contact	BE	\N	\N	\N	Zone géographique: Fonds\nMandat (MW): À scout\nTechnologies: logo-soc-invest	2026-06-15 11:28:33.390881	2026-06-15 11:28:33.390881	{}
636	PV-Fin	\N	\N	\N	investor	to_contact	BE	\N	\N	\N	Zone géographique: Financement PV\nMandat (MW): À scout	2026-06-15 11:28:33.390881	2026-06-15 11:28:33.390881	{}
637	SpaQue	\N	\N	\N	investor	to_contact	BE	\N	\N	\N	Zone géographique: Financement\nMandat (MW): À scout	2026-06-15 11:28:33.390881	2026-06-15 11:28:33.390881	{}
639	SWDE	\N	\N	\N	investor	to_contact	BE	\N	\N	\N	Zone géographique: Eau/Energie\nMandat (MW): À scout	2026-06-15 11:28:33.390881	2026-06-15 11:28:33.390881	{}
640	Bep	\N	\N	\N	investor	to_contact	BE	\N	\N	\N	Zone géographique: Agence dév. éco.\nMandat (MW): À scout	2026-06-15 11:28:33.390881	2026-06-15 11:28:33.390881	{}
678	Aquila Clean Energy	Sonia León	sonia.leon@aquila-capital.com	\N	investor	to_contact	ES	\N	\N	\N	Zone géographique: Andalucía, Castilla y León, Castilla-La Mancha, C. Valenciana, Extremadura, Murcia\nTechnologies: Solaire PV\nCritères: IPP / Investissement\nNotes: Fonds d'investissement allemand. Producteur d'énergie propre en Espagne.	2026-06-15 11:28:36.705667	2026-06-18 20:49:59.65214	{"bounced": true}
677	ABANCA Energy	F. García	fgarciac@abanca.com	\N	investor	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Investisseurs)	2026-06-15 11:28:36.705667	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
710	AVINTIA	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
711	Axon Time	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
712	Axpo Solar Iberia	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
713	BBVA	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
714	BDL Energy	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
715	BM2Solar	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
716	BOGARIS	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
717	BayWa r.e.	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
718	BeePlanet Factory	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
719	Belectric España	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
720	Benbros Energy	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
721	CHELION	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
722	CIRCLE ENERGY	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
723	COAGENER	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
724	CONERSA	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
725	CTG EU	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
726	Campo Zero	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
727	Cubico	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
728	DARGON ENERGY	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
729	DOMINION ENERGY	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
730	Diverxia	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
731	EDORA	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
732	EFELEC ENERGY	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
733	EKHI	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
734	ELAWAN ENERGY	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
735	ENDESA GENERACIÓN	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
736	ENERCAPITAL	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
737	ENERPAL	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
661	BayWa r.e. Belgium	\N	info@baywa-re.com	\N	developer	to_contact	BE	\N	\N	\N	Zone géographique: Belgique\nPortefeuille (MW): PV\nTechnologies: A scout	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"bounced": true}
739	ENERSIDE	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
740	ENPIA	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
741	EUDER ENERGY	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
742	Econergy	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
743	Elecsum	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
744	Emeren	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
745	Enerclic	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
746	Energreen Ibérica	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
747	Enerhi	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
749	Esparity Solar	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
750	Estabanell	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
751	FF VENTURES	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
752	FRV	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
753	Factor Energia	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
754	Ferrovial Energía	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
755	G-ENER	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
756	GC Development Group	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
757	GOLDBECK SOLAR	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
758	GREEN4YOU	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
759	GRENERGY	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
760	GRUPOTEC	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
761	Gamesa Electric	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
762	Green Mind Ventures	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
763	Green Tie Capital	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
764	Greenar	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
765	HECE	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
766	HERGO RENEWABLES	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
767	HYP Renewables Spain	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
768	Helexia	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
770	IBERDROLA RENOVABLES	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
771	IBERIA SOLAR	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
772	IBERSUN	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
773	IBV Solar Spain	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
774	ICOENERGÍA	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
775	IMPELIA ENERGY	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
776	IRRADIA ENERGIA	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
777	ISEMAREN	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
778	ISFOC SAU	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
779	Ingelectus	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
780	Innovo Renewables	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
781	Isotrol	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
782	JINKO POWER SPAIN	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
783	KM0 ENERGY	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
784	KOLYA PNE	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
785	Kenergy	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
786	LILAN ENERGY	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
787	Luminous Renewable Energy	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
788	MATRIX RENEWABLES Spain	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
789	MINISTRY OF SOLAR	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
790	MORERA VALLEJO RENOVABLES	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
792	NESS	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
793	NetOn Power	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
794	Nexer	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
795	Nexun Solar Spain	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
796	OHLA Energy	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
797	OKAMI POWER	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
798	OLARIS ENERGY	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
799	PARQUES SOLARES DE NAVARRA	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
800	PGP	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
662	TotalEnergies Belgium	\N	contact.be@totalenergies.com	\N	developer	to_contact	BE	\N	\N	\N	Zone géographique: Belgique\nPortefeuille (MW): PV/Eolien\nTechnologies: A scout	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"bounced": true}
802	PLENIUM PARTNERS	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
803	POWEN	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
804	PROAT	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
805	PYDESA RENOVABLES	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
806	Praxedo	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
807	Prenergy	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
808	Progressum	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
809	Prokon	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
810	Q Energy	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
811	QBi Solutions	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
812	QUANTOM SOLAR ESPAÑA	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
813	Qualifying Photovoltaics	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
814	Qualitas Energy	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
815	Quinto Armónico	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
816	R.Power	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
817	RDS	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
818	REPSOL	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
819	RIC ENERGY	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
820	Recap Energy	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
822	Renewco	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
823	Renovartia	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
824	Risen Energy	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
825	Rústicus	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
826	SOLARBAY	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
828	SUD Renovables	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
663	Veolia Belgium	\N	contact@veolia.be	\N	developer	to_contact	BE	\N	\N	\N	Zone géographique: Belgique\nPortefeuille (MW): Energie/Env.\nTechnologies: A scout	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"bounced": true}
830	Senda	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
831	Sinia Renovables	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
832	Smartenergy	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
833	Solarig Global Services	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
834	Solartree	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
835	Soldelia	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
836	Sunowatt	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
837	TKSOL	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
838	TOTAL ENERGIES	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
839	TRINA SOLAR SPAIN	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
840	Taiga Mistral	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
841	Tauber Solar Iberia	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
842	UBORA SOLAR	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
843	UKA Iberia	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
844	Umbrella Global Energy	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
847	Verbund Green Power Iberia	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
848	Verdian	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
849	WSP	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
850	Wattwin	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
851	Youdera	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
852	Zelestra Corporación	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
853	Zenit	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
854	iGU Energy	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
855	iasol	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-15 11:28:38.212806	{}
665	Sunbuild	Gilles Charlier	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	Zone géographique: Belgique\nPortefeuille (MW): PV	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
666	Power Dev Engineering	\N	info@powerdev.be	\N	developer	to_contact	BE	\N	\N	\N	Zone géographique: Belgique\nPortefeuille (MW): PV/EPC\nTechnologies: A scout	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"bounced": true}
668	Encon	Frederik Serdongs	\N	\N	developer	deuxieme_connexion	BE	\N	\N	\N	Zone géographique: Belgique\nPortefeuille (MW): PV/Energie	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
669	Fortech	\N	info@fortech.be	\N	developer	premiere_connexion	BE	\N	\N	\N	Zone géographique: Belgique (Flandre)\nPortefeuille (MW): Eolien\nTechnologies: A scout\nNotes: Developpeur eolien - Sint-Gillis-Waas. Projets: Braemland, Duikeldam, Bredekop. Tel: +32 3 225 10 01	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"em_1ere_sent": true}
670	KT Projects	Kris Truyman	kris.truyman@telenet.be	\N	developer	premiere_connexion	BE	\N	\N	\N	Zone géographique: Belgique (Flandre)\nPortefeuille (MW): Eolien\nTechnologies: A scout\nNotes: KT Projects bvba. Petit developpeur eolien - Sint-Gillis-Waas (Holstraat 6D)	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"em_1ere_sent": true}
672	Vleemo	\N	informatie@vleemo.be	\N	developer	premiere_connexion	BE	\N	\N	\N	Zone géographique: Belgique (Flandre)\nPortefeuille (MW): Eolien\nTechnologies: A scout\nNotes: Vlaams windenergiebedrijf - Port d Anvers. Tel: 03 206 02 20. LinkedIn dispo	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"em_1ere_sent": true}
673	Wind aan Stroom	\N	info@windaandestroom.be	\N	developer	premiere_connexion	BE	\N	\N	\N	Zone géographique: Belgique (Flandre)\nPortefeuille (MW): Eolien\nTechnologies: A scout\nNotes: NV Wind aan de Stroom - Port d Anvers (rive gauche). Tel: +32 3 205 20 24. Antwerpen (Zaha Hadidplein 1). LinkedIn dispo	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"em_1ere_sent": true}
674	Parkwind (JERA Nex)	\N	info@parkwind.eu	\N	developer	premiere_connexion	BE	\N	\N	\N	Zone géographique: Belgique (Offshore)\nTechnologies: Eolien offshore\nStade projets: Operationnel\nNotes: Operateur 4 parcs: Belwind, Northwind, Nobelwind, Northwester 2. Filiale de JERA (Japon)	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"em_1ere_sent": true}
676	EDF Power Solutions (Belgique)	\N	info@edf.be	\N	developer	premiere_connexion	BE	\N	\N	\N	Zone géographique: Belgique\nTechnologies: Services ENR\nNotes: Filiale EDF pour services energetiques en Belgique. Waregem	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"em_1ere_sent": true}
856	Ether Energy	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
857	dbgreen	\N	\N	\N	developer	deuxieme_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
858	ecconova	\N	\N	\N	developer	deuxieme_connexion	BE	\N	\N	\N	27/05/2024	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
859	electravent	\N	\N	\N	developer	deuxieme_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
651	Enerdeal	\N	contact@enerdeal.com	\N	developer	premiere_connexion	BE	\N	\N	\N	Zone géographique: Belgique\nPortefeuille (MW): PV/Energie\nTechnologies: A scout	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"em_1ere_sent": true, "li_1ere_sent": true}
861	noveway	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
862	skysun	\N	\N	\N	developer	deuxieme_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
652	Ventis	\N	info@ventis.eu	\N	developer	premiere_connexion	BE	\N	\N	\N	Zone géographique: Belgique\nPortefeuille (MW): Eolien\nTechnologies: A scout	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"em_1ere_sent": true, "li_1ere_sent": true}
863	walvert	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
864	watts.green	\N	\N	\N	developer	deuxieme_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
866	Bee	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
867	biopower	\N	\N	\N	developer	to_contact	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"pas_interesse": true}
868	c-power	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
648	Elicio	Emmanuel Van Vyve	\N	\N	developer	deuxieme_connexion	BE	\N	\N	\N	Zone géographique: Belgique\nPortefeuille (MW): Eolien\nStade projets: Offshore/onshore BE	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
869	EQUINOR	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
870	otary	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
415	Champeil	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
872	Veb	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
873	scholt	\N	\N	\N	developer	deuxieme_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
874	Octaplus	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
675	Norther	\N	info@norther.be	\N	developer	deuxieme_connexion	BE	\N	\N	\N	Zone géographique: Belgique (Offshore)\nPortefeuille (MW): 370 MW\nTechnologies: Eolien offshore\nStade projets: Operationnel\nNotes: Parc eolien offshore 370 MW	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"em_1ere_sent": true, "li_1ere_sent": true}
32	Alternativa AM	\N	\N	\N	investor	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Infrastructures\nCritères: AM\nNotes: Nouveau	2026-06-15 11:28:24.855739	2026-06-18 19:17:25.837916	{"li_1ere_sent": true}
875	laborelec	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
876	Aster	\N	\N	\N	developer	deuxieme_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
877	Zonnewind CV	\N	\N	\N	developer	deuxieme_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
878	TES	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
879	Energy Solutions Group	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
38	Champs Solaires Nucériens	Charles De Poumayrac	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: AgriPV\nStade projets: Développeur agrivoltaïque\nNotes: Membre FFPA	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"li_1ere_sent": true}
880	SolarPower Europe	\N	\N	\N	developer	deuxieme_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
881	Global Wind Energy Council (GWEC)	\N	\N	\N	developer	deuxieme_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
41	Langa International	Julien CALMETTE | LinkedIn: linkedin.com/company/langa-international	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France/International\nTechnologies: AgriPV\nStade projets: Développeur\nNotes: Développeur agrivoltaïque	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"li_1ere_sent": true}
882	Eoly Energy	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
883	Korys	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
884	Edaphon	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
885	Smile Invest	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
886	XYLERGY	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
887	coretec	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
888	vmnservices	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
889	Sonck	\N	\N	\N	developer	deuxieme_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
664	B-Watt	Laurent Noirhomme	\N	\N	developer	deuxieme_connexion	BE	\N	\N	\N	Zone géographique: Belgique\nPortefeuille (MW): PV	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
892	Minguet	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
893	Vinçotte	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
896	Coopérative Émissions Zéro - Énergie citoyenne	\N	\N	\N	developer	deuxieme_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
897	Etherenergy	\N	\N	\N	developer	deuxieme_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
641	Ideta	\N	\N	\N	investor	deuxieme_connexion	BE	\N	\N	\N	Zone géographique: Agence dév.\nMandat (MW): À scout	2026-06-15 11:28:33.390881	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
653	Green Energy 4 Seasons	\N	info@greenenergy4seasons.be	\N	developer	deuxieme_connexion	BE	\N	\N	\N	Zone géographique: Belgique\nPortefeuille (MW): PV\nTechnologies: A scout	2026-06-15 11:28:34.95484	2026-06-18 20:23:06.010211	{"em_1ere_sent": true, "li_1ere_sent": true}
898	Sov invest	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
899	Watt matters	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
900	wesmart	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
901	socofe	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
902	Helios Group	\N	\N	\N	developer	deuxieme_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
903	Raysun	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
904	memoco.eu	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
905	green-invest	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
906	Rutten-NES	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
907	greencitywallonie	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
909	Axpo Benelux SA	\N	\N	\N	developer	deuxieme_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
890	Soltis				developer	to_contact	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 21:03:20.053606	{"history":[{"person":"","email":"","linkedin":"","date":"18/06/2026","outcome":"no_response","li_1ere_sent":true,"em_1ere_sent":false,"li_2eme_sent":false,"em_2eme_sent":false,"li_1ere":"Bonjour ,\\n\\nJe suis chez ENECHANGE (Japon, TSE:4169) — via EIR, on connecte les développeurs ENR avec des investisseurs en Europe.\\n30+ investisseurs | 700+ projets\\nFinancement, acquisition ou cession ? Je peux vous aider.\\nZein\\nzein.tlais@enechange.com","em_1ere":"","li_2eme":"","em_2eme":""}],"later":false,"li_1ere":"","em_1ere":"","li_2eme":"","em_2eme":"","li_1ere_sent":false,"em_1ere_sent":false,"li_2eme_sent":false,"em_2eme_sent":false}
43	IB Vogt	\N	chabane.yousfi@ibvogt.com	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: Europe\nTechnologies: PV\nStade projets: Développeur allemand\nNotes: Développeur PV international	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
910	Energa Brussels	\N	\N	\N	developer	premiere_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
45	Eurowind Energy	\N	info-fr@ewe.dk	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: Europe/France\nTechnologies: Éolien, PV\nStade projets: Développeur danois\nNotes: Actif en France	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
911	Eni SpA Belgian Branch	\N	\N	\N	developer	deuxieme_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
47	Eurasolis	Thomas Nouguès	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, AgriPV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"li_1ere_sent": true}
912	RWE Belgium	\N	\N	\N	developer	deuxieme_connexion	BE	\N	\N	\N	\N	2026-06-18 20:23:06.010211	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
638	Enovos	\N	\N	\N	investor	premiere_connexion	BE	\N	\N	\N	Zone géographique: Fournisseur/Invest\nMandat (MW): À scout\nTechnologies: Luxembourg	2026-06-15 11:28:33.390881	2026-06-18 20:23:06.010211	{"li_1ere_sent": true}
54	SSE Renewables	\N	delphine.henri@sse.com	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: Europe/France\nTechnologies: Éolien, PV\nStade projets: Majeur britannique\nNotes: Filiale ENR de SSE	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
57	Reden	\N	contact@reden.solar	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur\nNotes: Développeur PV	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
58	RP Global	\N	contactfrance@rp-global.com	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: Europe/France\nTechnologies: PV, Éolien\nStade projets: Développeur\nNotes: Actif en France	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
75	European Energy	\N	aqui@europeanenergy.dk	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: Europe/France\nTechnologies: PV, Éolien, AgriPV\nStade projets: Développeur danois\nNotes: Actif en France	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
93	Akuo Energy		sombsthay@akuoenergy.com	https://linkedin.com/company/akuo-energy	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France/International\nTechnologies: PV, Éolien, AgriPV\nStade projets: IPP indépendant\nNotes: Producteur indépendant français	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
97	BayWa r.e. France		info@baywa-re.fr	https://linkedin.com/company/baywa-re	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, Éolien\nStade projets: Développeur/investisseur\nNotes: Filiale du groupe BayWa	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
738	ENERPARC	05 40 24 86 48	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{}
90	Verso Energy	\N	contact@verso.energy	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, AgriPV, Stockage\nStade projets: Développeur\nNotes: Spécialisé développement projets	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
769	Hive Energy	Thomas Quillasi	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{}
829	SUNCO CAPITAL	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{}
845	VIRIDI	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{}
98	BKW Énergie France	\N	contact@hydronext.fr	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, Éolien\nStade projets: Développeur suisse	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
144	Neoen		contact@neoen.com	https://linkedin.com/company/neoen	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France/International\nTechnologies: PV, Éolien, Stockage\nStade projets: IPP majeur\nNotes: Indépendant français	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
684	Adamant Solar	Thomas Loeff	thomas.loeff@adamantsolar.com	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Andalucía, Castilla-La Mancha, Com. Valenciana\nTechnologies: Solaire PV\nStade projets: Développement\nNotes: Développeur full-stack solaire. Aussi EPC/installation.	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{"bounced": true}
129	Harmony Energy France	\N	info@harmonyenergy.fr	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, Stockage\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
130	Iberdrola Renovables France	\N	contact@iberdrola.fr	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, Éolien\nStade projets: Majeur espagnol	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
132	IDEX Solar	\N	solaire@idex.fr	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
913	AMDA ENERGIA	Isaura Farfan	ifarfan@amda.es	\N	developer	premiere_connexion	ES	\N	\N	\N	Zone géographique: Aragón\nTechnologies: Solaire PV, Éolien\nStade projets: Développement\nNotes: Développeur multi-technologies grande échelle. Siège Saragosse.	2026-06-18 20:49:59.65214	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
140	Manorga Solar	\N	contact@manorgasolar.com	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
141	Nadara France	\N	infofrance@nadara.com	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, Éolien\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
147	NTR PLC	\N	daniel.lopes@ntrplc.com	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: Europe\nTechnologies: PV, Éolien\nStade projets: Investisseur/fonds\nNotes: Fonds d'investissement ENR	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
685	Aer Soleir	Livinio Stuyck	livinio@aersoleir.com	\N	developer	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Développeurs)	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
686	AGROLLUM	Jose Draper Torras	josedraper@hotmail.com	\N	developer	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Développeurs)	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
151	PNE France	\N	contact@pne-france.fr	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, Éolien\nStade projets: Développeur allemand	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
154	Skyborn Renewables	\N	france@skybornrenewables.com	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Éolien en mer\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
158	Stern Energy	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
167	Urbasolar		leon.cedric@urbasolar.com	https://linkedin.com/company/urbasolar	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur/producteur\nNotes: Filiale de Bouygues	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
196	enerparc	05 40 24 86 48	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (April 25)	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"li_1ere_sent": true}
163	Tenergie	\N	contact@tenergie.fr	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, AgriPV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
164	Tryba Energy	\N	contact@tryba-energy.com	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
165	TTR Energy	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, AgriPV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
166	Tucoénergie	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
168	Vattenfall Éolien	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Éolien en mer\nStade projets: Majeur suédois	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
169	Véles Énergies	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, Éolien\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
170	Vendée Énergie	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France (Vendée)\nTechnologies: PV, Éolien\nStade projets: SEM locale	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
171	Vents du Nord	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France (Nord)\nTechnologies: Éolien\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
172	Verspieren	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Assurance ENR\nStade projets: Courtage	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
173	Volkswind France	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: Éolien\nStade projets: Développeur allemand	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
174	Volta	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
175	Voltec Solar	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV (fabricant)\nStade projets: Fabricant/développeur	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
176	VSB Énergies Nouvelles	\N	contact.fr@vsb.energy	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, Éolien\nStade projets: Développeur	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
177	Greenvolt Next France	Tatiana Pinho	tatiana.pinho@greenvolt.com	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, Stockage\nStade projets: IPP\nNotes: IPP Greenvolt	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
178	Energesia PV (ENSIO)	Jeanne Magnani	jeanne.magnani@ensio.eu	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Developpeur\nNotes: Dev agriPV	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
179	HIS Renouvelables	Marie Vicente	marie.vicente@his-renewables.com	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, Eolien\nStade projets: Developpeur\nNotes: Contact Energaia	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
180	Energie d'Ici	Christophe De Grave	christophe.degrave@energiedici.fr	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nPortefeuille (MW): ~50 MW\nTechnologies: PV, Eolien\nStade projets: Developpeur\nNotes: Cooperative ENR	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
181	Bohr Energie	Julien Chollet	julien.chollet@bohr-energie.fr	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Developpeur\nNotes: Contact Energaia	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
182	Promolead Energy	Amaury Paour	amaury@promolead.fr	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV\nStade projets: Developpeur\nNotes: Contact Energaia	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
185	RWE	Armand Cnockaert	armand.cnockaert@rwe.com	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France/Europe\nTechnologies: PV, Eolien, Stockage\nStade projets: IPP Majeur\nNotes: RWE France	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
186	Clearway	Jacques Danton	jacques.danton@theclearwaygroup.fr	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nTechnologies: PV, Eolien, Stockage\nStade projets: IPP US\nNotes: IPP US France	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"em_1ere_sent": true}
700	3E_Iberica	Joan Vinaixa	jvi@3e.eu	\N	developer	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Développeurs)	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
701	mylight150	A. Antuña	a.antuna@mylight150.com	\N	developer	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Développeurs)	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
215	Hive energy	Thomas Quillasi	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions\nNotes: ZT: Preliminary discussions (Fev 25)	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"li_1ere_sent": true}
914	European Energy	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-18 20:49:59.65214	2026-06-18 20:49:59.65214	{}
915	Grupo Cobra	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-18 20:49:59.65214	2026-06-18 20:49:59.65214	{}
916	ID Energy Group	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-18 20:49:59.65214	2026-06-18 20:49:59.65214	{}
917	Lightsource bp	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-18 20:49:59.65214	2026-06-18 20:49:59.65214	{}
918	Reden	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-18 20:49:59.65214	2026-06-18 20:49:59.65214	{}
919	X-ELIO	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	Zone géographique: Espagne\nTechnologies: Solaire PV\nStade projets: Nouveau - à qualifier	2026-06-18 20:49:59.65214	2026-06-18 20:49:59.65214	{}
679	Alantra Solar	Javier Mellado	javier.mellado@alantrasolar.com	\N	investor	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Investisseurs)	2026-06-15 11:28:36.705667	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
680	AIP Management	Anne Andersen	aan@aipmanagement.dk	\N	investor	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Investisseurs)	2026-06-15 11:28:36.705667	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
681	AFRY	Ana Castelao	ana.castelao@afry.com	\N	investor	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Investisseurs)	2026-06-15 11:28:36.705667	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
682	Alten Energías Renovables	María de Frutos	maria.defrutos@alten-energy.com	\N	investor	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Investisseurs)	2026-06-15 11:28:36.705667	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
683	5B BALEARES	Gonzalo Carreras Montes	info@5bbaleares.com	\N	developer	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Développeurs)	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
687	Aleph Capital	Pedro Targhetta	ptarghetta@alephcapital.es	\N	developer	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Développeurs)	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
688	Alter Enersun	Alter Enersun	info@alterenersun.com	\N	developer	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Développeurs)	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
689	ARESOL	Javier Zurbano Reinares	aresol@aresol.com	\N	developer	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Développeurs)	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
690	ALUMBRA	Cristina Antón	canton@grupoalumbra.es	\N	developer	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Développeurs)	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
691	ARBA ENERGY	AMALIA TAJES	info@arbaenergia.com	\N	developer	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Développeurs)	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
692	ARTENG	MEHMET AKIN	iberia@arteng.es	\N	developer	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Développeurs)	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
693	AUREA CAPITAL	Bárbara González	barbara.gonzalez@aureacapital.com	\N	developer	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Développeurs)	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
694	ABEI ENERGY & INFRAESTRUTURE	Patricio Alañon	info@abeienergy.com	\N	developer	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Développeurs)	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
695	CLEANSUN	Conrado	jc@cleansun.es	\N	developer	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Développeurs)	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
696	ALDESA	\N	info@aldesa.es	\N	developer	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Développeurs)	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
697	ANUDAL	\N	administracion@anudal.com	\N	developer	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Développeurs)	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{"bounced": true, "em_1ere_sent": true}
698	AGR-AM	L. Fernández	lafernandez@agr-am.com	\N	developer	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Développeurs)	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
699	Acofile	\N	comercial@acofile.com	\N	developer	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Développeurs)	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
702	ABOVE	Luca Piccini	luca.piccini@abovesurveying.com	\N	developer	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Développeurs)	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
703	AICOSEN	\N	administracio@aicosen.cat	\N	developer	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Développeurs)	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
704	1KOMMA5°	Candela Aznar	candela.aznar@1komma5.es	\N	developer	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Développeurs)	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
705	ACELERA ENERGÍA	\N	hola@aceleraenergia.com	\N	developer	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Développeurs)	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
706	URBISOLAR	\N	info@urbisolar.com	\N	developer	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Développeurs)	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
707	Alfa Global	\N	autoconsumo@alfaglobal.es	\N	developer	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Développeurs)	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
708	HONRUBIA SOLAR	\N	honrubiasolar@gmail.com	\N	developer	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Développeurs)	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
709	ABASTE	\N	informa@abaste.com	\N	developer	premiere_connexion	ES	\N	\N	\N	Ajouté depuis le scouting ES (Prospects Développeurs)	2026-06-15 11:28:38.212806	2026-06-18 20:49:59.65214	{"em_1ere_sent": true}
667	Enovos	Ikram Abouda	\N	https://www.linkedin.com/in/ACoAAB6zYHIBtRf6Br8h4Hgpz5M0NjvnvWxzp6s?skipRedirect=true	developer	deuxieme_connexion	BE	\N	\N	\N	Zone géographique: Luxembourg/BE\nPortefeuille (MW): Energie/Invest	2026-06-15 11:28:34.95484	2026-06-18 22:58:16.498156	{"li_1ere_sent":true,"li_1ere":"Bonjour Ikram,\\n\\nJe suis chez ENECHANGE (Japon, TSE:4169) — via EIR, on connecte les développeurs ENR avec des investisseurs en Europe.\\n30+ investisseurs | 700+ projets\\nFinancement, acquisition ou cession ? Je peux vous aider.\\nZein\\nzein.tlais@enechange.com","li_2eme":"Bonjour Ikram,\\n\\nMerci pour la connexion. Nos investisseurs recherchent :\\n• Co-développement par jalons\\n• Projets RTB à acquérir\\n• Partenariats SPV\\n\\nRéservez un créneau : https://calendar.app.google/Fe8Br6t4KzuWRxDE8\\n\\nBien à vous,\\nZein","em_2eme":"Objet : Présentation EIR\\n\\nBonjour Ikram,\\n\\nSuite à notre échange LinkedIn, voici notre plateforme.\\n\\nBien à vous,\\nZein Tlais\\nzein.tlais@enechange.com"}
920	Uniper	Nicolas Babikian			ipp	to_contact	FR	\N	\N	\N	Head of Business Development Wind & Solar France. Ami de Zein. Sera à Intersolar (23-25 juin, Stand A3.509). Présent avec Adrien Appere. Uniper actif en solaire, éolien, BESS en France.	2026-06-18 23:01:30.369217	2026-06-18 23:01:30.369217	{"intersolar_2025": true, "stand": "A3.509", "event": "Intersolar Europe", "date": "23-25 juin 2025"}
921	Adiwatt	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Développeur PV pur (build-to-sell). Stand Intersolar Europe A6.520. Cède projets aux fonds (Mirova, RGreen Invest).	2026-06-19 18:52:20.610611	2026-06-19 18:52:20.610611	{"source": "Intersolar Europe 2026", "event": "The smarter E Europe"}
922	Equans Solar & Storage	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	DEV/EPC Groupe Engie. Stand Intersolar Europe A3.310. Energy services, développement solaire & stockage.	2026-06-19 18:52:20.632618	2026-06-19 18:52:20.632618	{"source": "Intersolar Europe 2026", "event": "The smarter E Europe"}
923	OMEXOM (Intersolar)	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	EPC infrastructure électrique 36 pays. Stand EM-Power Europe C5.110. Transmission, distribution, stockage.	2026-06-19 18:52:20.641321	2026-06-19 18:52:20.641321	{"source": "Intersolar Europe 2026", "event": "The smarter E Europe"}
924	Kingspan Solar & Storage	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	DEV toitures solaires + stockage. Stand Intersolar Europe A5.570. Groupe international, présent en France.	2026-06-19 18:52:20.649925	2026-06-19 18:52:20.649925	{"source": "Intersolar Europe 2026", "event": "The smarter E Europe"}
925	RCE constructeur éolien	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	DEV + EPC + IPP éolien intégré. Stand Intersolar Europe A5.235. Se diversifie solaire/stockage.	2026-06-19 18:52:20.656852	2026-06-19 18:52:20.656852	{"source": "Intersolar Europe 2026", "event": "The smarter E Europe"}
926	Saft	\N	\N	\N	ipp	to_contact	FR	\N	\N	\N	BESS/IPP filiale TotalEnergies. Stand ees Europe B2.220. 100 ans expertise batteries avancées.	2026-06-19 18:52:20.666399	2026-06-19 18:52:20.666399	{"source": "Intersolar Europe 2026", "event": "The smarter E Europe"}
927	Tilt Energy	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	DEV/IPP BESS + VPP. Stand EM-Power Europe C4.470E. Plateforme IA prédiction flexibilité, connecté RTE/ENEDIS.	2026-06-19 18:52:20.671191	2026-06-19 18:52:20.671191	{"source": "Intersolar Europe 2026", "event": "The smarter E Europe"}
928	Elmya	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	DEV/EPC solaire utility-scale Espagne. Stand Intersolar Europe A3.311. Installations électriques & renouvelables.	2026-06-19 18:52:20.680628	2026-06-19 18:52:20.680628	{"source": "Intersolar Europe 2026", "event": "The smarter E Europe"}
929	Norvento	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	DEV éolien + PV. Stand Intersolar Europe B4.530. 100% renouvelable, développe haute technologie.	2026-06-19 18:52:20.685505	2026-06-19 18:52:20.685505	{"source": "Intersolar Europe 2026", "event": "The smarter E Europe"}
930	EOSOL Group	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	DEV énergie Pays Basque. Stand EM-Power Europe C5.240. Cluster énergie, développement renouvelable.	2026-06-19 18:52:20.69026	2026-06-19 18:52:20.69026	{"source": "Intersolar Europe 2026", "event": "The smarter E Europe"}
931	European Energy World	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	DEV/EPC/O&M utility-scale solaire. Stand Intersolar Europe A1.330. Fabricant modules + développeur.	2026-06-19 18:52:20.699617	2026-06-19 18:52:20.699617	{"source": "Intersolar Europe 2026", "event": "The smarter E Europe"}
932	Nextpower Capital	\N	\N	\N	investor	to_contact	ES	\N	\N	\N	INV/IPP fonds institutionnels. Stand Intersolar Europe A5.580. Acquiert projets solaires, construit et exploite.	2026-06-19 18:52:20.703949	2026-06-19 18:52:20.703949	{"source": "Intersolar Europe 2026", "event": "The smarter E Europe"}
933	Vector Renewables	\N	\N	\N	investor	to_contact	ES	\N	\N	\N	INV ADVISORY conseil investisseurs 20 ans. Stand EM-Power Europe B5.455. Due diligence, advisory fonds.	2026-06-19 18:52:20.71459	2026-06-19 18:52:20.71459	{"source": "Intersolar Europe 2026", "event": "The smarter E Europe"}
934	SD Verdia Abogados	\N	\N	\N	investor	to_contact	ES	\N	\N	\N	INV LEGAL cabinet avocats fonds/FO énergie Espagne. Stand Intersolar Europe A2.230. Project finance, M&A.	2026-06-19 18:52:20.724269	2026-06-19 18:52:20.724269	{"source": "Intersolar Europe 2026", "event": "The smarter E Europe"}
935	QUINTO ARMÓNICO	\N	\N	\N	developer	to_contact	ES	\N	\N	\N	INV/DEV engineering business models PV/BESS/Wind. Stand Intersolar Europe A2.230. Optimisation PPA, due diligence.	2026-06-19 18:52:20.730615	2026-06-19 18:52:20.730615	{"source": "Intersolar Europe 2026", "event": "The smarter E Europe"}
936	The Green Giant	Franck Camus	\N	\N	developer	to_contact	FR	\N	\N	\N	Senior Advisor and Developer ENR. Stand participant The smarter E Europe 2026 (Intersolar).	2026-06-19 22:00:30.889564	2026-06-19 22:00:30.889564	{"source": "Intersolar Europe 2026 (participant)", "event": "The smarter E Europe"}
937	INTHY	Paul Morot	\N	\N	developer	to_contact	FR	\N	\N	\N	DEV + IPP + INV. Produit énergie renouvelable, investit solaire/éolien/BESS. Stand participant The smarter E Europe 2026.	2026-06-19 22:00:30.909424	2026-06-19 22:00:30.909424	{"source": "Intersolar Europe 2026 (participant)", "event": "The smarter E Europe"}
405	Viridi	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"li_1ere_sent": true}
399	Groupe IDEC	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{}
478	ENERGIES DU SUD	christelle guery	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent\nNotes: ZT: Invitation sent (2025-10-01 0) - À recontacter autre personne	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{}
538	QENERGY	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{}
543	VOLTA DEVELOPPEMENT	\N	\N	\N	developer	to_contact	FR	\N	\N	\N	Zone géographique: France	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{}
576	Sunco Capital	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 19:17:25.837916	{"li_1ere_sent": true}
617	Silversun Technics	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
602	CVE Biogaz	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
603	Direct Energie	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
604	Nucleosir	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
605	Le Havre energie	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
607	Alter Énergies	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
608	Quénéa'ch	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
609	Groupe ACAMA	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
611	ENERGY POOL	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
613	MGH ENERGY	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
614	R-EV	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
615	Laketricity	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
616	NOYANT-BIO-ENERGIES	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
618	Cubico Sustainable Investments	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
619	Silosun	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
620	Altergie Développement	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
621	Eolmed	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
622	Sereema	\N	\N	\N	developer	deuxieme_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Preliminary discussions	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
623	Solenvi	\N	\N	\N	developer	premiere_connexion	FR	\N	\N	\N	Zone géographique: France\nStade projets: Invitation sent	2026-06-15 11:28:26.379499	2026-06-18 20:00:06.05045	{"li_1ere_sent": true}
\.


--
-- Data for Name: task_suggestions; Type: TABLE DATA; Schema: public; Owner: hermes
--

COPY public.task_suggestions (id, week_start, source, entity_id, ref, company, contact_name, status, nda_signed, criteria, next_action, notes, notes_preview, score, reason, task, ai_generated, last_update, created_at) FROM stdin;
4	2026-06-22	prospect	103	prospect:103	Inesys (Inersys)	Sylvain Corlay	nda_signed	Oui	\N	Relancé par email le 21/05/2026 — en attente de réponse.	Réunion introductive 02/05/2024 (visio). NDA signé 07/05/2024. Sylvain a mentionné période difficile juin 2024. Projets solaires.	Réunion introductive 02/05/2024 (visio). NDA signé 07/05/2024. Sylvain a mentionné période difficile juin 2024. Projets solaires.	13.5	Email relance mai 2026 sans réponse, relation en veille depuis 2024	Relancer Sylvain Corlay (Inesys) par téléphone suite à l'email sans réponse du 21/05	t	2026-06-18 21:56:31.169056	2026-06-22 14:59:31.854982
5	2026-06-22	prospect	99	prospect:99	Enervivo	Sylvain FREDERIC	nda_signed	Oui	\N	13/06 : Damien a envoyé pitch deck Maroc + info memo levée | EIR : check BDD Afrique (projets matching sol/toiture ~5-15 MW, 14-16%) + sourcing investisseurs (Maroc 1,6 M€ et levée 30-90 M€) | Réponse envoyée à Damien le 14/06	Full value chain (BE + constructeur + exploitant) | Focus PV sol, toiture, AgriPV, BESS — pas d'éolien | France : 2 MW exploit., 10 MW toiture, ~200 MW pipeline Arc Atlantique | Modèle DevCo/AssetCo en JV 50-50 avec partenaire finançant 80% | Levée 37 M€ France. Cherchent 30-50 M€ pour véhicule international (fin 2026/début 2027) | Co-fondateurs : Damien Léonard, Sylvain Frédéric, Vincent | Marchés : France, Maroc, Tunisie, Sénégal, CI, Cameroun\n\nCall 11/06 (Damien remplaçait Sylvain) :\n🔥 Axe 1 — Maroc (CT) : 3 projets packagés (Coca-Cola construit ✅ + textile + Mexique). 1,7 M€ equity. Urgence sept 2026. PPA signés.\n🏗 Axe 2 — Tunisie (MT) : 5 MW sol. Partenariat ASTEG. Tarif réglementé + garantie change 80%. Mise en service 2027. Rendement ~15%.\n💼 Axe 3 — Levée (LT) : 30-50 M€ pour véhicule DevCo/AssetCo international. Répliquer modèle France. Info memo prêt.\n\nEIR peut apporter : BDD Afrique (matching 5-15 MW, 14-16%), investisseurs Moyen-Orient, veille de projets early stage pour alimenter le pipe de la levée\n\nNotes: Fee agreement envoyé le 19/03. Relance le 11/05 et 17/05/2026. Email Afrique de l'Ouest envoyé le 17/05/2026.	Full value chain (BE + constructeur + exploitant) | Focus PV sol, toiture, AgriPV, BESS — pas d'éolien | France : 2 MW exploit., 10 MW toiture, ~200 M	13.5	Pitch deck envoyé le 13/06, urgence Maroc septembre 2026	Faire le point avec Damien (Enervivo) sur l'avancement du matching investisseurs Maroc	t	2026-06-18 21:56:31.167458	2026-06-22 14:59:31.854982
6	2026-06-22	prospect	97	prospect:97	Renergies	Alexandre Malot	nda_signed	Oui	\N	follow up on our questions\nthen send projects to investors	23 mar Follow-up meeting with Renergies - 2026/03/23 13:30 CET - Notes by Gemini\n\nRenergies – 6 mars 2026\nActivités :\nDéveloppement PV (France)\nM&A / transactions (Europe) – recherche de projets pour ~20 investisseurs.\nPortefeuille : ~100 MW en développement (12 projets)\n• 7 matures (~60 MW)\n• 5 précoces (~40 MW)\nLes projets sont actuellement financés par un fonds.\nProjets matures : études d’impact terminées, permis en cours (~10 MW/projet).\nCalendrier : premiers permis attendus fin 2026 / début 2027, autres en 2028.\nTypes de projets :\n•        Toitures ≥ 100 kW\n•        Toitures 500 kW – 1 MW (autoconsommation)\n•        Projets au sol 5 – 50 MW\nModèles : vente RTB ou partenariat de développement (financement du développement par jalons).\nInformations :\n•        Renergies analyse le réseau électrique avant de sécuriser un terrain afin de réduire le risque de refus de raccordement.\n•        Analyse : distance au poste source, capacité disponible, possibilité d’un poste source secondaire.\n•        Ratios utilisés : ~1 MW / hectare ; ~1 MW / km ; idéalement < 10 km du poste source.\n•        Possibilité d’échanges techniques en amont avec Enedis.\n•        Le marché solaire repose actuellement sur les appels d’offres, mais ce système pourrait évoluer dans 1–2 ans → développement probable du stockage batterie et de nouveaux modèles de marché.\nOptions de raccordement :\n•        Raccordement classique via Enedis\n•        Piquage sur ligne haute tension avec transformateur dédié\n•        Phasage du raccordement (ex : 10 MW puis 10 MW), avec risque financier.	23 mar Follow-up meeting with Renergies - 2026/03/23 13:30 CET - Notes by Gemini\n\nRenergies – 6 mars 2026\nActivités :\nDéveloppement PV (France)\nM&A / 	13.5	Questions envoyées, pas de réponse documentée, projets en attente d'envoi investisseurs	Relancer Alexandre Malot (Renergies) pour obtenir réponses aux questions en attente	t	2026-06-18 21:56:31.166453	2026-06-22 14:59:31.854982
7	2026-06-22	prospect	90	prospect:90	8p2	Richard Musi	nda_signed	Oui	\N	no projects now. send when we find relevant opportunities\nreconnection email is scheduled in late June 2026	Update on requirements: want BESS projects in France only, operating, at most 10 MW\n\n8p2 x EIR Introductory meeting - 2026/01/13 13:59 CET - Notes by Gemini	Update on requirements: want BESS projects in France only, operating, at most 10 MW\n\n8p2 x EIR Introductory meeting - 2026/01/13 13:59 CET - Notes by 	13.5	Email de reconnexion schedulé fin juin 2026, échéance imminente	Envoyer l'email de reconnexion à Richard Musi (8p2) avec projets BESS France ≤10 MW	t	2026-06-18 21:56:31.163363	2026-06-22 14:59:31.854982
8	2026-06-22	prospect	113	prospect:113	EcoLinks	Johnson	nda_signed	Oui	\N	À intégrer dans le suivi	NDA: Yes | Priorité: Medium\n\n⏭ Actions:\nÀ intégrer dans le suivi	NDA: Yes | Priorité: Medium\n\n⏭ Actions:\nÀ intégrer dans le suivi	10.5	Contact jamais suivi malgré NDA signé	Contacter Johnson (EcoLinks) pour qualifier les projets et intégrer au suivi	t	2026-06-18 21:56:31.177701	2026-06-22 14:59:31.854982
9	2026-06-22	prospect	111	prospect:111	AgriSolarPV	Clotilde Bouvat-Martin	nda_signed	Oui	\N	À intégrer dans le suivi	NDA: Yes | Priorité: Medium\n\n⏭ Actions:\nÀ intégrer dans le suivi	NDA: Yes | Priorité: Medium\n\n⏭ Actions:\nÀ intégrer dans le suivi	10.5	Contact jamais suivi malgré NDA signé	Contacter Clotilde Bouvat-Martin (AgriSolarPV) pour qualifier les projets	t	2026-06-18 21:56:31.176485	2026-06-22 14:59:31.854982
10	2026-06-22	prospect	110	prospect:110	SUNMIND SAS	Alexis Jagorel	nda_signed	Oui	\N	À intégrer dans le suivi	NDA: Yes | Priorité: Medium\n\n⏭ Actions:\nÀ intégrer dans le suivi	NDA: Yes | Priorité: Medium\n\n⏭ Actions:\nÀ intégrer dans le suivi	10.5	Contact jamais suivi malgré NDA signé	Contacter Alexis Jagorel (SUNMIND) pour qualifier les projets et intégrer au suivi	t	2026-06-18 21:56:31.175883	2026-06-22 14:59:31.854982
11	2026-06-22	prospect	108	prospect:108	ECO DELTA	Elodie Pellitteri	nda_signed	Oui	\N	À intégrer dans le suivi	NDA: Yes | Priorité: Medium\n\n⏭ Actions:\nÀ intégrer dans le suivi	NDA: Yes | Priorité: Medium\n\n⏭ Actions:\nÀ intégrer dans le suivi	10.5	Contact jamais suivi malgré NDA signé	Contacter Elodie Pellitteri (ECO DELTA) pour qualifier les projets et intégrer au suivi	t	2026-06-18 21:56:31.175166	2026-06-22 14:59:31.854982
12	2026-06-22	prospect	104	prospect:104	Terravastus Infrastructures	Dave Kerecha	nda_signed	Oui	\N	Docs analysés — à discuter en interne.	Projet gouvernemental Kenya. Terravastus = SPV. NDA signé fév 2025. 100MW Solar + 40MWh BESS. CAPEX $55.4M. PPA $0.08/kWh. Docs: https://drive.google.com/drive/folders/13HZSS0V7-WcCWZaewBnDTAegGB6TvFtH	Projet gouvernemental Kenya. Terravastus = SPV. NDA signé fév 2025. 100MW Solar + 40MWh BESS. CAPEX $55.4M. PPA $0.08/kWh. Docs: https://drive.google.	10.5	Docs analysés mais aucune décision ni retour au prospect	Organiser une réunion interne pour décider de la suite sur le projet Kenya Terravastus	t	2026-06-18 21:56:31.169502	2026-06-22 14:59:31.854982
13	2026-06-22	prospect	98	prospect:98	REUS (Margaret)	Margaret Nganga	nda_signed	Oui	\N	follow up	POC: Zein Tlais | NDA: Yes\n👤 Margaret Nganga\n\n⏭ Actions:\nfollow up	POC: Zein Tlais | NDA: Yes\n👤 Margaret Nganga\n\n⏭ Actions:\nfollow up	10.5	Follow-up prévu mais aucune action concrète documentée	Relancer Margaret Nganga (REUS) via Zein pour qualifier les projets disponibles	t	2026-06-18 21:56:31.167043	2026-06-22 14:59:31.854982
14	2026-06-22	prospect	76	prospect:76	Aden FR	Eric DECOUX	nda_signed	Oui	\N	follow up with enrocks	Highly important notes on development risk: Aden et ENECHANGE - 2026/02/23 09:55 EET - Notes by Gemini\n\n\n\nMariella and (Eric DECOUX) - 2026/02/04 10:58 EET - Notes by Gemini	Highly important notes on development risk: Aden et ENECHANGE - 2026/02/23 09:55 EET - Notes by Gemini\n\n\n\nMariella and (Eric DECOUX) - 2026/02/04 10:5	10.5	Action follow-up Enrocks mentionnée mais non documentée	Faire le point avec Eric Decoux (Aden FR) sur l'avancement avec Enrocks	t	2026-06-18 21:56:31.158995	2026-06-22 14:59:31.854982
15	2026-06-22	prospect	39	prospect:39	Menapy	Robbert Van Boxelaere	nda_signed	Oui	\N	Q4 2026 reconnect Zein Tlais, email scheduled	fully restructuring their firm with new investors and new strategy...\nactivities in France, Italy, Belgium, Spain\nAdriano to reconnect with the Italian guy	fully restructuring their firm with new investors and new strategy...\nactivities in France, Italy, Belgium, Spain\nAdriano to reconnect with the Italia	8.5	Email planifié Q4 2026 mais anticipation utile	Préparer et envoyer l'email de reconnexion à Robbert Van Boxelaere (Menapy)	t	2026-06-18 21:56:31.175294	2026-06-22 14:59:31.854982
16	2026-06-22	prospect	67	prospect:67	Photosol	Ugo DE HALDAT DU LYS (Analyste M&A)	nda_signed	Oui	\N	follow up on italian pipeline	Photosol - December 22 2025\nonly buying RTB projects, but can consider others that are very close to RTB (Poland and Italy)\n15+ MW\nPV or PV+BESS\nalready acquired 100+ MW in Italy, they have a local team\ninterested in Fer-X eligible projects\nWant to invest in 50 MWp per year (2-3 projects)\nNot active in agriPV yet, may consider it\nNot interested in standalone BESS, but may consider it with MACSE developments\nPrefer projects in the Center-North / North Italy. Not interested in Sicily and Sardinia\nNext: update testers in Italy and Poland\nthen he will discuss internally and confirm Photosol's interest\n\nNotes: Suivi actif par Mariella jusqu'au 12/05/2026 — vérifier avec Mariella avant intervention	Photosol - December 22 2025\nonly buying RTB projects, but can consider others that are very close to RTB (Poland and Italy)\n15+ MW\nPV or PV+BESS\nalrea	8.5	NDA signe + action en attente · Statut: nda signed	\N	f	2026-06-18 21:56:31.155804	2026-06-22 14:59:31.854982
17	2026-06-22	prospect	30	prospect:30	Wiapro Solar	Wiapro Solar	nda_signed	Oui	\N	follow up with Abdelilah about his partner for Enrocks	POC: Mariella Mansour | NDA: Yes | Priorité: Low\n\n⏭ Actions:\nfollow up with Abdelilah about his partner for Enrocks	POC: Mariella Mansour | NDA: Yes | Priorité: Low\n\n⏭ Actions:\nfollow up with Abdelilah about his partner for Enrocks	8.5	NDA signe + action en attente · Statut: nda signed	\N	f	2026-06-18 21:56:31.14004	2026-06-22 14:59:31.854982
18	2026-06-22	prospect	21	prospect:21	Calycé	Paul-Antoine Grasset	nda_signed	Oui	\N	follow up	Dec 23 2025\n\nAgriPV developer, bureaux Reims & Toulouse, 30 employés.\nSell at RTB\n~100 MW under review (en instruction)\nTheir first permits early 2026\nTheir first RTB project in H2 2026.\n8-30 MW per project, mix élevage et grandes cultures.\nmay want to hybridize their projects (to be confirmed)\nno projects to sell at this stage (RTB)\nnot looking for milestone payments either	Dec 23 2025\n\nAgriPV developer, bureaux Reims & Toulouse, 30 employés.\nSell at RTB\n~100 MW under review (en instruction)\nTheir first permits early 2026	8.5	NDA signe + action en attente · Statut: nda signed	\N	f	2026-06-18 21:56:31.138691	2026-06-22 14:59:31.854982
19	2026-06-22	prospect	17	prospect:17	Enertrag	Antoine Pouille (Project Finance M&A)	nda_signed	Oui	\N	Relancé x2 19/05 — pas de réponse	Allemand éolien. France ~100MW (3 RTB), Allemagne ~300MW. Storage 50/50. Meeting 21/01.	Allemand éolien. France ~100MW (3 RTB), Allemagne ~300MW. Storage 50/50. Meeting 21/01.	8.5	NDA signe + action en attente · Statut: nda signed	\N	f	2026-06-18 21:56:31.137496	2026-06-22 14:59:31.854982
20	2026-06-22	prospect	11	prospect:11	TCO Solar EnR	Patrick F.A. Wurster & Thomas Casalta	nda_signed	Oui	\N	follow up	POC: Mariella Mansour | NDA: Yes | Priorité: Low\n👤 Patrick F.A. Wurster & Thomas Casalta\n\n📋 Résumé:\nPatrick to send presentation on French projects. Priority Italy.\n\n⏭ Actions:\nfollow up	POC: Mariella Mansour | NDA: Yes | Priorité: Low\n👤 Patrick F.A. Wurster & Thomas Casalta\n\n📋 Résumé:\nPatrick to send presentation on French projects. P	8.5	NDA signe + action en attente · Statut: nda signed	\N	f	2026-06-18 21:56:31.134486	2026-06-22 14:59:31.854982
21	2026-06-22	investor	19	investor:19	CATL / BESS Broadway	Antonio Sanchez	in_discussion	\N	\N	📩 Mariella envoie briefs Pologne + Finlande\n📄 Envoyer NDA EIR\n📎 Vérifier structure revenus capacity markets	## Compte-rendu réunion - CATL / BESS Broadway\nDate: 1 avril 2026 | Participants: Mariella Mansour (Enechange), Antonio Sanchez (CATL / BESS Broadway)\nContact: Antonio Sanchez — Head of Business Development & Investment Strategy (Europe)\n\n### Structure CATL / BESS Broadway\n- CATL = fabricant chinois de batteries (n°1 mondial) (BESS)\n- BESS Broadway = SPV dédié de CATL, en Joint Venture avec Lockpipe (investment group)\n- Lockpipe a engagé 200M$ dans la JV\n- Modèle : acquérir/développer projets → packager avec batteries CATL (prix compétitif fabricant) → vendre le package clé en main à Lockpipe\n\n### Cibles recherchées\n- Standalone BESS (priorité)\n- Projets PV+BESS collocated (envisageable, surtout pour charger batteries à coût zéro)\n- Pas de pur solaire seul\n- Stade min : grid connection sécurisée (open à early stage et co-développement)\n- RTB aussi possible si prix raisonnable\n\n### Marchés\n- Europe prioritaire : Espagne, Allemagne, Italie, Pologne, France, Roumanie, Suisse\n- International : Chili, Mexique, Australie, Japon (20 GW en vue au Japon)\n- Budget 2026 : 200M$ à déployer\n\n### Fee agreement\n- Antonio ouvert à reconnaître le rôle d'intermédiaire\n- Prêt à dire en meeting direct : structure fee avec Mariella/EIR\n- Pour lui, pas de problème à déclarer le mandat\n\n### Prochains steps\n- Mariella envoie briefs sur projet BESS Pologne (460 MW / 1 200 MWh, grid offer reçue, RTB Q2 2027)\n- Mariella envoie brief projet Finlande (à vérifier statut grid)\n- Vérifier structure revenus capacity markets / AS pour marchés nordiques\n- Envoyer NDA EIR\n- Continuer à envoyer portfolios	## Compte-rendu réunion - CATL / BESS Broadway\nDate: 1 avril 2026 | Participants: Mariella Mansour (Enechange), Antonio Sanchez (CATL / BESS Broadway)	10.5	Actions identifiées lors réunion avril 2026, toujours non réalisées	Envoyer à Antonio Sanchez (CATL/BESS Broadway) les briefs Pologne + Finlande et le NDA EIR	t	2026-06-18 14:38:38.082131	2026-06-22 14:59:31.854982
22	2026-06-22	investor	8	investor:8	Electron Green	Electron Green	active	\N	Dès early-stage jusqu'a operationnel	\N	Zone: France\nTechnologies: Toitures et ombrières C&I\nCritères: Dès early-stage jusqu'a operationnel	Zone: France\nTechnologies: Toitures et ombrières C&I\nCritères: Dès early-stage jusqu'a operationnel	7.5	Laurent a déjà contacté Electron Green, synergie directe à exploiter	Envoyer à Electron Green les projets toitures C&I de Laurent Cligny correspondant à leurs critères	t	2026-06-18 14:32:13.058966	2026-06-22 14:59:31.854982
23	2026-06-22	investor	5	investor:5	Enrocks	Enrocks	active	\N	Total 100 MW en 2026, co-développement préféré	\N	Zone: Europe\nTechnologies: PV\nCritères: Total 100 MW en 2026, co-développement préféré\nRemarques: RTB possible mais pas après RTB	Zone: Europe\nTechnologies: PV\nCritères: Total 100 MW en 2026, co-développement préféré\nRemarques: RTB possible mais pas après RTB	7.5	Objectif 100 MW en 2026, délai serré, aucun envoi documenté récent	Envoyer à Enrocks une sélection de projets PV co-développement pour atteindre objectif 100 MW 2026	t	2026-06-15 11:28:22.542893	2026-06-22 14:59:31.854982
24	2026-06-22	investor	3	investor:3	Phoenix Energy	Phoenix Energy	active	\N	Préférence Proche RTB (moins mature pourquoi pas) >5 MW, TIR ≥8%, plus proche RTB	\N	Zone: Actif en Italie\nTechnologies: PV Hybrides\nCritères: Préférence Proche RTB (moins mature pourquoi pas) >5 MW, TIR ≥8%, plus proche RTB\nRemarques: Il faut l'EPC lui-meme\nIl prefère des projets RTB pour les Construire\nFiliale du groupe Indevco	Zone: Actif en Italie\nTechnologies: PV Hybrides\nCritères: Préférence Proche RTB (moins mature pourquoi pas) >5 MW, TIR ≥8%, plus proche RTB\nRemarques:	4.5	Critères précis connus, aucun projet envoyé documenté	Envoyer à Phoenix Energy un teaser sur les projets PV hybrides Italy RTB >5 MW disponibles	t	2026-06-15 11:28:22.542893	2026-06-22 14:59:31.854982
25	2026-06-22	investor	6	investor:6	Philadelphia Solar	Philadelphia Solar	active	\N	Préfère near-RTB, projets ≥10 MWp	\N	Zone: Europe\nTechnologies: PV\nCritères: Préfère near-RTB, projets ≥10 MWp\nRemarques: Investit a travers ses modules + equity si nécessaire	Zone: Europe\nTechnologies: PV\nCritères: Préfère near-RTB, projets ≥10 MWp\nRemarques: Investit a travers ses modules + equity si nécessaire	4.5	Critères précis définis, aucun envoi de projet documenté	Envoyer à Philadelphia Solar un teaser sur les projets PV near-RTB ≥10 MWp disponibles	t	2026-06-15 11:28:22.542893	2026-06-22 14:59:31.854982
26	2026-06-22	investor	7	investor:7	Photosol (29/10/2025)	Ugo DE HALDAT DU LYS	active	\N	Préférence RTB\nItalie : 20–30 MW, Pologne : 50 MW+	\N	Zone: Italie, Pologne, UK, France\nTechnologies: PV, stockage\nCritères: Préférence RTB\nItalie : 20–30 MW, Pologne : 50 MW+\nRemarques: Préfère garder et exploiter les projets eux-mêmes; UK : intérêt non déterminé	Zone: Italie, Pologne, UK, France\nTechnologies: PV, stockage\nCritères: Préférence RTB\nItalie : 20–30 MW, Pologne : 50 MW+\nRemarques: Préfère garder et	4.5	Critères géographiques précis, aucune action documentée récente	Envoyer à Photosol (Ugo de Haldat) les projets PV RTB Italie 20-30 MW et Pologne 50 MW+	t	2026-06-15 11:28:22.542893	2026-06-22 14:59:31.854982
27	2026-06-22	investor	4	investor:4	Faradae	Philippe DURAND	active	\N	Capacité <2 MW, co-développement ou near-RTB\nPour profiter du dispositif d’EDF Obligation d’Achat (EDF OA)	\N	Zone: Europe\nTechnologies: PV, tout stade\nCritères: Capacité <2 MW, co-développement ou near-RTB\nPour profiter du dispositif d’EDF Obligation d’Achat (EDF OA)\nRemarques: Basé en France	Zone: Europe\nTechnologies: PV, tout stade\nCritères: Capacité <2 MW, co-développement ou near-RTB\nPour profiter du dispositif d’EDF Obligation d’Achat 	4.5	Critères précis connus, projets Stéphane Gilli <2 MW potentiellement matchants	Envoyer à Faradae (Philippe Durand) les projets PV <2 MW éligibles EDF OA disponibles	t	2026-06-15 11:28:22.542893	2026-06-22 14:59:31.854982
28	2026-06-22	investor	10	investor:10	Prosolia	Prosolia	active	\N	Dès early-stage jusqu'a operationnel	\N	Zone: France\nTechnologies: Eolien onshore (flexible in terms of capacity), prefer RTB, \nstockage standalone (<10MW), et PV+stockage (C&I)\nCritères: Dès early-stage jusqu'a operationnel	Zone: France\nTechnologies: Eolien onshore (flexible in terms of capacity), prefer RTB, \nstockage standalone (<10MW), et PV+stockage (C&I)\nCritères: Dè	4.5	Critères larges et bien définis, aucun envoi documenté	Envoyer à Prosolia les projets éolien onshore RTB et BESS standalone <10 MW disponibles	t	2026-06-15 11:28:22.542893	2026-06-22 14:59:31.854982
29	2026-06-22	investor	12	investor:12	Tozzi Green (?)	Tozzi Green	active	\N	\N	\N	\nTechnologies: 50 +- MW onshore wind, RTB, EPC selection on Tozzi	\nTechnologies: 50 +- MW onshore wind, RTB, EPC selection on Tozzi	4.5	Contact actif mais critères incomplets et aucun projet envoyé	Relancer Tozzi Green pour confirmer critères et envoyer projets éolien onshore ~50 MW RTB	t	2026-06-15 11:28:22.542893	2026-06-22 14:59:31.854982
30	2026-06-22	investor	13	investor:13	WSKW (intermediary)	WSKW	active	\N	\N	\N	\nTechnologies: Intermediary: their investor wants to acquire BESS projects, the first acquisition per developer has to be RTB, the rest can be at an earlier stage	\nTechnologies: Intermediary: their investor wants to acquire BESS projects, the first acquisition per developer has to be RTB, the rest can be at an e	4.5	Premier ticket doit être RTB, aucun projet soumis documenté	Relancer WSKW pour identifier les projets BESS RTB à soumettre en priorité à leur investisseur	t	2026-06-15 11:28:22.542893	2026-06-22 14:59:31.854982
31	2026-06-22	investor	18	investor:18	Regenerasun (David Lebret)	David Lebret	active	\N	Projets PV toiture proches RTB	\N	Zone: France\nTechnologies: PV Toitures industrielles RTB\nCritères: Projets PV toiture proches RTB\nRemarques: Présenté par Yann Barberis (ENR Courtage). Réunion faite avec Mariella. Intérêt pour portefeuille toitures industrielles PV RTB.	Zone: France\nTechnologies: PV Toitures industrielles RTB\nCritères: Projets PV toiture proches RTB\nRemarques: Présenté par Yann Barberis (ENR Courtage)	4.5	Intérêt confirmé en réunion, aucun envoi de dossier documenté	Envoyer à Regenerasun (David Lebret) un portefeuille de toitures industrielles PV proches RTB	t	2026-06-15 11:28:22.542893	2026-06-22 14:59:31.854982
32	2026-06-22	investor	17	investor:17	Avergies	Nicolas Gente	active	\N	fully RTB only (PTF finalisee)	\N	Zone: France\nPV pref. sud-est\nEolien et BESS: partout en FR\nTechnologies: PV, BESS, wind\nCritères: fully RTB only (PTF finalisee)	Zone: France\nPV pref. sud-est\nEolien et BESS: partout en FR\nTechnologies: PV, BESS, wind\nCritères: fully RTB only (PTF finalisee)	4.5	Critères stricts RTB uniquement, aucun projet envoyé documenté	Envoyer à Avergies (Nicolas Gente) les projets PV/BESS/éolien France fully RTB disponibles	t	2026-06-15 11:28:22.542893	2026-06-22 14:59:31.854982
33	2026-06-22	investor	15	investor:15	Chint Solar	Fathia Taghozi	active	\N	~15 MW per project or larger, near-RTB / RTB	\N	Zone: France\nTechnologies: PV, PV+BESS\nCritères: ~15 MW per project or larger, near-RTB / RTB	Zone: France\nTechnologies: PV, PV+BESS\nCritères: ~15 MW per project or larger, near-RTB / RTB	4.5	Critères précis définis, aucun envoi de projet documenté	Envoyer à Chint Solar (Fathia Taghozi) les projets PV near-RTB ≥15 MW France disponibles	t	2026-06-15 11:28:22.542893	2026-06-22 14:59:31.854982
34	2026-06-22	investor	16	investor:16	Enervivo	Sylvain FREDERIC	active	\N	250 kW+, near-RTB / RTB, mais peut considerer d'autres opportunites	\N	Zone: France\nTechnologies: Agri PV (sol ou toitures)\nCritères: 250 kW+, near-RTB / RTB, mais peut considerer d'autres opportunites	Zone: France\nTechnologies: Agri PV (sol ou toitures)\nCritères: 250 kW+, near-RTB / RTB, mais peut considerer d'autres opportunites	4.5	Critères précis, lien potentiel avec prospect Enervivo à exploiter	Envoyer à Enervivo investisseur les projets AgriPV ≥250 kW near-RTB France disponibles	t	2026-06-15 11:28:22.542893	2026-06-22 14:59:31.854982
35	2026-06-22	investor	11	investor:11	CATL	CATL	in_discussion	\N	\N	\N	\N		3	Doublon probable avec CATL/BESS Broadway, aucune note ni action	Vérifier si ce doublon CATL doit être fusionné avec investor:19 et archiver si nécessaire	t	2026-06-18 14:35:29.018206	2026-06-22 14:59:31.854982
\.


--
-- Data for Name: templates; Type: TABLE DATA; Schema: public; Owner: hermes
--

COPY public.templates (id, name, type, target, subject, body, language, notes, created_at, updated_at, step) FROM stdin;
29	LinkedIn 1ère connexion (EN)	linkedin	developer	\N	Hello [Prénom],\n\nI'm with ENECHANGE (Japan, TSE:4169) — via EIR, we connect RE developers with investors across EU.\n30+ investors | 700+ projects\nFinancing, acquisition, or sale? Happy to connect you.\nZein\nzein.tlais@enechange.com	en	\N	2026-06-15 18:14:20.2206	2026-06-15 18:14:20.2206	1
30	LinkedIn 1ère connexion (FR)	linkedin	developer	\N	Bonjour [Prénom],\n\nJe suis chez ENECHANGE (Japon, TSE:4169) — via EIR, on connecte les développeurs ENR avec des investisseurs en Europe.\n30+ investisseurs | 700+ projets\nFinancement, acquisition ou cession ? Je peux vous aider.\nZein\nzein.tlais@enechange.com	fr	\N	2026-06-15 18:14:20.2206	2026-06-15 18:14:20.2206	1
31	LinkedIn 2ème connexion (FR)	linkedin	developer	\N	Bonjour [Prénom],\n\nMerci pour la connexion. Je reviens vers vous car nos investisseurs sont activement à la recherche de :\n• Co-développement — paiement par jalons (signature, permis, RTB, COD)\n• Projets en RTB ou prêts-à-construire à acquérir directement\n• Partenariats sur projets en développement (solaire, éolien, BESS)\n• Prise de participation au capital de vos SPV\n\nSi vous voulez en savoir plus sur notre plateforme EIR et comment on connecte les développeurs avec 30+ investisseurs, je vous envoie une présentation par mail.\n\nEt si ça vous intéresse, vous pouvez directement réserver un créneau qui vous convient ici : https://calendar.app.google/Fe8Br6t4KzuWRxDE8\n\nBien à vous,\nZein	fr	\N	2026-06-15 18:14:20.2206	2026-06-15 18:14:20.2206	2
32	LinkedIn 2ème connexion (EN)	linkedin	developer	\N	Hello [Prénom],\n\nThanks for connecting. Our investors are actively looking for:\n• Co-development — milestone-based payments (signature, permits, RTB, COD)\n• RTB / ready-to-build projects for direct acquisition\n• Partnerships on development-stage projects (solar, wind, BESS)\n• Equity participation in your SPVs\n\nWant to know more about our EIR platform and how we connect developers with 30+ investors? I can send you a presentation.\n\nIf interested, feel free to book a slot directly: https://calendar.app.google/Fe8Br6t4KzuWRxDE8\n\nBest,\nZein	en	\N	2026-06-15 18:14:20.2206	2026-06-15 18:14:20.2206	2
33	LinkedIn 1ère connexion (EN)	linkedin	investor	\N	Hello [Prénom],\nI'm with ENECHANGE (Japan, TSE:4169) - via EIR, we source bankable RE projects across EU for investors.\n700+ projects screened | 30+ investors connected\nLooking for investment opportunities in solar, wind, or BESS — Happy to share our latest pipeline.\nBest,\nzein.tlais@enechange.com	en	\N	2026-06-15 18:14:20.2206	2026-06-15 18:14:20.2206	1
34	LinkedIn 2ème connexion (FR)	linkedin	investor	\N	Bonjour [Prénom],\n\nMerci pour la connexion. Via EIR, on connecte les investisseurs avec des opportunités en Europe :\n• Co-investissement aux côtés d'autres fonds sur des projets solaire, éolien, BESS\n• Partenariats en co-développement avec des développeurs (paiement par jalons)\n• Acquisition de projets RTB ou d'actifs en opération\n\nJe vous envoie une présentation de notre plateforme et de notre pipeline.\nSi ça vous intéresse, réservez un créneau directement : https://calendar.app.google/Fe8Br6t4KzuWRxDE8\n\nBien à vous,\nZein	fr	\N	2026-06-15 18:14:20.2206	2026-06-15 18:14:20.2206	2
35	LinkedIn 2ème connexion (EN)	linkedin	investor	\N	Hello [Prénom],\n\nThanks for connecting. Through EIR, we connect investors with opportunities across EU:\n• Co-investment alongside other funds on solar, wind, BESS projects\n• Co-development partnerships with developers (milestone-based)\n• Acquisition of RTB projects or operating assets\n\nI can send you a presentation of our platform and pipeline.\nIf interested, feel free to book a slot directly: https://calendar.app.google/Fe8Br6t4KzuWRxDE8\n\nBest,\nZein	en	\N	2026-06-15 18:14:20.2206	2026-06-15 18:14:20.2206	2
36	LinkedIn 1ère connexion (EN)	linkedin	ipp	\N	Hello [Prénom],\n\nI'm with ENECHANGE (Japan, TSE:4169) — via EIR, we connect IPPs with investors across EU.\n30+ investors | 700+ projects\nFinancing, acquisition, or portfolio sale? Happy to connect you.\n\nZein\nzein.tlais@enechange.com	en	\N	2026-06-15 18:14:20.2206	2026-06-15 18:14:20.2206	1
37	LinkedIn 1ère connexion (FR)	linkedin	ipp	\N	Bonjour [Prénom],\n\nJe suis chez ENECHANGE (Japon, TSE:4169) — via EIR, on connecte les IPP avec des investisseurs en Europe.\n30+ investisseurs | 700+ projets\nFinancement, acquisition ou cession de portefeuille ? Je peux vous aider.\n\nZein\nzein.tlais@enechange.com	fr	\N	2026-06-15 18:14:20.2206	2026-06-15 18:14:20.2206	1
38	LinkedIn 2ème connexion (FR)	linkedin	ipp	\N	Bonjour [Prénom],\n\nMerci pour la connexion. Via EIR, on connecte les IPP avec des investisseurs en Europe pour :\n• Financer vos projets en développement — co-développement par jalons\n• Acquérir vos projets RTB ou vos actifs en opération\n• Vous proposer des opportunités de cession de portefeuille\n\nJe vous envoie une présentation de notre plateforme.\nSi ça vous intéresse, réservez un créneau : https://calendar.app.google/Fe8Br6t4KzuWRxDE8\n\nBien à vous,\nZein	fr	\N	2026-06-15 18:14:20.2206	2026-06-15 18:14:20.2206	2
39	LinkedIn 1ère connexion (EN)	linkedin	family_office	\N	Hello [Prénom],\n\nI'm with ENECHANGE (Japan, TSE:4169) — via EIR, we connect investment funds with RE developers across EU.\n30+ investors | 700+ projects\nLooking for off-market deals or co-investment opportunities? Happy to connect you.\n\nZein\nzein.tlais@enechange.com	en	\N	2026-06-15 18:14:20.2206	2026-06-15 18:14:20.2206	1
40	LinkedIn 1ère connexion (FR)	linkedin	family_office	\N	Bonjour [Prénom],\n\nJe suis chez ENECHANGE (Japon, TSE:4169) — via EIR, on connecte les fonds d'investissement avec des développeurs ENR en Europe.\n30+ investisseurs | 700+ projets\nVous cherchez des deals off-market ou des opportunités de co-investissement ? Je peux vous aider.\n\nZein\nzein.tlais@enechange.com	fr	\N	2026-06-15 18:14:20.2206	2026-06-15 18:14:20.2206	1
41	LinkedIn 2ème connexion (FR)	linkedin	family_office	\N	Bonjour [Prénom],\n\nMerci pour la connexion. Via EIR, on connecte les fonds avec des opportunités en Europe :\n• Co-investir aux côtés d'autres fonds sur des projets solaire, éolien, BESS\n• Acquérir des projets RTB ou des actifs en opération\n• Participer au co-développement de projets (paiement par jalons)\n• Accéder à des deals off-market exclusifs\n\nJe vous envoie une présentation de notre plateforme.\nSi ça vous intéresse, réservez un créneau : https://calendar.app.google/Fe8Br6t4KzuWRxDE8\n\nBien à vous,\nZein	fr	\N	2026-06-15 18:14:20.2206	2026-06-15 18:14:20.2206	2
42	LinkedIn 1ère connexion (FR)	linkedin	investor	\N	Bonjour [Prénom],\nJe suis chez ENECHANGE (Japon, TSE:4169) — via EIR, on source des projets ENR bankables en Europe pour les investisseurs.\n700+ projets analysés | 30+ investisseurs connectés\nVous cherchez des opportunités d'investissement en solaire, éolien ou BESS ? Je vous partage notre pipeline.\nBest,\nzein.tlais@enechange.com	fr	\N	2026-06-15 18:14:20.2206	2026-06-15 18:14:20.2206	1
43	LinkedIn 2ème connexion (EN)	linkedin	ipp	\N	Hello [Prénom],\n\nThanks for connecting. Through EIR, we connect IPPs with investors across EU for :\n• Financing your development projects — co-development milestone-based\n• Acquiring your RTB projects or operating assets\n• Portfolio sale opportunities\n\nI can send you a presentation of our platform.\nIf interested, feel free to book a slot: https://calendar.app.google/Fe8Br6t4KzuWRxDE8\n\nBest,\nZein	en	\N	2026-06-15 18:14:20.2206	2026-06-15 18:14:20.2206	2
44	LinkedIn 2ème connexion (EN)	linkedin	family_office	\N	Hello [Prénom],\n\nThanks for connecting. Through EIR, we connect funds with opportunities across EU:\n• Co-invest alongside other funds on solar, wind, BESS projects\n• Acquire RTB projects or operating assets\n• Participate in co-development of projects (milestone-based)\n• Access off-market exclusive deals\n\nI can send you a presentation of our platform.\nIf interested, feel free to book a slot: https://calendar.app.google/Fe8Br6t4KzuWRxDE8\n\nBest,\nZein	en	\N	2026-06-15 18:14:20.2206	2026-06-15 18:14:20.2206	2
45	Email prospection (FR)	email	developer	EIR — mise en relation ENR	Bonjour [Prénom],\n\nJe suis Business Development Consultant chez ENECHANGE (Japon, TSE: 4169), et je travaille sur EIR, notre plateforme de mise en relation entre développeurs et investisseurs ENR.\n\nNous travaillons avec plus de 30 investisseurs actifs et une base de 500 projets sourcés en France et en Europe, sur toutes typologies (PV, agriPV, stockage, éolien), de 200 kW à 30 MW.\n\nNous accompagnons :\n- Développeurs → accès direct à des investisseurs pour co-développement, acquisition ou cession\n- Investisseurs → projets qualifiés à tous les stades (early-stage à RTB)\n\nSi vous avez des projets à financer ou des opportunités d'acquisition, je serais ravi d'échanger.\n\nBien cordialement,\n\nZein Tlais\nBusiness Development Consultant — ENECHANGE\nSchedule a meeting: https://calendar.app.google/Fe8Br6t4KzuWRxDE8\nLinkedIn: https://www.linkedin.com/in/zein-tlais-a91363172/\nMobile: 06 66 66 78 00	fr	\N	2026-06-15 18:14:20.2206	2026-06-15 18:14:20.2206	1
46	Email prospection (EN)	email	developer	EIR — Connecting RE Developers & Investors	Hello [Prénom],\n\nI am a Business Development Consultant at ENECHANGE (Japan, TSE: 4169), and I work on EIR, our platform connecting renewable energy developers with investors.\n\nWe work with over 30 active investors and a pipeline of 500+ sourced projects across Europe, covering all technologies (PV, agriPV, storage, wind), from 200 kW to 30 MW.\n\nWe support:\n- Developers → direct access to investors for co-development, acquisition or sale\n- Investors → qualified projects at all stages (early-stage to RTB)\n\nIf you have projects to finance or acquisition opportunities, I would be happy to discuss.\n\nBest regards,\n\nZein Tlais\nBusiness Development Consultant — ENECHANGE\nSchedule a meeting: https://calendar.app.google/Fe8Br6t4KzuWRxDE8\nLinkedIn: https://www.linkedin.com/in/zein-tlais-a91363172/\nMobile: +33 6 66 66 78 00	en	\N	2026-06-15 18:14:20.2206	2026-06-15 18:14:20.2206	1
47	Email prospection (FR)	email	investor	EIR — mise en relation ENR	Bonjour [Prénom],\n\nJe suis Business Development Consultant chez ENECHANGE (Japon, TSE: 4169), et je travaille sur EIR, notre plateforme de mise en relation entre développeurs et investisseurs ENR.\n\nNous travaillons avec plus de 30 investisseurs actifs et une base de 500 projets sourcés en France et en Europe, sur toutes typologies (PV, agriPV, stockage, éolien), de 200 kW à 30 MW.\n\nNous accompagnons :\n- Développeurs → accès direct à des investisseurs pour co-développement, acquisition ou cession\n- Investisseurs → projets qualifiés à tous les stades (early-stage à RTB)\n\nSi vous avez des projets à financer ou des opportunités d'acquisition, je serais ravi d'échanger.\n\nBien cordialement,\n\nZein Tlais\nBusiness Development Consultant — ENECHANGE\nSchedule a meeting: https://calendar.app.google/Fe8Br6t4KzuWRxDE8\nLinkedIn: https://www.linkedin.com/in/zein-tlais-a91363172/\nMobile: 06 66 66 78 00	fr	\N	2026-06-15 18:14:20.2206	2026-06-15 18:14:20.2206	1
48	Email prospection (EN)	email	investor	EIR — Connecting RE Developers & Investors	Hello [Prénom],\n\nI am a Business Development Consultant at ENECHANGE (Japan, TSE: 4169), and I work on EIR, our platform connecting renewable energy developers with investors.\n\nWe work with over 30 active investors and a pipeline of 500+ sourced projects across Europe, covering all technologies (PV, agriPV, storage, wind), from 200 kW to 30 MW.\n\nWe support:\n- Developers → direct access to investors for co-development, acquisition or sale\n- Investors → qualified projects at all stages (early-stage to RTB)\n\nIf you have projects to finance or acquisition opportunities, I would be happy to discuss.\n\nBest regards,\n\nZein Tlais\nBusiness Development Consultant — ENECHANGE\nSchedule a meeting: https://calendar.app.google/Fe8Br6t4KzuWRxDE8\nLinkedIn: https://www.linkedin.com/in/zein-tlais-a91363172/\nMobile: +33 6 66 66 78 00	en	\N	2026-06-15 18:14:20.2206	2026-06-15 18:14:20.2206	1
49	Email prospection (FR)	email	ipp	EIR — mise en relation ENR	Bonjour [Prénom],\n\nJe suis Business Development Consultant chez ENECHANGE (Japon, TSE: 4169), et je travaille sur EIR, notre plateforme de mise en relation entre développeurs et investisseurs ENR.\n\nNous travaillons avec plus de 30 investisseurs actifs et une base de 500 projets sourcés en France et en Europe, sur toutes typologies (PV, agriPV, stockage, éolien), de 200 kW à 30 MW.\n\nNous accompagnons :\n- Développeurs → accès direct à des investisseurs pour co-développement, acquisition ou cession\n- Investisseurs → projets qualifiés à tous les stades (early-stage à RTB)\n\nSi vous avez des projets à financer ou des opportunités d'acquisition, je serais ravi d'échanger.\n\nBien cordialement,\n\nZein Tlais\nBusiness Development Consultant — ENECHANGE\nSchedule a meeting: https://calendar.app.google/Fe8Br6t4KzuWRxDE8\nLinkedIn: https://www.linkedin.com/in/zein-tlais-a91363172/\nMobile: 06 66 66 78 00	fr	\N	2026-06-15 18:14:20.2206	2026-06-15 18:14:20.2206	1
50	Email prospection (EN)	email	ipp	EIR — Connecting RE Developers & Investors	Hello [Prénom],\n\nI am a Business Development Consultant at ENECHANGE (Japan, TSE: 4169), and I work on EIR, our platform connecting renewable energy developers with investors.\n\nWe work with over 30 active investors and a pipeline of 500+ sourced projects across Europe, covering all technologies (PV, agriPV, storage, wind), from 200 kW to 30 MW.\n\nWe support:\n- Developers → direct access to investors for co-development, acquisition or sale\n- Investors → qualified projects at all stages (early-stage to RTB)\n\nIf you have projects to finance or acquisition opportunities, I would be happy to discuss.\n\nBest regards,\n\nZein Tlais\nBusiness Development Consultant — ENECHANGE\nSchedule a meeting: https://calendar.app.google/Fe8Br6t4KzuWRxDE8\nLinkedIn: https://www.linkedin.com/in/zein-tlais-a91363172/\nMobile: +33 6 66 66 78 00	en	\N	2026-06-15 18:14:20.2206	2026-06-15 18:14:20.2206	1
51	Email prospection (FR)	email	family_office	EIR — mise en relation ENR	Bonjour [Prénom],\n\nJe suis Business Development Consultant chez ENECHANGE (Japon, TSE: 4169), et je travaille sur EIR, notre plateforme de mise en relation entre développeurs et investisseurs ENR.\n\nNous travaillons avec plus de 30 investisseurs actifs et une base de 500 projets sourcés en France et en Europe, sur toutes typologies (PV, agriPV, stockage, éolien), de 200 kW à 30 MW.\n\nNous accompagnons :\n- Développeurs → accès direct à des investisseurs pour co-développement, acquisition ou cession\n- Investisseurs → projets qualifiés à tous les stades (early-stage à RTB)\n\nSi vous avez des projets à financer ou des opportunités d'acquisition, je serais ravi d'échanger.\n\nBien cordialement,\n\nZein Tlais\nBusiness Development Consultant — ENECHANGE\nSchedule a meeting: https://calendar.app.google/Fe8Br6t4KzuWRxDE8\nLinkedIn: https://www.linkedin.com/in/zein-tlais-a91363172/\nMobile: 06 66 66 78 00	fr	\N	2026-06-15 18:14:20.2206	2026-06-15 18:14:20.2206	1
52	Email prospection (EN)	email	family_office	EIR — Connecting RE Developers & Investors	Hello [Prénom],\n\nI am a Business Development Consultant at ENECHANGE (Japan, TSE: 4169), and I work on EIR, our platform connecting renewable energy developers with investors.\n\nWe work with over 30 active investors and a pipeline of 500+ sourced projects across Europe, covering all technologies (PV, agriPV, storage, wind), from 200 kW to 30 MW.\n\nWe support:\n- Developers → direct access to investors for co-development, acquisition or sale\n- Investors → qualified projects at all stages (early-stage to RTB)\n\nIf you have projects to finance or acquisition opportunities, I would be happy to discuss.\n\nBest regards,\n\nZein Tlais\nBusiness Development Consultant — ENECHANGE\nSchedule a meeting: https://calendar.app.google/Fe8Br6t4KzuWRxDE8\nLinkedIn: https://www.linkedin.com/in/zein-tlais-a91363172/\nMobile: +33 6 66 66 78 00	en	\N	2026-06-15 18:14:20.2206	2026-06-15 18:14:20.2206	1
53	Suivi Sunrock - CR + NDA	email	ipp	Merci pour l'échange — Résumé & Prochaines étapes	Bonjour Franck,\n\nMerci beaucoup pour ton temps tout à l'heure, c'était un échange très enrichissant.\n\nComme convenu, voici un résumé de notre discussion et les prochaines étapes :\n\n📌 Ce qu'on retient :\n- Sunrock, exclusivement grandes toitures logistiques et ombrières (1-18 MW), pas de sol ni agriPV\n- 60 MW en France, objectif 100 MW puis 200 MW/an\n- Modèles ouverts : acquisition, co-développement, JV, co-SPV\n\n🎯 Prochaines étapes proposées :\n1. Je vous joins notre présentation EIR et notre modèle de NDA standard\n2. Votre présentation Sunrock nous intéresse beaucoup\n3. Nous avons identifié un lot de projets toiture (~3 MW, RTB, multi-régions) à vous partager\n4. On continue à vous sourcer des opportunités grandes toitures\n\n💡 Notre modèle de partenariat :\n- Période d'essai gratuite de 6 mois (accès à nos projets sans engagement)\n- Commission uniquement si vous investissez dans un projet qu'on vous présente\n- On évalue ensemble après 6 mois\n\nN'hésitez pas si vous avez des questions !\n\nBien cordialement,\n\nZein Tlais\nEntrepreneur in Residence — EIR (Enechange Insight Renewables)	fr	CR réunion 17/06/2026 avec Franck Burguion (Sunrock). Envoyer présentation EIR + NDA en pièces jointes.	2026-06-17 13:13:57.661197	2026-06-17 13:13:57.661197	2
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: hermes
--

COPY public.users (id, username, full_name, password_hash, role, is_active, created_at) FROM stdin;
2	mariella	Mariella Mansour	$2b$12$Dq3x99r/lBX7GcCPDP6PH.eCVxBiQ0tAQS//liYwTzvZgOY4ZQpGm	admin	t	2026-06-15 18:31:12.582709
3	adnan	Adnan	$2b$12$M/u4mnxBVXlDSqKX5AQHze4.5lWDxEZqp6oud/ultQKCbuqwJpjFy	admin	t	2026-06-16 01:50:34.524157
4	imad	Imad	$2b$12$TqHTDkYsaBsefIrKKKCWoe3Gh9g4PHHekPEkp8Vo/EDDC4iAxsFU6	admin	t	2026-06-16 10:43:21.891954
5	admin	Admin	$2b$12$0VlD8qZvyY1KZcJ6zfVxAuC3Kx5hAv555A50USQLkxOQaI2bOhiXG	admin	t	2026-06-17 02:03:50.489856
1	zein	Zein Tlais	$2b$12$UKDEAckxU8Zhk5NhdoP1IOGF1UJqrvo60GbHLqnT1Tnt3OutNo7Iq	admin	t	2026-06-15 18:31:12.582709
\.


--
-- Data for Name: weekly_notes; Type: TABLE DATA; Schema: public; Owner: hermes
--

COPY public.weekly_notes (id, note, category, related_company, status, week_start, done, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: weekly_tasks; Type: TABLE DATA; Schema: public; Owner: hermes
--

COPY public.weekly_tasks (id, title, description, category, related_company, outcome, priority, assignee, status, week_start, done, created_at, updated_at, prospect_id) FROM stdin;
21	Relancer Valeco — retour Zakaria & Cyril	NDA signé (Drive: Valeco.pdf).\nProjet Argillières (éolien 15,75 MW) : recours déposé le 16/04/2026 → cession en stand-by.\nPlus aucun projet disponible côté Valeco.\nCyril Giffard a demandé un track record EIR.\nAucun échange depuis le 16/04/2026.\nÀ discuter avec Mariella : transmettre track record, relancer, ou mettre en veille.	team	Valeco	\N	haute	Zein	a_faire	2026-06-22	f	2026-06-22 09:13:03.842198	2026-06-22 09:13:03.842198	1
42	Suivi EnR Courtage — 1. Retourner vers Yann: statut David Leb	NDA signe + action en attente · Statut: ProspectStatus.nda_signed\n\nVous a présenté David Lebret (Regenerasun) — intro call fait le 21/05. Fee-sharing 50/50 signé le 03/06 ✅. A un portefeuille 6/7 MWc à proposer. Proje	team	EnR Courtage	\N	haute		a_faire	2026-06-22	f	2026-06-22 11:33:19.031704	2026-06-22 11:41:36.896089	31
\.


--
-- Name: documents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: hermes
--

SELECT pg_catalog.setval('public.documents_id_seq', 180, true);


--
-- Name: exhibition_companies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: hermes
--

SELECT pg_catalog.setval('public.exhibition_companies_id_seq', 17, true);


--
-- Name: exhibitions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: hermes
--

SELECT pg_catalog.setval('public.exhibitions_id_seq', 3, true);


--
-- Name: investors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: hermes
--

SELECT pg_catalog.setval('public.investors_id_seq', 19, true);


--
-- Name: learning_id_seq; Type: SEQUENCE SET; Schema: public; Owner: hermes
--

SELECT pg_catalog.setval('public.learning_id_seq', 175, true);


--
-- Name: meeting_preps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: hermes
--

SELECT pg_catalog.setval('public.meeting_preps_id_seq', 1, true);


--
-- Name: opportunities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: hermes
--

SELECT pg_catalog.setval('public.opportunities_id_seq', 12, true);


--
-- Name: projects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: hermes
--

SELECT pg_catalog.setval('public.projects_id_seq', 195, true);


--
-- Name: prospects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: hermes
--

SELECT pg_catalog.setval('public.prospects_id_seq', 144, true);


--
-- Name: scouting_id_seq; Type: SEQUENCE SET; Schema: public; Owner: hermes
--

SELECT pg_catalog.setval('public.scouting_id_seq', 939, true);


--
-- Name: task_suggestions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: hermes
--

SELECT pg_catalog.setval('public.task_suggestions_id_seq', 35, true);


--
-- Name: templates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: hermes
--

SELECT pg_catalog.setval('public.templates_id_seq', 53, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: hermes
--

SELECT pg_catalog.setval('public.users_id_seq', 9, true);


--
-- Name: weekly_notes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: hermes
--

SELECT pg_catalog.setval('public.weekly_notes_id_seq', 1, false);


--
-- Name: weekly_tasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: hermes
--

SELECT pg_catalog.setval('public.weekly_tasks_id_seq', 46, true);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: exhibition_companies exhibition_companies_pkey; Type: CONSTRAINT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.exhibition_companies
    ADD CONSTRAINT exhibition_companies_pkey PRIMARY KEY (id);


--
-- Name: exhibitions exhibitions_pkey; Type: CONSTRAINT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.exhibitions
    ADD CONSTRAINT exhibitions_pkey PRIMARY KEY (id);


--
-- Name: investors investors_pkey; Type: CONSTRAINT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.investors
    ADD CONSTRAINT investors_pkey PRIMARY KEY (id);


--
-- Name: learning learning_pkey; Type: CONSTRAINT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.learning
    ADD CONSTRAINT learning_pkey PRIMARY KEY (id);


--
-- Name: meeting_preps meeting_preps_pkey; Type: CONSTRAINT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.meeting_preps
    ADD CONSTRAINT meeting_preps_pkey PRIMARY KEY (id);


--
-- Name: opportunities opportunities_pkey; Type: CONSTRAINT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.opportunities
    ADD CONSTRAINT opportunities_pkey PRIMARY KEY (id);


--
-- Name: projects projects_code_key; Type: CONSTRAINT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_code_key UNIQUE (code);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: prospects prospects_pkey; Type: CONSTRAINT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.prospects
    ADD CONSTRAINT prospects_pkey PRIMARY KEY (id);


--
-- Name: scouting scouting_pkey; Type: CONSTRAINT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.scouting
    ADD CONSTRAINT scouting_pkey PRIMARY KEY (id);


--
-- Name: task_suggestions task_suggestions_pkey; Type: CONSTRAINT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.task_suggestions
    ADD CONSTRAINT task_suggestions_pkey PRIMARY KEY (id);


--
-- Name: templates templates_pkey; Type: CONSTRAINT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.templates
    ADD CONSTRAINT templates_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: weekly_notes weekly_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.weekly_notes
    ADD CONSTRAINT weekly_notes_pkey PRIMARY KEY (id);


--
-- Name: weekly_tasks weekly_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.weekly_tasks
    ADD CONSTRAINT weekly_tasks_pkey PRIMARY KEY (id);


--
-- Name: ix_documents_id; Type: INDEX; Schema: public; Owner: hermes
--

CREATE INDEX ix_documents_id ON public.documents USING btree (id);


--
-- Name: ix_documents_prospect_id; Type: INDEX; Schema: public; Owner: hermes
--

CREATE INDEX ix_documents_prospect_id ON public.documents USING btree (prospect_id);


--
-- Name: ix_exhibition_companies_exhibition_id; Type: INDEX; Schema: public; Owner: hermes
--

CREATE INDEX ix_exhibition_companies_exhibition_id ON public.exhibition_companies USING btree (exhibition_id);


--
-- Name: ix_exhibition_companies_id; Type: INDEX; Schema: public; Owner: hermes
--

CREATE INDEX ix_exhibition_companies_id ON public.exhibition_companies USING btree (id);


--
-- Name: ix_exhibitions_id; Type: INDEX; Schema: public; Owner: hermes
--

CREATE INDEX ix_exhibitions_id ON public.exhibitions USING btree (id);


--
-- Name: ix_investors_id; Type: INDEX; Schema: public; Owner: hermes
--

CREATE INDEX ix_investors_id ON public.investors USING btree (id);


--
-- Name: ix_learning_id; Type: INDEX; Schema: public; Owner: hermes
--

CREATE INDEX ix_learning_id ON public.learning USING btree (id);


--
-- Name: ix_meeting_preps_company; Type: INDEX; Schema: public; Owner: hermes
--

CREATE INDEX ix_meeting_preps_company ON public.meeting_preps USING btree (company);


--
-- Name: ix_meeting_preps_id; Type: INDEX; Schema: public; Owner: hermes
--

CREATE INDEX ix_meeting_preps_id ON public.meeting_preps USING btree (id);


--
-- Name: ix_opportunities_id; Type: INDEX; Schema: public; Owner: hermes
--

CREATE INDEX ix_opportunities_id ON public.opportunities USING btree (id);


--
-- Name: ix_projects_id; Type: INDEX; Schema: public; Owner: hermes
--

CREATE INDEX ix_projects_id ON public.projects USING btree (id);


--
-- Name: ix_prospects_id; Type: INDEX; Schema: public; Owner: hermes
--

CREATE INDEX ix_prospects_id ON public.prospects USING btree (id);


--
-- Name: ix_scouting_id; Type: INDEX; Schema: public; Owner: hermes
--

CREATE INDEX ix_scouting_id ON public.scouting USING btree (id);


--
-- Name: ix_task_suggestions_id; Type: INDEX; Schema: public; Owner: hermes
--

CREATE INDEX ix_task_suggestions_id ON public.task_suggestions USING btree (id);


--
-- Name: ix_task_suggestions_ref; Type: INDEX; Schema: public; Owner: hermes
--

CREATE INDEX ix_task_suggestions_ref ON public.task_suggestions USING btree (ref);


--
-- Name: ix_task_suggestions_week_start; Type: INDEX; Schema: public; Owner: hermes
--

CREATE INDEX ix_task_suggestions_week_start ON public.task_suggestions USING btree (week_start);


--
-- Name: ix_templates_id; Type: INDEX; Schema: public; Owner: hermes
--

CREATE INDEX ix_templates_id ON public.templates USING btree (id);


--
-- Name: ix_users_id; Type: INDEX; Schema: public; Owner: hermes
--

CREATE INDEX ix_users_id ON public.users USING btree (id);


--
-- Name: ix_users_username; Type: INDEX; Schema: public; Owner: hermes
--

CREATE UNIQUE INDEX ix_users_username ON public.users USING btree (username);


--
-- Name: ix_weekly_notes_id; Type: INDEX; Schema: public; Owner: hermes
--

CREATE INDEX ix_weekly_notes_id ON public.weekly_notes USING btree (id);


--
-- Name: ix_weekly_tasks_id; Type: INDEX; Schema: public; Owner: hermes
--

CREATE INDEX ix_weekly_tasks_id ON public.weekly_tasks USING btree (id);


--
-- Name: ix_weekly_tasks_week_start; Type: INDEX; Schema: public; Owner: hermes
--

CREATE INDEX ix_weekly_tasks_week_start ON public.weekly_tasks USING btree (week_start);


--
-- Name: documents documents_investor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_investor_id_fkey FOREIGN KEY (investor_id) REFERENCES public.investors(id);


--
-- Name: documents documents_prospect_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_prospect_id_fkey FOREIGN KEY (prospect_id) REFERENCES public.prospects(id);


--
-- Name: opportunities opportunities_prospect_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.opportunities
    ADD CONSTRAINT opportunities_prospect_id_fkey FOREIGN KEY (prospect_id) REFERENCES public.prospects(id);


--
-- Name: projects projects_developer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_developer_id_fkey FOREIGN KEY (developer_id) REFERENCES public.prospects(id);


--
-- Name: weekly_tasks weekly_tasks_prospect_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hermes
--

ALTER TABLE ONLY public.weekly_tasks
    ADD CONSTRAINT weekly_tasks_prospect_id_fkey FOREIGN KEY (prospect_id) REFERENCES public.prospects(id);


--
-- PostgreSQL database dump complete
--

\unrestrict pwIob0Yb6kL0qdfGXZXcAE1rFQcdAShtAtVjbvhiYudxhgYpC72ncrdlFRmQBai

