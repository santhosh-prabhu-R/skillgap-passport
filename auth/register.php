<?php
require_once __DIR__ . '/../includes/functions.php';
require_once __DIR__ . '/../config/database.php';
if (is_logged_in()) redirect('student/dashboard.php');
$errors = [];
$values = ['full_name'=>'','email'=>'','roll_number'=>'','department'=>'','graduation_year'=>''];
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    verify_csrf();
    foreach ($values as $key => $_) $values[$key] = trim($_POST[$key] ?? '');
    $password = $_POST['password'] ?? '';
    $confirm = $_POST['confirm_password'] ?? '';
    if ($values['full_name'] === '') $errors[] = 'Please enter your full name.';
    if (!filter_var($values['email'], FILTER_VALIDATE_EMAIL)) $errors[] = 'Enter a valid email address.';
    if (strlen($password) < 8) $errors[] = 'Password must contain at least 8 characters.';
    if ($password !== $confirm) $errors[] = 'Passwords do not match.';
    if ($values['graduation_year'] !== '' && (!ctype_digit($values['graduation_year']) || (int)$values['graduation_year'] < 2020 || (int)$values['graduation_year'] > 2040)) $errors[] = 'Enter a valid graduation year.';
    if (!$errors) {
        try {
            $stmt = $pdo->prepare('INSERT INTO users (full_name,email,roll_number,password_hash,department,graduation_year) VALUES (?,?,?,?,?,?)');
            $stmt->execute([$values['full_name'],$values['email'],$values['roll_number'] ?: null,password_hash($password, PASSWORD_DEFAULT),$values['department'] ?: null,$values['graduation_year'] ?: null]);
            $userId = (int)$pdo->lastInsertId();
            session_regenerate_id(true);
            $_SESSION['user'] = ['user_id'=>$userId,'full_name'=>$values['full_name'],'email'=>$values['email'],'role'=>'student'];
            flash('Your account is ready. Let’s set up your career profile.');
            redirect('onboarding/index.php');
        } catch (PDOException $e) {
            $errors[] = $e->getCode() === '23000' ? 'That email address or roll number is already registered.' : 'Unable to create the account. Please try again.';
        }
    }
}
$pageTitle = 'Create your account'; include __DIR__ . '/../includes/header.php';
?>
<main class="auth-page">
 <aside class="auth-aside"><span class="eyebrow">Your journey starts here</span><h1>Build a career story backed by real work.</h1><p>Create your SkillGap Passport to explore career paths, understand your skill gaps and keep your practical progress in one place.</p><div class="auth-points"><div class="auth-point"><span>✓</span> Know which skills matter for a role</div><div class="auth-point"><span>✓</span> Turn learning into practical milestones</div><div class="auth-point"><span>✓</span> Keep evidence of what you can do</div></div></aside>
 <section class="auth-form-side"><form class="auth-form" method="post"><span class="eyebrow">Create account</span><h2>Join SkillGap Passport</h2><p>Start with a few details. You can complete your profile later.</p>
 <?php if ($errors): ?><div class="alert alert-error"><div><?= implode('<br>', array_map('h',$errors)) ?></div></div><?php endif; ?>
 <?= csrf_field() ?>
 <div class="field"><label for="full_name">Full name *</label><input class="input" id="full_name" name="full_name" required maxlength="100" value="<?= h($values['full_name']) ?>" placeholder="Your name"></div>
 <div class="field"><label for="email">Email address *</label><input class="input" id="email" name="email" type="email" required value="<?= h($values['email']) ?>" placeholder="you@example.com"></div>
 <div class="form-grid"><div class="field"><label for="roll_number">Roll number</label><input class="input" id="roll_number" name="roll_number" value="<?= h($values['roll_number']) ?>" placeholder="Optional"></div><div class="field"><label for="department">Department</label><input class="input" id="department" name="department" value="<?= h($values['department']) ?>" placeholder="e.g. CSE"></div></div>
 <div class="field"><label for="graduation_year">Expected graduation year</label><input class="input" id="graduation_year" name="graduation_year" type="number" min="2020" max="2040" value="<?= h($values['graduation_year']) ?>" placeholder="e.g. 2028"></div>
 <div class="field"><label for="password">Password *</label><div class="password-wrap"><input class="input" id="password" name="password" type="password" required minlength="8" placeholder="At least 8 characters"><button type="button" data-password-toggle="password">Show</button></div></div>
 <div class="field"><label for="confirm_password">Confirm password *</label><input class="input" id="confirm_password" name="confirm_password" type="password" required placeholder="Enter password again"></div>
 <button class="btn btn-primary btn-block" type="submit">Create my account <span>→</span></button><div class="form-foot">Already have an account? <a href="<?= h(url('auth/login.php')) ?>">Sign in</a></div>
 </form></section>
</main>
<?php include __DIR__ . '/../includes/footer.php'; ?>
