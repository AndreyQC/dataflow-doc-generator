/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/view/name/vw_scores_dashboard_all_courses
  object_name: vw_scores_dashboard_all_courses
  object_schema: mentor
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW mentor.vw_scores_dashboard_all_courses AS
 SELECT c.name AS course_name,
    t.name AS task_name,
    t.description AS task_desc,
    tt.name AS task_topic_name,
    st.subtask_id,
    st.name AS subtask_name,
    st.description AS subtask_desc,
    stt.name AS subtask_topic_name,
    cs1.course_staff_id AS student_id,
    u1.name AS student_name,
    cs2.course_staff_id AS reviewer_id,
    u2.name AS reviewer_name,
    stl.score,
    stl.ontime,
    (((((COALESCE(stl.name_conv, (0)::numeric) + COALESCE(stl.readability, (0)::numeric)) + COALESCE(stl.sarg, (0)::numeric)) + COALESCE(stl.schema_name, (0)::numeric)) + COALESCE(stl.aliases, (0)::numeric)) + COALESCE(stl.determ_sort, (0)::numeric)) AS accuracy,
    stl.extra,
    ((((((((COALESCE(stl.score, (0)::numeric) + COALESCE(stl.name_conv, (0)::numeric)) + COALESCE(stl.readability, (0)::numeric)) + COALESCE(stl.sarg, (0)::numeric)) + COALESCE(stl.schema_name, (0)::numeric)) + COALESCE(stl.aliases, (0)::numeric)) + COALESCE(stl.determ_sort, (0)::numeric)) + COALESCE(stl.ontime, (0)::numeric)) + COALESCE(stl.extra, (0)::numeric)) AS total_score,
    stl.comment
   FROM (((((((((lab.subtask_log stl
     JOIN lab.subtask st ON ((st.subtask_id = stl.subtask_id)))
     JOIN lab.topic stt ON ((stt.topic_id = st.topic_id)))
     JOIN lab.task t ON ((t.task_id = st.task_id)))
     JOIN lab.topic tt ON ((tt.topic_id = t.topic_id)))
     JOIN lab.course c ON ((c.course_id = t.course_id)))
     JOIN lab.course_staff cs1 ON ((cs1.course_staff_id = stl.student_id)))
     JOIN lab."user" u1 ON ((u1.id = cs1.user_id)))
     JOIN lab.course_staff cs2 ON ((cs2.course_staff_id = stl.reviewer_id)))
     JOIN lab."user" u2 ON ((u2.id = cs2.user_id)));


ALTER VIEW mentor.vw_scores_dashboard_all_courses OWNER TO bi_admin;
