require 'spec_helper'

describe Guard::Sprockets2::Compiler do
  
  def write_file(path, data)
    File.open(path, "wb") {|f| f.write data }
  end
  
  let(:tmp) { Pathname.new(File.expand_path("../../../../tmp", __FILE__)) }
  let(:sprockets) { Sprockets::Environment.new(tmp.to_s) }
  let(:assets_path) { tmp.join("assets") }
  let(:compiled_path) { tmp.join("compiled") }
  
  before do
    FileUtils.rm_rf tmp, :secure => true
    FileUtils.mkdir_p assets_path
    FileUtils.mkdir_p compiled_path
    sprockets.append_path(assets_path)
    write_file(assets_path.join("application.js").to_s, "//= require_tree .")
  end
  

  context 'preconfigured' do
    subject { Guard::Sprockets2::Compiler.new(:sprockets => sprockets, :assets_path => compiled_path.to_s) }
  
    it "compiles assets" do
      write_file(assets_path.join("hello.coffee").to_s, "console.log 'hello'")
      subject.compile
      asset = sprockets.find_asset("application.js")
      app_js_path = compiled_path.join(asset.digest_path)
    
      app_js_path.should exist
      app_js_path.read.should include("console.log('hello')")
    end
  end
  
  context 'with digest false' do
    subject { Guard::Sprockets2::Compiler.new(:sprockets => sprockets, :assets_path => compiled_path.to_s, :digest => false) }
    
    it "compiles assets without the digest" do
      write_file(assets_path.join("hello.coffee").to_s, "console.log 'hello'")
      subject.compile
      app_js_path = compiled_path.join('application.js')
      
      app_js_path.should exist
      app_js_path.read.should include("console.log('hello')")
    end
  end
  
  context 'with rails loaded' do
    before do
      write_file(assets_path.join("hello.coffee").to_s, "console.log 'hello2'")
      module Rails
      end
      Rails.stub(:public_path => tmp)
      Rails.stub_chain(:application, :assets).and_return(sprockets)
      Rails.stub_chain(:application, :config, :assets, :prefix).and_return('compiled')
      Rails.stub_chain(:application, :config, :assets, :precompile).and_return([ /\w+\.(?!js|css).+/, /application.(css|js)$/ ])
      subject.compile
    end

    subject { Guard::Sprockets2::Compiler.new }

    it "compiles assets" do
      asset = sprockets.find_asset("application.js")
      app_js_path = compiled_path.join(asset.digest_path)
    
      app_js_path.should exist
      app_js_path.read.should include("console.log('hello2')")
    end

    after { Object.send(:remove_const, :Rails) }
  end
end