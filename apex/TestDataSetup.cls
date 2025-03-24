# 🧱 Guia Rigoroso de TestDataSetup (Versão Estendida 2025)

> 🌐 Base: https://bit.ly/TestDataSetup

📎 Consulte também:
- 📘 [Guia de Revisão Apex](https://bit.ly/GuiaApexRevisao)
- 🧪 [Guia de Testes Apex](https://bit.ly/GuiaTestsApex)
- 🧪 [Guia de Logger](https://bit.ly/GuiaLoggerApex)
- 🔁 [Guia de Refatoração](https://bit.ly/ComparacaoApex)
- ✅ [Confirmação de Equivalência Funcional](https://bit.ly/ConfirmacaoApex)

---

## ✅ Objetivo
Definir padrões obrigatórios para criação de dados de teste reutilizáveis, centralizados e rastreáveis.

TestDataSetup é a **classe orquestradora principal**, usada por todas as suítes de testes Apex para montar o ambiente mínimo e completo.

---

## ⚙️ Regras Obrigatórias

### 1. Apenas `@TestSetup` pode invocar `setupCompleteEnvironment()`
- ❌ **Nunca** chamar `setupCompleteEnvironment()` dentro de métodos de teste individuais
- ✅ Cada método de teste deve fazer `SELECT` para buscar os registros criados
- ❌ Nunca reutilizar o `Map<String, SObject>` retornado pelo setup

### 2. A estrutura de dados criada deve cobrir:
- Usuário, Vertical, Originadores, Distribuidora, Produto, Usina, Lead, Conta, Contato, Oportunidade, Proposta, Documentos, UC, Cobrança, etc.

### 3. Toda lógica de criação de objetos deve ser delegada para `*TestDataSetup` especializados
- Exemplo: `UserTestDataSetup`, `LeadTestDataSetup`, `GeradorTestDataSetup`

### 4. Usar sempre `LoggerHelper.logInfo(...)` para rastreabilidade

### 5. Todos os métodos devem ser `@TestVisible`

---

## 🧪 Uso padrão nos testes

```apex
@TestSetup
static void setupTestData() {
    TestDataSetup.setupCompleteEnvironment();
    FlowControlManager.disableFlows();
}
```

```apex
@isTest
static void meuTeste() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    // seguir com lógica do teste...
}
```

---

## 🧩 Boas práticas

### 🧠 Nomenclatura das chaves no `Map<String, SObject>`
- Sempre use nomes padronizados e sem ambiguidades:
  - `'Account'`, `'Contact'`, `'Opportunity'`, `'LeadPF'`, `'Distribuidora'`, `'Produto'`, etc.

### ⚠️ `Map<String, SObject>` não deve ser reutilizado entre métodos
- Ele só serve para validação rápida em ambiente controlado

### 💡 Otimize com cache estático local em `*TestDataSetup` especializados
- Evite `SOQL` repetitivo: cacheie `RecordType`, `Profile`, etc.

---

## 📄 Estrutura obrigatória da classe TestDataSetup

### 1. Topo com variáveis padrão
```apex
public static final String environment = 'test';
public static final Logger.LogLevel log_level = Logger.LogLevel.DEBUG;
public static final String className = 'TestDataSetup';
public static final String triggerType = 'test';
public static final String logCategory = 'test-data';
```

### 2. Método principal de orquestração
```apex
@TestVisible
public static Map<String, SObject> setupCompleteEnvironment() {
    // Criação de objetos, delegando para classes auxiliares
    // Inserções e adições no Map<String, SObject>
    return createdRecords;
}
```

### 3. Métodos auxiliares (override de Label, cleanup, mocks)
```apex
@TestVisible
public static void overrideLabel(String labelName, String value) {...}

@TestVisible
public static void cleanUp(List<SObject> records) {...}
```

---

## 🧾 Checklist para `TestDataSetup.cls`
- [ ] Possui `setupCompleteEnvironment()` anotado com `@TestVisible`
- [ ] Usa `LoggerHelper` para todos os logs
- [ ] Não tem lógica de criação de objeto inline (usa `*TestDataSetup`)
- [ ] Não é usada fora do `@TestSetup`
- [ ] Todos os dados têm SELECT possível (sem depender de Map)
- [ ] Classe define: `environment`, `log_level`, `className`, `triggerType`, `logCategory`

---

## Conteúdo explícito da versão atual de TestDataSetup.cls (devemos sempre manter o guia atualizado)

@isTest
public class TestDataSetup {

    /**
     * Classe orquestradora principal responsável por montar o ambiente de teste completo
     * utilizado em todos os testes de integração e APIs.
     *
     * Todos os dados retornados no `Map<String, SObject>` podem ser acessados nos testes por chave.
     */

    public static final String environment = 'test';
    public static final Logger.LogLevel log_level = Logger.LogLevel.DEBUG;
    public static final String className = 'TestDataSetup';
    public static final String triggerType = 'test';
    public static final String logCategory = 'test-data';
    private static final String MOCK_DOMINIO = 'https://mock-dominio.com';
    private static final String MOCK_URL     = 'https://mock-token.com/oauth';


    public class TestSetupException extends Exception {}

    private static Map<String, String> testLabels = new Map<String, String>();

    @TestVisible
    public static void overrideLabel(String labelName, String value) {
        if (Test.isRunningTest()) {
            LoggerHelper.logInfo('Substituindo Label em teste: ' + labelName + ' = ' + value, className, 'overrideLabel', logCategory);
            testLabels.put(labelName, value);
        } else {
            throw new TestSetupException('Override de Label não permitido em produção.');
        }
    }

    @TestVisible
    public static String getLabel(String labelName) {
        return testLabels.containsKey(labelName) ? testLabels.get(labelName) : null;
    }

    @TestVisible
    public static Integracao__c createIntegracao() {
        LoggerHelper.logInfo('Criando registro de Integracao__c', className, 'createIntegracao', logCategory);
    
        try {
            Integracao__c integracao = new Integracao__c(
                Dominio__c     = 'https://mock-dominio.com',
                clientId__c    = 'mockClientId'+String.valueOf(System.currentTimeMillis()).right(8),
                clientSecret__c = 'mockClientSecret'+String.valueOf(System.currentTimeMillis()).right(8),
                username__c    = 'usuario'+String.valueOf(System.currentTimeMillis()).right(8),
                password__c    = 'senha'+String.valueOf(System.currentTimeMillis()).right(8),
                url__c         = 'https://mock-token.com/oauth'
            );
            insert integracao;
    
            LoggerHelper.logInfo('Integracao__c criado com sucesso: ' + integracao.Id, className, 'createIntegracao', logCategory);
            return integracao;
    
        } catch (Exception ex) {
            LoggerHelper.logError('Erro ao criar Integracao__c', className, 'createIntegracao', ex, logCategory);
            throw ex;
        }
    }

    @TestVisible
    public static Map<String, SObject> setupCompleteEnvironment() {
        LoggerHelper.logInfo('📌 [START] setupCompleteEnvironment', className, 'setupCompleteEnvironment', logCategory);

        Map<String, SObject> createdRecords = new Map<String, SObject>();

        try {
            // 🧑‍💼 Usuário e Responsável
            User user = UserTestDataSetup.createUser();
            Configuracoes__c responsavel = ResponsavelTestDataSetup.createResponsavel(user.Id);
            //Integracao__c integracao = createIntegracao();


            // 🏢 Vertical e Originadores
            Vertical__c vertical = VerticalTestDataSetup.createVertical('Ultragaz Energia');
            Originador__c originadorPai = OriginadorTestDataSetup.createOriginador(vertical.Id, null);
            Originador__c originadorFilho = OriginadorTestDataSetup.createOriginadorFilho(vertical.Id, null, originadorPai.Id);

            // ⚡ Distribuidora e Tarifa
            Distribuidora__c distribuidora = DistribuidoraTestDataSetup.createDistribuidora();
            Tarifa_Distribuidora__c tarifa = DistribuidoraTestDataSetup.createTarifaDistribuidora(distribuidora);

            // 🔋 Gerador e Produto
            Gerador__c gerador = GeradorTestDataSetup.createGerador();
            Veiculo__c veiculo = GeradorTestDataSetup.createVeiculo(gerador.Id, null);
            Plataforma_de_Cobranca__c plataforma = GeradorTestDataSetup.createPlataformaCobranca(veiculo.Id, 'itau');
            Produto_do_Gerador__c produto = GeradorTestDataSetup.createProdutoDoGerador(vertical.Id, veiculo.Id, distribuidora.Id, plataforma.Id);

            // Usina
            Usina__c usina = UsinaTestDataSetup.createUsina(distribuidora.Id, gerador.Id, veiculo.Id);
            
            // 🧪 Leads
            Lead leadPF = LeadTestDataSetup.createLeadPfQualificando(originadorPai.Id, distribuidora.Id);
            Lead leadPJ = LeadTestDataSetup.createLeadPjQualificando(originadorFilho.Id, distribuidora.Id, null);

            // 👤 Conta e Contato
            Account account = AccountTestDataSetup.createAccount(vertical.Id, originadorFilho.Id, null, '34.363.771/0001-65');
            Contact contact = AccountTestDataSetup.createContact(account.Id, null, null, null, null, null);

            // 💼 Oportunidade e Proposta
            Opportunity opportunity = OpportunityTestDataSetup.createOpportunity(account.Id, produto.Id, contact.Id);
            Proposta__c proposta = PropostaTestDataSetup.createProposta(opportunity.Id);

            // 📎 Documentos
            Documento_da_Conta__c docConta = DocumentoTestDataSetup.createDocConta(account.Id, null, null, null);
            Documento_do_Contato__c docContato = DocumentoTestDataSetup.createDocContato(contact.Id, null, null, null);
            Documento_da_Proposta__c docProposta = DocumentoTestDataSetup.createDocProposta(proposta.Id, null, null, null);
            Documento_da_Oportunidade__c docOportunidade = DocumentoTestDataSetup.createDocOportunidade(opportunity.Id, null, null);

            // ✍️ Assinaturas
            Signatario_do_Gerador__c signGerador = SignatarioTestDataSetup.createSignatarioGerador(gerador.Id, contact.Id);
            Signatario_da_Oportunidade__c signOpp = SignatarioTestDataSetup.createSignatarioOportunidade(docOportunidade.Id, contact.Id);

            // 🔗 Contrato e UC
            Contrato_de_Adesao__c contrato = UcTestDataSetup.createContratoDeAdesao(account.Id, contact.Id, veiculo.Id);
            UC__c uc = UcTestDataSetup.createUC(contrato.Id, produto.Id, proposta.Id);
            Contato_da_UC__c contatoDaUc = UcTestDataSetup.createContatoDaUC(uc.Id, uc.Rep_Legal__c, null);

            // 💰 Cobrança e 📞 Atendimento
            Cobranca__c cobranca = CobrancaTestDataSetup.createCobranca(uc.Id, null, 1000, null);
            Case caseRecord = CaseTestDataSetup.createCase(uc.Id);

            // ✅ Preenchendo o mapa de retorno
            createdRecords.put('User', user);
            createdRecords.put('Responsavel', responsavel);
            // createdRecords.put('Integracao', integracao);
            createdRecords.put('Vertical', vertical);
            createdRecords.put('Originador', originadorPai);
            createdRecords.put('OriginadorPai', originadorPai);
            createdRecords.put('OriginadorFilho', originadorFilho);
            createdRecords.put('Distribuidora', distribuidora);
            createdRecords.put('TarifaDistribuidora', tarifa);
            createdRecords.put('Gerador', gerador);
            createdRecords.put('Veiculo', veiculo);
            createdRecords.put('Plataforma', plataforma);
            createdRecords.put('Produto', produto);
            createdRecords.put('Usina', usina);
            createdRecords.put('LeadPF', leadPF);
            createdRecords.put('LeadPJ', leadPJ);
            createdRecords.put('Account', account);
            createdRecords.put('Contact', contact);
            createdRecords.put('Opportunity', opportunity);
            createdRecords.put('Proposta', proposta);
            createdRecords.put('DocConta', docConta);
            createdRecords.put('DocContato', docContato);
            createdRecords.put('DocProposta', docProposta);
            createdRecords.put('DocOportunidade', docOportunidade);
            createdRecords.put('SignatarioGerador', signGerador);
            createdRecords.put('SignatarioOportunidade', signOpp);
            createdRecords.put('Contrato', contrato);
            createdRecords.put('UC', uc);
            createdRecords.put('ContatoDaUc', contatoDaUc);
            createdRecords.put('Cobranca', cobranca);
            createdRecords.put('Case', caseRecord);

            LoggerHelper.logInfo('✅ Ambiente de teste completo configurado.', className, 'setupCompleteEnvironment', logCategory);
            return createdRecords;

        } catch (Exception ex) {
            LoggerHelper.logError('❌ Erro ao configurar ambiente de testes', className, 'setupCompleteEnvironment', ex, logCategory);
            throw ex;
        }
    }

    @TestVisible
    public static void cleanUp(List<SObject> records) {
        LoggerHelper.logInfo('Iniciando limpeza de registros', className, 'cleanUp', logCategory);

        try {
            if (records == null || records.isEmpty()) {
                LoggerHelper.logInfo('Nenhum registro fornecido para limpeza.', className, 'cleanUp', logCategory);
                return;
            }

            delete records;
            LoggerHelper.logInfo('Registros excluídos com sucesso: ' + records.size(), className, 'cleanUp', logCategory);

        } catch (Exception ex) {
            LoggerHelper.logError('Erro ao limpar registros', className, 'cleanUp', ex, logCategory);
            throw ex;
        }
    }
}
