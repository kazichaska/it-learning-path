# CI/CD (Continuous Integration / Continuous Delivery)

> **The goal:** every change is automatically built, tested and made ready to release, so releasing becomes a non-event you can do many times a day.

## The three terms

| Term | What happens automatically | Human step |
|---|---|---|
| **Continuous Integration (CI)** | On every push/PR: build, lint, test | Merge when green |
| **Continuous Delivery** | CI + produce a deployable artifact and deploy to staging | **A person clicks "deploy to production"** |
| **Continuous Deployment** | Every change that passes all checks goes to production | None |

## A typical pipeline

```
 push / PR
    │
    ▼
 ┌────────┐   ┌──────────┐   ┌─────────┐   ┌──────────────┐   ┌─────────┐   ┌────────────┐
 │  Lint  │──▶│  Test    │──▶│  Build  │──▶│ Security scan│──▶│ Deploy  │──▶│ Deploy prod│
 │        │   │ (unit)   │   │ (image) │   │ (deps, image)│   │ staging │   │ (approval?)│
 └────────┘   └──────────┘   └─────────┘   └──────────────┘   └─────────┘   └────────────┘
                                                                   │              │
                                                              smoke tests    smoke tests,
                                                                             monitor, rollback
```
**Fail fast:** put quick checks (lint) first so developers get feedback in seconds.

## GitHub Actions concepts

| Concept | Meaning |
|---|---|
| **Workflow** | A YAML file in `.github/workflows/` |
| **Event / trigger** | What starts it: `push`, `pull_request`, `schedule`, `workflow_dispatch` (manual), tags |
| **Job** | A group of steps on one fresh machine (runner). Jobs run **in parallel** unless linked with `needs:` |
| **Step** | A shell command (`run:`) or a reusable **action** (`uses:`) |
| **Runner** | The VM that runs the job (`ubuntu-latest`, or self-hosted) |
| **Secrets** | Encrypted values: `${{ secrets.NAME }}`. Never print them |
| **Artifacts / cache** | Pass files between jobs / speed up repeated downloads |
| **Environments** | `staging`/`production` with protection rules (required approvals) |

## 🔍 This repo's own pipeline

[`.github/workflows/ci.yml`](../../.github/workflows/ci.yml) runs on every push to `main` and every pull request:

| Job | What it checks | Why it matters |
|---|---|---|
| `lint` | ShellCheck on Bash scripts, Python and JS syntax | Catches bugs before anything runs |
| `test` | Runs the log analyzer, subnet calculator and health script | Proves the tools actually work |
| `terraform` | `terraform fmt -check` and `terraform validate` | IaC is code too; it needs CI |
| `docker` | Builds the example image, runs it, calls `/health` | A real container smoke test |

`test`, `terraform` and `docker` all have `needs: lint`, so they only run if linting passes, and then run **in parallel**.

See runs in the **Actions** tab on GitHub, or with:
```bash
gh run list
gh run watch
gh run view --log-failed      # show only the logs of failed steps
```

## Example: build & push a Docker image

[`examples/docker-build-push.yml`](examples/docker-build-push.yml) builds a multi-architecture image and pushes it to GitHub Container Registry when you push a tag like `v1.0.0`. Copy it into `.github/workflows/` to activate it.

## Deploying to AWS without storing keys (OIDC)

Instead of saving long-lived AWS keys as secrets, GitHub Actions can **assume an IAM role** using OpenID Connect:

```yaml
permissions:
  id-token: write
  contents: read

steps:
  - uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: arn:aws:iam::123456789012:role/github-deploy
      aws-region: us-east-1
  - run: aws s3 sync ./site s3://my-site-bucket --delete
```
The IAM role's trust policy only allows **your repo** (and optionally only the `main` branch) to assume it.

## Deployment strategies

| Strategy | How | Pros / cons |
|---|---|---|
| **Recreate** | Stop old, start new | Simple; downtime |
| **Rolling** | Replace instances a few at a time | No downtime; two versions live briefly (Kubernetes default) |
| **Blue/green** | Run new version alongside, switch traffic all at once | Instant rollback; double resources |
| **Canary** | Send a small % of traffic to the new version, increase gradually | Safest for big changes; needs good monitoring |
| **Feature flags** | Deploy code "off", enable per user/percentage | Separates deploy from release |

## CI/CD best practices

- ✅ Keep pipelines **fast** (< 10 minutes); cache dependencies
- ✅ **Build once, deploy the same artifact** everywhere (same image tag in staging and prod)
- ✅ Pin action versions (`@v4`, or a commit SHA for maximum security)
- ✅ Least-privilege `permissions:` in each workflow
- ✅ Protect `main`: require PRs, reviews and passing checks (GitHub → Settings → Branches/Rulesets)
- ✅ Automate rollback, or at least make it one command
- ❌ No secrets in logs, code or Docker images

## Other CI/CD tools you'll see in job ads

GitLab CI, Jenkins, CircleCI, Azure DevOps Pipelines, AWS CodePipeline, Argo CD / Flux (GitOps for Kubernetes). The concepts above apply to all of them.

## 🏋️ Exercises

1. Push this repo to GitHub and watch the CI run in the **Actions** tab.
2. Break something on purpose on a branch (e.g. add an unquoted variable to a script), open a PR and watch ShellCheck fail it. Fix it and watch it go green.
3. Add a step that runs `bash 02-linux/scripts/cleanup-old-files.sh /tmp 30` (dry run).
4. Activate the build-and-push example and pull your image with `docker pull ghcr.io/<you>/example-app:v1.0.0`.
5. Turn on branch protection for `main` requiring the CI checks to pass.
