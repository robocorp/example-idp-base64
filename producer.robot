*** Settings ***
Library     Collections
Library     RPA.Excel.Files
Library     RPA.Robocorp.WorkItems
Library     RPA.Tables
Library     convert         # convert.py
Library     String
Library     RPA.Robocorp.Vault
Library     RPA.HTTP


*** Variables ***
# USE THE MOCK ENDPOINT FOR DEV TIME TESTING
# AS IT DOES NOT CONSUME CREDITS
#${BASE64_API_URL}    https://base64.ai/mock/scan
${BASE64_API_URL}    https://base64.ai/api/scan


*** Tasks ***
Produce items
    [Documentation]
    ...    Get email workitem that triggered the process.
    ...    Read look for jpeg and png files.
    ...    Convert to base64 encoding and create output workitems for each.
    For Each Input Work Item    Unpack files


*** Keywords ***
Unpack files
    [Documentation]
    ...    Convert all jpgs and pngs from attachments to base64
    ...    and create output workitems.
    ${paths}=    Get Work Item Files    *

    FOR    ${path}    IN    @{paths}
        Log To Console    ${path}

        # Take only file extension
        ${fileext}=    Fetch From Right    ${path}    .

        # Currently supports only jpegs and pngs, ignoring the rest.
        IF    "${fileext}" == "jpg" or "${fileext}" == "jpeg"
            ${type}=    Set Variable    image/jpeg
        ELSE IF    "${fileext}" == "png"
            ${type}=    Set Variable    image/png
        ELSE
            Log    Not supported file type, skipping.
            Continue For Loop
        END

        # Convert picture to base64 encoding
        ${base64string}=    Image To Base64    ${path}

        # Create Base64.ai authentication headers
        ${base64_secret}=    Get Secret    Base64
        ${headers}=    Create Dictionary
        ...    Authorization=${base64_secret}[auth-header]

        # Create Base64.ai json payload
        ${string}=    Catenate    SEPARATOR=    data:    ${type}    ;base64,    ${base64string}
        ${body}=    Create Dictionary
        ...    image= ${string}

        # Post to Base64.ai API
        ${response}=    POST
        ...    url=${BASE64_API_URL}
        ...    headers=${headers}
        ...    json=${body}

        Log    ${response.json()}[0][model]

        Create Output Work Item
        ...    variables=${response.json()}[0]
        ...    save=True

    END
    Release Input Work Item    DONE
