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
