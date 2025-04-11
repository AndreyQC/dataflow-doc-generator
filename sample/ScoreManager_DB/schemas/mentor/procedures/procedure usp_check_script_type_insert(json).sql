/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/procedure/name/usp_check_script_type_insert(json)
  object_name: usp_check_script_type_insert(json)
  object_schema: mentor
  object_type: procedure
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE PROCEDURE mentor.usp_check_script_type_insert(IN jsn json)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DROP TABLE IF EXISTS temp_source;
    CREATE TEMPORARY TABLE temp_source (
        check_script_type_name VARCHAR(250)
    ) ON COMMIT DROP;
    
    INSERT INTO temp_source(check_script_type_name)
    SELECT value AS check_script_type_name
    FROM json_array_elements_text(jsn) AS j;
    
    -- check_script_type insert
    MERGE INTO lab.check_script_type tgt
    USING (
        SELECT tmp.check_script_type_name
        FROM temp_source tmp
    ) src 
        ON (TRIM(UPPER(src.check_script_type_name)) = TRIM(UPPER(tgt."name")))
    WHEN NOT MATCHED THEN
    INSERT (     
        "name"
    ) 
    VALUES (     
        src.check_script_type_name
    );
END; $$;


ALTER PROCEDURE mentor.usp_check_script_type_insert(IN jsn json) OWNER TO bi_admin;
