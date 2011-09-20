module Guard
  class Sprockets2::Compiler
    def initialize(options = {})
      configure(options)
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
          next unless path_matches?(path, logical_path)

          if asset = @sprockets.find_asset(logical_path)
            success = compile_asset(asset)
            break unless success
          end
        end
      end
      success
    end

    protected

    def compile_asset(asset)
      filename = @digest ? @target.join(asset.digest_path) : @target.join(asset.logical_path)
    
      FileUtils.mkdir_p filename.dirname
      asset.write_to(filename)
      asset.write_to("#{filename}.gz") if @gz && filename.to_s =~ /\.(css|js)$/
      true
    rescue => e
      puts unless ENV["GUARD_ENV"] == "test"
      UI.error e.message.gsub(/^Error: /, '')
      false
    end
  
    def path_matches?(path, logical_path)
      if path.is_a?(Regexp)
        path.match(logical_path)
      else
        File.fnmatch(path.to_s, logical_path)
      end
    end
  
    def configure(options)
      @sprockets = options[:sprockets]
      @assets_path = options[:assets_path]
      @precompile = options[:precompile]
      @digest = options[:digest]
      @gz = options[:gz]
      set_defaults
    end
  
    def set_defaults
      if defined?(Rails)
        @sprockets ||= Rails.application.assets
        @assets_path ||= File.join(Rails.public_path, Rails.application.config.assets.prefix)
        @precompile ||= Rails.application.config.assets.precompile
      else
        @assets_path ||= "#{Dir.pwd}/public/assets"
        @precompile ||= [ /\w+\.(?!js|css).+/, /application.(css|js)$/ ]
      end
      @digest = true if @digest.nil?
      @gz = true if @gz.nil?
    end
  end
end