#!/usr/bin/env python3

import argparse
import shutil
import subprocess
import sys
from pathlib import Path


DEFAULT_MANIFEST_URL = (
    "https://raw.githubusercontent.com/GoogleCloudPlatform/"
    "microservices-demo/main/release/kubernetes-manifests.yaml"
)


def run(cmd, cwd=None, check=True, capture_output=False):
    print(f"\n$ {' '.join(cmd)}")
    result = subprocess.run(
        cmd,
        cwd=cwd,
        check=False,
        text=True,
        capture_output=capture_output,
    )
    if result.stdout:
        print(result.stdout.strip())
    if result.stderr:
        print(result.stderr.strip(), file=sys.stderr)
    if check and result.returncode != 0:
        raise RuntimeError(f"Command failed with exit code {result.returncode}: {' '.join(cmd)}")
    return result


def ensure_binaries():
    required = ["gcloud", "terraform", "kubectl"]
    missing = [binary for binary in required if shutil.which(binary) is None]
    if missing:
        raise RuntimeError(
            "Missing required binaries: "
            + ", ".join(missing)
            + ". Install Google Cloud SDK, Terraform, and kubectl first."
        )


def gcloud_auth(project_id):
    run(["gcloud", "auth", "login"])
    run(["gcloud", "auth", "application-default", "login"])
    run(["gcloud", "config", "set", "project", project_id])


def terraform_apply(tf_dir, tfvars_file, auto_approve):
    run(["terraform", "init"], cwd=tf_dir)
    run(["terraform", "plan", f"-var-file={tfvars_file}"], cwd=tf_dir)

    apply_cmd = ["terraform", "apply", f"-var-file={tfvars_file}"]
    if auto_approve:
        apply_cmd.append("-auto-approve")
    run(apply_cmd, cwd=tf_dir)


def configure_kubectl(project_id, region, cluster_name):
    run(
        [
            "gcloud",
            "container",
            "clusters",
            "get-credentials",
            cluster_name,
            "--region",
            region,
            "--project",
            project_id,
        ]
    )


def ensure_namespace(namespace):
    ns_exists = run(["kubectl", "get", "namespace", namespace], check=False)
    if ns_exists.returncode != 0:
        run(["kubectl", "create", "namespace", namespace])


def deploy_online_boutique(namespace, manifest_url):
    run(["kubectl", "apply", "-n", namespace, "-f", manifest_url])


def verify(namespace, project_id, region):
    run(["kubectl", "get", "pods", "-n", namespace], check=False)
    run(
        [
            "gcloud",
            "run",
            "services",
            "describe",
            "boutique-frontend",
            "--region",
            region,
            "--project",
            project_id,
            "--format=value(status.url)",
        ],
        check=False,
    )


def parse_args():
    parser = argparse.ArgumentParser(
        description="Deploy GCP infrastructure and Online Boutique using gcloud SDK + Terraform + kubectl"
    )
    parser.add_argument("--project-id", required=True, help="GCP project ID")
    parser.add_argument("--region", default="us-central1", help="GCP region (default: us-central1)")
    parser.add_argument("--cluster-name", default="boutique-gke", help="GKE cluster name")
    parser.add_argument("--namespace", default="boutique", help="Kubernetes namespace")
    parser.add_argument(
        "--manifest-url",
        default=DEFAULT_MANIFEST_URL,
        help="Online Boutique manifest URL",
    )
    parser.add_argument(
        "--tf-dir",
        default=str(Path(__file__).resolve().parent),
        help="Terraform root directory",
    )
    parser.add_argument(
        "--tfvars-file",
        default="terraform.tfvars",
        help="Terraform var-file path (absolute or relative to --tf-dir)",
    )
    parser.add_argument("--skip-auth", action="store_true", help="Skip gcloud auth login steps")
    parser.add_argument("--skip-terraform", action="store_true", help="Skip terraform init/plan/apply")
    parser.add_argument("--skip-app", action="store_true", help="Skip kubectl app deployment")
    parser.add_argument("--auto-approve", action="store_true", help="Pass -auto-approve to terraform apply")
    return parser.parse_args()


def main():
    args = parse_args()
    tf_dir = Path(args.tf_dir).resolve()
    tfvars_file = Path(args.tfvars_file)

    if not tfvars_file.is_absolute():
        tfvars_file = tf_dir / tfvars_file

    try:
        ensure_binaries()

        if not args.skip_auth:
            gcloud_auth(args.project_id)

        if not args.skip_terraform:
            if not tfvars_file.exists():
                raise RuntimeError(
                    f"terraform var-file not found: {tfvars_file}. "
                    "Create it first or pass --tfvars-file."
                )
            terraform_apply(str(tf_dir), str(tfvars_file), args.auto_approve)

        if not args.skip_app:
            configure_kubectl(args.project_id, args.region, args.cluster_name)
            ensure_namespace(args.namespace)
            deploy_online_boutique(args.namespace, args.manifest_url)

        verify(args.namespace, args.project_id, args.region)
        print("\nDeployment workflow completed.")
    except RuntimeError as error:
        print(f"\nERROR: {error}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
