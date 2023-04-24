module AdminsBackofficeHelper

    def translate_attribute(object = nil, attribute = nil)
        if attribute && object
            object.model.human_attribute_name(attribute)
        else
            "Informe os parâmetros corretamente"
        end
    end
end
