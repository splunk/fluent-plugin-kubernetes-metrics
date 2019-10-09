#!/usr/bin/env bash
set -e

#!/usr/bin/env bash
LATEST_COMMIT=$(git rev-parse HEAD)
VERSION_COMMIT=$(git log -1 --format=format:%H VERSION)
if [ $VERSION_COMMIT = $LATEST_COMMIT ];
    then
        VERSION=`cat VERSION`
        echo "VERSION is changed to $VERSION"
        git checkout develop
        git pull origin develop
        git checkout -b release/$VERSION origin/develop
        git push origin release/$VERSION
        git checkout master
        git merge --no-edit release/$VERSION
        git tag -a $VERSION -m 'Release Tag $VERSION'
        git push origin master
        git push origin --tags
fi