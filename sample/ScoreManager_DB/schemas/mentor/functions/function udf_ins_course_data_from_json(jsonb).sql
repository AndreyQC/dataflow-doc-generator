/*====================================================================================
[<[autodoc-yaml]]
object:
  object_catalog: ScoreManager_DB
  object_key: pg_database/ScoreManager_DB/schema/mentor/type/function/name/udf_ins_course_data_from_json(jsonb)
  object_name: udf_ins_course_data_from_json(jsonb)
  object_schema: mentor
  object_type: function
project:
  build: true

[[autodoc-yaml]>]
=====================================================================================*/

CREATE FUNCTION mentor.udf_ins_course_data_from_json(p_parameters_json jsonb) RETURNS json
    LANGUAGE plpgsql
    AS $_$
/*=============================================================================
* p_parameters_json
* example p_parameters_json {
    "course_name":"BI.RD.LAB.2024.1",
    "course_datestart":"2024-10-21",
    "course_datefinish": "2025-02-28",
    "course_desc":"Course BI.RD.LAB.2024.1",
    "course_staff": [
        {
            "username": "Sergei Boikov",
            "user_email": "sergei_boikov@rntgroup.com",
            "user_password": "sha256$2cCnKvMl70MK1NBT$1f793dfc589af54b09642fb2d830db67ecad3cfeab37ad5b2587d16e4af97fd1",
            "user_type": "mentor",
            "user_city": "Saratov",
            "notes": "Notes for Sergei Boikov",
            "is_active": "true"
        }
    ],
    "tasks": [
        {
            "task_name": "03.SQL_Foundation.Homework.01",
            "task_description": "SQL Basics",
            "task_topic": "Module #3: SQL Foundation",
            "subtask_name": "Subtask.01",
            "subtask_description": "Basic SQL queries",
            "subtask_topic": "SQL",
            "subtask_max_score": 11,
            "subtask_bonuses": [
                {
                    "bonus_name": "Aliases"
                },
                {
                    "bonus_name": "Sargable"
                }
            ],
            "check_script": {
                "check_script_type": "SQL",
                "check_script_connection_name": "con_db_dvdrental",
                "check_script_description": "Basic SQL queries",
                "check_script_text": "SELECT * FROM table;"
            }
        }
    ]
}
* example of RETURN
* {"query_result" : "success"}
*
=============================================================================*/

DECLARE
    v_course_id INT;
    v_city_id INT;
    v_user_id INT;
    v_user_type_id INT;
    v_task_topic_id INT;
    v_task_id INT;
    v_check_script_id INT;
    v_check_script_type_id INT;
    v_connection_id INT;
    v_bonus_id INT;
    v_subtask_topic_id INT;
    v_subtask_id INT;

    v_staff_json JSONB;
    v_task_json JSONB;
    v_check_script_json JSONB;
    v_bonus_json JSONB;

    v_query_result TEXT;
