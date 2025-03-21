//@isTest
public class TestDataSetup {

    public class TestSetupException extends Exception {}

    public static void overrideLabel(String labelName, String value) {
        if (Test.isRunningTest()) {
            System.debug('Substituindo Label: ' + labelName + ' com valor: ' + value);
            // Aqui podemos armazenar a substituição em um Map para simular a mudança dos Labels
            testLabels.put(labelName, value);
        } else {
            throw new TestSetupException('Override de Label não permitido em produção.');
        }
    }
    
    // Adicione um Map para armazenar os valores dos labels durante os testes
    private static Map<String, String> testLabels = new Map<String, String>();
    
    // Método para recuperar um Label simulado
    public static String getLabel(String labelName) {
        return testLabels.containsKey(labelName) ? testLabels.get(labelName) : null;
    } 

    public static User createUser(String firstName, String lastName, String profileName, String email, String nickname) {
        System.debug('Iniciando criação de usuário');
    
        try {
            // Definir um nome de perfil padrão se não for informado
            profileName = String.isNotBlank(profileName) ? profileName : 'Standard User';
            
            // Buscar o ID do perfil
            Id profileId = getProfileIdByName(profileName);
            if (profileId == null) {
                throw new CustomException('Erro crítico: Perfil "' + profileName + '" não encontrado.');
            }
    
            // Criar informações únicas para evitar conflitos
            String uniqueSuffix = String.valueOf(System.currentTimeMillis()).right(4);
            String safeLastName = String.isNotBlank(lastName) ? lastName.toLowerCase() : 'mockuser';
            String safeFirstName = String.isNotBlank(firstName) ? firstName : 'random';
            String safeEmail = String.isNotBlank(email) ? email : safeLastName + uniqueSuffix + '@example.com';
            String safeAlias = (safeLastName + uniqueSuffix).left(8);
            String safeCommunityNickname = safeLastName + uniqueSuffix;
    
            User user = new User(
                FirstName = safeFirstName,
                LastName = safeLastName,
                Email = safeEmail,
                Username = safeEmail,
                Alias = safeAlias,
                CommunityNickname = safeCommunityNickname,
                ProfileId = profileId,
                TimeZoneSidKey = 'America/Sao_Paulo',
                LocaleSidKey = 'pt_BR',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                CompanyName = 'Ultragaz Energia',
                Department = 'Diretoria',
                Division = 'Gestão',
                Nivel__c = 10
            );
    
            insert user;
            
            System.debug('Usuário criado com sucesso: ' + user.Id);
            return user;
        } catch (Exception ex) {
            System.debug('Erro ao criar usuário: ' + ex.getMessage());
            throw new CustomException('Erro ao criar usuário: ' + ex.getMessage());
        }
    }
    
    // Método auxiliar para buscar o ID do perfil pelo nome
    private static Id getProfileIdByName(String profileName) {
        try {
            Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
            return (profile != null) ? profile.Id : null;
        } catch (Exception e) {
            System.debug('Erro ao buscar perfil: ' + profileName);
            return null;
        }
    }
    
    public static Configuracoes__c createResponsavel(Id responsavelId) {
        System.debug('Iniciando criação de responsável');
    
        Id defaultUserId;
        try {
            defaultUserId = [SELECT Id FROM User WHERE IsActive = TRUE ORDER BY CreatedDate ASC LIMIT 1].Id;
        } catch (Exception e) {
            System.debug('Nenhum usuário ativo encontrado. Criando um novo usuário.');
            try {
                defaultUserId = createUser(null, null, null, null, null).Id;
            } catch (Exception ex) {
                System.debug('Erro ao criar usuário padrão: ' + ex.getMessage());
                throw new CustomException('Erro crítico: Nenhum usuário padrão disponível.');
            }
        }
    
        Id finalResponsavelId = (responsavelId != null) ? responsavelId : defaultUserId;
    
        RecordType responsavelRT;
        try {
            responsavelRT = [SELECT Id FROM RecordType WHERE Name = 'Responsavel' LIMIT 1];
            if (responsavelRT == null) {
                throw new CustomException('RecordType "Responsavel" não encontrado.');
            }
        } catch (Exception e) {
            throw new CustomException('Erro ao buscar RecordType "Responsavel": ' + e.getMessage());
        }
    
        Configuracoes__c responsavel = new Configuracoes__c(
            Responsavel__c = finalResponsavelId,
            RecordTypeId = responsavelRT.Id,
            Ativo__c = true
        );
    
        insert responsavel;
        
        System.debug('Responsável criado com sucesso: ' + responsavel.Id);
        return responsavel;
    }
    
    public static Task createTask(Id ownerId, String subject, Date activityDate) {
        System.debug('Iniciando criação de Task');
    
        if (ownerId == null) {
            ownerId = UserInfo.getUserId();
        }
    
        Task task = new Task(
            Subject = String.isNotBlank(subject) ? subject : 'Onboarding Teste',
            OwnerId = ownerId,
            ActivityDate = activityDate != null ? activityDate : Date.today(),
            Responsavel_pelo_tratamento__c = ownerId
        );
    
        insert task;
    
        System.debug('Task criada com sucesso: ' + task.Id);
        return task;
    }
    

    public static Distribuidora__c createDistribuidora(String name, String uf) {
        System.debug('Iniciando criação de distribuidora');
        try {
            String uniqueSuffix = String.valueOf(System.currentTimeMillis()).right(4);
            String uniqueName = (String.isNotBlank(name) ? name : 'Distribuidora') + ' ' + uniqueSuffix;
            Distribuidora__c distribuidora = new Distribuidora__c(
                Name = uniqueName, uf__c = String.isNotBlank(uf) ? uf : 'SP',
                Minimo_PF__c = 1,Minimo_PJ__c = 1);
            insert distribuidora;
            System.debug('Distribuidora criada com sucesso: ' + distribuidora.Id);
            System.debug('Nome: ' + distribuidora.Name);
            System.debug('UF: ' + distribuidora.uf__c);
            System.debug('Ativa: ' + distribuidora.ativa__c);
            System.debug('Mínimo PF: ' + distribuidora.Minimo_PF__c);
            System.debug('Mínimo PJ: ' + distribuidora.Minimo_PJ__c);
            return distribuidora;
        } catch (Exception ex) {
            System.debug('Erro ao criar distribuidora: ' + ex.getMessage());
            throw ex;
        }
    }
    
