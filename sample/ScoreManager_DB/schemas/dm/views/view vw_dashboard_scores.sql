/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/dm/type/view/name/vw_dashboard_scores
  object_name: vw_dashboard_scores
  object_schema: dm
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW dm.vw_dashboard_scores AS
 SELECT c.name AS "Course Name",
    subt.task_topic AS "Task Topic",
    subt.task_name AS "Task Name",
    subt.subtask_desc AS "Subtask Description",
    subt.subtask_name AS "Subtask Name",
    stud.student_name AS "Student",
    scores.mentor_name AS "Reviewer",
    scores.ontime_bonus AS "Ontime Bonus",
    scores.accuracy_bonus AS "Accuracy Bonus",
    scores.extra_bonus AS "Extra Bonus",
    scores.score AS "Score",
    scores.total_score AS "Total Score",
    subt.subtask_max_score AS "Subtask Max Score",
    scores.comment AS "Comment",
    stud.email AS rls,
    stud.city_name AS "Student City",
    scores.mentor_city AS "Reviewer City",
        CASE
            WHEN (scores.score IS NULL) THEN 'None'::text
            WHEN (scores.score > (0)::numeric) THEN 'Pass'::text
            ELSE 'Fail'::text
        END AS "Homework Status"
   FROM (((lab.course c
     JOIN ( SELECT cs.course_id,
            cs.course_staff_id AS student_course_staff_id,
            u.name AS student_name,
            u.email,
            ct.name AS city_name
           FROM (((lab.course_staff cs
             JOIN lab.user_type ut ON (((ut.user_type_id = cs.user_type_id) AND ((ut.name)::text = 'student'::text))))
             JOIN lab."user" u ON ((u.id = cs.user_id)))
             JOIN lab.city ct ON ((ct.city_id = u.city_id)))) stud ON ((stud.course_id = c.course_id)))
     JOIN ( SELECT DISTINCT t.task_id,
            t.course_id,
            t.name AS task_name,
            tt.name AS task_topic,
            st.subtask_id,
            st.name AS subtask_name,
            st.description AS subtask_desc,
            st.max_score AS subtask_max_score,
            stt.name AS subtask_topic
           FROM (((lab.subtask st
             JOIN lab.topic stt ON ((stt.topic_id = st.topic_id)))
             JOIN lab.task t ON ((t.task_id = st.task_id)))
             JOIN lab.topic tt ON ((tt.topic_id = t.topic_id)))) subt ON ((subt.course_id = c.course_id)))
     LEFT JOIN ( SELECT stl.subtask_log_id,
            c_1.course_id,
            st.subtask_id,
            cs1.course_staff_id AS student_course_staff_id,
            cs2.course_staff_id AS mentor_course_staff_id,
            u.name AS mentor_name,
            ct.name AS mentor_city,
            stl.score,
            stl.ontime AS ontime_bonus,
            (((((COALESCE(stl.name_conv, (0)::numeric) + COALESCE(stl.readability, (0)::numeric)) + COALESCE(stl.sarg, (0)::numeric)) + COALESCE(stl.schema_name, (0)::numeric)) + COALESCE(stl.aliases, (0)::numeric)) + COALESCE(stl.determ_sort, (0)::numeric)) AS accuracy_bonus,
            stl.extra AS extra_bonus,
            ((((((((COALESCE(stl.score, (0)::numeric) + COALESCE(stl.name_conv, (0)::numeric)) + COALESCE(stl.readability, (0)::numeric)) + COALESCE(stl.sarg, (0)::numeric)) + COALESCE(stl.schema_name, (0)::numeric)) + COALESCE(stl.aliases, (0)::numeric)) + COALESCE(stl.determ_sort, (0)::numeric)) + COALESCE(stl.ontime, (0)::numeric)) + COALESCE(stl.extra, (0)::numeric)) AS total_score,
            stl.comment
           FROM (((((((lab.subtask_log stl
             JOIN lab.subtask st ON ((st.subtask_id = stl.subtask_id)))
             JOIN lab.task t ON ((t.task_id = st.task_id)))
             JOIN lab.course c_1 ON ((c_1.course_id = t.course_id)))
             JOIN lab.course_staff cs1 ON ((cs1.course_staff_id = stl.student_id)))
             JOIN lab.course_staff cs2 ON ((cs2.course_staff_id = stl.reviewer_id)))
             JOIN lab."user" u ON ((u.id = cs2.user_id)))
             JOIN lab.city ct ON ((ct.city_id = u.city_id)))) scores ON (((scores.subtask_id = subt.subtask_id) AND (scores.student_course_staff_id = stud.student_course_staff_id))));


ALTER VIEW dm.vw_dashboard_scores OWNER TO bi_admin;
