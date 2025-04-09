/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/view/name/vw_subtask_bonus_pivoted
  object_name: vw_subtask_bonus_pivoted
  object_schema: mentor
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW mentor.vw_subtask_bonus_pivoted AS
 SELECT DISTINCT t.course_id,
    t.task_id,
    t.name AS task_name,
    st.subtask_id,
    st.name AS subtask_name,
    st.description AS subtask_desc,
    st.topic_id AS subtask_topic_id,
    stt.name AS subtask_topic_name,
    ( SELECT true AS is_name_conv
           FROM mentor.vw_subtask_bonus stb
          WHERE ((stb.subtask_id = st.subtask_id) AND ((stb.bonus_code)::text = 'name_conv'::text))) AS is_name_conv,
    ( SELECT true AS is_read
           FROM mentor.vw_subtask_bonus stb
          WHERE ((stb.subtask_id = st.subtask_id) AND ((stb.bonus_code)::text = 'read'::text))) AS is_read,
    ( SELECT true AS is_sarg
           FROM mentor.vw_subtask_bonus stb
          WHERE ((stb.subtask_id = st.subtask_id) AND ((stb.bonus_code)::text = 'sarg'::text))) AS is_sarg,
    ( SELECT true AS is_schema_name
           FROM mentor.vw_subtask_bonus stb
          WHERE ((stb.subtask_id = st.subtask_id) AND ((stb.bonus_code)::text = 'schema_name'::text))) AS is_schema_name,
    ( SELECT true AS is_aliases
           FROM mentor.vw_subtask_bonus stb
          WHERE ((stb.subtask_id = st.subtask_id) AND ((stb.bonus_code)::text = 'aliases'::text))) AS is_aliases,
    ( SELECT true AS is_determ_sort
           FROM mentor.vw_subtask_bonus stb
          WHERE ((stb.subtask_id = st.subtask_id) AND ((stb.bonus_code)::text = 'determ_sort'::text))) AS is_determ_sort
   FROM ((lab.subtask st
     JOIN lab.task t ON ((t.task_id = st.task_id)))
     JOIN lab.topic stt ON ((stt.topic_id = st.topic_id)));


ALTER VIEW mentor.vw_subtask_bonus_pivoted OWNER TO bi_admin;
