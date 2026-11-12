# Script remediation — 8 November 2026

Nothing deployed. This patch deliberately removes unsafe storage automation rather than guessing production disk identities.

- iscsi_target: no RAW initialization, fixed disk-number partitioning or formatting. Requires exactly two reviewed UniqueId/SizeBytes/DriveLetter mappings in iscsi_target_volume_manifest and already provisioned healthy NTFS volumes. Read-only preflight runs before feature changes. Mapping changed-state equality fixed.
- iscsi_initiator: exact iscsi_target_iqn and portal; no wildcard target/size-selected LUN initialization or formatting. iscsi_lun_manifest must contain two reviewed UniqueId/SizeBytes mappings; existing LUN state is checked on the designated initial node. Identity must be established from authoritative storage inventory, not invented defaults.
- windows_failover_cluster: removes Get-ClusterAvailableDisk | Add-ClusterDisk. wsfc_expected_disk_resources must identify separately reviewed imported Physical Disk resources. Provision/import storage in a separate approved change; fresh automated builds stop until prerequisites are met.
- SQL: protected staging ACL preflight, unique password-bearing INI, no_log/diff suppression and always cleanup on failed setup. First-node setup and AddNode run in separate serial phases. Existing-instance schema and installed version verification are still prerequisites, not inferred from service presence.

Mandatory lab gates: exact OS/collection/setup-media versions; LUN identity and drive-letter mapping; multi-node fencing/cluster validation; SQL resource names/network/IP/template values; INI secret escaping; reboot/failure/retry/restore. Set sql_fci_lab_validated only after these gates, supply sql_secret_staging_directory pre-provisioned with protected ACL restricted to SYSTEM/Administrators/execution identity, and valid vault secrets. Default instance only. ACL provisioning, storage formatting, CNO/witness permissions and backup recovery are separate authorized infrastructure work. Controller interruption can defeat always cleanup; securely inspect staging after interruption. No claim of fully working FCI deployment.

Validation: local YAML parsing and source contract checks only until CI/lab evidence is recorded. No WinRM, SQL, cluster or storage target contacted.

Local validation: YAML parsing; VMware PowerCLI connection-scope/failure/WWPN/JSON fixtures passed in PowerShell 7.4.13 for the migration repository. Windows versions and Ansible contracts are checked by the PR CI; infrastructure integration remains unverified.

## Variable migration (breaking)

Role variables and registered results now use role prefixes; update external inventory/Vault overrides before applying. All in-repository references were migrated. The shared iscsi_target_name intentionally retains one value across both roles.

| Previous variable | Replacement |
|---|---|
| `ad_base_ous` | `ad_domain_controller_ad_base_ous` |
| `ad_domain_dn` | `ad_domain_controller_ad_domain_dn` |
| `ad_domain_name` | `ad_domain_controller_ad_domain_name` |
| `ad_domain_netbios_name` | `ad_domain_controller_ad_domain_netbios_name` |
| `ad_safe_mode_password` | `ad_domain_controller_ad_safe_mode_password` |
| `cluster_check` | `windows_failover_cluster_cluster_check` |
| `data_vdisk_result` | `iscsi_target_data_vdisk_result` |
| `forest_result` | `ad_domain_controller_forest_result` |
| `gpo_script_result` | `gpo_patching_gpo_script_result` |
| `iscsi_allowed_initiator_ips` | `iscsi_target_iscsi_allowed_initiator_ips` |
| `iscsi_data_disk_size_gb` | `iscsi_target_iscsi_data_disk_size_gb` |
| `iscsi_data_drive_letter` | `iscsi_target_iscsi_data_drive_letter` |
| `iscsi_initialize_disks` | `iscsi_initiator_iscsi_initialize_disks` |
| `iscsi_quorum_disk_size_gb` | `iscsi_target_iscsi_quorum_disk_size_gb` |
| `iscsi_quorum_drive_letter` | `iscsi_target_iscsi_quorum_drive_letter` |
| `iscsi_target_portal_ip` | `iscsi_initiator_iscsi_target_portal_ip` |
| `join_result` | `domain_join_join_result` |
| `mapping_result` | `iscsi_target_mapping_result` |
| `portal_result` | `iscsi_initiator_portal_result` |
| `quorum_vdisk_result` | `iscsi_target_quorum_vdisk_result` |
| `setup_exe_check` | `sql_server_fci_setup_exe_check` |
| `sql_agent_service_account` | `sql_server_fci_sql_agent_service_account` |
| `sql_agent_service_account_password` | `sql_server_fci_sql_agent_service_account_password` |
| `sql_config_file` | `sql_server_fci_sql_config_file` |
| `sql_server_data_drive` | `sql_server_fci_sql_server_data_drive` |
| `sql_server_instance_name` | `sql_server_fci_sql_server_instance_name` |
| `sql_server_media_path` | `sql_server_fci_sql_server_media_path` |
| `sql_service_account` | `sql_server_fci_sql_service_account` |
| `sql_service_account_password` | `sql_server_fci_sql_service_account_password` |
| `sql_service_check` | `sql_server_fci_sql_service_check` |
| `sql_setup_result` | `sql_server_fci_sql_setup_result` |
| `sql_sysadmin_accounts` | `sql_server_fci_sql_sysadmin_accounts` |
| `storage_preflight` | `iscsi_target_storage_preflight` |
| `wsfc_cluster_ip` | `windows_failover_cluster_wsfc_cluster_ip` |
| `wsfc_cluster_name` | `windows_failover_cluster_wsfc_cluster_name` |
| `wsfc_feature` | `windows_failover_cluster_wsfc_feature` |
| `wsfc_is_cluster_creation_node` | `windows_failover_cluster_wsfc_is_cluster_creation_node` |
| `wsfc_nodes` | `windows_failover_cluster_wsfc_nodes` |
| `wsfc_witness_share_path` | `windows_failover_cluster_wsfc_witness_share_path` |
| `wsus_classifications` | `wsus_server_wsus_classifications` |
| `wsus_config_result` | `wsus_server_wsus_config_result` |
| `wsus_content_dir` | `wsus_server_wsus_content_dir` |
| `wsus_feature` | `wsus_server_wsus_feature` |
| `wsus_port` | `wsus_server_wsus_port` |
| `wsus_postinstall_check` | `wsus_server_wsus_postinstall_check` |
| `wsus_postinstall_result` | `wsus_server_wsus_postinstall_result` |
| `wsus_products` | `wsus_server_wsus_products` |
| `wsus_sync_hour` | `wsus_server_wsus_sync_hour` |

Validation update: local yamllint, Ansible syntax check and ansible-lint basic profile pass after migrating role-variable names. CI no longer suppresses lint failures. Lab storage preflight fixtures reject unrelated RAW/system/boot disks and invalid manifests; Windows PowerShell array handling was corrected from CI evidence. No infrastructure play was executed.
