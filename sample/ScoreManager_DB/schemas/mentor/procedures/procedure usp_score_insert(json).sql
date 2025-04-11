/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/procedure/name/usp_score_insert(json)
  object_name: usp_score_insert(json)
  object_schema: mentor
  object_type: procedure
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE PROCEDURE mentor.usp_score_insert(IN jsn json)
    LANGUAGE plpgsql
    AS $$
DECLARE
    var_course_id_from_json     INT;
    var_subtask_id_from_json    INT;
    var_reviewer_id_from_json   INT;
    var_student_id_from_json    INT;
    var_course_id               INT;
    var_subtask_id              INT;
    var_reviewer_id             INT;
    var_student_id              INT;
    row record;
BEGIN
/*========================================================================================================================
 * Insert temp data from JSON
========================================================================================================================*/
    CREATE TEMPORARY TABLE temp_source (
        course_id       INT,
        reviewer_id     INT,
        student_id      INT,
        subtask_id      INT,
        score           NUMERIC(8,2),
        name_conv       NUMERIC(8,2),
        readability     NUMERIC(8,2),
        sarg            NUMERIC(8,2),
        schema_name     NUMERIC(8,2),
        aliases         NUMERIC(8,2),
        determ_sorting  NUMERIC(8,2),
        ontime          NUMERIC(8,2),
        extra           NUMERIC(8,2),
        "comment"       VARCHAR(2000)
    ) ON COMMIT DROP;

    INSERT INTO temp_source(
        course_id,
        reviewer_id,
        student_id,
        subtask_id,
        score,
        name_conv,
        readability,
        sarg,
        schema_name,
        aliases,
        determ_sorting,
        ontime,
        extra,
        "comment"
    )
    SELECT
        j.course_id,
        j.reviewer_id,
        j.student_id,
        j.subtask_id,
        j.score,
        j.name_conv,
        j.readability,
        j.sarg,
        j.schema_name,
        j.aliases,
        j.determ_sorting,
        j.ontime,
        j.extra,
        j."comment"
    FROM json_to_record(jsn) AS j(
        course_id       INT,
        reviewer_id     INT,
        student_id      INT,
        subtask_id      INT,
        score           NUMERIC(8,2),
        name_conv       NUMERIC(8,2),
        readability     NUMERIC(8,2),
        sarg            NUMERIC(8,2),
        schema_name     NUMERIC(8,2),
        aliases         NUMERIC(8,2),
        determ_sorting  NUMERIC(8,2),
        ontime          NUMERIC(8,2),
        extra           NUMERIC(8,2),
        "comment"       VARCHAR(2000)
    );

/*========================================================================================================================
 * Check course_id
========================================================================================================================*/

    SELECT t.course_id
    INTO var_course_id_from_json
    FROM temp_source AS t;

    SELECT c.course_id
    INTO var_course_id
    FROM lab.course AS c
    WHERE c.course_id = var_course_id_from_json;

    IF (var_course_id IS NULL)
    THEN
        RAISE EXCEPTION 'Course id: ''%'' isn''t found', var_course_id_from_json;
    END IF;

/*========================================================================================================================
 * Check reviewer_id
========================================================================================================================*/

    SELECT t.reviewer_id
    INTO var_reviewer_id_from_json
    FROM temp_source AS t;

    SELECT cs.course_staff_id
    INTO var_reviewer_id
    FROM lab.course_staff AS cs
    INNER JOIN lab.user_type AS ut
        ON ut.user_type_id = cs.user_type_id
            AND ut."name" = 'mentor'
    WHERE cs.course_staff_id = var_reviewer_id_from_json;

    IF (var_reviewer_id IS NULL)
    THEN
        RAISE EXCEPTION 'Reviewer id: ''%'' isn''t found', var_reviewer_id_from_json;
    END IF;

/*========================================================================================================================
 * Check student_id
========================================================================================================================*/

    SELECT t.student_id
    INTO var_student_id_from_json
    FROM temp_source AS t;

    SELECT cs.course_staff_id
    INTO var_student_id
    FROM lab.course_staff AS cs
    INNER JOIN lab.user_type AS ut
        ON ut.user_type_id = cs.user_type_id
            AND ut."name" = 'student'
    WHERE cs.course_staff_id = var_student_id_from_json;

    IF (var_student_id IS NULL)
    THEN
        RAISE EXCEPTION 'Student id: ''%'' isn''t found', var_student_id_from_json;
    END IF;

/*========================================================================================================================
 * Check subtask_id
========================================================================================================================*/

    SELECT t.subtask_id
    INTO var_subtask_id_from_json
    FROM temp_source AS t;

    SELECT s.subtask_id
    INTO var_subtask_id
    FROM lab.subtask AS s
    WHERE s.subtask_id = var_subtask_id_from_json;

    IF (var_subtask_id IS NULL)
    THEN
        RAISE EXCEPTION 'Subtask id: ''%'' isn''t found', var_subtask_id_from_json;
    END IF;

