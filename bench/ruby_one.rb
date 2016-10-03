require 'bundler'
Bundler.require(:default)
require 'benchmark'
require 'liquid/c'

include Benchmark         # we need the CAPTION and FORMAT constants

class BenchFileSystem
  def read_template_file(template_path)
    File.read 'dummy-template.liquid'
  end
end
Liquid::Template.file_system = BenchFileSystem.new


n = 100
list = (1..1000).to_a
Benchmark.benchmark(CAPTION, 7, FORMAT, ">avg:") do |x|
  tf = x.report("for:")   { for i in 1..n; tpl = Liquid::Template.parse("{% include 'dummy-template' %}").render("array" => list); end }
  [tf/n]
end
