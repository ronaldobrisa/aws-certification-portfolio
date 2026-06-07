# Migração / setup em uma máquina nova

Como subir este projeto **exatamente como está** em outro computador.

A reprodutibilidade está repartida em três lugares. O `git clone` traz o código; a
AWS guarda o state dos módulos de app; e a **sua máquina** guarda dois itens que
**não vão no git** (credencial e state do bootstrap) e precisam ser migrados à mão.

## TL;DR

```bash
git clone <repo> && cd aws-certification-portfolio
# instalar mise (https://mise.jdx.dev) e então:
mise run setup            # ferramentas pinadas + ~/.aws/config + checagem do cofre
# migrar o SEGREDO (escolha uma):
#   a) copiar ~/.awsvault/keys/ da máquina antiga, OU
#   b) aws-vault add rbti   (com a access key/secret do IAM)
mise run vault:login      # destrava o cofre com a passphrase
mise run tf:apply 01-cloud-practitioner/ec2-first-instance
```

## O que é automático

- **`git clone`** traz: código dos módulos, `backend.hcl` de cada um (force-added),
  pins de ferramentas (`mise.toml`), `docs/aws-config.example`.
- **`mise run setup`** instala as ferramentas pinadas, fixa o `aws-cli` no config
  global do mise e cria `~/.aws/config` a partir do exemplo (não sobrescreve um
  existente). Não toca em nenhum segredo.
- **State remoto:** o state dos módulos de app (ec2, s3-static-site, iam-basics,
  billing-alerts) mora no S3 (bucket do bootstrap) + lock no DynamoDB. O
  `tf:init` reconecta sozinho — o Terraform já sabe o que existe na conta.

## O que é manual (só existe na máquina antiga, fora do git)

### 1. Credencial AWS (cofre do aws-vault) — obrigatório

A chave IAM do `rbti` vive **apenas** em `~/.awsvault/keys/` (não há
`~/.aws/credentials`). Duas formas de levar:

- **Mais simples:** copiar o diretório `~/.awsvault/keys/` para a máquina nova. O
  backend `file` é portátil — mesmos arquivos + **mesma passphrase** = funciona.
  (O arquivo `sts.GetSessionToken,...` é sessão temporária; pode ignorar.)
- **Ou:** gerar uma **nova** access key para `rbti-github-actions` no console IAM e
  rodar `aws-vault add rbti`. (O aws-vault não exporta o segredo antigo, então sem
  copiar o keystore você precisa de chave nova; depois desative a antiga.)

> ⚠️ Faça isso **antes** de largar a máquina antiga — é o único lugar onde o
> segredo existe.

### 2. State local do `00-bootstrap` — só se for gerenciar a fundação

O `00-bootstrap` roda com **state local** (`00-bootstrap/terraform.tfstate`), que é
gitignored e **não vai no clone**.

- **Não é necessário** para subir/aplicar os módulos de app.
- **É necessário** se você for **modificar ou destruir** o bootstrap (role OIDC,
  bucket de state, lock DynamoDB, IAM). Sem o state, o Terraform tentaria criar de
  novo e quebraria com "already exists".
- → Copie `00-bootstrap/terraform.tfstate*` se quiser controlar a fundação.

## Ressalvas de "exatamente como estava"

- **EC2:** ao recriar, o IP público é **novo** (não há Elastic IP) e o AMI pode ser
  mais recente (`most_recent = true`). Funcionalmente idêntica.
- **S3 do site:** nome determinístico (derivado do account_id) → recria com o
  **mesmo nome**.
- **CloudFront:** recriar gera um **domínio novo** (`dxxxx.cloudfront.net`).
