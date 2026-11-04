<?php
require_once __DIR__ . '/includes/functions.php';
$pageTitle = 'Build skills you can prove';
include __DIR__ . '/includes/header.php';
?>
<main class="main">
<section class="hero">
  <div class="hero-inner">
    <div class="hero-copy">
      <span class="eyebrow">Your skills. Your proof. Your next step.</span>
      <h1 class="h1">Turn your skills into a <span style="color:#8fb0ff">career-ready</span> story.</h1>
      <p class="lead">Discover what your target career needs, understand where you stand, and follow a practical roadmap to build skills you can demonstrate.</p>
      <div class="hero-actions"><a class="btn btn-primary" href="<?= h(url(is_logged_in() ? 'student/dashboard.php' : 'auth/register.php')) ?>">Create your free passport <span>↗</span></a><a class="btn btn-outline" href="#how-it-works">See how it works <span>↓</span></a></div>
      <div class="hero-trust"><div class="mini-avatars"><span>AI</span><span>CL</span><span>WD</span><span>CS</span></div><span>One clear path from learning to demonstrating your skills.</span></div>
    </div>
    <div class="hero-visual">
      <div class="dashboard-preview">
        <div class="preview-top"><span>CAREER READINESS SNAPSHOT</span><span class="pill pill-green">Example</span></div>
        <div class="preview-main">
          <div class="score-ring"><strong>72%</strong></div>
          <div><div class="eyebrow" style="font-size:9px">TARGET ROLE</div><h3 style="font:800 17px Manrope;margin:3px 0">Cloud Engineer</h3><span style="font-size:10px;color:#7a879b">Illustrative skill coverage</span></div>
        </div>
        <div class="preview-skill"><div class="preview-skill-top"><span>AWS</span><b>45%</b></div><div class="progress"><span style="width:45%"></span></div></div>
        <div class="preview-skill"><div class="preview-skill-top"><span>Linux</span><b>80%</b></div><div class="progress"><span style="width:80%"></span></div></div>
        <div class="preview-skill"><div class="preview-skill-top"><span>Networking</span><b>60%</b></div><div class="progress"><span style="width:60%"></span></div></div>
        <div class="preview-bottom"><div class="preview-stat"><strong>3</strong><span>Priority gaps</span></div><div class="preview-stat"><strong>4</strong><span>Projects to try</span></div><div class="preview-stat"><strong>2</strong><span>Skills verified</span></div></div>
      </div>
      <div class="floating-note"><span class="floating-icon">✓</span><span><b>Progress with proof</b>Show what you can do</span></div>
    </div>
  </div>
</section>
<div class="logo-strip">DESIGNED FOR STUDENTS EXPLORING <strong>AI & ML</strong> · <strong>CLOUD</strong> · <strong>SOFTWARE</strong> · <strong>CYBERSECURITY</strong> CAREERS</div>
<section class="section" id="features"><div class="container">
  <div class="section-heading"><div><span class="eyebrow">A practical career companion</span><h2 class="h2" style="margin-top:8px">Everything you need to move forward</h2><p class="lead" style="font-size:14px;margin:10px 0 0">Not another list of courses. A clear system to assess, practice, demonstrate and improve.</p></div></div>
  <div class="grid grid-3">
    <article class="card feature-card"><div class="feature-icon">⌕</div><h3>Explore career roles</h3><p>Understand the skills, responsibilities and practical expectations behind different job roles.</p></article>
    <article class="card feature-card"><div class="feature-icon">◎</div><h3>Find your skill gaps</h3><p>Compare your current proficiency with role requirements and see which skills deserve attention first.</p></article>
    <article class="card feature-card"><div class="feature-icon">✦</div><h3>Prove your abilities</h3><p>Attach project links and practical evidence. Keep self-assessed and reviewer-verified skills distinct.</p></article>
    <article class="card feature-card"><div class="feature-icon">↗</div><h3>Build a personal roadmap</h3><p>Turn gaps into manageable learning, practice and project milestones.</p></article>
    <article class="card feature-card"><div class="feature-icon">▤</div><h3>Learn with direction</h3><p>Find curated documentation, tutorials and resources connected to skills you want to improve.</p></article>
    <article class="card feature-card"><div class="feature-icon">▣</div><h3>Carry your Skill Passport</h3><p>Keep a clear record of assessed skills, verified evidence and completed projects.</p></article>
  </div>
</div></section>
<section class="section" id="how-it-works" style="background:#fff"><div class="container">
  <div class="section-heading"><div><span class="eyebrow">Simple by design</span><h2 class="h2" style="margin-top:8px">A clearer way to build career skills</h2></div></div>
  <div class="grid grid-4"><article class="card step-card"><div class="step-number">01</div><h3>Choose a direction</h3><p>Explore career roles and select the one you want to work towards.</p></article><article class="card step-card"><div class="step-number">02</div><h3>Understand your level</h3><p>Assess your current skills against clear proficiency descriptions.</p></article><article class="card step-card"><div class="step-number">03</div><h3>Practice and prove</h3><p>Follow suggested projects and submit evidence of your work.</p></article><article class="card step-card"><div class="step-number">04</div><h3>Track your growth</h3><p>Complete milestones, request reviews and revisit your progress.</p></article></div>
</div></section>
<section class="section" id="careers"><div class="container">
  <div class="section-heading"><div><span class="eyebrow">Explore possibilities</span><h2 class="h2" style="margin-top:8px">Career paths to get you started</h2><p class="lead" style="font-size:13px;margin:8px 0 0">Starter examples are provided in the catalogue. Requirements are illustrative and can be edited by an administrator.</p></div><a class="link-arrow" href="<?= h(url('careers/index.php')) ?>">Explore all careers →</a></div>
  <div class="grid grid-3">
    <?php
    try {
      require_once __DIR__ . '/config/database.php';
      $roles = $pdo->query('SELECT job_role_id, role_name, career_field, short_description FROM job_roles WHERE is_active = 1 ORDER BY role_name LIMIT 6')->fetchAll();
    } catch (Throwable $e) { $roles = []; }
    $icons = ['Cloud Engineer'=>'☁','AI / Machine Learning Engineer'=>'✧','Frontend Developer'=>'◫','Backend Developer'=>'⌘','Cybersecurity Analyst'=>'⬡','DevOps Engineer'=>'⟳'];
    foreach ($roles as $role): ?>
      <a class="card role-card" href="<?= h(url('careers/view.php?id=' . (int)$role['job_role_id'])) ?>"><div class="role-icon"><?= h($icons[$role['role_name']] ?? '✦') ?></div><h3><?= h($role['role_name']) ?></h3><p><?= h($role['short_description']) ?></p><div class="role-meta"><span><?= h($role['career_field']) ?></span><span>View role →</span></div></a>
    <?php endforeach; ?>
    <?php if (!$roles): ?><div class="card card-pad"><p class="muted">Import the database setup to load starter career roles.</p></div><?php endif; ?>
  </div>
</div></section>
<section class="section"><div class="container"><div class="cta-band"><div><h2>Your next step can be clearer.</h2><p>Create a profile and start mapping your skills to a career direction.</p></div><a class="btn" href="<?= h(url(is_logged_in() ? 'student/dashboard.php' : 'auth/register.php')) ?>">Start your Skill Passport ↗</a></div></div></section>
</main>
<?php include __DIR__ . '/includes/footer.php'; ?>
