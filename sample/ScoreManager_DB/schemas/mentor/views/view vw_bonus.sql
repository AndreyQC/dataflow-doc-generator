/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/view/name/vw_bonus
  object_name: vw_bonus
  object_schema: mentor
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW mentor.vw_bonus AS
 SELECT b.bonus_id,
    b.name AS bonus_name,
    b.description AS bonus_desc,
    b.code AS bonus_code
   FROM lab.bonus b;


ALTER VIEW mentor.vw_bonus OWNER TO bi_admin;
