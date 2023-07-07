require 'rspec'

require_relative '../build_v4.rb'

describe ColorSetter do
  let(:color_setter) { ColorSetter.new }

  describe '#set_colors' do
    it 'displays colored output' do
      expect { color_setter.set_colors }.to output("\e[31mError: Something went wrong!\e[0m\n\e[32mSuccess: Package build completed!\e[0m\n\e[33mWarning: This package has missing dependencies.\e[0m\n").to_stdout
    end
  end
end
