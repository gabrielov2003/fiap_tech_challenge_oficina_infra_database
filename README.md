# fiap_tech_challenge_oficina_infra_database

Infraestrutura como código (Terraform) do banco de dados gerenciado utilizado pela aplicação da oficina. Provisiona o banco consumido pelo repositório `fiap_tech_challenge_oficina_api` e, para consulta de clientes na autenticação, pelo repositório `fiap_tech_challenge_oficina_auth_lambda`.

## Tecnologias utilizadas

* Terraform, provisionamento de infraestrutura
* AWS RDS (PostgreSQL), banco de dados gerenciado
* AWS VPC, rede dedicada ao banco
* GitHub Actions, pipeline de CI/CD

## Justificativa da escolha do banco

PostgreSQL foi escolhido por ser um banco relacional robusto, com suporte maduro na AWS via RDS gerenciado (backups automáticos, patching e alta disponibilidade cuidados pela própria AWS), e por ser compatível com o modelo relacional já usado pela aplicação desde as fases anteriores. A justificativa completa, com diagrama ER e explicação dos relacionamentos, será adicionada aqui como parte da documentação da Fase 3.

## O que é provisionado

* `module.vpc`: VPC dedicada com subnets públicas e privadas em 2 zonas de disponibilidade
* `aws_db_subnet_group`: grupo de subnets privadas onde a instância RDS é criada
* `aws_security_group`: libera a porta 5432 apenas para os blocos CIDR definidos em `allowed_cidr_blocks`
* `aws_db_instance`: instância RDS PostgreSQL 16, não publicamente acessível por padrão

A instância fica em uma VPC própria, sem publicidade por padrão. A conectividade com o cluster do repositório `fiap_tech_challenge_oficina_infra_k8s` e com a function do repositório `fiap_tech_challenge_oficina_auth_lambda` (peering de VPC ou liberação pontual de CIDR) será definida no próximo passo da Fase 3, quando a integração entre os repositórios for implementada.

## Como provisionar

Pré-requisitos: Terraform instalado e AWS CLI configurado com credenciais válidas (`aws configure`).

```bash
terraform init
terraform plan -var="db_password=SUA_SENHA"
terraform apply -var="db_password=SUA_SENHA"
```

## Variáveis

| Variável | Descrição | Padrão |
|---|---|---|
| `region` | Região AWS | `us-east-1` |
| `db_identifier` | Identificador da instância RDS | `oficina-db` |
| `db_name` | Nome do banco de dados | `oficina` |
| `db_username` | Usuário administrador do banco | `oficina_admin` |
| `db_password` | Senha do usuário administrador, obrigatória, não versionada | |
| `instance_class` | Classe da instância RDS | `db.t3.micro` |
| `allocated_storage` | Armazenamento em GB | `20` |
| `publicly_accessible` | Expõe a instância publicamente, usar apenas em desenvolvimento | `false` |
| `allowed_cidr_blocks` | Blocos CIDR autorizados a acessar a porta 5432 | `[]` |

## Outputs

| Output | Descrição |
|---|---|
| `db_endpoint` | Endpoint de conexão com o banco |
| `db_name` | Nome do banco de dados |
| `db_port` | Porta de conexão |

## CI/CD

O pipeline em `.github/workflows/ci-cd.yml` roda em pull requests e a cada push em `main`:

| Etapa | O que faz |
|---|---|
| `fmt` / `validate` | Verifica formatação e validade do código Terraform |
| `plan` | Mostra as mudanças propostas, roda apenas se houver credenciais AWS configuradas |
| `apply` | Aplica as mudanças, roda apenas em push para `main` e se houver credenciais AWS configuradas |

Secrets necessários no GitHub (Settings, Secrets and variables, Actions):

| Secret | Descrição |
|---|---|
| `AWS_ACCESS_KEY_ID` | Chave de acesso da AWS |
| `AWS_SECRET_ACCESS_KEY` | Chave secreta da AWS |
| `DB_PASSWORD` | Senha do usuário administrador do banco |

Sem essas credenciais configuradas, o pipeline roda normalmente até a validação e ignora as etapas de plan e apply.

## Documentação

O diagrama ER, a explicação dos relacionamentos e o diagrama de arquitetura específico deste repositório serão adicionados aqui conforme a Fase 3 avança.

---
Este projeto faz parte do Tech Challenge da Pós Graduação em Arquitetura de Software da FIAP.
