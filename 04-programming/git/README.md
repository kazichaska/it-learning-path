# Git & GitHub

> In DevOps, **everything lives in Git**: application code, infrastructure (Terraform), pipelines (GitHub Actions), Kubernetes manifests, docs. "If it's not in Git, it doesn't exist."

## The mental model

```
 Working directory ──git add──▶ Staging area ──git commit──▶ Local repo ──git push──▶ Remote (GitHub)
   (your files)                  (next snapshot)              (history)               (shared)
        ◀───────────────────────────────── git pull / git fetch + merge ◀─────────────────────
```

- A **commit** is a snapshot of the whole project plus a message, author and a unique ID (SHA).
- A **branch** is just a movable pointer to a commit.
- **HEAD** is "where you are now."
- **origin** is the usual name for your main remote.

## One-time setup

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
git config --global pull.rebase false        # or true, if your team prefers rebasing
gh auth login                                # GitHub CLI login
```

## Daily commands

```bash
git status                     # what changed? (run it constantly)
git diff                       # unstaged changes, line by line
git diff --staged              # what you're about to commit
git add file.txt               # stage one file
git add -p                     # stage changes hunk by hunk (review as you go)
git commit -m "Add backup script with rotation"
git push                       # upload commits
git pull                       # download + merge others' commits
git log --oneline --graph --all -20   # visual history
```

## Branching workflow (how teams work)

```bash
git switch -c feature/add-health-check     # create + switch to a new branch
# ...edit, add, commit...
git push -u origin feature/add-health-check
gh pr create --fill                        # open a pull request
gh pr view --web
# after review & merge on GitHub:
git switch main
git pull
git branch -d feature/add-health-check     # delete the local branch
```

**Why branches + PRs?**
- `main` always stays deployable
- Every change gets **reviewed** and **tested by CI** before merging
- History shows *why* things changed

### Merge vs rebase
| | Merge | Rebase |
|---|---|---|
| What it does | Joins histories with a merge commit | Replays your commits on top of the latest main |
| History | True but branchy | Linear and clean |
| Safety | Never rewrites history | Rewrites your commits; **never rebase shared branches** |

### Resolving merge conflicts
```
<<<<<<< HEAD
port = 8080
=======
port = 9090
>>>>>>> feature/change-port
```
Edit the file to the correct final version, delete the markers, then `git add file` and `git commit` (or `git rebase --continue`).

## Undoing things (the most valuable section)

| Situation | Command |
|---|---|
| Discard uncommitted changes to a file | `git restore file.txt` |
| Unstage a file (keep the changes) | `git restore --staged file.txt` |
| Fix the last commit's message / add a forgotten file (not pushed yet) | `git commit --amend` |
| Undo the last commit but keep the changes (not pushed yet) | `git reset --soft HEAD~1` |
| Undo a commit that's **already pushed** | `git revert <sha>` (creates a new "undo" commit; safe) |
| "I lost a commit!" | `git reflog` (shows everywhere HEAD has been; recover with `git switch -c rescue <sha>`) |
| Save work-in-progress temporarily | `git stash` … `git stash pop` |

⚠️ `git reset --hard` and `git push --force` **destroy** work. On shared branches, use `revert`, not `reset`. If you must force-push your own branch, use `git push --force-with-lease`.

## Good commit messages

```
Add nightly backup cron job for the web server

The old manual process was skipped twice last month. This runs
backup.sh at 02:00 and keeps 14 days of archives.
```
- Short summary line (≈50 chars), imperative mood: "Add", "Fix", "Remove"
- Explain **why** in the body when it isn't obvious
- Many teams use **Conventional Commits**: `feat: …`, `fix: …`, `docs: …`, `ci: …`

## .gitignore and secrets

- Ignore build output, dependencies, local env files, Terraform state (see this repo's [`.gitignore`](../../.gitignore))
- **If you commit a secret, removing it in a later commit is not enough**: it's still in history. **Rotate the secret immediately**, then clean history if needed (`git filter-repo`). Enable GitHub's secret scanning and push protection.

## Tags and releases

```bash
git tag -a v1.0.0 -m "First stable release"
git push origin v1.0.0
gh release create v1.0.0 --generate-notes
```
Tags often trigger CI/CD release pipelines.

## 🏋️ Exercises (do them in this repo!)

1. Create a branch `notes/linux-week1`, add a file of notes, commit, push and open a PR with `gh pr create`. Merge it on GitHub, then sync your local `main`.
2. Make a commit with a typo in the message, then fix it with `--amend` (before pushing).
3. Make a commit, push it, then undo it with `git revert`. Look at `git log`: what happened?
4. Create a merge conflict on purpose: change the same line on two branches, merge them and resolve it.
5. Delete a file, commit, then recover it from the previous commit: `git restore --source=HEAD~1 path/to/file`.

## 📚 Learn more
- Pro Git book (free): https://git-scm.com/book
- Visual branching game: https://learngitbranching.js.org/
- Oh Sh*t, Git!?! (fixes for common mistakes): https://ohshitgit.com/
