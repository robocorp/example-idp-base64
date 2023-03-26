*** Settings ***
Library     String
Library     OperatingSystem
Library     RPA.Robocorp.WorkItems
Library     RPA.Robocorp.Vault
Library     RPA.DocumentAI.Base64AI
Library     RPA.JSON

*** Variables ***
# Supported extensions
@{extensions}       jpg    jpeg    png    pdf    bmp    heic    webp    tif    tiff    doc    dox    xls    xlsx    ppt    pptx    ods    odt    odp

*** Tasks ***
Produce items
    [Documentation]
    ...    Get email workitem that triggered the process.
    ...    Read look for jpeg and png files.
    ...    Extract data with base64 and create output workitems for each.
    For Each Input Work Item    Unpack files

*** Keywords ***
Unpack files
    [Documentation]
    ...    Send supported files to Base64.ai for extraction.
    ...    Create output work items from responses.
    ${paths}=    Get Work Item Files    *

    FOR    ${path}    IN    @{paths}

        # Take only file extension
        ${fileext}=    Fetch From Right    ${path}    .

        IF     $fileext.lower() in $extensions
            Log To Console    Working on file: ${path}

            # Base64.ai authentication
            ${base64_secret}=    Get Secret    Base64
            Set Authorization  ${base64_secret}[email]   ${base64_secret}[api-key]

            ${results}=  Scan Document File  ${path}
            Log    ${results}[0][model]

            # Take the name of the file to use for resulting json
            ${filename}=    Fetch From Left    ${path}    .
            Save JSON to file    ${results}[0]    ${filename}.json

            # Creates an output workitem with used model as a payload, and result as a file
            Create Output Work Item    variables=${results}[0][model]    files=${filename}.json
            Save Work Item

        ELSE
            Log To Console    Ignoring file ${path}
        END
    END
    Release Input Work Item    DONE