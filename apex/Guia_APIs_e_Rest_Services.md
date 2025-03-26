# 🌐 Guia Oficial de REST Services e Integrações Externas – v2025
> _Padrão unificado para serviços REST, integrações com APIs e respostas estruturadas_

---

## 🌟 Guias relacionados
- https://bit.ly/GuiaApexRevisao
- https://bit.ly/GuiaLoggerApex
- https://bit.ly/Guia_APIs_REST
- https://bit.ly/GuiaTestsApex
- https://bit.ly/TestDataSetup
- https://bit.ly/ComparacaoApex
- https://bit.ly/ConfirmacaoApex

---

## 🌟 Objetivo
Estabelecer diretrizes padronizadas para:
- Criação de classes REST com `@RestResource`
- Tratamento de erros e validação de entradas
- Comunicação com serviços externos via HTTP
- Respostas padronizadas com `RestServiceHelper`
- Testes unitários para endpoints REST e integrações externas

---

# 🌐 Guia Oficial de REST Services e Integrações Externas – v2025
> _Padrão unificado para serviços REST, integrações com APIs e respostas estruturadas_

---

## 🌟 Guias relacionados
- [Guia Apex - Revisão e Padrões](https://bit.ly/GuiaApexRevisao)
- [Guia de Testes Unitários Apex](https://bit.ly/GuiaTestsApex)
- [TestDataSetup Central](https://bit.ly/TestDataSetup)
- [Guia Logger + Mock](https://bit.ly/GuiaLoggerApex)

---

## 📄 Status Code Padrão (HTTP)
Os seguintes códigos são oficialmente utilizados em nossa arquitetura REST:

| Código | Descrição                        | Uso no Helper                     |
|--------|----------------------------------|----------------------------------|
| 200    | OK                               | Resposta direta (pouco usado)     |
| 202    | Accepted                         | `accepted(...)`                   |
| 400    | Bad Request                      | `badRequest(...)`                 |
| 401    | Unauthorized                     | `unauthorized(...)`               |
| 404    | Not Found                        | `notFound(...)`                   |
| 406    | Not Acceptable (Conflito)        | `notAcceptable(...)`              |
| 500    | Internal Server Error            | `internalServerError(...)`        |

> Todos esses códigos são compatíveis com [RFC 9110 - HTTP Semantics (IETF)](https://datatracker.ietf.org/doc/html/rfc9110)

---

(continua com o restante do conteúdo já incluso...)



## 🧱 Estrutura Padrão de Classe REST

```apex
@RestResource(urlMapping='/updateLead')
global with sharing class LeadUpdateRestService {

    @HttpPost
    global static void updateLeadFromJson() {
        try {
            RestServiceHelper.validateAccessToken('Access_token', Label.BEARER_UPDATE_LEAD);

            Map<String, Object> body = RestServiceHelper.getRequestBody();
            String leadId = (String) body.get('Id');
            if (String.isBlank(leadId)) {
                RestServiceHelper.badRequest('Campo Id do Lead ausente.');
                return;
            }

            Lead lead = getLeadById(leadId);
            if (lead.IsConverted) {
                throw new RestServiceHelper.ConflictException('Lead já qualificado.');
            }

            RestServiceHelper.mapFieldsFromRequest(body, lead, 'Lead');
            update lead;

            RestServiceHelper.accepted('Lead atualizado.', new Map<String, Object>{
                'LeadId' => lead.Id,
                'Status' => lead.Status
            });

        } catch (RestServiceHelper.AccessException e) {
            RestServiceHelper.unauthorized(e.getMessage());
        } catch (RestServiceHelper.BadRequestException e) {
            RestServiceHelper.badRequest(e.getMessage());
        } catch (RestServiceHelper.ConflictException e) {
            RestServiceHelper.notAcceptable('Conflito: ' + e.getMessage());
        } catch (Exception e) {
            if (Test.isRunningTest()) RestServiceHelper.lastExceptionMessage = e.getMessage();
            RestServiceHelper.internalServerError('Erro inesperado.', e.getMessage());
        }
    }

    private static Lead getLeadById(String leadId) {
        try {
            return [SELECT Id, IsConverted, Status FROM Lead WHERE Id = :leadId LIMIT 1];
        } catch (QueryException e) {
            throw new RestServiceHelper.NotFoundException('Lead não encontrado.');
        }
    }
}
```

---

## 🪩 Classe Base: `RestServiceHelper`

Classe reutilizável para padronizar respostas e comportamentos REST. 
Inclui:

### ✅ Funções principais:
- `validateAccessToken(...)`: valida token enviado via header
- `getRequestBody()`: converte JSON do corpo da requisição
- `mapFieldsFromRequest(...)`: aplica campos JSON sobre um `SObject`
- `sendResponse(...)`: gera resposta padronizada em JSON

### ❌ Exceções personalizadas:
- `AccessException`, `BadRequestException`, `NotFoundException`, `ConflictException`

### 🔎 Exemplo de uso em testes:
```apex
@TestVisible private static String lastExceptionMessage;
```

### 📂 Código completo
```apex
public abstract class RestServiceHelper {

    @TestVisible private static final String environment = Label.ENVIRONMENT;
    @TestVisible private static final String log_level = Label.LOG_LEVEL;
    private static final String className = 'RestServiceHelper';
    private static final String logCategory = 'REST';

    @TestVisible private static String lastExceptionMessage;

    public class AccessException extends Exception {}
    public class BadRequestException extends Exception {}
    public class NotFoundException extends Exception {}
    public class ConflictException extends Exception {}

    public static void unauthorized(String message) {
        sendResponse(401, message, null);
    }
    public static void badRequest(String message) {
        sendResponse(400, message, null);
    }
    public static void notFound(String message) {
        notFound(message, null);
    }
    public static void notAcceptable(String message) {
        notAcceptable(message, null);
    }
    public static void internalServerError(String message) {
        internalServerError(message, null);
    }
    public static void accepted(String message) {
        accepted(message, null);
    }

    public static void notFound(String message, Object details) {
        sendResponse(404, message, details);
    }
    public static void notAcceptable(String message, Object details) {
        sendResponse(406, message, details);
    }
    public static void internalServerError(String message, Object details) {
        sendResponse(500, message, details);
    }
    public static void accepted(String message, Object details) {
        sendResponse(202, message, details);
    }

    public static void sendResponse(Integer statusCode, String message, Object details) {
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.statusCode = statusCode;
        Map<String, Object> response = new Map<String, Object>{ 'message' => message };
        if (details != null) {
            response.put('details', details);
        }
        RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(response));
    }

    public static void validateAccessToken(String headerName, String expectedTokenPrefix) {
        String accessToken = RestContext.request.headers.get(headerName);
        if (accessToken == null || !accessToken.startsWith(expectedTokenPrefix)) {
            throw new AccessException('Token de acesso inválido ou ausente.');
        }
    }

    public static Map<String, Object> getRequestBody() {
        RestRequest req = RestContext.request;
        if (req.requestBody == null || String.isBlank(req.requestBody.toString())) {
            throw new BadRequestException('O corpo da requisição está vazio.');
        }
        try {
            return (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
        } catch (Exception e) {
            throw new BadRequestException('Erro ao processar o corpo da requisição.');
        }
    }

    public static void mapFieldsFromRequest(Map<String, Object> requestBody, SObject record, String objectName) {
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Schema.SObjectType objectType = globalDescribe.get(objectName.toLowerCase());
        if (objectType == null) {
            throw new IllegalArgumentException('Objeto inválido: ' + objectName);
        }
        Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
        for (String fieldName : requestBody.keySet()) {
            if (fieldMap.containsKey(fieldName)) {
                Object fieldValue = requestBody.get(fieldName);
                if (fieldValue != null) {
                    record.put(fieldName, fieldValue);
                }
            } else {
                System.debug('Campo ignorado: ' + fieldName + ' (não encontrado no objeto ' + objectName + ')');
            }
        }
    }
}
```

---

## 🔄 Integração com APIs externas (Outbound Callouts)

### 🔒 Exemplo de chamada com tratamento de erro
```apex
public class ExternalApiService {
    public static String callApi(String endpoint, String token, String payload) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', token);
        req.setBody(payload);

        try {
            HttpResponse res = new Http().send(req);
            if (res.getStatusCode() != 200) {
                throw new RestServiceHelper.BadRequestException('Erro ao chamar API externa.');
            }
            return res.getBody();
        } catch (Exception e) {
            throw new RestServiceHelper.InternalServerErrorException('Falha ao integrar com serviço externo: ' + e.getMessage());
        }
    }
}
```

---

## 🧰 Testes de Serviços REST

### 🧰 Exemplo: Teste de POST com validação de token e status
```apex
@isTest
private class LeadUpdateRestServiceTest {

    @TestSetup
    static void setupTestData() {
        TestDataSetup.setupCompleteEnvironment();
        FlowControlManager.disableFlows();
    }

    static void setRestContext(String json, String token) {
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/updateLead';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(json);
        RestContext.request.headers.put('Access_token', token);
        RestContext.response = new RestResponse();
    }

    @isTest
    static void testLeadUpdateWithValidInput() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        setRestContext(JSON.serialize(new Map<String, Object>{ 'Id' => lead.Id }), Label.BEARER_UPDATE_LEAD);
        LeadUpdateRestService.updateLeadFromJson();

        System.assertEquals(202, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('Lead atualizado'));
    }
}
```

---

## ✅ Conclusões

- Toda resposta REST deve ser estruturada com código e mensagem JSON
- Testes devem cobrir todos os status esperados (202, 400, 401, 404, 406, 500)
- Nenhuma exceção deve vazar sem captura
- Toda entrada deve ser validada com segurança
- Reutilize `RestServiceHelper` sempre que possível

> 🧠 REST sem padrão é REST sem rastreabilidade. Aqui não. #OrgBlindada

