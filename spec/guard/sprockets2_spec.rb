require 'spec_helper'

describe Guard::Sprockets2 do
  
  before do
    @options = {:option => true}
    @compiler = mock(:clean => true, :compile => true)
    Guard::Sprockets2::Compiler.stub(:new => @compiler)
    @guard = described_class.new(['watchers'], @options)
  end
  
  %w[ start run_all run_on_change ].each do |method|
    describe "##{method}" do
      it "cleans" do
        @compiler.should_receive(:clean)
        @guard.send(method)
      end
      
      it "compiles" do
        @compiler.should_receive(:compile)
        @guard.send(method)
      end
    end
  end
  
end