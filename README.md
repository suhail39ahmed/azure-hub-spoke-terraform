# Azure Hub-and-Spoke Terraform (starter)

Starter Terraform modules for a basic Azure **hub-and-spoke** network layout, plus a small example wiring them together.

This is a **learning / foundation** repo — not a full enterprise landing zone.

## What's in the repo

```
modules/hub/      # hub VNet-oriented module
modules/spoke/    # spoke VNet-oriented module
examples/main/    # example that wires hub + spoke
```

## What this is not

The earlier marketing README over-claimed. This repository does **not** currently include:

- 50+ Azure Policy assignments
- Multi-region production topology with published uptime targets
- Private endpoint packs, GitLab CI, or OPA gates as maintained code in-tree

If you need those, add them deliberately — don't invent metrics.

## Usage

```bash
cd examples/main
terraform init
terraform plan
```

Review `modules/hub` and `modules/spoke` before applying. Treat this as a template to extend for your subscription, naming, and security standards.

## Known limitations

- Keep Azure Firewall SKU / hub vs VNet Firewall subnet choices aligned with current `azurerm` provider docs before apply — older samples sometimes mix hub firewall SKUs with classic `AzureFirewallSubnet` layouts.
- No automated `terraform validate` CI is attached yet; run `terraform fmt` / `terraform validate` locally.

## License

Use at your own risk in non-production first. No warranty.
