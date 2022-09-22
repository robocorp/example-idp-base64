*** Settings ***
Library     RPA.Excel.Files
Library     RPA.Robocorp.WorkItems
Library     RPA.Tables
Library     RPA.Robocorp.Vault
Library     RPA.HTTP
Library     RPA.Base64AI
Library     Collections
Library     String

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
    ...    Convert all jpgs and pngs from attachments to base64,
    ...    send extraction request to Base64 API,
    ...    and create output workitems out of response JSONs.
    ${paths}=    Get Work Item Files    *

    FOR    ${path}    IN    @{paths}
        Log To Console    ${path}

        # Base64.ai authentication
        ${base64_secret}=    Get Secret    Base64
        Set Authorization  ${base64_secret}[email]   ${base64_secret}[api-key]

        ${results}=  Scan Document File  ${path}
        Log    ${results}[0][model]

        # Create output workitem from full API responses.
        Create Output Work Item
        ...    variables=${results}[0]
        ...    save=True

    END
    Release Input Work Item    DONE