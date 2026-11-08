# Script remediation — 8 November 2026

Nothing deployed. This patch deliberately removes unsafe storage automation rather than guessing production disk identities.

- iscsi_target: no RAW initialization, fixed disk-number partitioning or formatting. Requires exactly two reviewed UniqueId/SizeBytes/DriveLetter mappings in iscsi_target_volume_manifest and already provisioned healthy NTFS volumes. Read-only preflight runs before feature changes. Mapping changed-state equality fixed.
- iscsi_initiator: exact iscsi_target_iqn and portal; no wildcard target/size-selected LUN initialization or formatting. iscsi_lun_manifest must contain two reviewed UniqueId/SizeBytes mappings; existing LUN state is checked on the designated initial node. Identity must be established from authoritative storage inventory, not invented defaults.
- windows_failover_cluster: removes Get-ClusterAvailableDisk | Add-ClusterDisk. wsfc_expected_disk_resources must identify separately reviewed imported Physical Disk resources. Provision/import storage in a separate approved change; fresh automated builds stop until prerequisites are met.
- SQL: protected staging ACL preflight, unique password-bearing INI, no_log/diff suppression and always cleanup on failed setup. First-node setup and AddNode run in separate serial phases. Existing-instance schema and installed version verification are still prerequisites, not inferred from service presence.

Mandatory lab gates: exact OS/collection/setup-media versions; LUN identity and drive-letter mapping; multi-node fencing/cluster validation; SQL resource names/network/IP/template values; INI secret escaping; reboot/failure/retry/restore. Set sql_fci_lab_validated only after these gates, supply sql_secret_staging_directory pre-provisioned with protected ACL restricted to SYSTEM/Administrators/execution identity, and valid vault secrets. Default instance only. ACL provisioning, storage formatting, CNO/witness permissions and backup recovery are separate authorized infrastructure work. Controller interruption can defeat always cleanup; securely inspect staging after interruption. No claim of fully working FCI deployment.

Validation: local YAML parsing and source contract checks only until CI/lab evidence is recorded. No WinRM, SQL, cluster or storage target contacted.

Local validation: YAML parsing; VMware PowerCLI connection-scope/failure/WWPN/JSON fixtures passed in PowerShell 7.4.13 for the migration repository. Windows versions and Ansible contracts are checked by the PR CI; infrastructure integration remains unverified.
