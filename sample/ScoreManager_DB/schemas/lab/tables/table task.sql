/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/lab/type/table/name/task
  object_name: task
  object_schema: lab
  object_type: table
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE TABLE lab.task (
    task_id integer NOT NULL,
    course_id integer NOT NULL,
    name character varying(250) NOT NULL,
    description character varying(250) NOT NULL,
    topic_id smallint NOT NULL,
    sys_created_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'utc'::text),
    sys_changed_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'utc'::text),
    sys_created_by integer DEFAULT '-1'::integer,
    sys_changed_by integer DEFAULT '-1'::integer
);


ALTER TABLE lab.task OWNER TO bi_admin;
