/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/view/name/vw_subtask_bonus
  object_name: vw_subtask_bonus
  object_schema: mentor
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW mentor.vw_subtask_bonus AS
 SELECT stb.subtask_bonus_id,
    stb.subtask_id,
    st.name AS subtask_name,
    stb.bonus_id,
    b.name AS bonus_name,
    b.code AS bonus_code
   FROM ((lab.subtask_bonus stb
     JOIN lab.subtask st ON ((st.subtask_id = stb.subtask_id)))
     JOIN lab.bonus b ON ((b.bonus_id = stb.bonus_id)));


ALTER VIEW mentor.vw_subtask_bonus OWNER TO bi_admin;
