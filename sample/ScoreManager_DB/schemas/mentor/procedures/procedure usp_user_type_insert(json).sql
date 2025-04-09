/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/procedure/name/usp_user_type_insert(json)
  object_name: usp_user_type_insert(json)
  object_schema: mentor
  object_type: procedure
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE PROCEDURE mentor.usp_user_type_insert(IN jsn json)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DROP TABLE IF EXISTS temp_source;
    CREATE TEMPORARY TABLE temp_source (
        user_type_name          VARCHAR(250),
        user_type_description   VARCHAR(250)
    ) ON COMMIT DROP;

    INSERT INTO temp_source(user_type_name, user_type_description)
    SELECT
        user_type_name,
        user_type_description
    FROM json_to_recordset(jsn) AS j(user_type_name VARCHAR(250), user_type_description VARCHAR(250));

    MERGE INTO lab.user_type AS tgt
    USING (
        SELECT DISTINCT
            tmp.user_type_name,
            tmp.user_type_description
        FROM temp_source AS tmp
    ) src
        ON (TRIM(UPPER(src.user_type_name)) = TRIM(UPPER(tgt."name")))
    WHEN MATCHED THEN
        UPDATE SET
            description     = src.user_type_description,
            sys_changed_at  = CURRENT_TIMESTAMP AT TIME ZONE 'utc'
    WHEN NOT MATCHED THEN
        INSERT (
            name,
            description
        )
        VALUES (
            src.user_type_name,
            src.user_type_description
        );
END; $$;


ALTER PROCEDURE mentor.usp_user_type_insert(IN jsn json) OWNER TO bi_admin;

SET default_tablespace = '';

SET default_table_access_method = heap;
