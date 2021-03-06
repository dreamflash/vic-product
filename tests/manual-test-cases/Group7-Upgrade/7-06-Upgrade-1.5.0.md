Test 7-06 - Upgrade 1.5.0
=======

# Purpose:
To verify the VIC OVA appliance v1.5.0 upgrades to latest with auto upgrade process works as expected

# References:

# Environment:
This test requires access to VMWare Nimbus cluster for dynamic ESXi and vCenter creation

# Test Steps:
1. Deploy a new vCenter in Nimbus that is a simple VC cluster
2. Install an older version of the VIC OVA appliance
3. Walk through completing the install and use the VCH creation wizard to create a VCH
4. Run a variety of docker commands on the VCH appliance
5. Install the latest version of the VIC OVA appliance
6. Execute the upgrade script pointing at the old version of the VIC OVA appliance
7. Walk through completing the install
8. Run a variety of docker commands on the previously created VCH

# Expected Outcome:
The VCH and VIC appliance upgrade should succeed without error and each of the docker commands executed against it should return without error

# Possible Problems:
