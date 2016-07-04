module ModulesHelper
    
    def googlemerchant_active?
        Object.const_defined?('TradoGooglemerchantModule') ? true : false
    end
end