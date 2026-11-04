<?php
require_once __DIR__ . '/functions.php';
$pageTitle = $pageTitle ?? APP_NAME;
$active = $active ?? '';
$user = current_user();
$flashes = pull_flashes();
$navItems = [
    ['label' => 'Dashboard', 'path' => 'student/dashboard.php', 'key' => 'dashboard', 'icon' => '▦'],
    ['label' => 'Career explorer', 'path' => 'careers/index.php', 'key' => 'careers', 'icon' => '⌕'],
    ['label' => 'Projects', 'path' => 'projects/index.php', 'key' => 'projects', 'icon' => '◇'],
    ['label' => 'Resources', 'path' => 'resources/index.php', 'key' => 'resources', 'icon' => '▤'],
    ['label' => 'My roadmap', 'path' => 'roadmap/index.php', 'key' => 'roadmap', 'icon' => '↗'],
    ['label' => 'Skill Passport', 'path' => 'passport/index.php', 'key' => 'passport', 'icon' => '✳'],
];
?>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="theme-color" content="#101b32">
    <title><?= h($pageTitle) ?> · <?= h(APP_NAME) ?></title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Manrope:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<?= h(url('assets/css/style.css')) ?>">
</head>
<body>
<div class="site-shell">
    <header class="topbar">
        <a class="brand" href="<?= h(url('index.php')) ?>">
            <span class="brand-mark">S<span>G</span></span>
            <span class="brand-name">skillgap<span>passport</span></span>
        </a>
        <?php if ($user): ?>
            <nav class="topnav" aria-label="Main navigation">
                <?php foreach ($navItems as $item): ?>
                    <a class="topnav-link <?= $active === $item['key'] ? 'active' : '' ?>" href="<?= h(url($item['path'])) ?>"><?= h($item['label']) ?></a>
                <?php endforeach; ?>
                <?php if (in_array($user['role'], ['mentor', 'admin'], true)): ?>
                    <a class="topnav-link <?= $active === 'mentor' ? 'active' : '' ?>" href="<?= h(url('mentor/dashboard.php')) ?>">Review</a>
                <?php endif; ?>
                <?php if ($user['role'] === 'admin'): ?>
                    <a class="topnav-link <?= $active === 'admin' ? 'active' : '' ?>" href="<?= h(url('admin/dashboard.php')) ?>">Admin</a>
                <?php endif; ?>
            </nav>
            <div class="topbar-actions">
                <a class="icon-button notification-link" href="<?= h(url('student/notifications.php')) ?>" aria-label="Notifications">♧</a>
                <a class="user-chip" href="<?= h(url('profile/index.php')) ?>"><span class="avatar avatar-sm"><?= h(initials($user['full_name'])) ?></span><span class="user-chip-name"><?= h(explode(' ', $user['full_name'])[0]) ?></span></a>
                <a class="logout-link" href="<?= h(url('auth/logout.php')) ?>">Sign out</a>
            </div>
        <?php else: ?>
            <nav class="topnav public-nav"><a class="topnav-link" href="<?= h(url('index.php#how-it-works')) ?>">How it works</a><a class="topnav-link" href="<?= h(url('index.php#features')) ?>">Features</a><a class="topnav-link" href="<?= h(url('index.php#careers')) ?>">Explore careers</a></nav>
            <div class="topbar-actions"><a class="login-link" href="<?= h(url('auth/login.php')) ?>">Sign in</a><a class="btn btn-primary btn-sm" href="<?= h(url('auth/register.php')) ?>">Get started <span>↗</span></a></div>
        <?php endif; ?>
        <button class="mobile-menu-button" type="button" aria-label="Open navigation" data-menu-toggle>☰</button>
    </header>
    <?php if ($flashes): ?>
        <div class="flash-stack container">
            <?php foreach ($flashes as $notice): ?>
                <div class="alert alert-<?= h($notice['type']) ?>"><span><?= h($notice['message']) ?></span><button type="button" class="alert-close" aria-label="Dismiss">×</button></div>
            <?php endforeach; ?>
        </div>
    <?php endif; ?>
