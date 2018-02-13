#!/bin/bash -e

fail_on_error()
{
    local _message="${1}"
    local _error_code=${2}

    if [ ${_error_code} -ne 0 ]
    then
        echo ${_message}
        exit ${_error_code}
    fi
}

echo Ensure you are logged into the correct Concourse instance using fly --target local login --team-name finkit-cpo --concourse-url CONCOURSE_EXTERNAL_URL
echo About to start pipeline - do not quit until the smoking_pipeline Configured message is displayed or errors are identified

fly --target local set-pipeline --pipeline dummy --config dummy.yml --var return_code=0 --non-interactive
fail_on_error "Failed to set dummy pipeline" $?

echo Setting up pipeline
if ! fly --target local pipelines|grep --silent dummy
then
   echo Pipeline not set up - may need to be run a few times after the initial Concourse setup/pipeline destruction
   exit 1
fi
echo Finished setting up pipeline

fly --target local unpause-pipeline --pipeline dummy
fail_on_error "Failed to unpause dummy pipeline" $?

#read -n 1 -s -r -p "Press any key to continue"
#echo

fly --target local trigger-job --job dummy/manual_trigger --watch
fail_on_error "Failed to trigger dummy pipeline" $?

echo dummy pipeline configured