    public static Tarifa_Distribuidora__c createTarifaDistribuidora(Distribuidora__c distribuidora) {
        System.debug('Iniciando criação de tarifa para distribuidora');
        Distribuidora__c dist = distribuidora;
        try {
            if (distribuidora == null) {
                System.debug('Nenhuma distribuidora fornecida, criando uma nova');
                dist = createDistribuidora(null, null);
            }
            Tarifa_Distribuidora__c tarifa = new Tarifa_Distribuidora__c(
                Distribuidora__c = dist.Id,TE__c = 0.5,TUSD__c = 0.5,
                Inicio_Vigencia__c = System.today(),
                Fim_Vigencia__c = System.today() + 365
            );
            insert tarifa;
            System.debug('Tarifa da distribuidora criada com sucesso: ' + tarifa.Id);
            System.debug('Nome: ' + tarifa.Name);
            System.debug('Distribuidora: ' + dist.Name);
            System.debug('TE: ' + tarifa.TE__c);
            System.debug('TUSD: ' + tarifa.TUSD__c);
            return tarifa;
        } catch (Exception ex) {
            System.debug('Erro ao criar tarifa da distribuidora: ' + ex.getMessage());
            throw ex;
        }
    }    
    
    public static Vertical__c createVertical(String name) {
        System.debug('Iniciando criação de vertical');
        try {
            String uniqueSuffix = String.valueOf(System.currentTimeMillis()).right(4);
            String uniqueName = String.isNotBlank(name) ? name : 'Vertical' + ' ' + uniqueSuffix;
            Vertical__c vertical = new Vertical__c(
                Name = uniqueName
                , Email_da_Vertical_para_enviar_o_case__c = 'vertical'+uniqueSuffix+'@gmail.com'
                , Email_da_Vertical__c = 'vertical'+uniqueSuffix+'@gmail.com'
                , Email_de_supervisao__c = 'vertical'+uniqueSuffix+'@gmail.com'
                , Email_do_ponto_focal__c = 'vertical'+uniqueSuffix+'@gmail.com'
                , Telefone_da_vertical__c = '552199999'+uniqueSuffix
                , WhatsApp_da_vertical__c = '552199999'+uniqueSuffix
                , Site_da_Vertical__c = 'www.'+uniqueName+'.com.br'
                , Ativa__c = true
            );
            insert vertical;
            System.debug('Vertical criada com sucesso: ' + vertical.Id);
            System.debug('Nome: ' + vertical.Name);
            return vertical;
        } catch (Exception ex) {
            System.debug('Erro ao criar vertical: ' + ex.getMessage());
            throw ex;
        }
    }

    public static Originador__c createOriginador(Id verticalId, String name) {
        System.debug('Iniciando criação de Originador');
        try {
            if (verticalId == null) {
                System.debug('Nenhuma vertical fornecida. Criando uma nova.');
                verticalId = createVertical(null).Id;
            }
            String uniqueSuffix = String.valueOf(System.currentTimeMillis()).right(4);
            String uniqueName = (String.isNotBlank(name) ? name : 'Originador') + ' ' + uniqueSuffix;
            Originador__c originador = new Originador__c(
                Name = uniqueName
                , Apelido__c = uniqueName
                , Vertical__c = verticalId
                , Email_para_envio_do_Case__c = 'originador'+uniqueSuffix+'@gmail.com'
                , Email_notificacao_novo_lead__c = 'originador'+uniqueSuffix+'@gmail.com'
                , Email__c = 'originador'+uniqueSuffix+'@gmail.com'
                , Telefone__c = '552199999'+uniqueSuffix
                , Fila__c = 'atendimento externo'
                , Ativo__c = true
                );
            insert originador;
            System.debug('Originador criado com sucesso: ' + originador.Id);
            System.debug('Nome: ' + originador.Name + ' | Apelido: ' + originador.Apelido__c);
            return originador;
        } catch (Exception ex) {
            System.debug('Erro ao criar Originador: ' + ex.getMessage());
            throw ex;
        }
    }
    
    public static Originador__c createOriginadorFilho(Id verticalId, String name, Id originadorPaiId) {
        System.debug('Iniciando criação de Originador Filho');
        try {
            if (verticalId == null) {
                System.debug('Nenhuma vertical fornecida. Criando uma nova.');
                verticalId = createVertical(null).Id;
            }
            if (originadorPaiId == null) {
                System.debug('Nenhum Originador Pai fornecido. Criando um novo Originador Pai.');
                originadorPaiId = createOriginador(verticalId, 'Originador Pai').Id;
            }
            String uniqueSuffix = String.valueOf(System.currentTimeMillis()).right(4);
            String uniqueName = (String.isNotBlank(name) ? name : 'Originador Filho') + ' ' + uniqueSuffix;
            Originador__c originadorFilho = new Originador__c(
                Name = uniqueName
                , Apelido__c = uniqueName
                , Vertical__c = verticalId
                , Originador_Pai__c = originadorPaiId
                , Email_para_envio_do_Case__c = 'originador'+uniqueSuffix+'@gmail.com'
                , Email_notificacao_novo_lead__c = 'originador'+uniqueSuffix+'@gmail.com'
                , Email__c = 'originador'+uniqueSuffix+'@gmail.com'
                , Telefone__c = '552199999'+uniqueSuffix
                , Fila__c = 'atendimento externo'
                , Ativo__c = true
            );
            insert originadorFilho;
            System.debug('Originador Filho criado com sucesso: ' + originadorFilho.Id);
            System.debug('Nome: ' + originadorFilho.Name + ' | Apelido: ' + originadorFilho.Apelido__c + ' | Originador Pai: ' + originadorFilho.Originador_Pai__c);
            return originadorFilho;
        } catch (Exception ex) {
            System.debug('Erro ao criar Originador Filho: ' + ex.getMessage());
            throw ex;
        }
    }

    // Método para criar um Lead PF qualificando (falta custo, mobile, email)
    public static Lead createLeadPfQualificando(Id originadorId, Id distribuidoraId) {
        System.debug('Iniciando criação de Lead PF Qualificando');
        try {    
            String uniqueSuffix = String.valueOf(System.currentTimeMillis()).right(4);
            String uniqueLastName = 'Lead PF Teste ' + uniqueSuffix;
            Lead lead = new Lead(LastName = uniqueLastName, Company = uniqueLastName,  CPF__c = '09458888727', Status = '10 Novo',
                Originador__c = originadorId,Distribuidora__c = distribuidoraId                
            );
            insert lead;
            System.debug('Lead PF Qualificando criado com sucesso: ' + lead.Id);
            System.debug('Nome: ' + lead.LastName);
            return lead;
        } catch (Exception ex) {
            System.debug('Erro ao criar Lead PF Qualificando: ' + ex.getMessage());
            throw ex;
        }
    }
    
