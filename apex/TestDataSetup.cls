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
- ❌ Nunca usar Logger nas classes *TestDataSetup.cls e *TestDataSetupTest.cls
- ❌ Nenhum método setup deve tentar logar mensagens com assert nos testes

### 2. A estrutura de dados criada deve cobrir:
- Usuário, Vertical, Originadores, Distribuidora, Produto, Usina, Lead, Conta, Contato, Oportunidade, Proposta, Documentos, UC, Cobrança, etc.

### 3. Toda lógica de criação de objetos deve ser delegada para `*TestDataSetup` especializados
- Exemplo: `UserTestDataSetup`, `LeadTestDataSetup`, `GeradorTestDataSetup`

### ❌ Nunca usar Logger nas classes *TestDataSetup.cls e *TestDataSetupTest.cls. Como exceção pode ser System.dubeg() nesses casos específicos.

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
    Não necessário nos testes

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
- [ ] Não usa `Logger`, mas como exceção pode usar System.Debug()
- [ ] Não tem lógica de criação de objeto inline (usa `*TestDataSetup`)
- [ ] Não é usada fora do `@TestSetup`
- [ ] Todos os dados dos métodos unitários têm SELECT possível (sem depender de Map criado no @TestSetup)

---

## Conteúdo explícito da versão atual de TestDataSetup.cls (devemos sempre manter o guia atualizado)

// @isTest
public class TestDataSetup {

    private static final String MOCK_DOMINIO = 'https://mock-dominio.com';
    private static final String MOCK_URL     = 'https://mock-token.com/oauth';

    @TestVisible
    public class TestSetupException extends Exception {}

    @TestVisible
    private static Map<String, String> testLabels = new Map<String, String>();

