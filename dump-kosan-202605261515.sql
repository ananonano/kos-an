--
-- PostgreSQL database dump
--

\restrict CS05WANXBvvNiGOWnlaAXObjtQM3JZqcJs4i5YaEkX3a04o168cPR0MMAJEVQz5

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

-- Started on 2026-05-26 15:15:33

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
-- TOC entry 234 (class 1259 OID 16583)
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
    CONSTRAINT announcements_prioritas_check CHECK (((prioritas)::text = ANY ((ARRAY['info'::character varying, 'penting'::character varying, 'urgent'::character varying])::text[]))),
    CONSTRAINT announcements_target_check CHECK (((target)::text = ANY ((ARRAY['semua'::character varying, 'tenant'::character varying, 'admin'::character varying])::text[])))
);


ALTER TABLE public.announcements OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16582)
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
-- TOC entry 5161 (class 0 OID 0)
-- Dependencies: 233
-- Name: announcements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.announcements_id_seq OWNED BY public.announcements.id;


--
-- TOC entry 228 (class 1259 OID 16486)
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
    CONSTRAINT bills_status_check CHECK (((status)::text = ANY ((ARRAY['belum_lunas'::character varying, 'lunas'::character varying, 'terlambat'::character varying])::text[])))
);


ALTER TABLE public.bills OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16485)
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
-- TOC entry 5162 (class 0 OID 0)
-- Dependencies: 227
-- Name: bills_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bills_id_seq OWNED BY public.bills.id;


--
-- TOC entry 226 (class 1259 OID 16457)
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
    CONSTRAINT contracts_status_check CHECK (((status)::text = ANY ((ARRAY['aktif'::character varying, 'selesai'::character varying, 'dibatalkan'::character varying])::text[])))
);


ALTER TABLE public.contracts OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16456)
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
-- TOC entry 5163 (class 0 OID 0)
-- Dependencies: 225
-- Name: contracts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.contracts_id_seq OWNED BY public.contracts.id;


--
-- TOC entry 232 (class 1259 OID 16551)
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
    CONSTRAINT maintenance_prioritas_check CHECK (((prioritas)::text = ANY ((ARRAY['rendah'::character varying, 'sedang'::character varying, 'tinggi'::character varying, 'urgent'::character varying])::text[]))),
    CONSTRAINT maintenance_status_check CHECK (((status)::text = ANY ((ARRAY['baru'::character varying, 'diproses'::character varying, 'selesai'::character varying, 'ditolak'::character varying])::text[])))
);


ALTER TABLE public.maintenance OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16550)
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
-- TOC entry 5164 (class 0 OID 0)
-- Dependencies: 231
-- Name: maintenance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.maintenance_id_seq OWNED BY public.maintenance.id;


--
-- TOC entry 230 (class 1259 OID 16518)
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
    CONSTRAINT payments_status_check CHECK (((status)::text = ANY ((ARRAY['menunggu_verifikasi'::character varying, 'lunas'::character varying, 'ditolak'::character varying])::text[])))
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16517)
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
-- TOC entry 5165 (class 0 OID 0)
-- Dependencies: 229
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payments_id_seq OWNED BY public.payments.id;


--
-- TOC entry 222 (class 1259 OID 16409)
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
    CONSTRAINT rooms_status_check CHECK (((status)::text = ANY ((ARRAY['kosong'::character varying, 'terisi'::character varying])::text[])))
);


ALTER TABLE public.rooms OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16408)
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
-- TOC entry 5166 (class 0 OID 0)
-- Dependencies: 221
-- Name: rooms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rooms_id_seq OWNED BY public.rooms.id;


--
-- TOC entry 224 (class 1259 OID 16429)
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
    CONSTRAINT tenants_status_check CHECK (((status)::text = ANY ((ARRAY['aktif'::character varying, 'tidak_aktif'::character varying])::text[])))
);


ALTER TABLE public.tenants OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16428)
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
-- TOC entry 5167 (class 0 OID 0)
-- Dependencies: 223
-- Name: tenants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tenants_id_seq OWNED BY public.tenants.id;


--
-- TOC entry 220 (class 1259 OID 16389)
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
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['admin'::character varying, 'tenant'::character varying])::text[])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16388)
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
-- TOC entry 5168 (class 0 OID 0)
-- Dependencies: 219
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 4922 (class 2604 OID 16586)
-- Name: announcements id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcements ALTER COLUMN id SET DEFAULT nextval('public.announcements_id_seq'::regclass);


--
-- TOC entry 4908 (class 2604 OID 16489)
-- Name: bills id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bills ALTER COLUMN id SET DEFAULT nextval('public.bills_id_seq'::regclass);


