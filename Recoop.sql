select * from cooperativa;
select * from empresa;
select * from produto;
select * from endereco;
select * from leilao;
select * from lance;


select * from log_cooperativa;
select * from log_empresa;
select * from log_produto;
select * from log_endereco;
select * from log_leilao;
select * from log_lance;

--Tabelas de log
create table log_cooperativa(
    log_cooperativa_id serial primary key,
    cod_cooperativa varchar(14),
    data_alteracao date not null,
    operacao varchar(80),
    usuario varchar(80),
    delete_old varchar(14)
);

create table log_empresa(
    log_empresa_id serial primary key,
    cod_empresa varchar(14),
    data_alteracao date not null,
    operacao varchar(80),
    usuario varchar(80),
    delete_old varchar(14)
);

create table log_leilao(
    log_leilao_id serial primary key,
    cod_leilao int,
    data_alteracao date not null,
    operacao varchar(80),
    usuario varchar(80),
    delete_old int
);

create table log_produto(
    log_produto_id serial primary key,
    cod_produto int,
    data_alteracao date not null,
    operacao varchar(80),
    usuario varchar(80),
    delete_old int
);

create table log_endereco(
    log_endereco_id serial primary key,
    cod_endereco int,
    data_alteracao date not null,
    operacao varchar(80),
    usuario varchar(80),
    delete_old int
);

create table log_lance(
    log_lance serial primary key,
    cod_lance int,
    data_alteracao date not null,
    operacao varchar(80),
    usuario varchar(80),
    delete_old int
);

--Tabelas normalizadas....................................................
create table cooperativa(
    cnpj_cooperativa VARCHAR(14) primary key,
    nome_cooperativa varchar,
    email_cooperativa varchar,
    senha_cooperativa varchar
);

create table empresa(
    nome_empresa varchar,
    email_empresa varchar,
    senha_empresa varchar,
    telefone_empresa varchar,
    cnpj_empresa varchar(14) primary key
);

create table produto(
    id_produto serial primary key,
    tipo_produto varchar,
    valor_inicial_produto numeric,
    valor_final_produto numeric,
    peso_produto numeric,
    foto_produto varchar
);

create table endereco(
    id_endereco serial primary key,
    cidade varchar,
    rua varchar,
    numero int
);

create table leilao(
   id_leilao serial primary key,
   data_inicio_leilao date,
   data_fim_leilao date,
   detalhes_leilao varchar,
   hora_leilao time,
   leilao_fim VARCHAR(3),
   id_endereco int REFERENCES endereco(id_endereco),
   id_produto int REFERENCES produto(id_produto),
   cnpj_cooperativa varchar REFERENCES cooperativa(cnpj_cooperativa)
);

--tabela app
-- preguntar na aula do grilo
CREATE TABLE lance (
   id_lance SERIAL PRIMARY KEY,
   id_leilao INT REFERENCES leilao(id_leilao),
   cnpj_empresa varchar REFERENCES empresa(cnpj_empresa),
   valor NUMERIC,
   data_lance DATE
);

--Procedure para verificar se tudo que foi para o banco esta certo........................................
--Cooperativa
create or replace procedure insert_cooperativa (c_cnpj varchar, c_nome varchar, c_email varchar, c_senha varchar)
    language 'plpgsql' as
$$
begin
    if c_email SIMILAR TO '%[@.]%' then
        if length(c_senha)>7 and c_senha SIMILAR TO '%[0-9]%' and c_senha SIMILAR TO '%[@.*%#!]%' then
            if c_email SIMILAR TO '%[@.]%' then
                INSERT INTO cooperativa (cnpj_cooperativa, nome_cooperativa, email_cooperativa, senha_cooperativa) VALUES (c_cnpj, c_nome, c_email, c_senha);
            else raise exception 'CNPJ deve ter 14 digitos!!!';
            end if;
        else raise exception 'Senha menor que 8 dígitos ou não tem numeros ou não possui caracteres especiais!!!';
        end if;
    else raise exception 'Email deve conter @ e .!!!';
    end if;
-- commit;
end;
$$;

--Empresa
create or replace procedure insert_empresa (e_nome varchar, e_email varchar, e_senha varchar, e_telefone varchar, e_cnpj varchar)
    language 'plpgsql' as
$$
begin
    if e_email SIMILAR TO '%[@.]%' then
        if length(e_senha)>7 and e_senha SIMILAR TO '%[0-9]%' and e_senha SIMILAR TO '%[@.*%#!]%' then
            if length(e_telefone)=11 and e_telefone SIMILAR TO '[0-9]+' then
                if length(e_cnpj)=14 then
                    INSERT INTO empresa (nome_empresa, email_empresa, senha_empresa, telefone_empresa, cnpj_empresa) VALUES (e_nome, e_email, e_senha, e_telefone, e_cnpj);
                else raise exception 'CNPJ não tem 14 digitos!!!';
                end if;
            else raise exception 'Telefone não tem 11 dígitos ou tem letras!!!';
            end if;
        else raise exception 'Senha menor que 8 dígitos ou não tem numeros ou não possui caracteres especiais!!!';
        end if;
    else raise exception 'Email não pode conter números e deve ter (@ e .)!!!';
    end if;
-- commit;
end;
$$;

