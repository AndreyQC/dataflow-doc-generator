/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/lab/type/table/name/course
  object_name: course
  object_schema: lab
  object_type: table
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE TABLE lab.course (
    course_id integer NOT NULL,
    name character varying(250) NOT NULL,
    datestart date NOT NULL,
    datefinish date,
    sys_created_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'utc'::text),
    sys_changed_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'utc'::text),
    sys_created_by integer DEFAULT '-1'::integer,
    sys_changed_by integer DEFAULT '-1'::integer,
    description character varying(250),
    CONSTRAINT ch_course_datefinish CHECK ((datefinish >= datestart))
);


ALTER TABLE lab.course OWNER TO bi_admin;
