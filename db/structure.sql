--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: amendments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE amendments (
    id integer NOT NULL,
    project_id integer,
    body text,
    posted_at timestamp without time zone,
    posted_by_officer_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    title text
);


--
-- Name: amendments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE amendments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: amendments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE amendments_id_seq OWNED BY amendments.id;


--
-- Name: bid_reviews; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bid_reviews (
    id integer NOT NULL,
    starred boolean,
    read boolean,
    officer_id integer,
    bid_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    rating integer
);


--
-- Name: bid_reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bid_reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bid_reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bid_reviews_id_seq OWNED BY bid_reviews.id;


--
-- Name: bids; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bids (
    id integer NOT NULL,
    vendor_id integer,
    project_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    submitted_at timestamp without time zone,
    dismissed_at timestamp without time zone,
    dismissed_by_officer_id integer,
    total_stars integer DEFAULT 0 NOT NULL,
    total_comments integer DEFAULT 0 NOT NULL,
    awarded_at timestamp without time zone,
    awarded_by_officer_id integer,
    average_rating numeric(3,2),
    total_ratings integer
);


--
-- Name: bids_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bids_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bids_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bids_id_seq OWNED BY bids.id;


--
-- Name: bids_labels; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bids_labels (
    bid_id integer,
    label_id integer
);


--
-- Name: collaborators; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE collaborators (
    id integer NOT NULL,
    project_id integer,
    officer_id integer,
    owner boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    added_by_officer_id integer
);


--
-- Name: collaborators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE collaborators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collaborators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE collaborators_id_seq OWNED BY collaborators.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    commentable_type character varying(255),
    commentable_id integer,
    officer_id integer,
    comment_type character varying(255),
    body text,
    data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0,
    attempts integer DEFAULT 0,
    handler text,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying(255),
    queue character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;


