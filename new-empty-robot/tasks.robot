*** Settings ***
Library     RPA.Browser.Selenium
Library     RPA.HTTP
Library     RPA.Windows
Library     RPA.Tables


*** Tasks ***
DesafioRobo
    Simulate Event
    Send Keys
    Is Radio Button Selected
    Is Radio Button Set To
    Select Radio Button
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order    headless=${TRUE}
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=${TRUE}
    ${table}=    Read table from CSV    orders.csv    ${TRUE}    delimiters=,
    FOR    ${row}    IN    table
        Click Element When Visible    alias:Button
        Select From List By Index    alias:Head    1
    END
