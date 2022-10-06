*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images

Library             RPA.Browser.Selenium    auto_close={False}
Library             RPA.Excel.Files
Library             RPA.Tables
Library             RPA.HTTP
Library             RPA.FileSystem
Library             RPA.PDF
Library             RPA.Archive
Library             RPA.Windows
Library             RPA.Robocorp.Vault


*** Variables ***
${secret}=          Get Secret    credentials
${PDF}=             ${CURDIR}${/}/PDF/
${CSV}=             ${CURDIR}${/}
${SCREEN}=          ${CURDIR}${/}
${Arquivo_CSV}=     https://robotsparebinindustries.com/orders.csv
${URL_SITE}=        https://robotsparebinindustries.com/#/robot-order


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Abrir o site robots
    ${orders}=    Read table from CSV    ${CSV}orders.csv
    FOR    ${order}    IN    @{orders}
        Log    ${order}
        Fill The Form    ${order}
    END
    ZIP PDF Folder


*** Keywords ***
Abrir o site robots
    Open Available Browser    ${URL_SITE}
    Maximize Browser Window
    Click Button    OK
    Download    ${Arquivo_CSV}    overwrite=True
    Create Directory    ${PDF}

Ler Arquivo Csv
    ${table}=    Read table from CSV    ${CSV}${/}orders.csv
    RETURN    ${table}

Fill The Form
    [Arguments]    ${order}
    Select From List By Value    id:head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    class:form-control    ${order}[Legs]
    Input Text    id:address    ${order}[Address]
    Click Button    id:preview
    Wait Until Keyword Succeeds    6x    2 sec    Clicar no botao Order e Verifica Recibo
    Tira o Screenshot do robo
    PDF File    ${order}[Order number]
    Click Button    id:order-another

    ${Mensagem}=    Does Page Contain Button    OK
    IF    ${Mensagem}    Click Button    OK

Tira o Screenshot do robo
    Wait Until Element Is Visible    id:robot-preview-image
    Capture Element Screenshot    id:robot-preview-image    filename=${SCREEN}${/}ImagemBot.png

Clicar no botao Order e Verifica Recibo
    Click Button    id:order
    Click Element    id:receipt

PDF File
    [Arguments]    ${OrderNumber}
    ${recibo}=    Get Element Attribute    id:receipt    outerHTML
    ${nomeArquivo}=    Set Variable    ${PDF}${OrderNumber}.pdf
    Html To Pdf    ${recibo}    ${nomeArquivo}
    Open Pdf    ${nomeArquivo}
    Add Watermark Image To Pdf    ${SCREEN}${/}ImagemBot.png    ${nomeArquivo}
    Close Pdf

Click On Message
    Click Button    OK

ZIP PDF Folder
    ${ZIP_Diretorio}=    Set Variable    ${SCREEN}/PDF.zip
    Archive Folder With Zip    ${PDF}    ${ZIP_Diretorio}
    Remove File    ${SCREEN}${/}ImagemBot.png
    Remove Directory    ${PDF}    recursive=${True}
