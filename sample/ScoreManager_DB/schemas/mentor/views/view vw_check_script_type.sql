/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/view/name/vw_check_script_type
  object_name: vw_check_script_type
  object_schema: mentor
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW mentor.vw_check_script_type AS
 SELECT cst.check_script_type_id,
    cst.name AS check_script_type_name
   FROM lab.check_script_type cst;


ALTER VIEW mentor.vw_check_script_type OWNER TO bi_admin;
