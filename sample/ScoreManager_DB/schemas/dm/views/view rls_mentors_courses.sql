/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/dm/type/view/name/rls_mentors_courses
  object_name: rls_mentors_courses
  object_schema: dm
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW dm.rls_mentors_courses AS
 SELECT DISTINCT c.course_id AS "Course Key",
    u.name AS "Mentor",
    u.email AS "Mentor Email",
    u.user_yc_id AS "Mentor YC Key"
   FROM (((lab.course_staff cs
     JOIN lab.course c ON ((c.course_id = cs.course_id)))
     JOIN lab."user" u ON ((u.id = cs.user_id)))
     JOIN lab.user_type ut ON (((ut.user_type_id = cs.user_type_id) AND ((ut.name)::text = 'mentor'::text))));


ALTER VIEW dm.rls_mentors_courses OWNER TO bi_admin;
