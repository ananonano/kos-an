--
-- PostgreSQL database dump
--

\restrict y5fZxJxMyJFgmnH1uOgBiXCkWvcCRAe876bLr6ct1IuNNeB9mRfP6ixi305zxjE

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: announcements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.announcements (
    id integer NOT NULL,
    judul character varying(255) NOT NULL,
    konten text NOT NULL,
    kategori character varying(100) NOT NULL,
    prioritas character varying(50) DEFAULT 'info'::character varying NOT NULL,
    target character varying(50) DEFAULT 'semua'::character varying NOT NULL,
    created_by integer,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT announcements_prioritas_check CHECK (((prioritas)::text = ANY (ARRAY[('info'::character varying)::text, ('penting'::character varying)::text, ('urgent'::character varying)::text]))),
    CONSTRAINT announcements_target_check CHECK (((target)::text = ANY (ARRAY[('semua'::character varying)::text, ('tenant'::character varying)::text, ('admin'::character varying)::text])))
);


ALTER TABLE public.announcements OWNER TO postgres;

--
-- Name: announcements_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.announcements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.announcements_id_seq OWNER TO postgres;

--
-- Name: announcements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.announcements_id_seq OWNED BY public.announcements.id;


--
-- Name: bills; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bills (
    id integer NOT NULL,
    tenant_id integer,
    contract_id integer,
    bulan character varying(50) NOT NULL,
    tahun integer NOT NULL,
    jumlah numeric(12,2) NOT NULL,
    status character varying(50) DEFAULT 'belum_lunas'::character varying NOT NULL,
    jatuh_tempo date NOT NULL,
    denda numeric(12,2) DEFAULT 0,
    catatan text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT bills_status_check CHECK (((status)::text = ANY (ARRAY[('belum_lunas'::character varying)::text, ('lunas'::character varying)::text, ('terlambat'::character varying)::text])))
);


ALTER TABLE public.bills OWNER TO postgres;

--
-- Name: bills_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bills_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bills_id_seq OWNER TO postgres;

--
-- Name: bills_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bills_id_seq OWNED BY public.bills.id;


--
-- Name: contracts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contracts (
    id integer NOT NULL,
    tenant_id integer,
    kamar_id integer,
    tanggal_mulai date NOT NULL,
    tanggal_selesai date,
    harga_per_bulan numeric(12,2) NOT NULL,
    deposit numeric(12,2) DEFAULT 0 NOT NULL,
    status character varying(50) DEFAULT 'aktif'::character varying NOT NULL,
    catatan text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT contracts_status_check CHECK (((status)::text = ANY (ARRAY[('aktif'::character varying)::text, ('selesai'::character varying)::text, ('dibatalkan'::character varying)::text])))
);


ALTER TABLE public.contracts OWNER TO postgres;

--
-- Name: contracts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.contracts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.contracts_id_seq OWNER TO postgres;

--
-- Name: contracts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.contracts_id_seq OWNED BY public.contracts.id;


--
-- Name: maintenance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.maintenance (
    id integer NOT NULL,
    tenant_id integer,
    kamar_id integer,
    judul character varying(255) NOT NULL,
    deskripsi text NOT NULL,
    kategori character varying(100) NOT NULL,
    prioritas character varying(50) DEFAULT 'sedang'::character varying NOT NULL,
    status character varying(50) DEFAULT 'baru'::character varying NOT NULL,
    foto jsonb,
    tanggal_lapor date NOT NULL,
    tanggal_selesai date,
    komentar_admin text,
    biaya numeric(12,2),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT maintenance_prioritas_check CHECK (((prioritas)::text = ANY (ARRAY[('rendah'::character varying)::text, ('sedang'::character varying)::text, ('tinggi'::character varying)::text, ('urgent'::character varying)::text]))),
    CONSTRAINT maintenance_status_check CHECK (((status)::text = ANY (ARRAY[('baru'::character varying)::text, ('diproses'::character varying)::text, ('selesai'::character varying)::text, ('ditolak'::character varying)::text])))
);


ALTER TABLE public.maintenance OWNER TO postgres;

--
-- Name: maintenance_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.maintenance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.maintenance_id_seq OWNER TO postgres;