--
-- TOC entry 4903 (class 2604 OID 16460)
-- Name: contracts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contracts ALTER COLUMN id SET DEFAULT nextval('public.contracts_id_seq'::regclass);


--
-- TOC entry 4917 (class 2604 OID 16554)
-- Name: maintenance id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance ALTER COLUMN id SET DEFAULT nextval('public.maintenance_id_seq'::regclass);


--
-- TOC entry 4913 (class 2604 OID 16521)
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);


--
-- TOC entry 4895 (class 2604 OID 16412)
-- Name: rooms id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms ALTER COLUMN id SET DEFAULT nextval('public.rooms_id_seq'::regclass);


--
-- TOC entry 4899 (class 2604 OID 16432)
-- Name: tenants id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenants ALTER COLUMN id SET DEFAULT nextval('public.tenants_id_seq'::regclass);


--
-- TOC entry 4891 (class 2604 OID 16392)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 5155 (class 0 OID 16583)
-- Dependencies: 234
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
\.


--
-- TOC entry 5149 (class 0 OID 16486)
-- Dependencies: 228
-- Data for Name: bills; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bills (id, tenant_id, contract_id, bulan, tahun, jumlah, status, jatuh_tempo, denda, catatan, created_at, updated_at) FROM stdin;
17	5	\N	Maret	2024	2000001.00	lunas	2024-03-10	0.00	\N	2026-05-26 01:19:33.970718	2026-05-26 11:19:17.627283
18	6	\N	Maret	2024	1500000.00	lunas	2024-03-10	0.00	\N	2026-05-26 01:19:33.970718	2026-05-26 12:25:56.412357
19	7	\N	Maret	2024	2000000.00	terlambat	2024-03-10	0.00	\N	2026-05-26 01:19:33.970718	2026-05-26 12:39:02.33799
20	8	\N	Maret	2024	2500000.00	terlambat	2024-03-10	0.00	\N	2026-05-26 01:19:33.970718	2026-05-26 12:39:02.33799
21	5	\N	Juni	2026	2000002.00	belum_lunas	2026-06-10	0.00	\N	2026-05-26 12:44:04.335788	2026-05-26 12:44:04.335788
22	6	\N	Juni	2026	1500000.00	belum_lunas	2026-06-10	0.00	\N	2026-05-26 12:44:04.335788	2026-05-26 12:44:04.335788
23	7	\N	Juni	2026	2000000.00	belum_lunas	2026-06-10	0.00	\N	2026-05-26 12:44:04.335788	2026-05-26 12:44:04.335788
24	8	\N	Juni	2026	2500000.00	belum_lunas	2026-06-10	0.00	\N	2026-05-26 12:44:04.335788	2026-05-26 12:44:04.335788
\.


