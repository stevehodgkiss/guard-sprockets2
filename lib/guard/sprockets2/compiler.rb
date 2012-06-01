module Guard
  class Sprockets2::Compiler
    def initialize(options = {})
      configure(options)
      @manifest = Sprockets::Manifest.new(@sprockets, @assets_path)
    end
  
    def clean
      @manifest.clean(@keep)
    end
  
    def compile
      @sprockets.send(:expire_index!)
      success = true
      @precompile.each do |path|
        @sprockets.each_logical_path do |logical_path|
          next unless path_matches?(path, logical_path)

          success = @manifest.compile(logical_path)
        end
      end
      success
    end

    protected
  
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
      @keep = options[:keep]
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
      @keep = 0 if @keep.nil?
    end
  end
end