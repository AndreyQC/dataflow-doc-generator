/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/dm/type/view/name/rls_students_courses
  object_name: rls_students_courses
  object_schema: dm
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW dm.rls_students_courses AS
 SELECT DISTINCT c.course_id AS "Course Key",
    u.name AS "Student",
    u.email AS "Student Email",
    u.user_yc_id AS "Student YC Key"
   FROM (((lab.course_staff cs
     JOIN lab.course c ON ((c.course_id = cs.course_id)))
     JOIN lab."user" u ON ((u.id = cs.user_id)))
     JOIN lab.user_type ut ON (((ut.user_type_id = cs.user_type_id) AND ((ut.name)::text = 'student'::text))));


ALTER VIEW dm.rls_students_courses OWNER TO bi_admin;