--
-- TOC entry 5147 (class 0 OID 16457)
-- Dependencies: 226
-- Data for Name: contracts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.contracts (id, tenant_id, kamar_id, tanggal_mulai, tanggal_selesai, harga_per_bulan, deposit, status, catatan, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5153 (class 0 OID 16551)
-- Dependencies: 232
-- Data for Name: maintenance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.maintenance (id, tenant_id, kamar_id, judul, deskripsi, kategori, prioritas, status, foto, tanggal_lapor, tanggal_selesai, komentar_admin, biaya, created_at, updated_at) FROM stdin;
7	6	2	AC tidak dingin	AC di kamar sudah 2 hari tidak dingin, mohon diperbaiki	AC	tinggi	baru	\N	2026-05-26	\N	\N	\N	2026-05-26 13:24:28.524545	2026-05-26 13:26:01.88099
\.


--
-- TOC entry 5151 (class 0 OID 16518)
-- Dependencies: 230
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payments (id, bill_id, tenant_id, jumlah, tanggal_bayar, metode_pembayaran, bukti_pembayaran, status, keterangan, verified_by, verified_at, created_at, updated_at) FROM stdin;
10	17	5	2000001.00	2026-05-26	transfer	\N	lunas	Pembayaran diverifikasi	1	2026-05-26 11:19:17.627283	2026-05-26 11:08:06.398782	2026-05-26 11:19:17.627283
11	18	6	1500000.00	2026-05-26	cash	\N	ditolak	Bukti pembayaran tidak valid	1	2026-05-26 11:21:21.842366	2026-05-26 11:21:10.524399	2026-05-26 11:21:21.842366
12	18	6	1500000.00	2026-05-26	transfer	\N	lunas	Pembayaran diverifikasi - Test API	1	2026-05-26 12:25:56.412357	2026-05-26 12:25:56.38482	2026-05-26 12:25:56.412357
13	18	6	1500000.00	2026-05-26	cash	\N	ditolak	Bukti pembayaran tidak valid - Test API	1	2026-05-26 12:25:56.429499	2026-05-26 12:25:56.39469	2026-05-26 12:25:56.429499
\.


--
-- TOC entry 5143 (class 0 OID 16409)
-- Dependencies: 222
-- Data for Name: rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rooms (id, nomor_kamar, tipe, harga, status, deskripsi, fasilitas, foto, created_at, updated_at) FROM stdin;
2	A2	Standard	1500000.00	terisi	Kamar nyaman dengan AC	["AC", "Kasur", "Lemari", "Meja Belajar"]	\N	2026-05-21 20:20:24.72276	2026-05-21 20:20:24.72276
3	A3	Standard	1500000.00	kosong	Kamar nyaman dengan AC	["AC", "Kasur", "Lemari", "Meja Belajar"]	\N	2026-05-21 20:20:24.72276	2026-05-21 20:20:24.72276
4	B1	Deluxe	2000000.00	terisi	Kamar mewah dengan kamar mandi dalam	["AC", "Kasur", "Lemari", "Meja Belajar", "Kamar Mandi Dalam", "TV"]	\N	2026-05-21 20:20:24.72276	2026-05-21 20:20:24.72276
5	B2	Deluxe	2000000.00	kosong	Kamar mewah dengan kamar mandi dalam	["AC", "Kasur", "Lemari", "Meja Belajar", "Kamar Mandi Dalam", "TV"]	\N	2026-05-21 20:20:24.72276	2026-05-21 20:20:24.72276
6	C1	Premium	2500000.00	terisi	Kamar premium dengan balkon	["AC", "Kasur", "Lemari", "Meja Belajar", "Kamar Mandi Dalam", "TV", "Balkon", "Kulkas"]	\N	2026-05-21 20:20:24.72276	2026-05-21 20:20:24.72276
7	C2	Premium	2500000.00	kosong	Kamar premium dengan balkon	["AC", "Kasur", "Lemari", "Meja Belajar", "Kamar Mandi Dalam", "TV", "Balkon", "Kulkas"]	\N	2026-05-21 20:20:24.72276	2026-05-21 20:20:24.72276
8	D1	Standard	1500000.00	kosong	Kamar nyaman dengan AC	["AC", "Kasur", "Lemari", "Meja Belajar"]	\N	2026-05-21 20:20:24.72276	2026-05-21 20:20:24.72276
1	A1	Standard	2000002.00	terisi	Kamar nyaman dengan AC	["AC", "Kasur", "Lemari", "Meja Belajar"]	\N	2026-05-21 20:20:24.72276	2026-05-26 12:14:08.224773
\.


--
-- TOC entry 5145 (class 0 OID 16429)
-- Dependencies: 224
-- Data for Name: tenants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tenants (id, user_id, kamar_id, nama, email, no_telepon, alamat_asal, pekerjaan, kontak_darurat, tanggal_masuk, tanggal_keluar, status, created_at, updated_at) FROM stdin;
6	3	2	Ani Wijaya	ani@email.com	081234567892	Bandung	Mahasiswa	081234567802	2024-01-15	\N	aktif	2026-05-21 20:28:41.209748	2026-05-21 20:28:41.209748
7	4	4	Citra Dewi	citra@email.com	081234567893	Surabaya	Freelancer	081234567803	2024-02-01	\N	aktif	2026-05-21 20:28:41.209748	2026-05-21 20:28:41.209748
8	5	6	Doni Pratama	doni@email.com	081234567894	Yogyakarta	Karyawan Swasta	081234567804	2024-02-15	\N	aktif	2026-05-21 20:28:41.209748	2026-05-21 20:28:41.209748
5	2	1	Budi Santoso	budi@email.com	08123456789123				2023-12-31	\N	aktif	2026-05-21 20:28:41.209748	2026-05-26 12:30:56.451444
\.


--
-- TOC entry 5141 (class 0 OID 16389)
-- Dependencies: 220
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, password, nama, role, no_telepon, foto, created_at, updated_at) FROM stdin;
2	budi@email.com	$2a$10$EbLRKqHcWhKZHOal.7dEQOyKJkwjrJlbUQ07L7d42ungR7ZOwV.Sy	Budi Santoso	tenant	081234567891	\N	2026-05-21 20:20:24.72276	2026-05-21 20:20:24.72276
3	ani@email.com	$2a$10$EbLRKqHcWhKZHOal.7dEQOyKJkwjrJlbUQ07L7d42ungR7ZOwV.Sy	Ani Wijaya	tenant	081234567892	\N	2026-05-21 20:20:24.72276	2026-05-21 20:20:24.72276
4	citra@email.com	$2a$10$EbLRKqHcWhKZHOal.7dEQOyKJkwjrJlbUQ07L7d42ungR7ZOwV.Sy	Citra Dewi	tenant	081234567893	\N	2026-05-21 20:20:24.72276	2026-05-21 20:20:24.72276
5	doni@email.com	$2a$10$EbLRKqHcWhKZHOal.7dEQOyKJkwjrJlbUQ07L7d42ungR7ZOwV.Sy	Doni Pratama	tenant	081234567894	\N	2026-05-21 20:20:24.72276	2026-05-21 20:20:24.72276
1	admingila@kosterpadu.com	$2a$10$wYwfyl4qTtznpsJDojY1Wuc3y33gAVILO2RIRYs.gygs.wm8/bERG	Admin Kos gorga	admin	0858838716651	\N	2026-05-21 20:20:24.72276	2026-05-26 00:19:36.910646
\.


