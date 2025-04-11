/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/view/name/vw_task_topic
  object_name: vw_task_topic
  object_schema: mentor
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW mentor.vw_task_topic AS
 SELECT t.topic_id,
    t.name AS task_topic_name
   FROM lab.topic t
  WHERE (t.is_topic_for_tasks = true);


ALTER VIEW mentor.vw_task_topic OWNER TO bi_admin;
