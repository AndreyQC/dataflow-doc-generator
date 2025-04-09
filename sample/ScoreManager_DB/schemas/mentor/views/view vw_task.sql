/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/view/name/vw_task
  object_name: vw_task
  object_schema: mentor
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW mentor.vw_task AS
 SELECT c.course_id,
    c.name AS course_name,
    t.task_id,
    t.name AS task_name,
    t.description AS task_desc,
    tt.topic_id,
    tt.name AS topic_name
   FROM ((lab.task t
     JOIN lab.course c ON ((c.course_id = t.course_id)))
     JOIN lab.topic tt ON ((tt.topic_id = t.topic_id)));


ALTER VIEW mentor.vw_task OWNER TO bi_admin;
