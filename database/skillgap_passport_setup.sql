-- SkillGap Passport: initial database setup
-- Compatible with XAMPP MariaDB / MySQL
-- Run this against the empty database named: skillgap_passport

SET NAMES utf8mb4;
-- 1. USER ACCOUNTS
CREATE TABLE IF NOT EXISTS users (
    user_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    roll_number VARCHAR(30) NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    department VARCHAR(100) NULL,
    college_name VARCHAR(150) NULL,
    graduation_year SMALLINT UNSIGNED NULL,
    current_semester TINYINT UNSIGNED NULL,
    bio TEXT NULL,
    profile_image VARCHAR(500) NULL,
    role ENUM('student','mentor','admin') NOT NULL DEFAULT 'student',
    account_status ENUM('active','blocked') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. SKILL CATEGORIES
CREATE TABLE IF NOT EXISTS skill_categories (
    category_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. SKILLS
CREATE TABLE IF NOT EXISTS skills (
    skill_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_id INT UNSIGNED NULL,
    skill_name VARCHAR(120) NOT NULL UNIQUE,
    description TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_skills_category FOREIGN KEY (category_id)
        REFERENCES skill_categories(category_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. CAREER / JOB ROLES
CREATE TABLE IF NOT EXISTS job_roles (
    job_role_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(120) NOT NULL UNIQUE,
    career_field VARCHAR(100) NOT NULL,
    short_description VARCHAR(500) NULL,
    responsibilities TEXT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. SKILLS REQUIRED FOR EACH CAREER ROLE
CREATE TABLE IF NOT EXISTS role_skills (
    role_skill_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    job_role_id INT UNSIGNED NOT NULL,
    skill_id INT UNSIGNED NOT NULL,
    required_level TINYINT UNSIGNED NOT NULL DEFAULT 3 COMMENT 'Scale: 0 to 5',
    importance_weight DECIMAL(5,2) NOT NULL DEFAULT 1.00,
    UNIQUE KEY uq_role_skill (job_role_id, skill_id),
    CONSTRAINT fk_role_skills_role FOREIGN KEY (job_role_id)
        REFERENCES job_roles(job_role_id) ON DELETE CASCADE,
    CONSTRAINT fk_role_skills_skill FOREIGN KEY (skill_id)
        REFERENCES skills(skill_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. STUDENT SKILL PROFILE
CREATE TABLE IF NOT EXISTS user_skills (
    user_skill_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    skill_id INT UNSIGNED NOT NULL,
    self_assessed_level TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Scale: 0 to 5',
    verified_level TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Scale: 0 to 5; changed after evidence review',
    last_assessed_at DATETIME NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_user_skill (user_id, skill_id),
    CONSTRAINT fk_user_skills_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_user_skills_skill FOREIGN KEY (skill_id)
        REFERENCES skills(skill_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. ASSESSMENT ATTEMPTS
CREATE TABLE IF NOT EXISTS assessments (
    assessment_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    job_role_id INT UNSIGNED NOT NULL,
    status ENUM('in_progress','completed','abandoned') NOT NULL DEFAULT 'in_progress',
    readiness_score DECIMAL(5,2) NULL,
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME NULL,
    CONSTRAINT fk_assessments_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_assessments_role FOREIGN KEY (job_role_id)
        REFERENCES job_roles(job_role_id) ON DELETE RESTRICT,
    KEY idx_assessments_user_date (user_id, started_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. QUESTION BANK (MCQ, scenario and short-answer questions)
CREATE TABLE IF NOT EXISTS assessment_questions (
    question_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    skill_id INT UNSIGNED NOT NULL,
    question_type ENUM('multiple_choice','scenario','short_answer') NOT NULL DEFAULT 'multiple_choice',
    question_text TEXT NOT NULL,
    difficulty ENUM('beginner','intermediate','advanced') NOT NULL DEFAULT 'beginner',
    target_level TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Suggested proficiency level: 0 to 5',
    points DECIMAL(6,2) NOT NULL DEFAULT 1.00,
    explanation TEXT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_questions_skill FOREIGN KEY (skill_id)
        REFERENCES skills(skill_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. OPTIONS FOR MULTIPLE-CHOICE QUESTIONS
CREATE TABLE IF NOT EXISTS assessment_options (
    option_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    question_id INT UNSIGNED NOT NULL,
    option_text TEXT NOT NULL,
    is_correct TINYINT(1) NOT NULL DEFAULT 0,
    option_order TINYINT UNSIGNED NOT NULL DEFAULT 1,
    CONSTRAINT fk_options_question FOREIGN KEY (question_id)
        REFERENCES assessment_questions(question_id) ON DELETE CASCADE,
    KEY idx_options_question (question_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. STUDENT ANSWERS
CREATE TABLE IF NOT EXISTS assessment_answers (
    answer_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    assessment_id INT UNSIGNED NOT NULL,
    question_id INT UNSIGNED NOT NULL,
    selected_option_id INT UNSIGNED NULL,
    answer_text TEXT NULL,
    is_correct TINYINT(1) NULL,
    earned_points DECIMAL(6,2) NOT NULL DEFAULT 0.00,
    answered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_assessment_question (assessment_id, question_id),
    CONSTRAINT fk_answers_assessment FOREIGN KEY (assessment_id)
        REFERENCES assessments(assessment_id) ON DELETE CASCADE,
    CONSTRAINT fk_answers_question FOREIGN KEY (question_id)
        REFERENCES assessment_questions(question_id) ON DELETE CASCADE,
    CONSTRAINT fk_answers_option FOREIGN KEY (selected_option_id)
        REFERENCES assessment_options(option_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 11. SKILL-BY-SKILL RESULTS FOR AN ASSESSMENT
CREATE TABLE IF NOT EXISTS assessment_results (
    result_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    assessment_id INT UNSIGNED NOT NULL,
    skill_id INT UNSIGNED NOT NULL,
    current_level TINYINT UNSIGNED NOT NULL DEFAULT 0,
    required_level TINYINT UNSIGNED NOT NULL DEFAULT 3,
    gap_level TINYINT UNSIGNED NOT NULL DEFAULT 0,
    coverage_percent DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    UNIQUE KEY uq_assessment_result_skill (assessment_id, skill_id),
    CONSTRAINT fk_results_assessment FOREIGN KEY (assessment_id)
        REFERENCES assessments(assessment_id) ON DELETE CASCADE,
    CONSTRAINT fk_results_skill FOREIGN KEY (skill_id)
        REFERENCES skills(skill_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 12. STUDENT EVIDENCE SUBMISSIONS
CREATE TABLE IF NOT EXISTS evidence_submissions (
    evidence_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    skill_id INT UNSIGNED NOT NULL,
    project_id INT UNSIGNED NULL,
    evidence_type ENUM('github','portfolio','project_link','document_link','description') NOT NULL,
    title VARCHAR(180) NOT NULL,
    evidence_url VARCHAR(1000) NULL,
    description TEXT NULL,
    status ENUM('pending','under_review','verified','changes_requested','rejected') NOT NULL DEFAULT 'pending',
    submitted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_evidence_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_evidence_skill FOREIGN KEY (skill_id)
        REFERENCES skills(skill_id) ON DELETE RESTRICT,
    KEY idx_evidence_user_status (user_id, status),
    KEY idx_evidence_project (project_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 13. EVIDENCE REVIEW HISTORY
CREATE TABLE IF NOT EXISTS evidence_reviews (
    review_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    evidence_id INT UNSIGNED NOT NULL,
    reviewer_id INT UNSIGNED NOT NULL,
    decision ENUM('verified','changes_requested','rejected') NOT NULL,
    reviewer_feedback TEXT NULL,
    reviewed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reviews_evidence FOREIGN KEY (evidence_id)
        REFERENCES evidence_submissions(evidence_id) ON DELETE CASCADE,
    CONSTRAINT fk_reviews_reviewer FOREIGN KEY (reviewer_id)
        REFERENCES users(user_id) ON DELETE RESTRICT,
    KEY idx_reviews_evidence_date (evidence_id, reviewed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 14. PRACTICAL PROJECT CATALOGUE
CREATE TABLE IF NOT EXISTS projects (
    project_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(180) NOT NULL,
    slug VARCHAR(200) NOT NULL UNIQUE,
    description TEXT NOT NULL,
    difficulty ENUM('beginner','intermediate','advanced') NOT NULL DEFAULT 'beginner',
    estimated_hours SMALLINT UNSIGNED NULL,
    prerequisites TEXT NULL,
    instructions LONGTEXT NULL,
    completion_criteria TEXT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add the optional project reference now that the projects table exists.
ALTER TABLE evidence_submissions
    ADD CONSTRAINT fk_evidence_project FOREIGN KEY (project_id)
    REFERENCES projects(project_id) ON DELETE SET NULL;

-- 15. SKILLS DEVELOPED BY EACH PROJECT
CREATE TABLE IF NOT EXISTS project_skills (
    project_skill_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    project_id INT UNSIGNED NOT NULL,
    skill_id INT UNSIGNED NOT NULL,
    target_level TINYINT UNSIGNED NOT NULL DEFAULT 2,
    UNIQUE KEY uq_project_skill (project_id, skill_id),
    CONSTRAINT fk_project_skills_project FOREIGN KEY (project_id)
        REFERENCES projects(project_id) ON DELETE CASCADE,
    CONSTRAINT fk_project_skills_skill FOREIGN KEY (skill_id)
        REFERENCES skills(skill_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 16. LEARNING RESOURCES
CREATE TABLE IF NOT EXISTS learning_resources (
    resource_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(180) NOT NULL,
    resource_type ENUM('documentation','article','video','course','practice') NOT NULL DEFAULT 'documentation',
    provider VARCHAR(120) NULL,
    resource_url VARCHAR(1000) NOT NULL,
    description TEXT NULL,
    is_free TINYINT(1) NOT NULL DEFAULT 1,
    estimated_minutes SMALLINT UNSIGNED NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 17. SKILLS COVERED BY EACH LEARNING RESOURCE
CREATE TABLE IF NOT EXISTS resource_skills (
    resource_skill_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    resource_id INT UNSIGNED NOT NULL,
    skill_id INT UNSIGNED NOT NULL,
    UNIQUE KEY uq_resource_skill (resource_id, skill_id),
    CONSTRAINT fk_resource_skills_resource FOREIGN KEY (resource_id)
        REFERENCES learning_resources(resource_id) ON DELETE CASCADE,
    CONSTRAINT fk_resource_skills_skill FOREIGN KEY (skill_id)
        REFERENCES skills(skill_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 18. PERSONALIZED CAREER ROADMAPS
CREATE TABLE IF NOT EXISTS roadmaps (
    roadmap_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    job_role_id INT UNSIGNED NOT NULL,
    assessment_id INT UNSIGNED NULL,
    title VARCHAR(180) NOT NULL,
    status ENUM('active','completed','paused','archived') NOT NULL DEFAULT 'active',
    start_date DATE NULL,
    target_date DATE NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_roadmaps_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_roadmaps_role FOREIGN KEY (job_role_id)
        REFERENCES job_roles(job_role_id) ON DELETE RESTRICT,
    CONSTRAINT fk_roadmaps_assessment FOREIGN KEY (assessment_id)
        REFERENCES assessments(assessment_id) ON DELETE SET NULL,
    KEY idx_roadmaps_user_status (user_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 19. ROADMAP TASKS / MILESTONES
CREATE TABLE IF NOT EXISTS roadmap_items (
    item_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    roadmap_id INT UNSIGNED NOT NULL,
    skill_id INT UNSIGNED NOT NULL,
    project_id INT UNSIGNED NULL,
    resource_id INT UNSIGNED NULL,
    item_type ENUM('learn','practice','project','assessment') NOT NULL DEFAULT 'learn',
    title VARCHAR(180) NOT NULL,
    description TEXT NULL,
    priority ENUM('high','medium','low') NOT NULL DEFAULT 'medium',
    status ENUM('not_started','in_progress','completed','skipped') NOT NULL DEFAULT 'not_started',
    sequence_number SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    due_date DATE NULL,
    completed_at DATETIME NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_roadmap_items_roadmap FOREIGN KEY (roadmap_id)
        REFERENCES roadmaps(roadmap_id) ON DELETE CASCADE,
    CONSTRAINT fk_roadmap_items_skill FOREIGN KEY (skill_id)
        REFERENCES skills(skill_id) ON DELETE RESTRICT,
    CONSTRAINT fk_roadmap_items_project FOREIGN KEY (project_id)
        REFERENCES projects(project_id) ON DELETE SET NULL,
    CONSTRAINT fk_roadmap_items_resource FOREIGN KEY (resource_id)
        REFERENCES learning_resources(resource_id) ON DELETE SET NULL,
    KEY idx_roadmap_items_order (roadmap_id, sequence_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 20. PROGRESS HISTORY
CREATE TABLE IF NOT EXISTS progress_logs (
    progress_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    skill_id INT UNSIGNED NOT NULL,
    roadmap_item_id INT UNSIGNED NULL,
    previous_level TINYINT UNSIGNED NULL,
    new_level TINYINT UNSIGNED NULL,
    note TEXT NULL,
    logged_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_progress_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_progress_skill FOREIGN KEY (skill_id)
        REFERENCES skills(skill_id) ON DELETE RESTRICT,
    CONSTRAINT fk_progress_roadmap_item FOREIGN KEY (roadmap_item_id)
        REFERENCES roadmap_items(item_id) ON DELETE SET NULL,
    KEY idx_progress_user_date (user_id, logged_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 21. SAVED CAREER ROLES
CREATE TABLE IF NOT EXISTS saved_job_roles (
    saved_role_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    job_role_id INT UNSIGNED NOT NULL,
    saved_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_saved_job_role (user_id, job_role_id),
    CONSTRAINT fk_saved_roles_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_saved_roles_role FOREIGN KEY (job_role_id)
        REFERENCES job_roles(job_role_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 22. SAVED PROJECTS
CREATE TABLE IF NOT EXISTS saved_projects (
    saved_project_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    project_id INT UNSIGNED NOT NULL,
    saved_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_saved_project (user_id, project_id),
    CONSTRAINT fk_saved_projects_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_saved_projects_project FOREIGN KEY (project_id)
        REFERENCES projects(project_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 23. SAVED LEARNING RESOURCES
CREATE TABLE IF NOT EXISTS saved_resources (
    saved_resource_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    resource_id INT UNSIGNED NOT NULL,
    saved_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_saved_resource (user_id, resource_id),
    CONSTRAINT fk_saved_resources_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_saved_resources_resource FOREIGN KEY (resource_id)
        REFERENCES learning_resources(resource_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 24. IN-APP NOTIFICATIONS
CREATE TABLE IF NOT EXISTS notifications (
    notification_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    title VARCHAR(180) NOT NULL,
    message TEXT NOT NULL,
    notification_type ENUM('general','assessment','evidence','roadmap','achievement') NOT NULL DEFAULT 'general',
    target_url VARCHAR(500) NULL,
    is_read TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notifications_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE,
    KEY idx_notifications_user_read (user_id, is_read, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 25. ACHIEVEMENT DEFINITIONS
CREATE TABLE IF NOT EXISTS achievements (
    achievement_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    achievement_code VARCHAR(80) NOT NULL UNIQUE,
    title VARCHAR(120) NOT NULL,
    description TEXT NULL,
    icon_name VARCHAR(80) NULL,
    requirement_type VARCHAR(80) NULL,
    requirement_value INT UNSIGNED NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 26. ACHIEVEMENTS EARNED BY STUDENTS
CREATE TABLE IF NOT EXISTS user_achievements (
    user_achievement_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    achievement_id INT UNSIGNED NOT NULL,
    awarded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_user_achievement (user_id, achievement_id),
    CONSTRAINT fk_user_achievements_user FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_user_achievements_achievement FOREIGN KEY (achievement_id)
        REFERENCES achievements(achievement_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- STARTER CATALOGUE DATA
-- These are editable starter examples, not official employer requirements.
-- Proficiency levels: 0=None, 1=Beginner, 2=Basic, 3=Intermediate,
-- 4=Advanced, 5=Expert. Weights indicate relative importance in the app.
-- ---------------------------------------------------------------------

INSERT IGNORE INTO skill_categories (category_name, description) VALUES
('Programming', 'Programming languages and coding fundamentals'),
('Web Development', 'Frontend, backend and web application technologies'),
('Cloud and Infrastructure', 'Cloud platforms, operating systems and infrastructure'),
('Networking', 'Computer networking concepts and tools'),
('Cybersecurity', 'Security operations, risk and defensive security'),
('AI and Machine Learning', 'Artificial intelligence and machine learning skills'),
('DevOps and Tools', 'Automation, containers, source control and deployment'),
('Professional Skills', 'Communication, teamwork and problem-solving');

INSERT IGNORE INTO skills (category_id, skill_name, description)
SELECT category_id, 'Python', 'Write and troubleshoot Python programs' FROM skill_categories WHERE category_name='Programming';
INSERT IGNORE INTO skills (category_id, skill_name, description)
SELECT category_id, 'Java', 'Develop applications using Java fundamentals' FROM skill_categories WHERE category_name='Programming';
INSERT IGNORE INTO skills (category_id, skill_name, description)
SELECT category_id, 'PHP', 'Build server-side web applications using PHP' FROM skill_categories WHERE category_name='Programming';
INSERT IGNORE INTO skills (category_id, skill_name, description)
SELECT category_id, 'HTML', 'Create semantic and accessible web page structures' FROM skill_categories WHERE category_name='Web Development';
INSERT IGNORE INTO skills (category_id, skill_name, description)
SELECT category_id, 'CSS', 'Style responsive web interfaces' FROM skill_categories WHERE category_name='Web Development';
INSERT IGNORE INTO skills (category_id, skill_name, description)
SELECT category_id, 'JavaScript', 'Build interactive browser experiences' FROM skill_categories WHERE category_name='Web Development';
INSERT IGNORE INTO skills (category_id, skill_name, description)
SELECT category_id, 'SQL', 'Query and manage relational databases' FROM skill_categories WHERE category_name='Programming';
INSERT IGNORE INTO skills (category_id, skill_name, description)
SELECT category_id, 'REST APIs', 'Consume and build RESTful services' FROM skill_categories WHERE category_name='Web Development';
INSERT IGNORE INTO skills (category_id, skill_name, description)
SELECT category_id, 'Linux', 'Use and administer Linux systems' FROM skill_categories WHERE category_name='Cloud and Infrastructure';
INSERT IGNORE INTO skills (category_id, skill_name, description)
SELECT category_id, 'Networking Fundamentals', 'Understand IP addressing, routing, DNS and network services' FROM skill_categories WHERE category_name='Networking';
INSERT IGNORE INTO skills (category_id, skill_name, description)
SELECT category_id, 'AWS', 'Use core Amazon Web Services cloud services' FROM skill_categories WHERE category_name='Cloud and Infrastructure';
INSERT IGNORE INTO skills (category_id, skill_name, description)
SELECT category_id, 'Microsoft Azure', 'Use core Microsoft Azure cloud services' FROM skill_categories WHERE category_name='Cloud and Infrastructure';
INSERT IGNORE INTO skills (category_id, skill_name, description)
SELECT category_id, 'Docker', 'Build and run containerized applications' FROM skill_categories WHERE category_name='DevOps and Tools';
INSERT IGNORE INTO skills (category_id, skill_name, description)
SELECT category_id, 'Git and GitHub', 'Track code changes and collaborate using Git' FROM skill_categories WHERE category_name='DevOps and Tools';
INSERT IGNORE INTO skills (category_id, skill_name, description)
SELECT category_id, 'CI/CD', 'Automate software build, test and deployment workflows' FROM skill_categories WHERE category_name='DevOps and Tools';
INSERT IGNORE INTO skills (category_id, skill_name, description)
SELECT category_id, 'Machine Learning', 'Train, evaluate and use machine learning models' FROM skill_categories WHERE category_name='AI and Machine Learning';
INSERT IGNORE INTO skills (category_id, skill_name, description)
SELECT category_id, 'Statistics Fundamentals', 'Use basic statistical reasoning for model evaluation' FROM skill_categories WHERE category_name='AI and Machine Learning';
INSERT IGNORE INTO skills (category_id, skill_name, description)
SELECT category_id, 'Data Preparation', 'Prepare and validate data for machine learning workflows' FROM skill_categories WHERE category_name='AI and Machine Learning';
INSERT IGNORE INTO skills (category_id, skill_name, description)
SELECT category_id, 'Model Evaluation', 'Evaluate model performance and interpret metrics' FROM skill_categories WHERE category_name='AI and Machine Learning';
INSERT IGNORE INTO skills (category_id, skill_name, description)
SELECT category_id, 'Security Fundamentals', 'Understand common security principles and threats' FROM skill_categories WHERE category_name='Cybersecurity';
INSERT IGNORE INTO skills (category_id, skill_name, description)
SELECT category_id, 'Log Analysis', 'Review system and security logs for unusual activity' FROM skill_categories WHERE category_name='Cybersecurity';
INSERT IGNORE INTO skills (category_id, skill_name, description)
SELECT category_id, 'Incident Response', 'Follow structured steps to investigate and respond to incidents' FROM skill_categories WHERE category_name='Cybersecurity';
INSERT IGNORE INTO skills (category_id, skill_name, description)
SELECT category_id, 'Vulnerability Assessment', 'Identify and prioritize common security weaknesses' FROM skill_categories WHERE category_name='Cybersecurity';
INSERT IGNORE INTO skills (category_id, skill_name, description)
SELECT category_id, 'Communication', 'Explain technical work clearly to others' FROM skill_categories WHERE category_name='Professional Skills';
INSERT IGNORE INTO skills (category_id, skill_name, description)
SELECT category_id, 'Problem Solving', 'Break down problems and evaluate possible solutions' FROM skill_categories WHERE category_name='Professional Skills';

INSERT IGNORE INTO job_roles (role_name, career_field, short_description, responsibilities) VALUES
('Cloud Engineer', 'Cloud Computing', 'Build, deploy and maintain cloud-based infrastructure and services.', 'Configure cloud services, manage infrastructure, monitor systems and support secure deployments.'),
('AI / Machine Learning Engineer', 'Artificial Intelligence', 'Build and evaluate software systems that use machine learning.', 'Prepare data, train models, evaluate performance and integrate models into applications.'),
('Frontend Developer', 'Software Development', 'Build responsive and interactive user interfaces for websites and applications.', 'Translate interface designs into accessible, responsive and interactive web experiences.'),
('Backend Developer', 'Software Development', 'Build server-side application logic, APIs and database integrations.', 'Develop application services, design APIs, manage data and implement secure business logic.'),
('Cybersecurity Analyst', 'Cybersecurity', 'Monitor systems and help identify, investigate and respond to security risks.', 'Review alerts and logs, investigate suspicious activity and support defensive security processes.'),
('DevOps Engineer', 'Cloud and Infrastructure', 'Improve software delivery through automation, infrastructure and deployment practices.', 'Automate delivery pipelines, manage containers and support reliable application deployment.');

-- Role-to-skill requirements: sample starting levels and weights for project demonstration.
INSERT IGNORE INTO role_skills (job_role_id, skill_id, required_level, importance_weight)
SELECT r.job_role_id, s.skill_id, 3, 2.00 FROM job_roles r CROSS JOIN skills s
WHERE r.role_name='Cloud Engineer' AND s.skill_name IN ('Linux','Networking Fundamentals','AWS','Docker','Git and GitHub','SQL');
INSERT IGNORE INTO role_skills (job_role_id, skill_id, required_level, importance_weight)
SELECT r.job_role_id, s.skill_id, 3, 1.50 FROM job_roles r CROSS JOIN skills s
WHERE r.role_name='AI / Machine Learning Engineer' AND s.skill_name IN ('Python','Machine Learning','Statistics Fundamentals','Data Preparation','Model Evaluation','Git and GitHub','SQL');
INSERT IGNORE INTO role_skills (job_role_id, skill_id, required_level, importance_weight)
SELECT r.job_role_id, s.skill_id, 3, 1.50 FROM job_roles r CROSS JOIN skills s
WHERE r.role_name='Frontend Developer' AND s.skill_name IN ('HTML','CSS','JavaScript','Git and GitHub','REST APIs','Problem Solving');
INSERT IGNORE INTO role_skills (job_role_id, skill_id, required_level, importance_weight)
SELECT r.job_role_id, s.skill_id, 3, 1.50 FROM job_roles r CROSS JOIN skills s
WHERE r.role_name='Backend Developer' AND s.skill_name IN ('PHP','SQL','REST APIs','JavaScript','Git and GitHub','Problem Solving');
INSERT IGNORE INTO role_skills (job_role_id, skill_id, required_level, importance_weight)
SELECT r.job_role_id, s.skill_id, 3, 1.50 FROM job_roles r CROSS JOIN skills s
WHERE r.role_name='Cybersecurity Analyst' AND s.skill_name IN ('Networking Fundamentals','Linux','Security Fundamentals','Log Analysis','Incident Response','Vulnerability Assessment','Problem Solving');
INSERT IGNORE INTO role_skills (job_role_id, skill_id, required_level, importance_weight)
SELECT r.job_role_id, s.skill_id, 3, 1.50 FROM job_roles r CROSS JOIN skills s
WHERE r.role_name='DevOps Engineer' AND s.skill_name IN ('Linux','Networking Fundamentals','Docker','Git and GitHub','CI/CD','AWS','Problem Solving');

-- Starter projects
INSERT IGNORE INTO projects (title, slug, description, difficulty, estimated_hours, prerequisites, instructions, completion_criteria) VALUES
('Deploy a Static Website on AWS', 'deploy-static-website-aws', 'Publish a responsive static website using an AWS storage and hosting service.', 'beginner', 5, 'Basic HTML and CSS; introductory cloud concepts.', 'Create a static website, configure hosting, publish the files and test the public endpoint.', 'Website loads from its deployed endpoint and project steps are documented.'),
('Build a Linux Web Server', 'build-linux-web-server', 'Install and configure a basic web server on a Linux environment.', 'beginner', 6, 'Basic command-line usage.', 'Create a Linux environment, install a web server, configure a simple page and test connectivity.', 'The server responds to a browser request and configuration steps are documented.'),
('Containerize a Web Application', 'containerize-web-application', 'Package a simple web application using Docker.', 'intermediate', 8, 'Basic web application and command-line knowledge.', 'Create a Dockerfile, build an image, run a container and document the commands.', 'The application runs successfully inside a container.'),
('Create a Responsive Portfolio Website', 'responsive-portfolio-website', 'Build a personal portfolio using HTML, CSS and JavaScript.', 'beginner', 8, 'Basic HTML and CSS.', 'Create profile, skills, projects and contact sections; make the layout responsive.', 'The portfolio works on desktop and mobile screen sizes.'),
('Build a PHP and MySQL REST-style Application', 'php-mysql-application', 'Create a small PHP application that stores and retrieves records from a relational database.', 'intermediate', 10, 'Basic PHP, SQL and HTML.', 'Create database tables, build PHP form handlers and implement safe database queries.', 'Users can create, view, update and delete records through the application.'),
('Build a Machine Learning Classifier', 'machine-learning-classifier', 'Train and evaluate a simple classification model using a prepared dataset.', 'intermediate', 10, 'Basic Python programming and introductory statistics.', 'Prepare a dataset, train a baseline model, evaluate it and document the results.', 'A reproducible model workflow and evaluation summary are submitted.'),
('Investigate a Sample Security Log', 'sample-security-log-investigation', 'Analyze a safe sample log file and document notable events.', 'beginner', 5, 'Basic networking and operating-system concepts.', 'Review a supplied or self-created sample log, identify unusual patterns and write findings.', 'A short investigation report explains observations and limitations.');

-- Map starter projects to skills
INSERT IGNORE INTO project_skills (project_id, skill_id, target_level)
SELECT p.project_id, s.skill_id, 2 FROM projects p CROSS JOIN skills s
WHERE p.slug='deploy-static-website-aws' AND s.skill_name IN ('AWS','HTML','CSS');
INSERT IGNORE INTO project_skills (project_id, skill_id, target_level)
SELECT p.project_id, s.skill_id, 2 FROM projects p CROSS JOIN skills s
WHERE p.slug='build-linux-web-server' AND s.skill_name IN ('Linux','Networking Fundamentals');
INSERT IGNORE INTO project_skills (project_id, skill_id, target_level)
SELECT p.project_id, s.skill_id, 3 FROM projects p CROSS JOIN skills s
WHERE p.slug='containerize-web-application' AND s.skill_name IN ('Docker','Linux','Git and GitHub');
INSERT IGNORE INTO project_skills (project_id, skill_id, target_level)
SELECT p.project_id, s.skill_id, 2 FROM projects p CROSS JOIN skills s
WHERE p.slug='responsive-portfolio-website' AND s.skill_name IN ('HTML','CSS','JavaScript','Git and GitHub');
INSERT IGNORE INTO project_skills (project_id, skill_id, target_level)
SELECT p.project_id, s.skill_id, 3 FROM projects p CROSS JOIN skills s
WHERE p.slug='php-mysql-application' AND s.skill_name IN ('PHP','SQL','REST APIs');
INSERT IGNORE INTO project_skills (project_id, skill_id, target_level)
SELECT p.project_id, s.skill_id, 3 FROM projects p CROSS JOIN skills s
WHERE p.slug='machine-learning-classifier' AND s.skill_name IN ('Python','Machine Learning','Statistics Fundamentals','Model Evaluation','Data Preparation');
INSERT IGNORE INTO project_skills (project_id, skill_id, target_level)
SELECT p.project_id, s.skill_id, 2 FROM projects p CROSS JOIN skills s
WHERE p.slug='sample-security-log-investigation' AND s.skill_name IN ('Log Analysis','Security Fundamentals','Networking Fundamentals');

-- Starter learning resources. Review links and availability before recommending them to students.
INSERT INTO learning_resources (title, resource_type, provider, resource_url, description, is_free, estimated_minutes) VALUES
('Python Tutorial', 'documentation', 'Python Software Foundation', 'https://docs.python.org/3/tutorial/', 'Official Python tutorial and language documentation.', 1, 120),
('MDN Web Docs', 'documentation', 'MDN', 'https://developer.mozilla.org/', 'Web development documentation for HTML, CSS and JavaScript.', 1, 120),
('PHP Manual', 'documentation', 'PHP Documentation', 'https://www.php.net/manual/en/', 'Official PHP language documentation.', 1, 120),
('MySQL Reference Manual', 'documentation', 'MySQL', 'https://dev.mysql.com/doc/', 'Reference documentation for MySQL concepts and SQL.', 1, 120),
('AWS Skill Builder', 'course', 'Amazon Web Services', 'https://skillbuilder.aws/', 'Official AWS learning and training portal; some content may require an account.', 1, 120),
('Docker Get Started', 'documentation', 'Docker', 'https://docs.docker.com/get-started/', 'Official introductory guide to Docker.', 1, 90),
('OWASP Top 10', 'article', 'OWASP', 'https://owasp.org/www-project-top-ten/', 'Awareness resource about common web application security risks.', 1, 60);

-- Link selected starter resources to relevant skills
INSERT IGNORE INTO resource_skills (resource_id, skill_id)
SELECT r.resource_id, s.skill_id FROM learning_resources r CROSS JOIN skills s
WHERE r.title='Python Tutorial' AND s.skill_name='Python';
INSERT IGNORE INTO resource_skills (resource_id, skill_id)
SELECT r.resource_id, s.skill_id FROM learning_resources r CROSS JOIN skills s
WHERE r.title='MDN Web Docs' AND s.skill_name IN ('HTML','CSS','JavaScript','REST APIs');
INSERT IGNORE INTO resource_skills (resource_id, skill_id)
SELECT r.resource_id, s.skill_id FROM learning_resources r CROSS JOIN skills s
WHERE r.title='PHP Manual' AND s.skill_name='PHP';
INSERT IGNORE INTO resource_skills (resource_id, skill_id)
SELECT r.resource_id, s.skill_id FROM learning_resources r CROSS JOIN skills s
WHERE r.title='MySQL Reference Manual' AND s.skill_name='SQL';
INSERT IGNORE INTO resource_skills (resource_id, skill_id)
SELECT r.resource_id, s.skill_id FROM learning_resources r CROSS JOIN skills s
WHERE r.title='AWS Skill Builder' AND s.skill_name='AWS';
INSERT IGNORE INTO resource_skills (resource_id, skill_id)
SELECT r.resource_id, s.skill_id FROM learning_resources r CROSS JOIN skills s
WHERE r.title='Docker Get Started' AND s.skill_name='Docker';
INSERT IGNORE INTO resource_skills (resource_id, skill_id)
SELECT r.resource_id, s.skill_id FROM learning_resources r CROSS JOIN skills s
WHERE r.title='OWASP Top 10' AND s.skill_name='Security Fundamentals';

-- Starter achievements
INSERT IGNORE INTO achievements (achievement_code, title, description, icon_name, requirement_type, requirement_value) VALUES
('FIRST_ASSESSMENT', 'First Assessment', 'Complete your first career skill assessment.', 'clipboard-check', 'completed_assessments', 1),
('FIRST_EVIDENCE', 'Evidence Contributor', 'Submit your first project or skill evidence.', 'file-check', 'evidence_submissions', 1),
('FIRST_PROJECT', 'Project Starter', 'Complete your first recommended project.', 'folder-check', 'completed_projects', 1),
('FIVE_SKILLS', 'Skill Explorer', 'Add proficiency information for five skills.', 'layers', 'profiled_skills', 5),
('ROADMAP_MILESTONE', 'Roadmap Progress', 'Complete your first roadmap milestone.', 'flag', 'completed_roadmap_items', 1);

-- End of initial setup. No default admin account is created.
-- Register normally, then promote a trusted account to admin through a controlled setup step.


-- STARTER ASSESSMENT QUESTION BANK
-- These sample MCQs are for demonstrating the assessment workflow.
INSERT INTO assessment_questions (skill_id, question_type, question_text, difficulty, target_level, points, explanation)
SELECT skill_id, 'multiple_choice', 'Which Python data type is commonly used to store an ordered, changeable collection of items?', 'beginner', 1, 1.00, 'A list is ordered and mutable.' FROM skills WHERE skill_name='Python';
INSERT INTO assessment_questions (skill_id, question_type, question_text, difficulty, target_level, points, explanation)
SELECT skill_id, 'multiple_choice', 'Which Python keyword is used to define a function?', 'beginner', 1, 1.00, 'The def keyword begins a function definition.' FROM skills WHERE skill_name='Python';
INSERT INTO assessment_questions (skill_id, question_type, question_text, difficulty, target_level, points, explanation)
SELECT skill_id, 'multiple_choice', 'Which HTML element creates a hyperlink?', 'beginner', 1, 1.00, 'The anchor element creates a hyperlink.' FROM skills WHERE skill_name='HTML';
INSERT INTO assessment_questions (skill_id, question_type, question_text, difficulty, target_level, points, explanation)
SELECT skill_id, 'multiple_choice', 'Which CSS property changes the text color?', 'beginner', 1, 1.00, 'The color property sets text color.' FROM skills WHERE skill_name='CSS';
INSERT INTO assessment_questions (skill_id, question_type, question_text, difficulty, target_level, points, explanation)
SELECT skill_id, 'multiple_choice', 'Which JavaScript method selects an element using its ID?', 'beginner', 1, 1.00, 'getElementById selects an element by its id attribute.' FROM skills WHERE skill_name='JavaScript';
INSERT INTO assessment_questions (skill_id, question_type, question_text, difficulty, target_level, points, explanation)
SELECT skill_id, 'multiple_choice', 'Which SQL statement is used to retrieve records from a table?', 'beginner', 1, 1.00, 'SELECT retrieves data from one or more tables.' FROM skills WHERE skill_name='SQL';
INSERT INTO assessment_questions (skill_id, question_type, question_text, difficulty, target_level, points, explanation)
SELECT skill_id, 'multiple_choice', 'Which Linux command lists files and directories?', 'beginner', 1, 1.00, 'The ls command lists directory contents.' FROM skills WHERE skill_name='Linux';
INSERT INTO assessment_questions (skill_id, question_type, question_text, difficulty, target_level, points, explanation)
SELECT skill_id, 'multiple_choice', 'What is the primary purpose of DNS?', 'beginner', 1, 1.00, 'DNS translates domain names into IP addresses.' FROM skills WHERE skill_name='Networking Fundamentals';
INSERT INTO assessment_questions (skill_id, question_type, question_text, difficulty, target_level, points, explanation)
SELECT skill_id, 'multiple_choice', 'Which AWS service provides resizable virtual servers?', 'beginner', 1, 1.00, 'Amazon EC2 provides virtual compute instances.' FROM skills WHERE skill_name='AWS';
INSERT INTO assessment_questions (skill_id, question_type, question_text, difficulty, target_level, points, explanation)
SELECT skill_id, 'multiple_choice', 'What does HTTPS add to HTTP?', 'beginner', 1, 1.00, 'HTTPS protects data in transit using TLS encryption.' FROM skills WHERE skill_name='Security Fundamentals';

-- Options for the starter questions
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'List', 1, 1 FROM assessment_questions WHERE question_text='Which Python data type is commonly used to store an ordered, changeable collection of items?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'Tuple', 0, 2 FROM assessment_questions WHERE question_text='Which Python data type is commonly used to store an ordered, changeable collection of items?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'Set', 0, 3 FROM assessment_questions WHERE question_text='Which Python data type is commonly used to store an ordered, changeable collection of items?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'String', 0, 4 FROM assessment_questions WHERE question_text='Which Python data type is commonly used to store an ordered, changeable collection of items?';

INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'def', 1, 1 FROM assessment_questions WHERE question_text='Which Python keyword is used to define a function?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'function', 0, 2 FROM assessment_questions WHERE question_text='Which Python keyword is used to define a function?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'fun', 0, 3 FROM assessment_questions WHERE question_text='Which Python keyword is used to define a function?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'define', 0, 4 FROM assessment_questions WHERE question_text='Which Python keyword is used to define a function?';

INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, '<a>', 1, 1 FROM assessment_questions WHERE question_text='Which HTML element creates a hyperlink?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, '<link>', 0, 2 FROM assessment_questions WHERE question_text='Which HTML element creates a hyperlink?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, '<href>', 0, 3 FROM assessment_questions WHERE question_text='Which HTML element creates a hyperlink?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, '<url>', 0, 4 FROM assessment_questions WHERE question_text='Which HTML element creates a hyperlink?';

INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'color', 1, 1 FROM assessment_questions WHERE question_text='Which CSS property changes the text color?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'font-style', 0, 2 FROM assessment_questions WHERE question_text='Which CSS property changes the text color?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'background-image', 0, 3 FROM assessment_questions WHERE question_text='Which CSS property changes the text color?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'text-align', 0, 4 FROM assessment_questions WHERE question_text='Which CSS property changes the text color?';

INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'document.getElementById()', 1, 1 FROM assessment_questions WHERE question_text='Which JavaScript method selects an element using its ID?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'document.getElementsByClass()', 0, 2 FROM assessment_questions WHERE question_text='Which JavaScript method selects an element using its ID?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'window.getId()', 0, 3 FROM assessment_questions WHERE question_text='Which JavaScript method selects an element using its ID?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'document.selectId()', 0, 4 FROM assessment_questions WHERE question_text='Which JavaScript method selects an element using its ID?';

INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'SELECT', 1, 1 FROM assessment_questions WHERE question_text='Which SQL statement is used to retrieve records from a table?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'UPDATE', 0, 2 FROM assessment_questions WHERE question_text='Which SQL statement is used to retrieve records from a table?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'INSERT', 0, 3 FROM assessment_questions WHERE question_text='Which SQL statement is used to retrieve records from a table?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'DELETE', 0, 4 FROM assessment_questions WHERE question_text='Which SQL statement is used to retrieve records from a table?';

INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'ls', 1, 1 FROM assessment_questions WHERE question_text='Which Linux command lists files and directories?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'cd', 0, 2 FROM assessment_questions WHERE question_text='Which Linux command lists files and directories?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'pwd', 0, 3 FROM assessment_questions WHERE question_text='Which Linux command lists files and directories?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'mkdir', 0, 4 FROM assessment_questions WHERE question_text='Which Linux command lists files and directories?';

INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'Translate domain names into IP addresses', 1, 1 FROM assessment_questions WHERE question_text='What is the primary purpose of DNS?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'Encrypt files on a computer', 0, 2 FROM assessment_questions WHERE question_text='What is the primary purpose of DNS?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'Assign usernames to users', 0, 3 FROM assessment_questions WHERE question_text='What is the primary purpose of DNS?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'Compress network packets', 0, 4 FROM assessment_questions WHERE question_text='What is the primary purpose of DNS?';

INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'Amazon EC2', 1, 1 FROM assessment_questions WHERE question_text='Which AWS service provides resizable virtual servers?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'Amazon S3', 0, 2 FROM assessment_questions WHERE question_text='Which AWS service provides resizable virtual servers?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'Amazon Route 53', 0, 3 FROM assessment_questions WHERE question_text='Which AWS service provides resizable virtual servers?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'Amazon CloudFront', 0, 4 FROM assessment_questions WHERE question_text='Which AWS service provides resizable virtual servers?';

INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'TLS encryption', 1, 1 FROM assessment_questions WHERE question_text='What does HTTPS add to HTTP?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'Image compression', 0, 2 FROM assessment_questions WHERE question_text='What does HTTPS add to HTTP?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'A faster CPU', 0, 3 FROM assessment_questions WHERE question_text='What does HTTPS add to HTTP?';
INSERT INTO assessment_options (question_id, option_text, is_correct, option_order)
SELECT question_id, 'A larger screen resolution', 0, 4 FROM assessment_questions WHERE question_text='What does HTTPS add to HTTP?';

-- End of SkillGap Passport database setup.
-- No default administrator is created. Admin access will be provisioned securely later.