    // Método para criar um Lead PJ Qualificando (falta custo, mobile, email)
    public static Lead createLeadPjQualificando(Id originadorId, Id distribuidoraId, String cnpj) {
        System.debug('Iniciando criação de Lead PJ Qualificando');
        try {    
            String uniqueSuffix = String.valueOf(System.currentTimeMillis()).right(4);
            String uniqueLastName = 'Lead PJ Teste ' + uniqueSuffix;
            String uniqueCompany = 'Empresa Teste ' + uniqueSuffix;
            Lead lead = new Lead(LastName = uniqueLastName, CPF__c = '09458888727', Company = uniqueCompany,
                Status = '10 Novo', Originador__c = originadorId, Distribuidora__c = distribuidoraId,
                CNPJ__c = String.isNotBlank(cnpj) ? cnpj : '34363771000165'
            );
            insert lead;
            System.debug('Lead PJ Qualificando criado com sucesso: ' + lead.Id);
            System.debug('Company: ' + lead.Company);
    
            return lead;
        } catch (Exception ex) {
            System.debug('Erro ao criar Lead PF Qualificando: ' + ex.getMessage());
            throw ex;
        }
    }

    // Método para criar um Lead
    public static Lead createLeadPfToConvert(Id originadorId, Id distribuidoraId) {
        System.debug('Iniciando criação de Lead PF Qualificado');
        try {    
            String uniqueSuffix = String.valueOf(System.currentTimeMillis()).right(4);
            String uniqueLastName = 'Lead PF Teste ' + uniqueSuffix;
            Lead lead = new Lead(LastName = uniqueLastName, Company = uniqueLastName, Status = '10 Novo',Originador__c = originadorId,Distribuidora__c = distribuidoraId,
                CPF__c = '09458888727',Custo__c = 10000,MobilePhone = '552199999'+uniqueSuffix,Email = 'email'+uniqueSuffix+'@gmail.com'
            );
            insert lead;
            System.debug('Lead PF Qualificado criado com sucesso: ' + lead.Id);
            System.debug('Nome: ' + lead.LastName);
            return lead;
        } catch (Exception ex) {
            System.debug('Erro ao criar Lead PF Qualificado: ' + ex.getMessage());
            throw ex;
        }
    }

    public static Lead createLeadPjToConvert(Id originadorId, Id distribuidoraId, String cnpj) {
        System.debug('Iniciando criação de Lead PJ Qualificado');
        try {    
            String uniqueSuffix = String.valueOf(System.currentTimeMillis()).right(4);
            String uniqueLastName = 'Lead PJ Teste ' + uniqueSuffix;
            String uniqueCompany = 'Empresa Teste ' + uniqueSuffix;
            Lead lead = new Lead(LastName = uniqueLastName,Company = uniqueCompany,Status = '10 Novo',Originador__c = originadorId,
                Distribuidora__c = distribuidoraId,CPF__c = '09458888727',Custo__c = 10000,CNPJ__c = String.isNotBlank(cnpj) ? cnpj : '34363771000165',
                MobilePhone = '552199999'+uniqueSuffix,Email = 'email'+uniqueSuffix+'@gmail.com'
            );
            insert lead;
            System.debug('Lead PJ Qualificado criado com sucesso: ' + lead.Id);
            System.debug('Company: ' + lead.Company);
            return lead;
        } catch (Exception ex) {
            System.debug('Erro ao criar Lead PF Qualificado: ' + ex.getMessage());
            throw ex;
        }
    }
    
    public static Gerador__c createGerador(String name) {
        System.debug('Iniciando criação de Gerador');
        try {
            String uniqueSuffix = String.valueOf(System.currentTimeMillis()).right(4);
            String uniqueName = (String.isNotBlank(name) ? name : 'Gerador') + ' ' + uniqueSuffix;
            Gerador__c gerador = new Gerador__c(Name = uniqueName, Ativo__c = true);
            insert gerador;
            System.debug('Gerador criado com sucesso: ' + gerador.Id);
            System.debug('Nome: ' + gerador.Name);
            return gerador;
        } catch (Exception ex) {
            System.debug('Erro ao criar Gerador: ' + ex.getMessage());
            throw ex;
        }
    }
    
    public static Veiculo__c createVeiculo(Id geradorId, String name) {
        System.debug('Iniciando criação de Veículo');
        try {
            if (geradorId == null) {
                System.debug('Nenhum Gerador fornecido, criando um novo.');
                Gerador__c novoGerador = createGerador(null);
                geradorId = novoGerador.Id;
            }
            String uniqueSuffix = String.valueOf(System.currentTimeMillis()).right(4);
            String uniqueName = (String.isNotBlank(name) ? name : 'Veículo') + ' ' + uniqueSuffix;
            Veiculo__c veiculo = new Veiculo__c(
                Name = uniqueName, 
                Gerador__c = geradorId, 
                Ato_Constitutivo__c = 'https://bit.ly/Ultragaz_SP_001',
                Razao_Social__c = 'SAO PAULO 001 CONSORCIO',
                CNPJ__c = '50.811.563/0001-38',
                Nire__c = '3550075562-0',
                Tipo_do_Logradouro__c = 'Avenida',
                Logradouro__c = 'Brigadeiro Luis Antonio',
                Numero__c = '1343',
                Complemento__c = 'Andar 6 Sala 1',
                UF__c = 'SP',
                Bairro__c = 'Bela Vista',
                Cidade__c = 'São Paulo',
                CEP__c = '01317001',
                Natureza_Juridica__c = 'Consórcio Simples',
                Orgao_de_Registro__c = 'JUCESP',
                Status__c = 'Operacional',
                DataDoRegistro__c = Date.valueOf('2023-05-25'),
                Isenta_ICMS_TE__c = true,
                Isenta_ICMS_TUSD__c = false,
                Abatimento_de_COFINS__c = false,
                Tipo_de_Veiculo__c = 'Consórcio'
            );
            insert veiculo;
            System.debug('Veículo criado com sucesso: ' + veiculo.Id);
            System.debug('Nome: ' + veiculo.Name);
            return veiculo;
        } catch (Exception ex) {
            System.debug('Erro ao criar Veículo: ' + ex.getMessage());
            throw ex;
        }
    }
    
