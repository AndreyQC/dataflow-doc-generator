/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/lab/type/function/name/udf_get_status_id_by_name(character
    varying)
  object_name: udf_get_status_id_by_name(character varying)
  object_schema: lab
  object_type: function
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE FUNCTION lab.udf_get_status_id_by_name(status_name character varying) RETURNS smallint
    LANGUAGE plpgsql
    AS $$
DECLARE 
    ret int; 
BEGIN  
    SELECT s.status_id INTO ret
    FROM lab.status s
    WHERE s."name" = status_name;

    RETURN ret;  
END;
$$;


ALTER FUNCTION lab.udf_get_status_id_by_name(status_name character varying) OWNER TO bi_admin;
