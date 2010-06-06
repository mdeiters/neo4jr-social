module Neo4jr
  module FormatHandler
    def self.registered(app)
      app.send :mime_type, :json, 'application/json'
      app.set :assume_xhr_is_js, true
      app.helpers self
      app.before do
        if request.env['HTTP_ACCEPT'] && request.env['HTTP_ACCEPT'].include?('text/html')
          format :html
        else
          format :json
        end
        charset 'utf-8'
      end      
    end
    
    def render_for_format(data)
      case format
        when :json : return JsonPrinter.render(data)
        when :html : return JsonPrinter.render_html(data)
        else
           fail("#{format} is not a supported MIME type")
      end
    end
       
    def format(val=nil)
      unless val.nil?
       type = mime_type(val)
       fail "Unknown mime type #{val}\nTry registering the extension with a mime type" if type.nil?

       @format = val.to_sym
       response['Content-Type'].sub!(/^[^;]+/, type)
      end

      @format
    end

    def charset(val=nil)
      fail "Content-Type must be set in order to specify a charset" if response['Content-Type'].nil?

      if response['Content-Type'] =~ /charset=[^;]+/
        response['Content-Type'].sub!(/charset=[^;]+/, (val == '' && '') || "charset=#{val}")
      else
        response['Content-Type'] += ";charset=#{val}"
      end unless val.nil?

      response['Content-Type'][/charset=([^;]+)/, 1]
    end
  end
end