    public static Plataforma_de_Cobranca__c createPlataformaCobranca(Id veiculoId, String provedor) {
        System.debug('Iniciando criação de Plataforma de Cobranca');
        try {
            if (veiculoId == null) {
                System.debug('VeiculoId é nulo. Criando um novo.');
                veiculoId = createVeiculo(null, null).Id;
            }
            if (provedor == null) {
                System.debug('Provedor é nulo. Seguindo com itau.');
                provedor = 'itau';
            }
            String uniqueSuffix = String.valueOf(System.currentTimeMillis()).right(4);
            Plataforma_de_Cobranca__c plataformaCobranca = new Plataforma_de_Cobranca__c(
                Veiculo__c = veiculoId, Provedor__c = provedor, TipoBoleto__c = 'a vista',
                Agencia__c = '29380', Conta_Corrente__c = '059541-6', ID_Carteira__c = 'mock_id_carteira',
                CodigoCarteira__c = '109', CodigoEspecie__c = '99', 
                LimiteParaPagamentoEmDias__c = 60, PctJurosAoMes__c = 1, PctMulta__c = 2,
                Key__c = 'mock_key'
            );
            insert plataformaCobranca;
            System.debug('Plataforma de Cobranca criada com sucesso: ' + plataformaCobranca.Id);
            System.debug('Nome: ' + plataformaCobranca.Name);
            return plataformaCobranca;
        } catch (Exception ex) {
            System.debug('Erro ao criar Plataforma de Cobranca: ' + ex.getMessage());
            throw ex;
        }
    }

    // Cria um Produto do Gerador associado a uma Vertical e Distribuidora
    public static Produto_do_Gerador__c createProdutoDoGerador(Id verticalId, Id veiculoId, Id distribuidoraId, Id plataformaCobrancaId) {
        System.debug('Iniciando criação de Produto do Gerador');
        try {
            if (verticalId == null) {
                System.debug('VerticalId é nulo. Criando um novo.');
                verticalId = createVertical(null).Id;
            }
            if (veiculoId == null) {
                System.debug('VeiculoId é nulo. Criando um novo.');
                veiculoId = createVeiculo(null, null).Id;
            }
            if (distribuidoraId == null) {
                System.debug('DistribuidoraId é nulo. Criando uma nova.');
                distribuidoraId = createDistribuidora(null, null).Id;
            }
            if (plataformaCobrancaId == null) {
                System.debug('plataformaCobrancaId é nulo. Criando uma nova.');
                plataformaCobrancaId = createPlataformaCobranca(veiculoId, 'itau').Id;
            }
            String uniqueSuffix = String.valueOf(System.currentTimeMillis()).right(4);
            Produto_do_Gerador__c produto = new Produto_do_Gerador__c(
                Vertical__c = verticalId, Veiculo__c = veiculoId,
                Distribuidora__c = distribuidoraId, Plataforma_de_Cobranca__c = plataformaCobrancaId,
                PF__c = true,PJ__c = true, B1__c = true,B3__c = true,Prioridade__c = 99,Tarifa_para_Desconto__c = 0.8,
                Pct_Desconto_Verde__c = 10, kWh_Total_Minimo_por_Opp__c = 1, kWh_Total_Minimo_por_UC__c = 1,
                kWh_Variavel_Minimo_por_Opp__c = 1, kWh_Variavel_Minimo_por_UC__c = 1,
                RS_Total_Minimo_por_Opp__c = 1,RS_Total_Minimo_por_UC__c = 1,
                RS_Variavel_Minimo_por_Opp__c = 1, RS_Variavel_Minimo_por_UC__c = 1
            );
            insert produto;
            System.debug('Produto do Gerador criado com sucesso: ' + produto.Id);
            System.debug('Nome: ' + produto.Name);
            return produto;
        } catch (Exception ex) {
            System.debug('Erro ao criar Produto do Gerador: ' + ex.getMessage());
            throw ex;
        }
    }

    // Cria uma Conta associada a uma Vertical e Originador
    public static Account createAccount(Id verticalId, Id originadorId, String name, String cnpj) {
        System.debug('Iniciando criação de Conta');
        try {
            if (verticalId == null) {
                System.debug('VerticalId é nulo. Criando uma nova Vertical.');
                verticalId = createVertical(null).Id;
            }
            if (originadorId == null) {
                System.debug('OriginadorId é nulo. Criando um novo Originador.');
                originadorId = createOriginador(verticalId, null).Id;
            }

            String uniqueSuffix = String.valueOf(System.currentTimeMillis()).right(4);
            String uniqueName = (String.isNotBlank(name) ? name : 'Conta ' + uniqueSuffix);
            
            // 🚨 Verificar se já existe uma conta com o mesmo CNPJ
            Account existingAccount = null;
            if (String.isNotBlank(cnpj)) {
                try {
                    existingAccount = [SELECT Id FROM Account WHERE CNPJ__c = :cnpj LIMIT 1];
                } catch (Exception e) {
                    System.debug('Erro ao buscar Account existente: ' + e.getMessage());
                }
            }

            if (existingAccount != null) {
                System.debug('Já existe uma Account com esse CNPJ. Retornando a existente.');
                return existingAccount; // Evita duplicação e erro de Flow
            }

            // 🚨 Gera um Username único para evitar conflitos
            String uniqueUsername = 'user' + uniqueSuffix + '@sandbox.com';

            Account account = new Account(
                Name = uniqueName,
                Vertical__c = verticalId,
                Originador__c = originadorId,
                CNPJ__c = String.isNotBlank(cnpj) ? cnpj : null,
                Usuario_Portal__c = uniqueUsername, // 🔹 Garante que o Username será único
                Logradouro__c = 'Rua da Conta', 
                Numero__c = 'Numero da Conta 123', 
                Complemento__c = 'Complemento da Conta',
                Bairro__c = 'Bairro da Conta', 
                Cidade__c = 'Cidade da Conta', 
                UF__c = 'RJ', 
                CEP__c = '224404032'
            );

            insert account;
            System.debug('Conta criada com sucesso: ' + account.Id);
            System.debug('Nome: ' + account.Name);
            return account;
        } catch (Exception ex) {
            System.debug('Erro ao criar Conta: ' + ex.getMessage());
            throw ex;
        }
    }

    
    public static Account createAccountPJ(Id verticalId, Id originadorId, String name, String cnpj) {
        System.debug('Iniciando criação de Conta PJ');
    
        try {
            if (verticalId == null) {
                System.debug('VerticalId é nulo. Criando uma nova Vertical.');
                verticalId = createVertical(null).Id;
            }
            if (originadorId == null) {
                System.debug('OriginadorId é nulo. Criando um novo Originador.');
                originadorId = createOriginador(verticalId, null).Id;
            }
            String uniqueSuffix = String.valueOf(System.currentTimeMillis()).right(4);
            String uniqueName = (String.isNotBlank(name) ? name : 'Conta PJ ' + uniqueSuffix);
            Account account = new Account(Name = uniqueName,Vertical__c = verticalId,
                Originador__c = originadorId, CNPJ__c = String.isNotBlank(cnpj) ? cnpj : '34.363.771/0001-65',
                Logradouro__c = 'Rua da Conta', Numero__c = 'Numero da Conta 123', Complemento__c = 'Complemento da Conta',
                Bairro__c = 'Bairro da Conta', Cidade__c = 'Cidade da Conta', UF__c = 'RJ', CEP__c = '224404032'
            );
            insert account;
            System.debug('Conta PJ criada com sucesso: ' + account.Id);
            System.debug('Nome: ' + account.Name);
            return account;
        } catch (Exception ex) {
            System.debug('Erro ao criar Conta PJ: ' + ex.getMessage());
            throw ex;
        }
    }