    @TestVisible
    public static void overrideLabel(String labelName, String value) {
        if (Test.isRunningTest()) {
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

        try {
            List<Integracao__c> existentes = [SELECT Id FROM Integracao__c LIMIT 1];

            if (!existentes.isEmpty()) {
                return existentes[0];
            }

            Integracao__c integracao = new Integracao__c(
                Dominio__c       = MOCK_DOMINIO,
                clientId__c      = 'mockClientId' + String.valueOf(System.currentTimeMillis()).right(8),
                clientSecret__c  = 'mockSecret'   + String.valueOf(System.currentTimeMillis()).right(8),
                username__c      = 'usuario'      + String.valueOf(System.currentTimeMillis()).right(8),
                password__c      = 'senha'        + String.valueOf(System.currentTimeMillis()).right(8),
                url__c           = MOCK_URL
            );

            insert integracao;
            return integracao;

        } catch (Exception ex) {
            throw ex;
        }
    }

    @TestVisible
    public static Map<String, SObject> setupCompleteEnvironment() {

        Map<String, SObject> createdRecords = new Map<String, SObject>();

        try {
            User user = UserTestDataSetup.createUser();
            Configuracoes__c responsavel = ResponsavelTestDataSetup.createResponsavel(user.Id);
            Integracao__c integracao = createIntegracao();

            Vertical__c vertical = VerticalTestDataSetup.createVertical('Ultragaz Energia');
            Originador__c originadorPai = OriginadorTestDataSetup.createOriginador(vertical.Id, null);
            Originador__c originadorFilho = OriginadorTestDataSetup.createOriginadorFilho(vertical.Id, null, originadorPai.Id);

            Distribuidora__c distribuidora = DistribuidoraTestDataSetup.createDistribuidora();
            Tarifa_Distribuidora__c tarifa = DistribuidoraTestDataSetup.createTarifaDistribuidora(distribuidora);

            Gerador__c gerador = GeradorTestDataSetup.createGerador();
            Veiculo__c veiculo = GeradorTestDataSetup.createVeiculo(gerador.Id, null);
            Plataforma_de_Cobranca__c plataforma = GeradorTestDataSetup.createPlataformaCobranca(veiculo.Id, 'itau');
            Produto_do_Gerador__c produto = GeradorTestDataSetup.createProdutoDoGerador(vertical.Id, veiculo.Id, distribuidora.Id, plataforma.Id);
            
            Usina__c usina = UsinaTestDataSetup.createUsina(distribuidora.Id, gerador.Id, veiculo.Id);
            Fatura_da_Usina__c faturaUsina = UsinaTestDataSetup.createFaturaDaUsina(usina.Id, Date.today().toStartOfMonth());
            List<Geracao__c> geracoes = UsinaTestDataSetup.createGeracoesParaUsina(usina.Id, Date.today().addMonths(-2), Date.today());

            Lead leadPF = LeadTestDataSetup.createLeadPfQualificando(originadorPai.Id, distribuidora.Id);
            Lead leadPJ = LeadTestDataSetup.createLeadPjQualificando(originadorFilho.Id, distribuidora.Id, null);

            Account account = AccountTestDataSetup.createAccount(vertical.Id, originadorFilho.Id, null, '34.363.771/0001-65');
            Contact contact = AccountTestDataSetup.createContact(account.Id, null, null, null, null, null);

            Opportunity opportunity = OpportunityTestDataSetup.createOpportunity(account.Id, produto.Id, contact.Id);
            Proposta__c proposta = PropostaTestDataSetup.createProposta(opportunity.Id);
            
            Documento_da_Conta__c docConta = DocumentoTestDataSetup.createDocConta(account.Id, null, null, null);
            Documento_do_Contato__c docContato = DocumentoTestDataSetup.createDocContato(contact.Id, null, null, null);
            Documento_da_Proposta__c docProposta = DocumentoTestDataSetup.createDocProposta(proposta.Id, null, null, null);
            Documento_da_Oportunidade__c docOportunidade = DocumentoTestDataSetup.createDocOportunidade(opportunity.Id, null, null);
            
            Signatario_do_Gerador__c signGerador = SignatarioTestDataSetup.createSignatarioGerador(gerador.Id, contact.Id);
            Signatario_da_Oportunidade__c signOpp = SignatarioTestDataSetup.createSignatarioOportunidade(docOportunidade.Id, contact.Id);
            
            Contrato_de_Adesao__c contrato = UcTestDataSetup.createContratoDeAdesao(account.Id, contact.Id, veiculo.Id);
            UC__c uc = UcTestDataSetup.createUC(contrato.Id, produto.Id, proposta.Id);
            Contato_da_UC__c contatoDaUc = UcTestDataSetup.createContatoDaUC(uc.Id, uc.Rep_Legal__c, null);
            
            Fatura__c faturaUc = UcTestDataSetup.createFatura(uc.Id, Date.today().toStartOfMonth());
            Cobranca__c cobranca = CobrancaTestDataSetup.createCobranca(uc.Id, null, 1000, null);
            
            Case caseRecord = CaseTestDataSetup.createCase(uc.Id);

            createdRecords.put('User', user);
            createdRecords.put('Responsavel', responsavel);
            createdRecords.put('Integracao', integracao);
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
            createdRecords.put('FaturaUC', faturaUc);
            createdRecords.put('FaturaUsina', faturaUsina);
            createdRecords.put('Geracoes', geracoes[0]);

            return createdRecords;

        } catch (Exception ex) {
            throw ex;
        }
    }

    @TestVisible
    public static void cleanUp(List<SObject> records) {

        try {
            if (records == null || records.isEmpty()) {
                return;
            }

            Map<String, List<SObject>> grouped = new Map<String, List<SObject>>();
            for (SObject s : records) {
                String tipo = String.valueOf(s.getSObjectType());
                if (!grouped.containsKey(tipo)) grouped.put(tipo, new List<SObject>());
                grouped.get(tipo).add(s);
            }

            Integer totalDeleted = 0;
            for (List<SObject> listToDelete : grouped.values()) {
                if (!listToDelete.isEmpty()) {
                    String tipo = String.valueOf(listToDelete[0].getSObjectType());
                    if (tipo == 'User') continue;
                    try {
                        delete listToDelete;
                        totalDeleted += listToDelete.size();
                    } catch (DmlException dex) {
                        if (!dex.getMessage().contains('ENTITY_IS_DELETED')) {
                            throw dex;
                        }
                    }
                }
            }

        } catch (Exception ex) {
            throw ex;
        }
    }

    @TestVisible
    public static void fullCleanUpAllSupportedObjects() {

        try {
            List<List<SObject>> batches = new List<List<SObject>>();
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Geracao__c')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Fatura_da_Usina__c')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Fatura__c')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Contato_da_UC__c')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM UC__c')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Contrato_de_Adesao__c')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Documento_da_Oportunidade__c')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Documento_da_Proposta__c')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Documento_do_Contato__c')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Documento_da_Conta__c')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Signatario_da_Oportunidade__c')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Signatario_do_Gerador__c')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Proposta__c')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Opportunity')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Contact')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Account')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Lead')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Usina__c')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Produto_do_Gerador__c')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Plataforma_de_Cobranca__c')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Veiculo__c')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Gerador__c')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Tarifa_Distribuidora__c')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Distribuidora__c')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Originador__c')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Vertical__c')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Configuracoes__c')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Integracao__c')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Case')));
            batches.add(new List<SObject>(Database.query('SELECT Id FROM Cobranca__c')));

            Integer totalDeleted = 0;
            for (List<SObject> listToDelete : batches) {
                if (!listToDelete.isEmpty()) {
                    String tipo = String.valueOf(listToDelete[0].getSObjectType());
                    if (tipo == 'User') continue;
                    try {
                        delete listToDelete;
                        totalDeleted += listToDelete.size();
                    } catch (DmlException dex) {
                        if (!dex.getMessage().contains('ENTITY_IS_DELETED')) {
                            throw dex;
                        }
                    }
                }
            }

        } catch (Exception ex) {
            throw ex;
        }
    }
}
