require 'guard/sprockets2/version'
require 'guard'
require 'guard/guard'
require 'rake'
require 'sprockets'

module Guard
  class Sprockets2 < Guard
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
    
    class Compiler
      def initialize(options = {})
        @sprockets = options[:sprockets]
        @assets_path = options[:assets_path]
        @precompile = options[:precompile]
        if defined?(Rails)
          @sprockets ||= Rails.application.assets
          @assets_path ||= File.join(Rails.public_path, Rails.application.config.assets.prefix)
          @precompile ||= Rails.application.config.assets.precompile
        else
          @assets_path ||= "#{Dir.pwd}/public/assets"
          @precompile ||= [ /\w+\.(?!js|css).+/, /application.(css|js)$/ ]
        end
      end
      
      def clean
        FileUtils.rm_rf @assets_path, :secure => true
      end
      
      def compile
        target = Pathname.new(@assets_path)
        @precompile.each do |path|
          @sprockets.each_logical_path do |logical_path|
            if path.is_a?(Regexp)
              next unless path.match(logical_path)
            else
              next unless File.fnmatch(path.to_s, logical_path)
            end

            if asset = @sprockets.find_asset(logical_path)
              filename = target.join(asset.digest_path)
              FileUtils.mkdir_p filename.dirname
              asset.write_to(filename)
              asset.write_to("#{filename}.gz") if filename.to_s =~ /\.(css|js)$/
            end
          end
        end
      end
    end
    
    protected
    
    def compile_assets
      @compiler.clean
      print "Compiling assets... " unless ENV["GUARD_ENV"] == "test"
      time_taken = time do
        @compiler.compile
      end
      UI.info "completed in #{time_taken} seconds"
    end
    
    def time(&block)
      start = Time.now
      yield
      finish = Time.now
      finish - start
    end
  end
end