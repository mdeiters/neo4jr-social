require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Neo4jr::FormatHandler do

  it 'returns pure json by default' do
    get '/'
    last_response.body.should_not include(html_space = '&nbsp;')
    last_response.headers['Content-Type'].should include('application/json')
  end

  it 'returns htmlized json if a browser request' do
    get '/', {}, {'HTTP_ACCEPT' => 'text/html'}
    last_response.body.should include(html_space = '&nbsp;')
    last_response.headers['Content-Type'].should include('text/html')
  end
  
  it 'always returns utf compliant text' do
    get '/'
    last_response.headers['Content-Type'].should include('charset=utf-8')
  end
  
end
