require 'find'
require 'optparse'

module Johnnie
  class Walker
    # Class macros

    @@instance = nil
    @@clauses  = []
    @@options  = {}

    # This is a hack to get dynamic scoping. This variable is set to
    # the path being acted upon so that the 'action' method can
    # have access to it.

    @@current_path = nil

    class << self
      def root(path)
        @@root = path
      end

      def is_type(path, type)
        case type
        when :file
          File.file?(path)
        when :directory
          File.directory?(path)
        else
          raise "Unknown file type!"
        end
      end

      def all_true(conds, path)
        conds.keys.reduce(true) { |ret, key|
          case key
          when :type
            ret and is_type(path, conds[key])
          when :path
            ret and (path =~ conds[key])
          end
        }
      end

      def for_path(path, &block)
        for_({:path => path}, &block)
      end

      def for_type(type, &block)
        for_({:type => type}, &block)
      end

      # Run the block for a path that satisfies ALL of the
      # supplied conditions

      # conds is a hash of all conditions
      # example: {:path => /foo/, :type => :file}

      def for_(conds, &block)
        @@clauses << {:conditions => conds, :action => block}
      end

      # TODO: Find a better name for this method
      def action(verb='', &block)
        if @@options[:dry_run]
          puts "Would #{verb} #{@@current_path}"
        else
          block.call
        end
      end

      def parse!
        OptionParser.new do |opts|
          opts.banner = "Usage: #{$0} [options]"

          opts.on("-h", "--help", "Print this help message") do
            puts opts
            exit(1)
          end

          opts.on("-d", "--dry-run", "Dry run, do not modify anything") do
            @@options[:dry_run] = true
          end

          opts.on("-r", "--root ROOT", "Specify the root directory (default: @@root)") do |r|
            root(r)
          end
        end.parse! ARGV
      end

      def run!
        parse!

        Find.find(@@root) do |path|
          @@clauses.each { |clause|
            if all_true(clause[:conditions], path)
              @@current_path = path
              clause[:action].call(path)
            end
          }
        end
      end
    end

    # Instance methods

    def initialize
      if @@instance == nil
        @@instance = super
      end

      @@instance
    end
  end
end
