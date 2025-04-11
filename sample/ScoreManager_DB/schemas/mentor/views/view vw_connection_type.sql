/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/view/name/vw_connection_type
  object_name: vw_connection_type
  object_schema: mentor
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW mentor.vw_connection_type AS
 SELECT ct.connection_type_id,
    ct.name AS connection_type_name,
    ct.description AS connection_type_desc
   FROM lab.connection_type ct;


ALTER VIEW mentor.vw_connection_type OWNER TO bi_admin;
