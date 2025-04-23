#### Dump in plain text format

```
pg_dump -U retailuser -d retaildb -Fp -f plaintext.sql
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
 pg_dump -U retailuser -d retaildb -Fc -f customdump.bkp
 pg_dump -U retailuser -d retaildb -Ft -f tardump.tar
 pg_dump -U retailuser -d retaildb -Fd -f dirdump
````

### More commands

```
|-----------------------------|---------------------------------------------------------------------|
| Type (Backups)              | Command                                                             |
|-----------------------------|---------------------------------------------------------------------|
| Custom format dump          | pg_dump -U retailuser -d retaildb -Fc -f customdump.bkp             |
| Tar format dump             | pg_dump -U retailuser -d retaildb -Ft -f tardump.tar                |
| Directory format dump       | pg_dump -U retailuser -d retaildb -Fd -f dirdump                    |
| products table only         | pg_dump -U retailuser -d retaildb  -t products -Fc -f products.bkp  |
| retail schema only          | pg_dump -U retailuser -d retaildb -n retail -Fc -f retailschema.bkp |
| data only                   | pg_dump -U retailuser -d retaildb -a  -Fc -f dataonly.bkp           |
| definitions only            | pg_dump -U retailuser -d retaildb -s  -Fc -f meta.bkp               |
|-----------------------------|---------------------------------------------------------------------|
| Type (Restore)              | Command                                                             |
|-----------------------------|---------------------------------------------------------------------|
| custom to sql               | pg_restore products.bkp -f productstosql.sql                        |
| Restore in restoreretaildb  | pg_restore -U retailuser -d restoreretail customdump.bkp            |
|-----------------------------|---------------------------------------------------------------------|
```

### Restore only certain object types

#### First take the dump:

```
pg_dump -U username --format=c --schema-only -f dump_test your_database
```
#### Then create a list of the functions:
```
pg_restore --list dump_test | grep FUNCTION > function_list

Example.,

[postgres@lab02 backups]$ pg_restore --list customdump.bkp | grep PROCEDURE
235; 1255 16985 PROCEDURE retail record_sale(integer, integer, integer, integer, date) retailuser
234; 1255 16984 PROCEDURE retail restock_product(integer, integer, integer) retailuser
[postgres@lab02 backups]$ pg_restore --list customdump.bkp | grep PROCEDURE > procedure_list
```

#### And finally restore them (-L or --use-list specifies the list file created above):
```
pg_restore -U username -d your_other_database -L function_list dump_test
```
