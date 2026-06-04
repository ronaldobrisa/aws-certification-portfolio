---
name: scaffold-module
description: Cria um novo módulo Terraform no AWS certification portfolio com todas as convenções do repo (backend S3 parcial + backend.hcl force-added, required_version pinado, locals de tags, stubs). Use ao adicionar um novo módulo/lab de certificação (ex.: em 01-cloud-practitioner/ ou 02-solutions-architect/).
---

# Scaffold de módulo de certificação

Procedimento para criar um módulo novo seguindo as convenções deste repo. Para o contexto geral,
ver `CLAUDE.md`. **Não pule o passo do `git add -f` no `backend.hcl`** — é a pegadinha que quebra o CI.

## Entradas necessárias
- **Caminho do módulo**: `<nivel>/<nome>`, ex.: `01-cloud-practitioner/vpc-basics`.
  Níveis existentes: `01-cloud-practitioner/`, `02-solutions-architect/`.
- **Certification**: rótulo da tag (ex.: `cloud-practitioner`, `solutions-architect`).

## Passos

1. **Descobrir o Account ID** a partir de um `backend.hcl` existente (não hardcode):
   ```bash
   grep -h bucket 01-cloud-practitioner/*/backend.hcl | head -1
   # bucket = "aws-cert-portfolio-tfstate-<ACCOUNT_ID>"
   ```

2. **Criar `versions.tf`** (required_version segue o pin do terraform; backend S3 parcial):
   ```hcl
   terraform {
     required_version = "~> 1.14"

     required_providers {
       aws = {
         source  = "hashicorp/aws"
         version = "~> 5.0"
       }
     }

     backend "s3" {}
   }

   provider "aws" {
     region = "us-east-1"

     default_tags {
       tags = {
         Owner     = "ronaldobrisa"
         ManagedBy = "terraform"
       }
     }
   }
   ```

3. **Criar `backend.hcl.example`** (template versionado) e `backend.hcl` (valores reais):
   ```hcl
   bucket         = "aws-cert-portfolio-tfstate-<ACCOUNT_ID>"
   key            = "<nivel>/<nome>/terraform.tfstate"
   region         = "us-east-1"
   dynamodb_table = "aws-cert-portfolio-tfstate-locks"
   encrypt        = true
   ```
   No `.example`, deixar `<YOUR_ACCOUNT_ID>` no lugar do account id.

4. **⚠️ Force-add do `backend.hcl`** (é gitignored — sem isso o `terraform init` no CI falha com
   "could not be read"):
   ```bash
   git add -f <nivel>/<nome>/backend.hcl
   ```

5. **Criar `main.tf`** com o bloco padrão de `locals` (todo módulo usa `Environment = "study"`):
   ```hcl
   locals {
     tags = merge({
       Project       = "aws-certification-portfolio"
       Environment   = "study"
       Certification = "<certification>"
       Module        = "<nome>"
     }, var.tags)
   }

   # recursos do módulo aqui...
   ```

6. **Criar `variables.tf`** (incluir ao menos `variable "tags" { type = map(string); default = {} }`)
   e `outputs.tf` conforme o módulo.

7. **Validar localmente** antes de commitar:
   ```bash
   mise run tf:fmt
   mise exec -- terraform -chdir=<nivel>/<nome> init -backend=false -input=false
   mise exec -- terraform -chdir=<nivel>/<nome> validate
   mise exec -- tflint --chdir=<nivel>/<nome>
   mise exec -- checkov -d <nivel>/<nome> --config-file .checkov.yaml
   ```

8. **Checkov**: corrigir hardening real (IMDSv2, criptografia); para findings intencionais do lab,
   usar `# checkov:skip=CKV_AWS_X: estudo — <motivo>` inline no recurso. Ver convenção no `CLAUDE.md`.

9. **Branch + PR** — nunca commitar direto na `main` (push na main dispara `terraform apply`).
   Abrir PR para rodar `terraform plan` e revisar o que será criado.

## Checklist final
- [ ] `versions.tf` com `required_version` pinado + `backend "s3" {}`
- [ ] `backend.hcl` **force-added** + `backend.hcl.example` versionado
- [ ] `locals.tags` com `Environment = "study"`
- [ ] `fmt`, `validate`, `tflint`, `checkov` verdes localmente
- [ ] Aberto via PR (não push direto na main)
