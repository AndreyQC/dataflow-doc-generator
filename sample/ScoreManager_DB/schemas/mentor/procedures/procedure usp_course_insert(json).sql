/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/procedure/name/usp_course_insert(json)
  object_name: usp_course_insert(json)
  object_schema: mentor
  object_type: procedure
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE PROCEDURE mentor.usp_course_insert(IN jsn json)
    LANGUAGE plpgsql
    AS $$
BEGIN
/*========================================================================================================================
 * Insert temp data from JSON
========================================================================================================================*/
    DROP TABLE IF EXISTS temp_source;
    CREATE TEMPORARY TABLE temp_source (
        course_name         VARCHAR(250),
        course_datestart    DATE,
        course_datefinish   DATE
    ) ON COMMIT DROP;

    INSERT INTO temp_source(course_name, course_datestart, course_datefinish)
    SELECT
        course_name,
        course_datestart,
        course_datefinish
    FROM json_to_recordset(jsn) AS j(course_name VARCHAR(250), course_datestart DATE, course_datefinish DATE);

/*========================================================================================================================
 * Merge data to target table
========================================================================================================================*/
    MERGE INTO lab.course AS tgt
    USING (
        SELECT DISTINCT
            tmp.course_name,
            tmp.course_datestart,
            tmp.course_datefinish
        FROM temp_source AS tmp
    ) src
        ON (TRIM(UPPER(src.course_name)) = TRIM(UPPER(tgt."name")))
    WHEN MATCHED THEN
        UPDATE SET
            datestart       = src.course_datestart,
            datefinish      = src.course_datefinish,
            sys_changed_at  = CURRENT_TIMESTAMP AT TIME ZONE 'utc'
    WHEN NOT MATCHED THEN
        INSERT (
            name,
            datestart,
            datefinish
        )
        VALUES (
            src.course_name,
            src.course_datestart,
            src.course_datefinish
        );
END; $$;


ALTER PROCEDURE mentor.usp_course_insert(IN jsn json) OWNER TO bi_admin;
