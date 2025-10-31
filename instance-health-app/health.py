#!/usr/bin/env python3
import boto3, time
from datetime import datetime

REGION = "af-south-1"
INSTANCE_ID = "i-086c0ceb86255211b"

ssm = boto3.client("ssm", region_name=REGION)


def send_cmd(cmds):
    resp = ssm.send_command(
        InstanceIds=[INSTANCE_ID],
        DocumentName="AWS-RunShellScript",
        Parameters={"commands": cmds},
    )
    cmd_id = resp["Command"]["CommandId"]
    time.sleep(3)
    out = ssm.get_command_invocation(CommandId=cmd_id, InstanceId=INSTANCE_ID)
    return out


def main():
    print("[*] Checking nginx health...")
    result = send_cmd(["curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1"])
    code = result.get("StandardOutputContent", "").strip()
    print(f"nginx HTTP status: {code}")
    if code != "200":
        msg = f"<html><body><h1>nginx unhealthy at {datetime.utcnow().isoformat()}Z</h1></body></html>"
        send_cmd([f'echo "{msg}" > /usr/share/nginx/html/index.html'])
        print("[ACTION] Homepage updated with unhealthy message")
    else:
        print("[OK] nginx healthy")


if __name__ == "__main__":
    main()