--
-- TOC entry 5169 (class 0 OID 0)
-- Dependencies: 233
-- Name: announcements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.announcements_id_seq', 7, true);


--
-- TOC entry 5170 (class 0 OID 0)
-- Dependencies: 227
-- Name: bills_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bills_id_seq', 24, true);


--
-- TOC entry 5171 (class 0 OID 0)
-- Dependencies: 225
-- Name: contracts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.contracts_id_seq', 8, true);


--
-- TOC entry 5172 (class 0 OID 0)
-- Dependencies: 231
-- Name: maintenance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.maintenance_id_seq', 7, true);


--
-- TOC entry 5173 (class 0 OID 0)
-- Dependencies: 229
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payments_id_seq', 13, true);


--
-- TOC entry 5174 (class 0 OID 0)
-- Dependencies: 221
-- Name: rooms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rooms_id_seq', 16, true);


--
-- TOC entry 5175 (class 0 OID 0)
-- Dependencies: 223
-- Name: tenants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tenants_id_seq', 11, true);


--
-- TOC entry 5176 (class 0 OID 0)
-- Dependencies: 219
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 13, true);


--
-- TOC entry 4978 (class 2606 OID 16603)
-- Name: announcements announcements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_pkey PRIMARY KEY (id);


--
-- TOC entry 4960 (class 2606 OID 16504)
-- Name: bills bills_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bills
    ADD CONSTRAINT bills_pkey PRIMARY KEY (id);


--
-- TOC entry 4962 (class 2606 OID 16506)
-- Name: bills bills_tenant_id_bulan_tahun_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bills
    ADD CONSTRAINT bills_tenant_id_bulan_tahun_key UNIQUE (tenant_id, bulan, tahun);


--
-- TOC entry 4955 (class 2606 OID 16474)
-- Name: contracts contracts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT contracts_pkey PRIMARY KEY (id);


--
-- TOC entry 4976 (class 2606 OID 16571)
-- Name: maintenance maintenance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance
    ADD CONSTRAINT maintenance_pkey PRIMARY KEY (id);


--
-- TOC entry 4970 (class 2606 OID 16534)
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- TOC entry 4946 (class 2606 OID 16427)
-- Name: rooms rooms_nomor_kamar_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_nomor_kamar_key UNIQUE (nomor_kamar);


--
-- TOC entry 4948 (class 2606 OID 16425)
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (id);


--
-- TOC entry 4953 (class 2606 OID 16445)
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (id);


--
-- TOC entry 4941 (class 2606 OID 16407)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 4943 (class 2606 OID 16405)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4979 (class 1259 OID 16628)
-- Name: idx_announcements_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_is_active ON public.announcements USING btree (is_active);


--
-- TOC entry 4980 (class 1259 OID 16629)
-- Name: idx_announcements_target; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_announcements_target ON public.announcements USING btree (target);


--
-- TOC entry 4963 (class 1259 OID 16620)
-- Name: idx_bills_bulan_tahun; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_bills_bulan_tahun ON public.bills USING btree (bulan, tahun);


--
-- TOC entry 4964 (class 1259 OID 16619)
-- Name: idx_bills_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_bills_status ON public.bills USING btree (status);


--
-- TOC entry 4965 (class 1259 OID 16618)
-- Name: idx_bills_tenant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_bills_tenant_id ON public.bills USING btree (tenant_id);


--
-- TOC entry 4956 (class 1259 OID 16616)
-- Name: idx_contracts_kamar_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_contracts_kamar_id ON public.contracts USING btree (kamar_id);


