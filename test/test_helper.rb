require 'test/unit'
require File.dirname(__FILE__) + '/../lib/goaloc'
require "shoulda"
require 'rubygems'
require 'mocha'

def self.should_create_directory(directory)
  should "create #{directory} directory" do
    assert File.exists?(File.join(@tmp_dir, directory))
    assert File.directory?(File.join(@tmp_dir, directory))
  end
end

def self.should_create_files(*files)
  should "create #{files.join ', '}" do
    files.each do |file|
      assert File.exists?(File.join(@tmp_dir, file))
      assert File.file?(File.join(@tmp_dir, file))        
    end
  end
end
