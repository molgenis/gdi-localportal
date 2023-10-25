#!/bin/bah

###
# This is a script that creates the "static" parts of the REMS (organizations, forms, workflows ...)
# It is called only once, before synchronization script is executed
###

while ! curl -s http://localhost:3000 2>&1 1>/dev/null; do
   echo " - [ makeusers.sh ] REMS not yet up, waiting ..."
   sleep 1;
done

_organization_id="umcg"
_organization_short_name="${_organization_id}"
_organization_name="Universitair Medisch Centrum Groningen"

_licence_title="Main License Agreement"
_licence_textcontent="The data here is a placeholder until the actual data will be uploaded.\nViewing, (re)using or accessing of the data on this website/server and connected resources, is permitted upon request and only after access request has been granted by this website owner."

_resource_id="urn:gdi:example-dataset"
_resource_org_id="${_organization_id}"
_resource_title="Dataset"
_resource_textcontent="resource textcontend"

_form_title="Data Access Request Form"
_form_internal_name="${_form_title}"
_form_external_title="${_form_title}"

_workflow_title="Default Workflow"
#_form_id="7"       # uncomment this to fix against specific form

_catalogue_title="example cataloge dataset"

# re to check the numbers
re='^[0-9]+$'

# A helper function to call 
# parameters [PUT] ["base API URL"] ["archived" or "enabled"] [item ID number] [archived or enabled boolean "true" or "false"]
function _curl(){
    _mode="${1}"        # PUT (or GET / POST)
    _api="${2}"         # api/licenes/enables
    shift 2
    _data="${*}"        # json data to be sumbitted
    _command="curl -s -X ${_mode} ${REMS_URL}${_api} \
        -H \"content-type: application/json\" \
        -H \"x-rems-api-key: ${REMS_API_KEY}\" \
        -H \"x-rems-user-id: ${REMS_OWNER}\" \
        -d '${_data}'"
    _curl_return=$(eval "${_command}")
    _curl_return_id=$(echo "${_curl_return}" | jq .id 2>/dev/null)
    _curl_success=$(echo "${_curl_return}" | jq .success 2>/dev/null)
    if [[ ${_mode} != "GET" ]]; then
        if [[ ${_curl_success} == "true" ]]; then echo "success"; return 0;
        else
            echo "error:"
            echo " input was: ${*}"
            echo -e " command executed was:\n    ${_command}"
            echo -e " and the output was:\n    ${_curl_return}"
            return 1
        fi
    else echo "${_curl_return}"         # return GET
    fi
}

# create an approver bot: for automatic approving of access requests
function bot(){
    _curl POST /api/users/create '{ "userid": "approver-bot", "name": "Approver Bot", "email": null }' || return 1
}


# this creates organization's json, to be called later in main_run function
function organization(){
    # create an organization which will hold all data

    # check if organization is already created
    _curl GET /api/organizations/${_organization_id}

    _data='{
                "organization/id": "'${_organization_id}'",
                "organization/short-name": {
                    "en": "'${_organization_short_name}'"
                },
                "organization/name": {
                    "en": "'${_organization_name}'"
                }
            }'
    _curl POST /api/organizations/create ${_data}
}

# this creates licence's json, to be called later in main_run function
function license(){
    # create a license for a resource

    _data='{
                "licensetype": "text",
                "organization": {
                    "organization/id": "'${_organization_id}'"
                },
                "localizations": {
                    "en": {
                        "title": "'${_licence_title}'",
                        "textcontent": "'${_licence_textcontent}'"
                    }
                }
            }'
    _curl POST /api/licenses/create ${_data}
    _license_id=${_curl_return_id}
}

