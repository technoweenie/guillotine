module Guillotine
  class TransitionAdapter < Adapter
    def initialize(new_adapter, old_adapter)
      @new_adapter = new_adapter
      @old_adapter = old_adapter
    end

    def add(url, code = nil, options = nil)
      created_code = @old_adapter.add(url, code, options)
      @new_adapter.add(url, created_code, options)
    end

    def find(code)
      url = @new_adapter.find(code)
      return url if url

      return unless url = @old_adapter.find(code)
      @new_adapter.add(url, code)
      url
    end

    def code_for(url)
      code = @new_adapter.code_for(url)
      return code if code

      return unless code = @old_adapter.code_for(url)
      @new_adapter.add(url, code)
      code
    end

    def clear(url)
      @new_adapter.clear(url)
      @old_adapter.clear(url)
    end

    def clear_code(code)
      @new_adapter.clear_code(code)
      @old_adapter.clear_code(code)
    end

    def reset
      @new_adapter.reset
      @old_adapter.reset
    end
  end
end
