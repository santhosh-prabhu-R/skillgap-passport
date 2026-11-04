    <footer class="footer">
        <div class="footer-inner">
            <a class="brand" href="<?= h(url('index.php')) ?>"><span class="brand-mark">S<span>G</span></span><span class="brand-name">skillgap<span>passport</span></span></a>
            <p>Build skills you can demonstrate. Move towards a career with clarity.</p>
            <span class="footer-copy">© <?= date('Y') ?> SkillGap Passport · Academic project</span>
        </div>
    </footer>
</div>
<script>window.APP_BASE_URL = <?= json_encode(rtrim(BASE_URL, '/')) ?>;</script>
<script src="<?= h(url('assets/js/app.js')) ?>"></script>
</body>
</html>
