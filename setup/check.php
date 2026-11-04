<?php
require_once __DIR__ . '/../includes/functions.php';
require_once __DIR__ . '/../config/database.php';
$expected = ['users','job_roles','skills','role_skills','assessments','assessment_results','evidence_submissions','roadmaps','roadmap_items','projects','learning_resources'];
$existing = $pdo->query('SHOW TABLES')->fetchAll(PDO::FETCH_COLUMN);
$missing = array_values(array_diff($expected, $existing));
$count = count($existing);
$pageTitle = 'Installation check';
include __DIR__ . '/../includes/header.php';
?>
<main class="main"><div class="container narrow section-sm"><div class="page-head"><div><span class="eyebrow">System check</span><h1 class="h1">Installation status</h1><p>Quick checks for the local SkillGap Passport setup.</p></div></div><section class="card card-pad"><div class="verified-skill"><div><strong>PHP</strong><p><?=h(PHP_VERSION)?></p></div><span class="pill pill-green">Available</span></div><div class="verified-skill"><div><strong>PDO MySQL driver</strong><p>Required for PHP-to-database connectivity</p></div><span class="pill <?=extension_loaded('pdo_mysql')?'pill-green':'pill-red'?>"><?=extension_loaded('pdo_mysql')?'Available':'Missing'?></span></div><div class="verified-skill"><div><strong>Database connection</strong><p>Connected to skillgap_passport</p></div><span class="pill pill-green">Connected</span></div><div class="verified-skill"><div><strong>Database tables</strong><p><?=$count?> tables found</p></div><span class="pill <?=$missing?'pill-red':'pill-green'?>"><?=$missing?'Missing expected tables':'Expected tables found'?></span></div><?php if($missing):?><div class="alert alert-error" style="margin-top:15px">Missing: <?=h(implode(', ',$missing))?></div><?php else:?><div class="alert alert-success" style="margin-top:15px">Core database tables are available. You can sign in or create a student account.</div><?php endif;?><a class="btn btn-primary btn-block" href="<?=h(url('index.php'))?>">Open SkillGap Passport</a></section><p class="tiny muted" style="margin-top:14px">For local development only. Remove or restrict setup utilities before deploying to a public server.</p></div></main>
<?php include __DIR__ . '/../includes/footer.php'; ?>
