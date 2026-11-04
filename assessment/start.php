<?php
require_once __DIR__ . '/../includes/functions.php';
require_login();
require_once __DIR__ . '/../config/database.php';

$roleId = (int)($_GET['role_id'] ?? 0);
$roleStmt = $pdo->prepare('SELECT * FROM job_roles WHERE job_role_id = ? AND is_active = 1');
$roleStmt->execute([$roleId]);
$role = $roleStmt->fetch();
if (!$role) {
    flash('Choose a valid career role before starting an assessment.', 'error');
    redirect('careers/index.php');
}

$userId = (int)current_user()['user_id'];
$skillStmt = $pdo->prepare('SELECT s.skill_id,s.skill_name,s.description,rs.required_level,rs.importance_weight,us.self_assessed_level FROM role_skills rs JOIN skills s ON s.skill_id=rs.skill_id LEFT JOIN user_skills us ON us.skill_id=s.skill_id AND us.user_id=? WHERE rs.job_role_id=? ORDER BY rs.importance_weight DESC,s.skill_name');
$skillStmt->execute([$userId, $roleId]);
$skills = $skillStmt->fetchAll();

$quizQuestions = [];
$optionsByQuestion = [];
if ($skills) {
    $questionStmt = $pdo->prepare('SELECT q.question_id,q.skill_id,q.question_text,q.difficulty,q.points,q.explanation,s.skill_name FROM assessment_questions q JOIN skills s ON s.skill_id=q.skill_id JOIN role_skills rs ON rs.skill_id=q.skill_id WHERE rs.job_role_id=? AND q.is_active=1 ORDER BY q.difficulty,q.question_id LIMIT 20');
    $questionStmt->execute([$roleId]);
    $quizQuestions = $questionStmt->fetchAll();
    if ($quizQuestions) {
        $questionIds = array_map(fn($q) => (int)$q['question_id'], $quizQuestions);
        $placeholders = implode(',', array_fill(0, count($questionIds), '?'));
        $optionStmt = $pdo->prepare("SELECT option_id,question_id,option_text,option_order FROM assessment_options WHERE question_id IN ($placeholders) ORDER BY question_id,option_order");
        $optionStmt->execute($questionIds);
        foreach ($optionStmt->fetchAll() as $option) {
            $optionsByQuestion[(int)$option['question_id']][] = $option;
        }
    }
}

$errors = [];
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    verify_csrf();
    $levels = $_POST['levels'] ?? [];
    if (!$skills) $errors[] = 'This career role does not have any mapped skills yet.';
    foreach ($skills as $skill) {
        $skillId = (int)$skill['skill_id'];
        $value = $levels[$skillId] ?? null;
        if ($value === null || filter_var($value, FILTER_VALIDATE_INT) === false || (int)$value < 0 || (int)$value > 5) {
            $errors[] = 'Please select a proficiency level for every skill.';
            break;
        }
    }

    if (!$errors) {
        $weighted = 0.0;
        $totalWeight = 0.0;
        $cleanResults = [];
        foreach ($skills as $skill) {
            $skillId = (int)$skill['skill_id'];
            $current = (int)$levels[$skillId];
            $required = (int)$skill['required_level'];
            $weight = (float)$skill['importance_weight'];
            $coverage = $required > 0 ? min($current / $required, 1) * 100 : 100;
            $gap = max(0, $required - $current);
            $weighted += $coverage * $weight;
            $totalWeight += $weight;
            $cleanResults[] = ['skill_id'=>$skillId, 'current'=>$current, 'required'=>$required, 'gap'=>$gap, 'coverage'=>$coverage];
        }
        $score = $totalWeight > 0 ? $weighted / $totalWeight : 0;

        try {
            $pdo->beginTransaction();
            $insertAssessment = $pdo->prepare("INSERT INTO assessments (user_id,job_role_id,status,readiness_score,completed_at) VALUES (?,?,'completed',?,NOW())");
            $insertAssessment->execute([$userId, $roleId, round($score, 2)]);
            $assessmentId = (int)$pdo->lastInsertId();

            $upsertSkill = $pdo->prepare('INSERT INTO user_skills (user_id,skill_id,self_assessed_level,last_assessed_at) VALUES (?,?,?,NOW()) ON DUPLICATE KEY UPDATE self_assessed_level=VALUES(self_assessed_level),last_assessed_at=NOW()');
            $insertResult = $pdo->prepare('INSERT INTO assessment_results (assessment_id,skill_id,current_level,required_level,gap_level,coverage_percent) VALUES (?,?,?,?,?,?)');
            foreach ($cleanResults as $result) {
                $upsertSkill->execute([$userId, $result['skill_id'], $result['current']]);
                $insertResult->execute([$assessmentId, $result['skill_id'], $result['current'], $result['required'], $result['gap'], round($result['coverage'], 2)]);
            }

            // Optional knowledge-check answers are recorded separately and do not alter self-assessed coverage.
            if ($quizQuestions) {
                $checkOption = $pdo->prepare('SELECT is_correct FROM assessment_options WHERE option_id=? AND question_id=?');
                $saveAnswer = $pdo->prepare('INSERT INTO assessment_answers (assessment_id,question_id,selected_option_id,is_correct,earned_points) VALUES (?,?,?,?,?)');
                $submittedAnswers = $_POST['quiz'] ?? [];
                foreach ($quizQuestions as $question) {
                    $questionId = (int)$question['question_id'];
                    $optionId = (int)($submittedAnswers[$questionId] ?? 0);
                    if (!$optionId) continue;
                    $checkOption->execute([$optionId, $questionId]);
                    $choice = $checkOption->fetch();
                    if (!$choice) continue;
                    $correct = (int)$choice['is_correct'];
                    $points = $correct ? (float)$question['points'] : 0.0;
                    $saveAnswer->execute([$assessmentId, $questionId, $optionId, $correct, $points]);
                }
            }

            $pdo->commit();
            award_achievement($pdo, $userId, 'FIRST_ASSESSMENT');
            $profiledStmt = $pdo->prepare('SELECT COUNT(*) FROM user_skills WHERE user_id=? AND self_assessed_level > 0');
            $profiledStmt->execute([$userId]);
            if ((int)$profiledStmt->fetchColumn() >= 5) award_achievement($pdo, $userId, 'FIVE_SKILLS');
            create_notification($pdo, $userId, 'Assessment completed', 'Your ' . $role['role_name'] . ' skill assessment is ready. Review your gaps and generate a roadmap.', 'assessment', 'assessment/result.php?id=' . $assessmentId);
            redirect('assessment/result.php?id=' . $assessmentId);
        } catch (Throwable $e) {
            if ($pdo->inTransaction()) $pdo->rollBack();
            error_log('Assessment save failed: ' . $e->getMessage());
            $errors[] = 'We could not save the assessment. Please try again.';
        }
    }
}

