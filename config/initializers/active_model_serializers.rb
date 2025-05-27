# frozen_string_literal: true

ActiveModelSerializers.config.adapter = :json_api
ActiveModelSerializers.config.key_transform = :underscore
ActiveModelSerializers.config.jsonapi_include_toplevel_object = true
ActiveModelSerializers.config.jsonapi_version = '1.0'
