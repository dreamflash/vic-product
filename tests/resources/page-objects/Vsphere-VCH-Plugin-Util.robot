# Copyright 2018 VMware, Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

*** Settings ***
Documentation  This resource contains any keywords dealing with web based operations being performed within vSphere on the VCH plugin
Resource  ../../resources/Util.robot

*** Variables ***
# css locators
${vic-home-iframe}  css=iframe[ng-src*='view=vch-view']
${vic-delete-iframe}  css=iframe[ng-src*='view=delete-vch']
${vch-name-input}  css=#nameInput
${next-button}  css=.clr-wizard-btn--primary
${datastore-dropdown}  css=select#image-store-selector
${bridge-network-dropdown}  css=select#bridge-network-selector
${public-network-dropdown}  css=select#public-network-selector
${toggle-secure}  css=div.toggle-switch--no-label
${ops-user-input}  css=input#ops-user
${ops-pwd-input}  css=input#ops-password
${finish-button}  css=.btn-success
${refresh-table-link}  css=.datagrid-cell .pointer-with-no-href
${vch-list-table}  css=clr-dg-table-wrapper.datagrid-table-wrapper

*** Keywords ***
Navigate To Summary Tab
    Log To Console  Navigating to Summary tab...
    Wait Until Element Is Visible And Enabled  css=ul.nav.nav-tabs > li:nth-child(1)
    Click Element  css=ul.nav.nav-tabs > li:nth-child(1)

    Wait Until Element Is Visible And Enabled  css=iframe[ng-src*='view=summary-view']
    Select Frame  css=iframe[ng-src*='view=summary-view']
    Wait Until Page Contains Element  css=vic-app
    Wait Until Page Contains Element  css=vic-summary-view
    Unselect Frame

Navigate To VCH Tab
    Log To Console  Navigating to VCH tab...
    Wait Until Element Is Visible And Enabled  xpath://*[contains(text(),'Virtual Container Hosts')]
    Click Element  xpath://*[contains(text(),'Virtual Container Hosts')]

    Wait Until Element Is Visible And Enabled  ${vic-home-iframe}
    Select Frame  ${vic-home-iframe}
    Wait Until Page Contains Element  css=vic-app
    Wait Until Page Contains Element  css=vic-vch-view
    Unselect Frame

Navigate To Containers Tab
    Log To Console  Navigating to Containers tab...
    Wait Until Element Is Visible And Enabled  css=ul.nav.nav-tabs > li:nth-child(3)
    Click Element  css=ul.nav.nav-tabs > li:nth-child(3)

    Wait Until Element Is Visible And Enabled  css=iframe[ng-src*='view=container-view']
    Select Frame  css=iframe[ng-src*='view=container-view']
    Wait Until Page Contains Element  css=vic-app
    Wait Until Page Contains Element  css=vic-container-view
    Unselect Frame

Click New Virtual Container Host Button
    Log To Console  Clicking new virtual host button...
    Wait Until Element Is Visible And Enabled  ${vic-home-iframe}
    Select Frame  ${vic-home-iframe}
    Wait Until Element Is Visible And Enabled  css=clr-icon[shape='add']
    Click Element  css=clr-icon[shape='add']
    Unselect Frame
    
    Wait Until Element Is Visible And Enabled  css=iframe[ng-src*='view=create-vch']
    Select Frame  css=iframe[ng-src*='view=create-vch']

    Wait Until Page Contains  VCH name

Input VCH Name
    [Arguments]  ${vch-name-text}
    Log To Console  Input VCH name...
    Wait Until Element Is Visible And Enabled  ${vch-name-input}
    Input Text  ${vch-name-input}  ${vch-name-text}

Click Next Button
    Log To Console  Clicking Next button...
    Wait Until Element Is Visible And Enabled  ${next-button}
    Click Button  ${next-button}

Select Image Datastore
    [Arguments]  ${ds-text}
    Log To Console  Selecting datastore...
    Wait Until Element Is Visible And Enabled  ${datastore-dropdown}
    Print Values And Select One From List  ${datastore-dropdown}  ${ds-text}

Select Bridge Network
    [Arguments]  ${network-text}
    Log To Console  Selecting bridge network...
    Wait Until Element Is Visible And Enabled  ${bridge-network-dropdown}
    Print Values And Select One From List  ${bridge-network-dropdown}  ${network-text}

Select Public Network
    [Arguments]  ${network-text}
    Log To Console  Selecting public network...
    Wait Until Element Is Visible And Enabled  ${public-network-dropdown}
    Print Values And Select One From List  ${public-network-dropdown}  ${network-text}

Toggle Client Certificate Option
    Log To Console  Toggle security...
    Wait Until Element Is Visible And Enabled  ${toggle-secure}
    Click Element  ${toggle-secure}

Input Ops User Name
    [Arguments]  ${ops-username-text}
    Log To Console  Input Ops username...
    Wait Until Element Is Visible And Enabled  ${ops-user-input}
    Input Text  ${ops-user-input}  ${ops-username-text}

