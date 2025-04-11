/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/view/name/vw_student
  object_name: vw_student
  object_schema: mentor
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW mentor.vw_student AS
 SELECT us.id AS student_user_id,
    us.name AS student_name,
    st.name AS student_status,
    ct.name AS student_city,
    crs.name AS student_course_name,
    us.email AS student_email
   FROM (((((lab.course_staff cs
     JOIN lab.course crs ON ((crs.course_id = cs.course_id)))
     JOIN lab.user_type ut ON (((ut.user_type_id = cs.user_type_id) AND ((ut.name)::text = 'student'::text))))
     JOIN lab."user" us ON ((us.id = cs.user_id)))
     JOIN lab.city ct ON ((ct.city_id = us.city_id)))
     LEFT JOIN lab.status st ON ((st.status_id = cs.status_id)));


ALTER VIEW mentor.vw_student OWNER TO bi_admin;
