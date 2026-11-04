# SkillGap Passport

A full-stack career skill assessment and development roadmap application built for a college Web Technologies project.

**Stack:** HTML5, CSS3, JavaScript, PHP (PDO), MariaDB/MySQL, Apache (XAMPP).

## Features included

- Student registration, sign-in, sign-out and profile management.
- Student, mentor and administrator roles.
- Career role catalogue with required skills and importance weights.
- Self-assessed skill levels from 0 to 5.
- Weighted skill-coverage / gap report for a selected career role.
- Assessment history.
- Personalized roadmaps generated from gaps, mapped projects and learning resources.
- Roadmap milestone status tracking.
- Project catalogue, project details and saved projects.
- Learning resource catalogue.
- Skill evidence submission through links and descriptions.
- Mentor review workflow: verify, request changes or reject.
- Verified skill levels kept separate from self-assessed levels.
- Personal Skill Passport, achievements and in-app notifications.
- Administrator overview and user-role / account-status management.
- CSRF tokens, server-side validation, password hashing, prepared statements and role checks.

The career-role requirements and starter catalogue are editable demonstration data. They are not official employer standards and should be reviewed before real career guidance is based on them.

## Install on Windows with XAMPP

1. Start **Apache** and **MySQL** in the XAMPP Control Panel.
2. Extract the `skillgap-passport` folder into your XAMPP `htdocs` directory. For this setup, the expected location is:

   `E:\XAMPP\htdocs\skillgap-passport\`

3. If you already have a temporary `test-db.php` file from the earlier connection test, you can delete it; this package does not need it.
4. Open phpMyAdmin at `http://localhost/phpmyadmin`.
5. Create a database named `skillgap_passport` using `utf8mb4_unicode_ci` if it does not already exist.
6. Select that database and use **Import** to import:

   `database/skillgap_passport_setup.sql`

   This step is only for a fresh empty database. If you already imported this SQL file successfully, **do not import it again**.
7. Check `config/database.php`. The defaults are:

   - Host: `127.0.0.1`
   - Database: `skillgap_passport`
   - Username: `root`
   - Password: blank

   These match a standard local XAMPP setup. Change them if your database credentials differ.
8. Open `http://localhost/skillgap-passport/setup/check.php` to verify the database connection and important tables.
9. Open `http://localhost/skillgap-passport/` and register a student account.

## Create the first administrator

There is intentionally no default administrator password in the project. Register your own account first. Then, in phpMyAdmin, select `skillgap_passport`, open the SQL tab and run the following statement using your registered email address:

```sql
UPDATE users SET role = 'admin' WHERE email = 'your-email@example.com';
```

Sign out and sign in again. The Admin link will appear in the navigation.

To create a mentor account, register a separate account and run:

```sql
UPDATE users SET role = 'mentor' WHERE email = 'mentor-email@example.com';
```

An administrator can also update account roles from **Admin → Manage users**.

## Important paths

- Landing page: `index.php`
- Database connection: `config/database.php`
- Database setup: `database/skillgap_passport_setup.sql`
- Installation check: `setup/check.php`
- Student dashboard: `student/dashboard.php`
- Career explorer: `careers/index.php`
- Assessment history: `assessment/history.php`
- Evidence submissions: `evidence/index.php`
- Mentor review: `mentor/dashboard.php`
- Admin overview: `admin/dashboard.php`

## Skill-coverage calculation

For each required skill, the coverage is calculated as:

`min(current_level / required_level, 1) * 100`

The overall score is the weighted average across the skills mapped to the selected role. The score is a self-assessed planning indicator; it is not a hiring probability, placement prediction or certification. Evidence reviewed by a mentor is stored separately as a verified level.

## Notes

- The application is intended for local academic demonstration. Do not deploy it publicly without additional security review, HTTPS, secure database credentials, backup procedures, stricter upload controls (if uploads are added), and privacy review.
- The current version accepts evidence links and written descriptions; it does not upload files to the server.
- Learning links and sample role requirements are starter examples. Confirm their current content and suitability before presenting them as official guidance.
- If you install the application in a folder other than `skillgap-passport`, update `BASE_URL` in `config/app.php`.
