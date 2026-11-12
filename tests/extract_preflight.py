"""Extract only the read-only storage preflight for isolated mocks; never run a playbook."""
from pathlib import Path
import yaml
root=Path(__file__).resolve().parents[1]
tasks=yaml.safe_load((root/'ansible/roles/iscsi_target/tasks/main.yml').read_text())
script=tasks[0]['ansible.windows.win_powershell']['script']
(root/'tests/storage-preflight.fixture.ps1').write_text(script)
