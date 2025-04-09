/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/lab/type/table/name/user
  object_name: user
  object_schema: lab
  object_type: table
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE TABLE lab."user" (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    city_id smallint NOT NULL,
    notes character varying(500),
    user_yc_id text,
    password character varying(500),
    is_active boolean DEFAULT true NOT NULL,
    sys_created_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'utc'::text),
    sys_changed_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'utc'::text),
    sys_created_by integer DEFAULT '-1'::integer,
    sys_changed_by integer DEFAULT '-1'::integer
);


ALTER TABLE lab."user" OWNER TO bi_admin;
