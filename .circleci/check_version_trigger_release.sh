#!/usr/bin/env bash
set -e

#!/usr/bin/env bash
LATEST_COMMIT=$(git rev-parse HEAD)
VERSION_COMMIT=$(git log -1 --format=format:%H VERSION)
if [ $VERSION_COMMIT = $LATEST_COMMIT ];
    then
        if [ -s VERSION ] # Check if content is empty
            then 
                VERSION=`cat VERSION`
                echo "VERSION is changed to $VERSION" 
            else 
                echo "[ERROR] VERSION file is empty."
                exit 1
        fi 
        # git checkout develop
        # git pull origin develop
        # git checkout -b release/$VERSION origin/develop
        # git push origin release/$VERSION
        # git checkout master
        # git merge --no-edit release/$VERSION
        # git tag -a $VERSION -m 'Release Tag $VERSION'
        # git push origin master
        # git push origin --tags
fi
VERSION=`cat VERSION`
git checkout release_process
git pull origin release_process
git checkout -b dummy/$VERSION origin/release_process
git push https://$RELEASE_GITHUB_USER:$RELEASE_GITHUB_PASS@github.com/splunk/fluent-plugin-kubernetes-metrics.git dummy/$VERSION
git checkout -b dummy_master
git merge --no-edit dummy/$VERSION
git tag -a $VERSION -m 'Release Tag $VERSION'
git push origin dummy_master
git push origin --tags