#!/bin/sh

SSH_KEY_PATH="$HOME/.ssh/openmw_deploy"
REMOTE_PATH="\$HOME/nightly"

# Add SSH key, here's how it's encoded to make Travis not choke upon newlines: https://github.com/travis-ci/travis-ci/issues/7715#issuecomment-433301692
echo "$OSX_DEPLOY_KEY" > "$SSH_KEY_PATH"
chmod 600 "$SSH_KEY_PATH"
# Make sure host is known, the line can be obtained by using ssh-keygen -F [host]:port
echo "$OSX_DEPLOY_HOST_FINGERPRINT" >> "$HOME/.ssh/known_hosts"

cd build || exit 1

DATE=$(date +'%d%m%Y')
SHORT_COMMIT=$(git rev-parse --short "${TRAVIS_COMMIT}")
TARGET_FILENAME="OpenMW-${DATE}-${SHORT_COMMIT}.dmg"

if ! ssh -p "$OSX_DEPLOY_PORT" -i "$SSH_KEY_PATH" "$OSX_DEPLOY_HOST" sh -c "ls \"$REMOTE_PATH\"" | grep "$SHORT_COMMIT" > /dev/null; then
    scp -P "$OSX_DEPLOY_PORT" -i "$SSH_KEY_PATH" ./*.dmg "$OSX_DEPLOY_HOST:$REMOTE_PATH/$TARGET_FILENAME"
fi
