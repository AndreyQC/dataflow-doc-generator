/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/view/name/vw_settings
  object_name: vw_settings
  object_schema: mentor
  object_type: view
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE VIEW mentor.vw_settings AS
 SELECT s.settings_id,
    s.setting_name,
    s.setting_value,
    u.id AS user_id,
    u.email AS user_email
   FROM (lab.settings s
     JOIN lab."user" u ON ((u.id = s.user_id)));


ALTER VIEW mentor.vw_settings OWNER TO bi_admin;
