<?php
require_once __DIR__ . '/../config/app.php';
if (session_status() !== PHP_SESSION_ACTIVE) {
    session_start();
}

function url(string $path = ''): string {
    return rtrim(BASE_URL, '/') . ($path ? '/' . ltrim($path, '/') : '/');
}
function h($value): string {
    return htmlspecialchars((string)($value ?? ''), ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}
function redirect(string $path): never {
    header('Location: ' . url($path));
    exit;
}
function current_user(): ?array {
    return $_SESSION['user'] ?? null;
}
function is_logged_in(): bool {
    return current_user() !== null;
}
function require_login(): void {
    if (!is_logged_in()) {
        flash('Please sign in to continue.', 'info');
        redirect('auth/login.php');
    }
}
function require_role(string ...$roles): void {
    require_login();
    $role = current_user()['role'] ?? 'student';
    if (!in_array($role, $roles, true)) {
        http_response_code(403);
        $pageTitle = 'Access denied';
        include __DIR__ . '/header.php';
        echo '<main class="container narrow"><section class="empty-state"><div class="empty-icon">🔒</div><h1>Access restricted</h1><p>Your account does not have permission to open this page.</p><a class="btn btn-primary" href="' . h(url('student/dashboard.php')) . '">Back to dashboard</a></section></main>';
        include __DIR__ . '/footer.php';
        exit;
    }
}
function flash(string $message, string $type = 'success'): void {
    $_SESSION['flash'][] = ['message' => $message, 'type' => $type];
}
function pull_flashes(): array {
    $flashes = $_SESSION['flash'] ?? [];
    unset($_SESSION['flash']);
    return $flashes;
}
function csrf_token(): string {
    if (empty($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf_token'];
}
function csrf_field(): string {
    return '<input type="hidden" name="csrf_token" value="' . h(csrf_token()) . '">';
}
function verify_csrf(): void {
    $sent = $_POST['csrf_token'] ?? '';
    if (!$sent || !hash_equals(csrf_token(), $sent)) {
        http_response_code(419);
        exit('Your form session expired. Go back, refresh the page and try again.');
    }
}
function level_label(int $level): string {
    $labels = ['No experience', 'Beginner', 'Basic', 'Intermediate', 'Advanced', 'Expert'];
    return $labels[max(0, min(5, $level))];
}
function level_description(int $level): string {
    $descriptions = [
        'I have not learned this skill yet.',
        'I understand a few basic concepts.',
        'I can complete simple tasks with guidance.',
        'I can complete practical tasks independently.',
        'I can handle complex tasks and troubleshoot issues.',
        'I can design, optimize and guide others in this area.'
    ];
    return $descriptions[max(0, min(5, $level))];
}
function award_achievement(PDO $pdo, int $userId, string $code): void {
    $stmt = $pdo->prepare('SELECT achievement_id FROM achievements WHERE achievement_code = ? AND is_active = 1 LIMIT 1');
    $stmt->execute([$code]);
    $achievementId = $stmt->fetchColumn();
    if ($achievementId) {
        $insert = $pdo->prepare('INSERT IGNORE INTO user_achievements (user_id, achievement_id) VALUES (?, ?)');
        $insert->execute([$userId, $achievementId]);
    }
}
function create_notification(PDO $pdo, int $userId, string $title, string $message, string $type = 'general', ?string $target = null): void {
    $stmt = $pdo->prepare('INSERT INTO notifications (user_id, title, message, notification_type, target_url) VALUES (?, ?, ?, ?, ?)');
    $stmt->execute([$userId, $title, $message, $type, $target]);
}
function initials(string $name): string {
    $parts = preg_split('/\s+/', trim($name));
    $letters = '';
    foreach (array_slice($parts, 0, 2) as $part) {
        $letters .= strtoupper(substr($part, 0, 1));
    }
    return $letters ?: 'SG';
}
function safe_return(string $candidate, string $fallback = 'student/dashboard.php'): string {
    if (str_starts_with($candidate, '/') || str_contains($candidate, '://') || str_contains($candidate, '..')) {
        return $fallback;
    }
    return $candidate ?: $fallback;
}
