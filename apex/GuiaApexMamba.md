# 🧱 Guia Master de Arquitetura Apex Mamba

> Este é o guia principal para toda e qualquer redação, estruturação, refatoração e evolução de código Apex na sua org.

📎 **Shortlink oficial:** [bit.ly/GuiaApexMamba](https://bit.ly/GuiaApexMamba)

Este documento organiza e referencia os padrões essenciais da sua base de código, unificando:
- Arquitetura
- Estilo
- Modularização
- Rastreabilidade
- Segurança e logging
- Estrutura REST
- Testabilidade
- Boas práticas para DTOs, helpers, validações, JSON, entre outros

---

# 🛡️ Padrão Universal de Consulta com Fallback Seguro

```apex
public class RecordHelper {
    public static SObject getById(Schema.SObjectType sobjectType, Id recordId, String queryFields) {
        if (recordId == null || String.isBlank(queryFields) || sobjectType == null) {
            return null;
        }

        String objectName = sobjectType.getDescribe().getName();
        String query = 'SELECT ' + queryFields + ' FROM ' + objectName + ' WHERE Id = :recordId LIMIT 1';

        List<SObject> records = Database.query(query);
        return records.isEmpty() ? null : records[0];
    }
}
```

✅ Elimina exceções de `List has no rows for assignment to SObject`  
✅ Compatível com qualquer objeto SObject  
✅ Reutilizável e rastreável  
✅ Padrão oficial para consultas por ID em todos os serviços  
✅ Recomendado: em testes de ID inválido, sempre use um ID **válido em morfologia**, mas inexistente na org:  
```apex
Id idInvalido = Id.valueOf('001000000000000AAA');
```

---

## 📓 Guias Referenciados

| Tema                         | Link Sugerido / Finalidade                                      |
|------------------------------|------------------------------------------------------------------|
| ✅ Guia de Redação e Arquitetura Apex (Master) | [bit.ly/GuiaApexMamba](https://bit.ly/GuiaApexMamba) (**este guia**) |
| 🔍 Revisão de Código Apex             | [bit.ly/GuiaApexRevisao](https://bit.ly/GuiaApexRevisao) |
| 🪪 Testes Unitários                    | [bit.ly/GuiaTestsApex](https://bit.ly/GuiaTestsApex)     |
| 🩵 Logger Estruturado                 | [bit.ly/GuiaLoggerApex](https://bit.ly/GuiaLoggerApex)   |
| 🌐 REST API JSON                      | [bit.ly/Guia_APIs_REST](https://bit.ly/Guia_APIs_REST)   |
| 🪩 Test Data Builders e Setup         | [bit.ly/TestDataSetup](https://bit.ly/TestDataSetup)     |
| 🔄 Comparações de Refatoração         | [bit.ly/ComparacaoApex](https://bit.ly/ComparacaoApex)   |
| ✅ Confirmação de Equivalência Funcional | [bit.ly/ConfirmacaoApex](https://bit.ly/ConfirmacaoApex) |

---

## 📆 Organização do Guia Master

Este guia está dividido em capítulos autônomos, com expansão contínua:

### ✅ Capítulo 1: Estrutura de Classe Apex
- Docstring no topo
- Logger `.start()` obrigatório
- Modularização com `@TestVisible`
- Métodos com responsabilidade única

### ✅ Capítulo 2: Logger como Rastreabilidade Institucional
- Log só em início, fim ou erro relevante
- Nada de logger em helpers, DTOs, transforms, callout internos
- Uso padrão de `FlowExecutionLog__c`
- Controle de nível de log por ambiente

### ✅ Capítulo 3: JSON com serializePretty
- Toda resposta REST e payload de log deve usar `JSON.serializePretty()`
- Exceção apenas para chamadas onde tamanho ou performance forem críticos

### ✅ Capítulo 4: RestServiceHelper
- Resposta estruturada `{ success, data, message, ref }`
- Exceções padronizadas com `.buildError(...)`
- Total desacoplamento da lógica de serialização REST

### ✅ Capítulo 5: Tipos de Classe e Roteiros
- REST Controllers
- Service Layers
- Queueables & Batches
- Validators & DTOs
- Callout Clients

### ✅ Capítulo 6: Naming Convention Institucional
- Verbos em métodos: `buscar`, `atualizar`, `enviar`
- Substantivos em classes: `UcService`, `PropostaClient`, `LeadValidator`
- DTOs nomeados como `ProdutoRequestDTO`, `UcResponseDTO`

### ✅ Capítulo 7: Patterns de Testes
- Isolamento por método
- Testes nomeados por padrão BDD (`testMetodo_QuandoCondicao_EntaoResultado`)
- Testes com mocks claros: `HttpCalloutMock`, `TestDataSetup`
- Assertivas obrigatoriamente com output real (ex: `obtido: ' + var`)
- Nunca validar logs (`FlowExecutionLog__c`) em testes

### ✅ Capítulo 8: FlowExecutionLog como Log Central de Integração
- Inbound: request + response
- Outbound: payload + retorno
- Serialização sempre via `.serializePretty`
- Logs disponíveis ao time de CDI
- Uso diferenciado por nível de log: `ERROR`, `INFO`, `DEBUG`

### ✅ Capítulo 9: Custom Settings de Configuração de Ambiente

**Observação:** Custom Settings não possuem regras de validação. Portanto, a validação de valores como picklists (`Log_Level__c`) deve ser feita em código Apex — preferencialmente via `CustomSettingManager.cls`.

**Exemplo de enforcement em código:**
```apex
Set<String> niveisPermitidos = new Set<String>{ 'ERROR', 'INFO', 'WARNING', 'DEBUG' };
if (!niveisPermitidos.containsIgnoreCase(config.Log_Level__c)) {
    throw new CustomException('Log_Level__c inválido: ' + config.Log_Level__c);
}
```

- **Nome:** `ConfiguracaoSistema__c` (tipo Hierarchy)
- **Campos sugeridos:**
  - `Log_Ativo__c` (Checkbox)
  - `Log_Level__c` (Picklist: `ERROR`, `INFO`, `DEBUG`)
  - `Habilita_Mock__c` (Checkbox)
  - `Ambiente__c` (Text)
  - `Modo_Teste_Ativo__c` (Checkbox)
  - `Habilita_Log_JSON__c` (Checkbox)
  - `Timeout_Callout__c` (Number)
  - `Endpoint_GCP__c` (URL/Text)
  - `Notificar_Erros__c` (Checkbox)
  - `Desativar_Flows__c` (Checkbox): controla se os flows devem ser desativados logicamente, usado em testes e ambiente QA.

#### ✅ Valores recomendados:
- **Log_Level__c:** `ERROR`, `INFO`, `WARNING`, `DEBUG`
- **Ambiente__c:** `Production`, `Sandbox`, `Scratch`, `QA`, `UAT`, `Dev`
- **Timeout_Callout__c:** `120000` (ms)
- **Endpoint_GCP__c:** `https://storage.googleapis.com/client-docs`

> Esses campos controlam dinamicamente o comportamento do Logger, mocks, callouts e rastreamento de integrações em todos os ambientes.

### ✅ Capítulo 10: Exemplos Reais da Org (em expansão)
- ProdutoRestController
- ControllerExportReports
- FileUploaderQueueable
- UcService
- TriggerContaHandler

---

## ✍️ Contribuindo com o Guia

- Toda nova classe deve ser redigida com base neste guia
- Sugestões de melhoria devem ser documentadas e discutidas com base nos capítulos
- Ao revisar código de terceiros, referencie o capítulo violado
- O guia cresce junto com a sua arquitetura

---

Este é o seu **padrão institucional autoral**.  
Modularidade, rastreabilidade e clareza — do início ao deploy.  

🧠🔥