BEGIN

    --====================================================================
    -- predefine
    --====================================================================
    v_query_result := 'failed';

    --=============================================================================
    -- Merge course data
    --=============================================================================

    -- Check if course already exists
    SELECT c.course_id INTO v_course_id
    FROM lab.course AS c
    WHERE c.name = p_parameters_json ->> 'course_name';

    IF v_course_id IS NOT NULL THEN
        RAISE EXCEPTION 'Course "%" already exists', p_parameters_json ->> 'course_name';
    END IF;

    INSERT INTO lab.course (
        name,
        datestart,
        datefinish,
        description
    )
    VALUES (
        p_parameters_json ->> 'course_name',
        (p_parameters_json ->> 'course_datestart')::DATE,
        (p_parameters_json ->> 'course_datefinish')::DATE,
        p_parameters_json ->> 'course_desc'
    )
    RETURNING course_id INTO v_course_id;

    --=============================================================================
    -- Merge course staff data
    --=============================================================================

    FOR v_staff_json IN SELECT * FROM jsonb_array_elements(p_parameters_json -> 'course_staff') LOOP

        -- Validate city
        SELECT c.city_id INTO v_city_id
        FROM lab.city AS c
        WHERE c.name = v_staff_json ->> 'user_city';

        IF v_city_id IS NULL THEN
            RAISE EXCEPTION 'City "%" not found', v_staff_json ->> 'user_city';
        END IF;

        --Validate user type
        SELECT ut.user_type_id INTO v_user_type_id
        FROM lab.user_type AS ut
        WHERE ut.name = v_staff_json ->> 'user_type';

        IF v_user_type_id IS NULL THEN
            RAISE EXCEPTION 'User type "%" not found', v_staff_json ->> 'user_type';
        END IF;

        --=============================================================================
        -- Merge user data
        --=============================================================================

        INSERT INTO lab.user (
            name,
            email,
            city_id,
            notes,
            password,
            is_active
        ) VALUES (
            v_staff_json ->> 'username',
            v_staff_json ->> 'user_email',
            v_city_id,
            v_staff_json ->> 'notes',
            v_staff_json ->> 'user_password',  --< Password is for insert records only
            (v_staff_json ->> 'is_active')::BOOLEAN
        ) ON CONFLICT (email) DO UPDATE
        SET
            name = EXCLUDED.name,
            city_id = EXCLUDED.city_id,
            notes = EXCLUDED.notes,
            is_active = EXCLUDED.is_active::BOOLEAN,
            sys_changed_at = CURRENT_TIMESTAMP AT TIME ZONE 'utc'
        RETURNING id INTO v_user_id;

        --=============================================================================
        -- Merge course staff data
        --=============================================================================

        INSERT INTO lab.course_staff (
            course_id,
            user_id,
            user_type_id
        ) VALUES (
            v_course_id,
            v_user_id,
            v_user_type_id
        ) ON CONFLICT (course_id, user_id) DO UPDATE
        SET
            user_type_id = EXCLUDED.user_type_id,
            sys_changed_at = CURRENT_TIMESTAMP AT TIME ZONE 'utc';
    END LOOP;

    --=============================================================================
    -- Merge tasks data
    --=============================================================================

    FOR v_task_json IN SELECT * FROM jsonb_array_elements(p_parameters_json -> 'tasks') LOOP

        -- Validate task topic
        SELECT t.topic_id INTO v_task_topic_id
        FROM lab.topic AS t
        WHERE t.name = v_task_json ->> 'task_topic'
            AND t.is_topic_for_tasks = TRUE;

        IF v_task_topic_id IS NULL THEN
            RAISE EXCEPTION 'Task topic "%" not found', v_task_json ->> 'task_topic';
        END IF;

        -- Validate subtask topic
        SELECT t.topic_id INTO v_subtask_topic_id
        FROM lab.topic AS t
        WHERE t.name = v_task_json ->> 'subtask_topic'
            AND t.is_topic_for_subtasks = TRUE;

        IF v_subtask_topic_id IS NULL THEN
            RAISE EXCEPTION 'Subtask topic "%" not found', v_task_json ->> 'subtask_topic';
        END IF;

        --=============================================================================
        -- Merge task
        --=============================================================================

        INSERT INTO lab.task (
            course_id,
            name,
            description,
            topic_id
        ) VALUES (
            v_course_id,
            v_task_json ->> 'task_name',
            v_task_json ->> 'task_description',
            v_task_topic_id
        ) ON CONFLICT (course_id, name) DO UPDATE
        SET
            description = EXCLUDED.description,
            topic_id = EXCLUDED.topic_id,
            sys_changed_at = CURRENT_TIMESTAMP AT TIME ZONE 'utc'
        RETURNING task_id INTO v_task_id;

        --=============================================================================
        -- Merge check script data
        --=============================================================================

        -- Get check script data
        v_check_script_json := v_task_json ->> 'check_script';
        IF v_check_script_json IS NOT NULL THEN
            -- Validate connection
            SELECT c.connection_id INTO v_connection_id
            FROM lab.connection AS c
            WHERE c.connection_name = v_check_script_json ->> 'check_script_connection_name';
    
            IF v_connection_id IS NULL THEN
                RAISE EXCEPTION 'Connection "%" not found', v_check_script_json ->> 'check_script_connection_name';
            END IF;
    
            -- Validate check script type
            SELECT cst.check_script_type_id INTO v_check_script_type_id
            FROM lab.check_script_type AS cst
            WHERE cst.name = v_check_script_json ->> 'check_script_type';
    
            IF v_check_script_type_id IS NULL THEN
                RAISE EXCEPTION 'Check script type "%" not found', v_check_script_json ->> 'check_script_type';
            END IF;
    
            -- Merge check script
            INSERT INTO lab.check_script (
                "text",
                description,
                connection_id,
                check_script_type_id
            ) VALUES (
                v_check_script_json ->> 'check_script_text',
                v_check_script_json ->> 'check_script_description',
                v_connection_id,
                v_check_script_type_id
            ) ON CONFLICT (description) DO UPDATE
            SET
                "text" = EXCLUDED."text",
                connection_id = EXCLUDED.connection_id,
                check_script_type_id = EXCLUDED.check_script_type_id,
                sys_changed_at = CURRENT_TIMESTAMP AT TIME ZONE 'utc'
            RETURNING check_script_id INTO v_check_script_id;
        END IF;
        

        --=============================================================================
        -- Merge subtask
        --=============================================================================

        INSERT INTO lab.subtask (
            task_id,
            name,
            description,
            topic_id,
            check_script_id,
            max_score
        ) VALUES (
            v_task_id,
            v_task_json ->> 'subtask_name',
            v_task_json ->> 'subtask_description',
            v_subtask_topic_id,
            v_check_script_id,
            (v_task_json ->> 'subtask_max_score')::NUMERIC(8,2)
        ) ON CONFLICT (task_id, name) DO UPDATE
        SET
            description = EXCLUDED.description,
            topic_id = EXCLUDED.topic_id,
            check_script_id = EXCLUDED.check_script_id,
            max_score = EXCLUDED.max_score,
            sys_changed_at = CURRENT_TIMESTAMP AT TIME ZONE 'utc'
        RETURNING subtask_id INTO v_subtask_id;

        --=============================================================================
        -- Merge subtask-bonus
        --=============================================================================

        FOR v_bonus_json IN SELECT * FROM jsonb_array_elements(v_task_json -> 'subtask_bonuses') LOOP

            -- Validate bonus
            SELECT b.bonus_id INTO v_bonus_id
            FROM lab.bonus AS b
            WHERE b.name = v_bonus_json ->> 'bonus_name';

            IF v_bonus_id IS NULL THEN
                RAISE EXCEPTION 'Bonus "%" not found', v_bonus_json ->> 'bonus_name';
            END IF;

            -- Merge subtask-bonus
            INSERT INTO lab.subtask_bonus (
                subtask_id,
                bonus_id
            ) VALUES (
                v_subtask_id,
                v_bonus_id
            ) ON CONFLICT (subtask_id, bonus_id) DO UPDATE
            SET
                sys_changed_at = CURRENT_TIMESTAMP AT TIME ZONE 'utc';
        END LOOP;
    END LOOP;

    v_query_result := 'success';

    RETURN JSON_BUILD_OBJECT (
        'query_result', v_query_result,
        'course_id', v_course_id
    );

END;
$_$;


ALTER FUNCTION mentor.udf_ins_course_data_from_json(p_parameters_json jsonb) OWNER TO bi_admin;
