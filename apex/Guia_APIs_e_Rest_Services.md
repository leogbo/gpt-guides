# 🌐 Guia Oficial de REST Services e Integrações Externas – v2025
> _Padrão unificado para serviços REST, integrações com APIs e respostas estruturadas_

---

## 🎯 Objetivo
Estabelecer diretrizes padronizadas para:
- Criação de classes REST com `@RestResource`
- Tratamento de erros e validação de entradas
- Comunicação com serviços externos via HTTP
- Respostas padronizadas com `RestServiceHelper`
- Testes unitários para endpoints REST e integrações externas

---

## 🧱 Estrutura Padrão de Classe REST

```apex
@RestResource(urlMapping='/updateLead')
global with sharing class LeadUpdateRestService {

    @HttpPost
    global static void updateLeadFromJson() {
        try {
            // 1. Validação de token
            RestServiceHelper.validateAccessToken('Access_token', Label.BEARER_UPDATE_LEAD);

            // 2. Corpo da requisição
            Map<String, Object> body = RestServiceHelper.getRequestBody();
            String leadId = (String) body.get('Id');
            if (String.isBlank(leadId)) {
                RestServiceHelper.badRequest('Campo Id do Lead ausente.');
                return;
            }

            // 3. Recuperação e validação
            Lead lead = getLeadById(leadId);
            if (lead.IsConverted) {
                throw new RestServiceHelper.ConflictException('Lead já qualificado.');
            }

            // 4. Aplicação de campos e atualização
            RestServiceHelper.mapFieldsFromRequest(body, lead, 'Lead');
            update lead;

            // 5. Retorno
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

## 🧩 Classe `RestServiceHelper`
> Veja [versão completa aqui](#)

Funções oferecidas:
- Validação de token: `validateAccessToken(...)`
- Parsing de JSON: `getRequestBody()`
- Atualização via JSON: `mapFieldsFromRequest(...)`
- Respostas estruturadas: `sendResponse(...)`, `badRequest(...)`, `accepted(...)`, etc.
- Exceções customizadas para controle REST: `AccessException`, `NotFoundException`, etc.

Inclui suporte a testes com:
```apex
@TestVisible private static String lastExceptionMessage;
```

---

## 🔁 Integração com APIs externas (Outbound Callouts)

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

## 🧪 Testes de Serviços REST

### 🧪 Exemplo: Teste de POST com validação de token e status
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


