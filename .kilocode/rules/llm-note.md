## 📘 General Workflow + Flake Development Notes

### Context
We don’t use **home-manager** standalone — it’s fully managed under NixOS.  
Useful fish functions live in `./home-modules/fish.nix`.

**⚠️ Reminder:**  
No configuration actually applies until you **rebuild** the target host.  
If you're working on configs for a *different* host, make sure that host’s user performs the rebuild.

Always `git add .` whenever you create **new files or directories** to update the git tree, ensuring flakes evaluate correctly.

---

## 🧩 Rebuild / Git Integration Commands

### One-Step Full Commit-Rebuild-Push
```bash
nixos-commit-rebuild-push "<[feat|fix|refactor|docs]:4/5-word-summary>"
```
> - Automatically stages all new files (`git add .`)
> - Prompts for commit message following conventions  
> - Runs `flake check`, rebuilds, then pushes

### Basic Rebuild (No Git)
```bash
nixos-rebuild-basic
```
> Runs system rebuild **without committing changes**  
> ⚠️ Won’t stage or update the flake tree; use only for local trials.

---

## ⚒️ Useful Commands

**Test machine-specific configuration:**
```bash
nixos-rebuild dry-run --flake .#<hostname>
```

**Validate flakes/configurations:**
```bash
nix flake check
```

**Search nixpkgs:**
```bash
nix search nixpkgs <package>
```

**Check Hyprland configuration errors:**
```bash
hyprctl configerrors
```

**View Hyprland help:**
```bash
hyprctl -h
```

**Check system identity:**
```bash
whoami && hostname && fastfetch
```

**Recent logs and kernel messages:**
```bash
journalctl | tail -80 && sudo dmesg | tail -40
```

**Tip:** Any command can be explored with `-h`, `--help`, `tldr`, or `man`.

---

# 💾 Commit Conventions (Integrated Quick Reference)

### 🧠 Format
```
<type>(scope): <action> <summary>

[optional body]
```

### 🧩 Type Categories
```
feat     - New feature
fix      - Bug fix
refactor - Restructure / no behavior change
docs     - Documentation / comments
style    - Formatting, whitespace
test     - Add/modify tests
chore    - Maintenance
perf     - Performance improvement
revert   - Undo previous commit
```

### 🎯 Scope Rules
- Use file basenames (e.g. `networking,hardware`)
- Max 3 files; use directory name if covering several
- Omit extensions unless ambiguous  
- No full paths — scope stays clean!

**Good:**  
`feat(home_modules): add wezterm terminal configuration`

**Bad:**  
`feat(shimboot_config/.../networking.nix): add networking config`

---

### 💬 Action Verbs
Use clear, imperative verbs:
```
add | remove | update | fix | refactor | implement
enable | disable | configure | integrate
```

---

### ✍️ Summary Rules
- Imperative mood (`add`, not `added`)
- Lowercase first word  
- No trailing period  
- ≤72 characters including type/scope  
- Explain **what changed**, not **why**

**Good:** `add zram swap configuration`  
**Bad:** `Added zram swap configuration because it improves performance.`

---

### 🧾 Commit Examples

**Simple Feature:**
```
feat(zram.nix): add zram swap configuration
```

**Multi-file Refactor:**
```
refactor(helpers): split filesystem and setup helpers
```

**Documentation Update:**
```
docs(SPEC): update section 5 with module structure
```

**Fix:**
```
fix(assemble-final.sh): correct vendor partition bind order
```

**Maintenance:**
```
chore(flake): update nixpkgs input to latest unstable
```

---

### 📜 Bodies (When Needed)
Add a body if:
- Complex reasoning
- Multiple related edits
- Breaking changes
- Non-obvious effects

**Example:**
```
fix(harvest-drivers.sh): prevent firmware symlink breakage

ChromeOS firmware contains symlinks to /opt/* paths that broke
when copied. Uses cp -L to dereference symlinks safely.

- Add -L flag to cp commands
- Verify firmware loads correctly
```

---

### 🧩 Automation & Validation

**Git Commit Alias:**
```bash
git c feat zram.nix add zram swap configuration
```

**Pre-Commit Message Check (Pattern Match):**
```bash
^(feat|fix|docs|style|refactor|test|chore|perf|revert)\([^)]+\): [a-z].+[^.]$
```

**Flake Validation Before Commit:**
```bash
nix flake check --impure --accept-flake-config
```

---

### ✅ Pre-Commit Checklist
```
[ ] No build artifacts staged (git status --ignored)
[ ] Flake passes nix flake check
[ ] Commit message follows conventions
[ ] Module header present if new .nix file
[ ] `git add .` performed for new files
```

---

**Quick Reference Commands:**
```bash
# Check git ignore rules
git status --ignored

# Check tracked files
git ls-files

# Evaluate flake
nix flake check --impure --accept-flake-config

# Inspect flake outputs
nix flake show
```