Input Ops User Password
    [Arguments]  ${ops-pwd-text}
    Log To Console  Input Ops user password...
    Wait Until Element Is Visible And Enabled  ${ops-pwd-input}
    Input Text  ${ops-pwd-input}  ${ops-pwd-text}

Click Finish Button
    Log To Console  Clicking Next button...
    Wait Until Element Is Visible And Enabled  ${finish-button}
    Click Button  ${finish-button}

Set Docker Host Parameters
    Log To Console  Set docker host paramenters...
    Wait Until Element Is Visible And Enabled  ${vic-home-iframe}
    Select Frame  ${vic-home-iframe}
    Ensure Fetch VCH IP

    # latest one is in the last row
    ${last-row}=  Get Text  css=clr-dg-table-wrapper.datagrid-table-wrapper clr-dg-row:last-of-type
    @{parts}=  Split String  ${last-row}
    Unselect Frame

    ${rest}  ${docker-host}=  Split String  @{parts}[1]  =
    @{hostParts}=  Split String  ${docker-host}  :
    ${ip}=  Strip String  @{hostParts}[0]
    ${port}=  Strip String  @{hostParts}[1]

    Set Test Variable  ${VCH-IP}  ${ip}
    Set Test Variable  ${VCH-PORT}  ${port}
    Set Test Variable  ${VIC-ADMIN}  https://${ip}:2378
    Run Keyword If  ${port} == 2376  Set Test Variable  ${VCH-PARAMS}  -H ${docker-host} --tls
    Run Keyword If  ${port} == 2375  Set Test Variable  ${VCH-PARAMS}  -H ${docker-host}

Ensure Fetch VCH IP
    :FOR  ${i}  IN RANGE  30
    \   Sleep  20
    \   Run Keyword And Ignore Error  Click Link  ${refresh-table-link}
    \   ${passed}=  Run Keyword And Return Status  Element Should Be Visible  ${refresh-table-link}
    \   Return From Keyword If  ${passed} == ${false}
    Fail  fetch vch ip failure.

Create VCH using UI And Set Docker Parameters
    # navigate to the wizard and create a VCH
    # set docker parameters for created VCH
    [Arguments]  ${test-name}  ${datastore}  ${bridge-network}  ${public-network}  ${ops-user}  ${ops-pwd}  ${tree-node}=1
    Open Firefox Browser
    Navigate To VC UI Home Page
    Login On Single Sign-On Page
    Verify VC Home Page
    Navigate To VCH Creation Wizard
    Navigate To VCH Tab
    Click New Virtual Container Host Button

    #general
    ${name}=  Evaluate  'VCH-${test-name}-' + str(random.randint(1000,9999)) + str(time.clock())  modules=random,time
    Input VCH Name  ${name}
    Click Next Button
    # compute capacity
    Log To Console  Selecting compute resource...
    # if cluster is present
    # There're 2 types of tree-node, if it's a index number, locator will be defined by CSS, if it's a IP address, locator will be defined by xpath 
    ${tree-node-len}=  Get Length  '${tree-node}'
    ${host_locator}=  set variable if  ${tree-node-len}<5  css=.clr-treenode-children clr-tree-node:nth-of-type(${tree-node}) .cc-resource  xpath://clr-tree-node//button[contains(., '${tree-node}')]
    Wait Until Element Is Enabled  ${host_locator}
    Click Button  ${host_locator}

    Click Next Button
    # storage capacity
    Select Image Datastore  ${datastore}
    Click Next Button
    #networks
    Select Bridge Network  ${bridge-network}
    Select Public Network  ${public-network}
    Click Next Button
    # security
    Toggle Client Certificate Option
    Click Next Button
    #registry access
    Click Next Button
    # ops-user
    Input Ops User Name  ${ops-user}
    Input Ops User Password  ${ops-pwd}
    Click Next Button
    # summary
    Click Finish Button
    Unselect Frame
    Wait Until Page Does Not Contain  VCH name
    Set Test Variable   ${VCH-NAME}  ${name}
    # retrieve docker parameters from UI
    Set Docker Host Parameters

Test Create VCH Using UI
    [Arguments]  ${test-name}  ${datastore}  ${bridge-network}  ${public-network}  ${ops-user}  ${ops-pwd}  ${tree-node}=1
    Click New Virtual Container Host Button

    #general
    ${name}=  Evaluate  'VCH-${test-name}-' + str(random.randint(1000,9999)) + str(time.clock())  modules=random,time
    Input VCH Name  ${name}
    Click Next Button
    # compute capacity
    Log To Console  Selecting compute resource...
    # if cluster is present
    # There're 2 types of tree-node, if it's a index number, locator will be defined by CSS, if it's a IP address, locator will be defined by xpath 
    ${tree-node-len}=  Get Length  '${tree-node}'
    ${host_locator}=  set variable if  ${tree-node-len}<5  css=.clr-treenode-children clr-tree-node:nth-of-type(${tree-node}) .cc-resource  xpath://clr-tree-node//button[contains(., '${tree-node}')]
    Wait Until Element Is Enabled  ${host_locator}
    Click Button  ${host_locator}

    Click Next Button
    # storage capacity
    Select Image Datastore  ${datastore}
    Click Next Button
    #networks
    Select Bridge Network  ${bridge-network}
    Select Public Network  ${public-network}
    Click Next Button
    # security
    Toggle Client Certificate Option
    Click Next Button
    #registry access
    Click Next Button
    # ops-user
    Input Ops User Name  ${ops-user}
    Input Ops User Password  ${ops-pwd}
    Click Next Button
    # summary
    Click Finish Button
    Unselect Frame
    Wait Until Page Does Not Contain  VCH name
    Set Test Variable   ${VCH-NAME}  ${name}
    # retrieve docker parameters from UI
    Set Docker Host Parameters
    [Return]  ${name}

