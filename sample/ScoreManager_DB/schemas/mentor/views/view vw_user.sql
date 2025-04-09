/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/view/name/vw_user
  object_name: vw_user
  object_schema: mentor
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW mentor.vw_user AS
 SELECT u.id AS user_id,
    u.name AS username,
    u.email AS user_email,
    u.password AS user_password,
    u.city_id AS user_city_id,
    c.name AS user_city_name,
    COALESCE(u.notes, ''::character varying) AS user_notes,
    u.is_active AS user_is_active
   FROM (lab."user" u
     JOIN lab.city c ON ((c.city_id = u.city_id)));


ALTER VIEW mentor.vw_user OWNER TO bi_admin;