    // Cria um Contato associado a uma Conta
    public static Contact createContact(Id accountId, String firstName, String lastName, String email, String mobilePhone, Date dataNascimento) {
        System.debug('Iniciando criação de contato');
        try {
            if (accountId == null) {
                System.debug('AccountId é nulo. Criando uma nova Account');
                accountId = createAccount(null, null, null, null).Id;
            }
            String uniqueSuffix = String.valueOf(System.currentTimeMillis()).right(4);
            String safeFirstName = String.isNotBlank(firstName) ? firstName : 'Contato';
            String safeLastName = String.isNotBlank(lastName) ? lastName : 'Sobrenome ' + uniqueSuffix;
            String safeEmail = String.isNotBlank(email) ? email : 'email' + uniqueSuffix + '@gmail.com';
            String safeMobilePhone = String.isNotBlank(mobilePhone) ? mobilePhone : '552199999' + uniqueSuffix;
            Date safeDataNascimento = dataNascimento != null ? dataNascimento : Date.newInstance(1982, 5, 19);
            
            // Criando o contato
            Contact contact = new Contact(
                AccountId = accountId, FirstName = safeFirstName, LastName = safeLastName,
                Email = safeEmail, MobilePhone = safeMobilePhone, Data_de_Nascimento__c = safeDataNascimento,
                CPF__c = '0945888'+uniqueSuffix,
                Logradouro__c = 'Rua do Contato', Numero__c = 'Numero do Contato 987', Complemento__c = 'Apto 1001',
                Bairro__c = 'Bairro do Contato', Cidade__c = 'Cidade do Contato', UF__c = 'RJ', CEP__c = '22441090'
            );
            insert contact;
            System.debug('Contato criado com sucesso: ' + contact.Id + ' | Nome: ' + safeFirstName + ' ' + safeLastName);
            return contact;
        } catch (Exception ex) {
            System.debug('Erro ao criar Contato: ' + ex.getMessage());
            throw ex;
        }
    }


    public static Opportunity createOpportunity(Id accountId, Id produtoId, Id repLegalId) {
        System.debug('Iniciando criação de oportunidade');
        try {
            if (accountId == null) {
                System.debug('AccountId é nulo. Criando uma nova Account');
                accountId = createAccount(null, null, null, null).Id;
            }
            if (repLegalId == null) {
                System.debug('RepLegalId é nulo. Criando um novo Contato');
                repLegalId = createContact(accountId, null, null, null, null, null).Id;
            }
            String uniqueSuffix = String.valueOf(System.currentTimeMillis()).right(4);
            String safeName = 'Oportunidade ' + uniqueSuffix;
            Date safeCloseDate = Date.today().addDays(30);
            Opportunity opportunity = new Opportunity(
                AccountId = accountId, Name = safeName, StageName = '015 Coleta fatura',
                Produto__c = produtoId, Rep_Legal__c = repLegalId, CloseDate = safeCloseDate
            );
            insert opportunity;
            System.debug('Oportunidade criada com sucesso: ' + opportunity.Id + ' | Nome: ' + safeName);
            return opportunity;
        } catch (Exception ex) {
            System.debug('Erro ao criar Oportunidade: ' + ex.getMessage());
            throw ex;
        }
    }
    

    public static Opportunity createOpportunityInAuditoria(Id accountId, Id produtoId, Id repLegalId, Date closeDate, String name) {
        System.debug('Iniciando criação de oportunidade em auditoria');
        try {
            if (accountId == null) {
                System.debug('AccountId é nulo. Criando uma nova Account');
                accountId = createAccount(null, null, null, null).Id;
            }
            if (repLegalId == null) {
                System.debug('RepLegalId é nulo. Criando um novo Contato');
                repLegalId = createContact(accountId, null, null, null, null, null).Id;
            }
            String uniqueSuffix = String.valueOf(System.currentTimeMillis()).right(4);
            String safeName = String.isNotBlank(name) ? name : 'Oportunidade Auditoria ' + uniqueSuffix;
            Date safeCloseDate = closeDate != null ? closeDate : Date.today().addDays(30);
            Opportunity opportunity = new Opportunity(
                AccountId = accountId,
                Name = safeName,
                StageName = '075 Auditoria',
                Produto__c = produtoId,
                Rep_Legal__c = repLegalId,
                CloseDate = safeCloseDate,
                Data_Devolucao__c = null,
                Coleta_Fatura_Concluida__c = true,
                Analisando_Proposta_Concluida__c = true,
                Coleta_Docs_Concluida__c = true,
                Validacao_Interna_Concluida__c = true,
                Validacao_Externa_Concluida__c = true,
                Enviar_Minuta_Concluida__c = true,
                Pre_assinatura_Gerador_Concluida__c = true,
                Cliente_Assinando_Concluida__c = true,
                Auditoria_Concluida__c = false,
                SDR__c = 'UserNickName',
                Auditor__c = 'UserNickName'
            );
            insert opportunity;
            System.debug('Oportunidade em Auditoria criada com sucesso: ' + opportunity.Id + ' | Nome: ' + safeName);
            return opportunity;
        } catch (Exception ex) {
            System.debug('Erro ao criar Oportunidade em Auditoria: ' + ex.getMessage());
            throw ex;
        }
    }
    
    
    // Cria uma Proposta associada a uma Oportunidade e Conta
    public static Proposta__c createProposta(Id opportunityId) {
        System.debug('Iniciando criação de proposta');
        try {
            if (opportunityId == null) {
                System.debug('OpportunityId é nulo. Criando uma nova Oportunidade');
                opportunityId = createOpportunity(null, null, null).Id;
            }
            String uniqueSuffix = String.valueOf(System.currentTimeMillis()).right(4);
            String safeNumeroInstalacao = String.valueOf(System.currentTimeMillis()).right(8);
            String safeLogin = 'login_teste';
            String safeSenha = 'senha_teste';
            Proposta__c proposta = new Proposta__c( Oportunidade__c = opportunityId,
                Numero_da_Instalacao__c = safeNumeroInstalacao, Distribuidora_Login__c = safeLogin, Distribuidora_Senha__c = safeSenha
            );
            insert proposta;
            System.debug('Proposta criada com sucesso: ' + proposta.Id + ' | Número da Instalação: ' + safeNumeroInstalacao);
            return proposta;
        } catch (Exception ex) {
            System.debug('Erro ao criar Proposta: ' + ex.getMessage());
            throw ex;
        }
    }    