--
-- Name: maintenance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.maintenance_id_seq OWNED BY public.maintenance.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    user_id integer NOT NULL,
    title character varying(255) NOT NULL,
    message text NOT NULL,
    type character varying(50) NOT NULL,
    related_id integer,
    is_read boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notifications_id_seq OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payments (
    id integer NOT NULL,
    bill_id integer,
    tenant_id integer,
    jumlah numeric(12,2) NOT NULL,
    tanggal_bayar date NOT NULL,
    metode_pembayaran character varying(100) NOT NULL,
    bukti_pembayaran text,
    status character varying(50) DEFAULT 'menunggu_verifikasi'::character varying NOT NULL,
    keterangan text,
    verified_by integer,
    verified_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT payments_status_check CHECK (((status)::text = ANY (ARRAY[('menunggu_verifikasi'::character varying)::text, ('lunas'::character varying)::text, ('ditolak'::character varying)::text])))
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payments_id_seq OWNER TO postgres;

--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payments_id_seq OWNED BY public.payments.id;


--
-- Name: rooms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rooms (
    id integer NOT NULL,
    nomor_kamar character varying(50) NOT NULL,
    tipe character varying(100) NOT NULL,
    harga numeric(12,2) NOT NULL,
    status character varying(50) DEFAULT 'kosong'::character varying NOT NULL,
    deskripsi text,
    fasilitas jsonb,
    foto text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT rooms_status_check CHECK (((status)::text = ANY (ARRAY[('kosong'::character varying)::text, ('terisi'::character varying)::text])))
);


ALTER TABLE public.rooms OWNER TO postgres;

--
-- Name: rooms_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rooms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rooms_id_seq OWNER TO postgres;

--
-- Name: rooms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rooms_id_seq OWNED BY public.rooms.id;


--
-- Name: tenants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tenants (
    id integer NOT NULL,
    user_id integer,
    kamar_id integer,
    nama character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    no_telepon character varying(20) NOT NULL,
    alamat_asal text,
    pekerjaan character varying(255),
    kontak_darurat character varying(20),
    tanggal_masuk date,
    tanggal_keluar date,
    status character varying(50) DEFAULT 'aktif'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT tenants_status_check CHECK (((status)::text = ANY (ARRAY[('aktif'::character varying)::text, ('tidak_aktif'::character varying)::text])))
);


ALTER TABLE public.tenants OWNER TO postgres;

--
-- Name: tenants_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tenants_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tenants_id_seq OWNER TO postgres;

--
-- Name: tenants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tenants_id_seq OWNED BY public.tenants.id;


--
-- Name: user_announcement_reads; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_announcement_reads (
    id integer NOT NULL,
    user_id integer NOT NULL,
    announcement_id integer NOT NULL,
    read_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.user_announcement_reads OWNER TO postgres;

--
-- Name: user_announcement_reads_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_announcement_reads_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_announcement_reads_id_seq OWNER TO postgres;

--
-- Name: user_announcement_reads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_announcement_reads_id_seq OWNED BY public.user_announcement_reads.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    nama character varying(255) NOT NULL,
    role character varying(50) DEFAULT 'tenant'::character varying NOT NULL,
    no_telepon character varying(20),
    foto text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY (ARRAY[('admin'::character varying)::text, ('tenant'::character varying)::text])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: announcements id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcements ALTER COLUMN id SET DEFAULT nextval('public.announcements_id_seq'::regclass);


--
-- Name: bills id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bills ALTER COLUMN id SET DEFAULT nextval('public.bills_id_seq'::regclass);


--
-- Name: contracts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contracts ALTER COLUMN id SET DEFAULT nextval('public.contracts_id_seq'::regclass);


--
-- Name: maintenance id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance ALTER COLUMN id SET DEFAULT nextval('public.maintenance_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);


--
-- Name: rooms id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms ALTER COLUMN id SET DEFAULT nextval('public.rooms_id_seq'::regclass);


--
-- Name: tenants id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenants ALTER COLUMN id SET DEFAULT nextval('public.tenants_id_seq'::regclass);


--
-- Name: user_announcement_reads id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_announcement_reads ALTER COLUMN id SET DEFAULT nextval('public.user_announcement_reads_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: announcements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.announcements (id, judul, konten, kategori, prioritas, target, created_by, is_active, created_at, updated_at) FROM stdin;
1	Pembayaran Bulan Maret	Mohon untuk segera melakukan pembayaran kos bulan Maret paling lambat tanggal 10 Maret 2024	Pembayaran	penting	tenant	1	t	2026-05-21 20:20:24.72276	2026-05-21 20:20:24.72276
2	Pemadaman Listrik	Akan ada pemadaman listrik pada hari Minggu, 10 Maret 2024 pukul 08:00 - 12:00 WIB	Informasi	urgent	semua	1	t	2026-05-21 20:20:24.72276	2026-05-21 20:20:24.72276
3	Jadwal Kebersihan	Jadwal pembersihan area umum setiap hari Senin dan Kamis pukul 09:00 WIB	Informasi	info	semua	1	t	2026-05-21 20:20:24.72276	2026-05-21 20:20:24.72276
4	Pembayaran Bulan Maret	Mohon untuk segera melakukan pembayaran kos bulan Maret paling lambat tanggal 10 Maret 2024	Pembayaran	penting	tenant	1	t	2026-05-21 20:28:41.209748	2026-05-21 20:28:41.209748
5	Pemadaman Listrik	Akan ada pemadaman listrik pada hari Minggu, 10 Maret 2024 pukul 08:00 - 12:00 WIB	Informasi	urgent	semua	1	t	2026-05-21 20:28:41.209748	2026-05-21 20:28:41.209748
6	Jadwal Kebersihan	Jadwal pembersihan area umum setiap hari Senin dan Kamis pukul 09:00 WIB	Informasi	info	semua	1	t	2026-05-21 20:28:41.209748	2026-05-21 20:28:41.209748
7	Pembayaran Bulan Juni	Mohon segera melakukan pembayaran untuk bulan Juni paling lambat tanggal 10 Juni 2026	Pembayaran	penting	semua	1	t	2026-05-26 13:35:44.221003	2026-05-26 13:35:44.221003
8	ADA DONAT DI RUANG TAMU	ambil 1 orang 1	Umum	info	semua	1	t	2026-06-03 19:29:58.380362	2026-06-03 19:29:58.380362
9	ada gorengan di ruang tamu	ambil 1 orang 2 	Umum	info	semua	1	t	2026-06-03 19:41:48.78574	2026-06-03 19:41:48.78574
10	ada jco di ruan tamu	wowowowasada	Umum	info	semua	1	t	2026-06-03 19:42:33.178517	2026-06-03 19:42:33.178517
11	ada kopi di bwah boleh ambil cepet cepetan	daiwodadaadoaad	Umum	info	semua	1	t	2026-06-03 19:51:53.958476	2026-06-03 19:51:53.958476
12	ADA PIZZA BAGI" REBUTAN DIBAWAH	GASFGAGASGSAGA	Umum	info	semua	1	t	2026-06-03 20:36:37.297128	2026-06-03 20:36:37.297128
13	ada bolu dibawah rebutn	gasgasasggasasgagasggag	Umum	info	semua	1	t	2026-06-03 21:05:17.30803	2026-06-03 21:05:17.30803
14	haloo ada pisang gorteng d bwah	asfsadasddasdasd	Umum	info	semua	1	t	2026-06-03 21:16:35.857711	2026-06-03 21:16:35.857711
15	halo adadassdasdadadasdad	asdadasdsadadad	Umum	info	semua	1	t	2026-06-03 21:16:55.75916	2026-06-03 21:16:55.75916
16	gigggigigiu	jibhibhuihbib	Umum	info	semua	1	t	2026-06-03 21:18:06.183016	2026-06-03 21:18:06.183016
17	giggiuigiygggiibb	byuvtuvftyftyft	Umum	info	semua	1	t	2026-06-03 21:19:31.176869	2026-06-03 21:19:31.176869
18	ubhububuoj	iubhuihbububui	Umum	info	semua	1	t	2026-06-03 21:20:02.060939	2026-06-03 21:20:02.060939
19	ugghhhhhh	iyvgbyibvhyibb	Umum	info	semua	1	t	2026-06-03 21:20:58.146309	2026-06-03 21:20:58.146309
20	alamaakalamaakalamaak	asdasdasdadasda	Umum	info	semua	1	t	2026-06-03 21:23:32.76622	2026-06-03 21:23:32.76622
21	ada dadging qurban d ruang tamu bagi"	ajdasndaddd	Umum	info	semua	1	t	2026-06-03 23:26:21.246971	2026-06-03 23:26:21.246971
22	ADA QURBAN LAGI LEK	SADSADASDADASDS	Umum	info	semua	1	t	2026-06-03 23:32:33.49457	2026-06-03 23:32:33.49457
23	rapat kosan 5 menit ke bwah	awwwwwwwwwwwwwwwwwwwwwwwwwwww	Umum	info	semua	1	t	2026-06-03 23:42:12.219109	2026-06-03 23:42:12.219109
24	ADA MAKANAN 	dibawah ada donat jco rebutan yang cpt dapat	Umum	info	semua	1	t	2026-06-04 04:39:38.243296	2026-06-04 04:39:38.243296
25	KEBAKARAN	KABURRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR	Umum	urgent	semua	1	t	2026-06-04 06:15:35.735469	2026-06-04 06:15:35.735469
\.


--
-- Data for Name: bills; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bills (id, tenant_id, contract_id, bulan, tahun, jumlah, status, jatuh_tempo, denda, catatan, created_at, updated_at) FROM stdin;
135	6	\N	April	2026	1500000.00	terlambat	2026-05-24	0.00	Tagihan periode 24 April - 23 Mei 2026	2026-06-03 19:18:06.554356	2026-06-03 19:18:06.554356
140	5	\N	Mei	2026	2000002.00	belum_lunas	2026-06-13	0.00	Tagihan periode 13 Mei - 12 Juni 2026	2026-06-03 19:18:06.568918	2026-06-03 19:18:06.568918
141	7	\N	April	2026	2000000.00	terlambat	2026-05-09	0.00	Tagihan periode 9 April - 8 Mei 2026	2026-06-03 19:18:06.571066	2026-06-03 19:18:06.571066
142	7	\N	Mei	2026	2000000.00	belum_lunas	2026-06-09	0.00	Tagihan periode 9 Mei - 8 Juni 2026	2026-06-03 19:18:06.571066	2026-06-03 19:18:06.571066
139	5	\N	April	2026	2000002.00	lunas	2026-05-13	0.00	Tagihan periode 13 April - 12 Mei 2026	2026-06-03 19:18:06.568918	2026-06-03 19:28:16.587791
137	8	\N	April	2026	2500000.00	lunas	2026-05-16	0.00	Tagihan periode 16 April - 15 Mei 2026	2026-06-03 19:18:06.566134	2026-06-03 22:13:40.068603
138	8	\N	Mei	2026	2500000.00	lunas	2026-06-16	0.00	Tagihan periode 16 Mei - 15 Juni 2026	2026-06-03 19:18:06.566134	2026-06-03 23:40:43.072402
143	6	\N	Juni	2024	1500000.00	terlambat	2024-06-10	0.00	\N	2026-06-04 05:18:38.535113	2026-06-04 05:59:34.162618
144	7	\N	Juni	2024	2000000.00	terlambat	2024-06-10	0.00	\N	2026-06-04 05:18:38.535113	2026-06-04 05:59:34.162618
145	8	\N	Juni	2024	2500000.00	terlambat	2024-06-10	0.00	\N	2026-06-04 05:18:38.535113	2026-06-04 05:59:34.162618
146	5	\N	Juni	2024	2000002.00	terlambat	2024-06-10	0.00	\N	2026-06-04 05:18:38.535113	2026-06-04 05:59:34.162618
147	13	\N	Juni	2024	1500000.00	terlambat	2024-06-10	0.00	\N	2026-06-04 05:18:38.535113	2026-06-04 05:59:34.162618
136	6	\N	Mei	2026	1500000.00	lunas	2026-06-24	0.00	Tagihan periode 24 Mei - 23 Juni 2026	2026-06-03 19:18:06.554356	2026-06-04 06:09:42.030746
\.


--
-- Data for Name: contracts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.contracts (id, tenant_id, kamar_id, tanggal_mulai, tanggal_selesai, harga_per_bulan, deposit, status, catatan, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: maintenance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.maintenance (id, tenant_id, kamar_id, judul, deskripsi, kategori, prioritas, status, foto, tanggal_lapor, tanggal_selesai, komentar_admin, biaya, created_at, updated_at) FROM stdin;
7	6	2	AC tidak dingin	AC di kamar sudah 2 hari tidak dingin, mohon diperbaiki	AC	tinggi	baru	\N	2026-05-26	\N	\N	\N	2026-05-26 13:24:28.524545	2026-05-26 13:26:01.88099
8	5	1	Atap bocor	bocor pak bagusinndong	Pintu/Jendela	tinggi	selesai	\N	2026-06-03	2026-06-03	\N	\N	2026-06-03 18:50:34.193868	2026-06-03 18:52:02.602838
9	8	6	ada musang di kasur	toolongggggggg	Lainnya	urgent	diproses	\N	2026-06-03	\N	\N	\N	2026-06-03 22:12:17.563454	2026-06-03 22:12:36.1608
10	5	1	Gada sinyal	pak gada singal ini knapa	Lainnya	urgent	selesai	\N	2026-06-03	2026-06-03	\N	\N	2026-06-03 23:24:58.473662	2026-06-03 23:25:26.971444
11	6	2	HEWAN	Ada harimau masuk kamar	Lainnya	sedang	diproses	\N	2026-06-04	\N	\N	\N	2026-06-04 06:03:49.830885	2026-06-04 06:04:08.524646
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (id, user_id, title, message, type, related_id, is_read, created_at, updated_at) FROM stdin;
3	4	📢 Pengumuman Baru	ADA PIZZA BAGI" REBUTAN DIBAWAH	announcement	12	f	2026-06-03 20:36:37.299947	2026-06-03 20:36:37.299947
7	4	📢 Pengumuman Baru	ada bolu dibawah rebutn	announcement	13	f	2026-06-03 21:05:17.310302	2026-06-03 21:05:17.310302
11	4	📢 Pengumuman Baru	haloo ada pisang gorteng d bwah	announcement	14	f	2026-06-03 21:16:35.880851	2026-06-03 21:16:35.880851
15	4	📢 Pengumuman Baru	halo adadassdasdadadasdad	announcement	15	f	2026-06-03 21:16:55.760788	2026-06-03 21:16:55.760788
19	4	📢 Pengumuman Baru	gigggigigiu	announcement	16	f	2026-06-03 21:18:06.185555	2026-06-03 21:18:06.185555
13	2	📢 Pengumuman Baru	halo adadassdasdadadasdad	announcement	15	t	2026-06-03 21:16:55.760788	2026-06-03 21:18:22.439223
23	4	📢 Pengumuman Baru	giggiuigiygggiibb	announcement	17	f	2026-06-03 21:19:31.178301	2026-06-03 21:19:31.178301
27	4	📢 Pengumuman Baru	ubhububuoj	announcement	18	f	2026-06-03 21:20:02.062129	2026-06-03 21:20:02.062129
31	4	📢 Pengumuman Baru	ugghhhhhh	announcement	19	f	2026-06-03 21:20:58.149301	2026-06-03 21:20:58.149301
35	4	📢 Pengumuman Baru	alamaakalamaakalamaak	announcement	20	f	2026-06-03 21:23:32.769329	2026-06-03 21:23:32.769329
1	2	📢 Pengumuman Baru	ADA PIZZA BAGI" REBUTAN DIBAWAH	announcement	12	t	2026-06-03 20:36:37.299947	2026-06-03 23:24:19.222551
5	2	📢 Pengumuman Baru	ada bolu dibawah rebutn	announcement	13	t	2026-06-03 21:05:17.310302	2026-06-03 23:24:19.222551
9	2	📢 Pengumuman Baru	haloo ada pisang gorteng d bwah	announcement	14	t	2026-06-03 21:16:35.880851	2026-06-03 23:24:19.222551
17	2	📢 Pengumuman Baru	gigggigigiu	announcement	16	t	2026-06-03 21:18:06.185555	2026-06-03 23:24:19.222551
21	2	📢 Pengumuman Baru	giggiuigiygggiibb	announcement	17	t	2026-06-03 21:19:31.178301	2026-06-03 23:24:19.222551
25	2	📢 Pengumuman Baru	ubhububuoj	announcement	18	t	2026-06-03 21:20:02.062129	2026-06-03 23:24:19.222551
29	2	📢 Pengumuman Baru	ugghhhhhh	announcement	19	t	2026-06-03 21:20:58.149301	2026-06-03 23:24:19.222551
33	2	📢 Pengumuman Baru	alamaakalamaakalamaak	announcement	20	t	2026-06-03 21:23:32.769329	2026-06-03 23:24:19.222551
37	2	Keluhan: Gada sinyal	Laporan keluhan Anda sedang diproses oleh admin	maintenance	10	f	2026-06-03 23:25:15.99688	2026-06-03 23:25:15.99688
41	4	📢 Pengumuman Baru	ada dadging qurban d ruang tamu bagi"	announcement	21	f	2026-06-03 23:26:21.250443	2026-06-03 23:26:21.250443
43	14	📢 Pengumuman Baru	ada dadging qurban d ruang tamu bagi"	announcement	21	f	2026-06-03 23:26:21.250443	2026-06-03 23:26:21.250443
8	5	📢 Pengumuman Baru	ada bolu dibawah rebutn	announcement	13	t	2026-06-03 21:05:17.310302	2026-06-03 23:39:48.398943
12	5	📢 Pengumuman Baru	haloo ada pisang gorteng d bwah	announcement	14	t	2026-06-03 21:16:35.880851	2026-06-03 23:39:48.398943
16	5	📢 Pengumuman Baru	halo adadassdasdadadasdad	announcement	15	t	2026-06-03 21:16:55.760788	2026-06-03 23:39:48.398943
20	5	📢 Pengumuman Baru	gigggigigiu	announcement	16	t	2026-06-03 21:18:06.185555	2026-06-03 23:39:48.398943
24	5	📢 Pengumuman Baru	giggiuigiygggiibb	announcement	17	t	2026-06-03 21:19:31.178301	2026-06-03 23:39:48.398943
28	5	📢 Pengumuman Baru	ubhububuoj	announcement	18	t	2026-06-03 21:20:02.062129	2026-06-03 23:39:48.398943
32	5	📢 Pengumuman Baru	ugghhhhhh	announcement	19	t	2026-06-03 21:20:58.149301	2026-06-03 23:39:48.398943
36	5	📢 Pengumuman Baru	alamaakalamaakalamaak	announcement	20	t	2026-06-03 21:23:32.769329	2026-06-03 23:39:48.398943
42	5	📢 Pengumuman Baru	ada dadging qurban d ruang tamu bagi"	announcement	21	t	2026-06-03 23:26:21.250443	2026-06-03 23:39:48.398943
45	5	Pembayaran Diverifikasi	Pembayaran Anda sebesar Rp 2.500.000 telah diverifikasi oleh admin.	payment	16	t	2026-06-03 23:40:43.147747	2026-06-03 23:40:48.029357
39	2	📢 Pengumuman Baru	ada dadging qurban d ruang tamu bagi"	announcement	21	t	2026-06-03 23:26:21.250443	2026-06-03 23:41:44.613795
38	2	Keluhan: Gada sinyal	Laporan keluhan Anda telah selesai ditangani	maintenance	10	t	2026-06-03 23:25:26.981058	2026-06-03 23:42:21.044888
2	3	📢 Pengumuman Baru	ADA PIZZA BAGI" REBUTAN DIBAWAH	announcement	12	t	2026-06-03 20:36:37.299947	2026-06-04 06:13:13.771777
6	3	📢 Pengumuman Baru	ada bolu dibawah rebutn	announcement	13	t	2026-06-03 21:05:17.310302	2026-06-04 06:13:13.771777
10	3	📢 Pengumuman Baru	haloo ada pisang gorteng d bwah	announcement	14	t	2026-06-03 21:16:35.880851	2026-06-04 06:13:13.771777
14	3	📢 Pengumuman Baru	halo adadassdasdadadasdad	announcement	15	t	2026-06-03 21:16:55.760788	2026-06-04 06:13:13.771777
18	3	📢 Pengumuman Baru	gigggigigiu	announcement	16	t	2026-06-03 21:18:06.185555	2026-06-04 06:13:13.771777
22	3	📢 Pengumuman Baru	giggiuigiygggiibb	announcement	17	t	2026-06-03 21:19:31.178301	2026-06-04 06:13:13.771777
26	3	📢 Pengumuman Baru	ubhububuoj	announcement	18	t	2026-06-03 21:20:02.062129	2026-06-04 06:13:13.771777
30	3	📢 Pengumuman Baru	ugghhhhhh	announcement	19	t	2026-06-03 21:20:58.149301	2026-06-04 06:13:13.771777
34	3	📢 Pengumuman Baru	alamaakalamaakalamaak	announcement	20	t	2026-06-03 21:23:32.769329	2026-06-04 06:13:13.771777
40	3	📢 Pengumuman Baru	ada dadging qurban d ruang tamu bagi"	announcement	21	t	2026-06-03 23:26:21.250443	2026-06-04 06:13:13.771777
44	16	📢 Pengumuman Baru	ada dadging qurban d ruang tamu bagi"	announcement	21	t	2026-06-03 23:26:21.250443	2026-06-04 06:16:00.191752
46	3	Keluhan: HEWAN	Laporan keluhan Anda sedang diproses oleh admin	maintenance	11	t	2026-06-04 06:04:08.526443	2026-06-04 06:13:13.771777
47	3	Pembayaran Diverifikasi	Pembayaran Anda sebesar Rp 1.500.000 telah diverifikasi oleh admin.	payment	21	t	2026-06-04 06:09:35.086339	2026-06-04 06:13:13.771777
48	3	Pembayaran Diverifikasi	Pembayaran Anda sebesar Rp 1.500.000 telah diverifikasi oleh admin.	payment	20	t	2026-06-04 06:09:42.040559	2026-06-04 06:13:13.771777
49	3	Pembayaran Ditolak	Pembayaran sebesar Rp 1.500.000 ditolak. Alasan: Pembayaran ditolak oleh admin	payment	19	t	2026-06-04 06:09:47.762324	2026-06-04 06:13:13.771777
50	3	Pembayaran Ditolak	Pembayaran sebesar Rp 1.500.000 ditolak. Alasan: Pembayaran ditolak oleh admin	payment	18	t	2026-06-04 06:09:51.592016	2026-06-04 06:13:13.771777
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payments (id, bill_id, tenant_id, jumlah, tanggal_bayar, metode_pembayaran, bukti_pembayaran, status, keterangan, verified_by, verified_at, created_at, updated_at) FROM stdin;
14	139	5	2000002.00	2026-06-03	E-Wallet	/path/to/image.jpg	lunas	Pembayaran telah diverifikasi	1	2026-06-03 19:28:16.587791	2026-06-03 19:27:26.764087	2026-06-03 19:28:16.587791
15	137	8	2500000.00	2026-06-03	Transfer Bank	/path/to/image.jpg	lunas	Pembayaran telah diverifikasi	1	2026-06-03 22:13:40.068603	2026-06-03 22:13:23.321756	2026-06-03 22:13:40.068603
16	138	8	2500000.00	2026-06-03	Transfer Bank	/path/to/image.jpg	lunas	Pembayaran telah diverifikasi	1	2026-06-03 23:40:43.072402	2026-06-03 23:40:23.013413	2026-06-03 23:40:43.072402
17	136	6	1500000.00	2026-06-04	Transfer Bank	\N	menunggu_verifikasi	udahhhh	\N	\N	2026-06-04 06:02:02.788624	2026-06-04 06:02:02.788624
21	136	6	1500000.00	2026-06-04	Transfer Bank	\N	lunas	Pembayaran telah diverifikasi	1	2026-06-04 06:09:35.02752	2026-06-04 06:08:51.210338	2026-06-04 06:09:35.02752
20	136	6	1500000.00	2026-06-04	Transfer Bank	\N	lunas	Pembayaran telah diverifikasi	1	2026-06-04 06:09:42.030746	2026-06-04 06:05:25.474815	2026-06-04 06:09:42.030746
19	136	6	1500000.00	2026-06-04	Transfer Bank	\N	ditolak	Pembayaran ditolak oleh admin	1	2026-06-04 06:09:47.752332	2026-06-04 06:03:03.84873	2026-06-04 06:09:47.752332
18	136	6	1500000.00	2026-06-04	Transfer Bank	\N	ditolak	Pembayaran ditolak oleh admin	1	2026-06-04 06:09:51.590789	2026-06-04 06:02:16.255739	2026-06-04 06:09:51.590789
\.


--
-- Data for Name: rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rooms (id, nomor_kamar, tipe, harga, status, deskripsi, fasilitas, foto, created_at, updated_at) FROM stdin;
2	A2	Standard	1500000.00	terisi	Kamar nyaman dengan AC	["AC", "Kasur", "Lemari", "Meja Belajar"]	\N	2026-05-21 20:20:24.72276	2026-05-21 20:20:24.72276
4	B1	Deluxe	2000000.00	terisi	Kamar mewah dengan kamar mandi dalam	["AC", "Kasur", "Lemari", "Meja Belajar", "Kamar Mandi Dalam", "TV"]	\N	2026-05-21 20:20:24.72276	2026-05-21 20:20:24.72276
5	B2	Deluxe	2000000.00	kosong	Kamar mewah dengan kamar mandi dalam	["AC", "Kasur", "Lemari", "Meja Belajar", "Kamar Mandi Dalam", "TV"]	\N	2026-05-21 20:20:24.72276	2026-05-21 20:20:24.72276
6	C1	Premium	2500000.00	terisi	Kamar premium dengan balkon	["AC", "Kasur", "Lemari", "Meja Belajar", "Kamar Mandi Dalam", "TV", "Balkon", "Kulkas"]	\N	2026-05-21 20:20:24.72276	2026-05-21 20:20:24.72276
7	C2	Premium	2500000.00	kosong	Kamar premium dengan balkon	["AC", "Kasur", "Lemari", "Meja Belajar", "Kamar Mandi Dalam", "TV", "Balkon", "Kulkas"]	\N	2026-05-21 20:20:24.72276	2026-05-21 20:20:24.72276
8	D1	Standard	1500000.00	kosong	Kamar nyaman dengan AC	["AC", "Kasur", "Lemari", "Meja Belajar"]	\N	2026-05-21 20:20:24.72276	2026-05-21 20:20:24.72276
1	A1	Standard	2000002.00	terisi	Kamar nyaman dengan AC	["AC", "Kasur", "Lemari", "Meja Belajar"]	\N	2026-05-21 20:20:24.72276	2026-05-26 12:14:08.224773
3	A3	Standard	1500000.00	terisi	Kamar nyaman dengan AC	["AC", "Kasur", "Lemari", "Meja Belajar"]	\N	2026-05-21 20:20:24.72276	2026-06-03 22:43:44.081398
17	666	VIP	999999999.00	kosong	kamar spesial 	["AC", "Lemari", "Dapur Bersama", "CCTV", "Security 24 Jam", "Kasur", "WiFi", "Kamar Mandi Dalam", "Kamar Mandi Luar", "Meja Belajar", "Parkir Motor", "Kursi", "Parkir Mobil", "TV", "Kulkas", "Laundry"]	\N	2026-06-03 22:46:08.734737	2026-06-03 22:46:08.734737
19	21312312	VIP	999999999.00	kosong	asdadasd	["Kasur"]	\N	2026-06-03 22:48:07.145989	2026-06-03 22:48:07.145989
\.


--
-- Data for Name: tenants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tenants (id, user_id, kamar_id, nama, email, no_telepon, alamat_asal, pekerjaan, kontak_darurat, tanggal_masuk, tanggal_keluar, status, created_at, updated_at) FROM stdin;
6	3	2	Ani Wijaya	ani@email.com	081234567892	Bandung	Mahasiswa	081234567802	2026-04-24	\N	aktif	2026-05-21 20:28:41.209748	2026-05-21 20:28:41.209748
8	5	6	Doni Pratama	doni@email.com	081234567894	Yogyakarta	Karyawan Swasta	081234567804	2026-04-16	\N	aktif	2026-05-21 20:28:41.209748	2026-05-21 20:28:41.209748
5	2	1	Budi Santoso	budi@email.com	08123456789123				2026-04-13	\N	aktif	2026-05-21 20:28:41.209748	2026-05-26 12:30:56.451444
7	4	4	Citra Dewa	citra@email.com	081234567893	Surabaya	Freelancer	081234567803	2026-04-09	\N	aktif	2026-05-21 20:28:41.209748	2026-06-01 21:57:14.410456
13	16	3	vanow	vano@email.com	08123454321	bebas	Mahasiswa	08888888	2026-06-03	\N	aktif	2026-06-03 22:43:44.081398	2026-06-03 22:43:44.081398
\.


--
-- Data for Name: user_announcement_reads; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_announcement_reads (id, user_id, announcement_id, read_at) FROM stdin;
1	2	2	2026-06-03 20:06:48.520449
2	2	6	2026-06-03 22:03:30.931091
3	5	6	2026-06-03 22:14:46.598009
5	2	22	2026-06-03 23:33:00.67139
6	5	23	2026-06-03 23:46:18.762649
9	2	7	2026-06-04 01:45:25.186374
10	2	4	2026-06-04 01:46:23.856858
11	2	23	2026-06-04 01:54:53.042088
14	2	9	2026-06-04 01:55:36.278522
15	2	11	2026-06-04 01:55:38.631549
17	2	15	2026-06-04 02:03:08.328023
20	2	5	2026-06-04 02:03:25.427786
27	2	17	2026-06-04 02:21:48.525646
36	2	8	2026-06-04 02:50:28.576212
38	2	12	2026-06-04 03:09:44.2527
43	2	10	2026-06-04 03:12:00.264989
44	2	13	2026-06-04 03:12:04.797958
45	2	21	2026-06-04 03:12:07.019558
59	2	24	2026-06-04 04:40:02.276531
61	2	18	2026-06-04 04:40:13.036505
63	3	19	2026-06-04 06:12:34.528963
64	3	24	2026-06-04 06:12:36.717461
65	3	7	2026-06-04 06:12:40.91863
66	3	6	2026-06-04 06:12:58.697308
67	3	5	2026-06-04 06:13:24.60455
68	16	6	2026-06-04 06:14:57.909629
69	16	22	2026-06-04 06:14:59.001515
70	16	24	2026-06-04 06:15:02.258711
71	16	23	2026-06-04 06:15:03.551639
72	2	25	2026-06-04 06:40:07.829974
76	3	25	2026-06-04 06:50:24.783825
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, password, nama, role, no_telepon, foto, created_at, updated_at) FROM stdin;
2	budi@email.com	$2a$10$EbLRKqHcWhKZHOal.7dEQOyKJkwjrJlbUQ07L7d42ungR7ZOwV.Sy	Budi Santoso	tenant	081234567891	\N	2026-05-21 20:20:24.72276	2026-05-21 20:20:24.72276
3	ani@email.com	$2a$10$EbLRKqHcWhKZHOal.7dEQOyKJkwjrJlbUQ07L7d42ungR7ZOwV.Sy	Ani Wijaya	tenant	081234567892	\N	2026-05-21 20:20:24.72276	2026-05-21 20:20:24.72276
4	citra@email.com	$2a$10$EbLRKqHcWhKZHOal.7dEQOyKJkwjrJlbUQ07L7d42ungR7ZOwV.Sy	Citra Dewi	tenant	081234567893	\N	2026-05-21 20:20:24.72276	2026-05-21 20:20:24.72276
5	doni@email.com	$2a$10$EbLRKqHcWhKZHOal.7dEQOyKJkwjrJlbUQ07L7d42ungR7ZOwV.Sy	Doni Pratama	tenant	081234567894	\N	2026-05-21 20:20:24.72276	2026-05-21 20:20:24.72276
1	admingila@kosterpadu.com	$2a$10$wYwfyl4qTtznpsJDojY1Wuc3y33gAVILO2RIRYs.gygs.wm8/bERG	Admin Kos gorga	admin	0858838716651	\N	2026-05-21 20:20:24.72276	2026-05-26 00:19:36.910646
14	aksa@email.com	$2a$10$C7xEmNjCCNJB/tXQY72wDuCQdq6RdnT2DRDLFI4AFg8Nk.dPSbT9a	Aksa D	tenant	081245784512	\N	2026-06-03 22:19:13.83468	2026-06-03 22:19:13.83468
16	vano@email.com	$2a$10$NM/UxHQFLSgWLVcaGlb1Fe324rD.8wR/WqlAZNeO2mewamykmtxPW	vanow	tenant	08123454321	\N	2026-06-03 22:43:44.070203	2026-06-03 22:43:44.070203
\.


--
-- Name: announcements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.announcements_id_seq', 25, true);


--
-- Name: bills_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bills_id_seq', 147, true);


--
-- Name: contracts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.contracts_id_seq', 8, true);


--
-- Name: maintenance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.maintenance_id_seq', 11, true);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notifications_id_seq', 50, true);


--
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payments_id_seq', 21, true);


--
-- Name: rooms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rooms_id_seq', 19, true);


--
-- Name: tenants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tenants_id_seq', 13, true);


--
-- Name: user_announcement_reads_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_announcement_reads_id_seq', 80, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 16, true);


--
-- Name: announcements announcements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_pkey PRIMARY KEY (id);


--
-- Name: bills bills_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bills
    ADD CONSTRAINT bills_pkey PRIMARY KEY (id);


--
-- Name: bills bills_tenant_id_bulan_tahun_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bills
    ADD CONSTRAINT bills_tenant_id_bulan_tahun_key UNIQUE (tenant_id, bulan, tahun);


--
-- Name: contracts contracts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT contracts_pkey PRIMARY KEY (id);


--
-- Name: maintenance maintenance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance
    ADD CONSTRAINT maintenance_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: rooms rooms_nomor_kamar_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_nomor_kamar_key UNIQUE (nomor_kamar);


--
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (id);


--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (id);


--
-- Name: user_announcement_reads user_announcement_reads_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_announcement_reads
    ADD CONSTRAINT user_announcement_reads_pkey PRIMARY KEY (id);


--
-- Name: user_announcement_reads user_announcement_reads_user_id_announcement_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_announcement_reads
    ADD CONSTRAINT user_announcement_reads_user_id_announcement_id_key UNIQUE (user_id, announcement_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_announcements_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_is_active ON public.announcements USING btree (is_active);


--
-- Name: idx_announcements_target; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_target ON public.announcements USING btree (target);


--
-- Name: idx_bills_bulan_tahun; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_bills_bulan_tahun ON public.bills USING btree (bulan, tahun);


--
-- Name: idx_bills_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_bills_status ON public.bills USING btree (status);


--
-- Name: idx_bills_tenant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_bills_tenant_id ON public.bills USING btree (tenant_id);


--
-- Name: idx_contracts_kamar_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_contracts_kamar_id ON public.contracts USING btree (kamar_id);


--
-- Name: idx_contracts_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_contracts_status ON public.contracts USING btree (status);


--
-- Name: idx_contracts_tenant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_contracts_tenant_id ON public.contracts USING btree (tenant_id);


--
-- Name: idx_maintenance_kamar_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_maintenance_kamar_id ON public.maintenance USING btree (kamar_id);


--
-- Name: idx_maintenance_prioritas; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_maintenance_prioritas ON public.maintenance USING btree (prioritas);


--
-- Name: idx_maintenance_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_maintenance_status ON public.maintenance USING btree (status);


--
-- Name: idx_maintenance_tenant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_maintenance_tenant_id ON public.maintenance USING btree (tenant_id);


--
-- Name: idx_notifications_is_read; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notifications_is_read ON public.notifications USING btree (is_read);


--
-- Name: idx_notifications_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notifications_user_id ON public.notifications USING btree (user_id);


--
-- Name: idx_payments_bill_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_payments_bill_id ON public.payments USING btree (bill_id);


--
-- Name: idx_payments_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_payments_status ON public.payments USING btree (status);


--
-- Name: idx_payments_tenant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_payments_tenant_id ON public.payments USING btree (tenant_id);


--
-- Name: idx_rooms_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rooms_status ON public.rooms USING btree (status);


--
-- Name: idx_tenants_kamar_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tenants_kamar_id ON public.tenants USING btree (kamar_id);


--
-- Name: idx_tenants_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tenants_status ON public.tenants USING btree (status);


--
-- Name: idx_tenants_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tenants_user_id ON public.tenants USING btree (user_id);


--
-- Name: idx_user_announcement_reads_announcement; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_announcement_reads_announcement ON public.user_announcement_reads USING btree (announcement_id);


--
-- Name: idx_user_announcement_reads_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_announcement_reads_user ON public.user_announcement_reads USING btree (user_id);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- Name: idx_users_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_role ON public.users USING btree (role);


--
-- Name: announcements announcements_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: bills bills_contract_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bills
    ADD CONSTRAINT bills_contract_id_fkey FOREIGN KEY (contract_id) REFERENCES public.contracts(id) ON DELETE CASCADE;


--
-- Name: bills bills_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bills
    ADD CONSTRAINT bills_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: contracts contracts_kamar_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT contracts_kamar_id_fkey FOREIGN KEY (kamar_id) REFERENCES public.rooms(id) ON DELETE CASCADE;


--
-- Name: contracts contracts_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT contracts_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: maintenance maintenance_kamar_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance
    ADD CONSTRAINT maintenance_kamar_id_fkey FOREIGN KEY (kamar_id) REFERENCES public.rooms(id) ON DELETE CASCADE;


--
-- Name: maintenance maintenance_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance
    ADD CONSTRAINT maintenance_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: payments payments_bill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_bill_id_fkey FOREIGN KEY (bill_id) REFERENCES public.bills(id) ON DELETE CASCADE;


--
-- Name: payments payments_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: payments payments_verified_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_verified_by_fkey FOREIGN KEY (verified_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: tenants tenants_kamar_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_kamar_id_fkey FOREIGN KEY (kamar_id) REFERENCES public.rooms(id) ON DELETE SET NULL;


--
-- Name: tenants tenants_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_announcement_reads user_announcement_reads_announcement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_announcement_reads
    ADD CONSTRAINT user_announcement_reads_announcement_id_fkey FOREIGN KEY (announcement_id) REFERENCES public.announcements(id) ON DELETE CASCADE;


--
-- Name: user_announcement_reads user_announcement_reads_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_announcement_reads
    ADD CONSTRAINT user_announcement_reads_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict y5fZxJxMyJFgmnH1uOgBiXCkWvcCRAe876bLr6ct1IuNNeB9mRfP6ixi305zxjE

