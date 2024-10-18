# Estrutura de Tabelas

## 1. Tabelas de Log
As tabelas de log são usadas para rastrear alterações nas tabelas principais (cooperativa, empresa, leilão, etc.). Cada tabela de log tem as seguintes colunas:

- **log_id**: Chave primária, identificador único para cada registro de log.
- **cod**: Código correspondente à tabela principal (cnpj, id, etc.).
- **data_alteracao**: Data da alteração no registro.
- **operacao**: Operação realizada (INSERT, UPDATE, DELETE).
- **usuario**: Usuário responsável pela operação.
- **delete_old**: Valor antigo do campo correspondente, antes da alteração.

### Tabelas de Log criadas:
- log_cooperativa
- log_empresa
- log_leilao
- log_produto
- log_endereco
- log_lance

## 2. Tabelas Normalizadas
Essas tabelas armazenam os dados principais da aplicação. Abaixo segue a descrição das principais tabelas:

- **cooperativa**: Armazena informações das cooperativas, incluindo `cnpj_cooperativa` como chave primária, nome, email, senha, e o status da cooperativa.
- **empresa**: Tabela para armazenar os dados das empresas, com `cnpj_empresa` como chave primária, nome, email, telefone, e senha.
- **endereco**: Armazena os endereços dos leilões. Contém `id_endereco` como chave primária, cidade, rua, número, e status do endereço.
- **produto**: Armazena os dados dos produtos leiloados. `id_produto` é a chave primária e a tabela contém os campos tipo_produto, valor_inicial, peso, foto, e status.
- **leilao**: Tabela principal dos leilões, com `id_leilao` como chave primária, e referência para as tabelas endereco, cooperativa e produto. Inclui também `data_inicio`, `data_fim`, detalhes e status do leilão.
- **lance**: Armazena os lances feitos pelas empresas. `id_lance` é a chave primária, e as chaves estrangeiras são `id_leilao` e `cnpj_empresa`.

## Procedures (Procedimentos Armazenados)
- **insert_cooperativa**: Insere dados na tabela cooperativa, verificando a validade do email e da senha.
    - *Validações*: O email deve conter "@" e ".", a senha deve ter mais de 7 dígitos e conter números e caracteres especiais.
- **insert_empresa**: Insere dados na tabela empresa, com verificações no formato de email, tamanho de senha, e validade do telefone e CNPJ.
- **insert_leilao**: Insere um novo leilão, verificando se o endereço, cooperativa e produto existem, além de garantir que a data de início do leilão é anterior à data de fim.
- **insert_produto**: Insere produtos na tabela produto, garantindo que o valor inicial do produto seja positivo.
- **insert_lance**: Insere lances na tabela lance, garantindo que o leilão e empresa existam antes de fazer a inserção.
- **insert_endereco**: Insere endereços na tabela endereco, garantindo que a cidade não contenha números.

## Triggers (Gatilhos)
Para cada tabela de log foi criado um gatilho (trigger) associado às operações de inserção, atualização e exclusão (INSERT, UPDATE, DELETE) nas tabelas principais. Eles registram as alterações em suas respectivas tabelas de log:

- **trg_log_cooperativa**: Gatilho para a tabela cooperativa, registra as mudanças na tabela log_cooperativa.
- **trg_log_empresa**: Gatilho para a tabela empresa, registra as mudanças na tabela log_empresa.
- **trg_log_leilao**: Gatilho para a tabela leilao, grava as alterações na tabela log_leilao.
- **trg_log_produto**: Gatilho para a tabela produto, registra as mudanças na tabela log_produto.
- **trg_log_endereco**: Gatilho para a tabela endereco, registra as mudanças na tabela log_endereco.
- **trg_log_lance**: Gatilho para a tabela lance, registra as mudanças na tabela log_lance.

## Considerações Finais
Esse banco de dados foi desenhado para registrar as atividades e mudanças nas tabelas principais, garantindo uma rastreabilidade das operações realizadas. Além disso, há forte validação em todos os procedimentos armazenados para garantir integridade nos dados inseridos.