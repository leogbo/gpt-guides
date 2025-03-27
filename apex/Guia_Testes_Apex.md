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

---

🧠🧱🧪 #TestesMamba #SemDadoDuplicado #AssertComMensagem #FakeIdSeguro #LoggerMockSempre

