# Terragrunt Neptune Infrastructure Guide

## Project Architecture

This is an **Infrastructure-as-Code (IaC) project** using **Terragrunt** to orchestrate **Terraform modules** on AWS.

**Directory breakdown:**
- `infastructure/aws/root.hcl` - Global Terragrunt settings (currently empty, used for shared configuration)
- `infastructure/aws/prod/` - Environment-specific deployments (vpc, ec2)
- `modules/` - Reusable Terraform modules referenced by Terragrunt configs

**Data flow & dependencies:**
1. VPC module (`modules/vpc/`) deploys networking infrastructure (VPC, subnets, NAT gateway)
2. EC2 module (`modules/ec2/`) deploys compute instances and depends on VPC outputs
3. Terragrunt's `dependency` blocks declare required ordering and pass outputs between components

## Key Terragrunt Patterns

### Using module references
In `infastructure/aws/prod/vpc/terragrunt.hcl`:
```hcl
terraform {
  source = "../../../../modules/vpc/"
}
```
This points to the relative Terraform module. Always use relative paths.

### Declaring dependencies with mock outputs
In `infastructure/aws/prod/ec2/terragrunt.hcl`:
```hcl
dependency "vpc" {
  config_path = "../vpc"
  
  mock_outputs = {
    vpc_id            = "vpc-mock"
    public_subnet_ids = ["subnet-mock"]
  }
}

inputs = {
  vpc_id    = dependency.vpc.outputs.vpc_id
  subnet_id = dependency.vpc.outputs.public_subnet_ids[0]
}
```
**Key pattern:** Mock outputs allow local development before dependencies exist. Always provide mock values for outputs you'll reference.

### Variables pass-through
Use `inputs = {}` block to map Terragrunt values to Terraform variables. Each `inputs` key must match a declared `variable` in the module.

## Critical Module Conventions

### VPC Module (`modules/vpc/main.tf`)
- **Multi-AZ design:** Creates separate public/private subnets in each AZ (default: 3 AZs)
- **Validation rule:** `public_subnet_cidrs` and `private_subnet_cidrs` lengths must equal `az_count`
- **NAT Gateway:** Single NAT in first public subnet; all private subnets route egress through it
- **Automatic AZ selection:** If `azs = []`, uses first `az_count` available AZs in region

**When modifying:** Ensure CIDR lists match `az_count`. Add AZ-specific resources via `count = length(local.azs)`.

### EC2 Module (`modules/ec2/main.tf`)
- **Ubuntu 22.04 LTS** selected via data source (filters by Canonical owner + AMI name pattern)
- **Security group:** Restricts SSH to `allowed_ssh_cidrs` (use `/32` for single IP). Optional gateway port (18789) for specific tools.
- **Public IP:** Controlled by `associate_public_ip` variable (true for internet-facing instances)
- **EBS volume:** gp3 type with configurable IOPS/throughput for performance tuning

**Key security detail:** SSH/gateway CIDR blocks must be explicitly provided; defaults to restrictive `["0.0.0.0/32"]`.

## AWS-Specific Patterns

- **Region:** All configs default to `us-east-1`; override in Terragrunt `inputs`
- **Tagging standard:** Always include `Environment` and `Project` tags (Neptune project uses both)
- **Tier tagging:** Subnets tagged with `Tier = "public"` or `Tier = "private"` for filtering
- **Provider version:** AWS provider pinned to `~> 5.0`; Terraform `>= 1.3.0` required

## Development Workflow

1. **Deploy VPC first** (no dependencies, forms network foundation)
   ```
   cd infastructure/aws/prod/vpc/
   terragrunt apply
   ```

2. **Deploy EC2 second** (waits for VPC outputs; mocks allow `terragrunt plan` without VPC existing)
   ```
   cd infastructure/aws/prod/ec2/
   terragrunt plan  # Safe before VPC exists; uses mock_outputs
   terragrunt apply
   ```

3. **Validate outputs** - Review outputs.tf in each module to understand what's exposed

## When Adding Infrastructure

1. Create module directory under `modules/` with `main.tf`, `variables.tf`, `outputs.tf`
2. Create Terragrunt config under `infastructure/aws/prod/[component]/terragrunt.hcl`
3. Declare any `dependency` blocks if it needs outputs from other modules
4. **Always provide mock_outputs** for dependencies (enables offline planning)
5. Apply variable validation (see VPC's `az_count` validation pattern)

## Common Gotchas

- **Dependency ordering:** Manually run `terragrunt apply` in correct order; consider `root.hcl` for automation
- **CIDR overlap:** Public + private subnets must not overlap and sum must fit in VPC CIDR
- **Mock outputs stale:** Update mock_outputs when module outputs change
- **SSH restrictions:** If `allowed_ssh_cidrs = ["0.0.0.0/32"]`, you won't be able to SSH. Always customize to your IP.