    public static Documento_da_Conta__c createDocConta(Id contaId, String nome, String tipo, String link) {
        System.debug('Iniciando criação de documento da conta');
        try {
            if (contaId == null) {
                System.debug('ContaId é nulo. Criando uma nova Conta');
                contaId = createAccount(null, null, null, null).Id;
            }
            String uniqueSuffix = String.valueOf(System.currentTimeMillis()).right(4);
            String safeTipo = String.isNotBlank(tipo) ? tipo : 'Cartão CNPJ';
            String safeNome = String.isNotBlank(nome) ? nome : 'Documento Conta ' + uniqueSuffix;
            String safeLink = String.isNotBlank(link) ? link : 'https://default-link.com';
            Documento_da_Conta__c docConta = new Documento_da_Conta__c( Conta__c = contaId,
                    Nome__c = safeNome, Tipo__c = safeTipo, Link__c = safeLink, Ativo__c = true
            );
            
            insert docConta;
            System.debug('Documento da Conta criado com sucesso: ' + docConta.Id + ' | Nome: ' + safeNome);
            return docConta;
        } catch (Exception ex) {
            System.debug('Erro ao criar Documento da Conta: ' + ex.getMessage());
            throw ex;
        }
    }
    

    public static Documento_do_Contato__c createDocContato(Id contatoId, String nome, String tipo, String link) {
        System.debug('Iniciando criação de documento do contato');
        try {
            if (contatoId == null) {
                System.debug('ContatoId é nulo. Criando um novo Contato');
                contatoId = createContact(null, null, null, null, null, null).Id;
            }
            String uniqueSuffix = String.valueOf(System.currentTimeMillis()).right(4);
            String safeTipo = String.isNotBlank(tipo) ? tipo : 'Identificação';
            String safeNome = String.isNotBlank(nome) ? nome : 'Documento Contato ' + uniqueSuffix;
            String safeLink = String.isNotBlank(link) ? link : 'https://default-link.com';
            Documento_do_Contato__c docContato = new Documento_do_Contato__c(Contato__c = contatoId,
                        Nome__c = safeNome, Tipo__c = safeTipo, Link__c = safeLink, Ativo__c = true
            );
            insert docContato;
            System.debug('Documento do Contato criado com sucesso: ' + docContato.Id + ' | Nome: ' + safeNome);
            return docContato;
        } catch (Exception ex) {
            System.debug('Erro ao criar Documento do Contato: ' + ex.getMessage());
            throw ex;
        }
    }
    

    // Função para criar Documento da Proposta
    public static Documento_da_Proposta__c createDocProposta(Id propostaId, String nome, String tipo, String link) {
        System.debug('Iniciando criação de documento da proposta');
        try {
            if (propostaId == null) {
                System.debug('PropostaId é nulo. Criando uma nova Proposta');
                propostaId = createProposta(null).Id;
            }
            String uniqueSuffix = String.valueOf(System.currentTimeMillis()).right(4);
            String safeTipo = String.isNotBlank(tipo) ? tipo : 'Fatura';
            String safeNome = String.isNotBlank(nome) ? nome : 'Documento Proposta ' + uniqueSuffix;
            String safeLink = String.isNotBlank(link) ? link : 'https://default-link.com';
            Documento_da_Proposta__c docProposta = new Documento_da_Proposta__c(
                Proposta__c = propostaId,
                Nome__c = safeNome,
                Tipo__c = safeTipo,
                Link__c = safeLink,
                Ativo__c = true
            );
            insert docProposta;
            System.debug('Documento da Proposta criado com sucesso: ' + docProposta.Id + ' | Nome: ' + safeNome);
            return docProposta;
        } catch (Exception ex) {
            System.debug('Erro ao criar Documento da Proposta: ' + ex.getMessage());
            throw ex;
        }
    }
    

    public static Documento_da_Oportunidade__c createDocOportunidade(Id oportunidadeId, String nome, String link) {
        System.debug('Iniciando criação de documento da oportunidade');
        try {
            if (oportunidadeId == null) {
                System.debug('OportunidadeId é nulo. Criando uma nova Oportunidade');
                oportunidadeId = createOpportunity(null, null, null).Id;
            }
            String uniqueSuffix = String.valueOf(System.currentTimeMillis()).right(4);
            String safeNome = String.isNotBlank(nome) ? nome : 'Documento Oportunidade ' + uniqueSuffix;
            String safeLink = String.isNotBlank(link) ? link : 'https://default-link.com';
            Documento_da_Oportunidade__c docOportunidade = new Documento_da_Oportunidade__c(
                Oportunidade__c = oportunidadeId,
                Filename__c = safeNome,
                Link__c = safeLink,
                Document_Key__c = 'ba9f1398-5a59-463f-8271-d11486bf'+uniqueSuffix,
                Ativo__c = true
            );
            insert docOportunidade;
            System.debug('Documento da Oportunidade criado com sucesso: ' + docOportunidade.Id + ' | Nome: ' + safeNome);
            return docOportunidade;
        } catch (Exception ex) {
            System.debug('Erro ao criar Documento da Oportunidade: ' + ex.getMessage());
            throw ex;
        }
    }

    public static Signatario_do_Gerador__c createSignatarioGerador(Id geradorId, Id contatoId) {
        System.debug('📌 [START] Criando Signatario_do_Gerador');
    
        try {
            if (geradorId == null) {
                System.debug('⚠ Nenhum Gerador fornecido. Criando um novo...');
                Gerador__c novoGerador = createGerador(null);
                geradorId = novoGerador.Id;
            }
            if (contatoId == null) {
                System.debug('⚠ ContatoId é nulo. Criando um novo contato...');
                contatoId = createContact(null, null, null, null, null, null).Id;
            }
    
            Signatario_do_Gerador__c signatarioGerador = new Signatario_do_Gerador__c(
                Gerador__c = geradorId,
                Contato__c = contatoId,
                Ordem__c = 1,
                Fase__c = 'Stella',
                Papel__c = 'procurador',
                Metodo_de_Assinatura__c = 'email',
                Telefone__c = '5521996554580'
            );
    
            insert signatarioGerador;
            System.debug('✅ Signatario_do_Gerador criado com sucesso! ID: ' + signatarioGerador.Id);
            return signatarioGerador;
        } catch (Exception ex) {
            System.debug('❌ ERRO ao criar Signatario_do_Gerador: ' + ex.getMessage());
            throw ex;
        }
    }
    
