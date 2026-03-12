# Azure Hub-and-Spoke Terraform

**Enterprise-grade network architecture with security guardrails**

Production-ready Terraform modules for deploying Azure Hub-and-Spoke network topology with centralized security controls, firewall policies, private endpoints, and automated compliance guardrails using Azure Policy and Defender for Cloud.

## Tech

Terraform · Azure · Azure Firewall · Private DNS · Azure Policy · Defender for Cloud · GitLab CI

## Highlights

- Centralized egress through Azure Firewall with FQDN-based policy
- Private endpoints for all PaaS services — no public internet exposure
- Automated Azure Policy assignments for CIS benchmark compliance
- GitLab CI pipeline with Terraform plan/apply and OPA policy gates
- Cost tagging enforcement and budget alerts at subscription level

## Metrics

- Hub-and-Spoke across 3 regions
- 50+ policy assignments
- Zero trust enforcement
- 99.99% network uptime

## License

MIT
