/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/procedure/name/usp_task_subtask_insert(json)
  object_name: usp_task_subtask_insert(json)
  object_schema: mentor
  object_type: procedure
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE PROCEDURE mentor.usp_task_subtask_insert(IN jsn json)
    LANGUAGE plpgsql
    AS $$
    DECLARE     
        no_matched_bonus_from_json          VARCHAR(250)    := '';
        no_matched_task_topic_from_json     VARCHAR(250)    := '';
        no_matched_course_from_json         VARCHAR(250)    := '';
        no_matched_subtask_topic_from_json  VARCHAR(250)    := '';
        existed_task_id                     INT             := -1;
        task_id_for_subtask                 INT             := -1;
        row                                 record;
BEGIN
/*========================================================================================================================
 * Insert temp data from JSON
========================================================================================================================*/

    CREATE TEMPORARY TABLE temp_source (
        course_name         VARCHAR(250),
        task_name           VARCHAR(100),
        task_description    VARCHAR(100),
        task_topic          VARCHAR(250),
        subtask_name        VARCHAR(250),
        subtask_description TEXT,
        subtask_topic       VARCHAR(250),
        subtask_max_score   NUMERIC(8,2),
        bonus               VARCHAR(250)
    ) ON COMMIT DROP;

    INSERT INTO temp_source(
        course_name,
        task_name,
        task_description,
        task_topic,
        subtask_name,
        subtask_description,
        subtask_topic,
        subtask_max_score,
        bonus            
    )
    SELECT
        root_l.course_name,
        root_l.task_name,
        root_l.task_description,
        root_l.task_topic,
        lief_l.subtask_name,
        lief_l.subtask_description,
        lief_l.subtask_topic,
        lief_l.subtask_max_score,
        json_array_elements_text(lief_l.bonuses) AS bonus
    FROM 
        json_to_record(jsn) AS root_l(
            course_name         VARCHAR(250),
            task_name           VARCHAR(100),
            task_description    VARCHAR(100),
            task_topic          VARCHAR(250)
        )
    LEFT JOIN (
        SELECT * 
        FROM json_to_recordset(
                json_extract_path(jsn, 'subtasks')
                ) AS lief_l(
                    subtask_name        VARCHAR(250),
                    subtask_description TEXT,
                    subtask_topic       VARCHAR(250),
                    subtask_max_score   NUMERIC(8,2),
                    bonuses             JSON)
    ) AS lief_l
        ON 1 = 1;

/*========================================================================================================================
 * Check task_topic names
========================================================================================================================*/
    SELECT tmp.task_topic
    INTO no_matched_task_topic_from_json
    FROM temp_source AS tmp
    LEFT JOIN lab.topic AS tt ON TRIM(UPPER(tt."name")) = TRIM(UPPER(tmp.task_topic))
    WHERE tmp.task_topic IS NOT NULL
        AND tt.topic_id IS NULL
    LIMIT 1;

    IF (no_matched_task_topic_from_json IS NOT NULL)
    THEN
        RAISE EXCEPTION 'Task topic: ''%'' isn''t found', no_matched_task_topic_from_json;
    END IF;    

/*========================================================================================================================
 * Check subtask_topic names
========================================================================================================================*/
    SELECT tmp.subtask_topic
    INTO no_matched_subtask_topic_from_json
    FROM temp_source AS tmp
    LEFT JOIN lab.topic AS stt ON TRIM(UPPER(stt."name")) = TRIM(UPPER(tmp.subtask_topic))
    WHERE tmp.subtask_topic IS NOT NULL
        AND stt.topic_id IS NULL
    LIMIT 1;

    IF (no_matched_subtask_topic_from_json IS NOT NULL)
    THEN
        RAISE EXCEPTION 'Subtask topic: ''%'' isn''t found', no_matched_subtask_topic_from_json;
    END IF;

/*========================================================================================================================
 * Check course
========================================================================================================================*/
    SELECT tmp.course_name
    INTO no_matched_course_from_json
    FROM temp_source AS tmp
    LEFT JOIN lab.course AS c ON TRIM(UPPER(c."name")) = TRIM(UPPER(tmp.course_name))
    WHERE tmp.course_name IS NOT NULL
        AND c."name" IS NULL
    LIMIT 1;

    IF (no_matched_course_from_json IS NOT NULL)
    THEN
        RAISE EXCEPTION 'Course: ''%'' isn''t found', no_matched_course_from_json;
    END IF;  

