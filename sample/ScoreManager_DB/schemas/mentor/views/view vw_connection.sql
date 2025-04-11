/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/view/name/vw_connection
  object_name: vw_connection
  object_schema: mentor
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW mentor.vw_connection AS
 SELECT cn.connection_id,
    cn.connection_name,
    cn.connection_desc,
    cn.connection_string,
    ct.connection_type_id,
    ct.name AS connection_type_name
   FROM (lab.connection cn
     JOIN lab.connection_type ct ON ((ct.connection_type_id = cn.connection_type_id)));


ALTER VIEW mentor.vw_connection OWNER TO bi_admin;
