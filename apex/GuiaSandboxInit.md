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


**classes .cls**

/**
 * Classe `OrgInitializer`
 * 
 * A classe `OrgInitializer` é responsável por configurar automaticamente a organização Salesforce para testes. 
 * Ela define o ambiente (sandbox ou produção), configura o nível de log, ativa ou desativa fluxos e mocks, 
 * e define outros parâmetros essenciais para a execução de testes e integração de dados. 
 * Além disso, ela se encarrega de garantir que os dados de teste sejam configurados corretamente antes da execução dos testes.
 *
 * ### Funcionalidade:
 * - **setupConfigSystem**: Configura a organização Salesforce com parâmetros como ambiente (sandbox ou produção), 
 *   nível de log, se o log está ativo, habilitação de mocks, entre outros. Cria ou atualiza o objeto `ConfiguracaoSistema__c`.
 * - **setupTestData**: Configura os dados de teste necessários para rodar os testes, garantindo que o ambiente esteja preparado.
 * - **configureOrg**: Realiza a configuração completa da organização, incluindo a verificação se está em ambiente de sandbox. 
 *   Executa a configuração do sistema e prepara os dados de teste.
 * - **run**: Método principal que executa a configuração completa da organização chamando o método `configureOrg`.
 *
 * ### Considerações Importantes:
 * - **Ambiente de Execução**: A classe verifica se a organização está em ambiente de sandbox antes de realizar quaisquer alterações. 
 *   Não permite que a execução ocorra em ambientes de produção.
 * - **Logs**: Utiliza o `Logger` para rastrear e registrar todas as ações de configuração, com logs detalhados de sucesso e falha.
 * - **Modularização**: Cada funcionalidade da classe está isolada em métodos específicos, permitindo fácil manutenção e extensibilidade.
 *
 * ### Exemplos de Uso:
 * - **Executando a Configuração da Org**: 
 *     ```apex
 *     OrgInitializer.run();  // Configura a organização para o ambiente de testes
 *     ```
 * - **Configurando Dados de Teste**:
 *     ```apex
 *     OrgInitializer.setupTestData();  // Configura os dados de teste após garantir que o ambiente está configurado
 *     ```
 *
 * @since 28/03/2025
 * @author Leo Mamba Garcia
 */

 public class OrgInitializer {

    private static final String CLASS_NAME = 'OrgInitializer';
    private static final String CATEGORY = 'Setup';
    private static final String TRIGGER_TYPE = 'Manual';

    // Método para inicializar ConfiguracaoSistema__c
    @TestVisible
    public static void setupConfigSystem(String ambiente, String logLevel, Boolean logAtivo, Boolean habilitaMock, Boolean modoTesteAtivo, Decimal timeoutCallout, Boolean desativarFlows) {
        Logger logger = new Logger()
            .setClass(CLASS_NAME)
            .setMethod('setupConfigSystem')
            .setCategory(CATEGORY);

        // Estrutura de dados do log
        Map<String, Object> logData = new Map<String, Object> {
            'ambiente' => ambiente,
            'logLevel' => logLevel,
            'logAtivo' => logAtivo,
            'habilitaMock' => habilitaMock,
            'modoTesteAtivo' => modoTesteAtivo,
            'timeoutCallout' => timeoutCallout,
            'desativarFlows' => desativarFlows
        };

        try {
            // Log de início de configuração
            logger.info('Iniciando configuração de ConfiguracaoSistema__c', JSON.serializePretty(logData));

            // Deleta qualquer configuração anterior (para garantir que só há uma)
            delete [SELECT Id FROM ConfiguracaoSistema__c];

            // Cria o novo registro de configuração
            ConfiguracaoSistema__c config = new ConfiguracaoSistema__c(
                SetupOwnerId = UserInfo.getOrganizationId(),
                Ambiente__c = ambiente,
                Log_Level__c = logLevel,
                Log_Ativo__c = logAtivo,
                Habilita_Mock__c = habilitaMock,
                Modo_Teste_Ativo__c = modoTesteAtivo,
                Timeout_Callout__c = timeoutCallout,
                Desativar_Flows__c = desativarFlows
            );

            insert config;

            // Log de sucesso com a configuração inserida
            logger.success('Configuração de sistema finalizada com sucesso', JSON.serializePretty(config));

        } catch (Exception ex) {
            logger.error('Erro ao configurar o sistema', ex, JSON.serializePretty(logData));
        }
    }

    // Método para configurar dados de teste
    @TestVisible
    public static void setupTestData() {
        Logger logger = new Logger()
            .setClass(CLASS_NAME)
            .setMethod('setupTestData')
            .setCategory(CATEGORY);

        logger.info('Iniciando configuração de dados de teste via TestDataSetup', null);

        try {
            // Garante que o ambiente está configurado antes de rodar os testes
            setupConfigSystem(
                'sandbox',
                'INFO',  // Usar INFO para evitar logs excessivos durante os testes
                true,
                true,
                true,
                120000,
                false
            );

            TestDataSetup.setupCompleteEnvironment();
            validateTestData();
            logger.success('Dados de teste configurados com sucesso', null);
        } catch (Exception ex) {
            logger.error('Erro ao configurar os dados de teste', ex, null);
        }
    }

    @TestVisible
    public static void validateTestData() {
        // Verifica se os dados esperados estão presentes no ambiente de teste.
        List<Account> contas = [SELECT Id FROM Account LIMIT 1];
        if (contas.isEmpty()) {
            throw new CustomException('Nenhuma conta foi configurada corretamente.');
        }
    }

    // Método para configurar a organização com as configurações básicas
    @TestVisible
    public static void configureOrg() {
        Logger logger = new Logger()
            .setClass(CLASS_NAME)
            .setMethod('configureOrg')
            .setCategory(CATEGORY);

        try {
            if (UserInfo.getUserType() != 'Standard' || !Test.isRunningTest()) {
                if (![SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox) {
                    logger.warn('Tentativa de execução do OrgInitializer em ambiente de produção bloqueada', null);
                    return;
                }
            }

            logger.info('Iniciando configuração da organização sandbox', null);

            // Apenas setupTestData, que já chama setupConfigSystem internamente
            setupTestData();

            logger.success('Configuração completa do ambiente finalizada', null);
        } catch (Exception ex) {
            logger.error('Erro ao configurar a organização', ex, null);
        }
    }

    // Método para rodar a inicialização
    @TestVisible
    public static void run() {
        configureOrg();
    }
}



/**
 * Classe `EnvironmentUtils`
 * 
 * Esta classe centraliza a leitura e atualização de configurações do ambiente da organização Salesforce
 * através do Custom Setting `ConfiguracaoSistema__c`. Ela permite acessar e manipular informações como 
 * o ambiente (produção ou sandbox), o nível de log, se o log está ativo, a habilitação de mocks, entre 
 * outros parâmetros configuráveis diretamente do Custom Setting. Os valores configurados são carregados e 
 * mantidos em cache para garantir a eficiência e evitar múltiplas consultas.
 * 
 * ### Funcionalidade:
 * - **Leitura dos Valores Configurados:** Os métodos de leitura permitem acessar o valor do ambiente, 
 *   o nível de log, se o log está ativo, e outros parâmetros.
 * - **Atualização das Configurações:** A classe fornece métodos para atualizar as configurações no Custom 
 *   Setting, permitindo alterar o ambiente, o nível de log, e outros valores diretamente na plataforma.
 * - **Cache Interno:** A classe utiliza um cache para armazenar os valores configurados após a leitura 
 *   inicial, evitando consultas repetidas e melhorando a performance das operações subsequentes.
 * - **Acesso a Custom Settings:** A classe interage diretamente com o Custom Setting `ConfiguracaoSistema__c`,
 *   que armazena valores específicos para a organização (como `Ambiente__c`, `Log_Level__c`, `Log_Ativo__c`, 
 *   `Habilita_Mock__c`, `Modo_Teste_Ativo__c`, entre outros).
 * 
 * ### Métodos de Leitura:
 * - `isProduction()`: Retorna `true` se o ambiente configurado for produção.
 * - `isSandbox()`: Retorna `true` se o ambiente configurado for sandbox.
 * - `getRaw()`: Retorna o valor do ambiente como uma string.
 * - `isKnownEnvironment()`: Retorna `true` se o ambiente for conhecido (produção ou sandbox).
 * - `getLogLevel()`: Retorna o nível de log configurado.
 * - `isLogAtivo()`: Retorna se o log está ativo.
 * - `isMockEnabled()`: Retorna se a funcionalidade de mock está habilitada.
 * - `isModoTesteAtivo()`: Retorna se o modo de teste está ativo.
 * - `getTimeoutCallout()`: Retorna o timeout de callout configurado.
 * - `isFlowsDisabled()`: Retorna se os flows estão desativados.
 * 
 * ### Métodos de Atualização:
 * - `updateEnvironment(String newEnvironment)`: Atualiza o ambiente configurado (produção ou sandbox).
 * - `updateLogLevel(String newLogLevel)`: Atualiza o nível de log configurado.
 * - `updateLogAtivo(Boolean newLogAtivo)`: Atualiza se o log está ativo.
 * - `updateHabilitaMock(Boolean newHabilitaMock)`: Atualiza se a funcionalidade de mock está habilitada.
 * - `updateModoTesteAtivo(Boolean newModoTesteAtivo)`: Atualiza se o modo de teste está ativo.
 * - `updateTimeoutCallout(Decimal newTimeout)`: Atualiza o timeout de callout configurado.
 * - `updateDesativarFlows(Boolean newDesativarFlows)`: Atualiza se os flows estão desativados.
 * 
 * ### Uso nas Demais Classes:
 * Esta classe deve ser utilizada em outras classes que necessitam acessar ou modificar as configurações 
 * globais de ambiente. Por exemplo:
 * - **Verificação do ambiente**: Qualquer lógica que dependa de saber se a organização está em ambiente 
 *   de produção ou sandbox pode usar os métodos `isProduction()` ou `isSandbox()`.
 * - **Configuração de logs**: Classes que realizam logging podem utilizar `getLogLevel()` e `isLogAtivo()` 
 *   para ajustar o nível de log dinamicamente.
 * - **Controle de comportamento de mocks e testes**: Métodos como `isMockEnabled()` e `isModoTesteAtivo()` 
 *   podem ser usados para configurar o comportamento de testes e mocks durante a execução de testes unitários.
 * - **Alteração de configurações**: Em cenários onde as configurações precisam ser alteradas (como mudar 
 *   o ambiente de sandbox para produção), os métodos `updateEnvironment()` e outros devem ser utilizados.
 * 
 * ### Considerações:
 * - A classe **carrega as configurações apenas uma vez** quando a aplicação é inicializada ou quando 
 *   ocorre uma atualização das configurações. Isso garante que a leitura e as atualizações subsequentes 
 *   sejam eficientes.
 * - A classe interage diretamente com o **Custom Setting** `ConfiguracaoSistema__c`, que deve estar 
 *   configurado corretamente no Salesforce para armazenar as variáveis de ambiente. Isso permite centralizar 
 *   e gerenciar as configurações de ambiente de maneira mais organizada e flexível.
 * - Certifique-se de **validar as permissões de acesso** para o Custom Setting `ConfiguracaoSistema__c` 
 *   em todos os usuários que possam interagir com a classe.
 */

 public class EnvironmentUtils {

    // 🔒 Cache de leitura
    @TestVisible private static String ENVIRONMENT;
    @TestVisible private static String LOG_LEVEL;
    @TestVisible private static Boolean LOG_ATIVO;
    @TestVisible private static Boolean HABILITA_MOCK;
    @TestVisible private static Boolean MODO_TESTE_ATIVO;
    @TestVisible private static Decimal TIMEOUT_CALLOUT;
    @TestVisible private static Boolean DESATIVAR_FLOWS;

    static {
        loadAllSettings();
    }

    @TestVisible
    private static void loadAllSettings() {
        try {
            // Realiza o SELECT para pegar o último registro criado
            ConfiguracaoSistema__c conf = [SELECT Ambiente__c, Log_Level__c, Log_Ativo__c, 
                                                Habilita_Mock__c, Modo_Teste_Ativo__c, 
                                                Timeout_Callout__c, Desativar_Flows__c 
                                           FROM ConfiguracaoSistema__c
                                           ORDER BY CreatedDate DESC LIMIT 1];

            if (conf != null) {
                ENVIRONMENT = String.isNotBlank(conf.Ambiente__c) ? conf.Ambiente__c.trim().toLowerCase() : null;
                LOG_LEVEL = String.isNotBlank(conf.Log_Level__c) ? conf.Log_Level__c.trim().toLowerCase() : null;
                LOG_ATIVO = conf.Log_Ativo__c;
                HABILITA_MOCK = conf.Habilita_Mock__c;
                MODO_TESTE_ATIVO = conf.Modo_Teste_Ativo__c;
                TIMEOUT_CALLOUT = conf.Timeout_Callout__c;
                DESATIVAR_FLOWS = conf.Desativar_Flows__c;
            }
        } catch (Exception ex) {
            System.debug('⚠️ Erro ao acessar Custom Setting: ' + ex.getMessage());
        }
    }

    // Métodos de leitura dos campos
    @TestVisible
    public static Boolean isProduction() {
        return 'production'.equalsIgnoreCase(ENVIRONMENT);
    }

    @TestVisible
    public static Boolean isSandbox() {
        return 'sandbox'.equalsIgnoreCase(ENVIRONMENT);
    }

    @TestVisible
    public static String getRaw() {
        return ENVIRONMENT;
    }

    @TestVisible
    public static Boolean isKnownEnvironment() {
        return isProduction() || isSandbox();
    }

    @TestVisible
    public static String getLogLevel() {
        return LOG_LEVEL;
    }

    @TestVisible
    public static Boolean isLogAtivo() {
        return LOG_ATIVO;
    }

    @TestVisible
    public static Boolean isMockEnabled() {
        return HABILITA_MOCK;
    }

    @TestVisible
    public static Boolean isModoTesteAtivo() {
        return MODO_TESTE_ATIVO;
    }

    @TestVisible
    public static Decimal getTimeoutCallout() {
        return TIMEOUT_CALLOUT;
    }

    @TestVisible
    public static Boolean isFlowsDisabled() {
        return DESATIVAR_FLOWS;
    }

    // Métodos de atualização dos campos

    @TestVisible
    public static void updateEnvironment(String newEnvironment) {
        if (String.isNotBlank(newEnvironment) && (newEnvironment.equalsIgnoreCase('production') || newEnvironment.equalsIgnoreCase('sandbox'))) {
            try {
                // Realiza o SELECT para pegar o último registro criado
                ConfiguracaoSistema__c conf = [SELECT Id, Ambiente__c FROM ConfiguracaoSistema__c 
                                               ORDER BY CreatedDate DESC LIMIT 1];
                if (conf == null) {
                    conf = new ConfiguracaoSistema__c(SetupOwnerId = UserInfo.getOrganizationId());
                }
                conf.Ambiente__c = newEnvironment;
                update conf;

                ENVIRONMENT = newEnvironment.toLowerCase();
            } catch (Exception ex) {
                System.debug('⚠️ Erro ao atualizar Custom Setting Ambiente: ' + ex.getMessage());
            }
        } else {
            throw new IllegalArgumentException('Ambiente inválido. Deve ser "production" ou "sandbox".');
        }
    }

    @TestVisible
    public static void updateLogLevel(String newLogLevel) {
        if (String.isNotBlank(newLogLevel) && (newLogLevel.equalsIgnoreCase('info') || newLogLevel.equalsIgnoreCase('error') || newLogLevel.equalsIgnoreCase('warn'))) {
            try {
                // Realiza o SELECT para pegar o último registro criado
                ConfiguracaoSistema__c conf = [SELECT Id, Log_Level__c FROM ConfiguracaoSistema__c 
                                               ORDER BY CreatedDate DESC LIMIT 1];
                if (conf == null) {
                    conf = new ConfiguracaoSistema__c(SetupOwnerId = UserInfo.getOrganizationId());
                }
                conf.Log_Level__c = newLogLevel;
                update conf;

                LOG_LEVEL = newLogLevel.toLowerCase();
            } catch (Exception ex) {
                System.debug('⚠️ Erro ao atualizar Custom Setting Log Level: ' + ex.getMessage());
            }
        } else {
            throw new IllegalArgumentException('Nível de Log inválido. Deve ser "INFO", "ERROR", ou "WARN".');
        }
    }

    @TestVisible
    public static void updateLogAtivo(Boolean newLogAtivo) {
        try {
            // Realiza o SELECT para pegar o último registro criado
            ConfiguracaoSistema__c conf = [SELECT Id, Log_Ativo__c FROM ConfiguracaoSistema__c 
                                           ORDER BY CreatedDate DESC LIMIT 1];
            if (conf == null) {
                conf = new ConfiguracaoSistema__c(SetupOwnerId = UserInfo.getOrganizationId());
            }
            conf.Log_Ativo__c = newLogAtivo;
            update conf;

            LOG_ATIVO = newLogAtivo;
        } catch (Exception ex) {
            System.debug('⚠️ Erro ao atualizar Custom Setting Log Ativo: ' + ex.getMessage());
        }
    }

    @TestVisible
    public static void updateHabilitaMock(Boolean newHabilitaMock) {
        try {
            // Realiza o SELECT para pegar o último registro criado
            ConfiguracaoSistema__c conf = [SELECT Id, Habilita_Mock__c FROM ConfiguracaoSistema__c 
                                           ORDER BY CreatedDate DESC LIMIT 1];
            if (conf == null) {
                conf = new ConfiguracaoSistema__c(SetupOwnerId = UserInfo.getOrganizationId());
            }
            conf.Habilita_Mock__c = newHabilitaMock;
            update conf;

            HABILITA_MOCK = newHabilitaMock;
        } catch (Exception ex) {
            System.debug('⚠️ Erro ao atualizar Custom Setting Habilita Mock: ' + ex.getMessage());
        }
    }

    @TestVisible
    public static void updateModoTesteAtivo(Boolean newModoTesteAtivo) {
        try {
            // Realiza o SELECT para pegar o último registro criado
            ConfiguracaoSistema__c conf = [SELECT Id, Modo_Teste_Ativo__c FROM ConfiguracaoSistema__c 
                                           ORDER BY CreatedDate DESC LIMIT 1];
            if (conf == null) {
                conf = new ConfiguracaoSistema__c(SetupOwnerId = UserInfo.getOrganizationId());
            }
            conf.Modo_Teste_Ativo__c = newModoTesteAtivo;
            update conf;

            MODO_TESTE_ATIVO = newModoTesteAtivo;
        } catch (Exception ex) {
            System.debug('⚠️ Erro ao atualizar Custom Setting Modo Teste Ativo: ' + ex.getMessage());
        }
    }

    @TestVisible
    public static void updateTimeoutCallout(Decimal newTimeout) {
        try {
            // Realiza o SELECT para pegar o último registro criado
            ConfiguracaoSistema__c conf = [SELECT Id, Timeout_Callout__c FROM ConfiguracaoSistema__c 
                                           ORDER BY CreatedDate DESC LIMIT 1];
            if (conf == null) {
                conf = new ConfiguracaoSistema__c(SetupOwnerId = UserInfo.getOrganizationId());
            }
            conf.Timeout_Callout__c = newTimeout;
            update conf;

            TIMEOUT_CALLOUT = newTimeout;
        } catch (Exception ex) {
            System.debug('⚠️ Erro ao atualizar Custom Setting Timeout Callout: ' + ex.getMessage());
        }
    }

    @TestVisible
    public static void updateDesativarFlows(Boolean newDesativarFlows) {
        try {
            // Realiza o SELECT para pegar o último registro criado
            ConfiguracaoSistema__c conf = [SELECT Id, Desativar_Flows__c FROM ConfiguracaoSistema__c 
                                           ORDER BY CreatedDate DESC LIMIT 1];
            if (conf == null) {
                conf = new ConfiguracaoSistema__c(SetupOwnerId = UserInfo.getOrganizationId());
            }
            conf.Desativar_Flows__c = newDesativarFlows;
            update conf;

            DESATIVAR_FLOWS = newDesativarFlows;
        } catch (Exception ex) {
            System.debug('⚠️ Erro ao atualizar Custom Setting Desativar Flows: ' + ex.getMessage());
        }
    }
}