/*========================================================================================================================
 * Merge data
========================================================================================================================*/
    MERGE INTO lab.subtask_log AS tgt
    USING (
        SELECT
            stl.subtask_log_id,
            var_subtask_id                  AS subtask_id,
            tmp.score,
            COALESCE(tmp.ontime, 0)         AS ontime,
            COALESCE(tmp.name_conv,0)       AS name_conv,
            COALESCE(tmp.readability,0)     AS readability,
            COALESCE(tmp.sarg,0)            AS sarg,
            COALESCE(tmp.schema_name,0)     AS schema_name,
            COALESCE(tmp.aliases,0)         AS aliases,
            COALESCE(tmp.determ_sorting,0)  AS determ_sorting,
            COALESCE(tmp.extra, 0)          AS extra,
            tmp.comment
        FROM temp_source AS tmp
        LEFT JOIN lab.subtask_log AS stl
            ON stl.subtask_id = var_subtask_id
                AND stl.student_id = var_student_id
    ) as src
        ON tgt.subtask_log_id = src.subtask_log_id
    WHEN MATCHED THEN
        UPDATE SET
            reviewer_id     = var_reviewer_id,
            score           = src.score,
            ontime          = src.ontime,
            name_conv       = src.name_conv,
            readability     = src.readability,
            sarg            = src.sarg,
            schema_name     = src.schema_name,
            aliases         = src.aliases,
            determ_sort     = src.determ_sorting,
            extra           = src.extra,
            "comment"       = src."comment",
            sys_changed_at  = CURRENT_TIMESTAMP AT TIME ZONE 'utc'
    WHEN NOT MATCHED THEN
        INSERT (
            subtask_id,
            student_id,
            reviewer_id,
            score,
            ontime,
            name_conv,
            readability,
            sarg,
            schema_name,
            aliases,
            determ_sort,
            extra,
            "comment"
        )
    VALUES (
        var_subtask_id,
        var_student_id,
        var_reviewer_id,
        src.score,
        src.ontime,
        src.name_conv,
        src.readability,
        src.sarg,
        src.schema_name,
        src.aliases,
        src.determ_sorting,
        src.extra,
        src."comment"
    );

/*========================================================================================================================
 * Return result
 -- TODO: Change this part of the query
========================================================================================================================*/
FOR row IN
    SELECT
        c."name"                                AS course_name,
        reviewer."name"                         AS reviewer_name,
        student."name"                          AS student_name,
        t."name"                                AS task_name,
        st."name"                               AS subtask_name,
        stl.score                               AS score,
        stl.name_conv                           AS name_conv,
        stl.readability                         AS readability,
        stl.sarg                                AS sarg,
        stl.schema_name                         AS schema_name,
        stl.aliases                             AS aliases,
        stl.determ_sort                         AS determ_sort,
        stl.ontime                              AS ontime,
        stl.extra                               AS extra,
        COALESCE(stl.score,0)
            + COALESCE(tmp.name_conv,0)
            + COALESCE(tmp.readability,0)
            + COALESCE(tmp.sarg,0)
            + COALESCE(tmp.schema_name,0)
            + COALESCE(tmp.aliases,0)
            + COALESCE(tmp.determ_sorting,0)
            + COALESCE(tmp.ontime,0)
            + COALESCE(tmp.extra,0)             AS total_score,
        stl."comment"       AS "comment"
    FROM temp_source AS tmp
    INNER JOIN lab.subtask AS st
        ON st.subtask_id = tmp.subtask_id
    INNER JOIN lab.task AS t
        ON t.task_id = st.task_id
    INNER JOIN lab.course AS c
        ON c.course_id = t.course_id
    INNER JOIN lab.subtask_log AS stl
        ON stl.subtask_id = st.subtask_id
            AND stl.student_id = tmp.student_id
            AND stl.reviewer_id = tmp.reviewer_id
    INNER JOIN (
        SELECT cs.course_staff_id, u."name"
        FROM lab.course_staff AS cs
        INNER JOIN lab."user" AS u
            ON u.id = cs.user_id
    ) AS reviewer
        ON reviewer.course_staff_id = stl.reviewer_id
    INNER JOIN (
        SELECT cs.course_staff_id, u."name"
        FROM lab.course_staff AS cs
        INNER JOIN lab."user" AS u
            ON u.id = cs.user_id
    ) AS student
        ON student.course_staff_id = stl.student_id
LOOP
    RAISE NOTICE 'course_name: %, reviewer_name: %, student_name: %, task_name: %, subtask_name: %, score: %, name_conv: %, readability: %, sarg: %, schema_name: %, aliases: %, determ_sort: %, ontime: %, extra: %, total_score: %, comment: %',
        row.course_name,
        row.reviewer_name,
        row.student_name,
        row.task_name,
        row.subtask_name,
        row.score,
        row.name_conv,
        row.readability,
        row.sarg,
        row.schema_name,
        row.aliases,
        row.determ_sort,
        row.ontime,
        row.extra,
        row.total_score,
        row."comment";
END LOOP;

END; $$;


ALTER PROCEDURE mentor.usp_score_insert(IN jsn json) OWNER TO bi_admin;
