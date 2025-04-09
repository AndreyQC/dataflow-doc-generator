/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/lab/type/table/name/check_script
  object_name: check_script
  object_schema: lab
  object_type: table
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE TABLE lab.check_script (
    check_script_id integer NOT NULL,
    text text NOT NULL,
    description text NOT NULL,
    connection_id integer NOT NULL,
    check_script_type_id smallint NOT NULL,
    sys_created_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'utc'::text),
    sys_changed_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'utc'::text),
    sys_created_by integer DEFAULT '-1'::integer,
    sys_changed_by integer DEFAULT '-1'::integer
);


ALTER TABLE lab.check_script OWNER TO bi_admin;
