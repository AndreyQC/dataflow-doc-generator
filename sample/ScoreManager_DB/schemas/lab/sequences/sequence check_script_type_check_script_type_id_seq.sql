/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/lab/type/sequence/name/check_script_type_check_script_type_id_seq
  object_name: check_script_type_check_script_type_id_seq
  object_schema: lab
  object_type: sequence
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE SEQUENCE lab.check_script_type_check_script_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE lab.check_script_type_check_script_type_id_seq OWNER TO bi_admin;
