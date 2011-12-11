#!/usr/bin/env ruby

require 'johnnie'

class MyWalker < Johnnie::Walker
  root "/Users/vikas"

  for_({:type => :directory, :path => /Eagles/}) do |path|
    action("upcase") {
      puts path.upcase
    }
  end
end

MyWalker.run!


