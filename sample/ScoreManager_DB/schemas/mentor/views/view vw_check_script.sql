/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/view/name/vw_check_script
  object_name: vw_check_script
  object_schema: mentor
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW mentor.vw_check_script AS
 SELECT st.subtask_id,
    st.name AS subtask_name,
    cs.check_script_id,
    cs.text AS check_script_text,
    cs.description AS check_script_desc,
    cst.check_script_type_id,
    cst.name AS check_script_type_name,
    cn.connection_id,
    cn.connection_string,
    ct.name AS connection_type_name,
    cn.connection_name,
    cn.connection_desc
   FROM ((((lab.check_script cs
     JOIN lab.check_script_type cst ON ((cst.check_script_type_id = cs.check_script_type_id)))
     JOIN lab.connection cn ON ((cn.connection_id = cs.connection_id)))
     JOIN lab.connection_type ct ON ((ct.connection_type_id = cn.connection_type_id)))
     LEFT JOIN lab.subtask st ON ((st.check_script_id = cs.check_script_id)));


ALTER VIEW mentor.vw_check_script OWNER TO bi_admin;
