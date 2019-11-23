
echo "VERIFYING PERSONAL ACCESS TOKEN"
    if [[ -z "$ACCESS_TOKEN_SECRET" ]]; then
        echo "Please set env var ACCESS_TOKEN_SECRET for git host: $GIT_HOST"
        exit 1
    fi

cd "$HOME"

TAG="$BUILD_SOURCEBRANCHNAME-$(echo $BUILD_SOURCEVERSION | cut -c1-7)"

# Remove http(s):// protocol from URL so we can insert PA token
repo_url=$GIT_CONFIGURATION_REPO
repo_url="${repo_url#http://}"
repo_url="${repo_url#https://}"

echo repo_url
echo "GIT CLONE: https://$ACCESS_TOKEN_SECRET@$repo_url"
git clone "https://$ACCESS_TOKEN_SECRET@$repo_url"

repo=${repo_url##*/}
repo_name=${repo%.*}

cd "$repo_name"
echo "GIT PULL ORIGIN MASTER"
git pull origin master
cd $PATH_IN_GIT_CONFIGURATION_REPO
cd $ENVIRONMENTNAME


sed -i "s/docker_image_tag.*/docker_image_tag:'$TAG',/g" params.libsonnet

git config user.email "mats@iremark.se"
git config user.name "Automated Azure Devops Account"

echo "GIT COMMIT"
git add params.libsonnet
git commit -m "$PATH_IN_GIT_CONFIGURATION_REPO - $ENVIRONMENTNAME - $TAG"

echo "GIT PUSH"
echo "GIT PUSH: https://$ACCESS_TOKEN_SECRET@$repo_url"
git push "https://$ACCESS_TOKEN_SECRET@$repo_url"
retVal=$? && [ $retVal -ne 0 ] && exit $retVal
echo "GIT STATUS"
git status