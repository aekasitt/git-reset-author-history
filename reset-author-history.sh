#!/bin/bash
### Get Current Branch Name ###
branch_name=$(git branch | sed -n 's/^\* //p')

### Get Git History 
git log > git-log.txt
echo 'git-log.txt' >> .gitignore
commits=($(sed -n 's/^\commit //p' < git-log.txt))

### Reverse Commit Order ###
for (( i=${#commits[@]}-1; i>=0; i-- )) do
  reversed_commits[${#reversed_commits[@]}]=${commits[i]}
done

### Checkout into a Temporary Branch ###
git checkout -b ${branch_name}-tmp
git reset --hard "${reversed_commits[0]}"

### Cherry-picks commits from previous branch and resets commit author ###
for commit in "${reversed_commits[@]}"; do
  git cherry-pick --allow-empty $commit
  git commit --amend --reset-author --no-edit
  git cherry-pick --allow-empty --skip >> /dev/null 2>&1
done

### Clear ###
unset commits
unset reversed_commits
rm -f git-log.txt

### Danger Zone ###
# git branch -D ${branch_name}
# git branch -M ${branch_name}-tmp ${branch_name}
# git branch --set-upstream-to origin/${branch_name}
# git push --force
