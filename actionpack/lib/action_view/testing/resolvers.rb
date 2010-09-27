require 'action_view/template/resolver'

module ActionView #:nodoc:
  # Use FixtureResolver in your tests to simulate the presence of files on the
  # file system. This is used internally by Rails' own test suite, and is
  # useful for testing extensions that have no way of knowing what the file
  # system will look like at runtime.
  class FixtureResolver < PathResolver
    attr_reader :hash

    def initialize(hash = {})
      super()
      @hash = hash
    end

  private

    def query(path, exts, formats)
      query = Regexp.escape(path)
      exts.each do |ext|
        query << '(' << ext.map {|e| e && Regexp.escape(".#{e}") }.join('|') << '|)'
      end

      templates = []
      @hash.select { |k,v| k =~ /^#{query}$/ }.each do |_path, source|
        handler, format = extract_handler_and_format(_path, formats)
        templates << Template.new(source, _path, handler,
          :virtual_path => _path, :format => format)
      end

      templates.sort_by {|t| -t.identifier.match(/^#{query}$/).captures.reject(&:blank?).size }
    end
  end

  class NullResolver < ActionView::PathResolver
    def query(path, exts, formats)
      handler, format = extract_handler_and_format(path, formats)
      [ActionView::Template.new("Template generated by Null Resolver", path, handler, :virtual_path => path, :format => format)]
    end
  end

end

