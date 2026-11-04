<?php
require_once __DIR__ . '/../includes/functions.php';
require_once __DIR__ . '/../config/database.php';
if (is_logged_in()) redirect('student/dashboard.php');
$error = '';
$email = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    verify_csrf();
    $email = trim($_POST['email'] ?? '');
    $password = $_POST['password'] ?? '';
    $stmt = $pdo->prepare('SELECT user_id,full_name,email,password_hash,role,account_status FROM users WHERE email = ? LIMIT 1');
    $stmt->execute([$email]);
    $user = $stmt->fetch();
    if ($user && password_verify($password, $user['password_hash']) && $user['account_status'] === 'active') {
        session_regenerate_id(true);
        $_SESSION['user'] = ['user_id'=>(int)$user['user_id'],'full_name'=>$user['full_name'],'email'=>$user['email'],'role'=>$user['role']];
        flash('Welcome back, ' . $user['full_name'] . '.');
        if (in_array($user['role'], ['mentor','admin'], true)) redirect($user['role'] === 'admin' ? 'admin/dashboard.php' : 'mentor/dashboard.php');
        redirect('student/dashboard.php');
    }
    $error = 'The email or password is incorrect, or this account is unavailable.';
}
$pageTitle = 'Sign in'; include __DIR__ . '/../includes/header.php';
?>
<main class="auth-page"><aside class="auth-aside"><span class="eyebrow">Welcome back</span><h1>Your next career milestone is waiting.</h1><p>Pick up where you left off. Review your roadmap, revisit saved career roles and keep building evidence of your skills.</p><div class="auth-points"><div class="auth-point"><span>✓</span> Continue your personalized roadmap</div><div class="auth-point"><span>✓</span> Track assessment improvements</div><div class="auth-point"><span>✓</span> Keep your Skill Passport current</div></div></aside>
<section class="auth-form-side"><form class="auth-form" method="post"><span class="eyebrow">Sign in</span><h2>Welcome back</h2><p>Enter your account details to continue.</p><?php if ($error): ?><div class="alert alert-error"><?= h($error) ?></div><?php endif; ?><?= csrf_field() ?><div class="field"><label for="email">Email address</label><input class="input" id="email" name="email" type="email" required value="<?= h($email) ?>" placeholder="you@example.com"></div><div class="field"><label for="password">Password</label><div class="password-wrap"><input class="input" id="password" name="password" type="password" required placeholder="Your password"><button type="button" data-password-toggle="password">Show</button></div></div><button class="btn btn-primary btn-block" type="submit">Sign in <span>→</span></button><div class="form-foot">New to SkillGap Passport? <a href="<?= h(url('auth/register.php')) ?>">Create an account</a></div></form></section></main>
<?php include __DIR__ . '/../includes/footer.php'; ?>
