/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/view/name/vw_user_type
  object_name: vw_user_type
  object_schema: mentor
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW mentor.vw_user_type AS
 SELECT ut.user_type_id,
    ut.name AS user_type_name,
    ut.description AS user_typedesc
   FROM lab.user_type ut;


ALTER VIEW mentor.vw_user_type OWNER TO bi_admin;