    public static Signatario_da_Oportunidade__c createSignatarioOportunidade(Id docOportunidadeId, Id contatoId) {
        System.debug('📌 [START] Criando Signatario_da_Oportunidade');
        Documento_da_Oportunidade__c docOportunidade;
        try {
            if (docOportunidadeId == null) {
                System.debug('⚠ Nenhuma docOportunidadeId fornecida. Criando uma nova...');
                docOportunidade = createDocOportunidade(null, null, null);
                docOportunidadeId = docOportunidade.Id;
            }
            if (contatoId == null) {
                System.debug('⚠ ContatoId é nulo. Criando um novo contato...');
                Contact contato = createContact(null, null, null, null, null, null);
                contatoId = contato.Id;
            }
            docOportunidade = [SELECT Oportunidade__c FROM Documento_da_Oportunidade__c WHERE Id = :docOportunidadeId LIMIT 1];
            Signatario_da_Oportunidade__c signatarioOportunidade = new Signatario_da_Oportunidade__c(
                Documento_da_Oportunidade__c = docOportunidadeId,
                Oportunidade__c = docOportunidade.Oportunidade__c,
                Contato__c = contatoId,
                Batch_Request_Signature_Key__c = 'batchsignerkeytest',
                Request_Signature_Key__c = 'resginerkeytest',
                Fase__c = 'Stella',
                Link_para_assinatura__c = 'www.globo.com',
                Plataforma_de_Assinatura_Nome__c = 'Clicksign',
                Papel__c = 'parte',
                Metodo_de_Assinatura__c = 'email',
                Ordem__c = 1,
                Signer_Key__c = 'b48c3965-9dbe-47cc-85c3-2ffe42724a22'
            );
    
            insert signatarioOportunidade;
            System.debug('✅ Signatario_da_Oportunidade criado com sucesso! ID: ' + signatarioOportunidade.Id);
            return signatarioOportunidade;
        } catch (Exception ex) {
            System.debug('❌ ERRO ao criar Signatario_da_Oportunidade: ' + ex.getMessage());
            throw ex;
        }
    }
     
    
    public static Contrato_de_Adesao__c createContratoDeAdesao(Id contaId, Id repLegalId, Id veiculoId) {
        System.debug('Iniciando criação de contrato de adesão');
        try {
            if (contaId == null) {
                System.debug('ContaId é nulo. Criando uma nova Conta');
                contaId = createAccount(null, null, null, null).Id;
            }
            if (repLegalId == null) {
                System.debug('RepLegalId é nulo. Criando um novo Contato');
                repLegalId = createContact(contaId, null, null, null, null, null).Id;
            }
            if (veiculoId == null) {
                System.debug('VeiculoId é nulo. Criando um novo Veículo');
                veiculoId = createVeiculo(null, null).Id;
            }
            Contrato_de_Adesao__c contrato = new Contrato_de_Adesao__c(Conta2__c = contaId, Rep_Legal__c = repLegalId, Veiculo__c = veiculoId);
            insert contrato;
            System.debug('Contrato de Adesão criado com sucesso: ' + contrato.Id);
            return contrato;
        } catch (Exception ex) {
            System.debug('Erro ao criar Contrato de Adesão: ' + ex.getMessage());
            throw ex;
        }
    }
    

    // Cria uma UC associada a Contrato de Adesão e outros objetos, com entradas opcionais para Conta, Distribuidora, Gerador, Originador, Proposta, Rep_Legal e Vertical
    public static UC__c createUC(Id contratoId, Id produtoId, Id propostaId) {
        System.debug('Iniciando criação de UC (Unidade Consumidora)');
        try {
            if (contratoId == null) {
                System.debug('ContratoId é nulo. Criando um novo Contrato de Adesão');
                contratoId = createContratoDeAdesao(null, null, null).Id;
            }
            if (produtoId == null) {
                System.debug('ProdutoId é nulo. Criando um novo Produto do Gerador');
                produtoId = createProdutoDoGerador(null, null, null, null).Id;
            }
            String uniqueSuffix = String.valueOf(System.currentTimeMillis()).right(8);

            // Criando a UC
            UC__c uc = new UC__c(
                Contrato_de_Adesao__c = contratoId
                , Titular__c = 'Ttular Teste ' + uniqueSuffix
                , CPF_CNPJ__c = '343637710001'+String.valueOf(System.currentTimeMillis()).right(2)
                , Produto__c = produtoId
                , Numero_da_Instalacao__c = uniqueSuffix
                , Logradouro__c = 'Rua da Conta', Numero__c = 'Numero da Conta 123', Complemento__c = 'Complemento da Conta'
                , Bairro__c = 'Bairro da Conta', Cidade__c = 'Cidade da Conta', UF__c = 'RJ', CEP__c = '224404032'
                , kWh_Contratado__c = 1000
            );
            
            insert uc;
            System.debug('UC criada com sucesso: ' + uc.Id + ' | Número da Instalação: ' + uniqueSuffix);
            return uc;
        } catch (Exception ex) {
            System.debug('Erro ao criar UC: ' + ex.getMessage());
            throw ex;
        }
    }
    

    // Cria uma Cobrança associada a uma UC, com entradas opcionais para data de vencimento, valor e status
    public static Cobranca__c createCobranca(Id ucId, Date dataVencimento, Decimal valor, String status) {
        System.debug('Iniciando criação de cobrança');
        try {
            if (ucId == null) {
                System.debug('UCId é nulo. Criando uma nova UC');
                ucId = createUC(null, null, null).Id;
            }
            Date safeDataVencimento = dataVencimento != null ? dataVencimento : Date.today().addMonths(1);
            Decimal safeValor = valor != null ? valor : 1000.00;
            String safeStatus = String.isNotBlank(status) ? status : 'Regular';
            
            // Criando a cobrança
            Cobranca__c cobranca = new Cobranca__c(
                UC__c = ucId,
                Mes_de_Referencia__c = Date.today(),
                Data_Emissao__c = Date.today(),
                Data_Vencimento__c = safeDataVencimento,
                Valor_Cobranca_Verde__c = safeValor,
                kWh_Energia_Cobrada__c = safeValor,
                Tarifa_Gerador__c = 1,
                kWh_Saldo__c = 100,
                Status__c = safeStatus,
                Juros_a_Mes__c = 1
            );
            insert cobranca;
            System.debug('Cobrança criada com sucesso: ' + cobranca.Id + ' | Valor: ' + safeValor + ' | Status: ' + safeStatus);
            return cobranca;
        } catch (Exception ex) {
            System.debug('Erro ao criar Cobrança: ' + ex.getMessage());
            throw ex;
        }
    }

