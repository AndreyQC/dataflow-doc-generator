/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/view/name/vw_subtask
  object_name: vw_subtask
  object_schema: mentor
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW mentor.vw_subtask AS
 SELECT DISTINCT t.task_id,
    t.name AS task_name,
    st.subtask_id,
    st.name AS subtask_name,
    st.description AS subtask_desc,
    st.max_score AS subtask_max_score,
    stt.topic_id AS subtask_topic_id,
    stt.name AS subtask_topic_name,
    cs.check_script_id AS subtask_check_script_id,
    cs.text AS subtask_check_script_text
   FROM (((lab.subtask st
     JOIN lab.task t ON ((t.task_id = st.task_id)))
     JOIN lab.topic stt ON ((stt.topic_id = st.topic_id)))
     LEFT JOIN lab.check_script cs ON ((cs.check_script_id = st.check_script_id)));


ALTER VIEW mentor.vw_subtask OWNER TO bi_admin;
