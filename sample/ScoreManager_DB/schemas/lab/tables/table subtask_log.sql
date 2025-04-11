/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/lab/type/table/name/subtask_log
  object_name: subtask_log
  object_schema: lab
  object_type: table
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE TABLE lab.subtask_log (
    subtask_log_id integer NOT NULL,
    subtask_id integer NOT NULL,
    student_id integer NOT NULL,
    reviewer_id integer,
    score numeric(8,2) DEFAULT 0 NOT NULL,
    ontime numeric(8,2) DEFAULT 0 NOT NULL,
    name_conv numeric(8,2) DEFAULT 0 NOT NULL,
    readability numeric(8,2) DEFAULT 0 NOT NULL,
    sarg numeric(8,2) DEFAULT 0 NOT NULL,
    schema_name numeric(8,2) DEFAULT 0 NOT NULL,
    aliases numeric(8,2) DEFAULT 0 NOT NULL,
    determ_sort numeric(8,2) DEFAULT 0 NOT NULL,
    extra numeric(8,2) DEFAULT 0 NOT NULL,
    comment character varying(2000),
    sys_created_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'utc'::text),
    sys_changed_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'utc'::text),
    sys_created_by integer DEFAULT '-1'::integer,
    sys_changed_by integer DEFAULT '-1'::integer
);


ALTER TABLE lab.subtask_log OWNER TO bi_admin;
