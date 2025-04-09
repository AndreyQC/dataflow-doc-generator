/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/dm/type/view/name/dim_subtasks
  object_name: dim_subtasks
  object_schema: dm
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW dm.dim_subtasks AS
 SELECT DISTINCT t.task_id AS "Task Key",
    t.name AS "Task Name",
    tt.name AS "Task Topic",
    st.subtask_id AS "Subtask Key",
    st.name AS "Subtask Name",
    st.description AS "Subtask Description",
    st.max_score AS "Subtask Max Score",
    stt.name AS "Subtask Topic"
   FROM (((lab.subtask st
     JOIN lab.topic stt ON ((stt.topic_id = st.topic_id)))
     JOIN lab.task t ON ((t.task_id = st.task_id)))
     JOIN lab.topic tt ON ((tt.topic_id = t.topic_id)));


ALTER VIEW dm.dim_subtasks OWNER TO bi_admin;
