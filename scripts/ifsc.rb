require 'json'

class IFSC
  attr_reader :data, :list
  def initialize
    @data = File.read 'data/IFSC.json'
    @list = File.read 'data/IFSC-list.json'
  end

  def lookup(code)
    @data[code]
  end
end