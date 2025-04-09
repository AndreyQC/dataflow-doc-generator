/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/view/name/vw_course_staff
  object_name: vw_course_staff
  object_schema: mentor
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW mentor.vw_course_staff AS
 SELECT cs.course_staff_id,
    c.course_id,
    c.name AS course_name,
    u.id AS user_id,
    u.name AS username,
    u.email AS user_email,
    ut.name AS user_type,
    s.name AS status_name,
    ct.name AS city_name
   FROM (((((lab.course_staff cs
     JOIN lab.course c ON ((c.course_id = cs.course_id)))
     JOIN lab."user" u ON ((u.id = cs.user_id)))
     JOIN lab.city ct ON ((ct.city_id = u.city_id)))
     JOIN lab.user_type ut ON ((ut.user_type_id = cs.user_type_id)))
     LEFT JOIN lab.status s ON ((s.status_id = cs.status_id)));


ALTER VIEW mentor.vw_course_staff OWNER TO bi_admin;