# this creates form's json, to be called later in main_run function
function form(){
    #/api/forms/{form-id}
    # create a form for the dataset application process
    # extra fields explained @ https://rems-demo.rahtiapp.fi/swagger-ui/index.html#/forms/post_api_forms_create
    _data='{
                "form/title": "'${_form_title}'",
                "form/internal-name": "'${_form_internal_name}'",
                "form/external-title": {
                    "en": "'${_form_external_title}'"
                },
                "form/fields": [
                    {
                        "field/title": {
                            "en": "Affiliation"
                        },
                        "field/type": "texta",
                        "field/max-length": 600,
                        "field/optional": false,
                        "field/placeholder": { "en": "Enter employment information or affiliation with any other organization." }
                    },
                    {
                        "field/title": {
                            "en": "Position"
                        },
                        "field/type": "text",
                        "field/max-length": null,
                        "field/optional": false
                    },
                    {
                        "field/title": {
                            "en": "Co-applicants"
                        },
                        "field/type": "texta",
                        "field/max-length": 1000,
                        "field/optional": false,
                        "field/placeholder": { "en": "Include full postal and email address for each co-applicant." }
                    },
                    {
                        "field/title": {
                            "en": "Title of the study"
                        },
                        "field/type": "texta",
                        "field/max-length": 200,
                        "field/optional": false,
                        "field/placeholder": { "en": "Enter the title of the study (less than 30 words)" }
                    },
                    {
                        "field/title": {
                            "en": "Study description"
                        },
                        "field/type": "texta",
                        "field/max-length": 2000,
                        "field/optional": false,
                        "field/placeholder": { "en": "Please describe the study in no more than 750 words.\n1. Outline of the study design\n2. An indication of the methodologies to be used\n3. Proposed use of the project data\n4. Preceding peer-reviews of the study (if any present)\n5. Specific details of what you plan to do with the project data\n6. Timeline\n7. Key references" }
                    }
                ],
                "organization": {
                    "organization/id": "'${_organization_id}'"
                }
            }'
            _curl POST /api/forms/create ${_data}
            _form_id=${_curl_return_id}
}
# This creates the workflow's json, to be called later in main_run function
function workflow(){
    # create a workflow (DAC) to handle the application, here the auto-approve bot will handle it
    _data='{
                "organization": {
                    "organization/id": "'${_organization_id}'"
                },
                "title": "'${_workflow_title}'",
                "forms": [
                    {
                        "form/id": '${_form_id}'
                    }
                ],
                "type": "workflow/default",
                "handlers": [
                    "approver-bot"
                ],
                "licenses": [ { "license/id": '${_license_id}' } ]
            }'
    _curl POST /api/workflows/create ${_data}
    _workflow_id=${_curl_return_id}
}


# This creates the resource's json, to be called later in main_run function
function resource(){
    _data='{
                "resid": "'${_resource_id}'",
                "organization": {
                    "organization/id": "'${_organization_id}'"
                },
                "licenses": ['${_license_id}']
            }'
    _curl POST /api/resources/create ${_data}
    _resource_id=${_curl_return_id}
}

# This creates the catalogue's json, to be called later in main_run function
function catalogue(){
    # finally create a catalogue item, so that the dataset shows up on the main page
    _data='{
                "organization": {
                    "organization/id": "'${_organization_id}'"
                },
                "form": '${_form_id}',
                "resid": '${_resource_id}',
                "wfid": '${_workflow_id}',
                "localizations": {
                    "en": {
                        "title": "'${_catalogue_title}'"
                    }
                },
                "enabled": true,
                "archived": false
            }'
    _curl POST /api/catalogue-items/create ${_data}
    _catalogue_id=${_curl_return_id}
}

# Main functions, actually applying all the changes
function main_run(){
   bot                     # create approver bot


   ### Organization ###
   # if needed hardcoded values
   # _organization_id="umcg"
   organization            # create organization

   ##### License ######
   # if needed hardcoded values
   #_license_id="3"
   license

   ####### Form #######
   # if needed hardcoded values
   # _form_id="3"
   form                    # create form

   ##### Workflow #####
   # if needed hardcoded values
   # _workflow_id="5"
   workflow                # create workflow

   ### Resource and Catalogue are not actually called here,
   ### as they are controled by synchronization script
   #resource                # create resources
   #catalogue               # create catalogues
}

main_run
