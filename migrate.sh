


usage="$0 source_repo target_repo"
if [[ $# < 2 ]]; then
    echo $usage
    exit 1
fi

rootdir=`dirname $0`
cachedir=$rootdir/gitmigratecache

git clone $1 $cachedir
pushd $cachedir
for r in `git branch -r|grep -v 'master\|HEAD'`; do
    git branch ${r#*/} --track $r
done
git push --all $2
git push --tags $2
popd

rm -rf $cachedir



