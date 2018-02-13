#!/bin/bash -e

# Needs sudo.
# Should not write to history.

if [ -z "${CONCOURSE_PASSWORD}" ]
then
    echo Must specify a password in CONCOURSE_PASSWORD
fi

CONCOURSE_EXTERNAL_URL="https://concourse.build.finkit.io"

secure_concourse()
{
    # TODO Use OAuth and standard accounts as described at https://concourse.ci/teams.html#authentication.
    sudo apt install --yes pwgen
    export CPO_ENG_PASSWORD=$(pwgen --num-passwords=1)
    echo The CPO Eng password is ${CPO_ENG_PASSWORD} - Store it securely, as it should not be available by other means.
    fly --target local set-team --team-name finkit-cpo --basic-auth-username cpo_eng --basic-auth-password ${CPO_ENG_PASSWORD} --non-interactive
    fly --target local login --team-name finkit-cpo --username cpo_eng --password ${CPO_ENG_PASSWORD}
    unset CPO_ENG_PASSWORD
}

if [ -n "${http_proxy}" -o -n "${https_proxy}" ]
then
    echo "*** Either disable any intermediate proxy (possibly just for Concourse via no_proxy) or ensure it allows the host to be contacted ***"
fi

if [ ! -f /usr/local/bin/fly ]
then
    sudo wget --no-clobber --output-document /usr/local/bin/fly https://github.com/concourse/concourse/releases/download/v3.8.0/fly_linux_amd64
fi

sudo chown ${USER}:$(id --group --name) /usr/local/bin/fly
sudo chmod u+x /usr/local/bin/fly

fly --target local login --username=cpo --password=${CONCOURSE_PASSWORD} --concourse-url=${CONCOURSE_EXTERNAL_URL}

# If the last command failed, it may be because of a version mismatch, which a sync should correct.
if [ $? -ne 0 ]
then
    fly --target local sync
    fly --target local login --username=cpo --password=${CONCOURSE_PASSWORD} --concourse-url=${CONCOURSE_EXTERNAL_URL}
fi

secure_concourse
