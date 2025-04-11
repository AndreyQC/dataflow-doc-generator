/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/dm/type/view/name/fact_scores
  object_name: fact_scores
  object_schema: dm
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW dm.fact_scores AS
 SELECT stl.subtask_log_id AS "Subtask Log Key",
    c.course_id AS "Course Key",
    st.subtask_id AS "Subtask Key",
    cs1.course_staff_id AS "Student Key",
    cs2.course_staff_id AS "Mentor Key",
    stl.score AS "Score",
    stl.ontime AS "Ontime Bonus",
    (((((COALESCE(stl.name_conv, (0)::numeric) + COALESCE(stl.readability, (0)::numeric)) + COALESCE(stl.sarg, (0)::numeric)) + COALESCE(stl.schema_name, (0)::numeric)) + COALESCE(stl.aliases, (0)::numeric)) + COALESCE(stl.determ_sort, (0)::numeric)) AS "Accuracy Bonus",
    stl.extra AS "Extra Bonus",
    ((((((((COALESCE(stl.score, (0)::numeric) + COALESCE(stl.name_conv, (0)::numeric)) + COALESCE(stl.readability, (0)::numeric)) + COALESCE(stl.sarg, (0)::numeric)) + COALESCE(stl.schema_name, (0)::numeric)) + COALESCE(stl.aliases, (0)::numeric)) + COALESCE(stl.determ_sort, (0)::numeric)) + COALESCE(stl.ontime, (0)::numeric)) + COALESCE(stl.extra, (0)::numeric)) AS "Total Score",
    stl.comment AS "Comment"
   FROM (((((lab.subtask_log stl
     JOIN lab.subtask st ON ((st.subtask_id = stl.subtask_id)))
     JOIN lab.task t ON ((t.task_id = st.task_id)))
     JOIN lab.course c ON ((c.course_id = t.course_id)))
     JOIN lab.course_staff cs1 ON ((cs1.course_staff_id = stl.student_id)))
     JOIN lab.course_staff cs2 ON ((cs2.course_staff_id = stl.reviewer_id)));


ALTER VIEW dm.fact_scores OWNER TO bi_admin;