    public static Case createCase(Id ucId) {
        System.debug('Iniciando criação de case');
        try {
            if (ucId == null) {
                System.debug('UCId é nulo. Criando uma nova UC');
                ucId = TestDataSetup.createUC(null, null, null).Id;
            }
            
            UC__c uc = [SELECT Id, Rep_Legal__c, Conta__c FROM UC__c WHERE Id = :ucId LIMIT 1];

            String testUserId = (UserInfo.getUserId() == null) ? createUser(null, null, null, null, null).Id : UserInfo.getUserId();
            
            Case caseRecord = new Case(
                UC__c = uc.Id
                , ContactId = uc.Rep_Legal__c
                , Email__c = 'admin.salesforce@stellaenergia.com.br'
                , Telefone__c = '5521999999999'
                , AccountId = uc.Conta__c
                , Tipo_contato__c = 'Titular'
                , Origin = 'Whatsapp'
                , Subject = 'Assunto teste'
                , Description = 'Descrição teste'
                , Tipo_do_Case__c = 'Case Externo'
                , Status = 'Em Aberto'
                , Data_agendado__c = Date.today()
                , Responsavel_Tratamento__c = testUserId
            );
            
            insert caseRecord;
            System.debug('Case criado com sucesso: ' + caseRecord.Id);
            return caseRecord;
        } catch (Exception ex) {
            System.debug('Erro ao criar Case: ' + ex.getMessage());
            throw ex;
        }
    }
     
    
    public static Map<String, SObject> setupCompleteEnvironment() {
        System.debug('📌 [START] Configuração completa do ambiente de testes');
        Map<String, SObject> createdRecords = new Map<String, SObject>();
    
        try {
            // Criando os registros
            User user = createUser(null,null,null,null,null);
            Configuracoes__c responsavel = createResponsavel(null);
            Vertical__c vertical = createVertical('Ultragaz Energia');
            Originador__c originadorPai = createOriginador(vertical.Id, null);
            Originador__c originadorFilho = createOriginadorFilho(vertical.Id, null, originadorPai.Id);
            Distribuidora__c distribuidora = createDistribuidora(null, null);
            Tarifa_Distribuidora__c tarifaDistribuidora = createTarifaDistribuidora(distribuidora);
            Gerador__c gerador = createGerador(null);
            Veiculo__c veiculo = createVeiculo(gerador.Id, null);
            Plataforma_de_Cobranca__c plataformaCobranca = createPlataformaCobranca(veiculo.Id, 'itau');
            Produto_do_Gerador__c produtoGerador = createProdutoDoGerador(vertical.Id, veiculo.Id, distribuidora.Id, plataformaCobranca.Id);
            Lead leadPF = createLeadPfQualificando(originadorPai.Id, distribuidora.Id);
            Lead leadPJ = createLeadPjQualificando(originadorFilho.Id, distribuidora.Id, null);
            Account account = createAccount(vertical.Id, originadorFilho.Id, null, '34.363.771/0001-65');
            Documento_da_Conta__c docConta = createDocConta(account.Id, null, null, null);
            Contact contact = createContact(account.Id, null, null, null, null, null);
            Documento_do_Contato__c docContato = createDocContato(contact.Id, null, null, null);
            Opportunity opportunity = createOpportunity(account.Id, produtoGerador.Id, contact.Id);
            Proposta__c proposta = createProposta(opportunity.Id);
            Documento_da_Proposta__c docProposta = createDocProposta(proposta.Id, null, null, null);
            Signatario_do_Gerador__c signatarioGerador = createSignatarioGerador(gerador.Id, contact.Id);
            Documento_da_Oportunidade__c docOportunidade = createDocOportunidade(opportunity.Id, null, null);
            Signatario_da_Oportunidade__c signatarioOportunidade = createSignatarioOportunidade(docOportunidade.Id, contact.Id);
            Contrato_de_Adesao__c contratoAdesao = createContratoDeAdesao(account.Id, contact.Id, veiculo.Id);
            UC__c uc = createUC(contratoAdesao.Id, produtoGerador.Id, proposta.Id);
            Cobranca__c cobranca = createCobranca(uc.Id, null, 1000, null);
            Case caseUc = createCase(uc.Id);
            Task task = createTask(null,null,null);


    
            // ✅ Adicionando TODOS os registros ao Map para evitar NullPointerException
            createdRecords.put('User', user);
            createdRecords.put('Responsavel', responsavel);
            createdRecords.put('Task', task);
            createdRecords.put('Vertical', vertical);
            createdRecords.put('OriginadorPai', originadorPai);
            createdRecords.put('OriginadorFilho', originadorFilho);
            createdRecords.put('Distribuidora', distribuidora);
            createdRecords.put('TarifaDistribuidora', tarifaDistribuidora);
            createdRecords.put('Gerador', gerador);
            createdRecords.put('Veiculo', veiculo);
            createdRecords.put('PlataformaCobranca', plataformaCobranca);
            createdRecords.put('ProdutoGerador', produtoGerador);
            createdRecords.put('LeadPF', leadPF);
            createdRecords.put('LeadPJ', leadPJ);
            createdRecords.put('Account', account);
            createdRecords.put('DocConta', docConta);
            createdRecords.put('Contact', contact);
            createdRecords.put('DocContato', docContato);
            createdRecords.put('Opportunity', opportunity);
            createdRecords.put('Proposta', proposta);
            createdRecords.put('DocProposta', docProposta);
            createdRecords.put('SignatarioGerador', signatarioGerador);
            createdRecords.put('DocOportunidade', docOportunidade);
            createdRecords.put('SignatarioOportunidade', signatarioOportunidade);
            createdRecords.put('ContratoAdesao', contratoAdesao);
            createdRecords.put('UC', uc);
            createdRecords.put('Cobranca', cobranca);
            createdRecords.put('Case', caseUc);

    
            System.debug('✅ Configuração completa do ambiente finalizada!');
            return createdRecords;
        } catch (Exception ex) {
            System.debug('❌ Erro na configuração do ambiente de testes: ' + ex.getMessage());
            throw ex;
        }
    }
    
    
    // Método de limpeza: exclui todos os registros criados
    public static void cleanUp(List<SObject> records) {
        Logger.log(Logger.LogLevel.DEBUG, 'Iniciando limpeza de registros', 'cleanUp', null);
    
        try {
            if (records == null || records.isEmpty()) {
                Logger.log(Logger.LogLevel.WARNING, 'Nenhum registro fornecido para limpeza', 'cleanUp', null);
                return;
            }
    
            delete records;
            Logger.log(Logger.LogLevel.INFO, 'Registros excluídos com sucesso: ' + records.size(), 'cleanUp', null);
        } catch (Exception ex) {
            Logger.log(Logger.LogLevel.ERROR, 'Erro ao limpar registros', 'cleanUp', ex);
            throw ex;
        }
    }
    
}