Check VCH Fail Alert
    Wait Until Element Is Visible And Enabled  ${vic-home-iframe}
    Select Frame  ${vic-home-iframe}
    ${visible}=  Run Keyword And Return Status  Wait Until Page Contains Element  css=span.alert-text
    ${alert_text}=  Run Keyword If  ${visible}  Get Text  css=span.alert-text
    Run Keyword If  ${visible}  Log  ${alert_text}
    Unselect Frame
    [Return]  ${visible}

Get Create VCH Count
    Wait Until Element Is Visible And Enabled  ${vic-home-iframe}
    Select Frame  ${vic-home-iframe}
    ${visible}=  Run Keyword And Return Status  Wait Until Page Contains Element  css=div.datagrid-foot-description
    ${foot_text}=  Run Keyword If  ${visible}  Get Text  css=div.datagrid-foot-description
    ...            ELSE  Set Variable  ${EMPTY}
    Log  ${foot_text}
    ${rc}  ${vch_count}=  Run And Return Rc And Output  echo '${foot_text}' | cut -d ' ' -f 5
    Log  ${vch_count}
    ${status}=  Run Keyword And Return Status  Should Contain  ${vch_count}  VCH
    Run Keyword If  ${status}  Capture Page Screenshot  get-vchfail-screenshot-{index}.png
    Should Be Equal As Integers  ${rc}  0
    Unselect Frame
    Return From Keyword If  '${foot_text}' != '${EMPTY}'  ${vch_count}
    [Return]  ${False}

Ensure Get VCH Count
    :FOR  ${IDX}  IN RANGE  3
    \   ${vch_count}=  Get Create VCH Count
    \   ${status}=  Run Keyword And Return Status  Should Contain  ${vch_count}  VCH
    \   Run Keyword If  ${status}  Reload Page
    \   Run Keyword If  ${status}  Sleep  3
    \   Return From Keyword If  ${status} == ${False}  ${vch_count}
    Fail  fetch vch count failure.

Delete VCH Using UI
    ${cur_vch_count}=  Ensure Get VCH Count
    Should Be True  ${cur_vch_count}
    Wait Until Element Is Visible And Enabled  ${vic-home-iframe}
    Select Frame  ${vic-home-iframe}
    ${visible}=  Run Keyword And Return Status  Wait Until Page Contains Element  css=button.datagrid-action-toggle > clr-icon
    Should Be True  ${visible}
    @{ele}=  Run Keyword If  ${visible}  Get WebElements  css=button.datagrid-action-toggle > clr-icon
    ...      ELSE                        Set Variable  ${EMPTY}
    Log  '${ele}'
    ${ele_count}=  Get Length  ${ele}
    Run Keyword If  ${ele_count} != 0  Click Element  @{ele}[-1]

    Wait Until Element Is Visible And Enabled  css=button.action-item.action-item-delete
    Click Element  css=button.action-item.action-item-delete
    Unselect Frame
  
    Wait Until Element Is Visible And Enabled  ${vic-delete-iframe}
    Select Frame  ${vic-delete-iframe}
    Wait Until Element Is Visible And Enabled  css=input#delete-volumes
    Click Element  css=div.checkbox > label
    Wait Until Element Is Visible And Enabled  css=button.btn.btn-danger
    Click Button  css=button.btn.btn-danger
    Unselect Frame
    Ensure Delete Succeed
    ${del_after_vch_count}=  Get Create VCH Count
    ${del_count}=  Evaluate  int(${cur_vch_count})-int(${del_after_vch_count})
    Should Be Equal As Integers  ${del_count}  1  
    
Ensure Delete Succeed
    :FOR  ${idx}  IN RANGE  60
    \   Sleep  2
    \   ${status}=  Run Keyword And Return Status  Wait Until Element Is Visible And Enabled  ${vic-delete-iframe}
    \   Return From Keyword If  ${status} == ${false}  
    Fail  this element is still showing.

Delete All VCH Using UI
    Set Browser Variables
    Open Firefox Browser
    Navigate To VC UI Home Page
    Login On Single Sign-On Page
    Verify VC Home Page
    Navigate To VCH Creation Wizard
    Navigate To VCH Tab
    :FOR  ${idx}  IN RANGE  99
    \   Delete VCH Using UI
    \   ${vch_count}=  Ensure Get VCH Count
    \   Exit For Loop If  ${vch_count} == 0
    Close Browser

