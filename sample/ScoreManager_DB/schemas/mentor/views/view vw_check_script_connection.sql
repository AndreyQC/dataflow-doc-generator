/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/view/name/vw_check_script_connection
  object_name: vw_check_script_connection
  object_schema: mentor
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW mentor.vw_check_script_connection AS
 SELECT csc.connection_id,
    csc.connection_name,
    csc.connection_desc,
    csc.connection_string
   FROM lab.connection csc;


ALTER VIEW mentor.vw_check_script_connection OWNER TO bi_admin;
