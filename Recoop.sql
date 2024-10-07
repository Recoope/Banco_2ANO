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
    senha_cooperativa varchar,
    status VARCHAR DEFAULT 'Ativo'
);

create table empresa(
    nome_empresa varchar,
    email_empresa varchar,
    senha_empresa varchar,
    telefone_empresa varchar,
    cnpj_empresa varchar(14) primary key
);

create table endereco(
    id_endereco serial primary key,
    cidade varchar,
    rua varchar,
    numero int,
    status VARCHAR DEFAULT 'Ativo'
);

create table leilao(
   id_leilao serial primary key,
   data_inicio_leilao date,
   data_fim_leilao date,
   hora_leilao time,
   id_endereco int REFERENCES endereco(id_endereco),
   cnpj_cooperativa varchar REFERENCES cooperativa(cnpj_cooperativa),
   status VARCHAR DEFAULT 'Ativo'
);

create table produto(
    id_produto serial primary key,
    tipo_produto varchar,
    valor_inicial_produto numeric,
    valor_final_produto numeric,
    peso_produto numeric,
    foto_produto varchar,
    id_leilao int REFERENCES leilao(id_leilao),
    status VARCHAR DEFAULT 'Ativo'
);

CREATE TABLE lance (
   id_lance SERIAL PRIMARY KEY,
   id_leilao INT REFERENCES leilao(id_leilao),
   cnpj_empresa varchar REFERENCES empresa(cnpj_empresa),
   valor NUMERIC,
   data_lance DATE
);

--Procedure para verificar se tudo que foi para o banco esta certo........................................
--Cooperativa
create or replace procedure insert_cooperativa (c_cnpj varchar, c_nome varchar, c_email varchar, c_senha varchar, c_status varchar)
    language 'plpgsql' as
$$
begin
    if c_email SIMILAR TO '%[@.]%' then
        if length(c_senha)>7 and c_senha SIMILAR TO '%[0-9]%' and c_senha SIMILAR TO '%[@.*%#!]%' then
            if c_email SIMILAR TO '%[@.]%' then
                INSERT INTO cooperativa (cnpj_cooperativa, nome_cooperativa, email_cooperativa, senha_cooperativa, status) VALUES (c_cnpj, c_nome, c_email, c_senha, c_status);
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
CREATE OR REPLACE PROCEDURE insert_leilao (
	lan_id_endereco int,
    lan_cnpj_cooperativa varchar, 
    leilao_data_inicio date, 
    leilao_data_fim date, 
    lan_id_leilao int,
    lan_hora time,
    lan_status varchar
    
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Verificar se a data de início é anterior à data de fim
    IF leilao_data_inicio < leilao_data_fim THEN
        IF EXISTS (SELECT 1 FROM endereco WHERE id_endereco = lan_id_endereco) AND
           EXISTS (SELECT 1 FROM cooperativa WHERE cnpj_cooperativa = lan_cnpj_cooperativa) then
           
            INSERT INTO leilao (id_leilao,data_inicio_leilao, data_fim_leilao, hora_leilao, id_endereco, cnpj_cooperativa, status)
            VALUES (lan_id_leilao,leilao_data_inicio, leilao_data_fim,lan_hora, lan_id_endereco, lan_cnpj_cooperativa,lan_status);
        else
            RAISE EXCEPTION 'Endereço ou produto não existe!!!';
        END IF;
    ELSE
        RAISE EXCEPTION 'Data de início deve ser anterior à data de fim!!!';
    END IF;
END;
$$;


--Produto
create or replace procedure insert_produto (p_id_produto int,p_tipo_produto varchar, p_valor_inicial_produto numeric, p_peso_produto numeric, p_foto_produto varchar,p_id_leilao int, p_status varchar)
    language 'plpgsql' as
$$
begin
    if exists (select id_leilao from leilao where id_leilao=p_id_leilao) then
        INSERT INTO produto (id_produto,tipo_produto, valor_inicial_produto, peso_produto, foto_produto, id_leilao,status) VALUES (p_id_produto, p_tipo_produto, p_valor_inicial_produto, p_peso_produto,p_foto_produto, p_id_leilao,p_status);
    else raise exception 'Esse leilão não existe!!!';
    end if;
-- commit;
end;
$$;

--Lance
create or replace procedure insert_lance (lan_id_lance int, lan_id_leilao int, lan_cnpj_empresa varchar(14), lan_valor numeric, lan_data date)
    language 'plpgsql' as
$$
begin
    if exists (select cnpj_empresa from empresa where cnpj_empresa=lan_cnpj_empresa) then
        if exists (select id_leilao from leilao where id_leilao=lan_id_leilao) then
            INSERT INTO lance (id_lance,id_leilao, cnpj_empresa, valor, data_lance) VALUES (lan_id_lance,lan_id_leilao, lan_cnpj_empresa, lan_valor, lan_data);
        else raise exception 'Esse leilão não existe!!!';
        end if;
    else raise exception 'Esse cnpj da empresa não existe!!!';
    end if;
-- commit;
end;
$$;

--Endereco
create or replace procedure insert_endereco (en_id int,en_cidade varchar, en_rua varchar, en_numero int, en_status varchar)
    language 'plpgsql' as
$$
begin
    if not en_cidade SIMILAR TO '%[0-9]%' then
        INSERT INTO endereco (id_endereco,cidade, rua, numero, status) VALUES (en_id, en_cidade, en_rua, en_numero, en_status);
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





-- TESTES ===================================================================================
-- lan_id_endereco int,
--     lan_cnpj_cooperativa varchar, 
--     leilao_data_inicio date, 
--     leilao_data_fim date, 
--     lan_id_leilao int,
--     lan_hora time,
--     lan_status varchar

-- (int(df_leilao['id_endereco'][i]), df_leilao['id_cooperativa'][i], df_leilao['data_inicio'][i], 
--                      df_leilao['data_fim'][i], int(df_leilao['id'][i]), df_leilao['hora'][i]))

-- CALL insert_leilao(1, '12345678901234'::varchar, '2024-08-28'::date, '2024-08-30'::date, 100, '10:00:00'::time);



-- select * from produto