--
-- Name: event_feeds; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE event_feeds (
    id integer NOT NULL,
    event_id integer,
    user_id integer,
    read boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: event_feeds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE event_feeds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_feeds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE event_feeds_id_seq OWNED BY event_feeds.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    targetable_type character varying(255),
    targetable_id integer,
    event_type smallint
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: form_templates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE form_templates (
    id integer NOT NULL,
    name character varying(255),
    response_fields text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    form_options text
);


--
-- Name: form_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE form_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: form_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE form_templates_id_seq OWNED BY form_templates.id;


--
-- Name: global_configs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE global_configs (
    id integer NOT NULL,
    bid_review_enabled boolean DEFAULT true,
    bid_submission_enabled boolean DEFAULT true,
    comments_enabled boolean DEFAULT true,
    questions_enabled boolean DEFAULT true,
    event_hooks text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    amendments_enabled boolean DEFAULT true,
    watch_projects_enabled boolean DEFAULT true,
    save_searches_enabled boolean DEFAULT true,
    search_projects_enabled boolean DEFAULT true,
    form_options text,
    passwordless_invites_enabled boolean DEFAULT false
);


--
-- Name: global_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE global_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: global_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE global_configs_id_seq OWNED BY global_configs.id;


--
-- Name: impressions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE impressions (
    id integer NOT NULL,
    impressionable_type character varying(255),
    impressionable_id integer,
    user_id integer,
    controller_name character varying(255),
    action_name character varying(255),
    view_name character varying(255),
    request_hash character varying(255),
    ip_address character varying(255),
    session_hash character varying(255),
    message text,
    referrer text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: impressions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE impressions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: impressions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE impressions_id_seq OWNED BY impressions.id;


--
-- Name: labels; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE labels (
    id integer NOT NULL,
    project_id integer,
    name character varying(255),
    color character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: labels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE labels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: labels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE labels_id_seq OWNED BY labels.id;


--
-- Name: officers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE officers (
    id integer NOT NULL,
    role_id integer,
    title character varying(255),
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: officers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE officers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: officers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE officers_id_seq OWNED BY officers.id;


--
-- Name: project_revisions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE project_revisions (
    id integer NOT NULL,
    body text,
    project_id integer,
    saved_by_officer_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: project_revisions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_revisions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_revisions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_revisions_id_seq OWNED BY project_revisions.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE projects (
    id integer NOT NULL,
    title character varying(255),
    body text,
    bids_due_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    posted_at timestamp without time zone,
    posted_by_officer_id integer,
    total_comments integer DEFAULT 0 NOT NULL,
    form_options text,
    abstract character varying(255),
    featured boolean,
    review_mode integer DEFAULT 1
);


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE projects_id_seq OWNED BY projects.id;


--
-- Name: projects_tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE projects_tags (
    project_id integer,
    tag_id integer
);


--
-- Name: questions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE questions (
    id integer NOT NULL,
    project_id integer,
    vendor_id integer,
    officer_id integer,
    body text,
    answer_body text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE questions_id_seq OWNED BY questions.id;


--
-- Name: response_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE response_fields (
    id integer NOT NULL,
    response_fieldable_id integer,
    response_fieldable_type character varying(255),
    label character varying(255),
    field_type character varying(255),
    field_options text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sort_order integer NOT NULL,
    key_field boolean,
    only_visible_to_admin boolean
);


--
-- Name: response_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE response_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: response_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE response_fields_id_seq OWNED BY response_fields.id;


--
-- Name: responses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE responses (
    id integer NOT NULL,
    responsable_id integer,
    responsable_type character varying(255),
    response_field_id integer,
    value text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sortable_value character varying(255),
    upload character varying(255),
    user_id integer
);


--
-- Name: responses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE responses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: responses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE responses_id_seq OWNED BY responses.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE roles (
    id integer NOT NULL,
    name character varying(255),
    role_type integer,
    permissions text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    undeletable boolean
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;


--
-- Name: saved_searches; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE saved_searches (
    id integer NOT NULL,
    vendor_id integer,
    search_parameters text,
    name character varying(255),
    last_emailed_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: saved_searches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE saved_searches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: saved_searches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE saved_searches_id_seq OWNED BY saved_searches.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255),
    crypted_password character varying(255),
    password_salt character varying(255),
    persistence_token character varying(255),
    notification_preferences text,
    owner_id integer,
    owner_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    perishable_token character varying(255) DEFAULT ''::character varying NOT NULL,
    last_login_at timestamp without time zone,
    current_login_at timestamp without time zone,
    last_login_ip character varying(255),
    current_login_ip character varying(255)
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: vendor_profiles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vendor_profiles (
    id integer NOT NULL,
    vendor_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: vendor_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vendor_profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vendor_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vendor_profiles_id_seq OWNED BY vendor_profiles.id;


--
-- Name: vendors; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vendors (
    id integer NOT NULL,
    account_disabled boolean,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: vendors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vendors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vendors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vendors_id_seq OWNED BY vendors.id;


--
-- Name: watches; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE watches (
    id integer NOT NULL,
    user_id integer,
    watchable_id integer,
    watchable_type character varying(255),
    disabled boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: watches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE watches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: watches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE watches_id_seq OWNED BY watches.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY amendments ALTER COLUMN id SET DEFAULT nextval('amendments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bid_reviews ALTER COLUMN id SET DEFAULT nextval('bid_reviews_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bids ALTER COLUMN id SET DEFAULT nextval('bids_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY collaborators ALTER COLUMN id SET DEFAULT nextval('collaborators_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_feeds ALTER COLUMN id SET DEFAULT nextval('event_feeds_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY form_templates ALTER COLUMN id SET DEFAULT nextval('form_templates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY global_configs ALTER COLUMN id SET DEFAULT nextval('global_configs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY impressions ALTER COLUMN id SET DEFAULT nextval('impressions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY labels ALTER COLUMN id SET DEFAULT nextval('labels_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY officers ALTER COLUMN id SET DEFAULT nextval('officers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_revisions ALTER COLUMN id SET DEFAULT nextval('project_revisions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects ALTER COLUMN id SET DEFAULT nextval('projects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY questions ALTER COLUMN id SET DEFAULT nextval('questions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_fields ALTER COLUMN id SET DEFAULT nextval('response_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY responses ALTER COLUMN id SET DEFAULT nextval('responses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY saved_searches ALTER COLUMN id SET DEFAULT nextval('saved_searches_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vendor_profiles ALTER COLUMN id SET DEFAULT nextval('vendor_profiles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vendors ALTER COLUMN id SET DEFAULT nextval('vendors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY watches ALTER COLUMN id SET DEFAULT nextval('watches_id_seq'::regclass);


--
-- Name: amendments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY amendments
    ADD CONSTRAINT amendments_pkey PRIMARY KEY (id);


--
-- Name: bid_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bid_reviews
    ADD CONSTRAINT bid_reviews_pkey PRIMARY KEY (id);


--
-- Name: bids_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bids
    ADD CONSTRAINT bids_pkey PRIMARY KEY (id);


--
-- Name: collaborators_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY collaborators
    ADD CONSTRAINT collaborators_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: event_feeds_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY event_feeds
    ADD CONSTRAINT event_feeds_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: form_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY form_templates
    ADD CONSTRAINT form_templates_pkey PRIMARY KEY (id);


--
-- Name: global_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY global_configs
    ADD CONSTRAINT global_configs_pkey PRIMARY KEY (id);


--
-- Name: impressions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY impressions
    ADD CONSTRAINT impressions_pkey PRIMARY KEY (id);


--
-- Name: labels_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY labels
    ADD CONSTRAINT labels_pkey PRIMARY KEY (id);


--
-- Name: officers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY officers
    ADD CONSTRAINT officers_pkey PRIMARY KEY (id);


--
-- Name: project_revisions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_revisions
    ADD CONSTRAINT project_revisions_pkey PRIMARY KEY (id);


--
-- Name: projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- Name: response_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY response_fields
    ADD CONSTRAINT response_fields_pkey PRIMARY KEY (id);


--
-- Name: responses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY responses
    ADD CONSTRAINT responses_pkey PRIMARY KEY (id);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: saved_searches_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY saved_searches
    ADD CONSTRAINT saved_searches_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vendor_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vendor_profiles
    ADD CONSTRAINT vendor_profiles_pkey PRIMARY KEY (id);


--
-- Name: vendors_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vendors
    ADD CONSTRAINT vendors_pkey PRIMARY KEY (id);


--
-- Name: watches_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY watches
    ADD CONSTRAINT watches_pkey PRIMARY KEY (id);


--
-- Name: controlleraction_ip_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX controlleraction_ip_index ON impressions USING btree (controller_name, action_name, ip_address);


--
-- Name: controlleraction_request_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX controlleraction_request_index ON impressions USING btree (controller_name, action_name, request_hash);


--
-- Name: controlleraction_session_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX controlleraction_session_index ON impressions USING btree (controller_name, action_name, session_hash);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX delayed_jobs_priority ON delayed_jobs USING btree (priority, run_at);


--
-- Name: impressionable_type_message_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX impressionable_type_message_index ON impressions USING btree (impressionable_type, message, impressionable_id);


--
-- Name: index_impressions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_impressions_on_user_id ON impressions USING btree (user_id);


--
-- Name: poly_ip_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX poly_ip_index ON impressions USING btree (impressionable_type, impressionable_id, ip_address);


--
-- Name: poly_request_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX poly_request_index ON impressions USING btree (impressionable_type, impressionable_id, request_hash);


--
-- Name: poly_session_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX poly_session_index ON impressions USING btree (impressionable_type, impressionable_id, session_hash);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: amendments_posted_by_officer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY amendments
    ADD CONSTRAINT amendments_posted_by_officer_id_fk FOREIGN KEY (posted_by_officer_id) REFERENCES officers(id);


--
-- Name: amendments_project_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY amendments
    ADD CONSTRAINT amendments_project_id_fk FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: bid_reviews_bid_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bid_reviews
    ADD CONSTRAINT bid_reviews_bid_id_fk FOREIGN KEY (bid_id) REFERENCES bids(id);


--
-- Name: bid_reviews_officer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bid_reviews
    ADD CONSTRAINT bid_reviews_officer_id_fk FOREIGN KEY (officer_id) REFERENCES officers(id);


--
-- Name: bids_labels_bid_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bids_labels
    ADD CONSTRAINT bids_labels_bid_id_fk FOREIGN KEY (bid_id) REFERENCES bids(id);


--
-- Name: bids_labels_label_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bids_labels
    ADD CONSTRAINT bids_labels_label_id_fk FOREIGN KEY (label_id) REFERENCES labels(id);


--
-- Name: bids_project_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bids
    ADD CONSTRAINT bids_project_id_fk FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: bids_vendor_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bids
    ADD CONSTRAINT bids_vendor_id_fk FOREIGN KEY (vendor_id) REFERENCES vendors(id);


--
-- Name: collaborators_officer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collaborators
    ADD CONSTRAINT collaborators_officer_id_fk FOREIGN KEY (officer_id) REFERENCES officers(id);


--
-- Name: collaborators_project_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collaborators
    ADD CONSTRAINT collaborators_project_id_fk FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: comments_officer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_officer_id_fk FOREIGN KEY (officer_id) REFERENCES officers(id);


--
-- Name: event_feeds_event_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_feeds
    ADD CONSTRAINT event_feeds_event_id_fk FOREIGN KEY (event_id) REFERENCES events(id);


--
-- Name: labels_project_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY labels
    ADD CONSTRAINT labels_project_id_fk FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: project_revisions_project_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_revisions
    ADD CONSTRAINT project_revisions_project_id_fk FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: projects_posted_by_officer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_posted_by_officer_id_fk FOREIGN KEY (posted_by_officer_id) REFERENCES officers(id);


--
-- Name: projects_tags_project_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects_tags
    ADD CONSTRAINT projects_tags_project_id_fk FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: projects_tags_tag_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects_tags
    ADD CONSTRAINT projects_tags_tag_id_fk FOREIGN KEY (tag_id) REFERENCES tags(id);


--
-- Name: questions_officer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questions
    ADD CONSTRAINT questions_officer_id_fk FOREIGN KEY (officer_id) REFERENCES officers(id);


--
-- Name: questions_project_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questions
    ADD CONSTRAINT questions_project_id_fk FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: questions_vendor_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questions
    ADD CONSTRAINT questions_vendor_id_fk FOREIGN KEY (vendor_id) REFERENCES vendors(id);


--
-- Name: responses_response_field_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY responses
    ADD CONSTRAINT responses_response_field_id_fk FOREIGN KEY (response_field_id) REFERENCES response_fields(id);


--
-- Name: saved_searches_vendor_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY saved_searches
    ADD CONSTRAINT saved_searches_vendor_id_fk FOREIGN KEY (vendor_id) REFERENCES vendors(id);


--
-- Name: vendor_profiles_vendor_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vendor_profiles
    ADD CONSTRAINT vendor_profiles_vendor_id_fk FOREIGN KEY (vendor_id) REFERENCES vendors(id);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20130204183601');

INSERT INTO schema_migrations (version) VALUES ('20130204183602');

INSERT INTO schema_migrations (version) VALUES ('20130204183603');

INSERT INTO schema_migrations (version) VALUES ('20130204183606');

INSERT INTO schema_migrations (version) VALUES ('20130204183734');

INSERT INTO schema_migrations (version) VALUES ('20130204184303');

INSERT INTO schema_migrations (version) VALUES ('20130205004911');

INSERT INTO schema_migrations (version) VALUES ('20130206001307');

INSERT INTO schema_migrations (version) VALUES ('20130206222933');

INSERT INTO schema_migrations (version) VALUES ('20130206222958');

INSERT INTO schema_migrations (version) VALUES ('20130206230706');

INSERT INTO schema_migrations (version) VALUES ('20130207171716');

INSERT INTO schema_migrations (version) VALUES ('20130208160548');

INSERT INTO schema_migrations (version) VALUES ('20130208172459');

INSERT INTO schema_migrations (version) VALUES ('20130208232526');

INSERT INTO schema_migrations (version) VALUES ('20130209171426');

INSERT INTO schema_migrations (version) VALUES ('20130212001903');

INSERT INTO schema_migrations (version) VALUES ('20130212002405');

INSERT INTO schema_migrations (version) VALUES ('20130215002715');

INSERT INTO schema_migrations (version) VALUES ('20130215014119');

INSERT INTO schema_migrations (version) VALUES ('20130215014409');

INSERT INTO schema_migrations (version) VALUES ('20130216005526');

INSERT INTO schema_migrations (version) VALUES ('20130216030446');

INSERT INTO schema_migrations (version) VALUES ('20130220234741');

INSERT INTO schema_migrations (version) VALUES ('20130220234812');

INSERT INTO schema_migrations (version) VALUES ('20130225231711');

INSERT INTO schema_migrations (version) VALUES ('20130228191259');

INSERT INTO schema_migrations (version) VALUES ('20130228222935');

INSERT INTO schema_migrations (version) VALUES ('20130301015538');

INSERT INTO schema_migrations (version) VALUES ('20130301015822');

INSERT INTO schema_migrations (version) VALUES ('20130301023529');

INSERT INTO schema_migrations (version) VALUES ('20130301183105');

INSERT INTO schema_migrations (version) VALUES ('20130302015127');

INSERT INTO schema_migrations (version) VALUES ('20130304010821');

INSERT INTO schema_migrations (version) VALUES ('20130305201039');

INSERT INTO schema_migrations (version) VALUES ('20130308053849');

INSERT INTO schema_migrations (version) VALUES ('20130308183135');

INSERT INTO schema_migrations (version) VALUES ('20130309000625');

INSERT INTO schema_migrations (version) VALUES ('20130313003836');

INSERT INTO schema_migrations (version) VALUES ('20130319012017');

INSERT INTO schema_migrations (version) VALUES ('20130319015840');

INSERT INTO schema_migrations (version) VALUES ('20130320181304');

INSERT INTO schema_migrations (version) VALUES ('20130321201112');

INSERT INTO schema_migrations (version) VALUES ('20130323045855');

INSERT INTO schema_migrations (version) VALUES ('20130403231904');

INSERT INTO schema_migrations (version) VALUES ('20130404174024');

INSERT INTO schema_migrations (version) VALUES ('20130406004215');

INSERT INTO schema_migrations (version) VALUES ('20130406004710');

INSERT INTO schema_migrations (version) VALUES ('20130408212810');

INSERT INTO schema_migrations (version) VALUES ('20130408231054');

INSERT INTO schema_migrations (version) VALUES ('20130411002227');

INSERT INTO schema_migrations (version) VALUES ('20130411010006');

INSERT INTO schema_migrations (version) VALUES ('20130412015423');

INSERT INTO schema_migrations (version) VALUES ('20130412033936');

INSERT INTO schema_migrations (version) VALUES ('20130412041345');

INSERT INTO schema_migrations (version) VALUES ('20130412172129');

INSERT INTO schema_migrations (version) VALUES ('20130412181224');

INSERT INTO schema_migrations (version) VALUES ('20130412185237');

INSERT INTO schema_migrations (version) VALUES ('20130412193007');

INSERT INTO schema_migrations (version) VALUES ('20130416213202');

INSERT INTO schema_migrations (version) VALUES ('20130419203956');