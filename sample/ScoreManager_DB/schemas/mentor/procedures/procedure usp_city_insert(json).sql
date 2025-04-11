/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/procedure/name/usp_city_insert(json)
  object_name: usp_city_insert(json)
  object_schema: mentor
  object_type: procedure
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE PROCEDURE mentor.usp_city_insert(IN jsn json)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DROP TABLE IF EXISTS temp_source;
    CREATE TEMPORARY TABLE temp_source (
        city_name           VARCHAR(100)
        , geo_point         TEXT
    ) ON COMMIT DROP;

    INSERT INTO temp_source(city_name, geo_point)
    SELECT
        city_name
        , geo_point
    FROM json_to_recordset(jsn) AS j(city_name VARCHAR(100), geo_point TEXT);

    MERGE INTO lab.city AS tgt
    USING (
        SELECT DISTINCT
            tmp.city_name
            , tmp.geo_point
        FROM temp_source AS tmp
    ) src
        ON (TRIM(UPPER(src.city_name)) = TRIM(UPPER(tgt."name")))
    WHEN MATCHED THEN
        UPDATE SET
            geo_point = src.geo_point
            , sys_changed_at  = CURRENT_TIMESTAMP AT TIME ZONE 'utc'
    WHEN NOT MATCHED THEN
        INSERT (
            "name"
            , geo_point
        )
        VALUES (
            src.city_name
            , geo_point
        );
END; $$;


ALTER PROCEDURE mentor.usp_city_insert(IN jsn json) OWNER TO bi_admin;
