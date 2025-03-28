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
