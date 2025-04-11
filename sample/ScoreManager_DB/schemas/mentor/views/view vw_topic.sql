/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/view/name/vw_topic
  object_name: vw_topic
  object_schema: mentor
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW mentor.vw_topic AS
 SELECT tt.topic_id,
    tt.name AS topic_name,
    tt.is_topic_for_tasks,
    tt.is_topic_for_subtasks
   FROM lab.topic tt;


ALTER VIEW mentor.vw_topic OWNER TO bi_admin;
