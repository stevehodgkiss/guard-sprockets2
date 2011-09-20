require 'guard/sprockets2/version'
require 'guard'
require 'guard/guard'
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
        @digest = options[:digest]
        @digest = true if @digest.nil?
        if defined?(Rails)
          @sprockets ||= Rails.application.assets
          @assets_path ||= File.join(Rails.public_path, Rails.application.config.assets.prefix)
          @precompile ||= Rails.application.config.assets.precompile
        else
          @assets_path ||= "#{Dir.pwd}/public/assets"
          @precompile ||= [ /\w+\.(?!js|css).+/, /application.(css|js)$/ ]
        end
        @target = Pathname.new(@assets_path)
      end
      
      def clean
        FileUtils.rm_rf @assets_path, :secure => true
      end
      
      def compile
        @sprockets.send(:expire_index!)
        success = true
        @precompile.each do |path|
          @sprockets.each_logical_path do |logical_path|
            if path.is_a?(Regexp)
              next unless path.match(logical_path)
            else
              next unless File.fnmatch(path.to_s, logical_path)
            end

            if asset = @sprockets.find_asset(logical_path)
              success = compile_asset(asset)
              break unless success
            end
          end
        end
        success
      end
      
      def compile_asset(asset)
        filename = @digest ? @target.join(asset.digest_path) : @target.join(asset.logical_path)
        
        FileUtils.mkdir_p filename.dirname
        asset.write_to(filename)
        asset.write_to("#{filename}.gz") if filename.to_s =~ /\.(css|js)$/
        true
      rescue => e
        puts unless ENV["GUARD_ENV"] == "test"
        UI.error e.message.gsub(/^Error: /, '')
        false
      end
    end
    
    protected
    
    def compile_assets
      @compiler.clean
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