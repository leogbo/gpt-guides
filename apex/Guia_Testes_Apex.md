🧠🛠️ Aqui está a **versão completa, atualizada e incrementada** do **🧪 Guia Rigoroso de Testes Apex 2025**, agora incluindo:

- Reforço da obrigatoriedade de `assert` com mensagens diagnósticas contendo o valor real
- Diretrizes refinadas com base em práticas reais aplicadas (como REST, status HTTP, contratos de resposta)
- Seções aprimoradas de `TestDataSetup`, `LoggerMock`, estrutura de teste e checklist final

---

# 🧪 Guia Rigoroso de Testes Apex (Versão Estendida 2025)

> 🌐 Base oficial: [bit.ly/GuiaTestsApex](https://bit.ly/GuiaTestsApex)

📎 Consulte também os guias complementares:
- 📘 [Guia de Revisão Apex](https://bit.ly/GuiaApexRevisao)
- 🧪 [Guia de Logger + LoggerContext](https://bit.ly/GuiaLoggerApex)
- 🔁 [Template de Comparação Antes vs Depois](https://bit.ly/ComparacaoApex)
- 🧱 [Classe TestDataSetup Central](https://bit.ly/TestDataSetup)
- ✅ [Confirmação de Equivalência Funcional](https://bit.ly/ConfirmacaoApex)

---

## ✅ Objetivo

Padronizar a estrutura, cobertura e qualidade dos testes Apex com base na filosofia **Mamba Mentality**:

- Clareza estrutural
- Cobertura total (positivos, inválidos e exceções)
- Rastreabilidade via logs, status e conteúdo de resposta
- Mensagens de erro sempre com conteúdo da variável testada

---

## ⚙️ Regras Técnicas Obrigatórias

### 1. Setup de ambiente centralizado
```apex
@TestSetup
static void setupTestData() {
    TestDataSetup.setupCompleteEnvironment();
    FlowControlManager.disableFlows();
}
```
✅ Nunca reaproveitar `Map<String, SObject>` do `@TestSetup`  
✅ Buscar dados no teste com `SELECT` direto  
❌ Proibido usar `setupCompleteEnvironment()` em métodos de teste diretamente

---

### 2. Uso obrigatório de `LoggerMock`
```apex
LoggerMock logger = new LoggerMock();
LoggerContext.setLogger(logger);
```
❌ Não testar conteúdo de logs (`LoggerQueueable` é assíncrono)  
✅ Usar `LoggerMock` apenas para prevenir efeitos colaterais

---

### 3. Proibição de chamadas assíncronas reais
❌ `System.enqueueJob(...)`  
✅ Simular efeito com `LoggerMock` se necessário

---

### 4. Cobertura obrigatória de cenários
| Tipo de Cenário        | Exigido |
|------------------------|---------|
| Fluxo positivo         | ✅      |
| Input inválido         | ✅      |
| Erros ou exceções      | ✅      |
| Mock de logger ativo   | ✅      |
| Validação do status    | ✅      |

---

### 5. `RestContext.response` em testes REST
```apex
RestContext.response = new RestResponse();
```
⚠️ Sem isso, `NullPointerException` em produção

---

### 6. Métodos internos testáveis
✅ Usar `@TestVisible` para lógica encapsulada  
✅ Métodos devem aceitar parâmetros isoláveis  
❌ Evite lógica dentro de `constructors` ou `static blocks`

---

## 🧠 7. Assertividade Cirúrgica (Mensagens com conteúdo real)

> Toda mensagem de erro de assert deve conter **a variável testada**, para rastreabilidade direta

### ✅ Correto:
```apex
System.assertEquals(200, status, '❌ Esperado status 200. Recebido: ' + status);
System.assert(responseBody.contains('assinatura_recebida'), '❌ Corpo inválido: ' + responseBody);
```

### ❌ Errado:
```apex
System.assertEquals(200, status, '❌ Status inválido');
```

🔍 Sempre revele a **causa concreta da falha** no log.

---

## 🧱 8. TestDataSetup – Setup Oficial da Org

### ✅ Por que usar
- Reutilizável, seguro e completo
- Garante vínculos válidos: `Lead → Opp → Proposta → UC → Cobranca`
- Mock de labels, logs e flows incluso
- Testes mais rápidos e rastreáveis

### 🧪 Exemplo:
```apex
LoggerContext.setLogger(new LoggerMock());

Map<String, SObject> dados = TestDataSetup.setupCompleteEnvironment();

UC__c uc = [SELECT Id FROM UC__c LIMIT 1];
System.assertNotEquals(null, uc, 'UC não criada no setup');
```

---

### ♻️ Métodos disponíveis:

| Método                             | Finalidade |
|------------------------------------|------------|
| `setupCompleteEnvironment()`       | Cria tudo para testes complexos |
| `createIntegracao()`               | Garante 1 registro funcional |
| `cleanUp(List<SObject>)`           | Best-effort delete |
| `fullCleanUpAllSupportedObjects()` | Limpeza geral controlada |

---

## 🔕 9. Diretrizes para Logs

- ❌ Nunca validar logs via `LoggerMock.getLogs()`
- ✅ Apenas isolar efeitos com `LoggerMock`
- ✅ `System.debug()` permitido apenas em **testes**, e se necessário
- ❌ `System.debug()` em produção é **proibido**

---

## 🧩 10. Estrutura Esperada de Teste

```apex
@isTest
private class MinhaClasseTest {

    @TestSetup
    static void setup() {
        TestDataSetup.setupCompleteEnvironment();
        FlowControlManager.disableFlows();
    }

    @isTest
    static void testePositivo() {
        LoggerContext.setLogger(new LoggerMock());
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        MinhaClasse.metodoTestado(acc.Id);
        Test.stopTest();

        System.assertEquals(true, acc != null, '❌ Account não foi recuperada corretamente. ID: ' + acc.Id);
    }
}
```

---

## ✅ 11. Checklist Final

| Item | Obrigatório |
|------|-------------|
| `@TestSetup` com `setupCompleteEnvironment()` | ✅ |
| `FlowControlManager.disableFlows()` após setup | ✅ |
| `SELECT` explícito para buscar dados | ✅ |
| `RestContext.response` inicializado em testes REST | ✅ |
| `LoggerMock` e `LoggerContext.setLogger()` | ✅ |
| `Test.startTest()` / `Test.stopTest()` | ✅ |
| `System.assert` com mensagem detalhada | ✅ |
| `@TestVisible` para lógica encapsulada | ✅ |
| Nenhuma validação de conteúdo de log | ✅ |

---

📘 Versão atualizada com base em revisões reais da sua org  
🧠 Aprovado pelo Revisor Rigoroso | Leo Garcia  
🖤 Mamba Mentality em cada linha de teste. Sem exceção.