/*========================================================================================================================
 * Insert task
========================================================================================================================*/
    --Create temporary table for Task
    CREATE TEMPORARY TABLE temp_task_result(
        task_id     INTEGER,
        "action"    TEXT
    ) ON COMMIT DROP;

    -- Get existed task_id
    SELECT 
        t.task_id
    INTO existed_task_id
    FROM temp_source AS tmp
    JOIN lab.course AS c ON c."name" = tmp.course_name
    JOIN lab.topic AS tt ON TRIM(UPPER(tt."name")) = TRIM(UPPER(tmp.task_topic))
    JOIN lab.task AS t ON t.course_id = c.course_id
        AND t."name" = tmp.task_name
    LIMIT 1;
    
    -- Merge data
    WITH inserted AS (
        INSERT INTO lab.task(course_id, "name", "description", topic_id)
        SELECT 
            c.course_id,
            tmp.task_name,
            tmp.task_description,
            tt.topic_id
        FROM (SELECT DISTINCT 
                course_name, 
                task_name, 
                task_description, 
                task_topic
            FROM temp_source
        ) AS tmp
        JOIN lab.course AS c ON c.name = tmp.course_name
        JOIN lab.topic AS tt ON TRIM(UPPER(tt.name)) = TRIM(UPPER(tmp.task_topic))
        LEFT JOIN lab.task AS t ON t.course_id = c.course_id
            AND t."name" = tmp.task_name
        ON CONFLICT (course_id, "name")
            DO UPDATE SET
                description = excluded.description,
                topic_id = excluded.topic_id,
                sys_changed_at = NOW()
                WHERE lab.task.course_id = excluded.course_id
                    AND lab.task."name" = excluded."name"
        RETURNING task_id, 'inserted' AS action
    )
    INSERT INTO temp_task_result(task_id, "action")
    SELECT task_id, action FROM inserted; 
    
    -- Get task_id for inserting into subtask
    IF (existed_task_id IS NOT NULL)
    THEN 
        SELECT existed_task_id INTO task_id_for_subtask;
    ELSE
        SELECT task_id INTO task_id_for_subtask FROM temp_task_result;
    END IF;

/*========================================================================================================================
 * Insert subtask
========================================================================================================================*/
    --Create temporary table for Subtask
    CREATE TEMPORARY TABLE temp_subtask_result(
        subtask_id      INTEGER,
        subtask_name    VARCHAR(250),
        "action"        TEXT
    ) ON COMMIT DROP;

    -- Merge data
    WITH inserted AS (
        INSERT INTO lab.subtask(task_id, "name", "description", topic_id, max_score)
        SELECT DISTINCT
            task_id_for_subtask                         AS task_id,
            tmp.subtask_name                            AS "name",
            tmp.subtask_description                     AS description,
            stt.topic_id                                AS topic_id,
            tmp.subtask_max_score                       AS max_score
        FROM (
            SELECT DISTINCT 
                subtask_name,
                subtask_description,
                subtask_max_score,
                subtask_topic
            FROM temp_source) AS tmp
        JOIN lab.topic AS stt ON TRIM(UPPER(stt."name")) = TRIM(UPPER(tmp.subtask_topic))
        LEFT JOIN lab.subtask AS st 
            ON st."name" = tmp.subtask_name
                AND st.task_id = task_id_for_subtask
        ON CONFLICT (task_id, "name")
            DO UPDATE SET
                description = excluded.description,
                topic_id = excluded.topic_id,
                max_score = excluded.max_score,
                sys_changed_at = NOW()
                WHERE lab.subtask.task_id = excluded.task_id
                    AND lab.subtask."name" = excluded."name"
        RETURNING subtask_id, "name", max_score, 'inserted' AS ACTION
    )
    INSERT INTO temp_subtask_result(subtask_id, subtask_name, action)
    SELECT subtask_id, "name", action FROM inserted; 
        
/*========================================================================================================================
 * Check bonus names
========================================================================================================================*/
    SELECT tmp.bonus
    INTO no_matched_bonus_from_json
    FROM temp_source AS tmp
    LEFT JOIN lab.bonus AS b ON TRIM(UPPER(b."name")) = TRIM(UPPER(tmp.bonus))
    WHERE tmp.bonus IS NOT NULL
        AND b.bonus_id IS NULL
    LIMIT 1;

    IF (no_matched_bonus_from_json IS NOT NULL)
    THEN
        RAISE EXCEPTION 'Bonus: ''%'' isn''t found', no_matched_bonus_from_json;
    END IF;                

/*========================================================================================================================
 * Merge subtask_bonus
========================================================================================================================*/

MERGE INTO lab.subtask_bonus AS tgt
    USING (
        SELECT
            tsr.subtask_id,
            b.bonus_id
        FROM temp_subtask_result tsr
        INNER JOIN temp_source AS tmp 
            ON tmp.subtask_name = tsr.subtask_name
        LEFT JOIN lab.bonus AS b ON b."name" = tmp.bonus
        WHERE tmp.bonus IS NOT NULL
    ) src 
        ON (src.subtask_id = tgt.subtask_id 
            AND src.bonus_id = tgt.bonus_id)
    WHEN NOT MATCHED THEN
        INSERT (
            subtask_id,
            bonus_id
        ) 
        VALUES (
            src.subtask_id,
            src.bonus_id
        );
    
/*========================================================================================================================
 * Delete not matched bonuses from lab.subtask_bonus
========================================================================================================================*/

DELETE FROM lab.subtask_bonus
WHERE subtask_bonus_id IN ( 
    SELECT stb.subtask_bonus_id
    FROM lab.subtask_bonus AS stb
    INNER JOIN lab.bonus AS b ON b.bonus_id = stb.bonus_id
    INNER JOIN temp_subtask_result AS tsr ON tsr.subtask_id = stb.subtask_id
    LEFT JOIN temp_source AS tmp ON tmp.subtask_name = tsr.subtask_name
        AND TRIM(UPPER(tmp.bonus)) = TRIM(UPPER(b."name"))
    WHERE tmp.bonus IS NULL);                
END; $$;


ALTER PROCEDURE mentor.usp_task_subtask_insert(IN jsn json) OWNER TO bi_admin;