--
-- TOC entry 4957 (class 1259 OID 16617)
-- Name: idx_contracts_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_contracts_status ON public.contracts USING btree (status);


--
-- TOC entry 4958 (class 1259 OID 16615)
-- Name: idx_contracts_tenant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_contracts_tenant_id ON public.contracts USING btree (tenant_id);


--
-- TOC entry 4971 (class 1259 OID 16625)
-- Name: idx_maintenance_kamar_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_maintenance_kamar_id ON public.maintenance USING btree (kamar_id);


--
-- TOC entry 4972 (class 1259 OID 16627)
-- Name: idx_maintenance_prioritas; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_maintenance_prioritas ON public.maintenance USING btree (prioritas);


--
-- TOC entry 4973 (class 1259 OID 16626)
-- Name: idx_maintenance_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_maintenance_status ON public.maintenance USING btree (status);


--
-- TOC entry 4974 (class 1259 OID 16624)
-- Name: idx_maintenance_tenant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_maintenance_tenant_id ON public.maintenance USING btree (tenant_id);


--
-- TOC entry 4966 (class 1259 OID 16621)
-- Name: idx_payments_bill_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_payments_bill_id ON public.payments USING btree (bill_id);


--
-- TOC entry 4967 (class 1259 OID 16623)
-- Name: idx_payments_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_payments_status ON public.payments USING btree (status);


--
-- TOC entry 4968 (class 1259 OID 16622)
-- Name: idx_payments_tenant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_payments_tenant_id ON public.payments USING btree (tenant_id);


--
-- TOC entry 4944 (class 1259 OID 16611)
-- Name: idx_rooms_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rooms_status ON public.rooms USING btree (status);


--
-- TOC entry 4949 (class 1259 OID 16613)
-- Name: idx_tenants_kamar_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tenants_kamar_id ON public.tenants USING btree (kamar_id);


--
-- TOC entry 4950 (class 1259 OID 16614)
-- Name: idx_tenants_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tenants_status ON public.tenants USING btree (status);


--
-- TOC entry 4951 (class 1259 OID 16612)
-- Name: idx_tenants_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tenants_user_id ON public.tenants USING btree (user_id);


--
-- TOC entry 4938 (class 1259 OID 16609)
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- TOC entry 4939 (class 1259 OID 16610)
-- Name: idx_users_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_role ON public.users USING btree (role);


--
-- TOC entry 4992 (class 2606 OID 16604)
-- Name: announcements announcements_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4985 (class 2606 OID 16512)
-- Name: bills bills_contract_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bills
    ADD CONSTRAINT bills_contract_id_fkey FOREIGN KEY (contract_id) REFERENCES public.contracts(id) ON DELETE CASCADE;


--
-- TOC entry 4986 (class 2606 OID 16507)
-- Name: bills bills_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bills
    ADD CONSTRAINT bills_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- TOC entry 4983 (class 2606 OID 16480)
-- Name: contracts contracts_kamar_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT contracts_kamar_id_fkey FOREIGN KEY (kamar_id) REFERENCES public.rooms(id) ON DELETE CASCADE;


--
-- TOC entry 4984 (class 2606 OID 16475)
-- Name: contracts contracts_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT contracts_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- TOC entry 4990 (class 2606 OID 16577)
-- Name: maintenance maintenance_kamar_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance
    ADD CONSTRAINT maintenance_kamar_id_fkey FOREIGN KEY (kamar_id) REFERENCES public.rooms(id) ON DELETE CASCADE;


--
-- TOC entry 4991 (class 2606 OID 16572)
-- Name: maintenance maintenance_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance
    ADD CONSTRAINT maintenance_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- TOC entry 4987 (class 2606 OID 16535)
-- Name: payments payments_bill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_bill_id_fkey FOREIGN KEY (bill_id) REFERENCES public.bills(id) ON DELETE CASCADE;


--
-- TOC entry 4988 (class 2606 OID 16540)
-- Name: payments payments_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- TOC entry 4989 (class 2606 OID 16545)
-- Name: payments payments_verified_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_verified_by_fkey FOREIGN KEY (verified_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- TOC entry 4981 (class 2606 OID 16451)
-- Name: tenants tenants_kamar_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_kamar_id_fkey FOREIGN KEY (kamar_id) REFERENCES public.rooms(id) ON DELETE SET NULL;


--
-- TOC entry 4982 (class 2606 OID 16446)
-- Name: tenants tenants_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


-- Completed on 2026-05-26 15:15:34

--
-- PostgreSQL database dump complete
--

\unrestrict CS05WANXBvvNiGOWnlaAXObjtQM3JZqcJs4i5YaEkX3a04o168cPR0MMAJEVQz5

