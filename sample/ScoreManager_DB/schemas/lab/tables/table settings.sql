/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/lab/type/table/name/settings
  object_name: settings
  object_schema: lab
  object_type: table
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE TABLE lab.settings (
    settings_id integer NOT NULL,
    user_id integer,
    setting_name character varying(100) NOT NULL,
    setting_value character varying(100),
    sys_created_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'utc'::text),
    sys_changed_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'utc'::text),
    sys_created_by integer DEFAULT '-1'::integer,
    sys_changed_by integer DEFAULT '-1'::integer
);


ALTER TABLE lab.settings OWNER TO bi_admin;
