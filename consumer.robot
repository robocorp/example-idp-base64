*** Settings ***
Library     Collections
Library     RPA.Browser.Selenium
Library     RPA.Robocorp.WorkItems
Library     RPA.Tables
Library     RPA.Robocorp.Vault
Library     RPA.Notifier

*** Variables ***
${THRESHOLD}    0.8

*** Tasks ***
Consume items
    [Documentation]    Cycle through work items.
    For Each Input Work Item    Handle item

*** Keywords ***
Action for item
    [Documentation]
    ...    Get document extraction payloads and do something with them.
    ...    This example just posts document model name and confidence to Slack.
    [Arguments]    ${payload}

    #
    # THE FOLLOWING BLOCK SIMULATES DOCUMENT TRIAGE BASED ON THE CONFIDENCE RESULT,
    # AND IT'S TYPE. THIS PART WOULD BE REPLACED WITH REAL BUSINESS LOGIC.
    #

    IF    ${payload}[model][confidence] < ${THRESHOLD}
        Fail    Manual review
    ELSE IF    "${payload}[model][type]" == "semantic/ajok"                # Finnish driver licence
        ${message}=    Catenate    Processing Finnish drivers licence, owner    ${payload}[fields][2][value]    with licence nr    ${payload}[fields][4d][value]

    ELSE IF   "${payload}[model][type]" == "driver_license/usa/ny"    # US/NY driver licence
        ${message}=    Catenate    Processing US/NY drivers licence, owner    ${payload}[fields][givenName][value]    ${payload}[fields][familyName][value]    with licence nr    ${payload}[fields][licenseNumber][value]

    ELSE IF   "${payload}[model][type]" == "driver_license/usa/ca"    # US/CA driver licence
        ${message}=    Catenate    Processing US/CA drivers licence, owner    ${payload}[fields][givenName][value]    ${payload}[fields][familyName][value]    with licence nr    ${payload}[fields][licenseNumber][value]

    ELSE IF   "${payload}[model][type]" == "finance/invoice"          # purchase invoice
        ${message}=    Catenate    Processing purchase invoice from    ${payload}[fields][companyName][value]    total value    ${payload}[fields][total][value]    and due date in    ${payload}[fields][dueDate][value]

    ELSE IF   "${payload}[model][type]" == "insurance/acord/25"       # ACORD 25 liability cert
        ${message}=    Catenate    Processing ACORD 25 liability cert nr    ${payload}[fields][certificateNumber][value]    produced by     ${payload}[fields][producer][value]    for the insured     ${payload}[fields][insured][value]    says:    ${payload}[fields][description][value]

    ELSE
        ${message}=    Catenate    There was a document type without handler implemented:     ${payload}[model][name]
    END

    # Send the model name and confidence to Slack
    ${slack_secret}=    Get Secret    Slack

    Notify Slack
    ...    message=${message}
    ...    channel=${slack_secret}[channel]
    ...    webhook_url=${slack_secret}[webhook]

Handle item
    [Documentation]    Error handling around one work item.
    ${payload}=    Get Work Item Variables
    TRY
        Action for item    ${payload}
        Release Input Work Item    DONE
    EXCEPT    Invalid data    type=START    AS    ${err}
        # Giving a good error message here means that data related errors can
        # be fixed faster in Control Room.
        # You can extract the text from the underlying error message.
        ${error_message}=    Set Variable
        ...    Data may be invalid, encountered error: ${err}
        Log    ${error_message}    level=ERROR
        Release Input Work Item
        ...    state=FAILED
        ...    exception_type=BUSINESS
        ...    code=INVALID_DATA
        ...    message=${error_message}
    EXCEPT    Manual review    type=START    AS    ${err}
        ${error_message}=    Set Variable
        ...    Work Item needs manual review and processing ${err}
        Log    ${error_message}    level=INFO
        Release Input Work Item
        ...    state=FAILED
        ...    exception_type=BUSINESS
        ...    code=MANUAL
        ...    message=${error_message}
    EXCEPT    *timed out*    type=GLOB    AS    ${err}
        ${error_message}=    Set Variable
        ...    Application error encountered: ${err}
        Log    ${error_message}    level=ERROR
        Release Input Work Item
        ...    state=FAILED
        ...    exception_type=APPLICATION
        ...    code=TIMEOUT
        ...    message=${error_message}
    END