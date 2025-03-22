@isTest
public class TestDataSetup {

    /*
    pendente: adicionar docstring explicando a funcao orquestradora da classe
    */

    public static final String environment = 'test';
    public static final Logger.LogLevel log_level = Logger.LogLevel.DEBUG;
    public static final String className = 'TestDataSetup';
    public static final String triggerType = 'test';
    public static final String logCategory = 'test-data';

    public class TestSetupException extends Exception {}

    private static Map<String, String> testLabels = new Map<String, String>();

    @TestVisible
    public static void overrideLabel(String labelName, String value) {
        if (Test.isRunningTest()) {
            LoggerHelper.logInfo('Substituindo Label em teste: ' + labelName + ' = ' + value, className, 'overrideLabel', logCategory);
            testLabels.put(labelName, value);
        } else {
            throw new TestSetupException('Override de Label não permitido em produção.');
        }
    }

    @TestVisible
    public static String getLabel(String labelName) {
        return testLabels.containsKey(labelName) ? testLabels.get(labelName) : null;
    }

    @TestVisible
    public static Map<String, SObject> setupCompleteEnvironment() {
        LoggerHelper.logInfo('📌 [START] setupCompleteEnvironment', className, 'setupCompleteEnvironment', logCategory);

        Map<String, SObject> createdRecords = new Map<String, SObject>();

        try {
            // 🧑‍💼 Usuário e Responsável
            User user = UserTestDataSetup.createUser(null, null, null, null, null);
            Configuracoes__c responsavel = ResponsavelTestDataSetup.createResponsavel(null);

            // 🏢 Vertical e Originadores
            Vertical__c vertical = VerticalTestDataSetup.createVertical('Ultragaz Energia');
            Originador__c originadorPai = OriginadorTestDataSetup.createOriginador(vertical.Id, null);
            Originador__c originadorFilho = OriginadorTestDataSetup.createOriginadorFilho(vertical.Id, null, originadorPai.Id);

            // ⚡ Distribuidora e Tarifa
            Distribuidora__c distribuidora = DistribuidoraTestDataSetup.createDistribuidora(null, null);
            Tarifa_Distribuidora__c tarifa = DistribuidoraTestDataSetup.createTarifaDistribuidora(distribuidora);

            // 🔋 Gerador e Produto
            Gerador__c gerador = GeradorTestDataSetup.createGerador(null);
            Veiculo__c veiculo = GeradorTestDataSetup.createVeiculo(gerador.Id, null);
            Plataforma_de_Cobranca__c plataforma = GeradorTestDataSetup.createPlataformaCobranca(veiculo.Id, 'itau');
            Produto_do_Gerador__c produto = GeradorTestDataSetup.createProdutoDoGerador(vertical.Id, veiculo.Id, distribuidora.Id, plataforma.Id);

            // 🧪 Leads
            Lead leadPF = LeadTestDataSetup.createLeadPfQualificando(originadorPai.Id, distribuidora.Id);
            Lead leadPJ = LeadTestDataSetup.createLeadPjQualificando(originadorFilho.Id, distribuidora.Id, null);

            // 👤 Conta e Contato
            Account account = AccountTestDataSetup.createAccount(vertical.Id, originadorFilho.Id, null, '34.363.771/0001-65');
            Contact contact = AccountTestDataSetup.createContact(account.Id, null, null, null, null, null);

            // 💼 Oportunidade e Proposta
            Opportunity opportunity = OpportunityTestDataSetup.createOpportunity(account.Id, produto.Id, contact.Id);
            Proposta__c proposta = PropostaTestDataSetup.createProposta(opportunity.Id);

            // 📎 Documentos
            Documento_da_Conta__c docConta = DocumentoTestDataSetup.createDocConta(account.Id, null, null, null);
            Documento_do_Contato__c docContato = DocumentoTestDataSetup.createDocContato(contact.Id, null, null, null);
            Documento_da_Proposta__c docProposta = DocumentoTestDataSetup.createDocProposta(proposta.Id, null, null, null);
            Documento_da_Oportunidade__c docOportunidade = DocumentoTestDataSetup.createDocOportunidade(opportunity.Id, null, null);

            // ✍️ Assinaturas
            Signatario_do_Gerador__c signGerador = SignatarioTestDataSetup.createSignatarioGerador(gerador.Id, contact.Id);
            Signatario_da_Oportunidade__c signOpp = SignatarioTestDataSetup.createSignatarioOportunidade(docOportunidade.Id, contact.Id);

            // 🔗 Contrato e UC
            Contrato_de_Adesao__c contrato = UcTestDataSetup.createContratoDeAdesao(account.Id, contact.Id, veiculo.Id);
            UC__c uc = UcTestDataSetup.createUC(contrato.Id, produto.Id, proposta.Id);
            Contato_da_UC__c contatoDaUc = UcTestDataSetup.createContatoDaUC(uc.Id, uc.Rep_Legal__c, null);

            // 💰 Cobrança e 📞 Atendimento
            Cobranca__c cobranca = CobrancaTestDataSetup.createCobranca(uc.Id, null, 1000, null);
            Case caseRecord = CaseTestDataSetup.createCase(uc.Id);

            // ✅ Preenchendo o mapa de retorno
            createdRecords.put('User', user);
            createdRecords.put('Responsavel', responsavel);
            createdRecords.put('Vertical', vertical);
            createdRecords.put('OriginadorPai', originadorPai);
            createdRecords.put('OriginadorFilho', originadorFilho);
            createdRecords.put('Distribuidora', distribuidora);
            createdRecords.put('TarifaDistribuidora', tarifa);
            createdRecords.put('Gerador', gerador);
            createdRecords.put('Veiculo', veiculo);
            createdRecords.put('Plataforma', plataforma);
            createdRecords.put('Produto', produto);
            createdRecords.put('LeadPF', leadPF);
            createdRecords.put('LeadPJ', leadPJ);
            createdRecords.put('Account', account);
            createdRecords.put('Contact', contact);
            createdRecords.put('Opportunity', opportunity);
            createdRecords.put('Proposta', proposta);
            createdRecords.put('DocConta', docConta);
            createdRecords.put('DocContato', docContato);
            createdRecords.put('DocProposta', docProposta);
            createdRecords.put('DocOportunidade', docOportunidade);
            createdRecords.put('SignatarioGerador', signGerador);
            createdRecords.put('SignatarioOportunidade', signOpp);
            createdRecords.put('Contrato', contrato);
            createdRecords.put('UC', uc);
            createdRecords.put('ContatoDaUc', contatoDaUc);
            createdRecords.put('Cobranca', cobranca);
            createdRecords.put('Case', caseRecord);

            LoggerHelper.logInfo('✅ Ambiente de teste completo configurado.', className, 'setupCompleteEnvironment', logCategory);
            return createdRecords;

        } catch (Exception ex) {
            LoggerHelper.logError('❌ Erro ao configurar ambiente de testes', className, 'setupCompleteEnvironment', ex, logCategory);
            throw ex;
        }
    }

    @TestVisible
    public static void cleanUp(List<SObject> records) {
        LoggerHelper.logInfo('Iniciando limpeza de registros', className, 'cleanUp', logCategory);

        try {
            if (records == null || records.isEmpty()) {
                LoggerHelper.logInfo('Nenhum registro fornecido para limpeza.', className, 'cleanUp', logCategory);
                return;
            }

            delete records;
            LoggerHelper.logInfo('Registros excluídos com sucesso: ' + records.size(), className, 'cleanUp', logCategory);

        } catch (Exception ex) {
            LoggerHelper.logError('Erro ao limpar registros', className, 'cleanUp', ex, logCategory);
            throw ex;
        }
    }
}
