-- Part A: Create New Database Infrastructure
CREATE DATABASE elearning_platform;
CREATE TABLESPACE video_storage
    LOCATION '/data/videos';

-- Part B: New Table Creation
-- This tables should be created in the elearning_platform database
\c elearning_platform
CREATE TABLE online_videos (
    video_id            SERIAL,
    course_id           INT,
    video_title         VARCHAR(100),
    video_description   TEXT,
    video_duration      TIME,
    file_size           BIGINT,
    upload_date         DATE,
    is_public           BOOLEAN,
    view_count          INT
);
CREATE TABLE student_progress (
    progress_id         INT,
    student_id          INT,
    video_id            INT,
    watch_percentage    DECIMAL(1),
    last_watched        TIMESTAMPTZ,
    completed           BOOLEAN,
    notes               TEXT,
    bookmark_time       TIME
);

-- Part C: Modify Existing Tables
-- This actions should be done in the university_main database
\c university_main
ALTER TABLE courses ADD COLUMN
    is_online_available BOOLEAN
    DEFAULT false;
ALTER TABLE courses ADD COLUMN
    platform_url VARCHAR(200);
ALTER TABLE courses ALTER COLUMN
    description
    SET DEFAULT 'No description available';
ALTER TABLE students ADD COLUMN
    preferred_language CHAR(5);
ALTER TABLE students ADD COLUMN
    last_login TIMESTAMP;

-- Part D: Quick Data Type Challenge
-- This table should be created in the elearning_platform database
\c elearning_platform
CREATE TABLE quiz_attempts (
    attempt_id      SERIAL,
    student_id      INT,
    quiz_name       VARCHAR(80),
    start_time      TIMESTAMPTZ,
    duration        INTERVAL,
    score           DECIMAL(2),
    passed_status   BOOLEAN,
    attempt_number  SMALLINT
);
