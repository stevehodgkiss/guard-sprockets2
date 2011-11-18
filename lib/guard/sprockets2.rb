require 'guard/sprockets2/version'
require 'guard'
require 'guard/guard'
require 'sprockets'

module Guard
  class Sprockets2 < Guard
    autoload :Compiler, 'guard/sprockets2/compiler'
    
    def initialize(watchers = [], options = {})
      super
      @compiler = Compiler.new(options)
    end
    
    def start
      compile_assets
    end
    
    def run_all
      compile_assets
    end
    
    def run_on_change(paths = [])
      compile_assets
    end
    
    protected
    
    def compile_assets
      @compiler.clean unless options[:clean] == false
      print "Compiling assets... " unless ENV["GUARD_ENV"] == "test"
      successful = true
      time_taken = time do
        successful = @compiler.compile
      end
      UI.info "completed in #{time_taken} seconds" if successful
    end
    
    def time(&block)
      start = Time.now
      yield
      finish = Time.now
      finish - start
    end
  end
end