# autocoder.vim

Creating appropriate classes and unit tests in a Rails project improves your
design. However, their creation process tends to be painful in whatever editor
you use.

So I wrote this plugin.

## Feature: auto-creating class and unit specs

Type `:AC`. Vim will ask you what's the path of the class you want to create:

    Type the path (e.g store/cart/item):

If you type `store/special_cart`, it will generate the following two files:

* `lib/store/special_cart.rb`

```ruby
module Store
  class SpecialCart
    def initialize(options)
      @options = options
    end

    private

    attr_reader :options
  end
end
```

* `spec/lib/store/special_cart_spec.rb`

```ruby
require "store/special_cart"

describe Store::SpecialCart do
  describe "#some_method" do
    it "returns true" do

    end
  end
end
```

## Feature: auto-creating contract classes

Creating contract tests is tedious. Given you have a class like this one:

```ruby
# lib/user.rb
class User
  def name
    # ...
  end
end
```

Type `:AContract`. This will create the following file:

```ruby
# spec/contracts/lib/user_contract.rb
shared_examples_for "a user" do
  subject { User.new }

  it "responds to name" do
    subject.should respond_to(:name)
  end
end
```

Explaining the idea behind contract tests is beyond the scope of this readme.

### Known issues

* it only works for files in the lib dir
* it only works with RSpec
* if the file already exists, it'll add the boilerplate code anyway

Please, send patches to fix these problems.

### License

MIT. Do what you want with it, but please consider contributing back :)