$pageTitle = 'Skill assessment';
$active = 'careers';
include __DIR__ . '/../includes/header.php';
?>
<main class="main"><div class="container section-sm">
    <div class="page-head"><div><span class="eyebrow">Career skill assessment</span><h1 class="h1"><?=h($role['role_name'])?></h1><p>Rate what you can do today. Be honest—this is a planning tool, not an exam or a judgment.</p></div><a class="btn btn-outline" href="<?=h(url('careers/view.php?id='.$roleId))?>">← Back to role</a></div>
    <div class="assessment-intro"><div class="row-between"><div><strong style="font-size:13px">How to choose a level</strong><p class="muted small" style="margin:4px 0 0">Use the descriptions below. Your answer can be changed after you gain more practice.</p></div><span class="pill pill-blue"><?=count($skills)?> skills to assess</span></div><div class="grid grid-3" style="margin-top:15px;gap:8px"><div class="tag">0 · No experience</div><div class="tag">1 · Beginner</div><div class="tag">2 · Basic</div><div class="tag">3 · Intermediate</div><div class="tag">4 · Advanced</div><div class="tag">5 · Expert</div></div></div>
    <?php if ($errors): ?><div class="alert alert-error"><?=implode('<br>', array_map('h', $errors))?></div><?php endif; ?>
    <form method="post" class="card" style="overflow:hidden"><?=csrf_field()?>
        <?php foreach ($skills as $i=>$skill): $current = $skill['self_assessed_level'] === null ? null : (int)$skill['self_assessed_level']; ?>
            <div class="assessment-skill"><div class="row-between" style="align-items:flex-start"><div><h3><?=($i+1)?>. <?=h($skill['skill_name'])?></h3><p><?=h($skill['description'])?></p></div><span class="pill pill-amber">Role target: <?=h(level_label((int)$skill['required_level']))?></span></div>
                <div class="assessment-levels"><?php for ($level=0; $level<=5; $level++): ?><label class="level-option"><input type="radio" name="levels[<?=(int)$skill['skill_id']?>]" value="<?=$level?>" <?=($current !== null && $current === $level) ? 'checked' : ''?> required><span><strong><?=$level?></strong><?=h(level_label($level))?></span></label><?php endfor; ?></div>
            </div>
        <?php endforeach; ?>
        <?php if ($quizQuestions): ?>
            <div class="form-section" style="background:#f8faff;border-top:1px solid var(--line)"><div class="panel-title"><div><h3>Optional knowledge check</h3><p class="muted tiny" style="margin:4px 0 0">Try the starter questions connected to this role. Unanswered questions are skipped. Quiz answers are stored separately and do not change your self-assessed skill coverage.</p></div><span class="pill pill-blue"><?=count($quizQuestions)?> questions</span></div>
            <?php foreach ($quizQuestions as $qi=>$question): ?><div style="padding:14px 0;border-bottom:1px solid var(--line)"><div class="row-between"><strong style="font-size:13px"><?=($qi+1)?>. <?=h($question['question_text'])?></strong><span class="tag"><?=h($question['skill_name'])?></span></div><div class="grid grid-2" style="margin-top:10px;gap:8px"><?php foreach (($optionsByQuestion[(int)$question['question_id']] ?? []) as $option): ?><label class="level-option"><input type="radio" name="quiz[<?=(int)$question['question_id']?>]" value="<?=(int)$option['option_id']?>"><span style="min-height:42px;padding:8px;text-align:left"><?=h($option['option_text'])?></span></label><?php endforeach; ?></div></div><?php endforeach; ?></div>
        <?php endif; ?>
        <div class="form-section"><p class="muted tiny">The weighted result uses the proficiency levels you select and the editable role requirements in this starter catalogue. It is not a certified measure of employability.</p><div class="form-actions"><button class="btn btn-primary" type="submit">Calculate my skill gaps →</button><a class="btn btn-outline" href="<?=h(url('careers/view.php?id='.$roleId))?>">Cancel</a></div></div>
    </form>
</div></main>
<?php include __DIR__ . '/../includes/footer.php'; ?>
