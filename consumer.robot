*** Settings ***
Library     Collections
Library     RPA.Browser.Selenium
Library     RPA.Robocorp.WorkItems
Library     RPA.Tables
Library     RPA.Robocorp.Vault
Library     RPA.Notifier

*** Variables ***
${channel}           alerts-dev-tommi


*** Tasks ***
Consume items
    [Documentation]    Login and then cycle through work items.
    TRY
        For Each Input Work Item    Handle item
    EXCEPT    AS    ${err}
        Log    ${err}    level=ERROR
        Release Input Work Item
        ...    state=FAILED
        ...    exception_type=APPLICATION
        ...    code=UNCAUGHT_ERROR
        ...    message=${err}
    END


*** Keywords ***
Action for item
    [Documentation]
    ...    Extract data from the images using Base64.ai API.
    [Arguments]    ${payload}

    # Send the model name and confidence to Slack
    ${slack_secret}=    Get Secret    Slack
    ${message}=    Catenate    Your attachment was    ${payload}[model][name]    with confidenced of    ${payload}[model][confidence]

    Notify Slack
    ...    message=${message}
    ...    channel=${channel}
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