--Leilão
create or replace procedure insert_leilao (l_data_inicio date, l_data_fim date, l_detalhes varchar, l_hora time, l_id_endereco int, l_id_produto int, l_cnpj_cooperativa varchar(14))
    language 'plpgsql' as
$$
begin
    if l_data_inicio < l_data_fim then
        if exists (select id_endereco from endereco where id_endereco=l_id_endereco) and exists (select id_produto from produto where id_produto=l_id_produto) then
            INSERT INTO leilao (data_inicio_leilao, data_fim_leilao, detalhes_leilao, hora_leilao,id_endereco,id_produto,cnpj_cooperativa) VALUES (l_data_inicio, l_data_fim, l_detalhes, l_hora,l_id_endereco,l_id_produto,l_cnpj_cooperativa);
        else raise exception 'Esse endereço ou produto não existe!!!';
        end if;
    else raise exception 'Data de início menor do que a de fim!!!';
    end if;
-- commit;
end;
$$;

--Lance
create or replace procedure insert_leilao (lan_valor numeric, lan_data_lance date, lan_cnpj_empresa varchar, leilao_data_inicio date, leilao_data_fim date, lan_id_leilao int)
    language 'plpgsql' as
$$
begin
    if leilao_data_inicio < leilao_data_fim then
        if lan_data_lance <= leilao_data_fim and leilao_data_inicio >= lan_data_lance then
            if exists (select id_leilao from leilao where id_leilao=lan_id_leilao) then
                INSERT INTO leilao (data_inicio_leilao, data_fim_leilao, detalhes_leilao, hora_leilao, lan_id_produto, lan_cnpj_cooperativa) VALUES (l_data_inicio, l_data_fim, l_detalhes, l_hora);
            else raise exception 'Esse leilão não existe!!!';
            end if;
        else raise exception 'A data do lance ou já acabou ou acabou!!!';
        end if;
    else raise exception 'Data de início menor do que a de fim!!!';
    end if;
-- commit;
end;
$$;

--Endereco
create or replace procedure insert_endereco (en_cidade varchar, en_rua varchar, en_numero int, en_registro_empresa date)
    language 'plpgsql' as
$$
begin
    if not en_cidade SIMILAR TO '%[0-9]%' then
        INSERT INTO endereco (cidade, rua, numero, registro_empresa) VALUES (en_cidade, en_rua, en_numero, registro_empresa);
    else raise exception 'Cidade não pode conter número!!!';
    end if;
-- commit;
end;
$$;

--Função de trigger....................................................
--Cooperativa
create or replace function func_log_cooperativa()
returns trigger as
$$
declare
usuario varchar(80);
begin
select usename from pg_user into usuario;
insert into log_cooperativa (cod_cooperativa,data_alteracao,operacao,usuario,delete_old) values (new.cnpj_cooperativa,current_date,tg_op,usuario,old.cnpj_cooperativa);
return new;
end;
$$
language 'plpgsql';

create trigger trg_log_cooperativa
    after insert or update or delete on cooperativa
    for each row
    execute procedure func_log_cooperativa();

--Empresa
create or replace function func_log_empresa()
returns trigger as
$$
declare
usuario varchar(80);
begin
select usename from pg_user into usuario;
insert into log_empresa (cod_empresa,data_alteracao,operacao,usuario,delete_old) values (new.cnpj_empresa,current_date,tg_op,usuario,old.cnpj_empresa);
return new;
end;
$$
language 'plpgsql';

create trigger trg_log_empresa
    after insert or update or delete on empresa
    for each row
    execute procedure func_log_empresa();

--Leilao
create or replace function func_log_leilao()
returns trigger as
$$
declare
usuario varchar(80);
begin
select usename from pg_user into usuario;
insert into log_leilao (cod_leilao,data_alteracao,operacao,usuario,delete_old) values (new.id_leilao,current_date,tg_op,usuario,old.id_leilao);
return new;
end;
$$
language 'plpgsql';

create trigger trg_log_leilao
    after insert or update or delete on leilao
    for each row
    execute procedure func_log_leilao();

--Produto
create or replace function func_log_produto()
returns trigger as
$$
declare
usuario varchar(80);
begin
select usename from pg_user into usuario;
insert into log_produto (cod_produto,data_alteracao,operacao,usuario,delete_old) values (new.id_produto,current_date,tg_op,usuario,old.id_produto);
return new;
end;
$$
language 'plpgsql';

create trigger trg_log_produto
    after insert or update or delete on produto
    for each row
    execute procedure func_log_produto();

--Endereco
create or replace function func_log_endereco()
returns trigger as
$$
declare
usuario varchar(80);
begin
select usename from pg_user into usuario;
insert into log_endereco (cod_endereco,data_alteracao,operacao,usuario,delete_old) values (new.id_endereco,current_date,tg_op,usuario,old.id_endereco);
return new;
end;
$$
language 'plpgsql';

create trigger trg_log_endereco
    after insert or update or delete on endereco
    for each row
    execute procedure func_log_endereco();

--Lance
create or replace function func_log_lance()
returns trigger as
$$
declare
usuario varchar(80);
begin
select usename from pg_user into usuario;
insert into log_lance (cod_lance,data_alteracao,operacao,usuario,delete_old) values (new.id_lance,current_date,tg_op,usuario,old.id_lance);
return new;
end;
$$
language 'plpgsql';

create trigger trg_log_lance
    after insert or update or delete on lance
    for each row
    execute procedure func_log_lance();