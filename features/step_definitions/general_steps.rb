Given /^I setup the example (\w+) app for testing$/ do |app|
  @app = app
  system "cp -r examples/#{app}_app tmp/aruba/#{app}_app"
  And "I cd to \"#{app}_app\""
end

Given /^I clean the generated assets$/ do
  FileUtils.rm_rf "tmp/aruba/#{@app}_app/public/assets"
end

When /^I wait (\d+) seconds$/ do |seconds|
  sleep(seconds.to_i)
end

When /^I stop the process$/ do
  process = processes.first
  pid = process[1].instance_variable_get("@process").pid
  Process.kill("INT", pid)
end

Then /^the hello asset should be compiled$/ do
  files = Dir["tmp/aruba/#{@app}_app/public/assets/*.js"]
  files.count.should eq 1

  file = files.first
  File.read(file).should include("console.log('Hello')")
end

Then /^the goodbye asset should be compiled$/ do
  files = Dir["tmp/aruba/#{@app}_app/public/assets/*.js"]
  files.count.should eq 1

  file = files.first
  File.read(file).should include("console.log('Goodbye')")
end