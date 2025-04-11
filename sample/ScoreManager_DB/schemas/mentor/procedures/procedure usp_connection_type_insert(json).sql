/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/procedure/name/usp_connection_type_insert(json)
  object_name: usp_connection_type_insert(json)
  object_schema: mentor
  object_type: procedure
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE PROCEDURE mentor.usp_connection_type_insert(IN jsn json)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DROP TABLE IF EXISTS temp_source;
    CREATE TEMPORARY TABLE temp_source (
        connection_type_name          VARCHAR(250),
        connection_type_description   VARCHAR(250)
    ) ON COMMIT DROP;

    INSERT INTO temp_source(connection_type_name, connection_type_description)
    SELECT
        connection_type_name,
        connection_type_description
    FROM json_to_recordset(jsn) AS j(connection_type_name VARCHAR(250), connection_type_description VARCHAR(250));

    MERGE INTO lab.connection_type AS tgt
    USING (
        SELECT DISTINCT
            tmp.connection_type_name,
            tmp.connection_type_description
        FROM temp_source AS tmp
    ) src
        ON (TRIM(UPPER(src.connection_type_name)) = TRIM(UPPER(tgt."name")))
    WHEN MATCHED THEN
        UPDATE SET
            description     = src.connection_type_description,
            sys_changed_at  = CURRENT_TIMESTAMP AT TIME ZONE 'utc'
    WHEN NOT MATCHED THEN
        INSERT (
            name,
            description
        )
        VALUES (
            src.connection_type_name,
            src.connection_type_description
        );
END; $$;


ALTER PROCEDURE mentor.usp_connection_type_insert(IN jsn json) OWNER TO bi_admin;
