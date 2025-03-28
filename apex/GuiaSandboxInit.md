Perfeito. Abaixo está:

---

# 📘 **Markdown Completo: `GuiaSandboxInit.md`**

```markdown
# 🧱 Guia de Inicialização de Ambientes Sandbox (`OrgInitializer + EnvironmentUtils`)

> Este guia define o padrão oficial de **setup automatizado** de ambientes **sandbox** da sua organização, utilizando as classes `OrgInitializer` e `EnvironmentUtils`.

---

## 🎯 Objetivo

Padronizar e automatizar a configuração de:

- Variáveis de ambiente globais via `ConfiguracaoSistema__c`
- Dados básicos via `TestDataSetup.setupCompleteEnvironment()`
- Inicialização controlada via `OrgInitializer.run()` somente em **sandbox**

---

## 🚦 Quando usar

- Após **criação ou refresh** de uma nova sandbox
- Em **pipelines de CI/CD** que provisionam ambientes automaticamente
- Para preparar o ambiente de teste local antes de execuções com mocks, logs, ou flows

---

## 🔧 Classes Utilizadas

### 🔹 `OrgInitializer`

Classe principal de execução.  
Executa:

```apex
OrgInitializer.run();
```

Internamente realiza:

- Configuração do Custom Setting `ConfiguracaoSistema__c`
- Execução de `TestDataSetup.setupCompleteEnvironment()`
- Proteção contra execução em produção (`Organization.IsSandbox == false`)

---

### 🔹 `EnvironmentUtils`

Classe auxiliar que:
- Lê e armazena em cache os valores de `ConfiguracaoSistema__c`
- Permite atualização de configurações via `updateX()` e leitura via `isX()` e `getX()`

---

## ⚙️ Valores default no `OrgInitializer`:

| Campo                   | Valor        |
|------------------------|--------------|
| Ambiente__c            | `sandbox`    |
| Log_Level__c           | `DEBUG`      |
| Log_Ativo__c           | `true`       |
| Habilita_Mock__c       | `true`       |
| Modo_Teste_Ativo__c    | `true`       |
| Timeout_Callout__c     | `120000`     |
| Desativar_Flows__c     | `false`      |

---

## ✅ Exemplo de Execução Manual

```apex
// Anonymous Apex
OrgInitializer.run();
```

---

## 🧪 Teste Automatizado Recomendado

```apex
@isTest
static void deve_inicializar_configuracao_sandbox() {
    OrgInitializer.run();

    ConfiguracaoSistema__c conf = [SELECT Ambiente__c FROM ConfiguracaoSistema__c LIMIT 1];
    System.assertEquals('sandbox', conf.Ambiente__c);
}
```

---

## 🔒 Proteções

- O método `OrgInitializer.configureOrg()` **só roda se**:
  - `Organization.IsSandbox == true`
  - Ou se estiver em `Test.isRunningTest()`

---

## 📦 Repositórios Impactados

- `OrgInitializer.cls`
- `EnvironmentUtils.cls`
- `TestDataSetup.cls`

---

## 🔗 Integrações e Referências

| Guia                      | Descrição                                        |
|---------------------------|--------------------------------------------------|
| [Guia Logger Apex](https://bit.ly/GuiaLoggerApex) | Integra com `getLogLevel()` e `isLogAtivo()` |
| [Guia Test Data Setup](https://bit.ly/TestDataSetup) | Usado dentro de `setupTestData()`           |
| [Guia de Mocks (se houver)](https://bit.ly/GuiaMocksSandbox) | Usa `isMockEnabled()`                       |

---
```

---

# 📦 **Pull Request: Blocos Markdown para guias existentes**

### ✅ Para `GuiaLoggerApex` (Logging):

```markdown
## 🔁 Integração com EnvironmentUtils

Você pode dinamicamente controlar o nível de log e ativação de logs usando:

```apex
if (EnvironmentUtils.isLogAtivo()) {
    logger.log(EnvironmentUtils.getLogLevel(), 'mensagem', null, JSON.serialize(something));
}
```

Esses valores são configurados via `ConfiguracaoSistema__c`, e podem ser inicializados com segurança em sandboxes via `OrgInitializer.run()`.
```

---

### ✅ Para `TestDataSetup`:

```markdown
## 🤖 Integração com OrgInitializer

A classe `OrgInitializer` automatiza a execução de `TestDataSetup.setupCompleteEnvironment()` em ambientes sandbox.

Use:

```apex
OrgInitializer.run();
```

Isso garante que o `ConfiguracaoSistema__c` também estará corretamente definido.
```

---

### ✅ Para Guia de Mocks (ex: `GuiaMocksSandbox`):

```markdown
## 🎭 Mock Dinâmico via EnvironmentUtils

Você pode condicionar mocks com base em configuração centralizada:

```apex
if (EnvironmentUtils.isMockEnabled()) {
    // Substituir serviços reais por mocks
}
```

O valor `Habilita_Mock__c` pode ser alterado diretamente ou via `OrgInitializer.setupConfigSystem(...)`.
```

---
