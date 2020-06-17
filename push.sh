
usage="$0 target_repo"
if [[ $# < 1 ]]; then
    echo $usage
    exit 1
fi

for r in `git branch -r|grep -v 'master\|HEAD'`; do
    git branch ${r#*/} --track $r
done
git push --all $1
git push --tags $1


