************** PENDENCIAS PARA INTEGRAR ****************

🆕 NOVA REGRA: Validação de parâmetros obrigatórios em Queueables e Services
Adicionar em seção: “Validações obrigatórias em testes”

✅ Toda classe Queueable, @InvocableMethod ou Service deve:

Lançar IllegalArgumentException clara e rastreável para entradas nulas ou inválidas

Ser coberta por testes que validem esses throw explicitamente com try/catch + System.assert(false, ...)

Checklist

Item	Obrigatório
String.isBlank(...) validando recordId	✅
recordId.startsWith(...) validando formato	✅
Teste negativo cobrindo exceção lançada	✅

💡 Sugestão: Consolidar uma nova seção nos guias
📂 Validação de Entradas e Assertivas em Testes

Onde centralizamos todas as regras que reforçam a importância de:

Validar parâmetros de entrada

Gerar exceções explícitas e previsíveis

Garantir que testes que esperam falha de fato cobrem essa falha

************** FIM DAS PENDENCIAS ****************


Vamos revisar e atualizar o **`GuiaTestsApex`** para refletir:

- Adoção oficial de `LoggerMock`  
- Uso obrigatório de `TestDataSetup`  
- Integração com fluxo de disable de Flow  
- Proibições de anti-patterns como `seeAllData`, `enqueueJob`, `System.debug`

---

# 🧪 Guia Oficial de Testes Apex – v2025  
> _Cobertura real. Isolamento absoluto. Testes de elite._

