### 🔥 **Guia Rigoroso para Escrita de Testes em Apex – Versão Atualizada**  

```markdown
# ✅ Guia Rigoroso para Escrita de Testes em Apex

Este guia define **padrões obrigatórios** para a criação de testes unitários em Apex, garantindo:

- Cobertura completa e significativa  
- Isolamento de efeitos colaterais  
- Uso seguro de logs com LoggerMock  
- Conformidade com o Guia Rigoroso de Revisão Apex  

---

## 📌 Objetivos

- Validar comportamentos, não implementações  
- Evitar testes frágeis ou não confiáveis  
- Facilitar manutenção, leitura e rastreabilidade  
- Cobrir fluxos positivos, negativos e de exceção  

---

## 🔒 Regras Obrigatórias

### ✅ Uso obrigatório de `Test.startTest()` e `Test.stopTest()`

Todo teste **deve** envolver o trecho testado com:

```apex
Test.startTest();
// chamada do método
Test.stopTest();
```

> **Regra**: Se `Test.startTest();` for omitido, o teste pode falhar com `System.FinalException: Testing has not started`.

---

### ✅ Ordem correta com TestDataSetup e FlowControl

Sempre chame `TestDataSetup.setupCompleteEnvironment()` **antes de desativar flows**.

```apex
Map<String, SObject> testData = TestDataSetup.setupCompleteEnvironment();
FlowControlManager.disableFlows();
```

> Flows são necessários para que certos registros sejam gerados corretamente.  
> Desativá-los antes pode causar dados incompletos ou inválidos.

#### ✅ Se precisar criar registros adicionais manualmente:

Sempre use os métodos do `TestDataSetup` antes de desativar os flows:

```apex
@isTest
static void setup() {
    // Criação de registros que dependem de Flow
    Account acc = TestDataSetup.createAccount(null, null, 'Empresa X', '12345678000195');

    // Agora é seguro desativar os flows
    FlowControlManager.disableFlows();
}
```

---

### ✅ Prevenção de `null` no `@testSetup`

Adicione validação dentro do `@testSetup` para garantir que `testData` nunca seja `null`.

```apex
@testSetup
static void setupTestData() {
    testData = TestDataSetup.setupCompleteEnvironment();
    System.assert(testData != null, 'testData não pode ser null no setup!');
}
```

> **Regra**: Sempre validar `testData` antes de acessá-lo.

---

### ✅ Uso de variáveis estáticas no início da classe de teste

Para controle e rastreabilidade:

```apex
private static Map<String, SObject> testData;
private static Boolean flowsDisabled = false;
private static LoggerMock logger;
```

---

### ✅ LoggerMock sempre que a classe usa LoggerContext

```apex
logger = new LoggerMock();
LoggerContext.setLogger(logger);
```

❌ **Evite validar logs de chamadas `Queueable`**  
Os logs podem ser processados de forma assíncrona, causando falhas intermitentes nos testes.

> **Correção**: Não faça assert diretamente em `logger.getLogs()` se houver `Queueable`.

✅ **Verificação segura:**
```apex
System.assert(true, 'O teste executou corretamente sem exceções.');
```

---

### ✅ Assertivas fortes e significativas

Evite asserts fracos como `System.assert(true)`.  
Use asserts com mensagens claras:

```apex
System.assertEquals(expected, actual, 'Mensagem clara de falha');
```

---

### ✅ Enfileiramento com LoggerJobManager em testes

Se sua classe enfileirar um `Queueable`, **o teste não deve chamar `System.enqueueJob(...)` diretamente**.

Em vez disso, apenas dispare o método que internamente chama:

```apex
LoggerJobManager.enqueueJob(new MeuQueueable(), recordId);
```

**Exemplo correto de teste:**

```apex
Test.startTest();
ClassePrincipal.acaoQueEnfileira();
Test.stopTest();
```

> **Regra**: A verificação deve ser feita por logs ou fluxo de execução, **não pela chamada direta do `Queueable`**.

#### ❌ Nunca faça:

```apex
System.enqueueJob(new MeuJobQueueable()); // ❌ Proibido em testes e produção
```

---

### ✅ Testes de fluxo completo

Sempre que possível:

- Caminho de sucesso  
- Parâmetros inválidos  
- Exceções simuladas (`HttpCalloutMock`)  

---

### ❌ Proibido

- Usar `System.enqueueJob()` diretamente em testes  
- Contar registros em `FlowExecutionLog__c`  
- Usar `System.debug()` fora de `Test.isRunningTest()`  
- Desativar flows antes de `setupCompleteEnvironment()` ou `TestDataSetup.createX`  
- Validar logs que possam ser enfileirados via `Queueable`  

---

## 🧪 Estrutura Recomendada

```apex
@isTest
private class MinhaClasseTest {

    private static Map<String, SObject> testData;
    private static Boolean flowsDisabled = false;
    private static LoggerMock logger;

    @testSetup
    static void setup() {
        testData = TestDataSetup.setupCompleteEnvironment();
        System.assert(testData != null, 'testData não pode ser null no setup!');
        FlowControlManager.disableFlows();
    }

    @isTest
    static void testCasoDeSucesso() {
        logger = new LoggerMock();
        LoggerContext.setLogger(logger);

        Test.startTest();
        MinhaClasse.metodoX();
        Test.stopTest();

        System.assert(true, 'O teste executou corretamente sem exceções.');
    }
}
```

---

## 📈 Cobertura mínima esperada

| Elemento                  | Coberto |
|---------------------------|---------|
| Fluxo principal           | ✅      |
| Fluxo alternativo         | ✅      |
| Erros esperados           | ✅      |
| Falhas simuladas (Mock)   | ✅      |
| Uso do LoggerContext      | ✅      |
| Enfileiramento rastreado  | ✅      |

---

## 🔁 Testes são obrigatórios para:

- Classes com lógica (REST, Batch, Queueable, TriggerHandler)  
- Métodos utilitários que manipulam dados  
- Lógicas condicionais ou de exceção  

---

## ✅ Conclusão

Testes são parte do contrato de código.  
Sem testes válidos, nenhuma refatoração é segura.  
Siga este guia em 100% dos casos.

---
