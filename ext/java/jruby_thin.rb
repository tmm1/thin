require 'http11'

module Thin
  class HttpParser < Mongrel::HttpParser
    def execute(env, data, nparsed)
      new_nparsed = super

      if body = env.instance_variable_get(:@http_body)
        env.instance_variable_set(:@http_body, nil)

        # delete unused entries
        env.delete 'HTTP_CONTENT_LENGTH'
        env.delete 'HTTP_CONTENT_TYPE'

        # set defaults
        env['SERVER_SOFTWARE'] = Thin::SERVER
        env['PATH_INFO'] = env['REQUEST_PATH'] || ''
        env['QUERY_STRING'] ||= ''
        env['SCRIPT_NAME'] = ''
        env['rack.url_scheme'] ||= 'http'

        # convert to rack.input
        if body.size > 0
          env['rack.input'].write(body)
        end
      end

      new_nparsed
    end
  end

  InvalidRequest = Mongrel::HttpParserError
end
