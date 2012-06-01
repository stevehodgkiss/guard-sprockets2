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
      manifest = {}
      @sprockets.send(:expire_index!)
      success = true
      @precompile.each do |path|
        @sprockets.each_logical_path do |logical_path|
          next unless path_matches?(path, logical_path)

          if asset = @sprockets.find_asset(logical_path)
            manifest[logical_path] = compile_asset(asset)
            break unless (success = !manifest[logical_path].nil?)
          end
        end
      end
      write_manifest(manifest) if success && @manifest
      success
    end

    protected

    def compile_asset(asset)
      path = @digest ? asset.digest_path : asset.logical_path
      filename = @target.join(path)
    
      FileUtils.mkdir_p filename.dirname
      asset.write_to(filename)
      asset.write_to("#{filename}.gz") if @gz && filename.to_s =~ /\.(css|js)$/
      path
    rescue => e
      puts unless ENV["GUARD_ENV"] == "test"
      UI.error e.message.gsub(/^Error: /, '')
      nil
    end

    def write_manifest(manifest)
      FileUtils.mkdir_p(@manifest_path)
      File.open("#{@manifest_path}/manifest.yml", 'wb') do |f|
        YAML.dump(manifest, f)
      end
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
      @manifest = options[:manifest]
      @manifest_path = options[:manifest_path]
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
      @manifest = false if @manifest.nil?
      @manifest_path = @assets_path if @manifest_path.nil?
    end
  end
end