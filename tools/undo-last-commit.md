```
git tag -d 0.5.10
git push origin --delete 0.5.10
git reset --hard HEAD~1
git push origin main --force

# undo git reset --soft HEAD~1
git tag -d 0.5.10
git push origin --delete 0.5.10
git reset --hard HEAD
git push origin main --force
```