📎 Guias complementares:
- 🪵 [Guia Logger Fluent + Mock](https://bit.ly/GuiaLoggerApex)
- 🧱 [TestDataSetup Global](https://bit.ly/TestDataSetup)
- 🔁 [Template Comparativo Antes vs Depois](https://bit.ly/ComparacaoApex)
- ✅ [Checklist de Equivalência Funcional](https://bit.ly/ConfirmacaoApex)

---

## 🎯 Objetivo

Garantir que toda classe testada atenda aos critérios de:
- 💥 Cobertura real de lógica (e não de linhas)
- 🔁 Independência entre testes
- 🧱 Isolamento de dados
- 🧠 Simulação de erros e exceções

---

## ✅ Regras Rígidas

---

## 🧠 Checklist Mamba de Rigor em Testes Apex

Este checklist é obrigatório. Nenhum PR de teste pode ser aprovado se violar qualquer um dos itens abaixo.

| ID  | Regra Mamba                                                                                     | Status  |
|------|------------------------------------------------------------------------------------------------|----------|
| T01 | ❌ `testData.get(...)` **proibido** dentro de métodos `@isTest`                                | 🔒       |
| T02 | ❌ `setupTestData()` **jamais chamado manualmente** dentro de métodos `@isTest`                | 🔒       |
| T03 | ✅ Toda preparação de dados deve ocorrer exclusivamente em `@TestSetup`                         | ✅       |
| T04 | ❌ `FlowControlManager.disableFlows()` deve ser chamado apenas 1x no `@TestSetup`              | 🔒       |
| T05 | ❌ `createUser(..., true)` + `System.runAs()` externo causam exceção (`Test already started`)  | 🔒       |
| T06 | ✅ Se `createUser(..., false)`, o `runAs + startTest/stopTest` deve ser explícito no teste     | ✅       |
| T07 | ❌ Testes com `isParallel=true` **não podem executar DML em objetos restritos** (User, Profile) | 🔒       |
| T08 | ✅ Sempre usar `SELECT` explícito nos métodos `@isTest` para acessar dados criados             | ✅       |
| T09 | ✅ Asserts devem ter mensagens claras, específicas e rastreáveis                               | ✅       |
| T10 | ❌ `LoggerMock.getLogs()` **nunca** deve ser usado para validação — apenas para neutralizar log | 🔒       |
| T11 | ✅ Dados de teste devem vir exclusivamente do `TestDataSetup`                                  | ✅       |
| T12 | ✅ Cada teste deve validar **comportamento funcional real**, não apenas rodar código           | ✅       |

---

📌 **Este checklist deve ser revisado antes da aprovação de qualquer classe de teste.**  
📦 Padronização, previsibilidade e rastreabilidade total são inegociáveis.

#MambaTestes #OrgBlindada #NadaPassa

### 1. Setup de ambiente
- ✅ Todo teste deve começar com:
  ```apex
  TestDataSetup.setupCompleteEnvironment();
  FlowControlManager.disableFlows();
  Logger.isEnabled = false;
  ```

### 2. Testes com `LoggerMock`
- Nunca insira logs reais em testes
- Use:
  ```apex
  LoggerMock mock = new LoggerMock();
  mock.setMethod('nomeTeste').info('teste', null);
  System.assertEquals(1, mock.getCaptured().size());
  ```

### 3. `Test.startTest()` obrigatório
- Use sempre que houver lógica assíncrona, DML ou `enqueue`
- Exemplo:
  ```apex
  Test.startTest();
  System.enqueueJob(new MinhaClasseQueueable());
  Test.stopTest();
  ```

### 4. Múltiplos cenários por método
- Todo método de teste deve cobrir:
  - ✅ Caminho feliz (positivo)
  - ⚠️ Validação de erros
  - 💥 Exceções simuladas

### 5. Nome de classe
- Sufixo obrigatório `Test`
- Nome deve corresponder 1:1 à classe de produção
  - Exemplo: `ClienteService → ClienteServiceTest`

---

## ⚠️ Proibições Intransigentes

| Proibido                        | Motivo                                                              |
|---------------------------------|---------------------------------------------------------------------|
| `System.debug()`                | Não rastreável. Use `LoggerMock`                                   |
| `System.enqueueJob(...)` direto | Deve ser encapsulado no teste e nunca validado diretamente         |
| `LoggerQueueable` em testes     | ⚠️ Não deve ser testado via log persistido (é assíncrono)          |
| `seeAllData=true`               | Rompe isolamento. Não usar.                                        |
| `Test.startTest()` sem `stop`   | Pode mascarar exceções                                             |

---

## 🧪 Padrão de Teste Apex

```apex
@IsTest
private class MinhaClasseTest {

    @TestSetup
    static void setup() {
        TestDataSetup.setupCompleteEnvironment();
        FlowControlManager.disableFlows();
        Logger.isEnabled = false;
    }

    @IsTest
    static void testHappyPath() {
        LoggerMock mock = new LoggerMock();
        Test.startTest();
        // Chamada ao método testado
        Test.stopTest();

        System.assertEquals(1, mock.getCaptured().size());
    }

    @IsTest
    static void testComErro() {
        try {
            // Simula erro
            System.assert(false, 'Forçar falha');
        } catch (Exception e) {
            System.assertEquals('Forçar falha', e.getMessage());
        }
    }
}
```

---

## 🛠️ Boas práticas

- Criar `TestDataBuilder` ou `TestDataSetup` por domínio
- Validar mensagens e fluxos, não só `.size()`
- Usar `.left(n)` para logs longos
- Nunca usar lógica condicional fora do método de teste

---

## ✅ Checklist de Revisão de Testes

- [ ] Usa `TestDataSetup.setupCompleteEnvironment()`?
- [ ] Flows desabilitados com `FlowControlManager.disableFlows()`?
- [ ] Usa `LoggerMock` (nunca `Logger` real)?
- [ ] Sem `System.debug()`?
- [ ] Sem `seeAllData=true`?
- [ ] Cobertura do happy path, erro e exceção?
- [ ] Classe termina com `Test`?
- [ ] Métodos testáveis são `@TestVisible`?

---

> 🧠 Testes são o escudo da sua org.  
> 🐍 Teste bem. Teste com padrão. Teste como Mamba.  

---
