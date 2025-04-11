/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/view/name/vw_mentor
  object_name: vw_mentor
  object_schema: mentor
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW mentor.vw_mentor AS
 SELECT us.id AS mentor_user_id,
    us.name AS mentor_name,
    st.name AS mentor_status,
    ct.name AS mentor_city,
    crs.name AS mentor_course_name,
    us.email AS mentor_email
   FROM (((((lab.course_staff cs
     JOIN lab.course crs ON ((crs.course_id = cs.course_id)))
     JOIN lab.user_type ut ON (((ut.user_type_id = cs.user_type_id) AND ((ut.name)::text = 'mentor'::text))))
     JOIN lab."user" us ON ((us.id = cs.user_id)))
     JOIN lab.city ct ON ((ct.city_id = us.city_id)))
     LEFT JOIN lab.status st ON ((st.status_id = cs.status_id)));


ALTER VIEW mentor.vw_mentor OWNER TO bi_admin;
