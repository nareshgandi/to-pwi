#### Dump in plain text format

```
pg_dump -U postgres -d retaildb -Fp -f plaintextdump.sql
```

Sample output

```
--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

....
....

CREATE SCHEMA retail;
ALTER SCHEMA retail OWNER TO retailuser;

CREATE TABLE retail.stores (
    store_id integer NOT NULL,
    store_name text NOT NULL,
    city text NOT NULL,
    state text NOT NULL,
    opened_on date
);


ALTER TABLE retail.stores OWNER TO retailuser;

--
-- Name: stores_store_id_seq; Type: SEQUENCE; Schema: retail; Owner: retailuser
--

CREATE SEQUENCE retail.stores_store_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE retail.stores_store_id_seq OWNER TO retailuser;

--
-- Name: stores_store_id_seq; Type: SEQUENCE OWNED BY; Schema: retail; Owner: retailuser
--

ALTER SEQUENCE retail.stores_store_id_seq OWNED BY retail.stores.store_id;


--
-- Name: v_customer_purchases; Type: VIEW; Schema: retail; Owner: retailuser
--

CREATE VIEW retail.v_customer_purchases AS
 SELECT c.customer_id,
    c.full_name,
    count(s.sale_id) AS total_orders,
    sum(s.total_amount) AS total_spent
   FROM (retail.customers c
     JOIN retail.sales s ON ((c.customer_id = s.customer_id)))
  GROUP BY c.customer_id, c.full_name;

...
...


--
-- Data for Name: categories; Type: TABLE DATA; Schema: retail; Owner: retailuser
--

COPY retail.categories (category_id, name, description) FROM stdin;
1       Personal Care   Shampoos, soaps, hygiene products
2       Groceries       Food items and essentials
3       Electronics     Mobile phones, gadgets, accessories
4       Beverages       Soft drinks, juices, and bottled water
\.

--
-- Name: TABLE stores; Type: ACL; Schema: retail; Owner: retailuser
--

GRANT SELECT ON TABLE retail.stores TO retailread;

```

### Other formats include

```
 pg_dump -U postgres -d retaildb -Fc -f customdump.bkp
 pg_dump -U postgres -d retaildb -Ft -f tardump.tar
 pg_dump -U postgres -d retaildb -Fd -f dirdump
````
