# frozen_string_literal: true

class ActionA < ActiveAct::ApplicationAction
  def call(*args, **kwargs)
    { foo: 1 }
  end
end

class ActionB < ActiveAct::ApplicationAction
  def call(params, **_kwargs)
    { bar: params[:foo] + 1 }
  end
end

RSpec.describe ActiveAct do
  it "has a version number" do
    expect(ActiveAct::VERSION).not_to be nil
  end

  it "permite encadear actions com .then" do
    result = ActionA.call.then(ActionB)
    puts "RESULT VALUE: ", result.value.inspect
    puts "RESULT ERROR: ", result.error.inspect
    expect(result).to be_a(ActiveAct::ActionResult)
    expect(result.success?).to eq(true)
    expect(result.value).to eq({ bar: 2 })
  end
end
