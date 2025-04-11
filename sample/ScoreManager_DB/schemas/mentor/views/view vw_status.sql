/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/view/name/vw_status
  object_name: vw_status
  object_schema: mentor
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW mentor.vw_status AS
 SELECT s.status_id,
    s.name AS status_name,
    s.description AS status_desc
   FROM lab.status s;


ALTER VIEW mentor.vw_status OWNER TO bi_admin;
