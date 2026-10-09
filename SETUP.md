# Setup (one time)

## 1. Jenkins server (Amazon Linux 2023)
    dnf install -y docker && systemctl enable --now docker && usermod -aG docker jenkins
    # gh CLI
    GH_VER=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | grep -oP '"tag_name": "v\K[^"]+')
    dnf install -y "https://github.com/cli/cli/releases/download/v${GH_VER}/gh_${GH_VER}_linux_amd64.rpm"
    # shellcheck
    cd /tmp && curl -LO https://github.com/koalaman/shellcheck/releases/download/v0.10.0/shellcheck-v0.10.0.linux.x86_64.tar.xz
    tar -xf shellcheck-v0.10.0.linux.x86_64.tar.xz && cp shellcheck-v0.10.0/shellcheck /usr/local/bin/
    systemctl restart jenkins

## 2. Jenkins
- Credentials: Username with password, ID `github-pat` (user = GitHub user, password = PAT with `repo` scope)
- New Item -> Multibranch Pipeline -> GitHub source
  - Behaviours: Discover branches, Discover pull requests from origin
  - Scan Repository Triggers: Periodically if not otherwise run -> 1 minute

## 3. GitHub
- Settings -> General -> Allow auto-merge
- Settings -> Branches -> rule for `main`:
  - Require status checks to pass -> add `continuous-integration/jenkins/pr-head`
  - (optional) Require a pull request before merging

## 4. Developer workflow
    git checkout -b feature/xyz
    # add / edit scripts/*.sh  (any *.sh in the repo is validated)
    git push origin feature/xyz
    # later pushes:  git pull --rebase origin feature/xyz  (bot pushes to your branch)
