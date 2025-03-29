Aqui está a versão revisada do **Guia Oficial de Testes Apex** incorporando a estratégia de **variáveis estáticas visíveis** para testar exceções e garantindo um controle rigoroso de falhas. Este capítulo foi adicionado ao guia, de forma que toda a abordagem de exceções, especialmente em cenários de validação, seja clara, rastreável e esteja em conformidade com os padrões Mamba.

---

# 🧪 Guia Oficial de Testes Apex – v2025 (Mentalidade Mamba)

📎 **Shortlink oficial:** [bit.ly/GuiaTestsApex](https://bit.ly/GuiaTestsApex)

> “Teste não é um detalhe. É o seu escudo.” – Mentalidade Mamba 🧠🔥

Este guia define os padrões obrigatórios para escrita de testes Apex com:
- Rastreabilidade
- Fallback seguro
- Dados reais via setup
- Assertivas com mensagens claras

---

## 📚 Referência cruzada obrigatória

- 📘 [Guia Master de Arquitetura](https://bit.ly/GuiaApexMamba)
- 🔍 [Guia de Revisão Apex](https://bit.ly/GuiaApexRevisao)
- 🪵 [Guia de Logger Apex](https://bit.ly/GuiaLoggerApex)
- 🧱 [Guia de TestData Setup](https://bit.ly/TestDataSetup)
- 🔁 [Guia de Comparações](https://bit.ly/ComparacaoApex)
- ✅ [Confirmação de Equivalência](https://bit.ly/ConfirmacaoApex)

---

## ✅ Setup oficial

```apex
@TestSetup
static void setup() {
    TestDataSetup.setupCompleteEnvironment();
    FlowControlManager.disableFlows();
}
```

Nunca chame `setupCompleteEnvironment()` dentro de um `@IsTest` individual. Isso causa dados duplicados e falhas com `DUPLICATE_VALUE`.

---

## ✅ Seleção de dados após o setup

Sempre use `SELECT LIMIT 1` com fallback:

```apex
List<Account> contas = [SELECT Id FROM Account LIMIT 1];
if (contas.isEmpty()) {
    TestHelper.assertSetupCreated('Account');
}
Account acc = contas[0];
```

---

## ✅ Assertivas obrigatórias

Nunca use `System.assert(x != null)` sem mensagem.

```apex
System.assertNotEquals(null, resultado, 'Lead não retornado');
System.assertEquals(2, lista.size(), 'Esperado 2 registros. Obtido: ' + lista.size());
```

---

## ✅ Fallbacks de ID com TestHelper

```apex
Id idInvalido = TestHelper.fakeIdForSafe(UC__c.SObjectType);
```

---

## ❌ Proibições em testes

| Prática                   | Status  | Correto                                       |
|---------------------------|---------|-----------------------------------------------|
| `testData.get(...)`       | ❌      | Use `SELECT` após `@TestSetup`               |
| `RecordHelper.getById` sem fallback | ❌      | Use `List<T> + isEmpty()` ou ID real         |
| `System.debug(...)`       | ❌      | Use Logger apenas se for produção real       |
| `LoggerQueueable` em teste| ❌      | Use `LoggerMock` para suprimir               |
| `setOrgWideEmail...` em sandbox | ⚠️ cuidado | Só se for autorizado no perfil               |

---

## ✅ Teste com falha rastreável

```apex
List<Lead> leads = [SELECT Id FROM Lead WHERE Email != null LIMIT 1];
if (leads.isEmpty()) {
    System.assert(false, 'Nenhum lead com email encontrado.');
}
Lead lead = leads[0];
```

---

## ✅ Teste com email avançado

```apex
LoggerContext.overrideLogger(new LoggerMock());

Send_Email_Avancado.Inputs input = new Send_Email_Avancado.Inputs();
input.id_do_lead_contato_ou_usuario = lead.Id;
input.email_responder_para = lead.Email;
input.emails_para_separados_por_virgula = lead.Email;
input.assunto_do_email = 'Teste';
input.corpo_do_email = 'Corpo';
input.salvar_no_timeline = true;

List<String> resultado = Send_Email_Avancado.enviar_email(new List<Send_Email_Avancado.Inputs>{ input });
System.assertEquals('Sucesso', resultado[0]);
```

---

## 🧠 Capítulo X: Estratégia de Testes com Exceções e Variáveis Estáticas Visíveis

Quando estamos lidando com a validação de campos obrigatórios ou qualquer outra exceção que precisa ser controlada de forma precisa, podemos empregar variáveis estáticas visíveis para garantir que o comportamento da exceção seja corretamente monitorado e testado.

#### ✅ Como Funciona:

1. **Introdução da variável estática**: 
   - Crie uma variável estática visível dentro da classe que será controlada durante os testes para garantir que a exceção seja lançada corretamente.
   - A variável será usada para monitorar se a exceção foi realmente lançada durante o processo de teste.

2. **Monitoramento da exceção**:
   - Dentro do método `@isTest`, use essa variável para verificar se a exceção foi realmente lançada, após a execução do método a ser testado.
   
3. **Exemplo**: 

```apex
public class ValidateNumeroInstalacao {

    // Variável para controle de exceção
    @TestVisible public static Boolean exceptionThrown = false;

    public static void handleException(Exception e, String method, String origin) {
        if (e instanceof RestServiceHelper.BadRequestException) {
            exceptionThrown = true;
            // Lógica de exceção
        }
    }
}

// Teste
@isTest
private class ValidateNumeroInstalacaoTest {

    @isTest
    static void testValidateRequiredFieldsMissingData() {
        ValidateNumeroInstalacao.exceptionThrown = false;

        // Configurar dados inválidos para teste
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"distribuidora_id": "", "numero_instalacao": ""}');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ValidateNumeroInstalacao.receivePost();
        Test.stopTest();

        // Verifica se a exceção foi lançada
        System.assert(ValidateNumeroInstalacao.exceptionThrown, 'Deveria lançar exceção de BadRequest devido a campos obrigatórios ausentes.');
    }
}
```

#### ✅ Por que usar essa estratégia?

- **Controle absoluto** sobre a exceção: A variável `exceptionThrown` vai permitir garantir que qualquer erro esperado seja lançado corretamente, sem depender do comportamento assíncrono ou de outros efeitos colaterais.
- **Testabilidade limpa**: Ao evitar a manipulação direta da exceção e deixando que a lógica de teste controle o lançamento da exceção, a cobertura do teste se torna mais confiável.
- **Seguindo a Mentalidade Mamba**: Essa abordagem segue rigorosamente os princípios de **rastreadibilidade** e **testabilidade** exigidos pela Mamba Mentality.

---

## 🧠 Checklist final para testes Apex

| Item                                                      | Verificado? |
|-----------------------------------------------------------|-------------|
| `@TestSetup` com `setupCompleteEnvironment()`             | [ ]         |
| `FlowControlManager.disableFlows()` após setup            | [ ]         |
| `SELECT` defensivo após setup                             | [ ]         |
| Sem `testData.get(...)`                                   | [ ]         |
| `LoggerMock` aplicado se necessário                       | [ ]         |
| Assertivas com mensagem real                              | [ ]         |
| `fakeIdForSafe(...)` para ID inexistente rastreável       | [ ]         |
| **Estratégia de Teste de Exceção com Variáveis Estáticas**| [ ]         |

---

🧠🧱🧪 #TestesMamba #SemDadoDuplicado #AssertComMensagem #FakeIdSeguro #LoggerMockSempre

---

Com essa inclusão, a estratégia de controle de exceções através de variáveis estáticas visíveis ficou centralizada no **Guia de Testes Apex**. Isso garante que a abordagem seja documentada e clara para futuras referências, mantendo a rastreabilidade e controle total sobre o fluxo de exceções, um princípio fundamental da **Mentalidade Mamba**.

**classes .cls***

/**
 * @since 2025-03-28
 * @author Leo Mamba Garcia
 * 
 * Classe `TestHelper`
 * 
 * Contém métodos utilitários para auxiliar a criação de dados de teste, geração de valores falsos
 * e a validação de pré-condições antes da execução dos testes. O TestHelper centraliza toda a lógica
 * de configuração de dados para evitar repetição e garantir consistência nos testes.
 */
public class TestHelper {

    /**
     * Gera um ID falso seguro para o tipo de objeto informado.
     */
    @TestVisible public static Id fakeIdForSafe(Schema.SObjectType type) {
        if (type == null) return null;

        try {
            // Tenta buscar um ID real do objeto
            String objectName = type.getDescribe().getName();
            String query = 'SELECT Id FROM ' + objectName + ' LIMIT 1';
            List<SObject> records = Database.query(query);

            if (records.isEmpty()) {
                // Se não houver registros reais, gera via getKeyPrefix com fallback controlado
                String prefix = type.getDescribe().getKeyPrefix();
                return Id.valueOf(prefix + '000000000000ZZZ'); // estrutura segura
            }

            Id realId = records[0].Id;
            String mutated = String.valueOf(realId).substring(0, 12) + 'ZZZ'; // troca sufixo
            return Id.valueOf(mutated);

        } catch (Exception ex) {
            System.debug('⚠️ fakeIdForSafe falhou: ' + ex.getMessage());
            return null;
        }
    }

    /**
     * Gera um e-mail aleatório para simulação de testes.
     */
    @TestVisible public static String randomEmail() {
        Integer suffix = Math.mod(Math.abs(Crypto.getRandomInteger()), 1000000);
        return 'usuario' + String.valueOf(suffix) + '@teste.com';
    }

    /**
     * Gera um CNPJ falso no formato '76.999.774/0001-XX'.
     */
    @TestVisible public static String fakeCnpj() {
        Integer digito = Math.mod(Math.abs(Crypto.getRandomInteger()), 90);
        String dv = digito < 10 ? '0' + String.valueOf(digito) : String.valueOf(digito);
        return '76.999.774/0001-' + dv;
    }

    /**
     * Gera um número de telefone no formato brasileiro, exemplo: 5521999XXXXXX.
     */
    @TestVisible public static String fakePhone() {
        // Gera um número do tipo 5521999XXXXXX (celular do RJ)
        String numero = '5521999' + randomDigits(6);
        return numero;
    }

    /**
     * Gera uma sequência de números aleatórios com o comprimento especificado.
     */
    @TestVisible public static String randomDigits(Integer length) {
        String result = '';
        while (result.length() < length) {
            result += String.valueOf(Math.abs(Crypto.getRandomInteger()));
        }
        return result.substring(0, length);
    }

    /**
     * Gera uma string aleatória com caracteres alfanuméricos, com o comprimento especificado.
     */
    @TestVisible public static String randomString(Integer length) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        String result = '';
        while (result.length() < length) {
            Integer r = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            result += chars.substring(r, r + 1);
        }
        return result;
    }

    /**
     * Método para assertiva de que o dado não foi configurado.
     */
    @TestVisible public static void assertSetupCreated(String objeto) {
        System.assert(false, '❌ Registro obrigatório do tipo ' + objeto + ' não foi criado via TestDataSetup.');
    }
}


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

            Account account = AccountTestDataSetup.createAccount(vertical.Id, originadorFilho.Id, null, '76.999.774/0001-30');
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
            UC__c uc = UcTestDataSetup.createUC(contrato.Id, produto.Id, proposta.Id, user.Id);
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
