# CLAUDE.md

Convenções e gotchas operacionais deste repositório. Para arquitetura e estrutura de
diretórios, ver o [README](README.md). Este arquivo cobre o que **não é óbvio** lendo o código.

## Política de versões de ferramentas — NUNCA `latest`

Toda ferramenta é fixada em **versão exata, um minor (ou patch) atrás do latest**. Nunca usar
`latest` nem range aberto que resolva para o mais novo (ex.: evitar `aws-cli = "2"`).

- Pins em `mise.toml` (`[tools]`): terraform, aws-vault, tflint, checkov.
- `aws-cli` fica no config **global** do mise (`~/.config/mise/config.toml`), não no repo.
- O próprio `mise` é fixado via `min_version` no `mise.toml` + `mise self-update <versão>`.
- Ao subir qualquer versão, escolher explicitamente a penúltima, nunca a mais recente.
- O aviso "TFLint is out of date" no CI é **esperado e desejado**, não um problema.

## Ambiente e execução (mise + aws-vault)

Credenciais AWS vêm via **aws-vault** (profile em `AWS_VAULT_PROFILE`, hoje `rbti`). As tasks do
mise detectam se já estão dentro de uma subshell `aws-vault` (`$AWS_VAULT`) e só chamam
`aws-vault exec` quando necessário.

- `mise run tf:init <módulo>` / `tf:plan <módulo>` / `tf:apply <módulo>`
- `mise run tf:fmt` (formata recursivamente) — rodar antes de commitar; o CI faz `fmt -check`
- `mise run tf:validate` (valida todos os módulos com `-backend=false`)
- `mise run bootstrap` (init + apply do `00-bootstrap`)
- `mise run vault:login` (abre subshell aws-vault de 8h)

## Convenções de Terraform

- **Backend S3 parcial:** cada módulo (exceto bootstrap) declara `backend "s3" {}` em `versions.tf`
  e fornece os valores via `backend.hcl` próprio.
- **`backend.hcl` é gitignored** (`!backend.hcl.example` mantém só o template). Ele **precisa** estar
  versionado para o CI funcionar, então é adicionado com `git add -f`. ⚠️ Ao criar um módulo novo,
  não esqueça de force-add o `backend.hcl` — senão o `terraform init` no CI falha com
  "could not be read".
- `required_version` segue a versão pinada do terraform (hoje `~> 1.14`).
- `00-bootstrap` roda primeiro com **state local** (ele cria o bucket/lock que os demais usam).

## CI/CD (GitHub Actions) — comportamento e gotchas

- **`terraform-plan.yml`** roda em **PR**: lint+security (fmt, tflint, checkov) e depois `plan`
  comentado no PR. `plan` depende de `lint-and-security` passar.
- **`terraform-apply.yml`** roda em **push na `main`**: `terraform apply -auto-approve`.
  ⚠️ **Merge/push na `main` cria infraestrutura real** (inclui EC2 com custo). Preferir validar via
  PR (só plan) antes de mergear.
- `detect-modules` monta a matrix a partir de arquivos `*.tf` alterados (`git diff`), **excluindo
  `00-bootstrap`**. Bootstrap é aplicado manualmente via `mise run bootstrap`.
- O passo `terraform init` no CI **precisa** de `-input=false -backend-config=backend.hcl` — sem
  isso, o backend parcial abre prompt interativo e **trava** o runner indefinidamente.
- Autenticação na AWS via **OIDC** (`aws-actions/configure-aws-credentials`), role criada no bootstrap.

## Segurança / Checkov

Config em `.checkov.yaml`. Este é um **repositório de estudo** (`Environment = study`), então a
postura de triagem é:

- **Corrigir** o que é hardening real e barato (ex.: IMDSv2, criptografia de EBS).
- **Skip inline** (`# checkov:skip=CKV_AWS_X: motivo`) para o que é **intencional do módulo**
  (site S3 público, SG aberto de demo, IAM admin pessoal). Inline mantém o check ativo nos demais
  recursos.
- **Skip global** (`.checkov.yaml`) apenas para **extras de produção** não aplicáveis a estudo
  (KMS CMK, WAF, lifecycle/notifications, PITR, custom SSL cert...). Sempre comentar o motivo.

## TODOs / dívidas conhecidas

- Actions usam **Node.js 20** (deprecado em GitHub Actions a partir de 2026-09). Atualizar
  `actions/checkout`, `setup-python`, etc. para versões com suporte a Node 24.
- Roles de deploy (`github_actions`, `terraform_local`) usam `AdministratorAccess` — escopar para
  permissões mínimas quando sair do contexto de estudo (hoje com skip documentado de `CKV_AWS_274`).
