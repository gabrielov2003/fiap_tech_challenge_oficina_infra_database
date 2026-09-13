# fiap_tech_challenge_oficina_infra_database

Infraestrutura como código (Terraform) do banco de dados gerenciado da oficina. Este é um dos 4 repositórios do Tech Challenge Fase 3:

| Repositório | Responsabilidade |
|---|---|
| `fiap_tech_challenge_oficina_api` | Aplicação principal, executando em Kubernetes |
| `fiap_tech_challenge_oficina_auth_lambda` | Function de autenticação via CPF e API Gateway |
| `fiap_tech_challenge_oficina_infra_k8s` | Rede, cluster Kubernetes, registro de imagens e monitoramento |
| `fiap_tech_challenge_oficina_infra_database` | Este repositório. Banco de dados gerenciado |

## Tecnologias utilizadas

* Terraform, com estado remoto no S3
* AWS RDS for PostgreSQL 16
* AWS SSM Parameter Store
* GitHub Actions

## Justificativa da escolha do banco

PostgreSQL foi escolhido por ser um banco relacional robusto, com suporte maduro na AWS via RDS gerenciado (backups automáticos, patching e alta disponibilidade opcional cuidados pela AWS), e por combinar com o modelo relacional que a aplicação usa desde as fases anteriores: clientes, veículos, ordens de serviço e seus itens têm relacionamentos fortes, que se beneficiam de chaves estrangeiras, transações e restrições de integridade. A justificativa completa, com diagrama ER e explicação dos relacionamentos, será adicionada como parte da documentação da Fase 3. As mudanças no modelo relacional estão resumidas no README do repositório `fiap_tech_challenge_oficina_api`.

## O que é provisionado

* Instância RDS PostgreSQL 16 (`db.t3.micro`), com armazenamento `gp3` criptografado e autoscaling de armazenamento até 50 GB
* Subnet group nas subnets privadas da VPC do cluster, lidas do SSM
* Security group que libera a porta 5432 apenas para o CIDR da VPC, onde rodam os pods do EKS e a Lambda de autenticação
* Senha do banco gerada aleatoriamente pelo Terraform
* Parâmetros no SSM com os dados de conexão

A instância não é publicamente acessível. Pods e Lambda acessam o banco pela rede privada da VPC criada pelo repositório `fiap_tech_challenge_oficina_infra_k8s`.

## Parâmetros lidos e publicados no SSM

| Parâmetro | Direção | Descrição |
|---|---|---|
| `/oficina/network/vpc_id` | Lido | VPC do cluster |
| `/oficina/network/vpc_cidr` | Lido | CIDR liberado no security group |
| `/oficina/network/private_subnet_ids` | Lido | Subnets do subnet group |
| `/oficina/db/host` | Publicado | Endereço da instância |
| `/oficina/db/port` | Publicado | Porta |
| `/oficina/db/name` | Publicado | Nome do banco |
| `/oficina/db/username` | Publicado | Usuário administrador |
| `/oficina/db/password` | Publicado (SecureString) | Senha gerada |

## Ambientes

O RDS é compartilhado pelos ambientes `dev` e `prod`, que ficam separados por schema (a API cria o schema do seu ambiente na inicialização). Por isso, neste repositório a branch `dev` roda apenas o `plan`, e a `main` aplica as mudanças.

## Como provisionar manualmente

Pré-requisitos: Terraform 1.10+, AWS CLI configurado (`aws configure`), o bucket de estado criado (veja o README do `infra_k8s`) e o `infra_k8s` já aplicado.

```bash
terraform init -backend-config="bucket=NOME_DO_BUCKET" -backend-config="key=infra-database/terraform.tfstate" -backend-config="region=us-east-1" -backend-config="use_lockfile=true"
terraform plan
terraform apply
```

## Variáveis

| Variável | Descrição | Padrão |
|---|---|---|
| `region` | Região AWS | `us-east-1` |
| `db_identifier` | Identificador da instância RDS | `oficina-db` |
| `db_name` | Nome do banco de dados | `oficina` |
| `db_username` | Usuário administrador do banco | `oficina_admin` |
| `engine_version` | Versão principal do PostgreSQL | `16` |
| `instance_class` | Classe da instância RDS | `db.t3.micro` |
| `allocated_storage` | Armazenamento inicial em GB | `20` |
| `max_allocated_storage` | Limite do autoscaling de armazenamento em GB | `50` |
| `multi_az` | Réplica em outra zona para alta disponibilidade | `false` |
| `allowed_cidr_blocks` | CIDRs extras liberados na porta 5432 | `[]` |

## Outputs

| Output | Descrição |
|---|---|
| `db_endpoint` | Endereço e porta de conexão |
| `db_address` | Endereço da instância |
| `db_port` | Porta |
| `db_name` | Nome do banco |
| `parametros_ssm` | Prefixo dos parâmetros de conexão no SSM |

## CI/CD

O pipeline em `.github/workflows/ci-cd.yml`:

| Job | Quando roda | O que faz |
|---|---|---|
| `validate` | Pull requests para `main` ou `dev`, e pushes | `terraform fmt` e `terraform validate` |
| `terraform` | Depois do validate | `plan` em pull requests e na branch `dev`, `apply` no push para `main` |

Secrets: `AWS_ACCESS_KEY_ID` e `AWS_SECRET_ACCESS_KEY`. Variáveis: `TF_STATE_BUCKET` e, opcional, `AWS_REGION`. Sem credenciais AWS, o pipeline para depois da validação.

Ordem do primeiro deploy: `infra_k8s`, este repositório, a API e por último a `auth_lambda`.

## Documentação

O diagrama ER, a explicação dos relacionamentos e o diagrama de arquitetura deste repositório serão adicionados aqui.

---
Este projeto faz parte do Tech Challenge da Pós Graduação em Arquitetura de Software da FIAP.
